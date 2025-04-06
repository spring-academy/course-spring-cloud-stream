+++
title="Create the Source Stream"
+++

As the name implies, our new `DataSourceService` will be where our Spring Cloud Stream will source cash card transaction data.

Let's make a Spring Cloud Stream **Source** application that will _source_ its data from the `DataSourceService`.

As explained in the _Programming Model_ lessons, a **Source** in Spring Cloud Stream can be represented via the `java.util.function.Supplier` bean. Let's use that.

1. Create the `stream` package.

   Using either the **Terminal** or the **Editor**, create a new package for our domain: `example.cashcard.stream`.

   The directory will be `~/exercises/src/main/java/example/cashcard/stream`.

   Now let's configure our Spring Cloud Stream **Source**.

1. Create the `CashCardStream` class.

   Create a new Spring configuration class named `CashCardStream` in the `stream` package, with a `Supplier` method that accepts the `DataSourceService`:

   ```editor:append-lines-to-file
   file: ~/exercises/src/main/java/example/cashcard/stream/CashCardStream.java
   description: "Generate the empty CashCardStream class"
   ```

   ```java
   package example.cashcard.stream;

   import example.cashcard.domain.Transaction;
   import example.cashcard.service.DataSourceService;
   import java.util.function.Supplier;
   import org.springframework.context.annotation.Bean;
   import org.springframework.context.annotation.Configuration;

   @Configuration
   public class CashCardStream {

     @Bean
     public Supplier<Transaction> approvalRequest(DataSourceService dataSource) {
       return null;
     }
   }

   ```

   As you can see, our new `Supplier` method returns `null`, which won't do us any good. We need to have it use the `dataSource` to... you guessed it, source data!

1. Utilize the `dataSource`.

   Update the `Supplier` method to fetch data from the `dataSource`:

   ```java
   @Configuration
   public class CashCardStream {

     @Bean
     public Supplier<Transaction> approvalRequest(DataSourceService dataSource) {
       // add this function call
       return () -> {
         return dataSource.getData();
       };
     }
   }

   ```

   Here, we wrote a lambda function that invokes `dataSource.getData()`.

   Review that method in `DataSourceService` if needed. It's our method that generates random cash card data.

   ```editor:select-matching-text
   file: ~/exercises/src/main/java/example/cashcard/service/DataSourceService.java
   text: "getData"
   description: "Review DataSourceService.getData"
   ```

   Next, we need a bean that supplies the `DataSourceService`.

1. Create the `DataSourceService` bean.

   Finally, add a bean method to supply the `DataSourceService` to the `Supplier` method.

   ```editor:select-matching-text
   file: ~/exercises/src/main/java/example/cashcard/stream/CashCardStream.java
   text: "public class CashCardStream"
   description: "Update CashCardStream"
   ```

   ```java
   @Configuration
   public class CashCardStream {

     @Bean
     public Supplier<Transaction> approvalRequest(DataSourceService dataSource) {
       return () -> {
         return dataSource.getData();
       };
     }

     // Add this bean
     @Bean
     public DataSourceService dataSourceService() {
       return new DataSourceService();
     }
   }

   ```

   Now that the `DataSourceService` bean is configured, it is available for Spring to inject into the `approvalRequest` method.

## Review

As you can see, our configuration class has two methods of interest:

- One Spring bean method that returns a `Supplier<Transaction>`.
- One Spring bean method that returns the data source service, which the `Supplier` bean autowires in its argument list.

Here's what will happen at runtime:

1. Since the `CashCardStream` class is a Spring Configuration class, our Spring Boot application will automatically invoke it and make it available in our Spring Boot application.
1. While our Spring Boot application is running, Spring Cloud Stream will automatically invoke the `Supplier` method on a set schedule, which by default is is every one (1) second.
1. When the `Supplier` method is called, all it does is call the `dataSouce`'s `getData()` method.
1. The data fetched by the `Supplier` method will automatically **produce** it to an external source, such as a Kafka channel for other subscribers to access. This will be the _output_ binding we learned about in a previous lesson.

That's it!

We just wrote our first Spring Cloud Stream **Source** application that queries a data source and can produce that to an external destination.

To make all that happen, no more code is needed!