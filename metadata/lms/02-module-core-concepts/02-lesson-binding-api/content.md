In the previous lesson you learned about the **_binder_** Service Provided Interface -- an SPI, implemented by software framework developers tasked with enabling Spring Cloud Stream to communicate with messaging middlewares. Application developers usually don't have to worry too much about this.

Now let's learn more about the **_binding_** feature in Spring Cloud Stream, which is an Application Programmer Interface -- an API. This is what you, the application programmer, will work with when developing an event-driven system with Spring Cloud Stream.

## What Does the Binder Bind?

We've answered the question, _"what is a binder?"_ Now let's answer the question, "_what exactly does the binder bind?_"

As mind-bending as it might sound, the _binder binds **bindings**_!

Let's unpack that.

## Binding Types

Spring Cloud Stream applications communicate via _input_ and _output_ bindings to messaging middleware. The binder establishes these for us, and applications don't really need to know anything about the middleware: they just send data out the _output_ and receive data in the _input_.

![Binders and Middleware](https://raw.githubusercontent.com/spring-academy/spring-academy-assets/main/courses/course-spring-cloud-stream/binders-and-middleware.svg)

Spring Cloud Stream has special names for how we work with these bindings within our Spring Cloud Stream system: Producer and Consumer bindings.

- **Producer bindings** correspond to the _output_ of an application.
- **Consumer bindings** provide the _input_ of an application.
- An application that has both an inputs and an outputs will have both producer and consumer bindings.

Binding types have a lot of overlap with the _Programming Model_ we learned about earlier. This makes since, since the model is our interface to Spring Cloud Stream -- our API.

## Producer Binding

The producer binding corresponds the _outputs_ of our event-driven system. Application developers work with the producer binding by writings `Supplier` beans:

```java
@Bean
public Supplier<String> supply() {
  return () -> dataProducingService.getLatestData();
}

```

Any data returned by the `Supplier` is eventually sent to the messaging middleware via the `output` binding by the binder.

## Consumer Binding

The situation is reversed for a consumer binding. The binder listens for messages from the middleware, and any data it receives from the middleware is placed on the _input_ channel by the binder.

Once the data is placed on the input message channel, it gets propagated to the application by Spring Cloud Stream.

Our APIs for the consumer binding are the `Consumer` and `Function` beans, both of which accept an input from the the _input_ binding:

```
@Bean
public Consumer<String> consume() {
    return s -> service.sendToMySink(s);
}
```

```java
@Bean
public Function<String, String> process() {
  return input -> service.doSomethingWithTheData(input);
}

```
