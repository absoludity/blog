---
title: "Carvel kbld With Helm Post Render"
date: 2021-02-02T15:24:29+11:00
draft: false
categories: ["programming", "vmware", "carvel", "helm", "kubeapps"]
tags: ["article"]
---

For the past couple of years I've been working on the [Kubeapps project](https://kubeapps.com/), which until recently has been a UI dashboard for the [Helm project](https://helm.sh/) - providing a simple, web-based UI to deploy applications on [Kubernetes](https://kubernetes.io/).

I'm currently looking at generalising Kubeapps to support other Kubernetes packages formats, including [Carvel](https://carvel.dev/) from VMware of course. So I set out today to start learning more about Carvel, which in contrast to more monolithic tools like Helm, provides "a set of single-purpose, composable tools that aid in your application building, configuration and deployment to Kubernetes".

As an example of that composability, I found I can deploy a helm chart using a set of immutable images by utilizing Helm's new-ish support for [post rendering of a chart](https://helm.sh/docs/topics/advanced/#post-rendering). Here's how...

<!--more-->

## Grab the latest Kubeapps Helm chart

Create a temporary directory to work in and pull the latest Kubeapps Helm chart to use for the demonstration.

```bash
$ mkdir /tmp/imgbld-helm-test && cd /tmp/imgbld-helm-test
$ helm pull bitnami/kubeapps
$ ls -la
total 576
drwxrwxr-x  2 michael michael   4096 Feb  2 15:35 .
drwxrwxrwt 29 root    root    507904 Feb  2 15:36 ..
-rw-r--r--  1 michael michael  73071 Feb  2 15:35 kubeapps-5.0.0.tgz
```

## Generate an image lock file with kbld

The [kbld](https://carvel.dev/kbld/) tool is one of the Carvel set which finds all image references in your Kubernetes config and produces an image lock file so that the mutable tags often found in Kubernetes configs (especially those produced by Helm charts) can be switched for immutable references. To do this, we'll use the template output of the helm chart and pass that to `kbld` with the arg to create an image lock file:

```bash
$ helm template ./kubeapps-5.0.0.tgz | kbld -f - --imgpkg-lock-output ./kubeapps-5.0.0-images.yml
...
Succeeded

$ head ./kubeapps-5.0.0-images.yml
---
apiVersion: imgpkg.carvel.dev/v1alpha1
images:
- annotations:
    kbld.carvel.dev/id: docker.io/bitnami/kubeapps-apprepository-controller:2.0.1-scratch-r0
  image: index.docker.io/bitnami/kubeapps-apprepository-controller@sha256:7e66a2432ca21fd6acb895b7fa71a49bc2626333342c2187f54c4a9b672e7905
- annotations:
    kbld.carvel.dev/id: docker.io/bitnami/kubeapps-asset-syncer:2.0.1-scratch-r0
  image: index.docker.io/bitnami/kubeapps-asset-syncer@sha256:358ad22ef9d5fdbd1c3e34c0e8f61b153ed4d796c83ca3689799f7f604cd74db
- annotations:
```

Note that because Helm charts contain conditionals which can potentially include other services, you may need to run the above helm command with specific options to get all the images for your chart (or manually add other references to the resulting image lock file).

I also then manually edited the image lockfile so that I can test whether I can use the lock file to switch to arbitrary images of my choice, by setting one of the references to a non-existent docker registry `doesnt.exist.example.com`:

```yaml
---
apiVersion: imgpkg.carvel.dev/v1alpha1
images:
- annotations:
    kbld.carvel.dev/id: docker.io/bitnami/kubeapps-apprepository-controller:2.0.1-scratch-r0
  image: doesnt.exist.example.com/bitnami/kubeapps-apprepository-controller@sha256:7e66a2432ca21fd6acb895b7fa71a49bc2626333342c2187f54c4a9b672e7905
- annotations:
    kbld.carvel.dev/id: docker.io/bitnami/kubeapps-asset-syncer:2.0.1-scratch-r0
  image: index.docker.io/bitnami/kubeapps-asset-syncer@sha256:358ad22ef9d5fdbd1c3e34c0e8f61b153ed4d796c83ca3689799f7f604cd74db
- annotations:
...
```

## Create a wrapper for kbld to be used by Helm

[Helm's support for a post-rendering tool](https://helm.sh/docs/topics/advanced/#post-rendering) requires a single command that takes the templated config as standard input and returns the templated config to standard output. To ensure we can pass `kbld` as a command as the post-renderer that does this, as well as also includes the image lock file images, I created the following tiny wrapper and made it executable:

```bash
$ cat ./kbld-stdin
#!/usr/bin/bash
kbld -f ./kubeapps-5.0.0-images.yml -f -
```

## Deploy the chart via `kbld`

With that setup, we're ready to go! I can deploy my chart using `kbld` as a post-renderer to switch in the images from my image lock file:

```bash
$ helm install kubeapps ./kubeapps-5.0.0.tgz --namespace kubeapps --post-renderer ./kbld-stdin
...
```

I can then verify that the deployment included the correct images from my lockfile:

```bash
$ kubectl -n kubeapps get deployment kubeapps-internal-apprepository-controller -o jsonpath='{.spec.template.spec.containers[].image}'
doesnt.exist.example.com/bitnami/kubeapps-apprepository-controller@sha256:7e66a2432ca21fd6acb895b7fa71a49bc2626333342c2187f54c4a9b672e7905
```

## Implications

This is pretty neat because it means not only can I deploy my Helm chart locally with a specific set of immutable images, but also that:

* I can, for example, provide a single Helm chart to different customers/users each with their own image lock file to ensure they get their own (custom?) images from their internal registry.
* I can combine this with another Carvel tool, [imgpkg](https://carvel.dev/imgpkg/) to bundle the chart and all associated images into a tarball for use in an air-gapped environment (and `imgpkg` even takes care of updating my image references when copying my tar file to a new private registry).
