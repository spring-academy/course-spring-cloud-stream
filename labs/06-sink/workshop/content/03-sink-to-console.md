+++
title="Sink to Console"
+++

Although our main use case is to write to a file in the sink, thus creating a _cash card transaction file sink_, we also want to log the data on the console so that teams such as ours can monitor the data in real-time.

Just as we did not want to burden the **Processor** with sink activity, we don't want to burden the console-writer or file-writer with the other's functionality.

To solve this, we will create two sink methods:

- A **_console sink_**
- A **_file sink_**

Let's write the console sink first, having it print to the console whenever an `EnrichedTransaction` appears.

Feel free to implement this yourself before looking about our implementation below.

1. Write the console sink `Consumer`.

   As you learned earlier, **Sinks** are defined with the `Consumer` interface.

   Create a `sinkToFile` method for an `EnrichedTransaction` using the `Consume` interface:

   ```editor:select-matching-text
   file: ~/exercises/cashcard-transaction-sink/src/main/java/example/cashcard/sink/CashCardTransactionSink.java
   text: "public Consumer<EnrichedTransaction> sinkToConsole()"
   description: "Add the console sink Consumer"
   ```

   ```java
   @Configuration
   public class CashCardTransactionSink {
       @Bean
       public Consumer<EnrichedTransaction> sinkToConsole() {
           return enrichedTransaction -> {

           };
       }
   }
   ```

   You'll need these `import` statements:

   ```java
   import example.cashcard.domain.EnrichedTransaction;
   import java.util.function.Consumer;
   import org.springframework.context.annotation.Bean;
   ```

1. Print that data!

   Though a more sophisticated system might use a true logging system, we'll make `sinkToConsole` simple by using a `System.out` statement:

   ```java
   @Configuration
   public class CashCardTransactionSink {
       @Bean
       public Consumer<EnrichedTransaction> sinkToConsole() {
           return enrichedTransaction -> {
               System.out.println("Transaction Received: " + enrichedTransaction);
           };
       }
   }
   ```

   Remarkably, that's all the production code required for this simple use case!

As the user of this sink, you do not need to worry about how the data is consumed from the middleware, given to the `Consumer` function, or any other technical details. As you are familiar with by now, all those concerns are handled by Spring Cloud Stream.

Let's go ahead and test the console sink.

## Write the Test

The goal of the test is to make sure that the console log contain the expected printed data.

For that, we need to rely on the JUnit extension `OutputCaptureExtension` provided by Spring Boot.

1. Set up the test.

   We need to configure our test class and console test with several annotations that accomplish the following:

   - Enable our test to be Spring Cloud Stream aware - `TestChannelBinderConfiguration`.
   - Enable our test to capture the console output - `OutputCaptureExtension`
   - Autowire the Spring Cloud Stream input - `InputDestination`
   - Autowire the captured console output - `CapturedOutput`.

   Here is the initial version of the test.

   ```editor:open-file
   file: ~/exercises/cashcard-transaction-sink/src/test/java/example/cashcard/sink/CashCardTransactionSinkTests.java
   description: "Edit the test"
   ```

   ```java
   @SpringBootTest
   @Import(TestChannelBinderConfiguration.class)
   @ExtendWith(OutputCaptureExtension.class)
   class CashCardTransactionSinkTests {

       @Test
       void cashCardSinkToConsole(@Autowired InputDestination inputDestination, CapturedOutput output) throws IOException {

       }

       @SpringBootApplication
       public static class App {

       }
   }
   ```

   Add the `import` statements, too:

   ```java
   import org.junit.jupiter.api.extension.ExtendWith;
   import org.springframework.context.annotation.Import;
   import org.springframework.beans.factory.annotation.Autowired;
   import org.springframework.boot.test.system.CapturedOutput;
   import org.springframework.boot.test.system.OutputCaptureExtension;
   import org.springframework.cloud.stream.binder.test.InputDestination;
   import org.springframework.cloud.stream.binder.test.TestChannelBinderConfiguration;
   ```

1. Send the `EnrichedTransaction` message.

   Following the pattern from other tests, create an `EnrichedTransaction`, wrap it in a `Message`, and send it to the `inputDestination` using the default-topic pattern you learned about and used in previous tests.

   Here's the code:

   ```java
   @Test
   void cashCardSinkToConsole(@Autowired InputDestination inputDestination, CapturedOutput output) throws IOException {

       // Set up the expected data
       Transaction transaction = new Transaction(1L, new CashCard(123L, "Kumar Patel", 1.00));
       EnrichedTransaction enrichedTransaction = new EnrichedTransaction(
         transaction.id(),
         transaction.cashCard(),
         ApprovalStatus.APPROVED,
         new CardHolderData(UUID.randomUUID(), transaction.cashCard().owner(), "123 Main Street"));

       // Send the message to the console sink's input topic
       Message<EnrichedTransaction> message = MessageBuilder.withPayload(enrichedTransaction).build();
       inputDestination.send(message, "sinkToConsole-in-0");
   }
   ```

   You'll need a bunch of `import` statements:

   ```java
   import org.springframework.integration.support.MessageBuilder;
   import org.springframework.messaging.Message;
   import java.util.UUID;
   import example.cashcard.domain.ApprovalStatus;
   import example.cashcard.domain.CardHolderData;
   import example.cashcard.domain.CashCard;
   import example.cashcard.domain.EnrichedTransaction;
   import example.cashcard.domain.Transaction;
   ```

1. Wait for and test the console output.

   This is new!

   We need to verify whether the consumer worked, but we are not pulling a message off of an `outputDestination`. We need the _console output_ from the `System.out.println` statement.

   How are we going to get that in our test?

   Answer: We will capture the output using the appropriately-named `CapturedOutput`, provided by `OutputCaptureExtension`.

   We are also using the `Awaitility` component from the `awaitility` library to wait until we see the expected data in the console output. We'll use a variable to set the maximum length of time to wait. Without this, our test might assert the test expectations before the `println` is finished.

   First, define the maximum length of time in seconds to wait for the console output:

   ```java
   class CashCardTransactionSinkTests {
       private static final int AWAIT_DURATION = 10;
       ...
   }
   ```

   Next, test the captured output within an `Awaitility.await` lambda:

   ```java
   @Test
   void cashCardSinkToConsole(@Autowired InputDestination inputDestination, CapturedOutput output) throws IOException {

       // Set up the expected data
       Transaction transaction = new Transaction(1L, new CashCard(123L, "Kumar Patel", 1.00));
       EnrichedTransaction enrichedTransaction = new EnrichedTransaction(
         transaction.id(),
         transaction.cashCard(),
         ApprovalStatus.APPROVED,
         new CardHolderData(UUID.randomUUID(), transaction.cashCard().owner(), "123 Main Street"));

       // Send the message to the console sink's input topic
       Message<EnrichedTransaction> message = MessageBuilder.withPayload(enrichedTransaction).build();
       inputDestination.send(message, "sinkToConsole-in-0");

       // Wait for, then test the console output
       Awaitility.await().atMost(Duration.ofSeconds(AWAIT_DURATION))
               .until(() -> output.toString().contains("Transaction Received: " + enrichedTransaction.toString()));
   }
   ```

   Don't forget these:

   ```java
   import org.awaitility.Awaitility;
   import java.time.Duration;
   ```

   Here, we've established that the test will wait at most 10 seconds for the console output to appear. The test will fail if that time is exceeded.

   Let's run the test and verify that it passes

1. Run the test.

   Let's test it out!

   You'll need to prefix the `test` task with the module name `cashcard-transaction-sink`:

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   [~/exercises] $ ./gradlew cashcard-transaction-sink:test
   ...
   BUILD SUCCESSFUL in 16s
   6 actionable tasks: 6 executed
   ```

   The test should pass as written.

   Feel free to play around with the test setup values to verify different success and failure scenarios, making sure you really understand what is going on. For example, change the expectation and see what happens when the `AWAIT_DURATION` is exceeded.

Now, before we move on writing our file sink, let's run our system of microservice applications and watch our console sink in action.
