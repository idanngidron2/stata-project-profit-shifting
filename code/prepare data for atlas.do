
// ---------------------------------
// Restructuring data for the Atlas 
// ---------------------------------

// This do file imports the data of part 1 of the analysis (estimating profits
// shifted) and part 2 of the analysis (reallocating shifted profits to source 
// countries) and restructures the results in the format necessary for the Atlas.

// ---------------------------------------------
// Step 1: profit and tax gains for tax havens
// ---------------------------------------------

use "$work/shifted_profits_U1_$temp", clear

// keep only tax haven countries 

keep if tax_haven == 1

// keep variables of relevance
keep country ISO3 tax_haven corptaxrev corporate_ETR shifted_profits


// prepare output by indicator. 

// 1. Starting with total profits shifted as indicator

// generate variables based on the Atlas data structure 
gen counterpart = ""
replace counterpart = "World"

gen indicator = ""
replace indicator = "shifted_profits"

gen value = . 
replace value = shifted_profits 

gen year = $temp 

rename ISO3 iso3 

keep iso3 indicator value counterpart year 
order iso3 indicator value counterpart year

tempfile tf 
save `tf', replace 

// 2. Tax revenue gain as indicator


use "$work/shifted_profits_U1_$temp", clear

// start with tax haven countries 

keep if tax_haven == 1

// keep variables of relevance
keep country ISO3 tax_haven corptaxrev corporate_ETR shifted_profits 


// generate variables based on the Atlas data structure 
gen counterpart = ""
replace counterpart = "World"

gen indicator = ""
replace indicator = "tax_won"

gen value = . 
replace value = shifted_profits * corporate_ETR

gen year = $temp 

rename ISO3 iso3 

keep iso3 indicator value counterpart year 
order iso3 indicator value counterpart year

tempfile tf2 
save `tf2', replace 

// 3. Tax gain as share of CIT as indicator

use "$work/shifted_profits_U1_$temp", clear

// start with tax haven countries 

keep if tax_haven == 1

// keep variables of relevance
keep country ISO3 tax_haven corptaxrev corporate_ETR shifted_profits 


// generate variables based on the Atlas data structure 
gen counterpart = ""
replace counterpart = "World"

gen indicator = ""
replace indicator = "corp_tax_gain"

gen value = . 
replace value = (shifted_profits * corporate_ETR)/corptaxrev
replace value = 1 if value > 1 	//we set a maximum of 100% of corporate tax gain 

gen year = $temp 

rename ISO3 iso3 

keep iso3 indicator value counterpart year 
order iso3 indicator value counterpart year

tempfile tf3 
save `tf3', replace 

// append together the three indicators for tax havens and save into one file

append using `tf'
append using `tf2'

save "$work/Atlas_tax_havens_$temp.dta", replace 


// save the values for 2015 which are derived directly from TWZ 

import excel "$rawdata/PSE - EU tax - database", sheet ("Profit_shifting") firstrow clear

keep if year == 2015

// keep variables of relevance
keep iso3 indicator value counterpart year

// destring value variable 
destring value, replace 

// keep values for tax havens only 
keep if indicator == "corp_tax_gain" | indicator == "shifted_profits" | indicator == "tax_won"

save "$work/Atlas_tax_havens_2015.dta", replace 


// append all years together into one file 

if $temp == 2022 {
	
	use "$work/Atlas_tax_havens_2015.dta", clear
	append using "$work/Atlas_tax_havens_2016.dta"
	append using "$work/Atlas_tax_havens_2017.dta"
	append using "$work/Atlas_tax_havens_2018.dta"
	append using "$work/Atlas_tax_havens_2019.dta"
	append using "$work/Atlas_tax_havens_2020.dta"
	append using "$work/Atlas_tax_havens_2021.dta"
	append using "$work/Atlas_tax_havens_2022.dta"
	
	replace value = 0 if value ==. 

	save "$work/Atlas_tax_havens_allyears.dta", replace 
	export excel using "$root/output/Atlas_tax_havens_allyears.xlsx", firstrow(var) sheet("Tax havens all years", replace) keepcellfmt 
}


// -----------------------------------------------
// Step 2: profit and tax loss for non-tax havens
// -----------------------------------------------

use "$work/table_C4d_$temp.dta", clear 

// keep only non-tax haven countries 

drop if group == "OECD_TH"

// keep variables of interest 

keep ISO3 All_havens EU_havens Non_EU_havens revenue_loss_All_havens loss_as_share_All_havens revenue_loss_Non_EU_havens loss_as_share_Non_EU_havens revenue_loss_EU_havens loss_as_share_EU_havens


// prepare intermediary output by indicator-counterpart 

// 1. counterpart = world ; indicator = profits shifted 

// generate variables based on the Atlas data structure 
gen counterpart = ""
replace counterpart = "World"

gen indicator = ""
replace indicator = "profits_shifted"

gen value = . 
replace value = All_havens

gen year = $temp 

rename ISO3 iso3 

keep iso3 indicator value counterpart year 
order iso3 indicator value counterpart year

tempfile tf4
save `tf4', replace 

// 2. counterpart = world ; indicator = tax loss 

use "$work/table_C4d_$temp.dta", clear 

// keep only non-tax haven countries 

drop if group == "OECD_TH"

// keep variables of interest 

keep ISO3 All_havens EU_havens Non_EU_havens revenue_loss_All_havens loss_as_share_All_havens revenue_loss_Non_EU_havens loss_as_share_Non_EU_havens revenue_loss_EU_havens loss_as_share_EU_havens

// generate variables based on the Atlas data structure 
gen counterpart = ""
replace counterpart = "World"

gen indicator = ""
replace indicator = "tax_lost"

gen value = . 
replace value = revenue_loss_All_havens

gen year = $temp 

rename ISO3 iso3 

keep iso3 indicator value counterpart year 
order iso3 indicator value counterpart year

tempfile tf5
save `tf5', replace 

// 3. counterpart = world ; indicator = tax loss as share of corporate tax rev. 

use "$work/table_C4d_$temp.dta", clear 

// keep only non-tax haven countries 

drop if group == "OECD_TH"

// keep variables of interest 

keep ISO3 All_havens EU_havens Non_EU_havens revenue_loss_All_havens loss_as_share_All_havens revenue_loss_Non_EU_havens loss_as_share_Non_EU_havens revenue_loss_EU_havens loss_as_share_EU_havens

// generate variables based on the Atlas data structure 
gen counterpart = ""
replace counterpart = "World"

gen indicator = ""
replace indicator = "corp_tax_lost"

gen value = . 
replace value = loss_as_share_All_havens
replace value = 1 if value > 1 	//we set a maximum of 100% of corporate tax loss 

gen year = $temp 

rename ISO3 iso3 

keep iso3 indicator value counterpart year 
order iso3 indicator value counterpart year

tempfile tf6
save `tf6', replace 

// 4. counterpart = EU havens ; indicator = profits shifted 

use "$work/table_C4d_$temp.dta", clear 

// keep only non-tax haven countries 

drop if group == "OECD_TH"

// keep variables of interest 

keep ISO3 All_havens EU_havens Non_EU_havens revenue_loss_All_havens loss_as_share_All_havens revenue_loss_Non_EU_havens loss_as_share_Non_EU_havens revenue_loss_EU_havens loss_as_share_EU_havens

// generate variables based on the Atlas data structure 
gen counterpart = ""
replace counterpart = "EU_Havens"

gen indicator = ""
replace indicator = "profits_shifted"

gen value = . 
replace value = EU_havens

gen year = $temp 

rename ISO3 iso3 

keep iso3 indicator value counterpart year 
order iso3 indicator value counterpart year

tempfile tf7
save `tf7', replace 

// 5. counterpart = EU havens ; indicator = tax loss 

use "$work/table_C4d_$temp.dta", clear 

// keep only non-tax haven countries 

drop if group == "OECD_TH"

// keep variables of interest 

keep ISO3 All_havens EU_havens Non_EU_havens revenue_loss_All_havens loss_as_share_All_havens revenue_loss_Non_EU_havens loss_as_share_Non_EU_havens revenue_loss_EU_havens loss_as_share_EU_havens

// generate variables based on the Atlas data structure 
gen counterpart = ""
replace counterpart = "EU_Havens"

gen indicator = ""
replace indicator = "tax_lost"

gen value = . 
replace value = revenue_loss_EU_havens

gen year = $temp 

rename ISO3 iso3 

keep iso3 indicator value counterpart year 
order iso3 indicator value counterpart year

tempfile tf8
save `tf8', replace 

// 6. counterpart = EU havens ; indicator = tax loss as share of corporate tax rev. 

use "$work/table_C4d_$temp.dta", clear 

// keep only non-tax haven countries 

drop if group == "OECD_TH"

// keep variables of interest 

keep ISO3 All_havens EU_havens Non_EU_havens revenue_loss_All_havens loss_as_share_All_havens revenue_loss_Non_EU_havens loss_as_share_Non_EU_havens revenue_loss_EU_havens loss_as_share_EU_havens

// generate variables based on the Atlas data structure 
gen counterpart = ""
replace counterpart = "EU_Havens"

gen indicator = ""
replace indicator = "corp_tax_lost"

gen value = . 
replace value = loss_as_share_EU_havens
replace value = 1 if value > 1 	//we set a maximum of 100% of corporate tax loss 

gen year = $temp 

rename ISO3 iso3 

keep iso3 indicator value counterpart year 
order iso3 indicator value counterpart year

tempfile tf9
save `tf9', replace 


// 7. counterpart = Non-EU havens ; indicator = profits shifted 

use "$work/table_C4d_$temp.dta", clear 

// keep only non-tax haven countries 

drop if group == "OECD_TH"

// keep variables of interest 

keep ISO3 All_havens EU_havens Non_EU_havens revenue_loss_All_havens loss_as_share_All_havens revenue_loss_Non_EU_havens loss_as_share_Non_EU_havens revenue_loss_EU_havens loss_as_share_EU_havens

// generate variables based on the Atlas data structure 
gen counterpart = ""
replace counterpart = "Non_EU_Havens"

gen indicator = ""
replace indicator = "profits_shifted"

gen value = . 
replace value = Non_EU_havens

gen year = $temp 

rename ISO3 iso3 

keep iso3 indicator value counterpart year 
order iso3 indicator value counterpart year

tempfile tf10
save `tf10', replace 

// 8. counterpart = Non-EU havens ; indicator = tax loss 

use "$work/table_C4d_$temp.dta", clear 

// keep only non-tax haven countries 

drop if group == "OECD_TH"

// keep variables of interest 

keep ISO3 All_havens EU_havens Non_EU_havens revenue_loss_All_havens loss_as_share_All_havens revenue_loss_Non_EU_havens loss_as_share_Non_EU_havens revenue_loss_EU_havens loss_as_share_EU_havens

// generate variables based on the Atlas data structure 
gen counterpart = ""
replace counterpart = "Non_EU_Havens"

gen indicator = ""
replace indicator = "tax_lost"

gen value = . 
replace value = revenue_loss_Non_EU_havens

gen year = $temp 

rename ISO3 iso3 

keep iso3 indicator value counterpart year 
order iso3 indicator value counterpart year

tempfile tf11
save `tf11', replace 

// 9. counterpart = Non-EU havens ; indicator = tax loss as share of corporate tax rev. 

use "$work/table_C4d_$temp.dta", clear 

// keep only non-tax haven countries 

drop if group == "OECD_TH"

// keep variables of interest 

keep ISO3 All_havens EU_havens Non_EU_havens revenue_loss_All_havens loss_as_share_All_havens revenue_loss_Non_EU_havens loss_as_share_Non_EU_havens revenue_loss_EU_havens loss_as_share_EU_havens

// generate variables based on the Atlas data structure 
gen counterpart = ""
replace counterpart = "Non_EU_Havens"

gen indicator = ""
replace indicator = "corp_tax_lost"

gen value = . 
replace value = loss_as_share_Non_EU_havens
replace value = 1 if value > 1 	//we set a maximum of 100% of corporate tax loss 

gen year = $temp 

rename ISO3 iso3 

keep iso3 indicator value counterpart year 
order iso3 indicator value counterpart year

tempfile tf12
save `tf12', replace 


// append all indicator-counterpart combinations 

use `tf4', clear
append using `tf5'
append using `tf6'
append using `tf7'
append using `tf8'
append using `tf9'
append using `tf10'
append using `tf11'
append using `tf12'


// shift values from USD mln to USD bln 
replace value = value/1000 if indicator == "profits_shifted" | indicator == "tax_lost"

save "$work/Atlas_non_tax_havens_$temp.dta", replace 

// 10. Import values for 2015 from TWZ 

import excel "$rawdata/PSE - EU tax - database", sheet ("Profit_shifting") firstrow clear

keep if year == 2015

// keep only countries of the main analysis (ROW countries will be added later)

* Define the list of isocodes to keep
local isocodes "AUS AUT CAN CHL CZE DEU DNK ESP EST FIN FRA GBR GRC HUN ISL ISR ITA JPN KOR LVA MEX NOR NZL POL PRT SVK SVN SWE TUR USA BRA CHN COL CRI IND RUS ZAF ARG EGY MYS NGA THA URY VEN NHT ROW WLD"

* Create a temporary variable to mark the isocodes to keep
gen keep = 0
foreach iso in `isocodes' {
    replace keep = 1 if iso3 == "`iso'"
}

* Keep only the rows with the specified isocodes
keep if keep == 1

* Drop the temporary variable
drop keep

// keep variables of relevance

keep iso3 indicator value counterpart year

// destring value variable 
destring value, replace 

// keep values for tax havens only 
keep if indicator == "corp_tax_lost" | indicator == "profits_shifted" | indicator == "tax_lost"

save "$work/Atlas_non_tax_havens_2015.dta", replace 

// append all years together into one file 

if $temp == 2022 {
	
	use "$work/Atlas_non_tax_havens_2015.dta", clear
	append using "$work/Atlas_non_tax_havens_2016.dta"
	append using "$work/Atlas_non_tax_havens_2017.dta"
	append using "$work/Atlas_non_tax_havens_2018.dta"
	append using "$work/Atlas_non_tax_havens_2019.dta"
	append using "$work/Atlas_non_tax_havens_2020.dta"
	append using "$work/Atlas_non_tax_havens_2021.dta"
	append using "$work/Atlas_non_tax_havens_2022.dta"
	
	replace value = 0 if value ==. 


	save "$work/Atlas_non_tax_havens_allyears.dta", replace 
	export excel using "$root/output/Atlas_non_tax_havens_allyears.xlsx", firstrow(var) sheet("Non-tax havens all years", replace) keepcellfmt 
}
