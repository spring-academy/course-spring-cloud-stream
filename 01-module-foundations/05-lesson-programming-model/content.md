Now that we understand the basic concepts behind event-driven systems and how Spring Cloud Stream is a good fit for writing event-driven applications, discuss its application programming model.

Although there are many nuances, a Spring Cloud Stream application performs 4 primary functions:

- Publish or generate data to a messaging middleware on a _fixed schedule_.
- Publish or generate data into a messaging middleware _on-demand_.
- Receive data from a messaging middleware.
- Receive data from a middleware, process it, then publish the processed data to a middleware destination.

Let's now look at the details of these four categories and how concretely they are made.

## Publisher Application

A publisher application constantly publishes data into a destination on the middleware.

In Spring Cloud Stream, an application can provide a `Supplier` bean, and the framework behind the scenes calls this supplier based on a schedule, which publishes data into the middleware.

Here is an example of a `Supplier` bean:

```java
@Bean
public Supplier<String> supply() {
  return () -> dataService.getLatestData();
}

```

The `Supplier` is implemented as a Java 8 lambda expression. The application simply includes this bean method in the Spring Boot application. If Spring Cloud Stream is on the classpath, the framework detects this `Supplier` bean and starts triggering it on behalf of the application.

## On-Demand Publisher with StreamBridge

The publishing programming model described above is for publishing data on a schedule. For example, when you have data that is produced on a constant basis, then using a `Supplier` is a natural choice.

However, we might have situations where we want to control how and when to publish data. Imagine that a system exposes a REST endpoint where clients can `POST` data that needs to be published immediately.

In these situations, Spring Cloud Stream provides an API called `StreamOperations`, with a standard implementation `StreamBridge`, which allows one to send data to a middleware destination on demand.

Here is an example of how a `StreamBridge` might be configured:

```java
@Configuration
public class OnDemandPublisher {
  private final StreamBridge streamBridge;
  ...
  // Called on-demand by a controller, service, or similar.
  public void publishOnDemand(Transaction transaction) {
    this.streamBridge.send("someBinding-out-0", transaction);
  }
}
```

Notice that the example `publishOnDemand` method above is _not_ a bean -- it's just a public method, configured with a `StreamBridge`, ready to be invoked as needed when data needs to be published.

## Processor Application

A processor application is both a publisher _and_ a subscriber. It subscribes to a destination and consumes data, then does some processing on that data, and finally publishes the data to another destination.

This model perfectly matches with the `java.util.function.Function` API where it takes an input and then produces an output. Here is a blueprint for this:

```java
@Bean
public Function<String, String> process() {
  return input -> service.doSomethingWithTheData(input);
}

```

Here again, the business logic is implemented as a lambda expression.

## Sink Application

A sink application is a consumer-only application subscribing to an input destination. Once again, there is a corresponding API for this type of application in the `java.util.function` package called `Consumer`. Here is how it looks:

```
@Bean
public Consumer<String> consume() {
    return data -> service.sendToMySink(data);
}
```

Notice that this is implemented as yet another lambda expression. Let's learn more about how lambdas are used in Spring Cloud Stream.

## Lambdas and Functions

The application's business logic is encapsulated as a standard lambda expression in all these three implementations: `Supplier`, `Function`, and `Consumer`. The rest of the infrastructure-related concerns, such as calling these functions and binding them to the proper destination on the messaging middleware, are all handled by the Spring Cloud Stream framework.

This programming model exposed by Spring Cloud Stream is enabled by another framework in the Spring Cloud ecosystem: [Spring Cloud Function](https://spring.io/projects/spring-cloud-function). Spring Cloud Function can detect the functions from the application, catalog them in a registry, and invoke the functions on behalf of the application. Spring Cloud Stream automatically includes Spring Cloud Function in its dependencies to enable this particular functional style of the programming model.

Don't worry if these concepts sound abstract at the moment. You will become much more familiar with them as we implement our Spring Cloud Stream application during the hands-on labs.
