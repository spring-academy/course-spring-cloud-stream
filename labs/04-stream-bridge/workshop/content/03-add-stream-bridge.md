+++
title="Add the StreamBridge"
+++

We are now ready to use Spring Cloud Stream's "bridging" feature to enable on-demand processing.

Open the `CashCardStream` class and review the `Supplier` Java function.

```editor:select-matching-text
file: ~/exercises/src/main/java/example/cashcard/stream/CashCardStream.java
text: "public Supplier<Transaction> approvalRequest(DataSourceService dataSource)"
description: "Review the CashCardStream class"
```

```java
@Configuration
public class CashCardStream {

    @Bean
    public Supplier<Transaction> approvalRequest(DataSourceService dataSource) {
        return () -> {
            return dataSource.getData();
        };
    }

    @Bean
    public DataSourceService dataSourceFacade() {
            return new DataSourceService();
    }
}
```

We are going to add another API method in the `CashCardStream` class to publish data on-demand for clients of `CashCardStream`.

1. Inject the `StreamBridge`.

   Since `StreamBridge` is the key to our on-demand needs, let's inject it into our configuration.

   Add the `StreamBridge` local variable, and add a constructor that take the `StreamBridge` as an argument, which will be injected by Spring:

   ```java
   @Configuration
   public class CashCardStream {

       private final StreamBridge streamBridge;

       public CashCardStream(StreamBridge streamBridge) {
           this.streamBridge = streamBridge;
       }
     ...
   }
   ```

   Be sure to add the new `import` statement for the `StreamBridge`:

   ```java
   import org.springframework.cloud.stream.function.StreamBridge;
   ```

1. Add an on-demand publishing method to the configuration.

   Now we need a method that grants access to the `StreamBridge`.

   Let's add the following method in the class:

   ```java
   public void publishOnDemand(Transaction transaction) {
       this.streamBridge.send("approvalRequest-out-0", transaction);
   }
   ```

   As you can see, the implementation calls the `send` method on the `StreamBridge`:

   - The first parameter is the binding name. As you may have noticed from previous labs, the binding is the same as the one we used before: `approvalRequest-out-0`. Therefore, both the supplier and the `StreamBridge` will publish to the same middleware destination represented by this binding.
   - The second parameter is the transaction that needs to be published.

Any clients that inject the `CashCardStream` bean can call this new stream method and provide the transaction, which will be published to a middleware destination.

## Learning Moment: Where's the Bean?

It is common to configure injectable dependencies as a bean using the `@Bean` annotation, as we have done here in the `CashCardStream` configuration class and elsewhere in our Spring application.

Why didn't we configure the `StreamBridge` dependency as a bean as well? For example we **_*did not*_** write anything like the following:

```java
// We DID NOT write anything like this:
@Bean
public StreamBridge streamBridge() {
  // return a StreamBridge instance
}
```

Answer: `StreamBridge` is _automatically_ configured as a bean by the Spring Cloud Stream framework! Applications are expected to inject the fully configured bean directly, which is what we have done here.

Now that we have made a `StreamBridge` available in our application, let's put it to use in our on-demand `POST` endpoint.
