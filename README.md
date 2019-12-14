# DOSP Projects

[![996.icu](https://img.shields.io/badge/link-996.icu-red.svg)](https://996.icu)

***University of Florida***  
*Keyuan Lu*  
keyuan.lu@ufl.edu

COP5615 Distributed Operating System Principles

## Project1

### Vampire Numbers

#### 1. Problem Definition  

An interesting kind of number in mathematics is **vampire number**. A vampire number is a **composite natural number**  with an even number of digits, that can be factored into two natural numbers each with *half as many digits as the original number* and *not both with trailing zeroes*, where the two factors contain precisely *all the digits of the original number*, in any order, counting multiplicity.  A classic example is: 1260= 21 x 60.

A vampire number can have multiple distinct pairs of fangs. A vampire numbers with 2 pairs of fangs is: 125460 = 204 × 615 = 246 × 510.

The goal of this first project is to use Elixir and the actor model to build a good solution to this problem that runs well on multi-core machines.

#### 2.Requirements

**Input**: The input provided (as command line to your program, e.g. my_app) will be two numbers: N1 and N2. The overall goal of your program is to find all vampire numbers starting at N1 and up to N2.

**Output**: Print, on independent lines, first the number then its fangs. If there are multiple fangs list all of them next to each other like it’s shown in the example below.

## Project2

### Gossip Simulator

#### 1.Problem Definition

As described in class Gossip type algorithms can be used both for group communication and for aggregate computation. The goal of this project is to determine the convergence of such algorithms through a simulator based on actors written in Elixir. Since actors in Elixir are fully asynchronous, the particular type of Gossip implemented is the so-called Asynchronous Gossip.  

Algorithm: **Gossip**, **Push-Sum**  

Topologies: **Full Network**, **Line**, **Random 2D Grid**, **3D Torus Grid**, **Honeycomb**, **Honeycomb with a random neighbor**

#### 2. Requirements

**Input**: The input provided (as command line to your program will be of the form:

```command
my_program numNodes topology algorithm
```

Where numNodes is the number of actors involved (for 3D based topologies you can round up until you get a cube, similarly for 2D until you get a square), topology is one of full, line, rand2D, 3Dtorus, honeycomb and randhoneycomb, algorithm is one of gossip, push-sum.

**Output**: Print the amount of time it took to achieve convergence of the algorithm. Please described how you measured the time in your report.

## Project3

### Tapestry Algorithm

#### 1. Problem Definition

We talked extensively in class about the overlay networks and how they can be used to provide services. The goal of this project is to implement in Elixir using the actor model the Tapestry Algorithm and a simple object access service to prove its usefulness. The specification of the Tapestry protocol can be found in the paperTapestry: **A Resilient Global-Scale Overlay for Service Deployment** by *Ben Y. Zhao, Ling Huang, Jeremy Stribling, Sean C. Rhea, Anthony D. Joseph and John D. Kubiatowicz*. Link to paper https://pdos.csail.mit.edu/~strib/docs/tapestry/tapestry\_jsac03.pdf. You can also refer to Wikipedia page: https://en.wikipedia.org/wiki/Tapestry_(DHT) . Here is other useful link: https://heim.ifi.uio.no/michawe/teaching/p2p-ws08/p2p-5-6.pdf .
Here is a survey paper on comparison of peer-to-peer overlay network schemes. https://zoo.cs.yale.edu/classes/cs426/2017/bib/lua05survey.pdf.

You have to implement the network join and routing as described in the Tapestry paper
(Section 3: TAPESTRY ALGORITHMS). You can change the message type sent and the specific
activity as long as you implement it using a similar API to the one described in the paper.

#### 2.Requirements

**Input**:

```command
mix run project3.exs numNodes numRequests
```

Where numNodes is the number of peers to be created in the peer to peer system and numRequests the number of requests each peer has to make. When all peers performed that many requests, the program can exit. Each peer should send a request/second.

**Output**:Print the average number of hops (node connections) that must be traversed to deliver a message.

**Actor Modeling**: In this project you have to use exclusively the actor facility in Elixir (i.e. GenServer) (**projects that do not use multiple actors or use any other form of parallelism will receive no credit**). You should have one actor for each of the peers modeled.

**README file**: In the README file you have to include the following material:

- Team members
- What is working
- What is the largest network you managed to deal with

## Project 4.1

### Twitter Engine

#### 1. Problem definition

The goal of this (and the next project) is to implement a Twitter-like engine and (in part 2) pair up with Web Sockets to provide full functionality.  
Specific things you have to do are:  
In part I, implement the following functionalities:  
1.Register accountand delete account2.  
Send  tweet.  Tweets  can  have  hashtags  (e.g.  #COP5615isgreat)  and  mentions (@bestuser). You can use predefines categories of messages for hashtags.  
3.Subscribe to user's tweets.  
4.Re-tweets (so that your subscribers get an interesting tweet you got by other means).  
5.Allow querying tweets subscribed to, tweets with specific hashtags, tweets in which the user is mentioned (my mentions).  
6.If the user is connected, deliver the above types of tweets live (without querying).  

Other considerations:  
The client part (send/receive tweets) and the engine (distribute tweets) have to be in separate processes. Preferably, you use multiple independent client processes that simulate thousands of clients and a single-engine process.  
1.You need to measure various aspects of your simulator and report performance.  
2.Write test cases using the elixir’s built-in ExUnit test framework verifying the correctness for each task. Specifically, you need to write unit tests and functional tests (simple scenarios in which a tweet is sent, the user is mentioned or re-tweets).Write 2-3 testsfor each functionality.  

#### 2. Requirements
**Input** The input provided (as command line to yourprogram will be of the form:
```command
mix run proj4 num_user num_msg
```
Where *num_user* is the number of actors you have to create and *num_msg* is the number of tweets a user has to make.


## Project4.2

1.  Implement a simulation with at least 100 users.

2. Implement a web interface for the simulator you created project 4.1, using phoenix that allows access to the ongoing simulation using a web browser ( You might need to use the matching JavaScript library that allows Phoenix messages to be received in the browser). Create WebSockets using Phoenix channels. if you are creating a chart, you can use Charts.js

You need to show all the scenarios that you implemented in 4.1.