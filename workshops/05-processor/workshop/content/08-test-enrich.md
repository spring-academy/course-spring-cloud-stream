+++
title="Test Enrichment"
+++

We know that we are receiving data from the output binding.

```editor:select-matching-text
file: ~/exercises/cashcard-transaction-enricher/src/test/java/example/cashcard/enricher/CashCardTransactionEnricherTests.java
text: "Message<byte[]> result = outputDestination.receive(5000, \"enrichTransaction-out-0\");"
description: "Review receiving data in our test"
```

```java
Message<byte[]> result = outputDestination.receive(5000, "enrichTransaction-out-0");
```

But, we only check to make sure the message is not `null`.

```java
assertThat(result).isNotNull();
```

Lame! We can do better than that.

Let's make sure our `Transaction` is actually enriched as an `EnrichedTransaction`.

1. Mock the `enrichmentService`.

   Similar to our **Source** application, we need to Mock our service so we can carefully control the data it returns.

   ```editor:select-matching-text
   file: ~/exercises/cashcard-transaction-enricher/src/main/java/example/cashcard/service/EnrichmentService.java
   text: "public EnrichedTransaction enrichTransaction(Transaction transaction)"
   description: "Review the EnrichmentService"
   ```

   Let's mock up some data and ensure we can assert the resultant data with some certainty.

   ```editor:open-file
   file: ~/exercises/cashcard-transaction-enricher/src/test/java/example/cashcard/enricher/CashCardTransactionEnricherTests.java
   description: "Update the test"
   ```

   First, create a `@MockBean` for `EnrichmentService` for the test.

   ```java
   public class CashCardTransactionEnricherTests {

     @MockBean
     private EnrichmentService enrichmentService;
     ...
   ```

   Here are the new `import`s:

   ```java
   import example.cashcard.service.EnrichmentService;
   import org.springframework.boot.test.mock.mockito.MockBean;
   ```

   Then, update the test to create an `EnrichedTransaction` to be returned by our mocked'ed service:

   ```java
   @Test
   void enrichmentServiceShouldAddDataToTransactions(
                       @Autowired InputDestination inputDestination,
                       @Autowired OutputDestination outputDestination) throws IOException {

     Transaction transaction = new Transaction(1L, new CashCard(123L, "sarah1", 1.00));

     // Wrap the Transaction in an EnrichedTransaction
     EnrichedTransaction enrichedTransaction = new EnrichedTransaction(
       transaction.id(),
       transaction.cashCard(),
       ApprovalStatus.APPROVED,
       new CardHolderData(UUID.randomUUID(), transaction.cashCard().owner(), "123 Main Street"));

     // mock the service's expected invocation and return value
     given(enrichmentService.enrichTransaction(transaction)).willReturn(enrichedTransaction);
     ...
   ```

   You'll need the following `import` statements:

   ```java
   import example.cashcard.domain.ApprovalStatus;
   import example.cashcard.domain.CardHolderData;
   import example.cashcard.domain.EnrichedTransaction;
   import java.util.UUID;
   import static org.mockito.BDDMockito.given;
   ```

1. Test interaction with the enrichment service.

   Let's give our selves confidence that, when Spring Cloud Stream sees a `Transaction` message on the `enrichTransaction-in-0` topic, that our service will be used to enrich that `Transaction`:

   ```java
   ...
   assertThat(result).isNotNull();

   // Deserialize the EnrichedTransaction
   ObjectMapper objectMapper = new ObjectMapper();
   EnrichedTransaction receivedData = objectMapper.readValue(result.getPayload(), EnrichedTransaction.class);

   assertThat(receivedData).isEqualTo(enrichedTransaction);
   }
   ```

   One more import:

   ```java
   import com.fasterxml.jackson.databind.ObjectMapper;
   ```

   Here is the full test:

   ```java
   package example.cashcard.enricher;

   import static org.assertj.core.api.Assertions.assertThat;
   import static org.mockito.BDDMockito.given;

   import java.io.IOException;
   import java.util.UUID;

   import org.junit.jupiter.api.Test;
   import org.springframework.beans.factory.annotation.Autowired;
   import org.springframework.boot.autoconfigure.SpringBootApplication;
   import org.springframework.boot.test.context.SpringBootTest;
   import org.springframework.boot.test.mock.mockito.MockBean;
   import org.springframework.cloud.stream.binder.test.InputDestination;
   import org.springframework.cloud.stream.binder.test.OutputDestination;
   import org.springframework.cloud.stream.binder.test.TestChannelBinderConfiguration;
   import org.springframework.context.annotation.Import;
   import org.springframework.integration.support.MessageBuilder;
   import org.springframework.messaging.Message;

   import com.fasterxml.jackson.databind.ObjectMapper;

   import example.cashcard.domain.ApprovalStatus;
   import example.cashcard.domain.CardHolderData;
   import example.cashcard.domain.CashCard;
   import example.cashcard.domain.EnrichedTransaction;
   import example.cashcard.domain.Transaction;
   import example.cashcard.service.EnrichmentService;

   @SpringBootTest
   @Import(TestChannelBinderConfiguration.class)
   public class CashCardTransactionEnricherTests {

       @MockBean
       private EnrichmentService enrichmentService;

       @Test
       void enrichmentServiceShouldAddDataToTransactions(@Autowired InputDestination inputDestination,
               @Autowired OutputDestination outputDestination) throws IOException {

           Transaction transaction = new Transaction(1L, new CashCard(123L, "Kumar Patel", 1.00));
           EnrichedTransaction enrichedTransaction = new EnrichedTransaction(transaction.id(), transaction.cashCard(),
                   ApprovalStatus.APPROVED,
                   new CardHolderData(UUID.randomUUID(), transaction.cashCard().owner(), "123 Main Street"));

           given(enrichmentService.enrichTransaction(transaction)).willReturn(enrichedTransaction);

           Message<Transaction> message = MessageBuilder.withPayload(transaction).build();
           inputDestination.send(message, "enrichTransaction-in-0");

           Message<byte[]> result = outputDestination.receive(5000, "enrichTransaction-out-0");
           assertThat(result).isNotNull();

           ObjectMapper objectMapper = new ObjectMapper();
           EnrichedTransaction receivedData = objectMapper.readValue(result.getPayload(), EnrichedTransaction.class);
           assertThat(receivedData).isEqualTo(enrichedTransaction);
       }

       @SpringBootApplication
       public static class App {

       }
   }
   ```

   Those were a lot of changes!

   Let's see how we did.

1. Run the tests again.

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   [~/exercises] $ ./gradlew test
   ...
   BUILD SUCCESSFUL in 23s
   8 actionable tasks: 8 executed
   ```

   They pass!

   Feel free to play with the test setup to see different ways the tests pass and fail.

Let's reward ourselves by running _both_ of our applications and monitor Kafka to see our data flowing.
