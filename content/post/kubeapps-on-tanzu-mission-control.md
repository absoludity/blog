---
title: "Kubeapps on Tanzu Mission Control via Pinniped"
date: 2021-02-25T11:40:02+11:00
draft: false
tags: [ "tutorial", "kubeapps", "tmc", "vmware", "pinniped" ]
---

We've been able to run [Kubeapps in a multi-cluster setup on various Kubernetes clusters]( {{< relref "kubeapps-on-tkg-management-cluster" >}} ) for a while now, but this was dependent on the Kubeapps' user being authenticated in a way that all the clusters trust. Up until now, this meant having all the clusters [configured to trust the same OIDC identity provider](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#configuring-the-api-server), which is not possible in some Kubernetes environments.

Particularly, this meant we were unable to demonstrate multi-cluster Kubeapps with clusters created by [Tanzu Mission Control](https://tanzu.vmware.com/mission-control) since we can't specify API server options, such as OIDC configuration, when creating a cluster in TMC. But that requirement has now changed thanks to a new project called [Pinniped](https://pinniped.dev/).

<!--more-->
The following video is an overview of running Kubeapps on TMC via pinniped: {{< youtube id="DGMWRZ7SyqY" >}}

## Kubeapps + Pinniped

The [Pinniped project](https://pinniped.dev), also from VMware, enables OIDC authentication to a cluster without any configuration of the cluster's API server. It does this by extending the Kubernetes API to include an endpoint that can exchange a valid OIDC `id_token` for a short-lived cluster certificate that identifies that same user and groups as the original token.

Pinniped itself is currently focusing on `kubectl` access to a cluster and is explicitly not (yet) supporting other clients, such as the Kubeapps web application. So we wrote a small service in [Rust](https://www.rust-lang.org/) called [`pinniped-proxy`](https://github.com/vmware-tanzu/kubeapps/blob/master/docs/user/using-an-OIDC-provider-with-pinniped.md) (I'll post more about that experience separately) which in our stack, ensures that any request from a user directed at an API server has its OIDC credential exchanged for a short-lived cluster certificate from that cluster before continuing on its journey. Note that the resulting certificate does not grant any privileges, it simply contains the same authentication information as the `id_token` to identify the username and groups associated with the user. The cluster RBAC still decides what that user can and cannot do as always.

You can read the docs for [configuring Kubeapps to use an OIDC provider with pinniped](https://github.com/vmware-tanzu/kubeapps/blob/master/docs/user/using-an-OIDC-provider-with-pinniped.md) in a generic cluster, with the following Tanzu Mission Control specific note.

## Configure pinniped on your cluster

TMC clusters are created with pinniped already on the cluster and at the time of writing, the version managed by the cluster is fine to use. At some point TMC will be upgrading to pinniped 0.6.0 which has a backwards incompatible change that [currently breaks our pinniped-proxy integration](https://github.com/vmware-tanzu/kubeapps/issues/2426). I'll update this post once we've adjusted to that change.

The first thing to do is to ensure that the installed pinniped service knows how to verify OIDC `id_tokens` for your identity provider. You can do this by creating a `JWTAuthenticator` resource within the same namespace that pinniped is installed - which in the case of TMC's default installation is `vmware-system-tmc`:

```yaml
kind: JWTAuthenticator
apiVersion: authentication.concierge.pinniped.dev/v1alpha1
metadata:
  name: jwt-authenticator
  namespace: vmware-system-tmc
spec:
  issuer: https://your-oidc-issuer.example.com
  audience: default
  claims:
    groups: groups
    username: email
  tls:
    certificateAuthorityData: <your-oidc-issuers-tls-cert-auth-data>
```

This enables pinniped to verify an `id_token` from your identity provider as being signed correctly. In our `values.yaml` for Kubeapps, we will need to ensure Kubeapps knows to include the `pinniped-proxy` service:

```yaml
pinnipedProxy:
  enabled: true
  defaultPinnipedNamespace: vmware-system-tmc
```

The last line is required here because by default pinniped will be in `pinniped-concierge` but TMC includes it in its own `vmware-system-tmc` namespace. Finally, our multi-cluster configuration for Kubeapps needs to identify individually each cluster that is using pinniped. This is because you may have a mixture of clusters, some using pinniped, others may be using OIDC:

```yaml
clusters:
  - name: tmc-aws-1
    pinnipedConfig:
      enabled: true
  - name: tmc-aws-1
    pinnipedConfig:
      enabled: true
    apiServiceURL: https://abcd123.elb.amazonaws.com:443
    serviceToken: ...
    certificateAuthorityData: ...
```

The rest of your `values.yaml` will include the [normal OIDC configuration for Kubeapps](https://github.com/vmware-tanzu/kubeapps/blob/master/docs/user/using-an-OIDC-provider.md#deploying-an-auth-proxy-to-access-kubeapps) and you can `helm install` away. In the demo above I'm using VMware's Cloud Services Platform for Single Sign On (SSO) and two TMC clusters in AWS.
