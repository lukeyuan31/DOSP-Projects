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
