+++
title="Inspect Queued Messages"
+++

Let's have a bit more fun and look at the data in the RabbitMQ exchange.

1. Bind a queue to the Exchange.

   Run the following command to create a queue named `test-queue` which will start pulling transaction data from the RabbitMQ exchange with all that activity:

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   [~/exercises] $ docker exec -it rabbitmq sh -c "rabbitmqadmin declare queue name=test-queue && rabbitmqadmin declare binding source=approvalRequest-out-0 destination=test-queue routing_key=#"
   ```

   When you switch back to the Overview, you'll see a new graphs for "Queued messages" and "Message rates":

   ```dashboard:open-dashboard
   name: RabbitMQ
   ```

   ![Rabbit MQ Management Console Overview Pane](/workshop/content/assets/rabbit-dashboard-update.png)

1. Fetch some queued messages.

   Next, in the **RabbitMQ** management UI, select the **Queues and Streams** tab and click on `test-queue`, which we created with the command above:

   ![Rabbit MQ Management Console Overview Pane](/workshop/content/assets/rabbit-queues.png)

   ![Rabbit MQ Management Console Overview Pane](/workshop/content/assets/rabbit-test-queue.png)

   Finally, scroll down to "Get messages" and fetch 100 message from the queue.

   ![Rabbit MQ Management Console Overview Pane](/workshop/content/assets/rabbit-messages.png)

   You'll see that the message contain our transactions!

1. Stop the app.

   Now that we have successfully swapped our middleware to RabbitMQ, please stop the running application by typing `CTL+C`:

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   ...
   Generating Transaction: Transaction[id=2901054998803121528, cashCard=CashCard[id=6878744951983194584, owner=sarah1, amountRequestedForAuth=77.91600726795862]]
   <==========---> 80% EXECUTING [2m 5s]
      > :bootRun
      ^C[~/exercises] $
   ```

   When you switch back to the `test-queue` view, you'll see that "Queued messages" has stopped increasing, and "Message rates" is now 0.0 messages per second:

   ```dashboard:open-dashboard
   name: RabbitMQ
   ```

   ![Rabbit MQ Management Console Overview Pane](/workshop/content/assets/rabbit-messages-stopped.png)

We did it!
