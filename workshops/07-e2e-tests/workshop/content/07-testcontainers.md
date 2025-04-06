+++
title="Using Test Containers"
+++

Before we conclude this lab, let us also explore a popular way for performing these types of full end-to-end tests using [Testcontainers](https://testcontainers.com/).

From the Testcontainers website:

> Testcontainers is an open source framework for providing throwaway, lightweight instances of databases, message brokers, web browsers, or just about anything that can run in a Docker container.

Spring Boot provides first-class support for running Testcontaners based tests that can be run against dockerized images from your tests.

Why is this appealing?

- You don't need to run locally or remotely installed supporting services on your development machine or testing pipeline.
- You don't need to rely on Spring-provided embedded services, such as `@EmbeddedKafka`. Not every service in the world is provided by Spring.
- It is very easy to switch between the binder implementations.

Suppose you are using RabbitMQ or Apache Pulsar instead of Apache Kafka. You can just swap out the Kafka dependency for the corresponding Testcontainers middleware image and then provide the correct `@ServiceConnection` bean. Easy!

Let's create a version of our streaming test that user Testcontainers instead of `@EmbeddedKafka`.

1. Add the Testcontainers dependencies.

   We need to explicitly add support for Testcontaniners.

   Add the following Kafka-related Testcontainers dependencies to our `build.gradle`:

   ```editor:select-matching-text
   file: ~/exercises/cashcard-transaction-e2e-tests/build.gradle
   text: "dependencies"
   after: 8
   description: "E2E test module dependencies"
   ```

   ```groovy
   dependencies {
     ...
     // Add the Testcontainers dependencies for Kafka
     testImplementation 'org.testcontainers:kafka'
     testImplementation 'org.springframework.boot:spring-boot-testcontainers'
   }
   ```

1. Copy the streaming e2e test as a basis.

   We'll use our fixed-schedule/streaming test as a basis for our Testcontainer-enabled test.

   Create a copy of `CashCardTransactionStreamE2ETests.java` named `CashCardTransactionStreamE2EContainerTests.java`.

   ```editor:open-file
   file: ~/exercises/cashcard-transaction-e2e-tests/src/test/java/example/cashcard/e2e/test/CashCardTransactionStreamE2ETests.java
   description: "E2E tests"
   ```

   Be sure and update the class name in the `.java` file, and the name of the configuration inner class referenced in the `@SpringBootTest` annotation, too:

   ```editor:select-matching-text
   file: ~/exercises/cashcard-transaction-e2e-tests/src/test/java/example/cashcard/e2e/test/CashCardTransactionStreamE2EContainerTests.java
   text: "@SpringBootTest"
   description: "Update the inner class reference"
   ```

   ```java
   // Update the configuration class name
   @SpringBootTest(classes = CashCardTransactionStreamE2EContainerTests.StreamTestConfig.class, properties = {
   ...
   }
   ```

1. Swap `@EmbeddedKafaka` for a `@ServiceConnection` bean.

   Now we get to the real update: removing the `@EmbeddedKafka`, and configuring Testcontainer support.

   First, delete the `@EmbeddedKafaka` annotation. We won't need that for this test.

   ```java
   // Delete the @EmbeddedKafka annotation
   // @EmbeddedKafka
   @SpringBootTest(classes = CashCardTransactionStreamE2EContainerTests.StreamTestConfig.class, properties = {
    // all the same properties ...
   }
   ```

   Next, update the configuration inner class to provide the Testcontainer `@ServiceConnection` bean for Kafka, which is based on the [Confluent Kafka image](https://hub.docker.com/r/confluentinc/cp-kafka) container:

   ```java
   ...
    // Configure auto-configuration of Testcontainer Kafka
   @EnableAutoConfiguration
   @Import({CashCardTransactionStream.class, CashCardTransactionEnricher.class, CashCardTransactionSink.class})
   public static class StreamTestConfig {

       // Configure the Testcontainer bean support for Kafka
       @Bean
       @ServiceConnection
       KafkaContainer kafkaContainer() {
         // Sometimes our lab environment is slow. Be sure to wait long enough for
         // the container to download and start 😉.
         WaitAllStrategy fiveMinutes = new WaitAllStrategy(WaitAllStrategy.Mode.WITH_OUTER_TIMEOUT)
         .withStartupTimeout(Duration.ofMinutes(5));

         // Specify the Kafka container
         return new KafkaContainer(DockerImageName.parse("confluentinc/cp-kafka:latest"))
         .waitingFor(fiveMinutes);
       }
   }
   ```

   Here are the new `import` statements:

   ```java
   import java.time.Duration;
   import org.springframework.context.annotation.Bean;
   import org.springframework.boot.testcontainers.service.connection.ServiceConnection;
   import org.testcontainers.containers.wait.strategy.WaitAllStrategy;
   import org.testcontainers.containers.KafkaContainer;
   import org.testcontainers.utility.DockerImageName;
   ```

   {{< note >}}
   Sometimes the Internet is slow!

   Notice that 5-minute timeout set above in the class called `WaitAllStrategy`:

   ```java
   new WaitAllStrategy(WaitAllStrategy.Mode.WITH_OUTER_TIMEOUT)
         .withStartupTimeout(Duration.ofMinutes(5));
   ```

   While we don't expect the test to take that long to run, it is true that that a fairly large Docker image will be downloaded and started. Our test needs to wait for all of this to happen, and we've specified to wait no longer than 5 minutes.

   We're not going to cover wait strategies in depth here, but feel free to learn more about them in the Testcontainers documentation: [Waiting for containers to start or be ready](https://java.testcontainers.org/features/startup_and_waits/). Wait strategies are an important concept to understand with Testcontainers, and different scenarios might require different strategies.
   {{< /note >}}

1. ~~Update the test logic~~ Actually, don't change the logic.

   The test logic will not change!

   This is a good thing: our test logic should be _agnostic of the actual middleware implementation_.

   The entire test looks like this:

   ```java
   package example.cashcard.e2e.test;

   import static org.assertj.core.api.Assertions.assertThat;

   import java.io.IOException;
   import java.nio.file.Files;
   import java.nio.file.Path;
   import java.nio.file.Paths;
   import java.time.Duration;
   import java.util.List;

   import org.awaitility.Awaitility;
   import org.junit.jupiter.api.Test;
   import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
   import org.springframework.boot.test.context.SpringBootTest;
   import org.springframework.boot.testcontainers.service.connection.ServiceConnection;
   import org.springframework.context.annotation.Bean;
   import org.springframework.context.annotation.Import;
   import org.testcontainers.containers.KafkaContainer;
   import org.testcontainers.containers.wait.strategy.WaitAllStrategy;
   import org.testcontainers.utility.DockerImageName;

   import example.cashcard.enricher.CashCardTransactionEnricher;
   import example.cashcard.sink.CashCardTransactionSink;
   import example.cashcard.stream.CashCardTransactionStream;

   @SpringBootTest(classes = CashCardTransactionStreamE2EContainerTests.StreamTestConfig.class, properties = {
       "spring.cloud.function.definition=approvalRequest;enrichTransaction;cashCardTransactionFileSink",
       "spring.cloud.stream.bindings.approvalRequest-out-0.destination=approval-requests",
       "spring.cloud.stream.bindings.enrichTransaction-in-0.destination=approval-requests",
       "spring.cloud.stream.bindings.enrichTransaction-out-0.destination=enriched-transactions",
       "spring.cloud.stream.bindings.cashCardTransactionFileSink-in-0.destination=enriched-transactions"
   })
   public class CashCardTransactionStreamE2EContainerTests {

     @Test
     void cashCardTransactionStreamEndToEnd() throws IOException {
       Path path = Paths.get(CashCardTransactionSink.CSV_FILE_PATH);
       ;

       // Remove the old sink-file if needed.
       if (Files.exists(path)) {
         Files.delete(path);
       }

       // Wait for the sink file to appear and fetch the first line
       Awaitility.await().until(() -> Files.exists(path));
       List<String> lines = Files.readAllLines(path);
       String csvLine = lines.get(0);

       // Test for information we know about the enriched transactions
       assertThat(csvLine).contains("sarah1");
       assertThat(csvLine).contains("123 Main street");
       assertThat(csvLine).contains("APPROVED");

     }

     // Configure auto-configuration of Testcontainer Kafka
     @EnableAutoConfiguration
     @Import({ CashCardTransactionStream.class, CashCardTransactionEnricher.class, CashCardTransactionSink.class })
     public static class StreamTestConfig {

       // Configure the Testcontainer bean support for Kafka
       @Bean
       @ServiceConnection
       KafkaContainer kafkaContainer() {
         // Sometimes our lab environment is slow. Be sure to wait long enough for
         // the container to download and start 😉.
         WaitAllStrategy fiveMinutes = new WaitAllStrategy(WaitAllStrategy.Mode.WITH_OUTER_TIMEOUT)
             .withStartupTimeout(Duration.ofMinutes(5));

         // Specify the Kafka container
         return new KafkaContainer(DockerImageName.parse("confluentinc/cp-kafka:latest"))
             .waitingFor(fiveMinutes);
       }
     }
   }
   ```

   Not much is different from our original streaming test. The primary differences are:

   - We removed the `@EmbeddedKafka` annotation.
   - We added a Spring Boot `ServiceConnection` bean for the Kafka container.

1. Run those tests again.

   When you run this test, we are now running our end-to-end data flow against a real world, dockerized Kafka cluster instead of running against an in-memory, embedded Kafka broker.

   Remember, this test run might take longer than previous runs since `CashCardTransactionStreamE2EContainerTests` is downloading and starting the Kafka container.

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   [~/exercises] $ ./gradlew cashcard-transaction-e2e-tests:test
   ...
   > Task :cashcard-transaction-e2e-tests:test
   ...
   BUILD SUCCESSFUL in 24s
   13 actionable tasks: 2 executed, 11 up-to-date
   ```

Congratulations! We finished our lab on verifying the data flow end-to-end.
