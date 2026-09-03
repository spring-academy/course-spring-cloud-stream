+++
title="Sink to File"
+++

We're now ready to write the file sink.

Before we write this second sink, we have something important to tell you: _the file-writing **is not** the cool part._

If you research _"the best way to write a .CSV file in Java"_ you will find many different options. In fact, if you don't like the way we implemented file-writing in this lab, feel free to implement it differently! Again, that isn't the cool part.

So what is interesting about our scenario if not the file-writing?

**Answer:** The interesting bit is how Spring Cloud Stream handles _multiple bindings_, and how we, the developers, need to change the pattern we have been following when there are multiple bindings.

But first, we need to add our second sink binding, which will write `EnrichedTransaction` data to a CSV file in `build/tmp/transactions-output.csv`.

1. Sink to a CSV file.

   First, add a constant defining the output directory. Normally this should be done in a configuration file, but we'll define it here for ease of visibility in this lab:

   ```editor:open-file
   file: ~/exercises/cashcard-transaction-sink/src/main/java/example/cashcard/sink/CashCardTransactionSink.java
   description: "Edit the sink configuration"
   ```

   ```java
   @Configuration
   public class CashCardTransactionSink {

    // Add a constant specifying the output file
    public static final String CSV_FILE_PATH = System.getProperty("user.dir") + "/build/tmp/transactions-output.csv";
    ...
   }
   ```

   Next, write the `EnrichedTransaction` as a string to that file location, following the below format for each line in the file:

   ```csv
   <enriched transaction id>,<cash card id>,<authorization amount>,<cardholder name>,<cardholder user id>,<cardholder address>,<approval status>
   ```

   As we mentioned, there are many techniques for writing data to a file in Java. We will primarily use the `StringJoiner`, `Paths`, and `Files` utilities.

   Here is the code we used:

   ```java
   @Configuration
   public class CashCardTransactionSink {

       public static final String CSV_FILE_PATH = System.getProperty("user.dir") + "/build/tmp/transactions-output.csv";

       ...
       @Bean
       public Consumer<EnrichedTransaction> sinkToConsole() {
           ...
       }

       // Add the file sink Consumer
       @Bean
       public Consumer<EnrichedTransaction> cashCardTransactionFileSink() {
           return enrichedTransaction -> {
               StringJoiner joiner = new StringJoiner(",");
               StringJoiner enrichedTxnTextual = joiner.add(String.valueOf(enrichedTransaction.id()))
                       .add(String.valueOf(enrichedTransaction.cashCard().id()))
                       .add(String.valueOf(enrichedTransaction.cashCard().amountRequestedForAuth()))
                       .add(enrichedTransaction.cardHolderData().name())
                       .add(enrichedTransaction.cardHolderData().userId().toString())
                       .add(enrichedTransaction.cardHolderData().address())
                       .add(enrichedTransaction.approvalStatus().name());
               Path path = Paths.get(CSV_FILE_PATH);
               try {
                   ensureSinkFileExists();
                   Files.writeString(path, enrichedTxnTextual.toString() + "\n", StandardOpenOption.APPEND);
               } catch (IOException e) {
                   throw new RuntimeException(e);
               }
           };
       }

       // Also add this helper method
       private void ensureSinkFileExists() throws IOException {
           new File(CSV_FILE_PATH).createNewFile();
       }
   }
   ```

   Here are the `import` statements:

   ```java
   import java.io.File;
   import java.io.IOException;
   import java.nio.file.Files;
   import java.nio.file.Path;
   import java.nio.file.Paths;
   import java.util.StringJoiner;
   import java.nio.file.StandardOpenOption;
   ```

   The code is fairly simple, if lengthy. Pick it apart as desired, or reimplement it as as long as the following are accomplished:

   - Receive the `EnrichedTransaction` in our `Consumer` lambda.
   - Append line to the file `build/tmp/transactions-output.csv` with all that sweet `EnrichedTransaction` data, matching the format we defined earlier.

   Keep in mind that, in real-world scenarios, this is where the complex business logic is placed.

   Before we write our tests, let's get a preview of what happens when we run our application.

   Wouldn't it be interesting if things were not working correctly for some reason?

1. Run the **Sink** application.

   Let's try to run our **Sink** application the same way we did earlier:

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   [~/exercises] $ ./gradlew cashcard-transaction-sink:bootRun --args="--spring.cloud.stream.bindings.sinkToConsole-in-0.destination=enrichTransaction-out-0"
   ...
   BUILD SUCCESSFUL in 3s
   6 actionable tasks: 3 executed, 3 up-to-date
   ```

   This output is a bit confusing: while `bootRun` states the status is `BUILD SUCCESSFUL`, our application is _not_ supposed to exit! Our application should remain running and consuming enriched transactions.

   Looking at the output in more detail, you will see a `WARN` line:

   ```shell
   [~/exercises] $ ./gradlew cashcard-transaction-sink:bootRun --args="--spring.cloud.stream.bindings.sinkToConsole-in-0.destination=enrichTransaction-out-0"
   ...
   20XX-XX-XXTXX:XX:XX.XXXZ  WARN 10892 --- [cashcard-sink] [           main] c.f.c.c.BeanFactoryAwareFunctionRegistry : Multiple functional beans were found [cashCardTransactionFileSink, sinkToConsole], thus can't determine default function definition. Please use 'spring.cloud.function.definition' property to explicitly define it.
   ...
   ```

   Interesting! Spring Cloud Stream is telling us:

   > Multiple functional beans were found [cashCardTransactionFileSink, sinkToConsole], thus can't determine default function definition.

   This is the multi-binding issue we eluded to at the beginning of this step: Spring Cloud Stream cannot determine if we want to make one, all, or some other combination of bindings available.

We will need to specify which bindings we want loaded. Let's start that process in our tests.
