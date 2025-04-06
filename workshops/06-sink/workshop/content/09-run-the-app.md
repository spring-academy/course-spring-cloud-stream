+++
title="Running the full system"
+++

Let's have even more fun!

First, let's switch to the **Terminal** tab and make sure that the **Source** and **Processor** apps are still running. If they are not, restart them.

```dashboard:open-dashboard
name: Terminal
```

Now, in the tests we just wrote, we needed to specify which Spring Cloud Stream bindings to enable for our **Sink**, given that it has more than one binding available.

We will need to specify this same `parameter` when running our **Sink** application as well.

This is adding up to quite a few parameters to pass in:

- The list of sink bindings to enable.
- The console sink's input destination topic.
- The file sinks's input destination topic.

Those arguments look like this:

- Enable both bindings:

  ```java
  --spring.cloud.function.definition=sinkToConsole;cashCardTransactionFileSink
  ```

- Console sink's input topic:

  ```java
  --spring.cloud.stream.bindings.sinkToConsole-in-0.destination=enrichTransaction-out-0
  ```

- File sink's input topic:

  ```java
  --spring.cloud.stream.bindings.cashCardTransactionFileSink-in-0.destination=enrichTransaction-out-0`
  ```

The resulting `bootRun` command is as follows:

```shell
[~/exercises] ./gradlew cashcard-transaction-sink:bootRun --args="--spring.cloud.function.definition=sinkToConsole;cashCardTransactionFileSink --spring.cloud.stream.bindings.cashCardTransactionFileSink-in-0.destination=enrichTransaction-out-0 --spring.cloud.stream.bindings.sinkToConsole-in-0.destination=enrichTransaction-out-0"
```

When you run that command, you should see the console sink's out put to the **Terminal** pane:

```shell
...
Transaction is EnrichedTransaction[id=-4861773610089625141, cashCard=CashCard[id=3561139781355664422, owner=sarah1, amountRequestedForAuth=61.18042859564109], approvalStatus=APPROVED, cardHolderData=CardHolderData[userId=c2ea2178-ff7b-40c8-b742-6fc0f64df75c, name=sarah1, address=123 Main street]]
Transaction is EnrichedTransaction[id=-5936968538848160037, cashCard=CashCard[id=-763607115410248414, owner=sarah1, amountRequestedForAuth=36.587137093194066], approvalStatus=APPROVED, cardHolderData=CardHolderData[userId=ad766d2a-2234-4130-9a25-6bd4db047bf2, name=sarah1, address=123 Main street]]
...
<===========--> 88% EXECUTING [8s]
> :cashcard-transaction-sink:bootRun
```

But what do you see when you open the file sink's output file?

```editor:open-file
file: ~/exercises/cashcard-transaction-sink/build/tmp/transactions-output.csv
line: 1000
description: "Open the file sink CSV"
```

There we have the same data, written to a file!

![File Sink Output in the CSV File](/workshop/content/assets/file-sink-output.png)

Hurray - we are done!

Please stop all applications in the **Terminal** pane before continuing.

```dashboard:open-dashboard
name: Terminal
```
