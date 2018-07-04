namespace QFT
{
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;

	// Check a qubit is in the expected state
    operation AssertState (register: Qubit[], desiredState : Result) : () {
        body {
            Assert([PauliZ], register, desiredState, "Expecting the qubit to be in the {desiredState} state");
        }
	}

    operation ThreeQubitQFT101 () : ()
    {
        body
        {

        }
    }

	operation ThreeQubitQFTGeneral (q1 : Qubit, q2 : Qubit, q3 : Qubit) : ()
    {
        body
        {
            
        }
    }

	operation QFT (qubits : Qubit[]) : ()
    {
        body
        {
            
        }
    }
}
