---
title: "Kubeapps on a TKG Management Cluster"
date: 2020-09-23T11:01:36+10:00
draft: true
tags: [ "tutorial", "kubeapps", "tkg", "vmware" ]
---

## Prepare a Kubeapps configuration

First create a kubeappsClientSecret and kubeappsCookieSecret (`$kubeappsClientSecret` etc.)

Here's a `values.yaml` file which you can use to deploy Kubeapps, substituting in the same values from earlier steps:

```yaml
# Ensure that Kubeapps is reachable externally via the frontend svc as an ELB
# currently without TLS.
# TODO: Try updating to use an ELB for the Kubeapps frontend service.
frontend:
  service:
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-backend-protocol: http
    port: 80
    type: LoadBalancer

# Setup the oauth2-proxy running on the frontend to handle the OIDC authentication
# for us.
authProxy:
  enabled: true
  provider: oidc
  clientID: kubeapps-oauth2-proxy
  clientSecret: <KUBEAPPS_CLIENT_SECRET>
  cookieSecret: <KUBEAPPS_COOKIE_SECRET>
  additionalFlags:
    - --oidc-issuer-url=https://<DEX_SVC_LB_HOSTNAME>
    # IMPORTANT: Overwrite the scope option to include the workload clusters' clientids in the audience.
    - --scope=openid email groups audience:server:client_id:my-oidc-cluster audience:server:client_id:second-oidc-cluster
    # TODO: Update to provide the dex ca via --provider-ca-file and mounting etc.
    - --ssl-insecure-skip-verify=true
    # Since Kubeapps is running without TLS, can't use secure cookies
    - --cookie-secure=false
    # If you need to access the actual token in the frontend for testing, uncomment the following.
    # - --set-authorization-header=true
```

As noted, the most important part here is the `--scope` argument which requests not only the normal `openid email groups` scopes but also requests the ...
