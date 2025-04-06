+++
title="Refactor our application"
+++

Our tests are encountering issues due to our fixed-schedule and on-demand Spring Cloud Stream processes running at the same time. This is indicative of our choice to combine the two configurations, which gives us less control over them at times.

Let's separate these two concerns into their contingent parts, which is a better design pattern anyway.

We will accomplish this by renaming several classes to be more specific, and moving the on-demand classes to their own package.

1. Create a new `CashCardTransactionOnDemand` configuration.

   Let's extract the on-demand functionality out of `CashCardStream` and into a new configuration class.

   First, create a new package named `example.cashcard.ondemand`.

   Next, create a new class named `CashCardTransactionOnDemand` in the `ondemand` package:

   ```editor:append-lines-to-file
   file: ~/exercises/src/main/java/example/cashcard/ondemand/CashCardTransactionOnDemand.java
   description: "Generate the empty CashCardTransactionOnDemand class"
   ```

   ```java
   package example.cashcard.ondemand;

   import org.springframework.context.annotation.Configuration;

   @Configuration
   public class CashCardTransactionOnDemand {

   }
   ```

1. Extract the on-demand functionality.

   Next, move all of the on-demand functionality out of `CashCardStream` and into `CashCardTransactionOnDemand`:

   ```java
   package example.cashcard.ondemand;

   import org.springframework.cloud.stream.function.StreamBridge;
   import org.springframework.context.annotation.Configuration;

   import example.cashcard.domain.Transaction;

   @Configuration
   public class CashCardTransactionOnDemand {

       private final StreamBridge streamBridge;

       public CashCardTransactionOnDemand(StreamBridge streamBridge) {
           this.streamBridge = streamBridge;
       }

       public void publishOnDemand(Transaction transaction) {
           this.streamBridge.send("approvalRequest-out-0", transaction);
       }
   }
   ```

1. Revert all changes in `CashCardStream`.

   Revisit `CashCardStream` and make sure that all changes have been reverted.

   ```editor:select-matching-text
   file: ~/exercises/src/main/java/example/cashcard/stream/CashCardStream.java
   text: "public class CashCardStream"
   description: "Review the CashCardStream class"
   ```

   It should look exactly as it did when you started this lab.

   ```java
   package example.cashcard.stream;

   import example.cashcard.service.DataSourceService;
   import example.cashcard.domain.Transaction;
   import java.util.function.Supplier;
   import org.springframework.context.annotation.Bean;
   import org.springframework.context.annotation.Configuration;

   @Configuration
   public class CashCardStream {

       @Bean
       public Supplier<Transaction> approvalRequest(DataSourceService dataSource) {
           return () -> {
               return dataSource.getData();
           };
       }

       @Bean
       public DataSourceService dataSourceService() {
           return new DataSourceService();
       }
   }
   ```

   This is another real-life situation for developers: sometimes you make a bunch of changes, only to revert them! But, as you can see, we have made a lot of progress, and the code was not lost.

1. Rename `CashCardStream`.

   Now that we have two Spring Cloud Stream configurations it is important to semantically name them and make sure they are unambiguous.

   Rename `CashCardStream` to `CashCardTransactionStream`, making sure to update all references to class.

   {{< note >}}
   You might want to use the **Rename Symbol** feature of the Java-aware VSCode IDE for this to make sure that all references are updates.

   1. Right-click on the class name `CashCardStream`
   1. Select "Rename Symbol"
   1. Enter "CashCardTransactionStream"

   When you press the `ENTER` key, all references will be updated.

   ![Rename the class, step 1](/workshop/content/assets/rename-symbol-1.png)

   ![Rename the class, step 2](/workshop/content/assets/rename-symbol-2.png)
   {{< /note >}}

   Now that we have a new, on-demand dedicated configuration, we need to update the on-demand functionality of our application to use it.

1. Update the controller.

   Our controller needs to switch to using the new on-demand focused class to access `StreamBridge`.

   Update `CashCardController` to reference `CashCardTransactionOnDemand` rather than `CashCardTransactionStream`. Consider updating the variable name, too.

   ```editor:select-matching-text
   file: ~/exercises/src/main/java/example/cashcard/controller/CashCardController.java
   text: "import example.cashcard.ondemand.CashCardTransactionStream"
   description: "Update the controller"
   ```

   ```java
   ​​package example.cashcard.controller;
   ...
   import example.cashcard.ondemand.CashCardTransactionOnDemand;
   ...

   @RestController
   public class CashCardController {

      private final CashCardTransactionOnDemand cashCardTransactionOnDemand;

      public CashCardController(@Autowired CashCardTransactionOnDemand cashCardTransactionOnDemand) {
          this.cashCardTransactionOnDemand = cashCardTransactionOnDemand;
      }

      @PostMapping(path = "/publish/txn")
      public void publishTxn(@RequestBody Transaction transaction) {
          this.cashCardTransactionOnDemand.publishOnDemand(transaction);
      }
   }
   ```

1. Update the controller test.

   Similar to the `CashCardController` changes above, update `CashCardControllerTests` to reference `CashCardTransactionOnDemand`.

   ```editor:open-file
   file: ~/exercises/src/test/java/example/cashcard/controller/CashCardControllerTests.java
   description: "Update CashCardControllerTests"
   ```

   ```java
   // update the two references from CashCardTransactionStream to CashCardTransactionOnDemand
   ...
   import example.cashcard.ondemand.CashCardTransactionOnDemand;
   ...

   @SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT)
   @Import({TestChannelBinderConfiguration.class, CashCardTransactionOnDemand.class})

   class CashCardControllerTests {
    ...
   }
   ```

1. Rerun the tests.

   When we run this test, we will see that the proper assertions work as expected.

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   [~/exercises] $ ./gradlew test
   ...
   BUILD SUCCESSFUL in 10s
   4 actionable tasks: 4 executed
   ```

   Success!

Our refactoring is complete! Not only have we made our application design better by separating the fixed-schedule and on-demand concerns, we have also made our tests predictable and repeatable.

Let's reward ourselves by running the application and watching _both_ Spring Cloud Stream publishing methods work.
