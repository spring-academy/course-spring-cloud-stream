+++
title="E2E Testing Support and Setup"
+++

Guess what? Another module!

## Our E2E Testing Module

You'll see that we have created a new module for us to begin our testing: `cashcard-transaction-e2e-tests`. It's mostly empty, and has the following interesting features to explore:

- It does not contain a Spring Boot application, only test-related components.
- All `build.gradle` dependencies are scoped to `testImplementation`.
- It pulls in all other project project modules.

Take a look at the dependencies again and notice all are scoped as a `testImplementation`

```editor:select-matching-text
file: ~/exercises/cashcard-transaction-e2e-tests/build.gradle
text: "dependencies"
after: 8
description: "E2E test module dependencies"
```

Also take a look at the scaffolding for the fixed-schedule and on-demand tests we've provided:

```editor:open-file
file: ~/exercises/cashcard-transaction-e2e-tests/src/test/java/example/cashcard/e2e/test/CashCardTransactionStreamE2ETests.java
description: "E2E tests"
```

## Using a Real Middleware

For our end-to-end tests, we are going to use a real Kafka broker in test-mode.

Thus far in our labs, we have used the test binder provided by Spring Cloud Stream so that we could quickly verify the bindings of each application. This is not a real middleware, such as Kafka or RabbitMQ - it just simulates a real middleware.

In order to test that our individual applications work gether as a true Spring Cloud Stream system, we needed to run a real Kafka broker for our integration tests.

The [Spring for Apache Kafka](https://spring.io/projects/spring-kafka) project, which the Spring Cloud Stream Kafka binder is built upon, provides an embedded-kafka broker (`@EmbeddedKafka`) for integration testing Apache Kafka applications. It is available as part of the `spring-kafka-test` module.

By including this module in our application's test-scope dependencies we can easily test our business logic against a real embedded Kafka cluster.

Take a look at our project's `build.gradle` to see how we define this dependency:

```editor:select-matching-text
file: ~/exercises/cashcard-transaction-e2e-tests/build.gradle
text: "testImplementation 'org.springframework.kafka:spring-kafka-test'"
description: "Embedded Kafka support"
```

With that review, let's us write our first end-to-end test for our on-demand cash card transaction stream.
