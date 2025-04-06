+++
title="Switch to RabbitMQ Dependencies"
+++

Now that we have proven that Kafka is no longer running, let's make the incredibly simple change to switch to RabbitMQ as the backing middleware for our Spring Cloud Stream application.

1. Add the RabbitMQ dependency.

   Update `build.gradle` to add the Spring Cloud Stream RabbitMQ dependency:

   ```editor:select-matching-text
   file: ~/exercises/build.gradle
   text: "dependencies"
   after: 7
   description: Add the RabbitMQ dependency.
   ```

   ```groovy
   implementation 'org.springframework.cloud:spring-cloud-stream-binder-rabbit'
   ```

1. Remove the Kafka dependencies.

   Next, remove or comment-out the Kafka-related dependencies:

   ```groovy
   dependencies {
   	implementation 'org.springframework.cloud:spring-cloud-stream-binder-rabbit'
   	implementation 'org.springframework.cloud:spring-cloud-stream'
   	// implementation 'org.springframework.cloud:spring-cloud-stream-binder-kafka'
   	// implementation 'org.springframework.kafka:spring-kafka'
   	testImplementation 'org.springframework.boot:spring-boot-starter-test'
   	testImplementation 'org.springframework.cloud:spring-cloud-stream-test-binder'
   	// testImplementation 'org.springframework.kafka:spring-kafka-test'
   }
   ```

   Did we break anything? Let's run the tests an find out.

1. Run the tests.

   Switch to the **Terminal** tab and run the tests:

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   [~/exercises] $ ./gradlew test
   ...
   BUILD SUCCESSFUL in 4s
   4 actionable tasks: 3 executed, 1 up-to-date
   ```

   The tests still pass!

   The same test binder we configured works just as well with RabbitMQ dependencies as with Kafka (and other) middleware dependencies.


That's it! With those simple changes you have updated our Spring Cloud Stream project from using Kafka to RabbitMQ.

But does it really work? Let's find out.
