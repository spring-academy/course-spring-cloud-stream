+++
title="Why are the tests failing?"
+++

Thus far in this course we rarely have dealt with test failures.

Here, we will need to address a real-world situation that commonly occurs as a side affect of changes such as the `StreamBridge` related updates we have made.

But first, let's investigate our test failures.

1. Find the failure.

   You likely see that there is a lot of test output in the **Terminal**, but it is not very useful.

   Let's run again passing in the `--info` flag to get more information about the test failure. Scroll through the output until you find the failure details, which will look something like this:

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   [~/exercises] $ ./gradlew test --info
   ... lots and lots of output ...
   CashCardControllerTests > cashCardStreamBridge(OutputDestination) FAILED
       org.opentest4j.AssertionFailedError:
       expected: 123L
       but was: -69970613332339299L
   ```

   Strange! Our test `POST`s a `Transaction` with ID of `123L`, which we configured in our test setup, but we're actually receiving a random value instead.

   ```editor:select-matching-text
   file: ~/exercises/src/test/java/example/cashcard/controller/CashCardControllerTests.java
   text: "new Transaction(123L,"
   description: "Review the test setup"
   ```

   Where have we seen these random values before?

   In `DataSourceService`, our fake data service!

   ```editor:select-matching-text
   file: ~/exercises/src/main/java/example/cashcard/service/DataSourceService.java
   text: "new Random().nextLong(), // Random ID"
   description: "Review DataSourceService"
   ```

1. Oh no.

   So, why are our tests failing?

   Our tests are failing because **_both_** Spring Cloud Stream processes we have implemented are publishing to the same binding: `approvaRequest-out-0`.

   That is, both our fixed-schedule processes defined in `CashCardStream.approvalRequest` **_and_** the process we trigger on-demand in `CashCardController.publishOnDemand` are publishing data at the same time. Or really, the fixed-schedule `CashCardStream.approvalRequest` is publishing first, and thus we area fetching it's `Transaction` in our controller test.

   While this is not necessarily "bad" in a running production situation, we currently have no control over our test setup, which is never a good thing, since we can not define a repeatable test scenario.

1. Understand the real problem.

   In reality, our test failures are a symptom of another more fundamental system design choice we have made: we have combined two configurations which should be independently defined. We have violated the [**_seperation of concerns_**](https://docs.spring.io/spring-integration/docs/4.3.20.RELEASE/reference/html/overview.html#overview-goalsandprinciples) principle.

   We have a few options here. First, we can disable the fixed-schedule binding in the controller test. However, that is a bit low-level for our learning at this point in this course.

   Therefore, let us try to exclude this test so that we will not activate the fixed-schedule supplier in the controller test by depending on the Spring Boot component scanning based on the package in which we run the test.

Let us refactor our codebase a bit to implement this new design.
