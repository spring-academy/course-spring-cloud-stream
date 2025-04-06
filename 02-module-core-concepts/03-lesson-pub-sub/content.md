Publish and subscribe, widely known as _pub/sub_, is a popular design pattern in event-driven systems. As the name suggests, the pattern helps with the development of applications that are capable of publishing and consuming from a subscription.

This pattern is helpful because introducing a messaging middleware between the publishing and consuming sides allows the producer and consuming applications to be completely decoupled. One side does not even need to know the other side's existence.

![Pub-Sub](https://raw.githubusercontent.com/spring-academy/spring-academy-assets/main/courses/course-spring-cloud-stream/pub-sub.svg)

The publisher does not have to wait for any subscribers for this pattern. All it cares about is publishing data. Similarly, consumers only know how to subscribe to data and nothing about producing it. Each component in the pub/sub model settles down to its single responsibility.

Spring Cloud Stream is a perfect framework for implementing the pub/sub model because of its core reliance on the binding API, particularly the producer and consumer binding model it exposes.

Spring Cloud Stream applications are either producers, consumers, or both. When an application produces and consumes, it receives and sends data. Although that sounds like going away from the decoupling aspects, Spring Cloud Stream still isolates itself under the hood through the consumer and producer bindings. When using the pub/sub model, Spring Cloud Stream allows the user to decide how the design is implemented. It can be a single publisher, subscriber, or both.
