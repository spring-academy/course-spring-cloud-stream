+++
title="Review the Controller and Test"
+++

As we mentioned the Overview, we want to use `StreamBridge` and a REST controller to help us publish transaction data on-demand.

We've provided some scaffolding for you: a controller, its test, and the required Spring Web dependencies.

Let's review the changes so you are familiar with how the controller currently works, before we implement our `StreamBridge` functionality.

1. Review the new dependency.

   Since we have a REST controller, we need the `spring-boot-starter-web` dependency.

   Take a look at `build.gradle` for this new dependency.

   ```editor:select-matching-text
   file: ~/exercises/build.gradle
   text: "implementation 'org.springframework.boot:spring-boot-starter-web'"
   description: "Review build.gradle dependencies"
   ```

   ```groovy
   dependencies {
     ...
     implementation 'org.springframework.boot:spring-boot-starter-web'
     ...
   }
   ```

   That's the only dependency we need to add to enable both REST interactions and also HTTP testing support.

1. Review the controller.

   We've created a new package named `example.cashcard.controller` with a simple REST controller named `CashCardController` within.

   You'll see that we have added a `POST` request handler endpoint, which takes a `Transaction` as a request payload.

   Give it a look now:

   ```editor:open-file
   file: ~/exercises/src/main/java/example/cashcard/controller/CashCardController.java
   description: "Review the CashCardController class"
   ```

   This will support the use case we described earlier: whenever a purchase is made, the transaction information can be sent to our REST controller for immediate handling by Spring Cloud Stream.

   ```java
   @PostMapping(path = "/publish/txn")
   public void publishTxn(@RequestBody Transaction transaction) {
     System.out.println("POST for Transaction: " + transaction);
   }
   ```

   For the moment we simply `System.out.println` the `Transaction`, which is bad and wrong and you should never do this in real life. But, it is very helpful at the moment as we get started. Don't worry, we'll change this soon.

1. Review and run the controller tests.

   If you are familiar with Spring MVC and its testing support, what we are doing here should be familiar to you.

   Take a look at the `CashCardControllerTests` class and the one test method, `postShouldSendTransactionAsAMessage`

   ```editor:select-matching-text
   file: ~/exercises/src/test/java/example/cashcard/controller/CashCardControllerTests.java
   text: "postShouldSendTransactionAsAMessage"
   description: "Review CashCardControllerTests"
   ```

   ```java
   @SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT)
   public class CashCardControllerTests {
    ...
     @Autowired
     private TestRestTemplate restTemplate;

     @Test
     void cashCardStreamBridge() throws IOException {
       Transaction transaction = new Transaction(1L, new CashCard(123L, "kumar2", 1.00));
       ResponseEntity<Transaction> response = this.restTemplate.postForEntity(
         "http://localhost:" + port + "/publish/txn",
         transaction, Transaction.class);

       assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
     }
     ...
   }
   ```

   Here are a few items of note:

   - We are autowiring the `TestRestTemplate` for interacting with our REST endpoint.
   - At the moment the test only asserts that at a `POST` to the endpoint completes without errors. We will soon update this expectation to test that posted transactions are "bridged" to our Spring Cloud Stream _output_ binding.

   Let's run the tests to make sure they pass:

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   [~/exercises] $ ./gradlew test
   ...
   BUILD SUCCESSFUL in 10s
   4 actionable tasks: 4 executed
   ```

   Great! Next, let's exercise the `POST` endpoint and make sure it works, too.

1. `POST` to the REST endpoint.

   In the **Terminal**, run the application using the `bootRun` command

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   [~/exercises] $ ./gradlew bootRun
   ...
   20XX-XX-XXTXX:XX:XX.XXXZ  INFO 14453 --- [CashCard] [           main] o.s.b.w.embedded.tomcat.TomcatWebServer  : Tomcat started on port 8080 (http) with context path ''
   20XX-XX-XXTXX:XX:XX.XXXZ  INFO 14453 --- [CashCard] [           main] example.cashcard.CashCardApplication     : Started CashCardApplication in 2.651 seconds (process running for 2.934)
   <==========---<==========---> 80% EXECUTING [59s]
   > :bootRun
   ```

   Next, in an unused pane, use the `curl` command to `POST` a transaction to the controller:

   ```shell
   [~/exercises] $ curl -d '{
     "id" : 100,
     "cashCard" : {
       "id" : 209,
       "owner" : "kumar2",
       "amountRequestedForAuth" : 200.0
     }
   }' -H "Content-Type: application/json" -X POST http://localhost:8080/publish/txn
   ```

   Thanks to the `println` statement we should see the transaction printed to the application's **Terminal** pane.

   ```shell
   20XX-XX-XXTXX:XX:XX.XXXZ  INFO 3476 --- [CashCard] [nio-8080-exec-1] o.s.web.servlet.DispatcherServlet        : Completed initialization in 1 ms
   POST for Transaction: Transaction[id=100, cashCard=CashCard[id=209, owner=kumar2, amountRequestedForAuth=200.0]]
   <==========---> 80% EXECUTING [40s]
   > :bootRun
   ```

This is a great start!

Let's move on and start implementing our use case: `POST`ing a `Transaction` to our controller should queue it in the Spring Cloud Stream _output_ binding.
