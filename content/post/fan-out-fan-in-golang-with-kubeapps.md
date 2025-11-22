---
title: "Fan-Out and Fan-In Golang channels in Kubeapps"
date: 2022-05-20T15:38:13+10:00
draft: false
categories: [ "programming", "kubeapps", "golang" ]
slug: "fan-out-fan-in-golang-kubeapps"
tags: ["article"]
commentable: true
---

During a career as a software engineer, every now and then you come across a [design pattern](https://en.wikipedia.org/wiki/Software_design_pattern) that becomes your darling for a few years following the discovery. Other design patterns are useful, but not so special that you want to tell the world about them.

Up until recently, my favourite design pattern was the [state pattern](https://en.wikipedia.org/wiki/State_pattern) which allows encapsulating different behaviours (implementations of an interface) in different classes so that an object can delegate its functionality to different state implementations which can be update at runtime. But more recently, while using a lot of concurrency in certain [Kubeapps](https://github.com/vmware-tanzu/kubeapps/) services, I've fallen in love with another design pattern - the fan-out/fan-in messaging pattern (or a form of it).

<!--more-->

Or, if you prefer you can watch a video demo'ing the fan-out/fan-in with the game Infinifactory:

{{< youtube id="hRQpU-w8fEY" >}}

## The problem

In Kubeapps, we have a [pluggable API server for supporting different package formats for Kubernetes]( {{<relref "kubeapps-apis-kubernetes-packages">}}), allowing users to install, update and delete packages on a cluster with a consistent UX experience across different packaging systems.

![Kubeapps coupled to Helm](/img/kubeapps-apis-kubernetes-packages/kubeapps-plugable.png)

But how do we handle returning a page of ordered, aggregated available packages from different plugins in a consistent and extensible way, without the client needing to care how the result is composed?

![Aggregation of available packages](/img/fan-out-fan-in-golang-kubeapps/available-packages-aggregated.png)

## The Fan-Out

When a request is received by the core packages API handler for a page of 20 available packages, the handler fans this request out, [creating a go-routine for each plugin](https://github.com/vmware-tanzu/kubeapps/blob/6eaeca0d5f23f443af8ed311bbdc225671661c72/cmd/kubeapps-apis/core/packages/v1alpha1/packages_fan_in.go#L169-L224), where each go-routine sends the results back to the fan-out routine, one at a time, each plugin via its own channel. This allows the fanned-out requests to the plugins to be handled concurrently, looking something like:

![The fan-out](/img/fan-out-fan-in-golang-kubeapps/fan-out.png)

It's important to note that each channel here is **unbuffered**, so the go-routine created for each plugin will only fetch the next page of results when the current results are exhausted from the channel, and so does only the minimum required amount of work.

At this point, the fan-out/fan-in routine has three channels of data. How does this help the API handler aggregate ordered data from the configured plugins?

## The Fan-In

Once data is coming in on the input channels, the fan-out/fan-in routine does the following in a loop:

- Ensure it has the latest item from each channel available for comparison,
- Selects the minimum item from those latest available from each channel,
- Sends the selected minimum value down its own channel back to the handler.

This routine will continue to loop until it has either sent the requested number of items back to the API handler, or it has exhausted all items from all plugins.

The comparison used to select the minimum is just a string comparison of the related Kubernetes resource `Metadata.Name`, since this is what the Kubernetes API server returns.

## Requesting further pages

With that, the fan-in is able to pass the correct number of aggregated individual items back to the API handler, in order, from the respective plugins which themselves fetch in parallel. It is not overly resource intensive since each plugin is only fetching its own next page of items when required, and importantly, each step is comparatively simple to reason about on its own.

Finally, to ensure that the client can request a subsequent page of results and continue to receive the correct, ordered, aggregated result from each of the plugins, the aggregated API returns an opaque `nextPageToken` back to the client. In reality, it's just a JSON-encoded string such as can be seen in the above screenshot of the debugging console: `{"helm.packages":77,"kapp_controller":13}`. When the next request from the client includes this token, the API handler passes each offset to each plugin with when setting up the fan-out, so that each plugin is able to begin at the correct point.

## Conclusion

And that's it! You can read the source for the [API handler for `GetAvailablePackagesummaries`](https://github.com/vmware-tanzu/kubeapps/blob/f41a14d588662b5c83e22186a10c6aded2f6dd89/cmd/kubeapps-apis/core/packages/v1alpha1/packages.go#L56-L104) which is kept quite simple, as well as the more substantial code for the [fan-out and fan-in with go channels](https://github.com/vmware-tanzu/kubeapps/blob/f41a14d588662b5c83e22186a10c6aded2f6dd89/cmd/kubeapps-apis/core/packages/v1alpha1/packages_fan_in.go#L43-L158).

It's so nice to have the primitives of go-routines and channels as part of the core language, and opens up a new set of message-based design patterns to fall in love with in your work!
