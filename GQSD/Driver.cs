using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;
using System;
using System.Linq;

namespace Quantum.GQSD
{
    class Program
    {

        static void Main(string[] args)
        {
            var sim = new QuantumSimulator(throwOnReleasingQubitsNotInZeroState: true);
            Console.Write("Enter the number of bits in the system (Less than 6):\n");
            var nDatabaseQubits = int.Parse(Console.ReadLine());
            if(nDatabaseQubits>6)
            {
                Console.WriteLine("Input greater than 6. Value defaulted to 6.");
                nDatabaseQubits = 6;
            }
            Console.Write($"N: {nDatabaseQubits}");
            var databaseSize = Math.Pow(2.0, nDatabaseQubits);
            var nIterations = (int)Math.Floor(Math.PI * 1 / (Math.Asin(Math.Sqrt(1 / databaseSize))) / 4);

            var queries = nIterations * 2 + 1;

            var classicalSuccessProbability = 1.0 / databaseSize;
            var quantumSuccessProbability = Math.Pow(Math.Sin((2.0 * (double)nIterations + 1.0) * Math.Asin(1.0 / Math.Sqrt(databaseSize))), 2.0);
            var repeats = 100;
            var successCount = 0;

            Console.Write(
                $"\n\nQuantum search for marked element in database.\n" +
                $"  Database size: {databaseSize}.\n" +
                $"  Classical success probability: {classicalSuccessProbability}\n" +
                $"  Quantum success probability: {quantumSuccessProbability}\n\n");



            foreach (var idxAttempt in Enumerable.Range(0, repeats))
            {
                var task = ApplyQuantumSearch.Run(sim, nIterations, nDatabaseQubits);

                var data = task.Result;

                var markedQubit = data.Item1;
                var databaseRegister = data.Item2.ToArray();

                successCount += markedQubit == Result.One ? 1 : 0;

                if ((idxAttempt + 1) % 10 == 0)
                {
                    var empiricalSuccessProbability = Math.Round((double)successCount / ((double)idxAttempt + 1), 3);
                    
                    var speedupFactor = Math.Round(empiricalSuccessProbability / classicalSuccessProbability / (double)queries, 3);

                    Console.Write(
                        $"Attempt {idxAttempt+1}. " +
                        $"Success: {markedQubit},  " +
                        $"Probability: {empiricalSuccessProbability} " +
                        $"Speedup: {speedupFactor} " +
                        $"Found database index {string.Join(", ", databaseRegister.Select(x => x.ToString()).ToArray())} \n");
                }
            }

            System.Console.WriteLine("\n\nPress any key to continue...\n");
            System.Console.ReadKey();

        }
    }
}
