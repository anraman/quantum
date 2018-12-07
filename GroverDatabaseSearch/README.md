# Grover's Search Algorithm

- Simplified code implementing Grover's search algorithm based on [this](https://github.com/Microsoft/Quantum/tree/master/Samples/DatabaseSearch) official Microsoft Quantum sample
- For an explanation of how the algorithm works, please see my post on the [Q# Advent Calendar 2018](https://blogs.msdn.microsoft.com/visualstudio/2018/11/15/q-advent-calendar-2018/)

## Instructions

- To run the sample either build & run through Visual Studio 2017 or VS Code or from the commandline run the following from the `GroverDatabaseSearch` subfolder (sample output provided):

```ps
$ dotnet build
$ dotnet run

Classical random search for marked element in database (no Grover iterations).
  Database size: 64
  Looking for marked element: One One One One One One

Attempt: 99. Success: False. Probability: 0.01. Found database index: Zero, One, One, Zero, Zero, Zero
Attempt: 199. Success: False. Probability: 0.005. Found database index: Zero, One, One, Zero, Zero, One
Attempt: 299. Success: False. Probability: 0.007. Found database index: Zero, One, Zero, Zero, One, One
Attempt: 399. Success: False. Probability: 0.01. Found database index: Zero, One, Zero, Zero, Zero, One
Attempt: 499. Success: False. Probability: 0.01. Found database index: One, One, Zero, Zero, One, Zero
Attempt: 599. Success: False. Probability: 0.01. Found database index: Zero, One, One, One, Zero, Zero
Attempt: 699. Success: False. Probability: 0.011. Found database index: One, Zero, Zero, One, Zero, Zero
Attempt: 799. Success: False. Probability: 0.011. Found database index: Zero, One, One, One, Zero, One
Attempt: 899. Success: False. Probability: 0.016. Found database index: Zero, Zero, Zero, One, One, Zero
Attempt: 999. Success: False. Probability: 0.014. Found database index: Zero, One, Zero, Zero, One, One

Total success count over 1000 attempts: 14.

Quantum search for marked element in database. Number of Grover iterations: 3
  Database size: 64
  Looking for marked element: One One One One One One

Attempt: 99. Success: True.  Found database index: One, One, One, One, One, One
Attempt: 199. Success: True.  Found database index: One, One, One, One, One, One
Attempt: 299. Success: True.  Found database index: One, One, One, One, One, One
Attempt: 399. Success: True.  Found database index: One, One, One, One, One, One
Attempt: 499. Success: False.  Found database index: Zero, One, One, Zero, Zero, Zero
Attempt: 599. Success: False.  Found database index: Zero, One, One, Zero, One, Zero
Attempt: 699. Success: True.  Found database index: One, One, One, One, One, One
Attempt: 799. Success: False.  Found database index: One, One, One, Zero, Zero, One
Attempt: 899. Success: False.  Found database index: One, One, Zero, One, Zero, Zero
Attempt: 999. Success: True.  Found database index: One, One, One, One, One, One

Total success count over 1000 attempts: 603.

Press any key to exit.
```

## Useful Links

- [Original sample code from Microsoft Quantum](https://github.com/Microsoft/Quantum/tree/master/Samples/DatabaseSearch)
- [Q# Advent Calendar 2018](https://blogs.msdn.microsoft.com/visualstudio/2018/11/15/q-advent-calendar-2018/)
- [Microsoft Quantum Kata for Grover's algorithm](https://github.com/Microsoft/QuantumKatas/tree/master/GroversAlgorithm)
- Lov Grover's original paper on the subject: [A fast quantum mechanical algorithm for database search](https://arxiv.org/abs/quant-ph/9605043)
- [Quantum Adventures blog](https://aka.ms/quantumadventures) (101-level content plus lots of helpful links for beginners on the landing page)