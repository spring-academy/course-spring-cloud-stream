+++
title="Create the Domain Objects"
+++

We need domain objects that will hold our data so Spring Cloud Stream can work with it.

1. Create the `domain` package.

   Using either the **Terminal** or the **Editor**, create a new package for our domain: `example.cashcard.domain`.

   The directory will be `~/exercises/src/main/java/example/cashcard/domain`.

1. Create the `CashCard` domain class.

   Next, add the following `CashCard` domain objects to the package:

   ```editor:append-lines-to-file
   file: ~/exercises/src/main/java/example/cashcard/domain/CashCard.java
   description: "Generate the empty CashCard class"
   ```

   ```java
   package example.cashcard.domain;

   public record CashCard(
     Long id,
     String owner,
     Double amountRequestedForAuth
   ) {}

   ```

   This is our basic cash card domain object with an ID, the cash card owner, and the monetary amount requested for authorization.

1. Create the `Transaction` domain class.

   Next, we need a `Transaction` object within our domain. This object will represents cash card activity within the Family Cash Card system.

   ```editor:append-lines-to-file
   file: ~/exercises/src/main/java/example/cashcard/domain/Transaction.java
   description: "Generate the empty Transaction class"
   ```

   ```java
   package example.cashcard.domain;

   public record Transaction(Long id, CashCard cashCard) {}

   ```

   Notice that a Transaction contains two fields:

   - `Long id`: this is the transaction's unique ID. Every transaction must be tracked separately.
   - `CashCard cashCard`: this represents the specific cash card with activity. You defined this class in the previous step.

These are all the domain objects we need at the moment. Let's move on to using them to create some data.
