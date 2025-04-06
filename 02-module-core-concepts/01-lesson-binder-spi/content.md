As we discussed in the _Foundations_ module, Spring Cloud Stream is a framework that helps you write event-driven applications using Spring-friendly abstractions familiar to Spring developers. In this lesson, we will take a deeper dive into the core concepts of Spring Cloud Stream.

Although there are several areas we can focus on when it comes to the core Spring Cloud Stream, we will limit our attention to just a few concepts. The two must-know concepts in Spring Cloud Stream are the **binder** and the **binding** APIs.

Let's start with the **binder**.

## The Binder

If you are new to Spring Cloud Stream, a natural question to ask is, "what is a **_binder?_**"

From the sound of it, it seems like a binder is something that can _connect_ or _bind_ things together. This intuition is correct! The binder allows you to bind or connect something from your application to an external component.

So what does a Spring Cloud Stream application need to connect to? The answer is a _messaging middleware_.

![Binders and Middleware](https://raw.githubusercontent.com/spring-academy/spring-academy-assets/main/courses/course-spring-cloud-stream/binders-and-middleware.svg)

It's the binder's job to manage the application-to-middleware communication. It does all the dirty work so the Spring Cloud Stream application developer doesn't have to.

## Binder Service Provided Interface

Spring Cloud Stream applications communicate via _input_ and _output_ bindings to messaging middleware. In fact, applications don't really know anything about the middleware, or even each other: they just send data out the _output_ and receive data in the _input_.

This interaction model is part of what's called the [Service Provider Interface](https://docs.spring.io/spring-cloud-stream/reference/spring-cloud-stream/overview-binder-api.html), or SPI. As long as a middleware binder implementation supports this interface, Spring Cloud Stream can interact with it.

SPIs don't grow on trees, though. Some part of our application framework needs to actually implement the concrete implementation specific to Kafka, RabbitMQ, or other middleware, and enable communication via the _input_ and _output_ bindings.

## Native Technology Awareness

A binder is the piece of software _natively aware of the inner workings_ of a particular technology. For Spring Cloud Stream, these native technologies are messaging middlewares such as Apache Kafka, RabbitMQ, and others.

To integrate with Kafka, a developer needs to add the [Spring Cloud Stream Kafka Binder](https://cloud.spring.io/spring-cloud-stream-binder-kafka/spring-cloud-stream-binder-kafka.html) dependency to their Spring Boot project. For RabbitMQ, the [Spring Cloud Stream RabbitMQ Binder](https://docs.spring.io/spring-cloud-stream-binder-rabbit/docs/current/reference/html/spring-cloud-stream-binder-rabbit.html). These implement the SPI we've been talking about.

And if there isn't a binder for your preferred messaging middleware, you can [implement your own custom binder](https://docs.spring.io/spring-cloud-stream/reference/spring-cloud-stream/overview-custom-binder-impl.html)!

## Swapping Middleware

The binder SPI architecture has immense benefits from the perspective of the application developer. Since the binder is an SPI, and implementations exist for various middleware technologies, an application can be written using Spring Cloud Stream in a middleware-agnostic manner. What does that mean?

Suppose an enterprise wants to use Apache Kafka as its messaging middleware. Developers can write their event-driven application using Spring Cloud Stream without really thinking about Kafka itself. The Kafka binder takes care of all the Kafka-specific details. Nice!

Now imagine the enterprise decides they want to switch to another messaging middleware, such as RabbitMQ or Apache Pulsar.

What needs to change within the Spring Cloud Stream applications? Almost nothing changes! Just replace the _binder dependency_ and you're good to go.

Since the binders implement the same SPI, the applications won't even know anything has changed. Application developers can focus on solving business and domain-specific problems, and not worry about how to adapt to some esoteric wire protocol.

But, there are always exceptions. Some applications might take advantage of vendor-specific features of a middleware, and in those cases the application developers might need to do some custom coding. You'll know if you're in this situation, because you likely got yourself into this situation.

And guess what? We'll prove it. Later in this course you will swap middlewares in a hands-on lab!
