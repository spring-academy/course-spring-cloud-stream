+++
title="Overview"
+++

With previous labs we have built two different kinds of sources in Spring Cloud Stream, using `java.util.function.Supplier` for a fixed-schedule supplier, and the `StreamBridge` API for an on-demand supplier.

Let us move on to the next phase: processing the data we are sending to our middleware.

## Processing with Spring Cloud Stream

As we discussed in previous lessons, there are many use cases for event-driven systems. The goal is not to pipe data into a middleware just for fun – interested parties want to do something with that data!

It is common for organizations to perform many different actions upon their data, based on their business needs. Application developers encode those business needs as business _logic_ in applications. In Spring Cloud Stream systems, the data consumption from middleware will trigger that business logic.

This lab will focus on writing a **_Processor_** using the `java.util.function.Function` interface. We discussed writing processors in the Programming Model lessons in this course.

## Processor Applications

If the `java.util.function.Function` interface is the way to wire up Spring Cloud Stream to let us process our data, we need a place for our `Function` and related business logic to live.

We could add all of this code and logic to our **Source** application, but that would be a violation of the _separation of concerns_ principle. By definition, a **Source** has different concerns than a **Processor**. So, what to do?

Let's develop a new _**Processor application**_, which will consume the messages our **Source** application sends to the middleware and "do some stuff" with that data.

First, let's think about how processing transaction data might be valuable in our our Family Cash Card domain.
