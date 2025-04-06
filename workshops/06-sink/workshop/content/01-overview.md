+++
title="Overview"
+++

We have come a long way in this course! To complete the realistic scenario of the Family Cash Card financial transaction use case we are exploring, we need to look at one more type of application in Spring Cloud Stream.

As we've learned, a **Source** application produces to a middleware destination; a **Processor** application receives the data from the middleware destination, transforms it, then sends that data to another destination on the middleware for other applications to consume.

![Enricher application](/workshop/content/assets/source-and-enricher.svg)

From here, the data might be sent to a "sink" - potentially the final destination of the data in motion.

## Sink Applications

A **Sink** application consumes this data from a middleware destination. It might perform some actions that are critical to the business, such as sending the data to an analytics platform, writing to files for FTP, displaying to a dashboard, or any number of other valuable actions.

## The Consumer Interface

As discussed in the Programming Model lesson, a "sink" component is perfectly modeled via the `java.util.function.Consumer<?>` interface, and expressed as a bean in Spring Cloud Stream applications:

```java
@Bean
public Consumer<Pojo> myConsumer() {
    return pojo -> {
        // logic to send the data to a sink.
    }
}
```

The core business logic is implemented in the lambda expression, similar to the `Supplier` and `Function` lambda expressions we've used earlier.

How might a **Sink** apply in the Family Cash Card domain?

## Sinks and the Family Cash Card

Imagine the business team has requested that we take the enriched cash card transaction data and send it to a filesystem for further analysis.

No problem! We can do that by implementing the following:

1. Create a new Spring Cloud Stream microservice application.
1. Have it listen on the **Processor's** output topic in the middleware.
1. When a new message containing an `EnrichedTransaction` appears, process it and write its data to the filesystem.

   And since our team is a stakeholder, too, we would like to monitor the processing of this data. With that in mind:

1. Write the data to an **_output console_**, as well!

![System with Sink](/workshop/content/assets/system-with-sink.svg)

You might ask at this point: why all this complexity with yet another microservice app? Why can't we simply write to a file after we have enriched the data in the enrichment **Processor** application?

## Separation of Concerns (again!)

While this is a valid question, there are various trade-offs. Certainly, you can do everything in the **Processor** itself. But if we do that, we are violating the single-responsibility principle.

If we added the sink's responsibility to the enricher, in addition to enriching the data, we would need to write it to a file, a console, a database, an analytics engine... who knows what! If one of those I/Os fails, we risk the entire enrichment process failing as well.

We also don't want to introduce latency into the enrichment process. Potentially thousands of transactions occur every second, and we should enrich those transactions as quickly as possible for others to consume, and not worry about why some filesystem is offline or a database is slow.

A **Source** is for sourcing, A **Processor** for processing, and a **Sink** should focus on various I/O and persistance activities.

Now, let us return to our Family Cash Card domain and how we might approach our new sink module.
