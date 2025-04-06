+++
title="Overview"
+++

As you have experienced in previous labs, we are a little obsessed with testing.

Thus far, we have written individual tests for our three types of Spring Cloud Stream applications, in their own modules. While our **_unit tests_** give us confidence in that these individual Spring Cloud Stream components perform as intended, we have been relying on manually spinning up the entire system in multiple **Terminal** panes, then monitoring the behavior with our own eyes.

This is fun! But, you have more important things to do than to stare at console panes and `.CSV` files. Computers, on the other hand, never tire of such activities. Let's put them to work.

## End-to-End Integration Tests

Unit test are critical for guarding against regressions and verifying the functionality of individual components. That said, they do not verify that the entire system works as a whole. For this reason, we highly recommended **_end-to-end integration tests (e2e tests)_** as well.

With end-to-end integration tests, we automate the setup and running of a whole system, and author automated tests that verify the entire system's functionality.

We will use a new testing-focused module that incorporates the individual **Source**, **Processor** and **Sink** components and test them as a system, with data flowing through it.

![Our Spring Cloud Stream System](/workshop/content/assets/system-with-sink.svg)

## Multiple Sources, Multiple E2E Tests

As you are well aware, we've designed our system to have two means of trigging data: a fixed-schedule **Source**, and an on-demand **Source** using a REST API and the `SpringBridge` interface. Two means of invoking our Spring Cloud Stream system means we need two end-to-end tests:

1. A _Streaming_ end to end test for cash card transactions generated on a fixed schedule:

   Stream/Fixed-Schedule **Source** ➡️ Enricher **Processor** ➡️ File **Sink**.

2. An _On Demand_ end to end test for cash card transactions submitted via HTTP `POST` to our REST controller:

   On-Demand **Source** ➡️ Enricher **Processor** ➡️ File **Sink**.

![Full System with Multiple Sources](/workshop/content/assets/full-system-with-sources.svg)

## Using a Real Kafka Middleware

We are building our Spring Cloud Stream applications using Apache Kafka middleware, so using Kafka we will ensure that our system works end-to-end as expected.

We will initially use the Embedded Kafka that we can use directly in the test. Once we verify this, we will also see how real Kafka brokers can be used in these types of testing scenarios by using the [Testcontainers Kafka](https://java.testcontainers.org/modules/kafka/) support.
