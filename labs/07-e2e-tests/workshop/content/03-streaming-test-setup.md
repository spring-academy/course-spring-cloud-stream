+++
title="Streaming E2E Test Setup"
+++

We're ready to write our first end-to-end integration test!

First, check out the test scaffolding we've provided for the streaming e2e test:

```editor:open-file
file: ~/exercises/cashcard-transaction-e2e-tests/src/test/java/example/cashcard/e2e/test/CashCardTransactionStreamE2ETests.java
description: "E2E tests"
```

```java
@SpringBootTest
public class CashCardTransactionStreamE2ETests {

    @Test
    void cashCardTransactionStreamEndToEnd() throws IOException {
    }
}
```

It currently looks very similar to the unit test scaffolding we've provided throughout this course. But not for long!

Our end-to-end integration tests will need a lot more configuration than our unit tests. Let's work on that now.

1. Configure Embedded Kafka.

   As we mentioned, Spring Cloud Stream provides testing support for embedded Kafka using the `@EmbeddedKafka` annotation.

   First, add the annotation to our test class, plus the required `import` statement:

   ```java
   // Add this import statement
   import org.springframework.kafka.test.context.EmbeddedKafka;

   // Enable Embedded Kafka
   @EmbeddedKafka
   @SpringBootTest
   public class CashCardTransactionStreamE2ETests {
       ...
   }
   ```

   `@EmbeddedKafka` starts the embedded Kafka broker when running the tests.

1. Set up the custom configuration.

   Next, set up a custom configuration inner class, importing our **Source**, **Processor**, and **Sink** configurations, along with these additional `import` statements:

   ```java
   // Add these imports
   import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
   import org.springframework.context.annotation.Import;
   import example.cashcard.enricher.CashCardTransactionEnricher;
   import example.cashcard.sink.CashCardTransactionSink;
   import example.cashcard.stream.CashCardTransactionStream;

   // Enable Embedded Kafka
   @EmbeddedKafka
   @SpringBootTest
   public class CashCardTransactionStreamE2ETests {
       ...
       // Configure auto-configuration of embedded Kafka for the individual application configurations
       @EnableAutoConfiguration
       @Import({CashCardTransactionStream.class, CashCardTransactionEnricher.class, CashCardTransactionSink.class})
       public static class StreamTestConfig {

       }
   }
   ```

   `@SpringBootTest` will apply Kafka auto-configuration so that all the Kafka properties are automatically applied behind the scenes. Spring Boot will do all the heavy-lifting, such as managing Kafka ports.

1. Configure the Spring Cloud Stream bindings.

   From our previous labs, you should be quite familiar with the `@SpringBootTest` annotation. This provides you auto-configuration in the same way in a real Spring Boot application

   In order to enable our end-to-end testing, `@SpringBootTest` needs some of the properties have been passing in to our individual applications on the command line when we run `./gradlew bootRun`:

   - The list of Spring Cloud Stream bindings to enable.
   - The specific input and output topics each component should utilize.

   More specifically:

   1. First, we will tell `@SpringBootTest` to specifically load our inner configuration class that is annotated with `@EnableAutoConfiguration`.
   2. Next, we will specify the bindings we want enabled.
   3. Finally, we will define input and output destination middleware topics.

   Let's configure the configuration class first:

   ```java
   // Set bindings and destination properties needed to connect the components
   @SpringBootTest(classes = CashCardTransactionStreamE2ETests.StreamTestConfig.class)
   ```

   Next, we want to activate the three components for this end-to-end test: the **Source**, **Processor**, and **Sink** components.

   If you remember our previous lessons, configurations define our Spring Cloud Stream bindings:

   - The supplier function is `approvalRequest`
   - The processor function is `enrichTransaction`
   - The sink defines the file-sink function `cashCardTransactionFileSink`

   These are all enabled via the following property, which follows the same format we use when running `bootRun` on the command line:

   - `spring.cloud.function.definition=approvalRequest;enrichTransaction;cashCardTransactionFileSink.`

   Here's the code within the `properties`:

   ```java
   // Set bindings and destination properties needed to connect the components
   @SpringBootTest(classes = CashCardTransactionStreamE2ETests.StreamTestConfig.class, properties = {
   "spring.cloud.function.definition=approvalRequest;enrichTransaction;cashCardTransactionFileSink"
   })
   ```

   Before completing the setup, let's talk about the input and output destinations in detail.

1. `@SpringBootTest` and input/output topic properties.

   We need to tell `@SpringBootTest` the input and output topics for our three bindings.

   - For the **Source** binding `approvalRequest`, the _output_ from the supplier goes to a Kafka topic called `approval-requests`.

     ```java
     spring.cloud.stream.bindings.approvalRequest-out-0.destination=approval-requests
     ```

   - In the enricher **Processor**, we _consume_ from `approval-requests`, and _output_ to `enriched-transactions`:

     ```java
     spring.cloud.stream.bindings.enrichTransaction-in-0.destination=approval-requests
     spring.cloud.stream.bindings.enrichTransaction-out-0.destination=enriched-transactions
     ```

   - Finally, our file-sink binding _consumes_ the messages from the enriched-transactions topic, `enriched-transactions`:

     ```java
     spring.cloud.stream.bindings.cashCardTransactionFileSink-in-0.destination=enriched-transactions
     ```

   When we we add these `properties`, the `@SpringBootTest` configuration looks like this:

   ```java
   // Set bindings and destination properties needed to connect the components
   @SpringBootTest(classes = CashCardTransactionStreamE2ETests.StreamTestConfig.class, properties = {
   "spring.cloud.function.definition=approvalRequest;enrichTransaction;cashCardTransactionFileSink",
   "spring.cloud.stream.bindings.approvalRequest-out-0.destination=approval-requests",
   "spring.cloud.stream.bindings.enrichTransaction-in-0.destination=approval-requests",
   "spring.cloud.stream.bindings.enrichTransaction-out-0.destination=enriched-transactions",
   "spring.cloud.stream.bindings.cashCardTransactionFileSink-in-0.destination=enriched-transactions"
   })
   ```

Now that the plumbing is established, let's write the test logic.
