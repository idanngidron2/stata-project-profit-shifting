//----------------------------------------
//Profit shifting do file
//----------------------------------------

//----------------------------------------
//Purpose of the do file
//----------------------------------------

//Downloads raw data from statistical agencies. 
//Transforms the data in the formats adequate for computations.  
//Saves transformed data in Stata files.


//----------------------------------------
//Step 1: BOP statistcs from IMF 
//----------------------------------------
	
//IMF BOP data is used to calculate the FDI income of countries
//It is used in the second part of the analysis to identify high-risk exports
//Also used in the first part to correct the global imbalance in FDI statistics 	
/*

	cd "$code"
	do "IMFs BOP data" 
	


//----------------------------------------
//Step 2: Tax statistics from UNU-WIDER 
//----------------------------------------	

//UNU-WIDER data includes corporate tax revenues, growth rates, and risky exports
//Corporate tax and growth rates are used in various instances in computations
//high risk exports complement Eurostat FDI data used for reallocating profits

	
	cd "$code"
	do "WBdata"					//downloads GDP and depreciation by country
	do "UN corp tax data" 		//downloads corporate tax revenues data
	do "GDPgrowthrates" 		//structures GDP data for subsequent use
	do "highriskexports" 		//downloads high risk exports for SGP, HKG, CHE and the world


//----------------------------------------
//Step 3: OECD data
//----------------------------------------	

//This data is used to calculate the corporate profits in OECD countries 
//the do files also derives FDI income of operating units in OECD countries
//FDI data is used to analyse imbalances in global FDI statistics for OECD countries


	cd "$code"
	do "FDI equity income operating units"	//downloads OECD BOP data and calculates the equity FDI income of operating units in OECD countries. Imputations are done when no data is available

	do "OECD BOP disc"						//computes the FDI income of countries + the mirror reports + the discrepancies for investee and investor reports in OECD countries 
	do "OECD Table 14a" 					//downloads OECD table 14a and computes the taxable profits of corporations in OECD countries and some major economies


//----------------------------------------
//Step 4: Eurostat service data
//----------------------------------------	

//This data is used to calculate the high risk imports of each country => the main allocation key in our benchmark scenario	
//Our version of the bulk download of eurostat main tables are attached  - if you want to replicate our findings precisely you shouldn't replace our master data in the following but just run the from the first do "non EU - debit" 

	cd "$code"
*	do "Eurostat services bulk download"
	
//In the following we create excel tables of available data + impute data whenever this is not available => imputations following strictly logical bookkeeping rules
//Variables are described by labels if this does not suffice, please read the eurostat documentation.
//Note in all the following that geo=reporting country (oppossed to partner)
//"Imports" is used to describe the value of each transaction in the following whether or not the reporting country is exporting/importing 
//"Dodgy" is the name we use for "high risk service payments" in the following see Appendix.pdf for an explanation of "high risk service payments" 

//begin here if you don't want to update data//

	do "non EU - debit" 			// the dofile that handles (including imputations) service debit data from non-EU (EU countries importing from non-EU countries)
	do "non EU - credit" 			// the dofile that handles (including imputations) service credit data from non-EU (EU countries importing from non-EU countries)
	do "Internal EU - credit" 		// the dofile that handles (including imputations) service credit data from EU (EU countries importing from EU countries)
*	do "EU - service discrepancies" // the dofile that calculates credit/debit discrepancies in EU to EU transactions





//----------------------------------------
//Step 5: Eurostat FDI data
//----------------------------------------


//This data is used to calculate the high risk imports of each country => the main allocation key in our benchmark scenario 
//Also used to calculate the dividend income of EU tax havens
//Our version of the bulk download of eurostat main tables are attached  - if you want to replicate our findings precisely you shouldn't replace our master data in the following but just run from the dofile "Div & Int EU (DO & DI) CRE"

//if you wish to update data:

//Downloading data: Install 7-zip here: C:\Program Files\7-Zip\7zG.exe to proceed from 7-zip.org 



	cd "$code"
	do "Eurostat FDI income bulk download"		
*/	do "Generating basic"

//In the following we create excel tables of available data + impute data whenever this is not available => imputations following strictly logical bookkeeping rules
//A small stata file "fdikeys.dta" is also used in the following (and included in the TWZ2018Programs.zip) - The file contains the total FDI income credited to rest of the world for EU countries.
//Variables are described by labels if this does not suffice, please read the eurostat documentation.
//Note in all the following that geo=reporting country (oppossed to partner)

//begin here if you don't want to update data

	cd "$code"
	do "Ireland mirror data" 			//NEEDS TO BE RUN FIRST - do-file that create mirror data reports for Ireland as they only report net-values to eurostat
	do "Div & Int EU (DO & DI) CRE" 	//the dofile that handles FDI income credit data where both parties are EU countries
	do "Div & Int EU (DO & DI) DEB"		//the dofile that handles FDI income debit data where both parties are EU countries
	do "Div & Int Non EU (DO & DI) CRE"	//the dofile that handles FDI income credit data where an EU country is the creditor and a non-EU country is the debitor
	do "Div & Int Non EU (DO & DI) DEB"	//the dofile that handles FDI income debit data where an EU country is the debitor and a non-EU country is the creditor

//the following files calculate the discrepancies in investor/investee FDI income reported 
	
	cd "$code"
	do "FDI income disc within EU" 
	do "FDI income mirroring EU vs non-EU" 
	do "FDI income mirroring_nonEU" 

/*
//----------------------------------------
//Step 6: US FATS data
//----------------------------------------

// here we download US outward foreign affiliate statistics data 
// used to compute the profit/wage ratio for affiliates of US multinationals outside the US	

	cd "$code"
	do "US outward FATS"	// used to compute the profit/wage ratio for affiliates of US multinationals outside the US	


//----------------------------------------
//Step 7: Erase unnecessary data
//----------------------------------------

// in this final step we erase the working files that are unnessary for further
// steps in the analysis. 


	cd "$code"
	do "erase data" 	// do file to erase unnecessary data files.
