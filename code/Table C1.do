//----------------------------------------------//
//Compute reallocated profits	
//----------------------------------------------//

//the next do files C1-C4d compute the shifted profits lost from non-haven countries
//the computation is done based on cross-border transaction data that economic literature associates with profit shifting 
//the final estimate of shifted profits away from non-haven countries is adjusted to match the total profit shifting estimate 
//do file "0d-compute-profit-shifting"


//----------//
//Table C1
//----------//

//-------------------------------------------------
//step 0: data cleaning for table Swiss pivot 
//-------------------------------------------------

//Swiss pivot computes the values of service payments to Switzerland
//this table is used subsequently for various computations

//we import the data by region due to syntax constraints

//europe
import excel "$rawdata/Swiss_data", sheet ("europe") clear

keep if A == "Countries" | A == "Component" | A == "$temp"

foreach var of varlist _all {
	
	if "`var'" != "A" {
		
	replace `var' = "Europe - United_Kingdom" if `var' == "Europe - United Kingdom"
	replace `var' = "Europe - EU_not_allocated" if `var' == "Europe - Europe (not allocated)"
	replace `var' = "Europe - Total_Europe" if `var' == "Europe - Total"
	
	replace `var' = subinstr(`var', "Europe - ","",.)
	
	replace `var' = "A" if `var' == "Insurance and pension services"
	replace `var' = "B" if `var' == "Financial services"
	replace `var' = "C" if `var' == "Licence fees"
	replace `var' = "D" if `var' == "Telecommunications, computer and information services"
	replace `var' = "E" if `var' == "Research and development services"
	replace `var' = "F" if `var' == "Consulting services"
	replace `var' = "G" if `var' == "Other services"
	preserve 
	keep if A == "Countries"
	local country = `var'
	restore 
	preserve 
	keep if A == "Component"
	local component = `var'
	restore
	rename `var' `component'_`country'
	}
	 
}

drop if A == "Countries"
drop if A == "Component"
rename A year


foreach var of varlist _all {
destring `var', replace
}
reshape long A_ B_ C_ D_ E_ F_ G_, i(year) j(country, string)

tempfile europe
save `europe', replace

//africa

import excel "$rawdata/Swiss_data", sheet ("africa") clear

keep if A == "Countries" | A == "Component" | A == "$temp"

foreach var of varlist _all {
	
	if "`var'" != "A" {
		
	replace `var' = "Africa - South_Africa" if `var' == "Africa - South Africa"
	replace `var' = "Africa - North_Africa" if `var' == "Africa - North Africa - Total"
	replace `var' = "Africa - Africa_not_allocated" if `var' == "Africa - Africa (not allocated)"
	replace `var' = "Africa - Total_Africa" if `var' == "Africa - Total"

	replace `var' = subinstr(`var', "Africa - ","",.)
	
	replace `var' = "A" if `var' == "Insurance and pension services"
	replace `var' = "B" if `var' == "Financial services"
	replace `var' = "C" if `var' == "Licence fees"
	replace `var' = "D" if `var' == "Telecommunications, computer and information services"
	replace `var' = "E" if `var' == "Research and development services"
	replace `var' = "F" if `var' == "Consulting services"
	replace `var' = "G" if `var' == "Other services"
	preserve 
	keep if A == "Countries"
	local country = `var'
	restore 
	preserve 
	keep if A == "Component"
	local component = `var'
	restore
	rename `var' `component'_`country'
	}
	 
}

drop if A == "Countries"
drop if A == "Component"
rename A year


foreach var of varlist _all {
destring `var', replace
}
reshape long A_ B_ C_ D_ E_ F_ G_, i(year) j(country, string)
append using `europe'
tempfile africa 
save `africa', replace 

//America 

import excel "$rawdata/Swiss_data", sheet ("america") clear

keep if A == "Countries" | A == "Component" | A == "$temp"

foreach var of varlist _all {
	
	if "`var'" != "A" {
		
	replace `var' = "America - America_not_allocated" if `var' == "America - America (not allocated)"
	replace `var' = "America - Total_America" if `var' == "America - Total"

	replace `var' = subinstr(`var', "America - ","",.)
	
	replace `var' = "A" if `var' == "Insurance and pension services"
	replace `var' = "B" if `var' == "Financial services"
	replace `var' = "C" if `var' == "Licence fees"
	replace `var' = "D" if `var' == "Telecommunications, computer and information services"
	replace `var' = "E" if `var' == "Research and development services"
	replace `var' = "F" if `var' == "Consulting services"
	replace `var' = "G" if `var' == "Other services"
	preserve 
	keep if A == "Countries"
	local country = `var'
	restore 
	preserve 
	keep if A == "Component"
	local component = `var'
	restore
	rename `var' `component'_`country'
	}
	 
}

drop if A == "Countries"
drop if A == "Component"
rename A year


foreach var of varlist _all {
destring `var', replace
}
reshape long A_ B_ C_ D_ E_ F_ G_, i(year) j(country, string)
append using `africa'
tempfile america 
save `america', replace 

//Asia 

import excel "$rawdata/Swiss_data", sheet ("asia") clear

keep if A == "Countries" | A == "Component" | A == "$temp"

foreach var of varlist _all {
	
	if "`var'" != "A" {
		
	replace `var' = "Asia - Asia_not_allocated" if `var' == "Asia - Asia (not allocated)"
	replace `var' = "Asia - Gulf_countries" if `var' == "Asia - Gulf Arabian countries"
	replace `var' = "Asia - Hong_kong" if `var' == "Asia - Hong Kong SAR"
	replace `var' = "Asia - Total_Asia" if `var' == "Asia - Total"

	replace `var' = subinstr(`var', "Asia - ","",.)
	
	replace `var' = "A" if `var' == "Insurance and pension services"
	replace `var' = "B" if `var' == "Financial services"
	replace `var' = "C" if `var' == "Licence fees"
	replace `var' = "D" if `var' == "Telecommunications, computer and information services"
	replace `var' = "E" if `var' == "Research and development services"
	replace `var' = "F" if `var' == "Consulting services"
	replace `var' = "G" if `var' == "Other services"
	preserve 
	keep if A == "Countries"
	local country = `var'
	restore 
	preserve 
	keep if A == "Component"
	local component = `var'
	restore
	rename `var' `component'_`country'
	}
	 
}

drop if A == "Countries"
drop if A == "Component"
rename A year


foreach var of varlist _all {
destring `var', replace
}
reshape long A_ B_ C_ D_ E_ F_ G_, i(year) j(country, string)
append using `america'
tempfile asia 
save `asia', replace

//Rest

import excel "$rawdata/Swiss_data", sheet ("rest") clear

keep if A == "Countries" | A == "Component" | A == "$temp"

foreach var of varlist _all {
	
	if "`var'" != "A" {
		
	replace `var' = "Australia, Oceania and Polar regions - Total_Oceania" if `var' == "Australia, Oceania and Polar regions - Total"
	replace `var' = "Australia, Oceania and Polar regions - Oceania_not_allocated" if `var' == "Australia, Oceania and Polar regions - Australia, Oceania and Polar regions (not allocated)"
	replace `var' = "Rest of the world (not allocated), international organisations - Rest_not_allocated" if `var' == "Rest of the world (not allocated), international organisations - Total"
	replace `var' = "All countries (excluding Rest of the world, international organisations) - Total_rest" if `var' == "All countries (excluding Rest of the world, international organisations) - Total"

	replace `var' = subinstr(`var', "Australia, Oceania and Polar regions - ","",.)
	replace `var' = subinstr(`var', "Rest of the world (not allocated), international organisations - ","",.)
	replace `var' = subinstr(`var', "All countries (excluding Rest of the world, international organisations) - ","",.)	
	replace `var' = subinstr(`var', "All countries - ","",.)	
	replace `var' = "A" if `var' == "Insurance and pension services"
	replace `var' = "B" if `var' == "Financial services"
	replace `var' = "C" if `var' == "Licence fees"
	replace `var' = "D" if `var' == "Telecommunications, computer and information services"
	replace `var' = "E" if `var' == "Research and development services"
	replace `var' = "F" if `var' == "Consulting services"
	replace `var' = "G" if `var' == "Other services"
	preserve 
	keep if A == "Countries"
	local country = `var'
	restore 
	preserve 
	keep if A == "Component"
	local component = `var'
	restore
	rename `var' `component'_`country'
	}
	 
}

drop if A == "Countries"
drop if A == "Component"
rename A year


foreach var of varlist _all {
destring `var', replace
}
reshape long A_ B_ C_ D_ E_ F_ G_, i(year) j(country, string)
append using `asia'

foreach var of varlist A_ B_ C_ D_ E_ F_ G_ {
	
	replace `var'=0 if `var'==.
	replace `var' = `var'*$CHF_USD			
										//from swiss francs millions to USD millions
}

gen sum_total =.
replace sum_total = A_ + B_ + C_ + D_ + E_ + F_ + G_
	rename A_ insurance_services
	rename B_ Financial_services
	rename C_ Licence_fees
	rename D_ ICT_services
	rename E_ R_and_D_services
	rename F_ Consulting_services
	rename G_ Other_services

save "$work/swiss_pivot_$temp", replace 


//------------------------
//Step 1: data structure
//------------------------

//We start with importing the country structure from past output

cd "$work"

use shifted_profits_U1_$temp, clear

keep country ISO3 tax_haven group


//we add several developing countries to the analysis 
set obs 81 
replace ISO3 = "ARG" if ISO3==""
replace country = "Argentina" if ISO3 == "ARG"
set obs 82
replace ISO3 = "EGY" if ISO3==""
replace country = "Egypt" if ISO3 == "EGY"
set obs 83
replace ISO3 = "MYS" if ISO3==""
replace country = "Malaysia" if ISO3 == "MYS"
set obs 84
replace ISO3 = "NGA" if ISO3==""
replace country = "Nigeria" if ISO3 == "NGA"
set obs 85
replace ISO3 = "THA" if ISO3==""
replace country = "Thailand" if ISO3 == "THA"
set obs 86
replace ISO3 = "URY" if ISO3==""
replace country = "Uruguay" if ISO3 == "URY"
set obs 87
replace ISO3 = "VEN" if ISO3==""
replace country = "Venezuela" if ISO3 == "VEN"

replace group = "NEW_DEV" if group == ""
replace tax_haven = 0 if tax_haven==.

gen EU = 0

replace EU =1 if ISO3 == "AUT" |ISO3 == "BEL" |ISO3 == "CZE" |ISO3 == "DNK" |ISO3 == "EST" |ISO3 == "FIN" |ISO3 == "FRA" |ISO3 == "DEU" |ISO3 == "GRC" |ISO3 == "HUN" |ISO3 == "ISL" |ISO3 == "IRL" |ISO3 == "ITA" |ISO3 == "LVA" |ISO3 == "LUX" |ISO3 == "NLD" |ISO3 == "POL" |ISO3 == "PRT" |ISO3 == "SVK" |ISO3 == "SVN" |ISO3 == "ESP" |ISO3 == "SWE" |ISO3 == "GBR"

//we remove non-OECD tax havens 
drop if group == "TH"

tempfile structure
save `structure', replace

//---------------------------------------------
//step 2: import data from IMF CDIS Table 4
//---------------------------------------------

//IMF data was bulk downloaded and available in raw-data
//The data includes inward direct investment positions of all reporting economies
//We compute the ratio of DI by country as a share of global DI



import excel "$rawdata/CDIS_Table_4", firstrow sheet("for_stata") clear

keep Investmentin year_$temp
gen DI_ratio = . 
sum year_$temp if Investmentin == "Total Investment"
local Total_Investment = r(mean)
replace DI_ratio = year_$temp/`Total_Investment'
replace DI_ratio = 0 if DI_ratio==. 

isocodes Investmentin, gen(iso3c)
rename iso3c ISO3 
replace ISO3 = "WLD" if Investmentin== "Total Investment"
replace ISO3 = "CUW" if Investmentin== "Curaçao, Kingdom of the Netherlands"
keep ISO3 DI_ratio year_$temp

merge m:m ISO3 using `structure'
keep if _merge == 3 | _merge==2
drop _merge


//compute DI ratio for missing countries (Colombia, and rest of the world)
replace DI_ratio = 0 if DI_ratio==. 
replace DI_ratio = 0.00119749790048501 if ISO3 =="COL" 	//Colombia has missing values in TWZ, we take the DI ratio of 2015 as in TWZ

//rest of the world
*sum year_$temp if (ISO3 != "WLD" & ISO3 != "HKG")
sum year_$temp if (ISO3 != "WLD")
local ROW = r(sum)

sum year_$temp if ISO3 == "WLD"
local WLD = r(mean)

display `WLD'
display `ROW'

replace year_$temp = `WLD' - `ROW' if ISO3 == "ROW"
replace DI_ratio = year_$temp/`Total_Investment' if ISO3 == "ROW"



gen CDIS_col_AS = . 
sum DI_ratio if (ISO3 == "ISR" | ISO3 == "COL" | ISO3 == "CRI" | ISO3 == "ROW")
local denominator = r(sum)

replace CDIS_col_AS = DI_ratio/`denominator' if (ISO3 == "ISR" | ISO3 == "COL" | ISO3 == "CRI" | ISO3 == "ROW")
replace CDIS_col_AS = 0 if CDIS_col_AS == .

gen CDIS_col_AC = . 
sum DI_ratio if (EU == 0 & ISO3 != "WLD")
local nonEU = r(sum)
replace CDIS_col_AC = DI_ratio/`nonEU' if EU == 0 
replace CDIS_col_AC = 0 if CDIS_col_AC == .


gen CDIS_col_AK = . 
sum DI_ratio if (ISO3 == "ARG"| ISO3 == "COL" | ISO3 == "CRI" | ISO3 == "EGY" | ISO3 == "IDN" | ISO3 == "ISL"| ISO3 == "KOR" | ISO3 == "NGA" | ISO3 == "NZL" | ISO3 == "ROW" | ISO3 == "THA" | ISO3 == "URY"| ISO3 == "VEN")
local denominator2 = r(sum)
replace CDIS_col_AK = DI_ratio/`denominator2' if (ISO3 == "ARG"| ISO3 == "COL" | ISO3 == "CRI" | ISO3 == "EGY" | ISO3 == "IDN" | ISO3 == "ISL"| ISO3 == "KOR" | ISO3 == "NGA" | ISO3 == "NZL" | ISO3 == "ROW" | ISO3 == "THA" | ISO3 == "URY"| ISO3 == "VEN")
replace CDIS_col_AK = 0 if CDIS_col_AK == . 


order country ISO3 EU group CDIS_col_AC CDIS_col_AK CDIS_col_AS 
keep country ISO3 EU group CDIS_col_AC CDIS_col_AK CDIS_col_AS
tempfile step2
save `step2', replace

//generate the 2019 share of interest payment of EU countries as a total of EU fdi interest for the years before 2019

use "$work/intra_eu_breakdown_credit_inward_2019", clear 
gen lux_ratio = . 
keep if geo_label == "Luxembourg"
sum imputed if partner == "EU28" 
local eu_lux = r(mean)
replace lux_ratio = imputed/`eu_lux'	//note that the sum of ratios will be above 1 since we include UK here as well while EU28 excludes UK
isocodes partner, gen (iso3c)
rename iso3c ISO3 
replace ISO3 = "EU_28" if partner == "EU28"
keep ISO3 lux_ratio
duplicates drop ISO3 lux_ratio, force
tempfile lux_ratio
save `lux_ratio', replace 

use "$work/intra_eu_breakdown_credit_outward_2019", clear 
gen lux_ratio = . 
keep if geo_label == "Luxembourg"
sum imputed if partner_l == "European Union - 27 countries (from 2020)" 
local eu_lux_out = r(mean)
replace lux_ratio = imputed/`eu_lux_out'	//note that the sum of ratios will be above 1 since we include UK here as well while EU28 excludes UK
isocodes partner, gen (iso3c)
rename iso3c ISO3 
replace ISO3 = "EU_28" if partner_l == "European Union - 27 countries (from 2020)" 
keep ISO3 lux_ratio
duplicates drop ISO3 lux_ratio, force
tempfile lux_ratio_out
save `lux_ratio_out', replace 



use `step2', clear 


//-----------------------------------------------
//step 3: FDI interest payments to EU havens
//-----------------------------------------------

//EU countries

foreach name in "Belgium" "Cyprus" "Ireland" "Luxembourg" "Malta" "Netherlands" {
	gen `name'_a = . 
}

tempfile tf1 
save `tf1', replace

use "$work/intra_eu_breakdown_credit_inward_$temp", clear
isocodes partner, gen(iso3c)
rename iso3c ISO3 
rename imputed inward
keep ISO3 inward geo_label
keep if geo_label == "Belgium" |geo_label == "Cyprus" |geo_label =="Ireland"|geo_label == "Luxembourg"|geo_label == "Malta" |geo_label =="Netherlands" 
reshape wide inward, i(ISO3) j(geo_label, string)
replace ISO3 = "EU_28" if ISO3 == ""
	

tempfile inward
save `inward', replace


use "$work/intra_eu_breakdown_credit_outward_$temp", clear

keep if geo_label == "Belgium" |geo_label == "Cyprus" |geo_label =="Ireland"|geo_label == "Luxembourg"|geo_label == "Malta" |geo_label =="Netherlands" 

isocodes partner_l, gen(iso3c)
rename iso3c ISO3 
rename imputed outward

keep ISO3 outward geo_label
duplicates drop ISO3 geo_label outward, force
drop if geo_label == "European Union - 28 countries (2013-2020)" |geo_label == "European Union - 27 countries (from 2020)" 
reshape wide outward, i(ISO3) j(geo_label, string)
replace ISO3 = "EU_28" if ISO3 == ""

merge 1:1 ISO3 using `inward', nogen


foreach name in "Belgium" "Cyprus" "Ireland" "Luxembourg" "Malta" "Netherlands" {
	replace inward`name' = 0 if inward`name'==.
	replace outward`name' = 0 if outward`name'==.
	replace outward`name' = outward`name' + inward`name'
	drop inward`name'
	rename outward`name' `name'
}


tempfile tf1
save `tf1', replace

//non-EU countries

use "$work/othercountrylosses_nonEU_inward_$temp", clear
isocodes partner, gen(iso3c)
rename iso3c ISO3
replace ISO3 = "CHN" if partner == "CN_X_HK"
replace ISO3 = "EXT_EU28" if partner == "EXT_EU28"
replace ISO3 = "EXT_EU_NAL" if partner == "EXT_EU_NAL"
drop if ISO3 == ""
rename imputed inward
keep ISO3 inward geo_label
keep if geo_label == "Belgium" |geo_label == "Cyprus" |geo_label =="Ireland"|geo_label == "Luxembourg"|geo_label == "Malta" |geo_label =="Netherlands" 
reshape wide inward, i(ISO3) j(geo_label, string)

tempfile inward
save `inward', replace


use "$work/othercountrylosses_nonEU_outward_$temp", clear
isocodes partner, gen(iso3c)
rename iso3c ISO3
replace ISO3 = "CHN" if partner == "CN_X_HK"
replace ISO3 = "EXT_EU28" if partner == "EXT_EU28"
replace ISO3 = "EXT_EU_NAL" if partner == "EXT_EU_NAL"
drop if ISO3 == ""
rename imputed outward
keep ISO3 outward geo_label
duplicates drop ISO3 geo_label outward, force
keep if geo_label == "Belgium" |geo_label == "Cyprus" |geo_label =="Ireland"|geo_label == "Luxembourg"|geo_label == "Malta" |geo_label =="Netherlands" 
reshape wide outward, i(ISO3) j(geo_label, string)


merge 1:1 ISO3 using `inward', nogen

foreach name in "Belgium" "Cyprus" "Ireland" "Luxembourg" "Malta" "Netherlands" {
	replace inward`name' = 0 if inward`name'==.
	replace outward`name' = 0 if outward`name'==.
	replace outward`name' = outward`name' + inward`name'
	drop inward`name'
	rename outward`name' `name'
}

append using `tf1'

foreach name in "Belgium" "Cyprus" "Ireland" "Luxembourg" "Malta" "Netherlands" {
										//change currency from EUR to USD 
replace `name'=`name'/$USD_EUR
}

drop if ISO3 == "EXT_EU_NAL" | ISO3 == "EXT_EU28"

tempfile step3
save `step3', replace



//-----------------------------------------------
//step 4: high-risk FDI payments to non-EU havens
//-----------------------------------------------

//counterpart Switzerland
//part 1: EU countries

//take sum of inward and outward
clear
use "$work/nonEU_debitint_nonEUhav_inward_$temp", clear
drop if geo_label=="European Union - 27 countries (from 2020)"
drop if bop_fdi6_inc$temp !=. & geo_label=="Ireland"		//keep only imputed values for ireland
keep if partner == "CH"
keep partner geo_label imputed
rename imputed Switzerland
tempfile che
save `che', replace

use "$work/nonEU_breakdown_debitint_nonEUhaven_outward_$temp", clear
drop if bop_fdi6_inc$temp !=. & geo_label=="Ireland"		//keep only imputed values for ireland
keep if partner == "CH"

merge 1:1 partner geo_label using `che'
replace Switzerland = Switzerland + imputed 

isocodes geo_label, gen (iso3c)
rename iso3c ISO3
*rename imputed Switzerland
keep ISO3 Switzerland
//currency change for EU countries from euro to USD
replace Switzerland=Switzerland/$USD_EUR		


tempfile che
save `che', replace


//counterpart Rest
//EU countries

//take sum of inward and outward
clear
use "$work/nonEU_debitint_nonEUhav_inward_$temp", clear
drop if geo_label=="European Union - 27 countries (from 2020)"
drop if bop_fdi6_inc$temp !=. & geo_label=="Ireland"		//keep only imputed values for ireland
keep if partner == "OFFSHO"
keep partner geo_label imputed
isocodes geo_label, gen (iso3c)
rename iso3c ISO3

rename imputed Rest
//currency change for EU countries from euro to USD
replace Rest=Rest/$USD_EUR		

tempfile rest
save `rest', replace

use "$work/nonEU_breakdown_debitint_nonEUhaven_outward_$temp", clear
drop if bop_fdi6_inc$temp !=. & geo_label=="Ireland"		//keep only imputed values for ireland
keep if partner == "OFFSHO"
isocodes geo_label, gen (iso3c)
rename iso3c ISO3

merge 1:1 partner geo_label using `rest'
replace Rest = Rest + imputed 


*rename imputed Switzerland
keep ISO3 Rest
drop if ISO3 ==""
tempfile rest
save `rest', replace

merge 1:1 ISO3 using `che'
drop _merge

tempfile non_eu_havens
save `non_eu_havens', replace

use `step2', clear
merge 1:1 ISO3 using `step3', nogen
merge 1:1 ISO3 using `non_eu_havens', nogen 
tempfile step4 
save `step4', replace
//counterpart Switzerland
//part 2: Non-EU countries

//K8 = E8-J8 
//J8 = 'Breakdown non-EU havens'!$M$32/E16 		//i.e. non-eu breakdown inward value when geo == CHE and partner == total and where total is calculated as the sum of all other partners excluding EU27
//E8 = +'fdiinterest_net (2)'!$C$32/1000000

//E8

use "$work/IMF_fdi_interest_$temp", clear
rename _ISO3C_ ISO3
keep ISO3 DI_interest_Credit
sum DI_interest_Credit if ISO3 == "CHE"
local switzerland = (r(mean)/1000000) 			//transforming from USD to USD mln

//J8 

use "$work/nonEU_debitint_nonEUhav_inward_$temp", clear
keep if partner == "CH"
keep imputed partner geo_label
drop if geo_label == "European Union - 27 countries (from 2020)"
sum imputed 
local total_ = (r(sum)/$USD_EUR)

//K8 					 

local swiss_interest = `switzerland' - `total_'

use `step4', clear
replace Switzerland = `swiss_interest' * CDIS_col_AC if EU!=1	
save `step4', replace

//counterpart Rest
//part 2: Non-EU countries

//K13 = E13 - J13
//J13 = +'Breakdown non-EU havens'!$L$32/E16
//E13 = E9 + E10 +E11
//E9 = interst received as reported by SGP 
//E10 = +'fdiinterest_net (2)'!$C$67/1000000 (probably HKG)
//E11 = +C11*SUM(E8:E10)/SUM(D8:D10) where 
//C11 = Table U1'!$AF$93*1000
//D8 = C8*(TWZRawDataC.xlsx]Data'!$H$8)
//D9 = C9*(TWZRawDataC.xlsx]Data'!$H$8)
//D10 = C10* (TWZRawDataC.xlsx]Data'!$H$8)

//C9 and C10 


use "$work/highriskexports_$temp", clear
preserve 
keep if country == "SGP"
sum yr$temp if indicatorname == "Charges for the use of intellectual property, receipts (BoP, current US$)"
local charges = r(mean)
sum yr$temp if indicatorname == "Insurance and financial services (% of service exports, BoP)"
local percent_finance = (r(mean)/100)
sum yr$temp if indicatorname == "Service exports (BoP, current US$)"
local service = r(mean)
sum yr$temp if indicatorname == "Communications, computer, etc. (% of service exports, BoP)"
local percent_ICT = (r(mean)/100)
local sgp_exports = (`charges' + (`percent_finance'+`percent_ICT')*`service')/1000000 
restore 

preserve 
keep if country == "HKG"
sum yr$temp if indicatorname == "Charges for the use of intellectual property, receipts (BoP, current US$)"
local charges = r(mean)
sum yr$temp if indicatorname == "Insurance and financial services (% of service exports, BoP)"
local percent_finance = (r(mean)/100)
sum yr$temp if indicatorname == "Service exports (BoP, current US$)"
local service = r(mean)
sum yr$temp if indicatorname == "Communications, computer, etc. (% of service exports, BoP)"
local percent_ICT = (r(mean)/100)
local hkg_exports = (`charges' + (`percent_finance'+`percent_ICT')*`service')/1000000 
restore 


//J13

use "$work/nonEU_debitint_nonEUhav_inward_$temp", clear
keep if partner == "OFFSHO"
keep imputed partner geo_label
drop if geo_label == "European Union - 27 countries (from 2020)"
sum imputed 
local total_2 = (r(sum)/$USD_EUR)

//E8 same as above 

//E9 compute as the global average share of FDI interest as a share of high-risk exports in havens * high-risk exports in SGP


local sgp = ((16/100) * `sgp_exports')

//E10 

use "$work/IMF_fdi_interest_$temp", clear
rename _ISO3C_ ISO3
keep ISO3 DI_interest_Credit
sum DI_interest_Credit if ISO3 == "HKG"
local hkg = (r(mean)/1000000) 			//transforming from USD to USD mln

//C11 (profits shifted for non-OECD tax havens excluding SGP, HKG, and PRI)

use "$work/shifted_profits_U1_$temp", clear
sum shifted_profits if group == "TH" & !(ISO3 == "SGP" | ISO3 == "HKG" | ISO3 == "PRI")
local non_oecd = (r(sum)*1000) 		//tranform from USD bln to USD mln

//H8 of Swiss Data 

import excel "$rawdata/Swiss_data", sheet ("Data") clear 
gen id = _n
keep if id == 6  
destring H, replace
sum H 
local export_share_CHE = (1-r(mean))



//C8 
use "$work/swiss_pivot_$temp", clear 
sum sum_total if country == "Total"
local che_exports = r(mean)

//D8, D9, and D10 

local D8 = (`che_exports' * `export_share_CHE')
local D9 = (`sgp_exports' * `export_share_CHE')
local D10 = (`hkg_exports' * `export_share_CHE')

//E11 

local E11 = `non_oecd' * ((`switzerland' + `hkg' + `sgp')/(`D8' + `D9' + `D10'))
display `E11'
display `non_oecd'
//E13 

local E13 = `E11' + `hkg' + `sgp'	
//K13 

local K13 = `E13' - `total_2'
display `K13'

use `step4', clear
replace Rest = `K13' * CDIS_col_AC if EU!=1	
save `step4', replace

//-------------------------------------
//Step 5 impute for ISR, COL, and CRI 	
//-------------------------------------

//for Israel, Colombia, and Costa Rica we impute the value of fdi interest as the product of 
//residual interest fdi from non-haven countries and the DI share of each country relative to 
//global DI as computed in step 2 
	
//inward data
use "$work/othercountrylosses_nonEU_inward_$temp", clear
isocodes partner, gen(iso3c)
rename iso3c ISO3
replace ISO3 = "CHN" if partner == "CN_X_HK"
replace ISO3 = "EXT_EU28" if partner == "EXT_EU28"
replace ISO3 = "EXT_EU_NAL" if partner == "EXT_EU_NAL"
replace ISO3 = "MAG" if partner == "MAGR"
replace ISO3 = "OFF" if partner == "OFFSHO"
replace ISO3 = "ORG" if partner == "ORG_NEUR"	
rename imputed inward
keep ISO3 inward geo_label
duplicates drop ISO3 geo_label inward, force
keep if geo_label == "Belgium" |geo_label == "Cyprus" |geo_label =="Ireland"|geo_label == "Luxembourg"|geo_label == "Malta" |geo_label =="Netherlands" 
reshape wide inward, i(ISO3) j(geo_label, string)
tempfile other_inward 
save `other_inward', replace 

//outward data

use "$work/othercountrylosses_nonEU_inward_$temp", clear
isocodes partner, gen(iso3c)
rename iso3c ISO3
replace ISO3 = "CHN" if partner == "CN_X_HK"
replace ISO3 = "EXT_EU28" if partner == "EXT_EU28"
replace ISO3 = "EXT_EU_NAL" if partner == "EXT_EU_NAL"
replace ISO3 = "MAG" if partner == "MAGR"
replace ISO3 = "OFF" if partner == "OFFSHO"
replace ISO3 = "ORG" if partner == "ORG_NEUR"	
rename imputed outward
keep ISO3 outward geo_label
duplicates drop ISO3 geo_label outward, force
keep if geo_label == "Belgium" |geo_label == "Cyprus" |geo_label =="Ireland"|geo_label == "Luxembourg"|geo_label == "Malta" |geo_label =="Netherlands" 
reshape wide outward, i(ISO3) j(geo_label, string)


merge 1:1 ISO3 using `other_inward', nogen

//build total as inward + outward 
foreach name in "Belgium" "Cyprus" "Ireland" "Luxembourg" "Malta" "Netherlands" {
	replace inward`name' = 0 if inward`name'==.
	replace outward`name' = 0 if outward`name'==.
	replace outward`name' = outward`name' + inward`name'
	drop inward`name'
	rename outward`name' `name'
}

//compute the residual interest fdi from non-haven countries
foreach name in "Belgium" "Cyprus" "Ireland" "Luxembourg" "Malta" "Netherlands" {

	sum `name'
	local `name'_tot = r(sum)
	preserve 
	keep if ISO3 == "EXT_EU28"
	local `name'_eu = `name' 
	restore 
	preserve 
	keep if ISO3 == "MAG"
	local `name'_mag = `name' 
	restore 
	preserve 
	keep if ISO3 == "PHL"
	local `name'_phl = `name' 
	restore 
	preserve 
	keep if ISO3 == "EXT_EU_NAL"
	local `name'_ext = `name' 
	restore 
	local `name'_final = (``name'_eu' + ``name'_eu'  + ``name'_mag' + ``name'_phl' + ``name'_ext' - ``name'_tot')
	replace `name' = ``name'_final' if ISO3 == "" 
}


use `step4', clear 

foreach name in "Belgium" "Cyprus" "Ireland" "Luxembourg" "Malta" "Netherlands" {
	replace `name' = ``name'_final' if ISO3 == "ISR" | ISO3 == "COL" | ISO3 == "CRI" | ISO3 == "ROW"
	replace `name' = `name' * CDIS_col_AS if ISO3 == "ISR" | ISO3 == "COL" | ISO3 == "CRI" | ISO3 == "ROW"

}

tempfile step5 
save `step5', replace

//-----------------------------------------------
//step 6: construct variables for group totals
//----------------------------------------------- 

foreach name in "Belgium" "Cyprus" "Ireland" "Luxembourg" "Malta" "Netherlands" "Rest" "Switzerland" {
										
replace `name'=0 if `name'==.
sum `name' if ISO3 != "WLD"
local wld_tot = r(sum)
replace `name'= `wld_tot' if ISO3=="WLD"			//populate world variable
}


gen EU_havens_interest = . 
replace EU_havens_interest = Belgium + Cyprus + Ireland + Luxembourg + Malta + Netherlands

gen Non_EU_havens_interest = . 
replace Non_EU_havens_interest = Switzerland + Rest

gen All_havens_interest = . 
replace All_havens_interest = Non_EU_havens_interest + EU_havens_interest

foreach name in "Belgium" "Cyprus" "Ireland" "Luxembourg" "Malta" "Netherlands" "Rest" "Switzerland" {
										
rename `name' `name'_interest
}


tempfile step6
save `step6', replace

//-----------------------------------------------------------------------
//step 7: royalty, financial, and other service payments to EU havens
//-----------------------------------------------------------------------


//EU countries 

use "$work/credit_EUhaven_intraEU_$temp", clear
isocodes partner_l, gen(iso3c)
rename iso3c ISO3 
keep ISO3 geo_label imputed 
keep if geo_label == "Belgium" |geo_label == "Cyprus" |geo_label =="Ireland"|geo_label == "Luxembourg"|geo_label == "Malta" |geo_label =="Netherlands" 

reshape wide imputed, i(ISO3) j(geo_label, string)

foreach name in "Belgium" "Cyprus" "Ireland" "Luxembourg" "Malta" "Netherlands" {
										
rename imputed`name' `name'
}
tempfile tf
save `tf', replace

use `step6', clear
merge 1:1 ISO3 using `tf', nogen 
tempfile step7
save `step7', replace


//non-EU countries 

use "$work/ser_other_co_loss_nonEU_$temp", clear 
keep if geo_label == "Belgium" |geo_label == "Cyprus" |geo_label =="Ireland"|geo_label == "Luxembourg"|geo_label == "Malta" |geo_label =="Netherlands" 

isocodes partner_l, gen(iso3c)
replace iso3c = "CHN" if iso3c == "HKG"
drop if iso3c == ""

rename iso3c ISO3 
rename dodgy_imputed imputed 
keep ISO3 geo_label imputed 
reshape wide imputed, i(ISO3) j(geo_label, string)


tempfile tf2
save `tf2', replace

use `step7', clear
merge 1:1 ISO3 using `tf2', nogen 

foreach name in "Belgium" "Cyprus" "Ireland" "Luxembourg" "Malta" "Netherlands" {
		
	replace `name' = imputed`name' if `name' == . & imputed`name' !=. 
	drop imputed`name'
	}

foreach name in "Belgium" "Cyprus" "Ireland" "Luxembourg" "Malta" "Netherlands" {
										//change currency from EUR to USD 
replace `name'=`name'/$USD_EUR
}
	
	
	
save `step7', replace

//-------------------------------------
//Step 8 impute for ISR, COL, and CRI 	
//-------------------------------------

//for Israel, Colombia, and Costa Rica we impute the value of service payments as the product of 
//residual service payments from non-haven countries and the DI share of each country relative to 
//global DI as computed in step 2 


use "$work/ser_other_co_loss_nonEU_$temp", clear 
keep if geo_label == "Belgium" |geo_label == "Cyprus" |geo_label =="Ireland"|geo_label == "Luxembourg"|geo_label == "Malta" |geo_label =="Netherlands" 

isocodes partner_l, gen(iso3c)
rename iso3c ISO3
rename dodgy_imputed imputed
replace ISO3 = "CHN" if ISO3 == "HKG"
replace ISO3 = "EXT_EU28" if partner_l == "Extra-EU27 (from 2020)"
replace ISO3 = "EXT_EU_NAL" if partner_l == "Extra-EU, not allocated"
replace ISO3 = "MAG" if partner_l == "Maghreb"
replace ISO3 = "MASH" if partner_l == "Mashrek"
replace ISO3 = "OFF" if partner_l == "Offshore financial centers"
replace ISO3 = "ORG" if partner_l == "Non European International Organizations"	

keep ISO3 geo_label imputed 
reshape wide imputed, i(ISO3) j(geo_label, string)


//compute the residual service payments from non-haven countries
foreach name in "Belgium" "Cyprus" "Ireland" "Luxembourg" "Malta" "Netherlands" {

	rename imputed`name' `name'
	sum `name'
	local `name'_tot = r(sum)
	preserve 
	keep if ISO3 == "EXT_EU28"
	local `name'_eu = `name' 
	restore 
	preserve 
	keep if ISO3 == "MAG"
	local `name'_mag = `name' 
	restore 
	preserve 
	keep if ISO3 == "MASH"
	local `name'_mash = `name'
	restore 
	preserve 
	keep if ISO3 == "PHL"
	local `name'_phl = `name' 
	restore 
	preserve 
	keep if ISO3 == "EXT_EU_NAL"
	local `name'_ext = `name' 
	restore 
	local `name'_final = (``name'_eu' + ``name'_eu'  + ``name'_mag' + ``name'_mash' + ``name'_phl' + ``name'_ext' - ``name'_tot')
}

use `step7', clear 

foreach name in "Belgium" "Cyprus" "Ireland" "Luxembourg" "Malta" "Netherlands" {
	replace `name' = ``name'_final' if ISO3 == "ISR" | ISO3 == "COL" | ISO3 == "CRI" | ISO3 == "ROW"
	replace `name' = `name' * CDIS_col_AS if ISO3 == "ISR" | ISO3 == "COL" | ISO3 == "CRI" | ISO3 == "ROW"

}

tempfile step8 
save `step8', replace

//-----------------------------------------------------------------------
//step 9: royalty, financial, and other service payments to non-EU havens
//-----------------------------------------------------------------------

//Switzerland as counterpart

//EU countries 
//for EU countries, there are three methods possible to compute this value 



// (1) using swiss pivot data

use "$work/swiss_pivot_$temp", clear

isocodes country, gen (iso3c)
rename iso3c ISO3 
drop if ISO3 == "" 
rename sum_total Swiss
keep ISO3 Swiss
tempfile swiss
save `swiss', replace

use `step8', clear 
merge 1:1 ISO3 using `swiss', nogen 
tempfile step9
save `step9', replace
// (2) import from Eurostat service payments data 
local temp = $temp 
use "$work/debit_nonEU_`temp'CH", clear 

isocodes geo_label, gen(iso3c)
rename iso3c ISO3 
rename imputed Switzerland 
keep ISO3 Switzerland 
//currency change for EU countries  from euro to USD
replace Switzerland=Switzerland/$USD_EUR
tempfile che 
save `che', replace 

use `step9', clear 
merge 1:1 ISO3 using `che', nogen 
replace Swiss = Switzerland if Swiss == . 
drop Switzerland
rename Swiss Switzerland

save `step9', replace

//for non-EU countries, we take the product of each country's DI share as total DI in high-risk services 
//and the residual calculated in table "non-EU tax havens"

//building value I8 = D8 - H8 - G8 

//D8 
//obtained from above using local `D8'

//G8 
//to be converted to USD 
use "$work/debit_nonEU_`temp'CH", clear 
sum imputed 
local total_che = (r(sum)/$USD_EUR)


//H8 
import excel "$rawdata/US_BEA_imports", sheet ("for_stata") firstrow clear 
keep if country == "Switzerland"
sum y_$temp 
local che_usa = r(sum)

//I8
local I8 = `D8' - `total_che' - `che_usa'

use `step9', clear 

replace Switzerland = `I8' * CDIS_col_AK if Switzerland==. & CDIS_col_AK!= 0 

save `step9', replace 


//Rest as counterpart 
//EU countries: import from Eurostat service payments data 

local temp = $temp 
use "$work/debit_nonEU_`temp'OFFSHO", clear 

isocodes geo_label, gen(iso3c)
rename iso3c ISO3 
rename imputed Rest 
keep ISO3 Rest 
//currency change for EU countries from EU to USD 
replace Rest=Rest/$USD_EUR
tempfile rest 
save `rest', replace 

use `step9', clear 
merge 1:1 ISO3 using `rest', nogen 
save `step9', replace 

//for non-EU countrieswe take the product of each country's DI share as total DI in high-risk services 
//and the residual calculated in table "non-EU tax havens"

//building value I13 = D13 - H13 - G13 

//D13 = sum(D9:D12)
//D9, use value from above 
//D10, use value from above 
//D11, use value from above as C11 - E11 
local D11 = `non_oecd' - `E11'

//D12, import the value of exports of Puerto Rico for Pharamaceuticals
import excel "$rawdata/Wright_Zucman", sheet ("PRI_exports") firstrow clear 
keep y_$temp
sum y_$temp 
local D12 = r(mean)

local D13 = `D9' +`D10'+`D11'+`D12'
display `D13'

//H13 = sum(H9:H12)
//H9, H10, and H11 derive from BEA 
import excel "$rawdata/US_BEA_imports", sheet ("for_stata") firstrow clear 
preserve
keep if country == "Hong Kong"
sum y_$temp 
local hkg_usa = r(sum)		//H10
restore 
preserve
keep if country == "Singapore"
sum y_$temp 
local sgp_usa = r(sum)		//H9
restore 
preserve 
drop if country == "Singapore" | country == "Hong Kong" | country == "Switzerland"
sum y_$temp
local rest_usa = r(sum)		//H11
restore

//H12 
import excel "$rawdata/Wright_Zucman", sheet ("PRI_trade_balance") clear 
keep if L == "      Recorded exports, total" | L == "        United States"
destring K, replace 
sum K if L == "      Recorded exports, total"
local denominator = r(mean)
sum K if L == "        United States"
local nominator = r(mean)
local pri_trade_balance = `nominator'/`denominator'
local H12 = `D12'*`pri_trade_balance'

//H13 
local H13 = `H12' + `hkg_usa' + `sgp_usa' + `rest_usa'
display `H13'

//G13 
use "$work/debit_nonEU_`temp'OFFSHO", clear 
sum imputed 
local total_offsho = (r(sum)/$USD_EUR)

//I13 
local I13 = `D13' - `total_offsho' - `H13'

use `step9', clear
replace Rest = `I13' * CDIS_col_AC if Rest == . & CDIS_col_AC!=0
replace Rest = `I13' *CDIS_col_AK if ISO3 == "ISL" & Rest ==. 

//replace value for USA using computed value H13
replace Rest = `H13' if ISO3 == "USA"
save `step9', replace 

//-----------------------------------------------
//step 10: construct variables for group totals
//----------------------------------------------- 

foreach name in "Belgium" "Cyprus" "Ireland" "Luxembourg" "Malta" "Netherlands" "Rest" "Switzerland" {
										
replace `name'=0 if `name'==.
sum `name' if ISO3 != "WLD"
local wld_tot = r(sum)
replace `name'= `wld_tot' if ISO3=="WLD"			//populate world variable
}




gen EU_havens_services = . 
replace EU_havens_services = Belgium + Cyprus + Ireland + Luxembourg + Malta + Netherlands

gen Non_EU_havens_services = . 
replace Non_EU_havens_services = Switzerland + Rest

gen All_havens_services = . 
replace All_havens_services = Non_EU_havens_services + EU_havens_services

foreach name in "Belgium" "Cyprus" "Ireland" "Luxembourg" "Malta" "Netherlands" "Rest" "Switzerland" {
										
rename `name' `name'_services
}
//drop unnecessary countries 
drop if EU==. 

//Final reoredering and export results
gen sort_dummy=.
replace sort_dummy=1 if group=="OECD"
replace sort_dummy=2 if group=="OECD_TH"
replace sort_dummy=3 if group=="DEV"
replace sort_dummy=4 if group=="NEW_DEV"
replace sort_dummy=5 if group=="other" 
sort sort_dummy ISO3 
drop sort_dummy
order country ISO3 EU group 
drop CDIS_col_AC CDIS_col_AS CDIS_col_AK

tempfile step10
save `step10', replace

//drop Venezuela outside of the analysis for the time being, as CIT revenue data is missing since 2017
drop if ISO3 == "VEN"


save "$work/table_C1_$temp", replace 
export excel using "$root/output/Part2-reallocating-profits-$temp.xlsx", firstrow(var) sheet("Table C1", replace) keepcellfmt

cd "$code"
