

//----------------------------------------
//Master do file
//----------------------------------------

//This do file sets up the Stata code with working directories and macros. 
//It also runs the running do files which prepare all necessary results.  
//Running this do file produces the full set results from start to finish. 


//----------------------------------------
//Step 1: setup 
//----------------------------------------

set more off 
clear all

*(i)* Working directories by user

	if "`c(username)'"=="...[Gabriel computer name]..." { 				// Gabriel
		global root "/Users/...[Gabriel P&D Dropbox name].../Dropbox\EUTO\09. Atlas of Offshore World\08. profit shifting\stata-project-profit-shifting"									
	}

	else if "`c(username)'" == "...[Ludvig computer name]..." {			// Ludvig
		global root "/Users/...[Ludvig Dropbox name].../Dropbox\EUTO\09. Atlas of Offshore World\ 08. profit shifting\stata-project-profit-shifting"	
	}

			
	else if "`c(username)'"=="i.gidron" { 								// Idann		
		global root "C:\Users\i.gidron\Dropbox\EUTO\09. Atlas of Offshore World\08. profit shifting\stata-project-profit-shifting"
	}
	
			
cd "$root"
			
			
*(ii)* Macro do files
global code "$root/code"

*(iii)* Macro raw data files
global rawdata "$root/raw-data"

*(iv)* Macro work-in-progress files
global work "$root/work-data"


//----------------------------------------
//Step 2: install packages 
//----------------------------------------

cd "$code"
*do "0b-install-packages"


//----------------------------------------
//Step 3: generate additional macros 
//----------------------------------------

cd "$code"

*foreach i in 2016 2017 2018 2019 2020 2021 2022 {		//analysis done for the years 2016-2022

foreach i in 2022{ 		//set this instead of the line above for a one-year analysis
	
												
//(i)// Macro year

global temp =`i'

//(ii)// Macro exchange rates


//USD-EUR
if $temp == 2016 {
	global USD_EUR = 0.904			//rates as reported  in https://www.irs.gov/individuals/international-taxpayers/yearly-average-currency-exchange-rates
	}
if $temp == 2017 {
	global USD_EUR = 0.923
}
if $temp == 2018 {
	global USD_EUR = 0.848
}
 if $temp == 2019 {
 	global USD_EUR = 0.893
 }
 if $temp == 2020 {
 	global USD_EUR = 0.877
 }
 if $temp == 2021 {
 	global USD_EUR = 0.846
 }
 if $temp == 2022 {
 	global USD_EUR = 0.951
 }

//USD-SGP
if $temp == 2016 {
	global SGP_USD = 1.382			//rates as reported  in https://www.irs.gov/individuals/international-taxpayers/yearly-average-currency-exchange-rates
	}
if $temp == 2017 {
	global SGP_USD = 1.437
}
if $temp == 2018 {
	global SGP_USD = 1.349
}
 if $temp == 2019 {
 	global SGP_USD = 1.364
 }
 if $temp == 2020 {
 	global SGP_USD = 1.379
 }
 if $temp == 2021 {
 	global SGP_USD = 1.344
 } 
 if $temp == 2022 {
 	global SGP_USD = 1.379
 } 
 
//USD-CHF 
 if $temp == 2016 {
	global CHF_USD = 0.985			//rates as reported  in https://www.irs.gov/individuals/international-taxpayers/yearly-average-currency-exchange-rates
	}
if $temp == 2017 {
	global CHF_USD = 0.984
}
if $temp == 2018 {
	global CHF_USD = 0.979
}
 if $temp == 2019 {
 	global CHF_USD = 0.994
 }
 if $temp == 2020 {
 	global CHF_USD = 0.939
 }
 if $temp == 2021 {
 	global CHF_USD = 0.914
 } 
 if $temp == 2022 {
 	global CHF_USD = 0.955
 } 

//(iii)// world GDP growth rate relative to 2015 (see raw data file "world growth rates.xlsx")

if $temp == 2016 {
	global world_growth = 1.025710000
	}
if $temp == 2017 {
	global world_growth = 1.092166239
}
if $temp == 2018 {
	global world_growth = 1.160024952
}
 if $temp == 2019 {
 	global world_growth = 1.176464406
 }
 if $temp == 2020 {
 	global world_growth = 1.142764849
 }
 if $temp == 2021 {
 	global world_growth = 1.307906936	
 }
 if $temp == 2022 {
 	global world_growth = 1.352835936	
 }


//----------------------------------------
//Step 4: run data transformation do files  
//----------------------------------------
cd "$code"

*do "0c-download-raw-data"				//downloads raw data from statistical agencies	
*do "0d-compute-profit-shifting"			//computes profit shifting estimates from raw data
*do "0e-compute-reallocated-profits"		//allocates profits to source country
*do "0f-order-data-for-Atlas"			//reorders the data for the Atlas
do "0g-graphs"							//graphs
*do "0i-build-summary-stat-table"		//builds a summary statistics table
	


}



//CHECK LIST BEFORE STARTING NEW YEAR OF ANALYSIS
// update macros in master do
// bulk download BOP time series in rawdata
// download US outwards FATS for most recent year
// update Wright_Zucman to most recent year of analysis (so far assumed to be same as 2020)
// update SGP and CHN net investment positions data
// update Imputed DI income using stocks in table B10 (so far assumed to be same as 2015)
// update data for Eurostat personel cost (so far beyond 2020 is assumed same as 2020)
// update Swiss Data for Discrepancy lost Swuss exports, share of total exports (so far assumed same as 2015)

//list of assumptions/changes to the data
//NLD, IRL, LUX 
//FDI stock data 
// Eurostat personnel data 
// Swiss disc data 
// Wright-Zucman data 