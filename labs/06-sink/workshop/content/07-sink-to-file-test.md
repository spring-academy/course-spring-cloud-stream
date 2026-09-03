+++
title="Sink to File Test"
+++

Now that we have told Spring Cloud Stream to enable both our console sink and file sink bindings, we are ready to write our file sink test.

1. Write the file sink test.

   The file sink test follows a similar pattern as previous tests, and also uses the `Awaitility` library to watch for our output file to exist before checking it for content.

   ```editor:open-file
   file: ~/exercises/cashcard-transaction-sink/src/test/java/example/cashcard/sink/CashCardTransactionSinkTests.java
   description: "Add the file sink test"
   ```

   ```java
   @Test
   void sinkToFile(@Autowired InputDestination inputDestination) throws IOException {

       // Setup the expected data
       Transaction transaction = new Transaction(1L, new CashCard(123L, "Kumar Patel", 100.25));
       UUID uuid = UUID.fromString("65d0b699-3695-44c6-ba23-4a241717dab7");
       EnrichedTransaction enrichedTransaction = new EnrichedTransaction(
         transaction.id(),
         transaction.cashCard(),
         ApprovalStatus.APPROVED,
         new CardHolderData(uuid, transaction.cashCard().owner(), "123 Main Street"));

       // Send the message to the sink's input
       Message<EnrichedTransaction> message = MessageBuilder.withPayload(enrichedTransaction).build();
       inputDestination.send(message, "cashCardTransactionFileSink-in-0");

       // Wait for the sink's output file to be written
       Path path = Paths.get(CashCardTransactionSink.CSV_FILE_PATH);
       Awaitility.await().until(() -> Files.exists(path));

       // Read from the output file and make sure the content is correct
       List<String> lines = Files.readAllLines(path);
       assertThat(lines.get(0)).isEqualTo
               ("1,123,100.25,Kumar Patel,65d0b699-3695-44c6-ba23-4a241717dab7,123 Main Street,APPROVED");
   }
   ```

   Here are the `import`s:

   ```java
   import static org.assertj.core.api.Assertions.assertThat;
   import java.nio.file.Files;
   import java.nio.file.Path;
   import java.nio.file.Paths;
   import java.util.List;
   ```

   As you can see, we send a specific `EnrichedTransaction` to the consumer function and then verify that we see the file created in the expected directory and then verify its content.

1. Run the tests again.

   Let's make sure our tests pass:

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   [~/exercises] $ ./gradlew cashcard-transaction-sink:test
   ...
   BUILD SUCCESSFUL in 16s
   6 actionable tasks: 6 executed
   ```

   They pass!

   As before, feel free to alter the values in the test setup and assertions and observe how those changes impact the test results.

Let's once again run our applications and watch everything work together in harmony!
