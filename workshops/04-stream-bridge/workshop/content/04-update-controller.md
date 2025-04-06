+++
title="Update the Controller"
+++

Now that we have a `StreamBridge` available in our configuration, let's use it in our controller to pass `POST`ed transaction data to our middleware layer for processing.

1. Add a `CashCardStream` field and constructor argument.

   In order to use the `CashCardStream`'s `publishOnDemand` method, we first need to inject `CashCardStream` into our controller.

   Add the `cashCardStream` local variable, and set it in the controller's constructor:

   ```editor:select-matching-text
   file: ~/exercises/src/main/java/example/cashcard/controller/CashCardController.java
   text: "public class CashCardController"
   description: "Update the CashCardController"
   ```

   ```java
   @RestController
   public class CashCardController {

     private CashCardStream cashCardStream;

     public CashCardController(CashCardStream cashCardStream) {
       this.cashCardStream = cashCardStream;
     }
     ...
   }
   ```

   Be sure to add the new `import` statement:

   ```java
   import example.cashcard.stream.CashCardStream;
   ```

   Now let's use it.

1. Use `publishOnDemand` in the `POST` handler.

   We are now ready to publish, on-demand!

   Update the `POST` request handler method to pass the `transaction` to `publishOnDemand`:

   ```java
   @PostMapping(path = "/publish/txn")
   public void publishTxn(@RequestBody Transaction transaction) {
      this.cashCardStream.publishOnDemand(transaction);
   }
   ```

   Excellent!

   But we're never done until we've updated the related tests. Let's do that now.

1. Update the controller test.

   At this point, we are ready to test the `StreamBridge` code we added.

   You might notice that our controller test does not reference any Spring Cloud Stream framework at all.

   Not yet, anyway!

   ```editor:select-matching-text
   file: ~/exercises/src/test/java/example/cashcard/controller/CashCardControllerTests.java
   text: "postShouldSendTransactionAsAMessage"
   description: "Review CashCardControllerTests"
   ```

   First, we need to trigger our Spring Cloud Stream `outputDestination` and test the `Transaction` receive from the destination, just as we've done in previous tests:

   ```java
   @Test
   void postShouldSendTransactionAsAMessage() throws IOException {
     ...
     assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);

     // trigger the outputDestination
     Message<byte[]> result = outputDestination.receive(5000, "approvalRequest-out-0");
     assertThat(result).isNotNull();

     // deserialize and test the Transaction
     ObjectMapper objectMapper = new ObjectMapper();
     Transaction transactionFromMessage = objectMapper.readValue(result.getPayload(), Transaction.class);
     assertThat(transactionFromMessage.id()).isEqualTo(postedTransaction.id());
   }
   ```

   Also, as in previous tests, we need to `import` the test binder's configuration, and autowire the `outputDestination`.

   In addition, we need to specifically `import` the `CashCardStream` class. This is because we are testing this from the `controller` package. In the earlier case with regular stream, we didn't need that since the class under test is under the same `stream` package:

   ```java
   // @Import the TestChannelBinderConfiguration and CashCardStream
   @Import({ TestChannelBinderConfiguration.class, CashCardStream.class })
   public class CashCardControllerTests {
     ...
     @Test
     // @Autowire the outputDestination
     void postShouldSendTransactionAsAMessage(@Autowired OutputDestination outputDestination) throws IOException {
        ...
     }
   }
   ```

   Finally, you'll need to add a whole bunch of required `import` statements:

   ```java
   import example.cashcard.stream.CashCardStream;
   import org.springframework.cloud.stream.binder.test.OutputDestination;
   import org.springframework.cloud.stream.binder.test.TestChannelBinderConfiguration;
   import org.springframework.context.annotation.Import;
   import org.springframework.messaging.Message;
   import com.fasterxml.jackson.databind.ObjectMapper;
   ```

   The entire test class now looks like this:

   ```java
   package example.cashcard.controller;

   import static org.assertj.core.api.Assertions.assertThat;

   import java.io.IOException;

   import org.junit.jupiter.api.Test;
   import org.springframework.beans.factory.annotation.Autowired;
   import org.springframework.boot.autoconfigure.SpringBootApplication;
   import org.springframework.boot.test.context.SpringBootTest;
   import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;
   import org.springframework.boot.test.web.client.TestRestTemplate;
   import org.springframework.boot.test.web.server.LocalServerPort;
   import org.springframework.cloud.stream.binder.test.OutputDestination;
   import org.springframework.cloud.stream.binder.test.TestChannelBinderConfiguration;
   import org.springframework.context.annotation.Import;
   import org.springframework.messaging.Message;

   import com.fasterxml.jackson.databind.ObjectMapper;

   import example.cashcard.domain.CashCard;
   import example.cashcard.domain.Transaction;
   import example.cashcard.stream.CashCardStream;

   @SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT)
   @Import({ TestChannelBinderConfiguration.class, CashCardStream.class })
   public class CashCardControllerTests {

       @LocalServerPort
       private int port;

       @Autowired
       private TestRestTemplate restTemplate;

       @Test
       void postShouldSendTransactionAsAMessage(@Autowired OutputDestination outputDestination) throws IOException {
          Transaction postedTransaction = new Transaction(123L, new CashCard(1L, "Foo Bar", 1.00));
          this.restTemplate.postForEntity("http://localhost:" + port + "/publish/txn", postedTransaction, Transaction.class);

          Message<byte[]> result = outputDestination.receive(5000, "approvalRequest-out-0");
          assertThat(result).isNotNull();
          ObjectMapper objectMapper = new ObjectMapper();
          Transaction transactionFromMessage = objectMapper.readValue(result.getPayload(), Transaction.class);
          assertThat(transactionFromMessage.id()).isEqualTo(postedTransaction.id());
       }

       @SpringBootApplication
       public static class App {

       }
   }
   ```

   Those were a lot of changes!

   Let's run the test and see what happens.

1. Run the test.

   Run the tests in the **Terminal**:

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   [~/exercises] $ ./gradlew test
   ...
   > Task :test FAILED

   3 tests completed, 1 failed

   FAILURE: Build failed with an exception.
   ```

   Wait... test failures?

This usually doesn't happen: our tests are failing! Let's find out why.
