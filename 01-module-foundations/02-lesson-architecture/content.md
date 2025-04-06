As we briefly mentioned in the previous lesson, event-driven applications can be either _producers_ or _consumers_. Often, they're both – that is, _processor_ applications.

A great benefit of this architectural style is that they can be loosely coupled, not knowing about each other -- meaning, they do not have explicit configuration that maps one to the other. This follows the modern microservices architecture in which a single application follows the _single responsibility principle_, focussing on one core activity.

Commonly, microservice applications are web-based and communicate over a well-known protocol, such as HTTP. Conversely, _event-driven microservices_ communicate through a messaging middleware, known as the message broker.

## Loose Coupling through Message Brokers

Unlike a relational database or a similar system, messaging brokers are built to natively handle a high throughput influx of data in a low-latency manner. The inherent nature of these messaging systems makes them perfect candidates to be the conduit between different event-driven microservices.

### Messaging Systems

The popular messaging systems in event-driven systems are [RabbitMQ](https://www.rabbitmq.com/), [Apache Kafka](https://kafka.apache.org/), [Apache Pulsar](https://pulsar.apache.org/), and others.

The prominent public cloud providers offer their own version of messaging brokers for use in their respective cloud platforms. For example, AWS provides a messaging system known as [Kinesis](https://aws.amazon.com/kinesis/), Google Cloud provides [Google PubSub](https://cloud.google.com/pubsub), while Azure provides [Event Hubs](https://azure.microsoft.com/en-us/products/event-hubs).

How exactly do these messaging systems play a role in event-driven applications? To answer this question, consider the following diagram:

![Single Producer-Consumer Architecture](https://raw.githubusercontent.com/spring-academy/spring-academy-assets/main/courses/course-spring-cloud-stream/producer-consumer.svg)

Although the diagram above looks simple, it nonetheless conveys a powerful idea: _loose coupling_.

### Loose Coupling

In a _loosely coupled_ event-driven system, the producer application _publishes_ to a message broker, while the consumer application _consumes_ from the same message broker. The producer application knows nothing about the consumer application and vice versa, and they both operate in an asynchronous manner. They communicate only through the messaging broker.

This sort of architecture gives immense power to applications when it comes to scaling. Look at the following version of the same diagram above:

![Multiple Producer-Consumer Architecture](https://raw.githubusercontent.com/spring-academy/spring-academy-assets/main/courses/course-spring-cloud-stream/producer-consumer-multiple.svg)

In this version, we are scaling the single producer application we saw earlier to multiple running instances, all publishing the events to the same destination on the message broker. Similarly, on the consumer side, the events are delivered to different consumers instead of one.

In a properly designed event-driven system, scaling like this does not require any application level code changes, only configuration or operational changes. These applications might also scale up or down automatically based on the needs of the system.

### Fault Tolerance

Most modern messaging brokers are built with fault tolerance as part of their design. For example, when producing a message, it gives the opportunity for the application to ensure that the publishing succeeds, by sending an acknowledgment back. Likewise, on the consumer side, after the processing of an event occurs, it informs the messaging system that it has completed processing the event by sending an acknowledgment. Event-driven applications benefit from relying on this fundamental and many other fault-tolerant features provided by the messaging systems.

## Real-Time and Streaming Data

[Martin Kleppmann](https://martin.kleppmann.com/) famously put it in perspective in his book "Designing Data-Intensive Applications": Data at rest is _batch processing_, data in motion is _stream processing_.

In our discussion of event-driven systems, we're talking about _data in motion_.

Think about the traffic app, or the video/audio streaming apps that we briefly described in the previous lesson. Data is constantly flowing in these systems, and the event-driven microservices need to process the information in near real-time, almost giving you the illusion that the events are occurring precisely on a real-time basis.

### Stream Processing

Depending on the use case of the application, if the data arrives a few seconds or a few minutes late, it's useless.

When event-driven applications process data in near real-time like this on a constant basis, and optionally produce an output, these applications belong to yet another class of applications known as _stream-processing_ or _streaming data_ applications.

Thus, stream-processing is a subdomain of event-driven systems, because a stream-processing application always acts upon a consumed event and then processes and optionally produces an output event.

### Stream Processing Libraries

While many even-driven applications are simple enough to write without the need of specialized libraries, there are situations when it is necessary to rely on advanced abstractions when designing complex stream processing applications.

Stateful stream processing systems are common, where an application is tasked with keeping track of the state of the system based on some previous metrics. For example, imagine a system that needs to aggregate sales data from a store on a rolling five-minute window.

For these types of use cases, usually developers rely on advanced libraries.

There are specialized libraries that are efficient at helping write stream-processing applications, such as the [Kafka Streams](https://kafka.apache.org/documentation/streams/) library exclusively used on Apache Kafka, [Apache Flink](https://flink.apache.org/), [Spark Streaming]()https://spark.apache.org/streaming/, and others.

## Challenges of Event-Driven Architecture

It's often very challenging to write event-driven systems that require high throughput and low latency requirements, primarily because of the innately distributed nature of their design.

### Common Misconceptions

In ["Fallacies of distributed computing"](https://nighthacks.com/jag/res/Fallacies.html), Peter Deutch famously devised eight common misconceptions about distributed computing. These principles are very much applicable to today's event-driven systems. These misconceptions are:

1. The network is reliable.
1. Latency is zero.
1. Bandwidth is infinite.
1. The network is secure.
1. The network topology doesn't change.
1. There is only one network system administrator.
1. The transport cost is zero.
1. The network is homogenous.

These distributed computing fallacies primarily deal with the networking-related aspects of distributed applications.

Since event-driven applications are microservices applications written in a distributed fashion, communicated over a network, these fallacies are essential to remember when writing event-driven microservices. Although the common touch point in an event-driven microservices ecosystem is the messaging broker, the communication happens over a network.

### The CAP Theorem: Consistency, Availability, Partitioning

Another factor that makes the development of event-driven systems difficult is the principles laid out in the _Consistency_, _Availability_, _Partitioning_ theorem, better known as the **CAP theorem**:

1. Consistency (C) - The reads receive the most recent write of the data, thus giving consistency.
1. Availability (A) - All the nodes in a system can read and write, even when there is a network failure
1. Partitioning (P) - Partitioning means a network partitioning or failure between members. In other words, the failure of one of more nodes or connections within a network.

All we need to do is solve for all of these issues. No problem, right?

### CAP: Pick Two of Three

In 1998, [Eric Brewer](https://people.eecs.berkeley.edu/~brewer/) of the University of California Berkeley laid out his famous CAP theorem, which states that no distributed stores (such as the messaging brokers we discussed above) can provide consistency, availability, and (network) partitioning all at the same time. He correctly argued that such systems can only provide, at the most, _two_ of these three guarantees _simultaneously._

It's up to each messaging broker to determine how it wants to pick and choose these guarantees. Some brokers provide **CA** (Consistency and High Availability), while others provide **AP** (High Availability and Partitioning).

When a system provides a **CA** guarantee, it usually provides consistency by using replication strategies on the broker nodes and making them available for data reads and writes. If a system provides an **AP** guarantee, it provides high availability on the nodes and the ability to serve them - even when a network failure occurs due to a network partition.

The CAP theorem is complex, and we don't need to understand all the details of it for this course. Nonetheless, understanding what CAP guarantees to a messaging system is often helpful in writing efficient event-driven systems.
