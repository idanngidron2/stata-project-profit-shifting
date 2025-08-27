//--------------------------------------------------//
//Compute reallocated profits		
//--------------------------------------------------//


//These do files uses profit shifting estimates from "0d-compute-profit-shifting"
//The values are reallocated to source countries using data on cross-border transactions
//This output shows the profits shifted away per losing country 

//---------------------------------------------//
//Step 1: 
//---------------------------------------------//



	cd "$code"

	do "Table C1"
	do "Table C2"
	
*	do "Table C3"
	do "Table C4"

	do "Table C4b"
	do "Table C4c"

	do "Table C4d"

	do "graphs_reallocated_profits"
	
	cd "$code"	












