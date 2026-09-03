+++
title="Overview"
+++

In this lab, we will write a Spring Cloud Stream application that produces data into an outbound destination.

We will take an iterative approach in this lab by building small components, testing them, and finally culminating in a full end-to-end Spring Cloud Stream **Source** application.

## Introducing the Family Cash Card Domain

We are going to build our apps around the Family Cash Card domain, which you learned about in the course Introduction. This is a contrived domain for our learning purposes, where we imagine millions of customers worldwide use this imaginary company's cash cards to help manage purchases by their family.

![Family Cash Cards](https://raw.githubusercontent.com/spring-academy/spring-academy-assets/main/courses/course-spring-brasb-build-a-rest-api/NEWcardUI.png)

### The Event-Driven Use Case

Let us assume that tons of data is captured and saved regarding customers and their cash card activity, and this data is saved in a specialized system. This system could be a relational database, file system, or something else entirely.

Imagine the Family Cash Card company wants a real-time understanding of how cash cards are used. For example, company management wants to track how many cards are authorized and declined, the amount credited, debited, etc.

An event driven system built with Spring Cloud Stream is perfect for this scenario!

## What Will We Build?

What we will build are **_Spring Cloud Stream applications_** that will receive data from this a data source, process that data, and re-publish it as another stream of data.

- Our Spring Cloud Stream **Source** application will **consume** data from the simulated data service.
- Then, our source application will **produce** it to a middleware destination, such as Kafka.

Who knows: this data might be consumed by many more other consumers downstream!

In this lab, we will create the **Source application**.

### Where will the Data Come From?

Luckily for us, advanced data management systems is outside the scope of this course.

We will abstract the data-layer and generate our own randomized cash card transactions for demonstration purposes.

Before we start building, let's first review what we have done so far.
