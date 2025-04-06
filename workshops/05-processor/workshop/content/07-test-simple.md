+++
title="Testing the Plumbing"
+++

As we've mentioned, amazingly we have written all the production code we need for our system to function properly.

Let's move on to adding some tests for the code using the test binder that we used in earlier labs.

## Basic Checks

We are going to follow the same pattern as our **Source** application and make sure that we can receive messages sent to our **Processor's** `outputDestination`.

Take a moment to review the **Source** application's test.

Feel free to use the patterns in that test to bootstrap the **Processor** test if you would like. Move on to our steps below when you are ready.

```editor:open-file
file: ~/exercises/cashcard-transaction-source/src/test/java/example/cashcard/stream/CashCardApplicationTests.java
description: "Review the Source test"
```

1. Autowire the Spring Cloud Stream dependencies.

   Open our Processor test and add the Spring Cloud dependencies and `import` statements we need:

   - The test binding configuration
   - The input and output destinations

   ```editor:open-file
   file: ~/exercises/cashcard-transaction-enricher/src/test/java/example/cashcard/enricher/CashCardTransactionEnricherTests.java
   description: "Wire up Spring Cloud Stream"
   ```

   ```java
   @SpringBootTest
   @Import(TestChannelBinderConfiguration.class)
   public class CashCardTransactionEnricherTests {

     @Test
     void enrichmentServiceShouldAddDataToTransactions(@Autowired InputDestination inputDestination,
                         @Autowired OutputDestination outputDestination) throws IOException {

       assertThat(true).isTrue();
     }

     @SpringBootApplication
     public static class App {

     }
   }
   ```

   You'll need these new import statements:

   ```java
   import org.springframework.beans.factory.annotation.Autowired;
   import org.springframework.cloud.stream.binder.test.InputDestination;
   import org.springframework.cloud.stream.binder.test.OutputDestination;
   ```

1. Test the bindings.

   Notice that above we inject **_both_** the `InputDestination` and the `OutputDestination` beans from the test binder.

   In our Source labs, we only needed the `OutputDestination`, since that application only sends data to the middleware.

   Now that we are testing the **Processor**, we also need the `InputDestination` autowired, as our **Processor** needs to both receive and send data to and from the middleware.

   Let's update the test perform the following:

   1. Create a `Transaction`.
   1. Wrap it in a `Message` and send it to the output topic.
   1. Receive it as a `Message` from the input topic.
   1. Make sure that the `Message` it is not `null`.

   Reference previous instructions for the default output and input topic names.

   Feel free to write that code on your own, or reference the code-block below.

   ```java
   @Test
   void enrichmentServiceShouldAddDataToTransactions(
       @Autowired InputDestination inputDestination,
       @Autowired OutputDestination outputDestination) throws IOException {

       Transaction transaction = new Transaction(1L, new CashCard(123L, "sarah1", 1.00));
       Message<Transaction> message = MessageBuilder.withPayload(transaction).build();
       inputDestination.send(message, "enrichTransaction-in-0");

       Message<byte[]> result = outputDestination.receive(5000, "enrichTransaction-out-0");
       assertThat(result).isNotNull();
   }
   ```

   Be sure to add the new `import` statements:

   ```java
   import org.springframework.messaging.Message;
   import org.springframework.integration.support.MessageBuilder;
   import example.cashcard.domain.CashCard;
   import example.cashcard.domain.Transaction;
   ```

1. Understand the test in more detail.

   In the test implementation, we create a simple `Transaction` object and then provide it to `InputDestination`'s `send` method.

   When sending it to `InputDestination`, we must wrap the `Transaction` object in a Spring `Message` object. For that, we seek the help of the `MessageBuilder` class.

   Let us take a closer look at our input sending:

   ```java
   inputDestination.send(message, "enrichTransaction-in-0");
   ```

   - The first argument is the message that contains the `Transaction`. What about the second argument?
   - We want the message to be sent to the actual binding name, which in this case is `enrichTransaction-in-0`, which matches the default we learned about earlier.

   Remember that `enrichTransaction-in-0` matches the input binding name from our configuration. Any message sent to this binding will trigger that `Function` bean.

   ```editor:select-matching-text
   file: ~/exercises/cashcard-transaction-enricher/src/main/java/example/cashcard/enricher/CashCardTransactionEnricher.java
   text: "public Function<Transaction, EnrichedTransaction> enrichTransaction(EnrichmentService enrichmentService)"
   description: "Review the Processor Function"
   ```

1. Run the tests.

   Before we move on, let's run our tests and make sure everything is working as expected:

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   [~/exercises] $ ./gradlew test
   ...
   BUILD SUCCESSFUL in 23s
   8 actionable tasks: 8 executed
   ```

   Everything should pass!

## Learning Moment: Bean Initialization

One question that you might ask at this point is: how is the `Function` bean initialized?

The fact that we are in a `@SpringBootTest` context, it will scan the corresponding production packages under `src/main/java`.

It will find any `@Configuration` components and instantiates all the relevant beans, which include our function bean and it's dependencies.

Long story short: both of the following beans are available in our test.

```java
@Bean
public Function<Transaction, EnrichedTransaction> enrichTransaction(EnrichmentService enrichmentService) {
    return transaction -> {
        return enrichmentService.enrichTransaction(transaction);
    };
}

@Bean
EnrichmentService enrichmentService() {
    return new EnrichmentService();
}
```

Let's make our test a bit more thorough by making sure that the simple `Transaction` we receive is properly enriched by our application.
