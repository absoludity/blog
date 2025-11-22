---
title: "What is Kubeapps"
date: 2020-09-28T10:06:28+10:00
draft: false
categories: [ "programming", "kubeapps", "vmware" ]
tags: ["article"]
commentable: true
---

For over a year now I've been working together with
[Andres](https://github.com/andresmgot) on the Kubeapps project at VMware
and have made various videos of new features that we've worked on, but I've
never stepped back to give an overview and answer the more general question,
"What is Kubeapps?" and show how those features work towards a single goal.

The goal of Kubeapps is to **help users and operators install and manage
applications on Kubernetes** and the following features work together to
achieve this goal:

## Simple configuration of app catalogs for your users

When you install Kubeapps on your cluster, your users will login to see a
catalog of apps which they can install into any namespace on the Kubernetes
cluster to which they have the required permissions. By default this catalog
will be the free [Bitnami Application
Catalog](https://bitnami.com/application-catalog) which is kept up-to-date
with the latest security fixes by VMware:

![Easy installation of Postgresql](/img/what-is-kubeapps/bitnami-catalog.png)

### Custom app catalogs

That said, with a simple configuration change it can just as easily include a
private catalog of charts specifically built on top of your organisations'
chosen base image using [VMware Tanzu Application
Catalog](https://tanzu.vmware.com/application-catalog).

A cluster operator can also update the [access-control for certain
users](https://github.com/vmware-tanzu/kubeapps/blob/master/docs/user/access-control.md#app-repositories)
so that those users can add other catalogs in a specific namespace, available only to
users of that namespace. This can even include private applications from
private catalogs if you choose to [configure the required secrets to pull
your private
images](https://github.com/vmware-tanzu/kubeapps/blob/master/docs/user/private-app-repository.md#associating-docker-image-pull-secrets-to-an-apprepository).
Users of the namespace can simply install the private app from the catalog
and the required secrets will be configured automatically as part of their
deployment.

### Operator support

Additionally, a cluster operator can enable the display and installation of
Kubernetes operators in the catalog. The following view shows the catalog
filtered to display only operators providing database apps.

![Operators in Kubeapps catalog](/img/what-is-kubeapps/catalog-filtered-operators.png)

## Easy self-service installation of apps by users

To ensure that users of an app catalog on Kubeapps can install their
applications without being overwhelmed by the myriad of options that are
typically available, Kubeapps presents a simple form with only the options
that the [Helm chart author determined to be most relevant](https://github.com/vmware-tanzu/kubeapps/blob/master/docs/developer/basic-form-support.md).
The following screenshot shows the options presented to a user when installing Postgresql:

![Easy installation of Postgresql](/img/what-is-kubeapps/postgres-form-deployment.png)

## Self-service updates and maintenance

Once applications have been installed by users, Kubeapps will ensure they
are aware when a new version of an app is available with the latest security fixes.

![App Upgrade indication](/img/what-is-kubeapps/app-upgrade.png)

Users can reconfigure an app at any time, upgrade to a newer version or roll
back to a previous version.

## Multi-cluster support

Finally, Kubeapps enables you, the cluster operator, to configure your
Kubeapps installation so that your users can install and manage applications
across multiple Kubernetes clusters, not just the cluster on which Kubeapps
is installed. You can see this in action in this short demo:

{{< youtube id="pzVMZGTK0vU" >}}

or you can also read more in our [multi-cluster
documentation](https://github.com/vmware-tanzu/kubeapps/blob/master/docs/user/deploying-to-multiple-clusters.md)
or browse the specific details required to [setup Kubeapps with multi-cluster
support on a specific Kubernetes environment - VMware Tanzu Kubernetes
Grid]({{< relref "kubeapps-on-tkg-management-cluster" >}}).

That's it! If you think I've missed an important Kubeapps feature or you have
questions about any of the above, you can leave a comment or join us on the
[kubeapps channel on Kubernetes
slack](https://kubernetes.slack.com/archives/C9D3TSUG4).
