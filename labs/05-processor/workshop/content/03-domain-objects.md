+++
title="Domain Objects"
+++

As we mentioned, we are going to enrich our cash card transaction data with additional information:

- Payment amount approval status
- Cardholder name and address

Let's add the domain objects we need to hold this data.

1. Add the `ApprovalStatus`.

   `ApprovalStatus` will represent statuses such as "approved", "denied", and others.

   Let's use an `enum`:

   ```editor:append-lines-to-file
   file: ~/exercises/cashcard-transaction-enricher/src/main/java/example/cashcard/domain/ApprovalStatus.java
   description: "Generate the empty ApprovalStatus enum"
   ```

   ```java
   package example.cashcard.domain;

   public enum ApprovalStatus {

       APPROVED,

       DENIED,

       AUTHORIZATION_PENDING,

       FRAUD_DETECTED;

   }

   ```

1. Add `CardHolderData`.

   `CashHolderData` has the id, name, and address of the cashcard owner:

   ```editor:append-lines-to-file
   file: ~/exercises/cashcard-transaction-enricher/src/main/java/example/cashcard/domain/CardHolderData.java
   description: "Generate the empty CardHolderData class"
   ```

   ```java
   package example.cashcard.domain;

   import java.util.UUID;

   public record CardHolderData(UUID userId, String name, String address) {
   }
   ```

1. Add `EnrichedTransaction`.

   Finally, all of this new data needs to be wrapped up in a new kind of transaction: an `EnrichedTransaction`.

   ```editor:append-lines-to-file
   file: ~/exercises/cashcard-transaction-enricher/src/main/java/example/cashcard/domain/EnrichedTransaction.java
   description: "Generate the empty EnrichedTransaction class"
   ```

   ```java
   package example.cashcard.domain;

   public record EnrichedTransaction(Long id,
           CashCard cashCard,
           ApprovalStatus approvalStatus,
           CardHolderData cardHolderData) {
   }
   ```

   `EnrichedTransaction` contains the approval status of the original transaction data and some additional card holder metadata.

Next, enrich our original transactions using these new domain objects.
