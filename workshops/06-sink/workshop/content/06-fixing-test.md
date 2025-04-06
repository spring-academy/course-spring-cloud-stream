+++
title="Fixing the Tests"
+++

We have discovered that our **Sink** application is failing to run. This is because we have _multiple bindings_ available and Spring Cloud Stream cannot figure out which bindings to load by default:

> Multiple functional beans were found [cashCardTransactionFileSink, sinkToConsole], thus can't determine default function definition.

Our tests also load Spring Boot and Spring Cloud Stream. Do they have the same problem?

Let's find out.

1. Run the tests.

   Even though we only have our console sink test, and we have not changed the console sink code, let's run our tests and see if adding a the file-sink binding had an impact.

   **Tip:** pass in the `--info` parameter for more verbose test output.

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   [~/exercises] $ ./gradlew cashcard-transaction-sink:test --info
   ...
   20XX-XX-XXTXX:XX:XX.XXXZ  WARN 18020 --- [cashcard-enricher] [    Test worker] c.f.c.c.BeanFactoryAwareFunctionRegistry : Multiple functional beans were found [cashCardTransactionFileSink, sinkToConsole], thus can't determine default function definition. Please use 'spring.cloud.function.definition' property to explicitly define it.
   ...
   CashCardTransactionSinkTests > cashCardSinkToConsole(InputDestination, CapturedOutput) FAILED
       java.lang.NullPointerException: Cannot invoke "org.springframework.messaging.SubscribableChannel.send(org.springframework.messaging.Message)" because the return value of "org.springframework.cloud.stream.binder.test.InputDestination.getChannelByName(String)" is null
   ...
   BUILD FAILED in 3s
   ```

   Our test is failing!

   Notice that we see the same `WARN` message as when running the application, and our test is failing because the `InputDestination` is `null`.

1. Specify the input property.

   At the moment Spring Cloud Stream cannot configure a default binding because we have two bindings: `sinkToConsole` and `cashCardTransactionFileSink`. We need to tell Spring Cloud Stream to enable _both bindings_.

   We can accomplish this goal by specifying a specific parameter: `spring.cloud.function.definition` and listing the bindings we want active: `sinkToConsole;cashCardTransactionFileSink`.

   When there is only a single function, we do not need to provide this property since Spring Cloud Stream will assume that this is the function to activate.

   Update the test to specify that both bindings are active:

   ```editor:select-matching-text
   file: ~/exercises/cashcard-transaction-sink/src/test/java/example/cashcard/sink/CashCardTransactionSinkTests.java
   text: "@SpringBootTest"
   description: "Add properties to @SpringBootTest"
   ```

   ```java
   // Add properties to the @SpringBootTest annotation
   @SpringBootTest(properties = "spring.cloud.function.definition=sinkToConsole;cashCardTransactionFileSink")
   @Import(TestChannelBinderConfiguration.class)
   @ExtendWith(OutputCaptureExtension.class)
   class CashCardTransactionSinkTests {
      ...
   }
   ```

   This should enable both bindings, including the `sinkToConsole` which was failing.

   Let's see if our console test is working again.

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   [~/exercises] $ ./gradlew cashcard-transaction-sink:test
   ...
   BUILD SUCCESSFUL in 16s
   6 actionable tasks: 6 executed
   ```

   The tests are passing again!

Let's write our file sink test now.
