//--------------------------------------------------//
//Compute profit shifting do file			
//--------------------------------------------------//


//These do files uses data from statistical agencies downloaded and structured in "0c-download-raw-data"
//The values are used to build the Global profits shifted table
//This output shows the profits attracted per tax haven country 

//---------------------------------------------//
//Step 1: Tables B11 and B10
//---------------------------------------------//

//Table B10 needs be run first
//This table updates and structures direct investment income data

	cd "$code"
	do "Table B11"
	do "Table B10"
//---------------------------------------------//
//Step 2: Table U1
//---------------------------------------------//	

//Table U1 estimates global profits shifted

	cd "$code"
	do "Table U1"













