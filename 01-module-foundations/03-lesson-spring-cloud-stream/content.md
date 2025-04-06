As we saw in a preceding lesson, the components and algorithms used in an event-driven system are fairly complex. But, the good news is that messaging systems, such as the brokers, already handle many of these complexities.

## Abstractions and Frameworks

The messaging brokers we mentioned before already consider the fallacies of distributed computing, and they provide guarantees, as allowed by the CAP theorem. These advantages are provided as part of the message broker, and these brokers provide client APIs to interact with them to write event-driven and stream-processing applications.

Often, it's pretty low level to work with the messaging systems directly, and there's a need for frameworks that can abstract away all these complexities, in a developer-friendly way.

Take Apache Kafka, for example:

- Kafka has the low-level Kafka wire protocol that the broker understands so we don't have to.
- Apache Kafka also provides language-specific client libraries, such as the Java client.

However, this is still low-level and complex.

Because of this, there are frameworks such as [Spring for Apache Kafka](https://spring.io/projects/spring-kafka), which makes it easy for Spring-centric developers to write applications against Apache Kafka.

Similar developer-friendly frameworks exist for other message brokers - such as Spring for AMQP (RabbitMQ), and Spring for Apache Pulsar.

### Framework Lock-in Risk

As you can see, application developers need to learn and understand one or more of these libraries to write event-driven applications for the relevant platforms.

If an event-driven platform uses Apache Kafka, it can use Spring for Apache Kafka. Similarly, if an event-driven system is built on top of RabbitMQ, it can use Spring for AMQP. Systems written this way are not very portable, as developers need to rewrite and re-compile the codebase for new messaging platforms.

It would be very convenient if application developers could write event-driven microservices by abstracting away the underlying low-level message broker-specific concerns, and only focus on the application's business logic itself.

Does such a high-level abstraction exist within the Spring ecosystem?

Yes it does!

### Spring Cloud Stream to the Rescue!

Here is where the main focus of this course comes into play: enter **Spring Cloud Stream**, which provides all the abstractions needed so that the developers can focus on the needs of the application, not low-level framework code.

## Overview of Spring Cloud Stream

At the very outset, the goal of the Spring Cloud Stream framework is to abstract the low-level messaging details of each messaging broker platform. It achieves this by providing a consistent programming model, regardless of an enterprise's messaging platform!

For example, the same Spring Cloud Stream standard applications that work with Apache Kafka also work with other messaging platforms, such as RabbitMQ or Apache Pulsar. We will see how Spring Cloud Stream accomplishes this in the upcoming sections of this course.

### Benefits

The main benefit of Spring Cloud Stream is that the event-driven application developer can primarily focus on the business needs of the application, while the framework is responsible for all the communication and coordination activities with the message broker.

The high-level benefits of using the Spring Cloud Stream framework include the following:

- The Framework is built specifically for writing event-driven applications using the microservices pattern.
- Allows loose coupling between various microservices.
- Supports producer, consumer, and processor type applications.
- Handles all the low-level messaging broker communication on behalf of the application.

Spring Cloud Stream is a Spring Boot-based framework in the family of Spring Cloud projects. The framework follows the release cadence of the umbrella Spring Cloud portfolio of projects.

Because this is a Spring Boot-based project, a Spring Cloud Stream application brings all the benefits of Spring Boot!

### Spring Cloud Stream Systems

When using Spring Cloud Stream, the event-driven systems look like this:

![Simple Producer-Consumer Architecture](https://raw.githubusercontent.com/spring-academy/spring-academy-assets/main/courses/course-spring-cloud-stream/message-broker-stack.svg)

This looks almost identical to the previous diagrams we looked at. The main difference is that message broker communication responsibilities have moved to Spring Cloud Stream in both producer and consumer applications.

If you are familiar with creating and writing a Spring Boot application, doing the same with Spring Cloud Stream will certainly feel at home. You're just adding two additional dependencies your Boot application, which are:

1. Spring Cloud Stream core module - `spring-cloud-stream`
2. A broker-specific binder for Spring Cloud Stream - such as `spring-cloud-stream-binder-rabbit` or `spring-cloud-stream-kafka`.

Don't worry about what a binder in Spring Cloud Stream is at this point. All we need to know at the moment is that a binder is a component in Spring Cloud Stream that helps us to connect to a messaging system for real-world applications.