+++
title="Testing our Supplier - Test Logic"
+++

At this point we are ready to write the logic of our test so we can be confident that our **Source** application is doing exactly what we need it to do.

1. Configure the mock `DataSourceService`.

   First, let's "mock" the actual data source service as we want to control the data it returns.

   Our `DataSourceService` would normally generate randomized data, which is extremely hard to use in tests -- you never know what data you're going to get!

   Luckily, we have used Spring's `@MockBean` annotation to inject a _mock_ `DataSourceService` bean we can control.

   ```editor:select-matching-text
   file: ~/exercises/src/test/java/example/cashcard/stream/CashCardApplicationTests.java
   text: "void basicCashCardSupplier1(@Autowired OutputDestination outputDestination)"
   description: "Update basicCashCardSupplier1"
   ```

   ```java
   @Test
   void basicCashCardSupplier1(@Autowired OutputDestination outputDestination) throws IOException {
     // Configure the mocked DataSourceService
     Transaction testTransaction = new Transaction(1L, new CashCard(123L, "sarah1", 1.00));
     given(dataSourceService.getData()).willReturn(testTransaction);
   }
   ```

   Be sure to add the following new `import` statements:

   ```java
   import static org.mockito.BDDMockito.given;
   import example.cashcard.domain.CashCard;
   import example.cashcard.domain.Transaction;
   ```

   Here, we have created a simple `testTransaction`, and configured `dataSourceService` to always return it when the `getData()` method is called.

   Now that have a consistent data returned, let's continue testing our **Source** application.

1. Invoke the `outputDestination`.

   Next, we need to trigger our Spring Cloud Stream `outputDestination` to perform its job.

   We are pretty sure that when it is invoked it will fetch data from our data source, but we need to test it to be sure.

   ```java
   @Test
   void basicCashCardSupplier1(@Autowired OutputDestination outputDestination) throws IOException {
     Transaction testTransaction = new Transaction(1L, new CashCard(123L, "sarah1", 1.00));
     given(dataSourceService.getData()).willReturn(testTransaction);

     // invoke the outputDestination and make sure it returned something
     Message<byte[]> result = outputDestination.receive(5000, "approvalRequest-out-0");
     assertThat(result).isNotNull();
   }
   ```

   Be sure to add the following new `import` statements:

   ```java
   import static org.assertj.core.api.Assertions.assertThat;
   import org.springframework.messaging.Message;
   ```

   Here, you can see that we invoke the `outputDestination`, then assert that it returns _something_ that is not `null`. But, there is a lot more going on here.

   Let's dive deeper.

   ### Learning Moment: `outputDestination.receive`

   Let's look at this line:

   ```java
   Message<byte[]> result = outputDestination.receive(5000, "approvalRequest-out-0");
   ```

   What's going on here?

   - The call `outputDestination.receive` returns the data that the supplier component produces, which in this case, is what we set through the expectation on the mocked `DataSourceService` bean: `testTransaction`.
   - For producer bindings, Spring Cloud Stream uses the following naming strategy by default to generate the output binding name `approvalRequest-out-0`:

     The `Supplier` returns a lambda expression. Since we are not specifying any custom bean names, the bean name will be the method name which is `approvalRequest` in this case.

     ```editor:select-matching-text
     file: ~/exercises/src/main/java/example/cashcard/stream/CashCardStream.java
     text: "public Supplier<Transaction> approvalRequest(DataSourceService dataSource)"
     description: "Review the approvalRequest method"
     ```

     The bean name is followed by the suffix `-out-0`. If there are multiple output bindings, the` -0` part is incremented by the corresponding index, but that is an advanced topic, and we don't need to be concerned about that at this point.

     The main thing to remember here is that our output binding name from this `Supplier` becomes `approvalRequest-out-0`.

   - We are requesting the `OutputDestination` to receive data from our output binding - `approvalRequest-out-0`. Since the supplier is called every one (1) second we should get data immediately, but we put an upper threshold of 5 seconds to timeout as indicated by the first argument just because we can.

   With that, let's run our tests.

1. Run the tests.

   In either the **Editor** or **Terminal**, run the tests and see if our **Source** application returns at least _something_ when is invoked.

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   [~/exercises] $ ./gradlew test
   ...
   BUILD SUCCESSFUL in 4s
   4 actionable tasks: 1 executed, 3 up-to-date
   ```

   It passes!

   Now let's add a few more assertions to make sure it's returning the data we expect.

1. Enhance the test.

   We've tested that our **Source** application is returning _something_, but is it returning _the right something?_

   Let's find out.

   Add assertions that test that the transaction an cash card are the values we expect.

   ```editor:open-file
   file: ~/exercises/src/test/java/example/cashcard/stream/CashCardApplicationTests.java
   description: "Open CashCardApplicationTests"
   ```

   ```java
   @Test
   void basicCashCardSupplier1(@Autowired OutputDestination outputDestination) throws IOException {
     Transaction testTransaction = new Transaction(1L, new CashCard(123L, "sarah1", 1.00));
     given(dataSourceService.getData()).willReturn(testTransaction);

     Message<byte[]> result = outputDestination.receive(5000, "approvalRequest-out-0");
     assertThat(result).isNotNull();

     // Deserialize the transaction and inspect it
     ObjectMapper objectMapper = new ObjectMapper();
     Transaction transaction = objectMapper.readValue(result.getPayload(), Transaction.class);

     assertThat(transaction.id()).isEqualTo(1L);
     assertThat(transaction.cashCard()).isEqualTo(testTransaction.cashCard());
   }

   ```

   Be sure and add the new `import`:

   ```java
   import com.fasterxml.jackson.databind.ObjectMapper;
   ```

   Now our test is much more robust:

   - It uses an `ObjectMapper` to deserialize the received data into a `Transaction`.
   - Then, we test that the transaction ID and its cash card data are the same values we originally configured.

   The entire test now looks like this:

   ```java
   package example.cashcard.stream;

   import static org.assertj.core.api.Assertions.assertThat;
   import static org.mockito.BDDMockito.given;

   import java.io.IOException;

   import org.junit.jupiter.api.Test;
   import org.springframework.beans.factory.annotation.Autowired;
   import org.springframework.boot.test.context.SpringBootTest;
   import org.springframework.boot.test.mock.mockito.MockBean;
   import org.springframework.cloud.stream.binder.test.OutputDestination;
   import org.springframework.cloud.stream.binder.test.TestChannelBinderConfiguration;
   import org.springframework.context.annotation.Import;
   import org.springframework.messaging.Message;

   import com.fasterxml.jackson.databind.ObjectMapper;

   import example.cashcard.domain.CashCard;
   import example.cashcard.domain.Transaction;
   import example.cashcard.service.DataSourceService;

   @SpringBootTest
   @Import(TestChannelBinderConfiguration.class)
   class CashCardApplicationTests {

     @MockBean
     private DataSourceService dataSourceService;

     @Test
     void basicCashCardSupplier1(@Autowired OutputDestination outputDestination) throws IOException {
       Transaction testTransaction = new Transaction(1L, new CashCard(123L, "sarah1", 1.00));
       given(dataSourceService.getData()).willReturn(testTransaction);

       Message<byte[]> result = outputDestination.receive(5000, "approvalRequest-out-0");
       assertThat(result).isNotNull();

       ObjectMapper objectMapper = new ObjectMapper();
       Transaction transaction = objectMapper.readValue(result.getPayload(), Transaction.class);
       assertThat(transaction.id()).isEqualTo(1L);
       assertThat(transaction.cashCard()).isEqualTo(testTransaction.cashCard());
     }
   }
   ```

1. Run the tests again.

   Let's make sure our new assertions are correct.

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   [~/exercises] $ ./gradlew test
   ...
   BUILD SUCCESSFUL in 4s
   4 actionable tasks: 1 executed, 3 up-to-date
   ```

   Everything passes!

That was a lot of testing!

Now let's reward ourselves by running the application and watching it work.
