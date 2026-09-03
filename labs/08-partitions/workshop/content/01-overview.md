+++
title="Overview"
+++

# Lab: Partitions and Consumer Groups

On the heels of the knowledge we have gained from the previous lesson, let us dive into seeing how the principles behind partitions and consumer groups are applied in Spring Cloud Stream.

In this lab, rather than creating a new module, we will build on top of our existing producer and consumer applications.

Let us open our source application - `cashcard-transaction-source`.

Go to `CashCardTransactionStream`.

We have the `Supplier` defined as below.

```java
@Bean

public Supplier<Transaction> approvalRequest(DataSourceService dataSource) {
    return () -> {
        return dataSource.getData();
    };
}

```

Our goal is to refactor this method in such a way that when we publish to the Kafka topic, we will publish to a specific partition.

There are a few ways to approach this problem - but as explained in the lesson, let us stick with a basic method to see this in action by relying on the Spring messaging support.

**Message** is a core class that is available from **spring-messaging**. A **Message** is a simple class that is capable of holding a payload and an optional set of headers. We will change our `Supplier` so that instead of returning a raw Transaction object, we will wrap it in a Message object, as outlined below.

```java
@Bean
public Supplier<Message<Transaction>> approvalRequest(DataSourceService dataSource) {
   return () -> {
       String originState = originCities[random.nextInt(originCities.length)];
       return MessageBuilder.withPayload(dataSource.getData())
               .build();
   };
}
```

The easiest way to publish the record into a particular partition is to associate each record with a key.

Let us assume that our stores are located in various big cities in the United States.

Here is a sample of data we can use for the store locations.

```java
final String[] originCities = {"New York", "San Francisco", "Philadelphia", "Denver", "Miami", "Houston",
      "Baltimore", "Dallas", "Los Angeles", "Chicago"};
```

Each time we publish a `Transaction` record, we also tell the record which store it is coming from by keying the record to the associated city.

For our demonstration purposes, let us contrive some basic rules by relying on the Random object from the JDK.

Here is how the code now looks.

```java
@Configuration
public class CashCardTransactionStream {

   final String[] originCities = {"New York", "San Francisco", "Philadelphia", "Denver", "Miami", "Houston",
           "Baltimore", "Dallas", "Los Angeles", "Chicago"};


   Random random = new Random();

   @Bean
   public Supplier<Message<Transaction>> approvalRequest(DataSourceService dataSource) {
       return () -> {
           String originState = originCities[random.nextInt(originCities.length)];
           return MessageBuilder.withPayload(dataSource.getData()).setHeader(KafkaHeaders.KEY, originState)
                   .build();
       };
   }

   @Bean
   public DataSourceService dataSourceFacade() {
           return new DataSourceService();
   }

}
```

Pay attention to how we add the header. We randomly select a store from our array and attach it to the record with a key—`KafkaHeaders.KEY`.

When this record reaches the Kafka producer, it evaluates the key and assigns a partition. The same keys will always end up in the same partition.

Remember that we have another type of on-demand producer based on the **StreamBridge **API. We will also need to adapt that code hierarchy to ensure that we are publishing with a record key. We will leave that up to the learner as an exercise. This is a fairly easy process. One thing to keep in mind is that you may want to pass the store location as an HTTP header when calling the controller or hard-code the data in ​​the `CashCardTransactionOnDemand` class in the same way that we did in `CashCardTransactionStream`.

They should pass if you run our built-in unit tests in the module.

The next step is to run the producer application in partitioning mode.

First, we need to ensure that we have a Kafka topic with multiple partitions. Usually, a Kafka admin pre-creates and provisions the topic with the required number of partitions. Spring Cloud Stream provides a ProvisioningProvider API, which the binders can use to try to provision a topic. The Kafka binder in Spring Cloud Stream provides an implementation for this API, using which an application can automatically create a topic (if the Kafka cluster is enabled for that) with the expected number of partitions.

By providing the following property in the configuration, we can instruct the binder to provision the topic.

```yaml
spring.cloud.stream.bindings.approvalRequest-out-0.producer.partition-count=4
```

Look at the deeper structure of this configuration. It is under `spring.cloud.stream.bindings`. Then we specify the actual binding name, followed by a producer-specific property under the binding called partition-count. In this example, the Kafka binder will create a topic for the binding (if there is a destination property specified, otherwise the default name is the same as the binding name) with **four **partitions.

You can provide this property when running the application as a runtime configuration property as we have done in the previous labs. You can also put this in an application.properties or application.yaml configuration file.

Let us use **approvals **as the topic name.

```yaml
spring.cloud.stream.bindings.approvalRequest-out-0.destination=approvals
```

Because we are publishing both key and value in our record, we need to talk about a concept that we were able to avoid up until now. In Spring Cloud Stream, message conversions are done by the framework using Spring’s message converter support. Therefore, when you provide an object of `Transaction`, the framework serializes that object - using a JSON converter in this example and send the `byte[]` to Kafka topic.

By default, Spring Cloud Stream sets a `byte[]` based serializer for both keys and values in the Kafka binder. This message conversion is only done for the payloads (record value), and not for the keys. Keys are always passed in as is and not going through any message conversion.

Because in Kafka binder, we set a default value of `byte[]` based serializer for both keys and values, in our example, it will fail since we send a String type as the key. To fix this, we need to instruct the application to use a specific key serializer that Kafka understands. You can do that using the property below.

```yaml
spring.cloud.stream.kafka.bindings.approvalRequest-out-0.producer.configuration.key.serializer=org.apache.kafka.common.serialization.StringSerializer
```

We provide binding property under spring.cloud.stream.kafka and then set a producer property. Anything under **configuration** will be directly delegated as a Kafka native property - in this case, key.serializer.

Run our docker based Kafka.

Pass these three properties and run the application.

At this point, you can see that the application is running.

Before running the application on the consumer side, let us verify that we see some data.

```shell
docker exec -it kafka /opt/kafka/bin/kafka-topics.sh --bootstrap-server localhost:9092 --describe --topic approvalRequest-out-0

```

You will see that the topic has 4 partitions.

```shell
docker exec -it kafka /opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic approvalRequest-out-0 --group my-speicial-group --property print.partition=true --property print.key=true

```

We are running the console script. Notice that we are passing a –group property to the script. This specifies that we are running this consumer under a specific group called **my-special-group**.

You will see that we see data from all the partitions.

Now, run this again in a different terminal session.

```shell
docker exec -it kafka /opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic approvalRequest-out-0 --group my-speicial-group --property print.partition=true --property print.key=true

```

Then again, another one.

Then again, another one.

Now see the data in all four sessions. You will see that the data is received by all 4 consumers, and they are dividing the data between the partitions since they are running under the same consumer group.

**Next, we will run our consumer (sink) application and verify that we receive data from partitions.**

**_(Note: consider breaking here and having a Consumer Group lab)_**

In order to keep the discussion brief, let us focus on our enrichment processor, which is a consumer under the hood. It then publishes the enriched data to another topic.

Once you learn how we can scale this consumer application, then you can take the concepts learned and apply them to our transaction-sink consumer.

Here is what we need to do:

1. We need to consume data from a topic that has four partitions. This is where our producer is publishing data.
2. Once consumed, we need to enrich the data (which we already have done in the previous lessons).
3. Then, we need to produce the data to another topic, which may or may not be partitioned, but for our example, we will keep the same number of partitions on the outgoing topic.

A diagram that captures these steps might be useful here.

Let us modify our function in the enrichment processor as below.

```java
@Bean
public Function<Message<Transaction>, Message<EnrichedTransaction>> enrichTransaction(EnricherService enricherService) {
   return transaction -> {
       System.out.println("RECEIVED PARTITION: " + transaction.getHeaders().get(KafkaHeaders.RECEIVED_PARTITION));
       Object receivedKey = transaction.getHeaders().get(KafkaHeaders.RECEIVED_KEY);
       String originCity = new String((byte[]) receivedKey);
       System.out.println("FROM CITY: " + originCity);
       EnrichedTransaction enrichedTransaction = enricherService.enrichTransaction(transaction.getPayload());
       return MessageBuilder.withPayload(enrichedTransaction).setHeader(KafkaHeaders.KEY, originCity)
               .build();
   };
}
```

We change the function’s input and output type signatures to wrap the `Transaction` type in a `Message` object. Then, we log the partition and key received for demonstration purposes. After enriching the data, we build another message with the same key as the one received.

Let us run this application, but please use the following properties when we run the enrichment processor.

```yaml
spring.cloud.stream.bindings.enrichTransacton-in-0.group=enriching-group

spring.cloud.stream.bindings.enrichTransaction-in-0.destination=approvals
spring.cloud.stream.bindings.enrichTransaction-out-0.destination=enriched-approvals

spring.cloud.stream.bindings.enrichTransaction-out-0.producer.partition-count=4

spring.cloud.stream.kafka.bindings.enrichTransaction-out-0.producer.configuration.key.serializer=org.apache.kafka.common.serialization.StringSerializer
```

Let us go through them one by one.

- The first property is a very important configuration property that instructs Spring Cloud Stream to run this consumer under a specific named group. Internally, the binder will translate this into the Kafka consumer group. This configuration enables the consumer to be scaled into various instances.
- The next two destination properties define the target topics on input and output. The input topic is the same as the one that the producer publishes.
- On the outbound topic’s binding (`enrichTransaction-out-0`), we define the partition-count property so that the provisioner in the binder creates the topic with the required number of partitions - four in this case.
- Finally, we define the key serializer required for outbound publishing.

Remember from the producer side of our discussion that the keys are natively serialized, and it needs to be known what middleware-specific serializer to use. Since we are using the same incoming key, which is a String type, we instruct Kafka to use its `StringSerializer`.

Run the application in a terminal session. Please ensure that our producer application above is also running. You should see that the enricher application receives data from all partitions of the approval topic.

Now run another instance of the enricher application. You should see that a rebalance gets triggered (from the Kafka broker), and the data is now split between the consumer instances, but a single consumer always consumes data from a single partition. Then start another instance, and then a fourth instance. You should see the transaction data distributed across the instances.

At this point, run a fifth consumer instance. You should see that one of the consumer instances goes idle after the rebalance. This is because, in Apache Kafka, scalability has an upper bound of the number of partitions. Since we only have four partitions, we can only have four active consumer instances. If we have more instances than that, then we will have idle consumers.

In this lab, we learned how Spring Cloud Stream producers can publish into a partitioned Kafka topic using a key-based strategy. Then, we learned how that data could be processed on the consuming side from multiple partitions and saw how the consumer app could be scaled into multiple instances using the consumer-group mechanism.
