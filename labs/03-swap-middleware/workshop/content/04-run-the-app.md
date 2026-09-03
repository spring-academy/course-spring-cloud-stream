+++
title="Run the App"
+++

So far we have stopped the Kafka service and switched our Spring Cloud Stream dependencies to use RabbitMQ... at least we hope so.

Let's verify that our changes worked and are actually using RabbitMQ as our messaging middleware.

1. Launch the RabbitMQ Management Console.

   Unlike Kafka, RabbitMQ does not have a handy shell script that lets us easily monitor its activity.

   But, luckily for us, RabbitMQ does provide handy a management UI for us to explore.

   Switch to the **RabbitMQ** tab and log in using the following credentials:

   - Username: `guest`
   - Password: `guest`

   ```dashboard:open-dashboard
   name: RabbitMQ
   ```

   ![Rabbit MQ Management Console Login Window](/workshop/content/assets/rabbit-login.png)

   Notice that the **Overview** tab within the console shows no activity or graphs.

   ![Rabbit MQ Management Console Overview Pane](/workshop/content/assets/rabbit-overview.png)

   Let's give it something to graph about.

1. Run the application.

   As we did before, let's run our application in an unused **Terminal** pane, but this time producing 10 transactions per second, or every **100 milliseconds**:

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   [~/exercises] $ ./gradlew bootRun --args="--spring.integration.poller.fixed-delay=100"

   ...
   Generating Transaction: Transaction[id=-2719852727681158000, cashCard=CashCard[id=-6079371198316955842, owner=sarah1, amountRequestedForAuth=36.18919281848337]]
   Generating Transaction: Transaction[id=-5607247743473931121, cashCard=CashCard[id=6889019574148834540, owner=sarah1, amountRequestedForAuth=0.7966132708258855]]
   Generating Transaction: Transaction[id=8789939425625482805, cashCard=CashCard[id=6270568951233307661, owner=sarah1, amountRequestedForAuth=33.58135053399174]]
   <==========---> 80% EXECUTING [8s]
   > :bootRun
   ```

   Everything seems normal, but how do we know it's actually working?

1. Watch the RabbitMQ activity.

   ```dashboard:open-dashboard
   name: RabbitMQ
   ```

   Within a few seconds you should see a graph appear on the **Overview** tab spike up to 10 messages per second.

   ![Rabbit MQ Management Console Overview Pane](/workshop/content/assets/rabbit-graph-2.png)

That's Spring Cloud Stream in action!

