Before looking at Spring Cloud Stream itself, we explore why an event-driven system is worthwhile.

Therefore, we'll start this course by answering the question, _"What formulates an event-driven system, and why do we need one?"_

## The Need: Data, Data Everywhere

Today's enterprises are inundated with data events. These events come in all kinds of structures and shapes, or no structure at all. Some data is very structured data, such as conforming to a relational database or standardized data formats. Other data is unstructured, such as unpredictably-formatted documents, images, videos, audio files, binary data sent over an HTTP connection, and many other possibilities.

Here are some real-world examples of data events:

- A audio-video platform that streams A/V data over a TCP network.
- A credit card processing gateway tasked with real-time transaction approval and fraud detection.
- A stock exchange that deals with the constant influx of stock trading transactions.
- An airline's internet-of-things (IOT) system sending airplane sensor data to a central system.
- A street traffic application that monitors live road traffic and sends alerts to users in real time.
- A website analytics system that receives and analyzes a constant stream of user interaction data.

The list above is a tiny sample to illustrate the kind of data that modern enterprise software systems frequently deal with.

These types of data events occur in almost all the business and technical domains in which software plays a role: Banking, brokerages, financial clearinghouses, video/audio streaming platforms, e-commerce systems, healthcare solutions, entertainment, hospitality, news media, communication sector, education... the list goes on, into every imaginable aspects of our lives.

## Event-Driven Systems

We have seen that the amount of data that various systems generate and consume has expanded by many orders of magnitude, decade over decade. This plethora of data events was the catalyst that carved the path for a new class of software applications widely known as event-driven systems. In all likelihood, this trend will only continue, especially with the AI revolution that started in the early 2020s, with the immense data needs that it requires.

## Producers and Consumers

At the heart of event-driven systems are two activities, one where the system generates events, and another that consumes events. The former is generally known as a producer or publisher application, and the latter is called a consumer or receiver application. An event-driven system can also perform _both_ activities in a single application – by consuming on one end, and producing on the other. When doing so, such an application is known as a _processor_.

This kind of generalization of event-driven systems might bring a flashback to some readers of a familiar pattern that has been used in enterprise systems for decades, traditionally known as _pub-sub messaging,_ short for the _publish-subscribe_ architectural pattern.

A natural question might be, _"If this pattern has been around for a while, what suddenly changed that requires our special attention now?"_

One of the primary reasons for the sudden focus is the vast amount of data and the random nature of it, and the necessity to deliver this data in a reliable manner.

## Bah, Networks!

Almost all of these data event systems require high throughput and low latency. Take any of the example domains we listed at above. Any of these could potentially generate a ton of data every second, making the throughput requirements critical. Often these systems may generate terabytes of data per minute to process! At the same time, once this high throughput data is generated, it needs to be processed almost instantaneously, and latency cannot be tolerated.

For example, take the video streaming scenario, the binary data for a particular video frame might be delivered immediately, while the next packet is late... glitchy video! Or take the credit card approval system: if there is latency, then a customer might be waiting awkwardly for their credit card purchase to be approved. Not to mention how important it is to receive real-time traffic information during one's commute.

These scenarios illustrate the importance of avoiding latency in these high-throughput event-driven applications.
