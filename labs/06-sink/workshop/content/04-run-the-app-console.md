+++
title="Watching the Console Sink"
+++

Let's have some fun!

This time we'll be running three applications: our **Source**, **Processor**, and **Sink**.

Thanks to our console logging, we won't need to monitor the Kafka middleware this lab to see what's going on.

1. Run the **Source**.

   We've done this before.

   In an unused **Terminal** pane, run the **Source** application, prefixing the target with the correct module prefix of `:cashcard-transaction-source`:

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   [~/exercises] $ ./gradlew cashcard-transaction-source:bootRun
   ...
   <===========--> 88% EXECUTING [22s]
   > :cashcard-transaction-source:bootRun
   ```

   You won't see anything happening once the application is running.

1. Run the **Processor**.

   We've done this before, too.

   Run the **Processor** application in another unused pane, prefixing the target with the correct module prefix of `:cashcard-enricher-source`. You will also need to specify the correct topic input destination `enrichTransaction-in-0.destination` to be `approvalRequest-out-0` -- the **Source** application's output destination:

   ![Pub/Sub topics](/workshop/content/assets/topics.svg)

   Here is the command:

   ```shell
   [~/exercises] $ ./gradlew cashcard-transaction-enricher:bootRun --args="--spring.cloud.stream.bindings.enrichTransaction-in-0.destination=approvalRequest-out-0"
   ...
   <===========--> 88% EXECUTING [11s]
   > :cashcard-transaction-enricher:bootRun
   ```

   Again, there won't be any more output here once the application is running.

   You can leave both the **Source** and **Processor** applications running for the remainder of this lab.

1. Run the **Sink**.

   Similar to the pattern established by the **Processor** application's input topic, we need to specify the **Sink's** input topic:

   - Run the **Sink** application in the third **Terminal** pane, prefixing the target with the correct module prefix of `:cashcard-sink-source`.
   - Specify the that the input of the **Sink** is the output of the **Processor**, which is setting `sinkToConsole-in-0.destination` to `enrichTransaction-out-0`.

   ![System with Sink](/workshop/content/assets/system-with-sink.svg)

   Here is the command:

   ```shell
   [~/exercises] $ ./gradlew cashcard-transaction-sink:bootRun --args="--spring.cloud.stream.bindings.sinkToConsole-in-0.destination=enrichTransaction-out-0"
   ```

   You'll see that the enriched transactions are being printed to the console by our `sinkToConsole` `Consumer`!

   ```shell
   ...
   Transaction is EnrichedTransaction[id=-4861773610089625141, cashCard=CashCard[id=3561139781355664422, owner=sarah1, amountRequestedForAuth=61.18042859564109], approvalStatus=APPROVED, cardHolderData=CardHolderData[userId=c2ea2178-ff7b-40c8-b742-6fc0f64df75c, name=sarah1, address=123 Main street]]
   Transaction is EnrichedTransaction[id=-5936968538848160037, cashCard=CashCard[id=-763607115410248414, owner=sarah1, amountRequestedForAuth=36.587137093194066], approvalStatus=APPROVED, cardHolderData=CardHolderData[userId=ad766d2a-2234-4130-9a25-6bd4db047bf2, name=sarah1, address=123 Main street]]
   ...
   <===========--> 88% EXECUTING [8s]
   > :cashcard-transaction-sink:bootRun
   ```

We did it! Or at least, we've done _half_ of it. We still need to sink to a file a well.

Go ahead and stop the **Sink** application by issuing `CMD+C` in its pane. Again, you can keep the other applications running.
