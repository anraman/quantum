// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.


namespace Microsoft.Quantum.Samples.DatabaseSearch {
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Extensions.Convert;
    open Microsoft.Quantum.Extensions.Math;
    open Microsoft.Quantum.Canon;

    // Apply the Hadamard operation to each qubit in the register to transform
    // from |00...0〉 to the uniform superposition |++...+〉 = |u〉 
    operation UniformSuperpositionOracle(databaseRegister: Qubit[]) : () {
        body {
            let nQubits = Length(databaseRegister);
            for (idxQubit in 0..nQubits - 1) {
                H(databaseRegister[idxQubit]);
            }
        }

        adjoint auto
    }

    // Oracle that flips the marked qubit from |0〉 to |1〉 if and only if
    // the database register is in state |N-1〉 = |11...1〉
    operation DatabaseOracle(markedQubit: Qubit, databaseRegister: Qubit[]) : () {
        body {
            // Make use of the Controlled functor to apply this operation
            (Controlled X)(databaseRegister, markedQubit);
        }

        adjoint auto
    }

    // Prepare the state for amplitude amplification:
    // # Create uniform superposition |u〉 = |++...+〉 = |0〉 + |1〉 + ... + |N-1〉 by bitwise application of the Hadamard
    // ## |0〉 = |00...0〉, |1〉 = |00...1〉, ..., |N-1〉 = |11...1〉
    // # |m〉 is our marked qubit, initially in state |0〉 as well
    // # Apply the oracle to |m〉|u〉. |m〉 is flipped to |1〉 using the X operation if and only if the database register
	// |u〉 is in state |N-1〉 = |11...1〉
    operation StatePreparationOracle(markedQubit: Qubit, databaseRegister: Qubit[]) : () {
        body {
            // Starting state
            // |0〉|00...0〉

            UniformSuperpositionOracle(databaseRegister);
            // |0〉|++...+〉 = 1/√N * |0〉(|0〉 + |1〉 + ... + |N-1〉)
            
            DatabaseOracle(markedQubit, databaseRegister);
            // |s〉 = 1/√N * |0〉(|0〉 + |1〉 + ... + |N-2〉) + 1/√N * |1〉|N-1〉
        }

        adjoint auto
    }

    // Apply a rotation that has the effect of applying a -1 phase to amplitude of the marked element only
    // This has no effect on unmarked elements. All probability amplitudes remain the same during
    // this transformation, just the phase changes (this has no effect on measurement probabilities)
    operation ReflectMarked(markedQubit : Qubit) : (){
        body {
            // Marked elements always have the marked qubit in the state |1〉.
            R1(PI(), markedQubit);
        }
    }

    // Reflection about the |00…0〉 state.
    operation ReflectZero(databaseRegister : Qubit[]) : () {
        body {
            let nQubits = Length(databaseRegister);

            // Flip all the qubits (including the marked qubit, at position 0)
            for(idxQubit in 0..nQubits-1){
                X(databaseRegister[idxQubit]);
            }

            // Apply phase of -1 to the marked qubit
            (Controlled Z)(databaseRegister[1..nQubits-1], databaseRegister[0]);
            for(idxQubit in 0..nQubits-1){
                X(databaseRegister[idxQubit]);
            }
        }
    }

    // This is WRW in the original paper (HRH)
    // Reflect about the start state
    operation ReflectStart(markedQubit : Qubit, databaseRegister: Qubit[]) : () {
        body {
            // Perform adjoint state preparation operation to retrieve start state
            (Adjoint StatePreparationOracle)(markedQubit, databaseRegister);

            // Reflect about the start state
            ReflectZero([markedQubit] + databaseRegister);

            // Prepare the state |s〉 again using the oracle
            StatePreparationOracle(markedQubit, databaseRegister);
        }
    }

    // Repeat the two reflection steps O(√N) times to obtain the marked element with O(1) probability
    operation QuantumSearch(nIterations : Int, markedQubit : Qubit, databaseRegister: Qubit[]) : () {
        body {
            StatePreparationOracle(markedQubit, databaseRegister);
            // Loop over Grover iterates.
            for(idx in 0..nIterations-1){
                ReflectMarked(markedQubit);
                ReflectStart(markedQubit, databaseRegister);
            }
        }
    }

    // Allocate qubits for Grover's algorithm, implement the `QuantumSearch`, measure the marked qubit 
    // and the database register, and returns the measurement results.
    operation ApplyQuantumSearch(nIterations : Int, nDatabaseQubits : Int) : (Result, Result[]) {
        body{
            // Allocate variables to store measurement results.
            mutable resultSuccess = Zero;
            mutable resultElement = new Result[nDatabaseQubits];
            
            // Allocate nDatabaseQubits + 1 qubits. These are all in the |0〉
            // state.
            using (qubits = Qubit[nDatabaseQubits+1]) {
                
                // Define marked qubit to be indexed by 0.
                let markedQubit = qubits[0];

                // Let all other qubits be the database register.
                let databaseRegister = qubits[1..nDatabaseQubits];

                // Implement the quantum search algorithm.
                QuantumSearch(nIterations, markedQubit, databaseRegister);

                // Measure the marked qubit. On success, this should be One.
                set resultSuccess = M(markedQubit);

                // Measure the state of the database register post-selected on
                // the state of the marked qubit.
                set resultElement = MultiM(databaseRegister);

                // These reset all qubits to the |0〉 state, which is required 
                // before deallocation.
                if (resultSuccess == One) {
                    X(markedQubit);
                }
                for (idxResult in 0..nDatabaseQubits - 1) {
                    if (resultElement[idxResult] == One) {
                        X(databaseRegister[idxResult]);
                    }
                }
            }

            // Returns the measurement results of the algorithm.
            return (resultSuccess, resultElement);
        }
    }
}
