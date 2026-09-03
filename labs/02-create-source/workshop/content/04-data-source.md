+++
title="Create the Fake Data Source"
+++

Our Spring Cloud Stream application needs data to operate upon.

Remember earlier when we said we'd simulate fetching cash card data from a data-storage system? This is it!

An enterprise-level **Source** application might contain complex logic to  query databases, parse files from a file system, fetch data from an FTP server, or any number of sophisticated operations.

We're not going to do any of that.

Instead, our source application will simply generate random cash card data in a custom-made service.

1. Create the `service` package.

   Using either the **Terminal** or the **Editor**, create a new package for our data service: `example.cashcard.service`.

   The directory will be `~/exercises/src/main/java/example/cashcard/service`.

   This is where we keep our service classes.

   Now we need a fake-data generator.

1. Create the `DataSourceService`.

   Within the `service` package, create a new class called `DataSourceService`, with the implementation as below:

   ```editor:append-lines-to-file
   file: ~/exercises/src/main/java/example/cashcard/service/DataSourceService.java
   description: "Generate the empty DataSourceService class"
   ```

   ```java
   package example.cashcard.service;

   import example.cashcard.domain.CashCard;
   import example.cashcard.domain.Transaction;
   import java.util.Random;

   public class DataSourceService {

     public Transaction getData() {
       CashCard cashCard = new CashCard(
         new Random().nextLong(), // Random ID
         "sarah1",
         new Random().nextDouble(100.00) // Random Amount
       );
       return new Transaction(new Random().nextLong(), cashCard);
     }
   }

   ```

As you can see, our data source service has a single method that returns a `Transaction` containing random cash card data for a user named `sarah1`.

Now that we have domain objects and a fake-data service, let's start using them in a real Spring Cloud Stream application!
