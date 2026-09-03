+++
title="Overview"
+++

Thus far, we have used the `java.util.function.supplier` interface to write a function that produces cash card transaction data for our application -- fake transactions in our case. The Spring Cloud Stream framework then calls this function on a **_fixed schedule_**, configurable via the property `spring.integration.poller.fixed-delay`.

This is a good way to constantly generate data. For example, our application invokes our data source on each invocation of the `Supplier`. Other applications might invoke databases, service APIs, or any number of other data sources.

This is great, but a real-world question arises: how does an application generate data when needed, or _on-demand_?

In our Family Cash Card use case, we might want to publish transaction data to our middleware immediately whenever a cash card is used for a purchase.
Even if our application provided a facility for this, such as exposing a REST endpoint, our current `Supplier` model of producing data on a fixed schedule will not work in this scenario.

## StreamBridge to the Rescue

Spring Cloud Stream provides a facility to "bridge" to middleware destinations on-demand. This bridge API is conveniently called `StreamBridge`, and it is backed by an interface called `StreamOperations`. The `StreamBridge` API can send records to a binding.

Thus, we could write a controller with a REST endpoint that allowed services to `POST` transaction data whenever cash card transactions occur. Sounds like fun, right?

Let's use `StreamBridge` and a REST controller to implement this use case.

## A new REST Controller

In this lab, we will see how to use the `StreamBridge` API to publish cash card transactions when an HTTP REST endpoint is invoked.

We've provided an empty REST controller and test for you to build upon for this functionality. Let's review the controller and its now.
