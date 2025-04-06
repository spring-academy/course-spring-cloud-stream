+++
title="Bootstrap the Project"
+++

Complete the following steps to use Spring Initializr to set up the Family Cash Card event-driven service.

1. Open dashboard tab labeled _Spring Initializr_:

   ```dashboard:open-dashboard
   name: Spring Initializr
   description: Click to open the Spring Initializr
   ```

   ![](/workshop/content/images/initializr-metadata.png)

   **Note:** You may notice that the Initializr dashboard has different versions than what we show you here.
   The Spring Team continually updates the Initializr with the latest available versions of Spring
   and Spring Boot.

1. Select the following options:

   - Project: **Gradle - Groovy**
   - Language: **Java**
   - SpringBoot: Choose the latest **3.2.X** version

1. Enter the following values next to the corresponding Project Metadata fields:

   - Group: `example`
   - Artifact: `cashcard`
   - Name: `CashCard`
   - Description: `CashCard service for Family Cash Cards`
   - Packaging: **Jar**
   - Java: **17**

   **Note:** You don't have to enter the "Package name" field -- Spring Initializr will fill this in for you!

1. Select the **ADD DEPENDENCIES...** button from the **Dependencies** panel.

1. Select the following option, since we know that we'll be creating an event-driven streaming application:

   - **Cloud Stream**
   - **Spring for Apache Kafka**

   Later on in the course, you might add additional dependencies without using Spring Initializr.

   ![](/workshop/content//images/initializr-dependencies.png)

1. Click the **CREATE** button.

   Spring Initializr will generate a zip file of code and unzip it in your home directory.

1. From the command line in the _Terminal_ tab, enter the following commands to use the gradle wrapper to build and test the generated application.

   Go to the `cashcard` directory in the _Terminal_ dashboard tab.

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   [~] $ cd cashcard
   [~/cashcard] $
   ```

   Next, run the `./gradlew build` command:

   ```shell
   [~/cashcard] $ ./gradlew build
   ```

   The output shows that the application passed the tests and was successfully built.

   ```shell
   ~/cashcard] $ ./gradlew build
   Downloading ...
   ...
   Starting a Gradle Daemon (subsequent builds will be faster)
   OpenJDK 64-Bit Server VM warning: Sharing is only supported for boot loader classes because bootstrap classpath has been appended
   20XX-XX-XXTXX:XX:XX.XXXZ  INFO 534 --- [CashCard] [ionShutdownHook] o.s.i.endpoint.EventDrivenConsumer       : Removing {logging-channel-adapter:_org.springframework.integration.errorLogger} as a subscriber to the 'errorChannel' channel
   20XX-XX-XXTXX:XX:XX.XXXZ  INFO 534 --- [CashCard] [ionShutdownHook] o.s.i.channel.PublishSubscribeChannel    : Channel 'CashCard.errorChannel' has 0 subscriber(s).
   20XX-XX-XXTXX:XX:XX.XXXZ  INFO 534 --- [CashCard] [ionShutdownHook] o.s.i.endpoint.EventDrivenConsumer       : stopped bean '_org.springframework.integration.errorLogger'

   BUILD SUCCESSFUL in 46s
   7 actionable tasks: 7 executed
   [~/cashcard] $
   ```

1. Run the Application.

   Now that we've built the downloaded project, let's see what happens when we run it.

   ```shell
   [~/cashcard] $ cd build/libs/
   [~/cashcard/build/libs] $ java -jar cashcard-0.0.1-SNAPSHOT.jar
   ```

   You'll see that the application runs, does not do very much, and quickly exits.

   But, looking at the Terminal output, you can see that several Spring Cloud Stream configurations attempt to load.

   Look in the output for references to the following:

   - `errorChannel`
   - `DefaultHeaderChannelRegistry`
   - `EventDrivenConsumer`
   - `PublishSubscribeChannel`

   ```shell
   ... INFO ... : Starting CashCardApplication v0.0.1-SNAPSHOT using Java 17.0.7 with PID 1914 (/home/eduk8s/cashcard/build/libs/cashcard-0.0.1-SNAPSHOT.jar started by eduk8s in /home/eduk8s/cashcard/build/libs)
   ... INFO ... : No active profile set, falling back to 1 default profile: "default"
   ... INFO ... : No bean named 'errorChannel' has been explicitly defined. Therefore, a default PublishSubscribeChannel will be created.
   ... INFO ... : No bean named 'integrationHeaderChannelRegistry' has been explicitly defined. Therefore, a default DefaultHeaderChannelRegistry will be created.
   ... INFO ... : Adding {logging-channel-adapter:_org.springframework.integration.errorLogger} as a subscriber to the 'errorChannel' channel
   ... INFO ... : Channel 'CashCard.errorChannel' has 1 subscriber(s).
   ... INFO ... : started bean '_org.springframework.integration.errorLogger'
   ... INFO ... : Started CashCardApplication in 1.275 seconds (process running for 1.595)
   ... INFO ... : Removing {logging-channel-adapter:_org.springframework.integration.errorLogger} as a subscriber to the 'errorChannel' channel
   ... INFO ... : Channel 'CashCard.errorChannel' has 0 subscriber(s).
   ... INFO ... : stopped bean '_org.springframework.integration.errorLogger'
   ```

   Channels, Consumers, and Publishers are all event-driven system concepts you'll soon learn about in this course.

   It is expected at this point that most of the messages are regarding errors. Yet, even though most of the messages are regarding errors, it is clear tha Spring Cloud Stream is loaded automatically by Spring Boot.

   This means we're ready to develop our application!
