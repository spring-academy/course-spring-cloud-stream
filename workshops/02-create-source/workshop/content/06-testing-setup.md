+++
title="Testing our Supplier - Test Setup"
+++

When we bootstrapped the application, Spring Initializr also added the `spring-cloud-stream-test-binder` dependency, which provides an in-memory binder convenient for unit testing.

This test binder does not communicate with external middleware systems and is very lightweight for basic unit-level testing of Spring Cloud Stream components.

This is the dependency we added:

```editor:select-matching-text
file: ~/exercises/build.gradle
text: "testImplementation 'org.springframework.cloud:spring-cloud-stream-test-binder'"
description: "Review the test dependency"
```

```groovy
testImplementation 'org.springframework.cloud:spring-cloud-stream-test-binder'
```

We can use this test binder to ensure that the business logic in the `Supplier` component works as expected.

Let's create a new test!

1. Create the test `stream` package.

   Using either the **Terminal** or the **Editor**, create a new package for our `stream` tests in the `test` source: `example.cashcard.stream`.

   The directory will be `~/exercises/src/test/java/example/cashcard/stream`.

1. Create a test class with a `basicCashCardSupplier` test method.

   Create a new test class named `CashCardApplicationTests` in the test `stream` package:

   ```editor:append-lines-to-file
   file: ~/exercises/src/test/java/example/cashcard/stream/CashCardApplicationTests.java
   description: "Generate the empty test class"
   ```

   Next, fill in the basic scaffolding for the test:

   ```java
   package example.cashcard.stream;

   import org.junit.jupiter.api.Test;
   import org.springframework.boot.test.context.SpringBootTest;

   @SpringBootTest
   class CashCardApplicationTests {

     @Test
     void basicCashCardSupplier() {}
   }

   ```

   Currently the empty test we've written is not Spring Cloud Stream-aware.

   Let's fix that.

1. Activate the Spring Cloud Stream test binder.

   To activate the test binder, we need to import its configuration for the test.

   The test binder in Spring Cloud Stream provides two main components - `OutputDestination` and `InputDestination`. Since we are dealing with **Source** applications in this lab, we only need an `OutputDestination`.

   Below is the code for the test class after importing the test binder configuration and auto-wiring the `OutputDestination` component.

   Be sure to add the new `import` statements as well.

   ```java
   package example.cashcard.stream;

   import org.junit.jupiter.api.Test;
   import org.springframework.beans.factory.annotation.Autowired;
   import org.springframework.boot.test.context.SpringBootTest;
   import org.springframework.cloud.stream.binder.test.OutputDestination;
   import org.springframework.cloud.stream.binder.test.TestChannelBinderConfiguration;
   import org.springframework.context.annotation.Import;

   @SpringBootTest
   // Add this @Import statement
   @Import(TestChannelBinderConfiguration.class)
   class CashCardApplicationTests {

     // Autowire the OutputDestination
     @Test
     void basicCashCardSupplier(@Autowired OutputDestination outputDestination) {}
   }

   ```

   Pay attention to the statement `@Import(TestChannelBinderConfiguration.class)`, which imports the test binder's configuration. Without this line, Spring Cloud Stream's functionality would not be invoked as part of the test.

   To test our **Source** application we'll need to use our data source -- the `DataSourceService`. But, we have a problem: it generates random data, so we have no idea what data to expect in our test. We need to be able to control its random data so we can write a predictable, repeatable test.

   Let's do that now.

1. Inject a Mock `DataSourceService`.

   The Spring framework test dependencies include support for replacing beans with versions we can carefully configure when we write our tests -- "mock" beans. Learn more about `MockBean` [here.](https://docs.spring.io/spring-boot/docs/current/api/org/springframework/boot/test/mock/mockito/MockBean.html)

   Let's replace the `DataSourceService` available in our test with a "mock" that we can configure later:

   ```java
   package example.cashcard.stream;

   import java.io.IOException;

   import org.junit.jupiter.api.Test;
   import org.springframework.beans.factory.annotation.Autowired;
   import org.springframework.boot.test.context.SpringBootTest;
   import org.springframework.boot.test.mock.mockito.MockBean;
   import org.springframework.cloud.stream.binder.test.OutputDestination;
   import org.springframework.cloud.stream.binder.test.TestChannelBinderConfiguration;
   import org.springframework.context.annotation.Import;

   import example.cashcard.service.DataSourceService;

   @SpringBootTest
   @Import(TestChannelBinderConfiguration.class)
   class CashCardApplicationTests {

     // Autowire a mock bean for the DataSourceService
     @MockBean
     private DataSourceService dataSourceService;

     @Test
     void basicCashCardSupplier1(@Autowired OutputDestination outputDestination) throws IOException {
     }
   }
   ```

That was a lot of setup! The investment is about to pay off.

Next, let's write our testing logic.
