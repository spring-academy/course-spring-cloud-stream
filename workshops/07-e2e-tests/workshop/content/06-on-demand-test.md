+++
title="On-Demand E2E Test"
+++

Our on-demand, `SpringBridge` enabled REST API **Source** should have exactly the same result as our fixed-schedule, streaming supplier.

In fact, most (but not all) of the configuration setup is the same.

We'll call out the differences.

1. Review the on-demand test scaffold.

   We are going to send HTTP requests to the REST API to trigger the on-demand `SpringBridge` functionality.

   First, review the controller, where we use the `SpringBridge` feature:

   ```editor:open-file
   file: ~/exercises/cashcard-transaction-source/src/main/java/example/cashcard/controller/CashCardController.java
   description: "Review the CashCardController"
   ```

   Next, review the test scaffold, where you will see that we have partially set up the test as a web-enabled test:

   ```editor:open-file
   file: ~/exercises/cashcard-transaction-e2e-tests/src/test/java/example/cashcard/e2e/test/CashCardTransactionOnDemandE2ETests.java
   description: "On Demand e2e test with web support"
   ```

   This test does not run a the moment. Let's finish writing it.

1. Configure Embedded Kafka.

   We just did this. Let's do it again!

   First, add the annotation to our test class, plus the required `import` statement:

   ```java
   // Add this import statement
   import org.springframework.kafka.test.context.EmbeddedKafka;

   // Enable Embedded Kafka
   @EmbeddedKafka
   @SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
   public class CashCardTransactionOnDemandE2ETests {
       ...
   }
   ```

1. Configure auto-configuration, adding the REST API controller.

   This is mostly the same, but also a little different.

   Just as before, we need a custom auto-configuration, importing our **Source**, **Processor**, and **Sink** configurations.

   In addition, since we are exercising the **Source** REST API, we need to load the `CashCardController` as well:

   ```java
   // Add these imports
   import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
   import org.springframework.context.annotation.Import;
   import example.cashcard.enricher.CashCardTransactionEnricher;
   import example.cashcard.sink.CashCardTransactionSink;
   import example.cashcard.ondemand.CashCardTransactionOnDemand;
   import example.cashcard.controller.CashCardController;

   @EmbeddedKafka
   @SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
   public class CashCardTransactionOnDemandE2ETests {
       ...
       // Configure auto-configuration of embedded Kafka for the individual application configurations
      // Also, load the Source controller so we can send HTTP requests to it
       @EnableAutoConfiguration
       @Import({CashCardController.class, CashCardTransactionOnDemand.class, CashCardTransactionEnricher.class, CashCardTransactionSink.class})
       public static class OnDemandTestConfig {

       }
   }
   ```

1. Configure the bindings and input/output topic destinations.

   Again, these are _almost_ the same as the Stream **Source**.

   Here's what's different as a result of using the on-demand trigger vs. the streaming binding: `spring.cloud.function.definition`:

   - We only need to enable the `enrichTransaction` and `cashCardTransactionFileSink` bindings. We are not going to use the fixed-schedule streaming binding, `approvalRequest`, and thus it is not listed.

   Here's the final version of `@SpringBootTest`:

   ```java
   @EmbeddedKafka
   @SpringBootTest(classes = CashCardTransactionOnDemandE2ETests.OnDemandTestConfig.class, properties = {
   "spring.cloud.function.definition=enrichTransaction;cashCardTransactionFileSink",
   "spring.cloud.stream.bindings.approvalRequest-out-0.destination=approval-requests",
   "spring.cloud.stream.bindings.enrichTransaction-in-0.destination=approval-requests",
   "spring.cloud.stream.bindings.enrichTransaction-out-0.destination=enriched-transactions",
   "spring.cloud.stream.bindings.cashCardTransactionFileSink-in-0.destination=enriched-transactions"
   },
   webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
   public class CashCardTransactionOnDemandE2ETests {
   ...
   }
   ```

1. Write the test logic.

   We're ready for the test logic!

   It's similar to the streaming test, but instead of waiting for the fixed-schedule **Source** binding to automatically fire, we'll trigger it ourselves using the REST API:

   - Create a new `Transaction` for us to test.
   - `POST` it to the controller endpoint.
   - Then, wait for the **Sink** output file to get generated and test the enriched output.

   Here's what we came up with; feel free to edit the expected values:

   ```java
   @Test
   void cashCardTransactionOnDemandEndToEnd() throws IOException {
       // Remove the old sink-file if needed.
       Path path = Paths.get(CashCardTransactionSink.CSV_FILE_PATH);
       if (Files.exists(path)) {
           Files.delete(path);
       }

      // Create a transaction to POST
       Transaction transaction = new Transaction(1122334455L, new CashCard(6677889900L, "kumar2", 820.0));

      // POST the transaction to our SpringBridge REST API
       this.restTemplate.postForEntity("http://localhost:" + port + "/publish/txn", transaction, Transaction.class);

       // Wait for the sink file to appear and fetch the first line
       Awaitility.await().until(() -> Files.exists(path));
       List<String> lines = Files.readAllLines(path);
       String csvLine = lines.get(0);

       // Test for information we know about the enriched transactions
       assertThat(csvLine).contains("1122334455");
       assertThat(csvLine).contains("6677889900");
       assertThat(csvLine).contains("kumar2");
       assertThat(csvLine).contains("820.0");
   }
   ```

   You'll need these imports:

   ```java
   import java.nio.file.Files;
   import java.nio.file.Path;
   import java.nio.file.Paths;
   import java.util.List;
   import org.awaitility.Awaitility;
   import static org.assertj.core.api.Assertions.assertThat;
   import example.cashcard.domain.CashCard;
   import example.cashcard.domain.Transaction;
   ```

   The entire test looks like this:

   ```java
   package example.cashcard.e2e.test;

   import example.cashcard.controller.CashCardController;
   import example.cashcard.domain.CashCard;
   import example.cashcard.domain.Transaction;
   import example.cashcard.enricher.CashCardTransactionEnricher;
   import example.cashcard.ondemand.CashCardTransactionOnDemand;
   import example.cashcard.sink.CashCardTransactionSink;
   import org.awaitility.Awaitility;
   import org.junit.jupiter.api.Test;
   import org.springframework.beans.factory.annotation.Autowired;
   import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
   import org.springframework.boot.test.context.SpringBootTest;
   import org.springframework.boot.test.web.client.TestRestTemplate;
   import org.springframework.boot.test.web.server.LocalServerPort;
   import org.springframework.context.annotation.Import;
   import org.springframework.kafka.test.context.EmbeddedKafka;

   import java.io.IOException;
   import java.nio.file.Files;
   import java.nio.file.Path;
   import java.nio.file.Paths;
   import java.util.List;

   import static org.assertj.core.api.Assertions.assertThat;

   // Enable Embedded Kafka
   @EmbeddedKafka
   @SpringBootTest(classes = CashCardTransactionOnDemandE2ETests.OnDemandTestConfig.class, properties = {
     "spring.cloud.function.definition=enrichTransaction;cashCardTransactionFileSink",
     "spring.cloud.stream.bindings.approvalRequest-out-0.destination=approval-requests",
     "spring.cloud.stream.bindings.enrichTransaction-in-0.destination=approval-requests",
     "spring.cloud.stream.bindings.enrichTransaction-out-0.destination=enriched-transactions",
     "spring.cloud.stream.bindings.cashCardTransactionFileSink-in-0.destination=enriched-transactions"
   }, webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
   public class CashCardTransactionOnDemandE2ETests {

     @LocalServerPort
     private int port;

     @Autowired
     private TestRestTemplate restTemplate;

     @Test
     void cashCardTransactionOnDemandEndToEnd() throws IOException {
       // Remove the old sink-file if needed.
       Path path = Paths.get(CashCardTransactionSink.CSV_FILE_PATH);
       if (Files.exists(path)) {
         Files.delete(path);
       }

       // Create a transaction to POST
       Transaction transaction = new Transaction(1122334455L, new CashCard(6677889900L, "kumar2", 820.0));

       // POST the transaction to our SpringBridge REST API
       this.restTemplate.postForEntity("http://localhost:" + port + "/publish/txn", transaction, Transaction.class);

       // Wait for the sink file to appear and fetch the first line
       Awaitility.await().until(() -> Files.exists(path));
       List<String> lines = Files.readAllLines(path);
       String csvLine = lines.get(0);

       // Test for information we know about the enriched transactions
       assertThat(csvLine).contains("1122334455");
       assertThat(csvLine).contains("6677889900");
       assertThat(csvLine).contains("kumar2");
       assertThat(csvLine).contains("820.0");
     }


     // Configure auto-configuration of embedded Kafka for the individual application configurations
     // Also, load the Source controller so we can send HTTP requests to it
     @EnableAutoConfiguration
     @Import({CashCardController.class, CashCardTransactionOnDemand.class, CashCardTransactionEnricher.class, CashCardTransactionSink.class})
     public static class OnDemandTestConfig {

     }
   }
   ```

1. Run the test.

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   [~/exercises] $ ./gradlew cashcard-transaction-e2e-tests:test
   ...
   > Task :cashcard-transaction-e2e-tests:test
   ...
   BUILD SUCCESSFUL in 8s
   13 actionable tasks: 2 executed, 11 up-to-date
   ```

   It works!

   Take a look at the output file to verify if you would like:

   ```editor:open-file
   file: ~/exercises/cashcard-transaction-e2e-tests/build/tmp/transactions-output.csv
   description: "Open the file sink output file"
   ```

   Hurray! We've tested that both **Source** suppliers are working, **Processor** is enriching transactions, the **Sink** is writing to our `CSV` file.

Let's make one more test and play around with an alternative Kafka provider.
