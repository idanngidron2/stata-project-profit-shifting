// -------------------------- // 
// Data for tooltip 
// -------------------------- // 


//This do file prepares the data for the Atlas tooltip
//Implying it runs the code to disaggregate profit losses and tax losses from each 
//source country to several tax havens, including EU tax havens, Switzerland, 
//and the remaining tax havens separately 

// We start from importing the data from table C4 which is the main source 
// for this exercise: table C4 includes profits shifted from each source country 
// to the group of tax haven countries 


// ----------------------------------------- //
// Step 0: import data for 2015 from TWZ 
// ----------------------------------------- //

//the estimates for 2015 are imported directly from the TWZ results


import excel "$rawdata/TWZ_original_results_2015.xlsx", firstrow sheet("TableC4") cellrange("B8:M90") clear
isocodes B, gen(iso3c)

//remove tax havens 

* Define the list of isocodes to keep
local isocodes "AUS AUT CAN CHL CZE DEU DNK ESP EST FIN FRA GBR GRC HUN ISL ISR ITA JPN KOR LVA MEX NOR NZL POL PRT SVK SVN SWE TUR USA BRA CHN COL CRI IND RUS ZAF ARG EGY MYS NGA THA URY VEN NHT ROW WLD"

* Create a temporary variable to mark the isocodes to keep
gen keep = 0
foreach iso in `isocodes' {
    replace keep = 1 if iso3c == "`iso'"
}

* Keep only the rows with the specified isocodes
keep if keep == 1

* Drop the temporary variable
drop keep

tempfile tf 
save `tf', replace 

//import corporate tax revenue
import excel "$rawdata/TWZ_original_results_2015.xlsx", firstrow sheet("TableC4d") cellrange("B8:M90") clear
isocodes B, gen(iso3c)

//remove tax havens 

* Define the list of isocodes to keep
local isocodes "AUS AUT CAN CHL CZE DEU DNK ESP EST FIN FRA GBR GRC HUN ISL ISR ITA JPN KOR LVA MEX NOR NZL POL PRT SVK SVN SWE TUR USA BRA CHN COL CRI IND RUS ZAF ARG EGY MYS NGA THA URY VEN NHT ROW WLD"

* Create a temporary variable to mark the isocodes to keep
gen keep = 0
foreach iso in `isocodes' {
    replace keep = 1 if iso3c == "`iso'"
}

* Keep only the rows with the specified isocodes
keep if keep == 1

* Drop the temporary variable
drop keep


rename C corptaxrev 
rename D STR 

keep iso3c corptaxrev STR 
tempfile tf1 
save `tf1', replace 

use `tf', clear 
merge 1:1 iso3c using `tf1', nogen 
gen group = ""
rename iso3c ISO3 
rename Allhavens All_havens
rename EUhavens EU_havens
rename NonEUtaxhavens Non_EU_havens

save "$work/Atlas_tooltip_2015_workdata.dta", replace 





// prepare subfiles by counterpart-indicator 

// ---------------------------- // 
// Step 1: profits shifted 
// ---------------------------- // 

if $temp == 2022 {

foreach i in 2015 2016 2017 2018 2019 2020 2021	2022{		//analysis done for the years 2015-2022
*foreach i in 2015{
local temp =`i'


if `temp' > 2015 {
	use "$work/table_C4_`temp'", clear 
}

if `temp' == 2015 {
	use "$work/Atlas_tooltip_2015_workdata", clear
}

//1) counterpart Belgium 

// remove tax haven countries 
drop if group == "OECD_TH"

keep ISO3 Belgium 

gen year = `temp'

gen indicator = ""
replace indicator = "profits_shifted"

gen counterpart = ""
replace counterpart = "Belgium"

rename Belgium value 
replace value = value /1000 	//USD mln to USD bln 

rename ISO3 iso3 
order iso3 indicator value counterpart year

tempfile bel 
save `bel', replace 



//2) counterpart Cyprus

if `temp' > 2015 {
	use "$work/table_C4_`temp'", clear 
}

if `temp' == 2015 {
	use "$work/Atlas_tooltip_2015_workdata", clear
}


// remove tax haven countries 
drop if group == "OECD_TH"

keep ISO3 Cyprus 

gen year = `temp'

gen indicator = ""
replace indicator = "profits_shifted"

gen counterpart = ""
replace counterpart = "Cyprus"

rename Cyprus value 
replace value = value /1000 	//USD mln to USD bln 

rename ISO3 iso3 
order iso3 indicator value counterpart year

tempfile cyp 
save `cyp', replace 

//3) counterpart Ireland

if `temp' > 2015 {
	use "$work/table_C4_`temp'", clear 
}

if `temp' == 2015 {
	use "$work/Atlas_tooltip_2015_workdata", clear
}


// remove tax haven countries 
drop if group == "OECD_TH"

keep ISO3 Ireland 

gen year = `temp'

gen indicator = ""
replace indicator = "profits_shifted"

gen counterpart = ""
replace counterpart = "Ireland"

rename Ireland value 
replace value = value /1000 	//USD mln to USD bln 

rename ISO3 iso3 
order iso3 indicator value counterpart year

tempfile irl 
save `irl', replace 

//4) counterpart Luxembourg

if `temp' > 2015 {
	use "$work/table_C4_`temp'", clear 
}

if `temp' == 2015 {
	use "$work/Atlas_tooltip_2015_workdata", clear
}


// remove tax haven countries 
drop if group == "OECD_TH"

keep ISO3 Luxembourg 

gen year = `temp'

gen indicator = ""
replace indicator = "profits_shifted"

gen counterpart = ""
replace counterpart = "Luxembourg"

rename Luxembourg value 
replace value = value /1000 	//USD mln to USD bln 

rename ISO3 iso3 
order iso3 indicator value counterpart year

tempfile lux 
save `lux', replace 

//5) counterpart Malta

if `temp' > 2015 {
	use "$work/table_C4_`temp'", clear 
}

if `temp' == 2015 {
	use "$work/Atlas_tooltip_2015_workdata", clear
}


// remove tax haven countries 
drop if group == "OECD_TH"

keep ISO3 Malta 

gen year = `temp'

gen indicator = ""
replace indicator = "profits_shifted"

gen counterpart = ""
replace counterpart = "Malta"

rename Malta value 
replace value = value /1000 	//USD mln to USD bln 

rename ISO3 iso3 
order iso3 indicator value counterpart year

tempfile mlt 
save `mlt', replace 

//6) counterpart Netherlands

if `temp' > 2015 {
	use "$work/table_C4_`temp'", clear 
}

if `temp' == 2015 {
	use "$work/Atlas_tooltip_2015_workdata", clear
}


// remove tax haven countries 
drop if group == "OECD_TH"

keep ISO3 Netherlands 

gen year = `temp'

gen indicator = ""
replace indicator = "profits_shifted"

gen counterpart = ""
replace counterpart = "Netherlands"

rename Netherlands value 
replace value = value /1000 	//USD mln to USD bln 

rename ISO3 iso3 
order iso3 indicator value counterpart year

tempfile nld 
save `nld', replace 

//7) counterpart Switzerland

if `temp' > 2015 {
	use "$work/table_C4_`temp'", clear 
}

if `temp' == 2015 {
	use "$work/Atlas_tooltip_2015_workdata", clear
}


// remove tax haven countries 
drop if group == "OECD_TH"

keep ISO3 Switzerland 

gen year = `temp'

gen indicator = ""
replace indicator = "profits_shifted"

gen counterpart = ""
replace counterpart = "Switzerland"

rename Switzerland value 
replace value = value /1000 	//USD mln to USD bln 

rename ISO3 iso3 
order iso3 indicator value counterpart year

tempfile che 
save `che', replace 

//8) counterpart Rest

if `temp' > 2015 {
	use "$work/table_C4_`temp'", clear 
}

if `temp' == 2015 {
	use "$work/Atlas_tooltip_2015_workdata", clear
}


// remove tax haven countries 
drop if group == "OECD_TH"

keep ISO3 Rest 

gen year = `temp'

gen indicator = ""
replace indicator = "profits_shifted"

gen counterpart = ""
replace counterpart = "Rest"

rename Rest value 
replace value = value /1000 	//USD mln to USD bln 

rename ISO3 iso3 
order iso3 indicator value counterpart year

tempfile rest 
save `rest', replace 


//9) counterpart EU havens

if `temp' > 2015 {
	use "$work/table_C4_`temp'", clear 
}

if `temp' == 2015 {
	use "$work/Atlas_tooltip_2015_workdata", clear
}


// remove tax haven countries 
drop if group == "OECD_TH"

keep ISO3 EU_havens 

gen year = `temp'

gen indicator = ""
replace indicator = "profits_shifted"

gen counterpart = ""
replace counterpart = "EU_Havens"

rename EU_havens value 
replace value = value /1000 	//USD mln to USD bln 

rename ISO3 iso3 
order iso3 indicator value counterpart year

tempfile eu 
save `eu', replace 

//10) counterpart non-EU havens

if `temp' > 2015 {
	use "$work/table_C4_`temp'", clear 
}

if `temp' == 2015 {
	use "$work/Atlas_tooltip_2015_workdata", clear
}


// remove tax haven countries 
drop if group == "OECD_TH"

keep ISO3 Non_EU_havens 

gen year = `temp'

gen indicator = ""
replace indicator = "profits_shifted"

gen counterpart = ""
replace counterpart = "Non_EU_Havens"

rename Non_EU_havens value 
replace value = value /1000 	//USD mln to USD bln 

rename ISO3 iso3 
order iso3 indicator value counterpart year

tempfile noneu 
save `noneu', replace 

//11) counterpart all havens

if `temp' > 2015 {
	use "$work/table_C4_`temp'", clear 
}

if `temp' == 2015 {
	use "$work/Atlas_tooltip_2015_workdata", clear
}


// remove tax haven countries 
drop if group == "OECD_TH"

keep ISO3 All_havens 

gen year = `temp'

gen indicator = ""
replace indicator = "profits_shifted"

gen counterpart = ""
replace counterpart = "World"

rename All_havens value 
replace value = value /1000 	//USD mln to USD bln 

rename ISO3 iso3 
order iso3 indicator value counterpart year

tempfile all 
save `all', replace 


// bring together all counterpart files 

use `bel', clear 
append using `cyp'
append using `irl'
append using `lux'
append using `mlt'
append using `nld'
append using `che'
append using `rest'
append using `eu'
append using `noneu'
append using `all'

save "$work/Atlas_tooltip_profits_shifted_`temp'.dta", replace 




// ---------------------------- // 
// Step 2: tax losses
// ---------------------------- // 

if `temp' >2015 {

use "$work/table_C4_`temp'", clear 

// import country-specific STR and corporate tax revenue


import excel "$rawdata/1980_2023_Corporate_Tax_Rates_Around_the_World_Tax_Foundation", firstrow clear

//source: tax foundation https://taxfoundation.org/data/all/global/corporate-tax-rates-by-country-2023/
//in the following lines we add CIT rates from tax foundation to the list of CIT rates previously used, 
//but for missing countries 

keep iso_3 country y_`temp'
rename iso_3 iso3c 
rename y_`temp' CIT_secondbest
replace CIT_secondbest = "0" if CIT_secondbest == "NA"
destring CIT_secondbest, replace 

tempfile cit 
save `cit', replace

use "$work/CIT rates", clear 
keep iso3c y_`temp' 
merge m:1 iso3c using `cit'

replace y_`temp' = CIT_secondbest if y_`temp'==.
drop CIT_secondbest _merge 

rename iso3c CountryCode

// Merge step2 and step3 

merge m:1 CountryCode using "$work/corptaxrev_comprehensive_`temp'"
drop if _merge ==1
drop _merge

// compute missing statutory rates 

replace y_`temp' = 10 if CountryCode == "KOS"
replace country = "Kosovo" if CountryCode == "KOS"

// destring CIT rates 
*replace y_`temp' = "0" if y_`temp' == "NA"
*destring y_`temp', replace

// keep only countries of the main analysis (this analysis is not done for ROW)

* Define the list of isocodes to keep
local isocodes "AUS AUT CAN CHL CZE DEU DNK ESP EST FIN FRA GBR GRC HUN ISL ISR ITA JPN KOR LVA MEX NOR NZL POL PRT SVK SVN SWE TUR USA BRA CHN COL CRI IND RUS ZAF ARG EGY MYS NGA THA URY VEN NHT ROW WLD"

* Create a temporary variable to mark the isocodes to keep
gen keep = 0
foreach iso in `isocodes' {
    replace keep = 1 if CountryCode == "`iso'"
}

* Keep only the rows with the specified isocodes
keep if keep == 1

* Drop the temporary variable
drop keep


// keep necessary variables 
drop country 
rename CountryCode ISO3 
rename y_`temp' STR 
replace STR = STR/100 

merge 1:1 ISO3 using "$work/table_C4_`temp'"
keep if _merge == 3 
drop _merge 

order ISO3 country EU group STR corptaxrev
save "$work/tooltip_taxloss_working.dta", replace 
}

*-----------------------------------------------------------------------


//1) counterpart Belgium ; tax loss


use "$work/tooltip_taxloss_working.dta", clear 

if `temp' == 2015 {
	use "$work/Atlas_tooltip_2015_workdata.dta", clear
}

gen value = . 
replace value = Belgium * STR 
replace value = value /1000 	//USD mln to USD bln 

gen indicator = ""
replace indicator = "tax_lost"

gen counterpart = ""
replace counterpart = "Belgium"

gen year = `temp' 

rename ISO3 iso3 

keep iso3 indicator value counterpart year 
order iso3 indicator value counterpart year

tempfile bel
save `bel', replace 


//2) counterpart Ireland; tax loss


use "$work/tooltip_taxloss_working.dta", clear 

if `temp' == 2015 {
	use "$work/Atlas_tooltip_2015_workdata.dta", clear
}

gen value = . 
replace value = Ireland * STR 
replace value = value /1000 	//USD mln to USD bln 

gen indicator = ""
replace indicator = "tax_lost"

gen counterpart = ""
replace counterpart = "Ireland"

gen year = `temp' 

rename ISO3 iso3 

keep iso3 indicator value counterpart year 
order iso3 indicator value counterpart year

tempfile irl
save `irl', replace 

//3) counterpart Luxembourg; tax loss


use "$work/tooltip_taxloss_working.dta", clear 

if `temp' == 2015 {
	use "$work/Atlas_tooltip_2015_workdata.dta", clear
}


gen value = . 
replace value = Luxembourg * STR 
replace value = value /1000 	//USD mln to USD bln 

gen indicator = ""
replace indicator = "tax_lost"

gen counterpart = ""
replace counterpart = "Luxembourg"

gen year = `temp' 

rename ISO3 iso3 

keep iso3 indicator value counterpart year 
order iso3 indicator value counterpart year

tempfile lux
save `lux', replace 

//4) counterpart Malta; tax loss


use "$work/tooltip_taxloss_working.dta", clear 

if `temp' == 2015 {
	use "$work/Atlas_tooltip_2015_workdata.dta", clear
}


gen value = . 
replace value = Malta * STR 
replace value = value /1000 	//USD mln to USD bln 

gen indicator = ""
replace indicator = "tax_lost"

gen counterpart = ""
replace counterpart = "Malta"

gen year = `temp' 

rename ISO3 iso3 

keep iso3 indicator value counterpart year 
order iso3 indicator value counterpart year

tempfile mlt
save `mlt', replace 

//5) counterpart Netherlands; tax loss


use "$work/tooltip_taxloss_working.dta", clear 

if `temp' == 2015 {
	use "$work/Atlas_tooltip_2015_workdata.dta", clear
}


gen value = . 
replace value = Netherlands * STR 
replace value = value /1000 	//USD mln to USD bln 

gen indicator = ""
replace indicator = "tax_lost"

gen counterpart = ""
replace counterpart = "Netherlands"

gen year = `temp' 

rename ISO3 iso3 

keep iso3 indicator value counterpart year 
order iso3 indicator value counterpart year

tempfile nld
save `nld', replace 

//6) counterpart Cyprus; tax loss


use "$work/tooltip_taxloss_working.dta", clear 

if `temp' == 2015 {
	use "$work/Atlas_tooltip_2015_workdata.dta", clear
}


gen value = . 
replace value = Cyprus * STR 
replace value = value /1000 	//USD mln to USD bln 

gen indicator = ""
replace indicator = "tax_lost"

gen counterpart = ""
replace counterpart = "Cyprus"

gen year = `temp' 

rename ISO3 iso3 

keep iso3 indicator value counterpart year 
order iso3 indicator value counterpart year

tempfile cyp
save `cyp', replace 

//7) counterpart all havens; tax loss


use "$work/tooltip_taxloss_working.dta", clear 

if `temp' == 2015 {
	use "$work/Atlas_tooltip_2015_workdata.dta", clear
}


gen value = . 
replace value = All_havens * STR 
replace value = value /1000 	//USD mln to USD bln 

gen indicator = ""
replace indicator = "tax_lost"

gen counterpart = ""
replace counterpart = "World"

gen year = `temp' 

rename ISO3 iso3 

keep iso3 indicator value counterpart year 
order iso3 indicator value counterpart year

tempfile wld
save `wld', replace 

//8) counterpart EU havens; tax loss


use "$work/tooltip_taxloss_working.dta", clear 

if `temp' == 2015 {
	use "$work/Atlas_tooltip_2015_workdata.dta", clear
}


gen value = . 
replace value = EU_havens * STR 
replace value = value /1000 	//USD mln to USD bln 

gen indicator = ""
replace indicator = "tax_lost"

gen counterpart = ""
replace counterpart = "EU_Havens"

gen year = `temp' 

rename ISO3 iso3 

keep iso3 indicator value counterpart year 
order iso3 indicator value counterpart year

tempfile eu
save `eu', replace 

//9) counterpart non-EU havens; tax loss


use "$work/tooltip_taxloss_working.dta", clear 

if `temp' == 2015 {
	use "$work/Atlas_tooltip_2015_workdata.dta", clear
}


gen value = . 
replace value = Non_EU_havens * STR 
replace value = value /1000 	//USD mln to USD bln 

gen indicator = ""
replace indicator = "tax_lost"

gen counterpart = ""
replace counterpart = "Non_EU_Havens"

gen year = `temp' 

rename ISO3 iso3 

keep iso3 indicator value counterpart year 
order iso3 indicator value counterpart year

tempfile noneu
save `noneu', replace 


//10) counterpart Switzerland; tax loss


use "$work/tooltip_taxloss_working.dta", clear 

if `temp' == 2015 {
	use "$work/Atlas_tooltip_2015_workdata.dta", clear
}


gen value = . 
replace value = Switzerland * STR 
replace value = value /1000 	//USD mln to USD bln 

gen indicator = ""
replace indicator = "tax_lost"

gen counterpart = ""
replace counterpart = "Switzerland"

gen year = `temp' 

rename ISO3 iso3 

keep iso3 indicator value counterpart year 
order iso3 indicator value counterpart year

tempfile che
save `che', replace 

//11) counterpart Rest; tax loss


use "$work/tooltip_taxloss_working.dta", clear 

if `temp' == 2015 {
	use "$work/Atlas_tooltip_2015_workdata.dta", clear
}


gen value = . 
replace value = Rest * STR 
replace value = value /1000 	//USD mln to USD bln 

gen indicator = ""
replace indicator = "tax_lost"

gen counterpart = ""
replace counterpart = "Rest"

gen year = `temp' 

rename ISO3 iso3 

keep iso3 indicator value counterpart year 
order iso3 indicator value counterpart year

tempfile rest
save `rest', replace 





// bring together all counterpart files 

use `bel', clear 
append using `cyp'
append using `irl'
append using `lux'
append using `mlt'
append using `nld'
append using `che'
append using `rest'
append using `eu'
append using `noneu'
append using `wld'

save "$work/Atlas_tooltip_tax_loss_`temp'.dta", replace 



// ----------------------------------------- // 
// Step 3: tax loss as share of CIT revenue
// ----------------------------------------- // 



//1) counterpart Belgium ; tax loss as share of CIT revenue


use "$work/tooltip_taxloss_working.dta", clear 

if `temp' == 2015 {
	use "$work/Atlas_tooltip_2015_workdata.dta", clear
}


gen value = . 
replace value = Belgium * STR 
replace value = value /1000 	//USD mln to USD bln 
replace value = value/corptaxrev 

gen indicator = ""
replace indicator = "corp_tax_lost"

gen counterpart = ""
replace counterpart = "Belgium"

gen year = `temp' 

rename ISO3 iso3 

keep iso3 indicator value counterpart year 
order iso3 indicator value counterpart year

tempfile bel
save `bel', replace 


//2) counterpart Ireland; tax loss as share of CIT revenue


use "$work/tooltip_taxloss_working.dta", clear 

if `temp' == 2015 {
	use "$work/Atlas_tooltip_2015_workdata.dta", clear
}


gen value = . 
replace value = Ireland * STR 
replace value = value /1000 	//USD mln to USD bln 
replace value = value/corptaxrev 

gen indicator = ""
replace indicator = "corp_tax_lost"

gen counterpart = ""
replace counterpart = "Ireland"

gen year = `temp' 

rename ISO3 iso3 

keep iso3 indicator value counterpart year 
order iso3 indicator value counterpart year

tempfile irl
save `irl', replace 

//3) counterpart Luxembourg; tax loss as share of CIT revenue


use "$work/tooltip_taxloss_working.dta", clear 

if `temp' == 2015 {
	use "$work/Atlas_tooltip_2015_workdata.dta", clear
}


gen value = . 
replace value = Luxembourg * STR 
replace value = value /1000 	//USD mln to USD bln 
replace value = value/corptaxrev 

gen indicator = ""
replace indicator = "corp_tax_lost"

gen counterpart = ""
replace counterpart = "Luxembourg"

gen year = `temp' 

rename ISO3 iso3 

keep iso3 indicator value counterpart year 
order iso3 indicator value counterpart year

tempfile lux
save `lux', replace 

//4) counterpart Malta; tax loss as share of CIT revenue


use "$work/tooltip_taxloss_working.dta", clear 

if `temp' == 2015 {
	use "$work/Atlas_tooltip_2015_workdata.dta", clear
}


gen value = . 
replace value = Malta * STR 
replace value = value /1000 	//USD mln to USD bln 
replace value = value/corptaxrev 

gen indicator = ""
replace indicator = "corp_tax_lost"

gen counterpart = ""
replace counterpart = "Malta"

gen year = `temp' 

rename ISO3 iso3 

keep iso3 indicator value counterpart year 
order iso3 indicator value counterpart year

tempfile mlt
save `mlt', replace 

//5) counterpart Netherlands; tax loss as share of CIT revenue


use "$work/tooltip_taxloss_working.dta", clear 


if `temp' == 2015 {
	use "$work/Atlas_tooltip_2015_workdata.dta", clear
}

gen value = . 
replace value = Netherlands * STR 
replace value = value /1000 	//USD mln to USD bln 
replace value = value/corptaxrev 

gen indicator = ""
replace indicator = "corp_tax_lost"

gen counterpart = ""
replace counterpart = "Netherlands"

gen year = `temp' 

rename ISO3 iso3 

keep iso3 indicator value counterpart year 
order iso3 indicator value counterpart year

tempfile nld
save `nld', replace 

//6) counterpart Cyprus; tax loss as share of CIT revenue


use "$work/tooltip_taxloss_working.dta", clear 

if `temp' == 2015 {
	use "$work/Atlas_tooltip_2015_workdata.dta", clear
}


gen value = . 
replace value = Cyprus * STR 
replace value = value /1000 	//USD mln to USD bln 
replace value = value/corptaxrev 

gen indicator = ""
replace indicator = "corp_tax_lost"

gen counterpart = ""
replace counterpart = "Cyprus"

gen year = `temp' 

rename ISO3 iso3 

keep iso3 indicator value counterpart year 
order iso3 indicator value counterpart year

tempfile cyp
save `cyp', replace 

//7) counterpart all havens; tax loss as share of CIT revenue


use "$work/tooltip_taxloss_working.dta", clear 

if `temp' == 2015 {
	use "$work/Atlas_tooltip_2015_workdata.dta", clear
}


gen value = . 
replace value = All_havens * STR 
replace value = value /1000 	//USD mln to USD bln 
replace value = value/corptaxrev 

gen indicator = ""
replace indicator = "corp_tax_lost"

gen counterpart = ""
replace counterpart = "World"

gen year = `temp' 

rename ISO3 iso3 

keep iso3 indicator value counterpart year 
order iso3 indicator value counterpart year

tempfile wld
save `wld', replace 

//8) counterpart EU havens; tax loss as share of CIT revenue


use "$work/tooltip_taxloss_working.dta", clear 

if `temp' == 2015 {
	use "$work/Atlas_tooltip_2015_workdata.dta", clear
}


gen value = . 
replace value = EU_havens * STR 
replace value = value /1000 	//USD mln to USD bln 
replace value = value/corptaxrev 

gen indicator = ""
replace indicator = "corp_tax_lost"

gen counterpart = ""
replace counterpart = "EU_Havens"

gen year = `temp' 

rename ISO3 iso3 

keep iso3 indicator value counterpart year 
order iso3 indicator value counterpart year

tempfile eu
save `eu', replace 

//9) counterpart non-EU havens; tax loss as share of CIT revenue


use "$work/tooltip_taxloss_working.dta", clear 


if `temp' == 2015 {
	use "$work/Atlas_tooltip_2015_workdata.dta", clear
}


gen value = . 
replace value = Non_EU_havens * STR 
replace value = value /1000 	//USD mln to USD bln 
replace value = value/corptaxrev 

gen indicator = ""
replace indicator = "corp_tax_lost"

gen counterpart = ""
replace counterpart = "Non_EU_Havens"

gen year = `temp' 

rename ISO3 iso3 

keep iso3 indicator value counterpart year 
order iso3 indicator value counterpart year

tempfile noneu
save `noneu', replace 

//10) counterpart Switzerland; tax loss as share of CIT revenue


use "$work/tooltip_taxloss_working.dta", clear 

if `temp' == 2015 {
	use "$work/Atlas_tooltip_2015_workdata.dta", clear
}



gen value = . 
replace value = Switzerland * STR 
replace value = value /1000 	//USD mln to USD bln 
replace value = value/corptaxrev 

gen indicator = ""
replace indicator = "corp_tax_lost"

gen counterpart = ""
replace counterpart = "Switzerland"

gen year = `temp' 

rename ISO3 iso3 

keep iso3 indicator value counterpart year 
order iso3 indicator value counterpart year

tempfile che
save `che', replace 

//10) counterpart Rest; tax loss as share of CIT revenue


use "$work/tooltip_taxloss_working.dta", clear 

if `temp' == 2015 {
	use "$work/Atlas_tooltip_2015_workdata.dta", clear
}


gen value = . 
replace value = Rest * STR 
replace value = value /1000 	//USD mln to USD bln 
replace value = value/corptaxrev 

gen indicator = ""
replace indicator = "corp_tax_lost"

gen counterpart = ""
replace counterpart = "Rest"

gen year = `temp' 

rename ISO3 iso3 

keep iso3 indicator value counterpart year 
order iso3 indicator value counterpart year

tempfile rest
save `rest', replace 



// bring together all counterpart files 

use `bel', clear 
append using `cyp'
append using `irl'
append using `lux'
append using `mlt'
append using `nld'
append using `che'
append using `rest'
append using `eu'
append using `noneu'
append using `wld'

save "$work/Atlas_tooltip_tax_loss_as_share_of_cit_`temp'.dta", replace 



// ---------------------------------------- //
// Step 4: bring together all tooltip files 
// ---------------------------------------- //


if `temp' == 2022 {

	use "$work/Atlas_tooltip_profits_shifted_2015", clear 
	append using "$work/Atlas_tooltip_profits_shifted_2016"
	append using "$work/Atlas_tooltip_profits_shifted_2017"
	append using "$work/Atlas_tooltip_profits_shifted_2018"
	append using "$work/Atlas_tooltip_profits_shifted_2019"
	append using "$work/Atlas_tooltip_profits_shifted_2020"
	append using "$work/Atlas_tooltip_profits_shifted_2021"
	append using "$work/Atlas_tooltip_profits_shifted_2022"
	append using "$work/Atlas_tooltip_tax_loss_2015"
	append using "$work/Atlas_tooltip_tax_loss_2016"
	append using "$work/Atlas_tooltip_tax_loss_2017"
	append using "$work/Atlas_tooltip_tax_loss_2018"
	append using "$work/Atlas_tooltip_tax_loss_2019"
	append using "$work/Atlas_tooltip_tax_loss_2020"
	append using "$work/Atlas_tooltip_tax_loss_2021"
	append using "$work/Atlas_tooltip_tax_loss_2022"
	append using "$work/Atlas_tooltip_tax_loss_as_share_of_cit_2015"
	append using "$work/Atlas_tooltip_tax_loss_as_share_of_cit_2016"
	append using "$work/Atlas_tooltip_tax_loss_as_share_of_cit_2017"
	append using "$work/Atlas_tooltip_tax_loss_as_share_of_cit_2018"
	append using "$work/Atlas_tooltip_tax_loss_as_share_of_cit_2019"
	append using "$work/Atlas_tooltip_tax_loss_as_share_of_cit_2020"
	append using "$work/Atlas_tooltip_tax_loss_as_share_of_cit_2021"
	append using "$work/Atlas_tooltip_tax_loss_as_share_of_cit_2022"
	
	save "$work/Atlas_tooltip_allyears.dta", replace 
	export excel using "$root/output/Atlas_tooltip_allyears.xlsx", firstrow(var) sheet("Tooltip all years", replace) keepcellfmt 

	
	}


}
}

// step 5: create table with corporate tax rates for tax havens 

use "$work/shifted_profits_U1_2016", clear
keep if tax_haven == 1
keep ISO3 corporate_ETR corptaxrev
gen year = 2016 

tempfile tf 
save `tf', replace

use "$work/shifted_profits_U1_2017", clear
keep if tax_haven == 1

keep ISO3 corporate_ETR corptaxrev
gen year = 2017 

append using `tf'
save `tf', replace

use "$work/shifted_profits_U1_2018", clear
keep if tax_haven == 1

keep ISO3 corporate_ETR corptaxrev
gen year = 2018

append using `tf'
save `tf', replace

use "$work/shifted_profits_U1_2019", clear
keep if tax_haven == 1

keep ISO3 corporate_ETR corptaxrev
gen year = 2019

append using `tf'
save `tf', replace

use "$work/shifted_profits_U1_2020", clear
keep if tax_haven == 1

keep ISO3 corporate_ETR corptaxrev
gen year = 2020

append using `tf'
save `tf', replace

use "$work/shifted_profits_U1_2021", clear
keep if tax_haven == 1

keep ISO3 corporate_ETR corptaxrev
gen year = 2021

append using `tf'
save `tf', replace

use "$work/shifted_profits_U1_2022", clear
keep if tax_haven == 1

keep ISO3 corporate_ETR corptaxrev
gen year = 2022

append using `tf'

save "$work/tax_haven_ETRs", replace 

*drop 2021 for now, will be added back for the November update
*drop if year == 2021

export excel using "$root/output/Tax_haven_tax_rates_tooltip.xlsx", firstrow(var) sheet("Effective tax rates", replace) keepcellfmt 