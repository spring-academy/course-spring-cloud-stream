+++
title="Streaming E2E Test Logic"
+++

At this point we are ready to write our end-to-end test logic.

1. Write the test logic.

   We'll keep it simple, testing the _expected outcome:_ lines of enriched transaction data should be written to our sink-output file:

   ```java
   @Test
   void cashCardTransactionStreamEndToEnd() throws IOException {
     // Get the sink-file path
      Path path = Paths.get(CashCardTransactionSink.CSV_FILE_PATH);;

     // Remove the old sink-file if needed.
     if (Files.exists(path)) {
          Files.delete(path);
      }

      // Wait for the sink file to be written and fetch the first line
      Awaitility.await().until(() -> Files.exists(path));
      List<String> lines = Files.readAllLines(path);
      String csvLine = lines.get(0);

     // Test for information we know about the enriched transactions
      assertThat(csvLine).contains("sarah1");
      assertThat(csvLine).contains("123 Main street");
      assertThat(csvLine).contains("APPROVED");
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
   ```

   The entire test will look like this:

   ```java
   package example.cashcard.e2e.test;

   import static org.assertj.core.api.Assertions.assertThat;

   import java.io.IOException;
   import java.nio.file.Files;
   import java.nio.file.Path;
   import java.nio.file.Paths;
   import java.util.List;

   import org.awaitility.Awaitility;
   import org.junit.jupiter.api.Test;
   import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
   import org.springframework.boot.test.context.SpringBootTest;
   import org.springframework.context.annotation.Import;
   import org.springframework.kafka.test.context.EmbeddedKafka;

   import example.cashcard.enricher.CashCardTransactionEnricher;
   import example.cashcard.sink.CashCardTransactionSink;
   import example.cashcard.stream.CashCardTransactionStream;

   // Enable Embedded Kafka
   @EmbeddedKafka
   // Configure auto-configuration of embedded Kafka for the individual application configurations
   @SpringBootTest(classes = CashCardTransactionStreamE2ETests.StreamTestConfig.class, properties = {
     "spring.cloud.function.definition=approvalRequest;enrichTransaction;cashCardTransactionFileSink",
     "spring.cloud.stream.bindings.approvalRequest-out-0.destination=approval-requests",
     "spring.cloud.stream.bindings.enrichTransaction-in-0.destination=approval-requests",
     "spring.cloud.stream.bindings.enrichTransaction-out-0.destination=enriched-transactions",
     "spring.cloud.stream.bindings.cashCardTransactionFileSink-in-0.destination=enriched-transactions"
     })
     public class CashCardTransactionStreamE2ETests {

     @Test
     void cashCardTransactionStreamEndToEnd() throws IOException {
       Path path = Paths.get(CashCardTransactionSink.CSV_FILE_PATH);;

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

      // Configure auto-configuration of embedded Kafka for the individual components
      @EnableAutoConfiguration
      @Import({CashCardTransactionStream.class, CashCardTransactionEnricher.class, CashCardTransactionSink.class})
      public static class StreamTestConfig {

      }
   }
   ```

   As you can see, the test is really straightforward. The good thing is that when you run this test, you are exercising our end-to-end data flow from source all the way to the file sink against a _real_ Kafka cluster.

   Go ahead and run the test and verify that it works.

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

   Feel free to alter the setup and learn how the changes impact the results.

This is pretty impressive: with some simple configuration we were able to run our entire system with a _real_ embedded Kafka cluster.

Let's now move on to our other variant of the end-to-end test: a transaction posted on-demand via our REST API.
