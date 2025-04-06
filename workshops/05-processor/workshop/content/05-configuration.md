+++
title="Spring Cloud Stream Configuration"
+++

We are now ready to write the piece of code that is the crux of this lab - the actual **Processor** that consumes the data and then calls the enrichment service to enrich the transaction.

1. Review the two configuration classes.

   As we've mentioned, we're following many of the patterns established in our **Source** application to build our **Processor** application.

   First, review the **Source** application's configuration:

   ```editor:open-file
   file: ~/exercises/cashcard-transaction-source/src/main/java/example/cashcard/stream/CashCardTransactionStream.java
   description: "Review the Source configuration"
   ```

   Buy contrast, our **Processor** applications configuration class is mostly empty at the moment:

   ```editor:open-file
   file: ~/exercises/cashcard-transaction-enricher/src/main/java/example/cashcard/enricher/CashCardTransactionEnricher.java
   description: "Enrich the transactions"
   ```

   Can you predict how we might follow this pattern in our **Processor** application?

   - We need to make our service available as a bean.
   - We'll also need some kind of lambda expression bean to invoke the service, returning a `java.util.function.Function`.

   After your review, feel free to attempt to implement those changes.

   When you're finished, move on our version of the **Processor** configuration below.

1. Add the service bean.

   Open `CashCardTransactionEnricher` and make our `EnrichmentService` available as a bean:

   ```editor:open-file
   file: ~/exercises/cashcard-transaction-enricher/src/main/java/example/cashcard/enricher/CashCardTransactionEnricher.java
   description: "Add the service bean"
   ```

   ```java
   @Configuration
   public class CashCardTransactionEnricher {

       @Bean
       EnrichmentService enrichmentService() {
           return new EnrichmentService();
       }
   }
   ```

   Be sure to add the new `import` statements:

   ```java
   import org.springframework.context.annotation.Bean;
   import example.cashcard.service.EnrichmentService;
   ```

1. Invoke the service.

   As mentioned in previous lessons and earlier in this lab, Spring Cloud Stream utilizes the `java.util.function.Function` interface for processors.

   Let us add a `Function` to process and enrich a supplied `Transaction`:

   ```java
   @Bean
   public Function<Transaction, EnrichedTransaction> enrichTransaction(EnrichmentService enrichmentService) {
       return transaction -> {
           return enrichmentService.enrichTransaction(transaction);
       };
   }
   ```

   You'll need these new `import` statements:

   ```java
   import java.util.function.Function;
   import example.cashcard.domain.EnrichedTransaction;
   import example.cashcard.domain.Transaction;
   ```

   The implementation now consists of the following:

   - We define a method that returns a `java.util.function.Function` object.
   - We define a lambda expression that takes the input as a "normal" transaction, then uses our new service to output and return an `EnrichedTransaction`.

Although the implementation is quite simple, Spring Cloud Stream does a number of things behind the scenes. Let's spend a moment talking about that.
