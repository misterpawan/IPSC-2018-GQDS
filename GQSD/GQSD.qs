namespace Quantum.GQSD {
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Extensions.Convert;
    open Microsoft.Quantum.Extensions.Math;
    open Microsoft.Quantum.Canon;

    operation DatabaseOracle(markedQubit: Qubit, databaseRegister: Qubit[]) : () {
        body {
            (Controlled X)(databaseRegister, markedQubit);
        }
        adjoint auto
    }


    operation UniformSuperpositionOracle(databaseRegister: Qubit[]) : () {
        body {
            let nQubits = Length(databaseRegister);
            for (idxQubit in 0..nQubits - 1) {
                H(databaseRegister[idxQubit]);
            }
        }
        adjoint auto
    }

	
    operation StatePreparationOracle(markedQubit: Qubit, databaseRegister: Qubit[]) : () {
        body {
            UniformSuperpositionOracle(databaseRegister);
            DatabaseOracle(markedQubit, databaseRegister);
        }

        adjoint auto
    }

    
    operation ReflectMarked(markedQubit : Qubit) : (){
        body {
            R1(PI(), markedQubit);
        }
    }

	
    operation ReflectZero(databaseRegister : Qubit[]) : () {
        body {
            let nQubits = Length(databaseRegister);
            for(idxQubit in 0..nQubits-1){
                X(databaseRegister[idxQubit]);
            }
            (Controlled Z)(databaseRegister[1..nQubits-1], databaseRegister[0]);
            for(idxQubit in 0..nQubits-1){
                X(databaseRegister[idxQubit]);
            }
        }
    }

	
    operation ReflectStart(markedQubit : Qubit, databaseRegister: Qubit[]) : () {
        body {
            (Adjoint StatePreparationOracle)(markedQubit,databaseRegister);
            ReflectZero([markedQubit] + databaseRegister);
            StatePreparationOracle(markedQubit,databaseRegister);
        }
    }


    operation ApplyQuantumSearch(nIterations : Int, nDatabaseQubits : Int) : (Result, Result[]) {
        body{
			
            mutable resultSuccess = Zero;
            mutable resultElement = new Result[nDatabaseQubits];
            
            using (qubits = Qubit[nDatabaseQubits+1]) {
                
                let markedQubit = qubits[0];
                let databaseRegister = qubits[1..nDatabaseQubits];
				
				StatePreparationOracle(markedQubit, databaseRegister);
				for(idx in 0..nIterations-1){
					ReflectMarked(markedQubit);
					ReflectStart(markedQubit, databaseRegister);
				}

                set resultSuccess = M(markedQubit);
                set resultElement = MultiM(databaseRegister);

                if (resultSuccess == One) {
                    X(markedQubit);
                }
                for (idxResult in 0..nDatabaseQubits - 1) {
                    if (resultElement[idxResult] == One) {
                        X(databaseRegister[idxResult]);
                    }
                }
            }

            return (resultSuccess, resultElement);
        }
    }

}
