---
title: "Flipping a Coin: An Analogy for simulated Quantum Computing Limitations"
date: 2025-06-07T14:05:30+10:00
draft: false
tags: ["learning", "quantum-computing"]
---

I love chatting about science with whoever I find myself with and learning together through those interactions. A few times I've found myself talking about Quantum Computing and specifically discussing why quantum computers are required for quantum calculations. That is, restating the question, **why can't we just simulate quantum calculations on the powerful computers we have today**?

The quick answer is that the **amount of data (numbers) required to do those quantum calculations grows way too large very quickly** as the size of the calculation grows. So yes, we can simulate very simple quantum calculations that require only a few quantum bits, or qubits, but as the number of qubits grows, that data required for the calculation grows too large for our computers to handle - at least with the current math that we use for quantum calculations.

But that's not a satisfactory explanation: **it's a question stopper rather than a way to help understand why**. So here's my attempt to unpack a little more deeply why the data required for a quantum calculation grows so quickly, using an analogy of flipping coins. I've tried to keep the maths to a minimum required, but have introduced one of the simpler notation ideas of quantum mechanics - the state vector.

## A single coin flip

If I flip a single coin and keep it covered with my hand, I know the coin is already in one of two states - either heads or tails. Assuming it's a standard coin, the probability of it being heads is one half, as is the probability of it being tails. I can represent the current state of my single coin system as \\(\psi\\) with a probability equation:
$$\psi = \frac{1}{2}\text{HEADS} + \frac{1}{2}\text{TAILS}$$
to communicate that the probability that my single coin is heads-up is one half and the probability that it is tails-up is one half.

Let's simplify the notation by just using \\(\text{H}\\) and \\(\text{T}\\) for \\(\text{HEADS}\\) and \\(\text{TAILS}\\), so it's just:

$$\psi = \frac{1}{2}\text{H} + \frac{1}{2}\text{T}$$

Notice that we need to use two numbers: one number for the probability of each possible state of the single coin. In quantum mechanics, this is expressed more concisely as a state vector of just those two numbers.

### A state vector for a single coin flip

$$
\psi = \begin{pmatrix}
          \frac{1}{2} \\\\[1ex]
          \frac{1}{2}
       \end{pmatrix}
$$

This notation assumes that the top number represents \\(\text{H}\\) and the bottom number \\(\text{T}\\) (this isn't a quantum state vector as there's nothing quantum about coin flipping, but just introduces the similar notation).

## A double coin flip

Now let's look at the similar situation but with two coins - coin A and coin B. If we flip both and cover both, then both coins are in the state, having equal chance of being heads or tails:
$$
\begin{align}
\psi_{A} &= \frac{1}{2}\text{H} + \frac{1}{2}\text{T} \\\\[2ex]
\psi_{B} &= \frac{1}{2}\text{H} + \frac{1}{2}\text{T}
\end{align}
$$

I can again represent the current *system* state of the two coins A and B together with a probability equation but this time it is the product of my two individual state equations for each coin. Let's call this the *product state*:

### A product state for two coins A and B

$$
\psi_{AB} = \psi_{A}\psi_{B} = (\frac{1}{2}\text{H} + \frac{1}{2}\text{T})(\frac{1}{2}\text{H} + \frac{1}{2}\text{T})
$$

**Product State**: the state of the system expressed as the product of the individual states of each coin.

Notice that the product state has 2 numbers for each coin's state and so \\(2 + 2 = 4\\) numbers in total to represent the product state.

We can also expand the product state to reveal the probabilities of each possible result for the two coins A and B in an expanded state:
$$
\psi_{AB} = \frac{1}{4}\text{HH} +\frac{1}{4}\text{HT}  +\frac{1}{4}\text{TH}  +\frac{1}{4}\text{TT}
$$
**Expanded State**: the state of the system expressed as the expansion of the product state which lists each possible *system outcome of both coins* with its own probability.

### A state vector for a double coin flip

And again, in quantum mechanics, the more concise state vector notation would be used:

$$
\psi_{AB} = \begin{pmatrix}\frac{1}{4} \\\\[1ex] \frac{1}{4}\\\\[1ex] \frac{1}{4}\\\\[1ex] \frac{1}{4}\end{pmatrix}
$$

with the knowledge that the first top number represents the probability of both coins being heads (\\(\text{HH}\\)), the second heads-tails, the third tails-heads and the last tails-tails.

For this state vector we need 4 numbers to represent the 4 different system states that the coins might be in (\\(\text{HH}\\), \\(\text{HT}\\), \\(\text{TH}\\) or \\(\text{TT}\\)).

## A triple coin flip

Using the same process with three coins we start to see a difference between the two representations of the **product state** and the quantum mechanics **state vector**. Without repeating the same steps, the product state for the system where I flip and cover three coins, coin A, coin B and coin C, is:

### Product state for three coins A, B and C
$$
\psi_{ABC} = \psi_{A}\psi_{B}\psi_{C} = (\frac{1}{2}\text{H} + \frac{1}{2}\text{T})(\frac{1}{2}\text{H} + \frac{1}{2}\text{T}) (\frac{1}{2}\text{H} + \frac{1}{2}\text{T})
$$

Now we have \\(2 + 2 + 2 = 2 \times 3 = 6\\) numbers to represent the product state. Yet when we expand the product to get the expanded state it now lists all 8 possible outcomes for our system with three labelled coins:
$$
\psi_{ABC} = \frac{1}{8}\text{HHH} +\frac{1}{8}\text{HHT}  +\frac{1}{8}\text{HTH}  +\frac{1}{8}\text{HTT} + \frac{1}{8}\text{THH} +\frac{1}{8}\text{THT}  +\frac{1}{8}\text{TTH}  +\frac{1}{8}\text{TTT}
$$
or as a quantum mechanics state vector as follows.

### A state vector for a triple coin flip
The more concise state vector notation from quantum mechanics would be:
$$
\psi_{ABC} = \begin{pmatrix}\frac{1}{8} \\\\[1ex] \frac{1}{8} \\\\[1ex] \frac{1}{8} \\\\[1ex] \frac{1}{8} \\\\[1ex] \frac{1}{8} \\\\[1ex] \frac{1}{8} \\\\[1ex] \frac{1}{8} \\\\[1ex] \frac{1}{8}\end{pmatrix}
$$
again with the knowledge that the top number represents the probability of \\(\text{HHH}\\), followed by \\(\text{HHT}\\), \\(\text{HTH}\\), etc. through to \\(\text{TTT}\\).

So now, given the two possible outcomes for coin A, two possible outcomes for coin B and two possible outcomes for coin C, we need \\(2\times 2\times 2 = 2^{3} = 8\\) numbers to represent the 8 separate possible outcomes. This is only slightly larger than the 6 numbers we needed above for the product state of the three coins.

## Exponential requirements for more coin flips

So if we have 5 coins, we'll need \\(5\times 2 = 10\\) numbers to represent the state as the product state - the product of 5 individual coin states, but if we expand that product out to obtain the expanded system state with a separate probability for each possible outcome, we'll have \\(2\times 2 \times 2 \times 2 \times 2 = 2^5 = 32\\) possible system states for the five coins (\\(\text{HHHHH, HHHHT, HHHTH,}\\)... etc.) needing 32 numbers to represent the system state, with the  state vector looking something like:

$$
\psi_{ABCDE} = \begin{pmatrix}\frac{1}{32} \\\\[1ex] \frac{1}{32} \\\\[1ex] \frac{1}{32} \\\\[1ex] \frac{1}{32} \\\\[1ex] \frac{1}{32} \\\\[1ex] \frac{1}{32} \\\\[1ex] \vdots \\\\[1ex] \frac{1}{32}\end{pmatrix}
$$
but much longer (ie. with 32 numbers in total). So rather than the \\(5\times 2 = 10\\) numbers needed to express the same system as a *product of individual states*, we need 32 numbers for the state vector.

This difference between the how many numbers are needed to represent the *product state* versus the state vector diverges very quickly:

- 10 coins: 20 vs 1024 numbers
- 20 coins:  40 vs 1,048,576 numbers
- 50 coins: 100 vs 1,125,899,906,842,624 numbers

With 100 coins, we'd need 200 numbers to store and manipulate the *product of individual states* but \\(2^{100}\\) numbers to represent all the different possible states in a state vector, which is around a billion times more numbers than the best guesstimates of the number of grains of sand on the earth ([estimated to be somewhere around](https://www.scientificamerican.com/article/do-stars-outnumber-the-sands-of-earths-beaches/) \\(10^{20}\\) where as \\(2^{100}\\) is around \\(10^{30}\\)).

So why not just use the product state, which requires only 200 numbers for the 100 coins? That's exactly what you'd do if we were just calculating non-quantum coin flips, but...

## Quantum Bits versus Coins

Unlike the state of a system of coins, the state of a system of quantum bits, known as qubits, **can't always be represented as a product of individual states**. In quantum calculations the qubits become entangled with one another (dependent on one another) in a way that means, at least with our current maths, we can't represent intermediate single states of qubits and so **the full state vector is required to represent the system**.

The \\(2^{100}\\) numbers required for the state vector of a 100 qubit simulation is not physically possible for any computer to store or process. To give an idea of how much computer storage would be required, if you assume 8 bytes of data per number (for a single-precision floating point number), it works out to around 40 million times more data than [humans are estimated to have ever created up until 2024 ](https://www.statista.com/statistics/871513/worldwide-data-created/) (which is approximately 120 zettabytes, for what it's worth).

So with a 2025 typical laptop, you'll being doing well to be able to simulate quantum simulations of [20 to 30 qubits](https://quantumai.google/qsim/choose_hw).

It would require a little more maths to be able to explain *why* quantum calculations can't use the product of individual states, but hopefully this analogy with coin flipping goes one level deeper than the initial explanation and at least helps understand **why the state vector for a system grows exponentially as the number of coins or qubits increases**.
