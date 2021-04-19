---
title: "Tanzu Kubernetes Grid 1.3 with Identity Management"
date: 2021-04-19T06:42:43+10:00
draft: false
tags: [ "tutorial", "kubeapps", "tkg", "vmware" ]
---

Way back in 2020 I'd detailed how I'd setup a [Tanzu Kubernetes Grid 1.1 management cluster with OpenID Connect support]( {{<relref "tanzu-kubernetes-grid-tkg-first-experience" >}} ) (for single sign-on) before installing [Kubeapps with single sign-on on that management cluster]( {{< relref "kubeapps-on-tkg-management-cluster" >}} ).

Recently TKG 1.3 was released and the identity management support in TKG has changed significantly, so it's time to see what's different when setting up a TKG cluster with identity management as well as how we can run Kubeapps on TKG 1.3 with identity management. You will of course need to work through the [TKG 1.3 documentation for your environment](https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.3/vmware-tanzu-kubernetes-grid-13/GUID-index.html), I'll just highlight the significant points and small issues that I needed to work around, due to my environment.

This series of two post details the steps that I took to enable Kubeapps running on a TKG 1.3
cluster on AWS configured to allow users to access via the configured identity management:

* This post focuses on the TKG 1.3 setup required to get a workload clusters with identity management (using your chosen identity provider),
* the followup post details the related [Kubeapps installation and configuration]( {{<relref "kubeapps-on-tanzu-kubernetes-grid-13-part-2" >}} ) on TKG 1.3.

## Setting up a TKG 1.3 management cluster with identity management

### An all new `tanzu` CLI

The first difference is that we no longer use the `tkg` CLI, but rather a new integrated `tanzu` CLI which you will need to ensure is [installed and ready to use on your system](https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.3/vmware-tanzu-kubernetes-grid-13/GUID-install-cli.html). It seems that the `tanzu` CLI is a move towards a single CLI experience for all things Tanzu - good move!

### Setting up identity management - AKA single sign-on

Identity management is where TKG has changed quite significantly between TKG 1.1 and TKG 1.3. Previously, TKG workload clusters were configured at creation time with OIDC parameters for the Dex instance running on your management cluster, and the management cluster itself did not enable direct access via identity management at all. With TKG 1.3, the new [VMware Pinniped project](https://pinniped.dev) is being used so that identity management can be configured and updated at runtime and is also supported for accessing the management cluster.

It's worth reading through the [Enabling identity management docs](https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.3/vmware-tanzu-kubernetes-grid-13/GUID-mgmt-clusters-enabling-id-mgmt.html) to understand the new setup as well as create your oauth2 client id with your chosen identity provider (I'm using google in this example below, the docs recommend Okta)

### Creating your TKG 1.3 management cluster

I initially had errors when trying to create a management cluster on AWS, both via the `--ui` as well as via the console. It turned out that even though I'd used the ui installer and selected the "Automate creation of AWS CloudFormation stack" checkbox, the required profiles still did not exist, so my (later) console-based install attempts would fail with:

```bash
[cluster control plane is still being initialized, cluster infrastructure is still being provisioned], retrying
cluster creation failed, reason:'InstanceProvisionFailed @ Machine/kubeapps-tkg-13-2-test-control-plane-x2sw2', message:'1 of 2 completed'


Failure while deploying management cluster, Here are some steps to investigate the cause:

Debug:
    kubectl get po,deploy,cluster,kubeadmcontrolplane,machine,machinedeployment -A --kubeconfig /home/michael/.kube-tkg/tmp/config_RaAxrTtO
    kubectl logs deployment.apps/<deployment-name> -n <deployment-namespace> manager --kubeconfig /home/michael/.kube-tkg/tmp/config_RaAxrTtO

To clean up the resources created by the management cluster:
          tanzu management-cluster delete
Error: unable to set up management cluster: unable to wait for cluster and get the cluster kubeconfig: error waiting for cluster to be provisioned (this may take a
 few minutes): cluster creation failed, reason:'InstanceProvisionFailed @ Machine/kubeapps-tkg-13-2-test-control-plane-x2sw2', message:'1 of 2 completed'
```

Checking the logs as suggested indicated that the expected AWS InstanceProfiles didn't exist:

```bash
kubectl logs deployment.apps/capa-controller-manager -n capa-system manager --kubeconfig /home/michael/.kube-tkg/tmp/config_RaAxrTtO
...
E0414 04:01:43.434245       1 controller.go:257] controller-runtime/controller "msg"="Reconciler error" "error"="failed to create AWSMachine instance: failed to run instance: InvalidParameterValue: Value (control-plane.tkg.cloud.vmware.com) for parameter iamInstanceProfile.name is invalid. Invalid IAM Instance Profile name\n\tstatus code: 400, request id: ff25f867-8d16-49ef-bb9e-cc745ecd3b0c" "controller"="awsmachine" "name"="kubeapps-tkg-13-2-test-control-plane-drhmh" "namespace"="tkg-system"
```

Sure enough, if I then checked what `InstanceProfiles` exist within my account, I could see that similar but not the same profiles existed:

```bash
aws --profile my-profile iam list-instance-profiles | jq ".InstanceProfiles[] | .InstanceProfileName"
"control-plane.cluster-api-provider-aws.sigs.k8s.io"
"controllers.cluster-api-provider-aws.sigs.k8s.io"
...
"nodes.cluster-api-provider-aws.sigs.k8s.io"
...
```

For example, the error was because the InstanceProfile `control-plane.tkg.cloud.vmware.com` did not exist, whereas `control-plane.cluster-api-provider-aws.sigs.k8s.io` *did* exist. It turns out the existing `InstanceProfiles` were from last year when I installed TKG 1.1 and the required ones for 1.3 were, for reasons still not known to me, not yet present. A helpful TKG expert pointed me to the manual TKG 1.3 management cluster install on AWS instructions, specifically the [instructions to create the CloudFormation stack on AWS](https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.3/vmware-tanzu-kubernetes-grid-13/GUID-mgmt-clusters-config-aws.html#create-an-aws-cloudformation-stack-1).

When following those instructions, I had to include the `AWS_REGION` env var even though it was specified in my aws credentials file, but it did the trick:

```bash
AWS_PROFILE=my-profile AWS_REGION=us-east-1 tanzu management-cluster permissions aws set

Creating AWS CloudFormation Stack

Following resources are in the stack:

Resource                  |Type                                                                |Status
AWS::IAM::InstanceProfile |control-plane.tkg.cloud.vmware.com                                  |CREATE_COMPLETE
AWS::IAM::InstanceProfile |controllers.tkg.cloud.vmware.com                                    |CREATE_COMPLETE
...
```

With the correct profiles created, I was then able to get a management cluster running, though with a small issue.

### Tagging an AWS subnet

While following the [configuring identity management after management cluster deployment doc](https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.3/vmware-tanzu-kubernetes-grid-13/GUID-mgmt-clusters-configure-id-mgmt.html) I noticed that although my management cluster was created, some of the services were unable to be setup as load balancers:

```bash
  Warning  SyncLoadBalancerFailed  4m36s (x13 over 39m)  service-controller  Error syncing load balancer: failed to ensure load balancer: could not find any suitable subnets for creating the ELB
```

I'd hit this before when trying TKG 1.1 and once again, the reason it happened was that I'd initially selected the UI option for the TKG installer to create a new VPC, but after my initial install failed, I'd chosen to re-use that VPC (actually re-using the complete cluster config other than changing the name) when retrying, which meant that VPC subnets were not tagged with my new cluster name.

To fix this, I again navigated to the list of subnets for the region, for example, for us-east-1 you will find the list at [https://console.aws.amazon.com/vpc/home?region=us-east-1#subnets:sort=desc:tag:Name](https://console.aws.amazon.com/vpc/home?region=us-east-1#subnets:sort=desc:tag:Name). In this list you will see a `-public` and `-private` subnet prefixed by the name of your management cluster, for example, in my case I see:

![Management cluster subnets](/img/kubeapps-on-tkg-management-cluster/tkg-management-subnets.png)

If you click on the first subnet, the public one, the details will be displayed including a `Tags` tab. Click on the `Tags` tab and you should see that the subnet includes a tag for your management cluster, but in my case, it was for a previously failed management cluster name. I edited the tag to use the correct cluster name and after a few minutes the service had a load balancer.

### Ensuring the pinniped post-deploy job succeeds

With the load balancer now set I was able to continue following the [configuration of identity management after management cluster deployment documentation](https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.3/vmware-tanzu-kubernetes-grid-13/GUID-mgmt-clusters-configure-id-mgmt.html) and update the callbacks in my identity provider, but I was unable to generate a kubeconfig for use with my configured identity provider, instead getting the error:

```bash
tanzu management-cluster kubeconfig get --export-file /tmp/id_mgmt_test_kubeconfig

Error: failed to get pinniped-info from cluster: failed to get pinniped-info from the cluster
```

Checking the pinniped pods showed that pinniped runs a post-deploy job which depends on the pinniped supervisor load balancer being available, which in my case, had not been available at the time the job ran due to the missing subnet tags identified above. So this post-deploy job had exceeded the backoff limit (of 6 failures) while I as fixing the subnet tag and was no longer retrying.

To fix this, I edited the job to have a larger backoff limit (of 7), waited a few minutes and saw the job then complete successfully:

```bash
pinniped-post-deploy-job-ver-1-w5q8g   0/1     Error       0          66m
pinniped-post-deploy-job-ver-2-t2fc2   0/1     Completed   0          86s
```

I was then able to successfully authenticate via kubectl using my google account identity, following the instructions at the end of the [configuration of identity management after management cluster deployment documentation](https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.3/vmware-tanzu-kubernetes-grid-13/GUID-mgmt-clusters-configure-id-mgmt.html) to add a role-binding for my user.

So, management cluster complete with only a few environment-specific hiccups along the way!

## Setting up a TKG 1.3 workload cluster with identity management

Creating a workload cluster was as simple as copying the config that I'd just used successfully for the management cluster, changing the CLUSTER_NAME only, and then:

```
tanzu cluster create --file ~/.tanzu/tkg/clusterconfigs/workload.yaml
```

though check the [full documentation for details](https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.3/vmware-tanzu-kubernetes-grid-13/GUID-tanzu-k8s-clusters-deploy.html).

I then used very similar commands to grab an admin kubeconfig (ie. one that is setup with cert-based authentication, not using the identity management) for my new workload cluster:

```
tanzu cluster kubeconfig get kubeapps-tkg-13-workload-test --admin
```

and used that to verify for myself that the Kubernetes api server of the workload cluster in TKG 1.3 no longer sets any of the `--oidc-*` flags, instead it's Pinniped all the way down. Pinniped is already installed and configured on the workload cluster, so last of all, I created a non-admin kubeconfig (ie. one which will use the identity management):

```
tanzu cluster kubeconfig get kubeapps-tkg-13-workload-test --export-file /tmp/id_workload_test_kubeconfig
```

and then verified that, after creating a role-binding, I am able to use the cluster using my google identity:

```
kubectl create clusterrolebinding id-workload-test-rb --clusterrole cluster-admin --user my-user@example.com
kubectl get pods -A --kubeconfig /tmp/id_workload_test_kubeconfig
```

Success. Now we're ready to install Kubeapps on the workload cluster...
