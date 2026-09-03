+++
title="Overview"
+++

One of the main benefits of Spring Cloud Stream is that it is a middleware-neutral framework, and it is agnostic to any middleware-specific details.

As explained in the lesson about _binders_, binders shield the Spring Cloud Stream core from any specific middleware technology details. This provides an important benefit of writing the core business abstractions in an application without worrying about the target middleware.

For example, we can take our application, change only one dependency, and run it against a different middleware without making any application code changes. That's pretty amazing!

As long as an application his not utilized vendor-specific features, the same application that works against Apache Kafka can also against running RabbitMQ, Apache Pulsar, and other messaging middleware. This is consistent with Spring's design philosophy of making your applications as portable as possible without the developer getting bogged down with infrastructure concerts.

Let's see these bold claims in action by switching our application from using Kafka to running against RabbitMQ, a popular messaging middleware based on the AMQP protocol.

## See the Running Middlewares

Before we move on, switch to the **Terminal** tab and confirm that we are running both Kafka and RabbitMQ as backing middleware n Docker containers.

We can see what is running by executing `docker ps`, with a little formatting to make the output more readable:

```dashboard:open-dashboard
name: Terminal
```

```shell
[~/exercises] $ docker ps --format 'table {{.Names}}\t{{.ID}}\t{{.Image}}\t{{.Status}}'
NAMES      CONTAINER ID   IMAGE                 STATUS
kafka      fde1261e8eab   apache/kafka:latest   Up 8 minutes
rabbitmq   27bce655e84d   rabbitmq:management   Up 8 minutes
```

As you can see, both Kafka and RabbitMQ are running via Docker.
