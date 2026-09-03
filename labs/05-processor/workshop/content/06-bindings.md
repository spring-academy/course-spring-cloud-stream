+++
title="Bindings and Topics"
+++

We've written all of the code we need to run our applications! All concerns of connecting to the middleware, publishing to the destination, consuming messages, and other technical details are taken care of by the Spring Cloud Stream framework.

We are now ready to update our tests, then run our applications and have our **Processor** enrich data produced by the **Source**.

First, let's do a bit of review, and make sure we understand how everything connected, as we will need to use some of this knowledge to write our **Processor** test, and when we run our applications.

## Review

Our goals is to "enrich" a "normal" cash card transaction with additional valuable data.

![Enricher application](/workshop/content/assets/enricher-app.svg)

For this to happen we need the following to occur:

1. The **Source** application needs to fetch data from a data source, do whatever actions might be needed to it, then send this data to a middleware.
1. Our **Processor** application, also configured by Spring Cloud Stream, needs to be looking for data in the correct **_topic_** in the middleware to receive the **Source**'s transactions.
1. Once received by our **Processor**, it will enrich the data using the enrichment service we wrote, then send _that_ data back to the middleware for other applications or systems to consume.

![Enricher application](/workshop/content/assets/source-and-enricher.svg)

At this point we have written all the code to enable this workflow!

But, there is an important aspect we have not covered:

> Our **Processor** application, also configured by Spring Cloud Stream, _needs to be looking for data in the correct **topic** in the middleware to receive the **Source's** transactions._

So far we have not configured anything for actually receiving messages from the middleware. How do we even know where to look?

## Spring Cloud Stream Defaults

We've mentioned in earlier lessons and labs that Spring Cloud Stream generates default topics for configured applications.

For example, based on the `Supplier` bean method name:

> The main thing to remember here is that our output binding name from this `Supplier` becomes `approvalRequest-out-0`.

Take a look at the Supplier bean method `approvalRequest`:

```editor:select-matching-text
file: ~/exercises/cashcard-transaction-source/src/main/java/example/cashcard/stream/CashCardTransactionStream.java
text: "public Supplier<Transaction> approvalRequest(DataSourceService dataSource)"
description: "Review the Source Supplier"
```

From this a topic of `approvalRequest-out-0` is generated.

By contrast, our **Processor** configures a `Function`:

```editor:select-matching-text
file: ~/exercises/cashcard-transaction-enricher/src/main/java/example/cashcard/enricher/CashCardTransactionEnricher.java
text: "public Function<Transaction, EnrichedTransaction> enrichTransaction(EnrichmentService enrichmentService)"
description: "Review the Processor Function"
```

It turns out that a very similar convention is used for the `Function` bean names as well, which we will need to know when we write our **Processor** test, and also when running the **Processor** application.

## Auto-Generated Bindings

Spring Cloud Stream creates **_bindings_** for both the input and output aspects of both components with the following default names:

- `approvalRequest-in-0` and `approvalRequest-out-0` for the **Source** bean method name `approvalRequest`.
- `enrichTransaction-in-0` and `enrichTransaction-out-0` for the **Processor** bean method name `enrichTransaction`.

`approvalRequest-in-0` should look familiar since we have referenced it several times throughout this course:

- When monitoring Kafka topics:

  ```shell
  [~/exercises] $ docker exec -it kafka /opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic approvalRequest-out-0
  ```

- When publishing a `Transaction` on-demand using `StreamBridge`

  ```java
  // ~/exercises/cashcard-transaction-source/src/main/java/example/cashcard/ondemand/CashCardTransactionOnDemand.java
  public void publishOnDemand(Transaction transaction) {
    this.streamBridge.send("approvalRequest-out-0", transaction);
  }
  ```

- When receiving messages from the `outputDestination` in our tests:

  ```java
  // ~/exercises/cashcard-transaction-source/src/test/java/example/cashcard/stream/CashCardApplicationTests.java
  ...
  Message<byte[]> result = outputDestination.receive(5000, "approvalRequest-out-0");
  ...
  ```

These are all destination topics.

## It's not the Journey, It's the Destination

By default, Spring Cloud Stream consumes the data from the topic bound to the `<beanMethodName>-in-0` binding. Each time it receives data from the topic, the framework will invoke the function on behalf of the end user. In our system, these will be `approvalRequest-in-0` and `enrichTransaction-in-0`.

Once Spring Cloud Stream gets the data back from their configured lambda functions, it will send that to the destination bound by the output binding `<beanMethodName>-out-0`. In our system, these will be `approvalRequest-out-0` and `enrichTransaction-out-0`.

Thus, to work with the default configuration generated by Spring Cloud Stream, we will need to specify the **Processor input** to be the **Source output** when running our applications.

![Pub/Sub topics](/workshop/content/assets/topics.svg)

Now that we know the bindings generated by Spring Cloud Stream, let's use this information to write our **Processor** test, then run our applications.
