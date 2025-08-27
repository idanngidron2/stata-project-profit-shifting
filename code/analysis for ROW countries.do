// ------------------------------ //
// Analysis for ROW countries 
// ------------------------------ //



// This do file runs a separate estimation for an additional group of countries 
// For these countries (all non-tax havens), estimates of profits shifted, tax 
// loss and tax loss as a share of CIT are derived using the estimate for tax loss 
// as a share of CIT obtained for "Rest of the World" in the main analysis (table U1).
// This estimation uses the country-specific corporate statutory rate and 
// corporate tax revenue. 


// Note: this is the only do-file of the analysis which runs from 2015 instead of 2016
// this is because for this do file we add data for 2015 to complete TWZ data

if $temp == 2022 {

*foreach i in 2015 2016 2017 2018 2019 2020 2021 2022{		//analysis done for the years 2015-2022
foreach i in 2022 {		//analysis done for the year 2022

local temp =`i'


// ---------------------------------------------- //
// Step 1: import values for rest of the world
// ---------------------------------------------- //


use "$work/Atlas_non_tax_havens_allyears.dta", clear 

//Import values for ROW revenue loss as a share of CIT collected


sum value if iso3=="ROW" & year==`temp' & indicator=="corp_tax_lost" & counterpart =="World" 
local world_ROW_`temp' = r(mean)

sum value if iso3=="ROW" & year==`temp' & indicator=="corp_tax_lost" & counterpart =="EU_Havens" 
local EU_ROW_`temp' = r(mean)

sum value if iso3=="ROW" & year==`temp' & indicator=="corp_tax_lost" & counterpart =="Non_EU_Havens" 
local nonEU_ROW_`temp' = r(mean)

//Import values for ROW total profits shifted

sum value if iso3=="ROW" & year==`temp' & indicator=="profits_shifted" & counterpart=="World" 
local world_ROW_profits_`temp' = r(mean)

sum value if iso3=="ROW" & year==`temp' & indicator=="profits_shifted" & counterpart=="EU_Havens" 
local EU_ROW_profits_`temp' = r(mean)

sum value if iso3=="ROW" & year==`temp' & indicator=="profits_shifted" & counterpart=="Non_EU_Havens" 
local nonEU_ROW_profits_`temp' = r(mean)


// ----------------------------------------------------------- //
// Step 2: import country-specific corporate revenue
// ----------------------------------------------------------- //


// some data transformations until we get the clean version from Xabi and Pierre

//start with the file which includes data in USD for 2015-2018
use "$rawdata/corp_tax_USD.dta", clear 
keep if year >=2015
replace pct_1200_abs = pct_1200_abs/1.0e+09
keep pct_1200_abs country year
reshape wide pct_1200_abs, i(country) j(year)

tempfile tf1 
save `tf1', replace 


//we use the data file with local currencies and data for 2015-2020 to compute 
//growth rates of CIT revenue by country 
/*
use "$rawdata/corp_tax_bachas_et_al.dta", clear 
keep pct_1200_abs country year
reshape wide pct_1200_abs, i(country) j(year)

// generate growth rate variables by country-year 

gen growth_2019 = . 
replace growth_2019 = (pct_1200_abs2019 - pct_1200_abs2018)/pct_1200_abs2018

gen growth_2020 = . 
replace growth_2020 = (pct_1200_abs2020 - pct_1200_abs2018)/pct_1200_abs2018

gen growth_2021 = growth_2019 		//assume revenue in 2019 is identical to 2021 for now

keep country growth_2019 growth_2020 growth_2021

tempfile tf 
save `tf', replace 

use `tf1', clear 
merge 1:1 country using `tf', nogen 

gen pct_1200_abs2019 = pct_1200_abs2018 * (1 + growth_2019)
gen pct_1200_abs2020 = pct_1200_abs2018 * (1 + growth_2020)
gen pct_1200_abs2021 = pct_1200_abs2018 * (1 + growth_2021)

drop growth*

reshape long pct_1200_abs, i(country) j(year)
label variable pct_1200_abs "Corporate tax revenue (USD)"

rename country CountryCode 
keep if year ==`temp'

merge 1:m CountryCode using "$work/globaltaxrev_`temp'"

replace pct_1200_abs = corptaxrev if pct_1200_abs == . 
drop if pct_1200_abs == .

keep CountryCode pct_1200_abs
rename pct_1200_abs corptaxrev

save "$work/corptaxrev_comprehensive_`temp'", replace 
*/

//take 2 using the new data for 2022
use "$rawdata/pct_1200_abs_2025.dta", clear
*use "$rawdata/CIT_from_ETR_project_2015-21.dta", clear 

keep pct_1200_abs country year
reshape wide pct_1200_abs, i(country) j(year)

// generate growth rate variables by country-year 

gen growth_2019 = . 
replace growth_2019 = (pct_1200_abs2019 - pct_1200_abs2018)/pct_1200_abs2018

gen growth_2020 = . 
replace growth_2020 = (pct_1200_abs2020 - pct_1200_abs2018)/pct_1200_abs2018

gen growth_2021 = .
replace growth_2021 = (pct_1200_abs2021 - pct_1200_abs2018)/pct_1200_abs2018

gen growth_2022 = .
replace growth_2022 = (pct_1200_abs2022 - pct_1200_abs2018)/pct_1200_abs2018


keep country growth_2019 growth_2020 growth_2021 growth_2022

// impute missing values: set same as previous year is n/a

*replace growth_2021 = growth_2019 if growth_2021 == .		//set same as pre-COVID
*replace growth_2022 = growth_2021 if growth_2022 == .		//set same as previous year


tempfile tf 
save `tf', replace 

use `tf1', clear 
merge 1:1 country using `tf', nogen 

gen pct_1200_abs2019 = pct_1200_abs2018 * (1 + growth_2019)
gen pct_1200_abs2020 = pct_1200_abs2018 * (1 + growth_2020)
gen pct_1200_abs2021 = pct_1200_abs2018 * (1 + growth_2021)
gen pct_1200_abs2022 = pct_1200_abs2018 * (1 + growth_2022)

drop growth*

reshape long pct_1200_abs, i(country) j(year)
label variable pct_1200_abs "Corporate tax revenue (USD)"

rename country CountryCode 
keep if year ==`temp'

*tempfile tff
*save `tff', replace 

*use "$work/corptaxrev_comprehensive_`temp'.dta", clear
*merge m:m CountryCode using "$work/globaltaxrev_`temp'"
merge m:m CountryCode using "$work/corptaxrev_comprehensive_`temp'"


replace pct_1200_abs = corptaxrev if pct_1200_abs == . 
drop if pct_1200_abs == .

keep CountryCode pct_1200_abs
rename pct_1200_abs corptaxrev

save "$work/corptaxrev_comprehensive_`temp'", replace

// correct typo for Zimbabwe
/*
use "$work/corptaxrev_comprehensive_2020", clear

replace corptaxrev = corptaxrev/100 if CountryCode == "ZWE" 

save "$work/corptaxrev_comprehensive_2020", replace

use "$work/corptaxrev_comprehensive_2021", clear

replace corptaxrev = corptaxrev/100 if CountryCode == "ZWE" 

save "$work/corptaxrev_comprehensive_2021", replace
*/


// impute missing values for 2022 using values for 2021

use "$work/corptaxrev_comprehensive_2021", clear
rename corptaxrev corptaxrev2021
merge 1:1 CountryCode using "$work/corptaxrev_comprehensive_2022", nogen 
replace corptaxrev = corptaxrev2021 if corptaxrev == .
drop corptaxrev2021
save "$work/corptaxrev_comprehensive_2022", replace

// ----------------------------------------------------------- //
// Step 3: import country-specific corporate statutory rates
// ----------------------------------------------------------- //

import excel "$rawdata/1980_2023_Corporate_Tax_Rates_Around_the_World_Tax_Foundation", firstrow clear
*isocodes LOCATION, gen (iso3c)
*drop if iso3c == ""
//source: tax foundation https://taxfoundation.org/data/all/global/corporate-tax-rates-by-country-2023/

keep iso_3 country y_`temp'
rename iso_3 CountryCode

// Merge step2 and step3 

merge m:1 CountryCode using "$work/corptaxrev_comprehensive_`temp'"
drop if _merge ==1
drop _merge

// compute missing statutory rates 

replace y_`temp' = "10" if CountryCode == "KOS"
replace country = "Kosovo" if CountryCode == "KOS"

// destring CIT rates 
replace y_`temp' = "0" if y_`temp' == "NA"
destring y_`temp', replace

//remove countries for which data is obtained using the main methodology

rename CountryCode iso3


//tax havens 

* List of ISO3 codes to drop
local iso3_to_drop "BEL CHE IRL LUX NLD ABW AIA AND ATG BES BHR BHS BLZ BMU BRB CUW CYM CYP GGY GIB GRD HKG IMN JEY KNA LBN LCA LIE MAC MCO MHL MLT MUS PAN PRI SGP SXM SYC TCA VCT VGB"

* Loop through the list and drop observations
foreach code in `iso3_to_drop' {
    drop if iso3 == "`code'"
}

//non tax havens

* List of ISO3 codes to drop
local iso3_to_drop "AUS AUT CAN CHL CZE DEU DNK ESP EST FIN FRA GBR GRC HUN ISL ISR ITA JPN KOR LVA MEX NOR NZL POL PRT SVK SVN SWE TUR USA BRA CHN COL CRI IND RUS ZAF ARG EGY MYS NGA THA URY VEN NHT ROW WLD"

* Loop through the list and drop observations
foreach code in `iso3_to_drop' {
    drop if iso3 == "`code'"
}





// ----------------------------------------------- //
// Step 4: generate profits and tax losses
// ----------------------------------------------- //

// methodology in four steps 
//1) We compute the tax revenue loss "in reverse" by multiplying the country-specific 
//CIT revenue by the value for tax loss as a share of CIT revenue collected of ROW.

//2) generate the total profits shifted should these countries have had [tax loss = STR * profits shifted]. 
//Thus for each country, we compute [tax loss/STR = profits shifted]. 
//The total profits shifted are then the sum of this value from each country.

//3) calculate weights as the share of each country to the total profits shifted

//4) compute profits shifted using weights obtained in 3) and adjust profits shifted 
//such that the total sum equals the ROW total value for the given year and counterpart.



gen year = `temp'

rename y_`temp' STR 
replace STR = STR/100 

//corp tax loss as share of corp tax revenue collected
gen World_corp_tax_lost = .
replace World_corp_tax_lost = `world_ROW_`temp''
gen EU_corp_tax_lost = .
replace EU_corp_tax_lost = `EU_ROW_`temp''
gen nonEU_corp_tax_lost = .
replace nonEU_corp_tax_lost = `nonEU_ROW_`temp''


//(1) Tax revenue lost
//method: We compute the tax revenue loss "in reverse" by multiplying the country-specific 
//CIT revenue by the value for tax loss as a share of CIT revenue collected of ROW.


gen World_tax_lost = .
replace World_tax_lost= World_corp_tax_lost*corptaxrev

gen EU_tax_lost = .
replace EU_tax_lost = EU_corp_tax_lost*corptaxrev

gen nonEU_tax_lost =.
replace nonEU_tax_lost = nonEU_corp_tax_lost*corptaxrev


//Profits shifted

//(2) generate the total profits shifted should these countries have had tax loss = STR * profits shifted

//method: generate the total profits shifted should these countries have had [tax loss = STR * profits shifted]. 
//Thus for each country, we compute [tax loss/STR = profits shifted]. 
//The total profits shifted are then the sum of this value from each country.

gen World_profits_shifted_2 =.
replace World_profits_shifted_2= World_tax_lost/(STR)

sum World_profits_shifted_2
local World_total_profits = r(sum)
display `World_total_profits'

gen EU_profits_shifted_2 =.
replace EU_profits_shifted_2= EU_tax_lost/(STR)

sum EU_profits_shifted_2
local EU_total_profits = r(sum)
display `EU_total_profits'

gen nonEU_profits_shifted_2 =.
replace nonEU_profits_shifted_2= nonEU_tax_lost/(STR)

sum nonEU_profits_shifted_2
local nonEU_total_profits = r(sum)
display `nonEU_total_profits'

//(3) generate weights as the share of each country to the total profits shifted
//method: calculate weights as the share of each country to the total profits shifted

gen World_weights=.
replace World_weights=World_profits_shifted_2/`World_total_profits' 

gen EU_weights=.
replace EU_weights=EU_profits_shifted_2/`EU_total_profits' 

gen nonEU_weights=.
replace nonEU_weights=nonEU_profits_shifted_2/`nonEU_total_profits' 


//(4) compute profits shifted using weights and ROW value for the given year
//method: compute profits shifted using weights obtained in 3) and adjust profits shifted 
//such that the total sum equals the ROW total value for the given year and counterpart.


gen World_profits_shifted =.
replace World_profits_shifted = World_weights * `world_ROW_profits_`temp''
drop World_profits_shifted_2

gen EU_profits_shifted =.
replace EU_profits_shifted = EU_weights * `EU_ROW_profits_`temp''
drop EU_profits_shifted_2

gen nonEU_profits_shifted =.
replace nonEU_profits_shifted = nonEU_weights * `nonEU_ROW_profits_`temp''
drop nonEU_profits_shifted_2


rename corptaxrev CIT_rev

// test that computations are correct 
// sum of all weights should equal 1

sum World_weights
 display r(sum)
 // .99999999

sum EU_weights
 display r(sum)
 // 1
 
sum nonEU_weights
 display r(sum)
 // 1

save "$work/Atlas_ROW_`temp'.dta", replace 
 
 
// ----------------------------------------------- //
// Step 5: rearrange results for Atlas 
// ----------------------------------------------- //


// create subfiles by indicator-counterpart 

// 1) counterpart world; indicator corp tax lost as share of corp tax rev.

use "$work/Atlas_ROW_`temp'.dta", clear

// generate variables based on the Atlas data structure 
gen counterpart = ""
replace counterpart = "World"

gen indicator = ""
replace indicator = "corp_tax_lost"

gen value = . 
replace value = World_corp_tax_lost

keep iso3 indicator value counterpart year 
order iso3 indicator value counterpart year

tempfile tf2 
save `tf2', replace 

// 2) counterpart EU_Havens; indicator corp tax lost as share of corp tax rev.

use "$work/Atlas_ROW_`temp'.dta", clear

// generate variables based on the Atlas data structure 
gen counterpart = ""
replace counterpart = "EU_Havens"

gen indicator = ""
replace indicator = "corp_tax_lost"

gen value = . 
replace value = EU_corp_tax_lost

keep iso3 indicator value counterpart year 
order iso3 indicator value counterpart year

tempfile tf3 
save `tf3', replace 

// 3) counterpart Non-EU_Havens; indicator corp tax lost as share of corp tax rev.

use "$work/Atlas_ROW_`temp'.dta", clear

// generate variables based on the Atlas data structure 
gen counterpart = ""
replace counterpart = "Non_EU_Havens"

gen indicator = ""
replace indicator = "corp_tax_lost"

gen value = . 
replace value = nonEU_corp_tax_lost

keep iso3 indicator value counterpart year 
order iso3 indicator value counterpart year

tempfile tf4 
save `tf4', replace 


// 4) counterpart World; indicator tax loss

use "$work/Atlas_ROW_`temp'.dta", clear

// generate variables based on the Atlas data structure 
gen counterpart = ""
replace counterpart = "World"

gen indicator = ""
replace indicator = "tax_lost"

gen value = . 
replace value = World_tax_lost

keep iso3 indicator value counterpart year 
order iso3 indicator value counterpart year

tempfile tf5 
save `tf5', replace 


// 5) counterpart EU_Havens; indicator tax loss

use "$work/Atlas_ROW_`temp'.dta", clear

// generate variables based on the Atlas data structure 
gen counterpart = ""
replace counterpart = "EU_Havens"

gen indicator = ""
replace indicator = "tax_lost"

gen value = . 
replace value = EU_tax_lost

keep iso3 indicator value counterpart year 
order iso3 indicator value counterpart year

tempfile tf6 
save `tf6', replace 

// 6) counterpart Non-EU_Havens; indicator tax loss

use "$work/Atlas_ROW_`temp'.dta", clear

// generate variables based on the Atlas data structure 
gen counterpart = ""
replace counterpart = "Non_EU_Havens"

gen indicator = ""
replace indicator = "tax_lost"

gen value = . 
replace value = nonEU_tax_lost

keep iso3 indicator value counterpart year 
order iso3 indicator value counterpart year

tempfile tf7 
save `tf7', replace 


// 7) counterpart World; indicator profits shifted

use "$work/Atlas_ROW_`temp'.dta", clear

// generate variables based on the Atlas data structure 
gen counterpart = ""
replace counterpart = "World"

gen indicator = ""
replace indicator = "profits_shifted"

gen value = . 
replace value = World_profits_shifted

keep iso3 indicator value counterpart year 
order iso3 indicator value counterpart year

tempfile tf8 
save `tf8', replace 


// 8) counterpart EU_Havens; indicator profits shifted

use "$work/Atlas_ROW_`temp'.dta", clear

// generate variables based on the Atlas data structure 
gen counterpart = ""
replace counterpart = "EU_Havens"

gen indicator = ""
replace indicator = "profits_shifted"

gen value = . 
replace value = EU_profits_shifted

keep iso3 indicator value counterpart year 
order iso3 indicator value counterpart year

tempfile tf9 
save `tf9', replace 

// 9) counterpart Non-EU_Havens; indicator profits shifted

use "$work/Atlas_ROW_`temp'.dta", clear

// generate variables based on the Atlas data structure 
gen counterpart = ""
replace counterpart = "Non_EU_Havens"

gen indicator = ""
replace indicator = "profits_shifted"

gen value = . 
replace value = nonEU_profits_shifted

keep iso3 indicator value counterpart year 
order iso3 indicator value counterpart year

tempfile tf10 
save `tf10', replace 

// append all indicator-counterpart combinations 

use `tf2', clear
append using `tf3'
append using `tf4'
append using `tf5'
append using `tf6'
append using `tf7'
append using `tf8'
append using `tf9'
append using `tf10'


save "$work/Atlas_ROW_`temp'.dta", replace 

// append all years together into one file 

if `temp' == 2022 {
	
	use "$work/Atlas_ROW_2015.dta", clear
	append using "$work/Atlas_ROW_2016.dta"
	append using "$work/Atlas_ROW_2017.dta"
	append using "$work/Atlas_ROW_2018.dta"
	append using "$work/Atlas_ROW_2019.dta"
	append using "$work/Atlas_ROW_2020.dta"
	append using "$work/Atlas_ROW_2021.dta"
	append using "$work/Atlas_ROW_2022.dta"
	
	replace value = 0 if value ==. 
	

	save "$work/Atlas_ROW_allyears.dta", replace 
	export excel using "$root/output/Atlas_ROW_allyears.xlsx", firstrow(var) sheet("Rest of the world all years", replace) keepcellfmt 
}


// Prepare final file with all data for the Atlas 



	use "$work/Atlas_tax_havens_allyears.dta", clear
	append using "$work/Atlas_non_tax_havens_allyears.dta"
	append using "$work/Atlas_ROW_allyears.dta"
	sort  year counterpart indicator iso3
	
	* these lines are added to drop the value for ROW, NHT, WLD, so that in computations done in the atlas,
	* the sum total does not double count the world total or rest of the world.
	
	replace value = 0 if iso3 == "ROW"
	replace value = 0 if iso3 == "NHT"
	replace value = 0 if iso3 == "WLD"
	
	*remove the drop of 2021 for the November update
	
	save "$work/Atlas_allcountries_allyears.dta", replace 
	export excel using "$root/output/Atlas_allcountries_allyears.xlsx", firstrow(var) sheet("all countries all years", replace) keepcellfmt 

}


}
