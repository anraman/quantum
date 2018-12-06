// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.


using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Microsoft.Quantum.Samples.DatabaseSearch
{
    class Program
    {
        public static void Pause()
        {
            System.Console.WriteLine("\nPress any key to continue...\n");
            System.Console.Read();
        }

        static void Main(string[] args)
        {

            #region Simulator Setup

            // We begin by defining a quantum simulator to be our target
            // machine.
            var sim = new QuantumSimulator(throwOnReleasingQubitsNotInZeroState: true);

            #endregion

            #region Random (Classical) Database Search

            // Let us investigate the success probability of classical random search.
            // This corresponds to the case where we only prepare the start state, and
            // do not perform any Grover iterations to amplify the marked subspace
            var nIterations = 0;

            // We now define the size `N` = 2^n of the database to search in terms of 
            // number of qubits `n`
            var nDatabaseQubits = 6;

            // 2^6 = 64
            var databaseSize = Math.Pow(2.0, nDatabaseQubits);

            // We now execute the classical random search.
            // Repeat 1000 times to collect enough data.
            var repeats = 1000;
            var successCount = 0;

            Console.Write(
                $"Classical random search for marked element in database. No Grover iterations performed hence no amplitude amplification.\n" +
                $"  Database size: {databaseSize}\n" +
                $"  Looking for marked element: One One One One One One\n\n");



            foreach (var idxAttempt in Enumerable.Range(0, repeats))
            {
                // Each operation has a static method called Run which takes a simulator as
                // an argument, along with all the arguments defined by the operation itself.  
                var task = ApplyQuantumSearch.Run(sim, nIterations, nDatabaseQubits);

                // We extract the return value of the operation by getting the Results property.
                var data = task.Result;

                // Extract the marked qubit state
                var markedQubit = data.Item1;
                var databaseRegister = data.Item2.ToArray();

                successCount += markedQubit == Result.One ? 1 : 0;

                // Print the results of the search every 100 attempts
                if ((idxAttempt + 1) % 100 == 0)
                {
                    var success = false;

                    if (markedQubit == Result.One)
                    {
                        success = true;
                    }

                    Console.Write(
                        $"Attempt: {idxAttempt}. " +
                        $"Success: {success}. " +
                        $"Probability: {Math.Round((double)successCount / ((double)idxAttempt + 1), 3)}. " +
                        $"Found database index: {string.Join(", ", databaseRegister.Select(x => x.ToString()).ToArray())} \n");
                }
            }
            Console.Write($"\nTotal success count over {repeats} attempts: {successCount}.\n");

            //Pause();

            #endregion

            #region Quantum Database Search

            // Let us investigate the success probability of the quantum search.

            // Wedefine the size `N` = 2^n of the database to searched in terms of 
            // number of qubits `n`. 
            nDatabaseQubits = 6;
            databaseSize = Math.Pow(2.0, nDatabaseQubits);

            // We now perform Grover iterates to amplify the marked subspace.
            nIterations = 3;

            // Number of queries to database oracle.
            var queries = nIterations * 2 + 1;

            // We now execute the quantum search.
            repeats = 1000;
            successCount = 0;
            
            Console.Write(
                $"\nQuantum search for marked element in database. Number of Grover iterations: {nIterations}\n" +
                $"  Database size: {databaseSize}\n" +
                $"  Looking for marked element: One One One One One One\n\n");



            foreach (var idxAttempt in Enumerable.Range(0, repeats))
            {
                // Each operation has a static method called Run which takes a simulator as
                // an argument, along with all the arguments defined by the operation itself.  
                var task = ApplyQuantumSearch.Run(sim, nIterations, nDatabaseQubits);

                // We extract the return value of the operation by getting the Results property.
                var data = task.Result;

                // Extract the marked qubit state
                var markedQubit = data.Item1;
                var databaseRegister = data.Item2.ToArray();

                successCount += markedQubit == Result.One ? 1 : 0;

                // Print the results of the search every 10 attemps
                if ((idxAttempt + 1) % 100 == 0)
                {
                    var success = false;

                    if (markedQubit == Result.One)
                    {
                        success = true;
                    }

                    Console.Write(
                        $"Attempt: {idxAttempt}. " +
                        $"Success: {success}.  " +
                        $"Found database index: {string.Join(", ", databaseRegister.Select(x => x.ToString()).ToArray())} \n");
                }
            }

            Console.Write($"\nTotal success count over {repeats} attempts: {successCount}.\n");

            Pause();

            #endregion
        }
    }
}
