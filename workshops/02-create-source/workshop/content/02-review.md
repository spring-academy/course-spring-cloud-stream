+++
title="Review the Project"
+++

In our first lab, we bootstrapped a simple Spring Cloud Stream application by creating the basics from Spring Initializr.

In this lab, we are going to build on top of that baseline. Our goal is to develop a **Source** application.

## Review the Baseline

Let us reopen the same project that we bootstrapped in first lab:

```editor:open-file
file: ~/exercises/src/main/java/example/cashcard/CashCardApplication.java
description: "Review the CashCardApplication"
```

Also review our build dependencies in the `build.gradle` file:

```editor:select-matching-text
file: ~/exercises/build.gradle
text: "dependencies"
after: 7
description: "Look at the build.gradle dependencies"
```

```groovy
dependencies {
  implementation 'org.springframework.cloud:spring-cloud-stream'
  implementation 'org.springframework.cloud:spring-cloud-stream-binder-kafka'
  implementation 'org.springframework.kafka:spring-kafka'
  testImplementation 'org.springframework.boot:spring-boot-starter-test'
  testImplementation 'org.springframework.cloud:spring-cloud-stream-test-binder'
  testImplementation 'org.springframework.kafka:spring-kafka-test'
}
```

Note the following Spring Cloud Stream dependencies in particular:

- `org.springframework.cloud:spring-cloud-stream`: The core dependency for Spring Cloud Stream.
- `org.springframework.cloud:spring-cloud-stream-binder-kafka`: The Kafka binder dependency spring-cloud-stream-binder-kafka, which uses the `spring-kafka` module.
- `org.springframework.cloud:spring-cloud-stream-test-binder`: The test binder that will enable testing of our Spring Cloud Stream applications.

Now that we are done with our review, let's start building our **Source** application!
