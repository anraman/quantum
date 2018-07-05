namespace Quantum.QFT
{
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
	open Microsoft.Quantum.Extensions.Math;
	open Microsoft.Quantum.Extensions.Convert;

	// Check a qubit is in the expected state
    operation AssertState (register: Qubit[], desiredState : Result) : () {
        body {
            Assert([PauliZ], register, desiredState, $"Expecting the qubit to be in the {desiredState} state");
        }
	}

	// Three-qubit QFT algorithm (only works for the |101> state)
    operation QFTThreeQubit101 () : ()
    {
        body
        {
            using (register = Qubit[3]) {

				// Allocate qubits
				let q1 = register[0];
				let q2 = register[1];
				let q3 = register[3];

				// Set initial state of qubits to |101>
				X(q1);
				X(q3);

				// Check the qubits are in the state we are expecting
				AssertState([q1;q3], One);
				AssertState([q2], Zero);

				// Do the QFT
				H(q1);
				T(q1);

				H(q2);
				S(q2);

				H(q3);

				SWAP(q1, q3);

				// Reset qubits allocated by this operation
				ResetAll(register);
			}
        }
    }

	// General algorithm for three-qubit QFT
	// For more information on Adjoint & Controlled operators, see the Functors documentation:
	// https://docs.microsoft.com/en-us/quantum/quantum-qr-typemodel?view=qsharp-preview#operation-and-function-types
	operation QFTThreeQubitGeneral (q1 : Qubit, q2 : Qubit, q3 : Qubit) : ()
    {
        body
        {
			H(q1);
            (Controlled S)([q2], q1);
			(Controlled T)([q3], q1);

			H(q2);
			(Controlled S)([q3], q2);

			H(q3);

			SWAP(q1, q3);
        }
    }

	// Even more general algorithm making use of the Rotation operation RFrac instead of the S & T gates
	// RFrac docs: https://docs.microsoft.com/en-us/qsharp/api/prelude/microsoft.quantum.primitive.rfrac?view=qsharp-preview
	operation QFTThreeQubitGeneralR (q1 : Qubit, q2 : Qubit, q3 : Qubit) : ()
    {
        body
        {
			H(q1);
			// R_2 rotation operator
            (Controlled RFrac)([q2], (PauliZ, 2, 2, q1));
			//R_3 rotation operator
			(Controlled RFrac)([q3], (PauliZ, 2, 3, q1));

			H(q2);
			// R_2 rotation operator
            (Controlled RFrac)([q3], (PauliZ, 2, 2, q2));

			H(q3);

			SWAP(q1, q3);
        }
    }

	// General algorithm for n-qubit QFT
	operation QFTNQubit (register : Qubit[]) : ()
    {
        body
        {
			let numQubits = Length(register);

			// Loop over all our qubits
            for (i in 0..numQubits - 1) {

				// First step is always to apply the Hadamard. This happens to all our qubits.
				H(register[i]);
				
				// Next, we repeatedly apply the rotation operator. 
				// Qubits later in the register have fewer rotations applied as can be seen from the circuit diagram.
				// When numQubits - i < 2, the for loop doesn't run and therefore only the Hadamard is applied to 
				// the last qubit.
				for (j in 2..numQubits - i) {
					(Controlled RFrac)([register[j-1]], (PauliZ, 2, j, register[i]));
				}
			} 

			// SWAP each opposite pair of qubits to complete the final step
			// numQubits/2 will always round towards zero so we don't need to use a floor function in case of odd numQubits
			for (k in 0..numQubits/2 - 1)) {
				SWAP(register[k], register[numQubits - 1 - k]);
			}
        }
    }
}
