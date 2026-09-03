+++
title="Run the Application"
+++

In the first lab, we added the Kafka binder to our application. We will need Kafka running in order for our Spring Cloud Stream application to work.

Guess what? _We're running Kafka now_ in this interactive lab environment using docker!

Go ahead, take a look and see that it is running by executing the `docker ps` command in the **Terminal**:

```dashboard:open-dashboard
name: Terminal
```

```shell
[~/exercises] $ docker ps
CONTAINER ID   IMAGE                 COMMAND                  CREATED          STATUS          PORTS                                       NAMES
0034eb13e35b   apache/kafka:latest   "/__cacert_entrypoin…"   15 minutes ago   Up 15 minutes   0.0.0.0:9092->9092/tcp, :::9092->9092/tcp   kafka
```

We won't get into the details of installing and running Kafka in this lab. Let's take advantage that it's already running and we can use it.

1. Run the application.

   Let's run the application with the Kafka binder as a dependency.

   In one of the unused **Terminal** panes, run the application using `bootRun`:

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   [~/exercises] $ ./gradlew bootRun
   ...
   20XX-XX-XXTXX:XX:XX.XXXZ  INFO 2627 --- [CashCard] [           main] o.a.kafka.common.utils.AppInfoParser     : Kafka version: 3.6.2
   20XX-XX-XXTXX:XX:XX.XXXZ  INFO 2627 --- [CashCard] [           main] o.a.kafka.common.utils.AppInfoParser     : Kafka commitId: c4deed513057c94e
   20XX-XX-XXTXX:XX:XX.XXXZ  INFO 2627 --- [CashCard] [           main] o.a.kafka.common.utils.AppInfoParser     : Kafka startTimeMs: 1715638156031
   20XX-XX-XXTXX:XX:XX.XXXZ  INFO 2627 --- [CashCard] [ad | producer-1] org.apache.kafka.clients.Metadata        : [Producer clientId=producer-1] Cluster ID: Some(5L6g3nShT-eMCtK--X86sw)
   20XX-XX-XXTXX:XX:XX.XXXZ  INFO 2627 --- [CashCard] [           main] o.s.c.s.m.DirectWithAttributesChannel    : Channel 'CashCard.approvalRequest-out-0' has 1 subscriber(s).
   20XX-XX-XXTXX:XX:XX.XXXZ  INFO 2627 --- [CashCard] [           main] o.s.i.e.SourcePollingChannelAdapter      : started bean 'approvalRequest-out-0_spca'
   20XX-XX-XXTXX:XX:XX.XXXZ  INFO 2627 --- [CashCard] [           main] example.cashcard.CashCardApplication     : Started CashCardApplication in 1.624 seconds (process running for 1.812)
   <==========---<==========---> 80% EXECUTING [59s]
   > :bootRun
   ```

   When you start this application, you will see a lot of information printed on the console. This is expected.

   The application is running, meaning the `Supplier` is producing transaction output every one (1) second by default.

   But is it really? We're not actually seeing any activity. Let's use Apache Kafka to verify that data is being sent to the _output_ binding.

1. Use Kafka to verify.

   But wait, which topic in Kafka should we monitor?

   We explained before that when we don't specify a destination, the binding name becomes the destination, so in this case, Spring Cloud Stream must have created a new topic in Kafka called **`approvalRequest-out-0`**.

   While the **Source** app is still up and running, use the unused **Terminal** pane and connect to Kafka using the following command:

   ```shell
   [~/exercises] $ docker exec -it kafka /opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic approvalRequest-out-0
   ...
   {"id":-66561165137247368,"cashCard":{"id":6094323678418692169,"owner":"sarah1","amountRequestedForAuth":50.7668781314909}}
   {"id":-5634650775918976902,"cashCard":{"id":3090043269501770643,"owner":"sarah1","amountRequestedForAuth":63.79583001467617}}
   {"id":-14741824561737749,"cashCard":{"id":-4335146560811993412,"owner":"sarah1","amountRequestedForAuth":12.783311898916805}}
   {"id":5558799879234294766,"cashCard":{"id":-4613724913650180843,"owner":"sarah1","amountRequestedForAuth":58.932051104126955}}
   {"id":6868476944436589763,"cashCard":{"id":8526417364307544245,"owner":"sarah1","amountRequestedForAuth":46.38569473593444}}
   ...
   ```

   It works!

   You should see that the application is producing transactions to Kafka every one (1) second.

   Let's play around a bit more and configure the application.

1. Change the production rate.

   Just for fun, let's produce data to the _output_ topic every 5 seconds instead of every one (1) second.

   First, stop the running application by typing `CTL-C` in `./gradlew bootRun` **Terminal** pane. You can keep the `docker` command connected to Kafka running.

   ```shell
   <==========---> 80% EXECUTING [15m 51s]
   > :bootRun
   ^C[~/exercises] $
   ```

   Note that when you stop the application, no additional output appears in the Kafka terminal.

   Next, Re-run the application as below, specifying a `fixed-delay` of `5000` milliseconds (5 seconds), which overrides the default delay:

   ```shell
   [~/exercises] $ ./gradlew bootRun --args="--spring.integration.poller.fixed-delay=5000"
   ```

   In the Kafka pane, you should see transactions printed out every 5 seconds now!

Good job! We're done for now.

Please stop the application and docker console sessions by typing `CTL-C` in their panes.
