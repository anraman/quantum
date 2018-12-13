# Gro-ho-ho-ver's Algorithm - How Quantum Computing Saved Christmas

> The non-festive version of this post can be found [here](./GroversBlog_Regular.md).

If you’ve been reading into quantum computing you’ve probably come across something called [Grover’s algorithm](https://en.wikipedia.org/wiki/Grover's_algorithm). Grover’s algorithm is famously applied to the search of an unordered database but it is applicable across a wide range of problems (such as [nearest neighbour classification](https://arxiv.org/pdf/1401.2142.pdf) in machine learning, for example) – even helping Santa find the right present in his sack!

You see, usually Santa’s elves make sure that all the presents in the sack are ordered in such a way that the right one is always at the top – otherwise he’d never get anything delivered! This year however, a little too much fun was had at the North Pole Christmas Party and the Chief Present Sorter had to ‘work from home’ on sorting day – crisis! Now Santa’s sack is full of presents but they are totally jumbled – how will he deliver them all in time?!

In the best case scenario, when Santa lands on the rooftop of a house and reaches into the sack, he will get lucky and pull the right present out first time. In the worst case scenario however, it will be the very last present he tries! On average, he will have to try roughly 50% of the presents before he finds the right one – with more than a billion children on the list, this is going to take far too long! In computer science speak, if there are N presents in the sack this problem is O(N).

Fortunately for us, elves are well known for their excellent grasp of quantum mechanics and so the Science and Magic Team quickly came up with an efficient solution to the problem – Gro-ho-ho-ver’s algorithm! This new technique makes use of quantum interference in order to reduce the complexity of the problem (to O(√N)). Unlike some other quantum algorithms (such as Shor’s), this is not an exponential speedup vs. the classical alternative, however it can still provide significant benefit if applied over a large enough problem space.

In this post we will explore how Grover’s algorithm works in a bit more detail by walking through a [simplified implementation](https://github.com/anraman/quantum/tree/master/GroverDatabaseSearch) in Q#, based on [this sample](https://github.com/Microsoft/Quantum/tree/release/v0.3.1810/Samples/src/DatabaseSearch) provided by the [Microsoft Quantum team on GitHub](https://github.com/Microsoft/Quantum) 😊

## The Scenario

First, let’s define the problem:

- **We have:** Santa's sack with N unsorted presents in it
- **We want to:** Find the present for child *k* (0 ≤ *k* ≤ N-1) - the *k*th present is our ‘marked element’
- **We need:** *n* qubits to represent this information (remember each qubit can represent two bits of information so to represent N presents we need *n* qubits such that 2*ⁿ* ≥ N)
- **We start with:** All the qubits in our register initialised to a simple starting state, in this case all Zeroes, like so: |000…00〉

For the purposes of this blog post, we will assume that Santa’s sack has eight presents in it, which means we will need **three** qubits (2³ = 8) in our register. We will be looking for present number eight (represented by |7〉, because we start at index 0) in this example – this is our marked element.

## Step 1: Prepare States for Search

The first thing we need to do is to create an equal superposition of states (presents) using the Hadamard operator applied to each of our qubits (which all start in the Zero state).

As a reminder, the Hadamard (H) operator transforms a qubit in the |0〉 state to a qubit in the |+〉 state, which is an equal superposition of the |0〉 and |1〉 states (i.e. when you measure the superposition it collapses to |0〉 with 50% probability and |1〉 with 50% probability). This is shown below:

![Using the Hadamard gate to prepare a uniform superposition (|+〉) from a starting state of |0〉](./Images/PrepPlusState.png)

![Measurement probabilities for a uniform superposition](./Images/UniformSuperposProb.png)

When we apply the Hadamard to an *n*-qubit register (H<sup>⊗*n*</sup>) initialised to the all-Zero state (|00...0〉), we get the following:

![H<sup>⊗*n*</sup> applied to an *n*-qubit register initialised to the all-Zero state (|00...0〉)](./Images/HxnZeroes.png)

Substituting in N = 8 for our three-qubit case:

![H<sup>⊗3</sup> applied to a 3-qubit register initialised to the all-Zero state (|000〉)](./Images/Hx3Zeroes.png)

If Santa were to look in the sack (take a measurement of the register) at this point, he would find the present he is looking for (|7〉) with probability ¹/<sub>N</sub> = ¹/<sub>8</sub> - this is the same situation as we have classically.

Below is a visualisation of what this looks like in terms of probability amplitudes – as you can see, currently the probability amplitudes are equal across all states in the register which means that when we pull a present from the sack, we are equally likely to see any of the presents |0〉 to |7〉:

![Uniform superposition over 8 states](./Images/UniformSuperpos.png)

In Q#, this operation looks like this:

```csharp
// Oracle that applies the Hadamard operator to each qubit in the register
// to transform starting state |00...0〉 to the uniform superposition |++...+〉 = |u〉

operation UniformSuperpositionOracle (databaseRegister : Qubit[]) : Unit {
    body (...) {
        let nQubits = Length(databaseRegister);
        for (idxQubit in 0 .. nQubits - 1) {
            H(databaseRegister[idxQubit]);
        }
    }
    adjoint invert;
}
```

We then need to mark the present we are looking for using a single ancillary qubit which we will flip from state |0〉 to |1〉 if and only if the register is in the state we are looking for (in this case, |7〉 = |111〉):

```csharp
// Oracle that flips the marked qubit from |0〉 to |1〉 if and only if
// the database register is in state |N-1〉 = |11...1〉
operation DatabaseOracle (markedQubit : Qubit, databaseRegister : Qubit[]) : Unit {
    body (...) {
        // Make use of the Controlled functor to apply this operation
        Controlled X(databaseRegister, markedQubit);
    }
    adjoint invert;
}
```

Putting these steps together:

```csharp
operation StatePreparationOracle (markedQubit : Qubit, databaseRegister : Qubit[]) : Unit {
    body (...) {
        // Starting state
        // |0〉|00...0〉

        UniformSuperpositionOracle(databaseRegister);
        // |0〉|++...+〉 = 1/√N * |0〉(|0〉 + |1〉 + ... + |N-1〉)

        DatabaseOracle(markedQubit, databaseRegister);
        // |s〉 = 1/√N * |0〉(|0〉 + |1〉 + ... + |N-2〉) + 1/√N * |1〉|N-1〉
    }

    adjoint invert;
}
```

The ancillary qubit is the single qubit you see before the register qubits in the comments above – we can see that after the last operation (`DatabaseOracle`) the state of this marker qubit is |1〉 for the marked present (|N-1〉 = |8-1〉 = |7〉) and |0〉 for all other presents. 

The term oracle is used to refer to any ‘black box’ process that is used as input to another algorithm – you can read more about quantum oracles [here](https://docs.microsoft.com/en-us/quantum/concepts/oracles?view=qsharp-preview).

## Step 2: Selectively apply phase shift to the marked present

We now need to apply some transformations that only influence the marked present. The first one is a reflection about the marked state. This has the effect of applying a phase change of -1 to the state we are looking for but has no effect on the other presents.

During this transformation, all probability amplitudes remain the same – only the phase changes (this has no effect on measurement probabilities):

![Phase shifted superposition](./Images/PhaseShiftedSuperpos.png)

As we can see from the above, only the sign of the probability amplitude for our marked present has changed because of this operation – the bars are still all the same height (they still have the same magnitude). In code, this reflection looks like this:

```csharp
// Apply a rotation that has the effect of applying a -1
// phase to the amplitude of the marked element only
operation ReflectMarked (markedQubit : Qubit) : Unit {
    // Marked elements always have the marked qubit in the state |1〉
    R1(PI(), markedQubit);
}
```

## Step 3: Invert about the average (reflect about the start state)

The next step – also known as the diffusion operator – influences the probability amplitudes of all the presents in the register by inverting around the average. This has the effect of taking the difference from the average probability amplitude and subtracting this value from each bar (in the case that the difference is negative (i.e. Δ₂ below), this results in an addition). 

This process is perhaps more easily understood through illustration:

![Before inversion](./Images/BeforeInversion.png)
![After inversion](./Images/AfterInversion.png)

And here’s the code:

```csharp
// Reflect about the start state
operation ReflectStart (markedQubit : Qubit, databaseRegister : Qubit[]) : Unit {
    // Perform adjoint state preparation operation to retrieve start state
    Adjoint StatePreparationOracle(markedQubit, databaseRegister);

    // Reflect about the start state (|00…0〉)
    ReflectZero([markedQubit] + databaseRegister);

    // Prepare the state |s〉 again using the oracle
    StatePreparationOracle(markedQubit, databaseRegister);
}
```

Together, steps two and three make up the ‘Grover iteration’. In order to find the right present with probability O(1), we simply need to repeat the Grover iteration O(√N) (√8 in this case) times. This has the effect of massively amplifying the probability amplitude of the marked present and greatly dampening the probability amplitudes of all other presents:

![Final superposition](./Images/FinalState.png)

Now, when Santa looks in the sack (takes a measurement of the register), he is much more likely to find the marked present than any other. Of course, this is still a probabilistic measurement so there is a chance that he will measure and find a present other than the one he is looking for; however, this can be mitigated by repeating the measurement a small number of times.

Putting it all together, the full algorithm is as follows:

1. Prepare states for search
2. Selectively apply phase shift to the marked element
3. Invert about the average (reflect about the start state)
4. Repeat steps 2 & 3 O(√N) times
5. Measure (there is now an O(1) probability of finding the marked state)

The code for the full quantum search looks like this:

```csharp
// Repeat the two reflection steps O(√N) times to amplify the amplitude of
// the marked state and obtain the marked element with O(1) probability
operation QuantumSearch (nIterations : Int, markedQubit : Qubit, databaseRegister : Qubit[]) : Unit {
    StatePreparationOracle(markedQubit, databaseRegister);

    // Perform Grover iterations
    for (idx in 0 .. nIterations - 1) {
        ReflectMarked(markedQubit);
        ReflectStart(markedQubit, databaseRegister);
    }
}
```

## Final Step: Try it for yourself!

All the code shown so far is available [here](https://github.com/anraman/quantum/tree/master/GroverDatabaseSearch) on GitHub - feel free to download and run the sample for yourself (instructions in the readme). The program does two things:

- First, it runs a classical search 1000 times (i.e. measuring the register in balanced superposition without performing any Grover iterations) and prints the result.
- Second, it runs the quantum search 1000 times with three Grover iterations per run and prints this result for comparison. Try modifying the number of Grover iterations to see how this affects the success rate of the search!

Once you’ve explored the code there, it’s a good idea to check out the [DatabaseSearch sample](https://github.com/Microsoft/Quantum/tree/release/v0.3.1810/Samples/src/DatabaseSearch) on the [official Microsoft Quantum GitHub](https://github.com/Microsoft/Quantum) which provides a more sophisticated implementation, as well as the fantastic [Quantum Kata for Grover’s algorithm](https://github.com/Microsoft/QuantumKatas/tree/master/GroversAlgorithm) which will really put your understanding to the test!

Don’t forget to tune in for more posts each day this month as the [Q# Advent Calendar 2018](https://blogs.msdn.microsoft.com/visualstudio/2018/11/15/q-advent-calendar-2018/) continues 😊