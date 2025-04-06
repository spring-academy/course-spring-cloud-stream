+++
title="Service and Business Logic"
+++

Now that we defined our domain objects, let's add the business logic we need to enrich "normal" transactions.

As you can see, we have provided an empty `EnrichmentService`.

```editor:open-file
file: ~/exercises/cashcard-transaction-enricher/src/main/java/example/cashcard/service/EnrichmentService.java
description: "Open the EnrichmentService"
```

Just as in our **Source** application, we'll use contrived data to enrich our transactions. In a real application we might integrate with multiple specialized systems or perform database look-ups to compile such data, but our fake data will work for explanatory purposes.

Feel free to play around with various values if you would like, but this lab will assume the service is implemented as below:

1. We'll say that every transaction has the same `ApprovalStatus` of `APPROVED`.
1. The address will be the same for all transactions.

Below is the implementation:

```java
package example.cashcard.service;

import java.util.UUID;

import example.cashcard.domain.ApprovalStatus;
import example.cashcard.domain.CardHolderData;
import example.cashcard.domain.EnrichedTransaction;
import example.cashcard.domain.Transaction;

public class EnrichmentService {
    public EnrichedTransaction enrichTransaction(Transaction transaction) {
        return new EnrichedTransaction(transaction.id(), transaction.cashCard(), ApprovalStatus.APPROVED,
                new CardHolderData(UUID.randomUUID(), transaction.cashCard().owner(), "123 Main street"));
    }
}
```

Now that we have added enriching business logic to our service, let's wire it up to Spring Cloud Stream.
