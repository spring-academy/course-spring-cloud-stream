+++
title="Processor: Family Cash Card Use Case"
+++

In this lab, we will consume the data produced by our **Source** application, then _enrich_ the data by adding additional information about the card owner and the transaction.

Here is the scenario in detail:

1. Just as we have developed in previous labs, our **Source** application will generate fake cash card transactions and then send them to a Kafka topic.
2. We will create a new _enrichment processor_ that will do the following:
   1. **Consume** the sourced cash card transaction data.
   2. Call an `EnrichmentService` to add additional valuable information about the `CashCard` transactions. Once "enriched", the transaction data will contain the transaction **approval status** and **cardholder information**, such as the cardholder's name and billing address.
   3. Finally, it will **publish** the enriched cashcard transaction into another Kafka topic.

![Enricher application](/workshop/content/assets/enricher-app.svg)

But our project only has one application: our **Source** application. How are we going to create and run a second application?

## Our Multi-Module, Multi-Application Project

As we've described here, we are going to write a _second application_ that will enrich the data that our **Source** application extracts from the data-source and sends to the middleware. After we enrich the data, we'll publish that enriched data back to the middleware, where in theory yet another application could perform additional processing upon it -- perhaps us in a future lab!

![Enricher application](/workshop/content/assets/source-and-enricher.svg)

We have good news: Spring Boot supports multiple applications in one project. We won't go into the details about how multi-module projects work, but you can learn more about them in [this guide](https://spring.io/guides/gs/multi-module).

### The Enricher Application Scaffolding

Take a moment to open the **Editor** tab and explore the directory structures of the two applications within. You should see two main directories:

- `exercises/cashcard-transaction-enricher`
- `exercises/cashcard-transaction-source`

```dashboard:open-dashboard
   name: Editor
```

Our **Processor** application – the enricher application – is going to follow the same pattern as our **Source** application. Given this, we have provided the basic scaffolding for you:

- A configuration that enables Spring Cloud Stream's features.
- An `example.cashcard.domain` package that will encapsulate the data we are working with.
- A service that will contain the enrichment business logic.
- A test that will confirm everything is working correctly.

### Duplicate Domain Objects

You'll notice that the enricher applications contains `CashCard` and `Transaction` domain objects. There are duplicates from the **Source** application:

```editor:open-file
file: ~/exercises/cashcard-transaction-enricher/src/main/java/example/cashcard/domain/CashCard.java
description: "Duplicated domain objects"
```

We have a few options for eliminating this duplication, but we will tolerate this duplication for now for simplicity.

This scaffolding is helpful to get started, but is not a true **Processor** yet -- it's just another Spring Boot app. Let's start making it a Spring Cloud Stream app.
