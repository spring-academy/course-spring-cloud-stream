+++
title="Review the Kafka Implementation"
+++

We've been using Kafka as our middleware for our Family Cash Card project.

Let's play around with it a bit to see how it reacts when we stop Kafka.

1. Adding logging to `DataSourceService`.

   Let's temporarily add extra logging to our fake data service to help us see the affect of our changes as we make them.

   ```editor:select-matching-text
   file: ~/exercises/src/main/java/example/cashcard/service/DataSourceService.java
   text: "return new Transaction(new Random().nextLong(), cashCard);"
   description: "Add logging to DataSourceService"
   ```

   ```java
   public Transaction getData() {
     CashCard cashCard = new CashCard(
       new Random().nextLong(), // Random ID
       "sarah1",
       new Random().nextDouble(100.00) // Random Amount
     );
     Transaction transaction = new Transaction(new Random().nextLong(), cashCard);
     System.out.println("Generating Transaction: " + transaction);
     return transaction;
   }
   ```

1. Run the application.

   Let's run the application and see that it is generating transactions:

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   [~/exercises] $ ./gradlew bootRun
   ...
   Generating Transaction: Transaction[id=-2719852727681158000, cashCard=CashCard[id=-6079371198316955842, owner=sarah1, amountRequestedForAuth=36.18919281848337]]
   Generating Transaction: Transaction[id=-5607247743473931121, cashCard=CashCard[id=6889019574148834540, owner=sarah1, amountRequestedForAuth=0.7966132708258855]]
   Generating Transaction: Transaction[id=8789939425625482805, cashCard=CashCard[id=6270568951233307661, owner=sarah1, amountRequestedForAuth=33.58135053399174]]
   <==========---> 80% EXECUTING [8s]
   > :bootRun
   ```

   But what would happen if Kafka was unavailable?

1. Stop Kafka.

   Before we swap our middleware to RabbitMQ, let's observe what happens when the middleware is unavailable to the running application.

   Using an unused **Terminal** pane, stop Kafka using the `docker stop kafka` command:

   ```shell
   [~/exercises] $ docker stop kafka
   ```

   Look what happens in the **Terminal** pane running our application:

   ```shell
   ...
   Generating Transaction: Transaction[id=2175805216802058711, cashCard=CashCard[id=7436539443625164261, owner=sarah1, amountRequestedForAuth=2.112304484447358]]
   Generating Transaction: Transaction[id=7686026790369954447, cashCard=CashCard[id=-9056617961033348083, owner=sarah1, amountRequestedForAuth=41.2613014355566]]
   20XX-XX-XXTXX:XX:XX.XXXZ  INFO 18618 --- [CashCard] [ad | producer-1] org.apache.kafka.clients.NetworkClient   : [Producer clientId=producer-1] Node 1 disconnected.
   20XX-XX-XXTXX:XX:XX.XXXZ  INFO 18618 --- [CashCard] [ad | producer-1] org.apache.kafka.clients.NetworkClient   : [Producer clientId=producer-1] Node -1 disconnected.
   20XX-XX-XXTXX:XX:XX.XXXZ  INFO 18618 --- [CashCard] [ad | producer-1] org.apache.kafka.clients.NetworkClient   : [Producer clientId=producer-1] Node 1 disconnected.
   20
   ```

   Oh no! Though we are still generating Transactions, our application is failing with `Node 1 disconnected` errors.

   This is telling us that Kafka is no longer available.

   Go ahead and stop the running application with the `CTL+C` command.

   While you're there, run the fancy `docker ps` command again to see that only RabbitMQ is now running:

   ```shell
   [~/exercises] $ docker ps --format 'table {{.Names}}\t{{.ID}}\t{{.Image}}\t{{.Status}}'
   NAMES      CONTAINER ID   IMAGE                 STATUS
   rabbitmq   27bce655e84d   rabbitmq:management   Up 10 minutes
   ```

We're ready to start using RabbitMQ!
