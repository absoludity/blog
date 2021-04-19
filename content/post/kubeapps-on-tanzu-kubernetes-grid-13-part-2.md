---
title: "Kubeaps on Tanzu Kubernetes Grid 1.3"
date: 2021-04-19T21:39:49+10:00
draft: false
---

This is the second post in a series of two post detailing the steps that I took to install Kubeapps running on a TKG 1.3 cluster on AWS configured to allow user authentication via the TKG identity management:

* The first post focuses on the [TKG 1.3 setup required to get a workload clusters with identity management]( {{<relref "kubeapps-on-tanzu-kubernetes-grid-13" >}} ) (using your chosen identity provider),
* This followup post details the related Kubeapps installation and configuration on the TKG 1.3 workload cluster.

The details below assume that you've already successfully created your TKG management and workload clusters configured with identity management and verified that you can authenticate with both clusters using your identity provider (ie. not admin credentials).

## Configuring Pinniped to trust your identity provider directly

### Some background about Pinniped versions

First, query your workload cluster to see whether any JWT Authenticators are already defined and you'll find that there is one which is setup to trust tokens issued by the pinniped-supervisor service on your management cluster:

```
kubectl get jwtauthenticators -A --kubeconfig /tmp/id_workload_test_kubeconfig

NAMESPACE            NAME                    ISSUER
pinniped-concierge   tkg-jwt-authenticator   https://domain-of-pinniped-supervisor-on-mgt-cluster
```

This is used by pinniped from the `kubectl` CLI, but it's not (yet) clear to me whether it'll be possible for a web app, such as Kubeapps, to use this issuer as Kubeapps only knows about your client-id and identity provider which issues the JWT token credentials.

Also, the fact that this existing JWT Authenticator is namespaced (in the `pinniped-concierge` namespace) shows us that the version of Pinniped running on a TKG 1.3 system is earlier than Pinniped 0.6.0, as [Pinniped 0.6.0 had a backwards incompatible change](https://github.com/vmware-tanzu/pinniped/releases/tag/v0.6.0) where JWT Authenticators (along with all Pinniped Concierge APIs) were moved to be cluster-scoped rather than per-namespace. If you explicitly check the deployment, you'll see that it is in fact v0.4.1 of Pinniped:

```
    image: projects.registry.vmware.com/tkg/pinniped:v0.4.1_vmware.1
```

This will have implications for the version of Kubeapps we can use since Kubeapps had to update to support the backwards incompatible change of pinniped 0.6.0 (in v2.3.0 of Kubeapps released as part of the Kubeapps chart v5.4.0), so we'll need to use the prior version.

### Create an OAuth2 client-id for Kubeapps to use

We want to setup Kubeapps with its own OAuth2 client-id, rather than re-using the client-id intended for the kubectl CLI. Do this by going back to your identity provider that you used when setting up your [TKG 1.3 cluster with identity management]( {{<relref "kubeapps-on-tanzu-kubernetes-grid-13" >}} ) and creating a new client-id, noting the id and secret. Don't worry about specifying the callback url just yet, you can leave it blank or enter a dummy one if required, we'll come back and fill this in after installing Kubeapps.

### Create a Pinniped JWT Authenticator for the new client-id

Create a new `kubeapps-jwt-authentication` JWT Authenticator to tell Pinniped that your workload cluster trusts tokens issued by your identity provider. For me this is a JWT Authenticator with google as the issuer since I'm using google for authentication:

```yaml
apiVersion: authentication.concierge.pinniped.dev/v1alpha1
kind: JWTAuthenticator
metadata:
  name: kubeapps-jwt-authenticator
  namespace: pinniped-concierge
spec:
  audience: your client id
  claims:
    groups: "groups"
    username: "email"
  issuer: https://accounts.google.com
```

**Note:** I need to check with the pinniped folk whether they are happy for us users to do this, or whether we should be using the supervisor on the management cluster somehow (not sure how we can for a web-app like Kubeapps).

### Create the configuration values for Kubeapps and install

As mentioned, because TKG 1.3 is using an older version of Pinniped, we also need to use an older version of Kubeapps. Additionally, because of an issue we had in our Kubeapps chart, we need to specify the exact image version of our pinniped-proxy to use, as shown below:

```yaml
frontend:
  service:
    type: LoadBalancer
    port: 443
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-backend-protocol: http
      # Update the cert arn below once added to aws.
      # service.beta.kubernetes.io/aws-load-balancer-ssl-cert: <aws-arn-for-your-ssl-cert>
authProxy:
  enabled: true
  provider: oidc
  clientID: your client id
  clientSecret: your client secret
  # Create a random cookie secret with:
  # python -c 'import os,base64; print(base64.urlsafe_b64encode(os.urandom(16)).decode())'
  cookieSecret: your cookie secret
  additionalFlags:
    - --oidc-issuer-url=https://accounts.google.com # or your issuer URL
    - --scope=openid email
pinnipedProxy:
  enabled: true
  defaultAuthenticatorName: kubeapps-jwt-authenticator
  image:
    repository: bitnami/kubeapps-pinniped-proxy
    # Explicitly request the version of pinniped-proxy which supports the pre 0.6.0 version of pinniped.
    tag: 2.2.1-debian-10-r22
clusters:
  - name: default
    pinnipedConfig:
      enable: true
```

With this configuration, the specific version of Kubeapps can be installed with:

```
kubectl create ns kubeapps
helm upgrade --install kubeapps bitnami/kubeapps --version=5.3.4 --namespace kubeapps --values ~/path/to/your/above/values.yaml
```

Note that I've just used a `LoadBalancer` service type for the Kubeapps frontend above as I'm happy to use the default AWS load balancer DNS address for this test environment, but for anything other than a test environment you'd be best using Ingress and a cert-manager-issued TLS cert. To use a `LoadBalancer` like this in AWS as a TLS endpoint, I needed to do a couple of extra steps in AWS which I'll happily add to an appendix here as soon as someone asks :)

### Last steps to enable your user access

Once you know the address that you'll be using for your test Kubeapps setup, you'll need to go back and update your OAuth2 client details in your identity provider, adding your callback URL as `https://your.address.example.com/oauth2/callback`.

You will also need to ensure that the user with which you will be logging in has appropriate RBAC in the cluster to be able to query the API server.

```
kubectl create clusterrolebinding id-workload-test-rb --clusterrole cluster-admin --user your.user@example.com
```

With that, you should be able to login to Kubeapps on your TKG 1.3 workload cluster using that user and deploy some apps! Remember, if you have any issues, please take a look at the [Debugging auth failures when using OIDC](https://github.com/kubeapps/kubeapps/blob/master/docs/user/using-an-OIDC-provider.md#debugging-auth-failures-when-using-oidc) section of the documentation and if you're stuck, drop in on the [#kubeapps channel on Kubernetes slack](https://kubernetes.slack.com/archives/C9D3TSUG4).

