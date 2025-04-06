+++
title="Domain Object and Sink Modules"
+++

To recap, we have the following domain objects in our system:

- `ApprovalStatus`
- `CardHolerData`
- `CashCard`
- `EnrichedTransaction`
- `Transaction`

![Domain Objects](/workshop/content/assets/domain-objects.svg)

We have good news: We don't need to write any new domain objects in this lab! That said, we do need to use these domain objects in our new **Sink** microservice.

When we made our **Processor** application, we chose to duplicate the `CashCard` and `Transaction` domain objects in that app. But, now we're contemplating duplicating _five_ domain objects in yet another application.

We've decided to apply the _"third time's the charm"_ principle here: given this would be the third duplication of the same exact domain objects, we've decided to extract them as a shared module.

```editor:open-file
file: ~/exercises/cashcard-transaction-domain/src/main/java/example/cashcard/domain/ApprovalStatus.java
description: "Review the Domain Objects module"
```

We won't go into the details about how multi-module projects work in Spring projects, but you can learn more about them by looking through the `build.gradle` and `settings.gradle` files, and by working through [this guide](https://spring.io/guides/gs/multi-module).

## The Sink Module

In the previous lab we wrote a **Processor** microservice to enrich `Transaction` data, emitting `EnrichedTransaction`s to our middleware. That application followed a similar structure and pattern as our **Source** application and module.

Can you guess what pattern the **Sink** will follow?

That's right: a **Sink** module with it's own Spring Cloud Stream microservice application!

As in previous labs, we've provide a scaffolding for you. Please explore the `cashcard-transaction-sink` module now, which you'll notice is contains mostly-empty classes for the following:

- A sink configuration
- A sink test

```editor:open-file
file: ~/exercises/cashcard-transaction-sink/src/main/java/example/cashcard/sink/CashCardTransactionSink.java
description: "Explore the Sink module"
```

With that context, let's develop our **Sink** application.
