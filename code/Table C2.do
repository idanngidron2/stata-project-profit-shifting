




//-------------
//Table C2
//-------------

//---------------------------
//Step 1: data structure
//---------------------------

//we import the data structure from table C1 

use "$work/table_C1_$temp", clear 

foreach var of varlist _all {

	if "`var'"!= "group" & "`var'"!= "country" & "`var'" != "EU" & "`var'" != "ISO3" {
		
	replace `var'=.
		
	}

}

tempfile step1
save `step1', replace

keep ISO3 group EU country 
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

merge m:m ISO3 using `step1'
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
sum DI_ratio if (ISO3 == "ARG"| ISO3 == "COL" | ISO3 == "CRI" | ISO3 == "EGY" | ISO3 == "IDN" | ISO3 == "ISL"| ISO3 == "KOR" | ISO3 == "NGA" | ISO3 == "NZL" | ISO3 == "ROW" | ISO3 == "THA" | ISO3 == "URY")
local denominator2 = r(sum)
replace CDIS_col_AK = DI_ratio/`denominator2' if (ISO3 == "ARG"| ISO3 == "COL" | ISO3 == "CRI" | ISO3 == "EGY" | ISO3 == "IDN" | ISO3 == "ISL"| ISO3 == "KOR" | ISO3 == "NGA" | ISO3 == "NZL" | ISO3 == "ROW" | ISO3 == "THA" | ISO3 == "URY")
replace CDIS_col_AK = 0 if CDIS_col_AK == . 


order country ISO3 EU group CDIS_col_AC CDIS_col_AK CDIS_col_AS 
keep country ISO3 EU group CDIS_col_AC CDIS_col_AK CDIS_col_AS
tempfile step2
save `step2', replace


//------------------------------------------
//Step 3: speculative tax losses: EU havens
//------------------------------------------

//first EU countries

// (i) // generate locals for GDP values using table U1

use "$work/shifted_profits_U1_$temp", clear 

keep ISO3 GDP group
replace GDP = GDP  * $USD_EUR	* 1000		//from USD bln to mln and from USD to EURO

preserve
replace ISO3 = "Belgium" if ISO3 == "BEL"
replace ISO3 = "Cyprus" if ISO3 == "CYP"
replace ISO3 = "Ireland" if ISO3 == "IRL"
replace ISO3 = "Luxembourg" if ISO3 == "LUX"
replace ISO3 = "Malta" if ISO3 == "MLT"
replace ISO3 = "Netherlands" if ISO3 == "NLD"
replace ISO3 = "Switzerland" if ISO3 == "CHE"


foreach name in "Belgium" "Cyprus" "Ireland" "Luxembourg" "Malta" "Netherlands" "Switzerland" "WLD" "SGP" "HKG" "PRI" {
	
	sum GDP if ISO3=="`name'" 
	local GDP_`name'= r(mean) 
	
}
restore


//compute GDP of EU22 (EU28 net of EU havens)
preserve
keep if ISO3 == "AUT" |ISO3 == "BGR" |ISO3 == "CZE" |ISO3 == "DNK" |ISO3 == "EST" |ISO3 == "FIN" |ISO3 == "FRA" |ISO3 == "DEU" |ISO3 == "GRC" |ISO3 == "HUN" |ISO3 == "ISL" |ISO3 == "ROU" |ISO3 == "ITA" |ISO3 == "LVA" |ISO3 == "HRV" |ISO3 == "POL" |ISO3 == "PRT" |ISO3 == "SVK" |ISO3 == "SVN" |ISO3 == "ESP" |ISO3 == "SWE" |ISO3 == "GBR" 
sum GDP
local GDP_EU22 = r(sum) 
restore 

//compute GDP of all non-OECD tax havens 

sum GDP if group=="TH"
local GDP_OFFSHO = r(sum)

//compute GDP of all non-EU 


drop if ISO3 == "AUT" |ISO3 == "BGR" |ISO3 == "CZE" |ISO3 == "DNK" |ISO3 == "EST" |ISO3 == "FIN" |ISO3 == "FRA" |ISO3 == "DEU" |ISO3 == "GRC" |ISO3 == "HUN" |ISO3 == "ISL" |ISO3 == "ROU" |ISO3 == "ITA" |ISO3 == "LVA" |ISO3 == "HRV" |ISO3 == "POL" |ISO3 == "PRT" |ISO3 == "SVK" |ISO3 == "SVN" |ISO3 == "ESP" |ISO3 == "SWE" |ISO3 == "GBR" | ISO3 =="BEL" | ISO3 == "CYP" | ISO3 == "LUX" | ISO3 == "IRL" | ISO3 == "MLT" | ISO3 == "NLD" | ISO3 == "ROW" | ISO3 == "WLD"

sum GDP
local GDP_non_EU = r(sum)


// (ii) // import interest payments to European havens


use "$work/intra_eu_breakdown_credit_inward_$temp", clear
isocodes partner, gen(iso3c)
rename iso3c ISO3 
rename imputed inward
keep ISO3 inward geo_label

//create a variable for "other eu countries" i.e. EU net of of EU tax havens
preserve 
drop if geo_label == "Belgium" |geo_label == "Cyprus" |geo_label =="Ireland"|geo_label == "Luxembourg"|geo_label == "Malta" |geo_label =="Netherlands" | geo_label=="European Union - 27 countries (from 2020)" | geo_label == "European Union - 28 countries (2013-2020)" 
collapse (sum) inward, by (ISO3)
replace ISO3 = "EU_28" if ISO3 == ""
rename inward other_european
tempfile other_eu_inward 
save `other_eu_inward', replace
restore


keep if geo_label == "Belgium" |geo_label == "Cyprus" |geo_label =="Ireland"|geo_label == "Luxembourg"|geo_label == "Malta" |geo_label =="Netherlands"
reshape wide inward, i(ISO3) j(geo_label, string)
replace ISO3 = "EU_28" if ISO3 == ""
	

tempfile inward
save `inward', replace

use "$work/intra_eu_breakdown_credit_outward_$temp", clear

*keep if geo_label == "Belgium" |geo_label == "Cyprus" |geo_label =="Ireland"|geo_label == "Luxembourg"|geo_label == "Malta" |geo_label =="Netherlands" 

isocodes partner_l, gen(iso3c)
rename iso3c ISO3 
rename imputed outward

keep ISO3 outward geo_label
duplicates drop ISO3 geo_label outward, force

//create a variable for "other eu countries" i.e. EU net of of EU tax havens


preserve 
drop if geo_label == "Belgium" |geo_label == "Cyprus" |geo_label =="Ireland"|geo_label == "Luxembourg"|geo_label == "Malta" |geo_label =="Netherlands" | geo_label=="European Union - 27 countries (from 2020)" | geo_label == "European Union - 28 countries (2013-2020)" 
collapse (sum) outward, by (ISO3)
replace ISO3 = "EU_28" if ISO3 == ""
rename outward other_european_out
tempfile other_eu_outward 
save `other_eu_outward', replace
restore

keep if geo_label == "Belgium" |geo_label == "Cyprus" |geo_label =="Ireland"|geo_label == "Luxembourg"|geo_label == "Malta" |geo_label =="Netherlands"
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

merge 1:1 ISO3 using `other_eu_inward', nogen
merge 1:1 ISO3 using `other_eu_outward', nogen 

replace other_european = other_european + other_european_out
drop other_european_out



// (iii) // generate values for EU22 (EU28 net of EU havens)

foreach name in "Belgium" "Cyprus" "Ireland" "Luxembourg" "Malta" "Netherlands" "other_european"{

	sum `name' if ISO3 == "BEL"
	local `name'_BEL = r(mean)
	sum `name' if ISO3 == "CYP"
	local `name'_CYP = r(mean)
	sum `name' if ISO3 == "IRL"
	local `name'_IRL = r(mean)
	sum `name' if ISO3 == "LUX"
	local `name'_LUX = r(mean)
	sum `name' if ISO3 == "MLT"
	local `name'_MLT = r(mean)
	sum `name' if ISO3 == "NLD"
	local `name'_NLD = r(mean)
	sum `name' if (ISO3!="GBR" & ISO3!="EU_28")
	local `name'_EU28 = r(sum)
	replace `name' = ``name'_EU28' - ``name'_BEL' - ``name'_CYP' - ``name'_IRL' - ``name'_LUX' - ``name'_MLT' - ``name'_NLD' if ISO3 == "EU_28"
}

replace ISO3 = "EU22" if ISO3 == "EU_28"


// (iv) // compute speculative tax losses 


//	replace `name' = `name' - `name'/(T46/Z46)

//T46 = T41/B54

//B54 = `GDP_ISO'

//T41 = `name' if ISO3 == EU22


//Z46 = Z41/H54

//Z41 = "other countries" if ISO3 == EU22

sum other_european if ISO3 == "EU22"
local other_EU22 = r(mean)

//H54

foreach name in "Belgium" "Cyprus" "Ireland" "Luxembourg" "Malta" "Netherlands" {

	sum `name' if ISO3 == "EU22"
	local `name'EU22 = r(mean)
	local numerator = (``name'EU22'/`GDP_`name'')
	local denominator = (`other_EU22'/`GDP_EU22')
	local rattio = (`numerator'/`denominator')
	replace `name' = `name' - (`name'/`rattio')


}

drop other_european
drop if ISO3 == "EU22"
tempfile eu_speculative_tax 
save `eu_speculative_tax', replace 



//second, non-EU countries 
//inward
use "$work/othercountrylosses_nonEU_inward_$temp", clear
isocodes partner, gen(iso3c)
rename iso3c ISO3
replace ISO3 = "CHN" if partner == "CN_X_HK"
replace ISO3 = "EXT_EU28" if partner == "EXT_EU28"
replace ISO3 = "EXT_EU_NAL" if partner == "EXT_EU_NAL"
replace ISO3 = "OFFSHO" if partner == "OFFSHO"
drop if ISO3 == ""
rename imputed inward


//create a variable for "other eu countries" i.e. EU net of of EU tax havens
preserve 
drop if geo_label == "Belgium" |geo_label == "Cyprus" |geo_label =="Ireland"|geo_label == "Luxembourg"|geo_label == "Malta" |geo_label =="Netherlands" | geo_label=="European Union - 27 countries (from 2020)" | geo_label == "European Union - 28 countries (2013-2020)" 
collapse (sum) inward, by (ISO3)
rename inward other_european
tempfile other_eu_inward 
save `other_eu_inward', replace
restore


keep ISO3 inward geo_label
keep if geo_label == "Belgium" |geo_label == "Cyprus" |geo_label =="Ireland"|geo_label == "Luxembourg"|geo_label == "Malta" |geo_label =="Netherlands"
reshape wide inward, i(ISO3) j(geo_label, string)

tempfile inward
save `inward', replace

//outward
use "$work/othercountrylosses_nonEU_outward_$temp", clear
isocodes partner, gen(iso3c)
rename iso3c ISO3
replace ISO3 = "CHN" if partner == "CN_X_HK"
replace ISO3 = "EXT_EU28" if partner == "EXT_EU28"
replace ISO3 = "EXT_EU_NAL" if partner == "EXT_EU_NAL"
replace ISO3 = "OFFSHO" if partner == "OFFSHO"
drop if ISO3 == ""
rename imputed outward


//create a variable for "other eu countries" i.e. EU net of of EU tax havens
preserve 
drop if geo_label == "Belgium" |geo_label == "Cyprus" |geo_label =="Ireland"|geo_label == "Luxembourg"|geo_label == "Malta" |geo_label =="Netherlands" | geo_label=="European Union - 27 countries (from 2020)" | geo_label == "European Union - 28 countries (2013-2020)" 
collapse (sum) outward, by (ISO3)
replace ISO3 = "EU_28" if ISO3 == ""
rename outward other_european_out
tempfile other_eu_outward 
save `other_eu_outward', replace
restore

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

merge 1:1 ISO3 using `other_eu_inward', nogen
merge 1:1 ISO3 using `other_eu_outward', nogen 

replace other_european = other_european + other_european_out
drop other_european_out



foreach name in "Belgium" "Cyprus" "Ireland" "Luxembourg" "Malta" "Netherlands" {
	sum `name' if ISO3 == "EXT_EU28"
	local ext_eu28 = r(mean)
	sum `name' if (ISO3 == "CHE" | ISO == "OFFSHO")
	local offsho = r(sum)
	local noneu_nonhaven = `ext_eu28' - `offsho'
	local `name'_int_gdp = (`noneu_nonhaven'/`GDP_`name'')
*	replace `name' = `noneu_nonhaven' if ISO3 == "CHE"
*	replace ISO3 = "NONEU_NONHAVEN" if ISO3 == "CHE"
	
}

sum other_european if ISO3 == "EXT_EU28"
local ext_eu28 = r(mean)
sum other_european if (ISO3 == "CHE" | ISO == "OFFSHO")
local offsho = r(sum)
local noneu_nonhaven = `ext_eu28' - `offsho'
local eu22_int_gdp = (`noneu_nonhaven'/`GDP_EU22')
drop other_european

foreach name in "Belgium" "Cyprus" "Ireland" "Luxembourg" "Malta" "Netherlands" {

	replace `name' = (`name' * (1- (`eu22_int_gdp'/``name'_int_gdp')))

}

tempfile noneu_speculative_tax
save `noneu_speculative_tax', replace 

append using `eu_speculative_tax'

merge 1:1 ISO3 using `step2', nogen 

tempfile step3
save `step3', replace 

//-------------------------------------------------
//Step 4: compute values for ISR COL CRI and ROW 
//-------------------------------------------------


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
	local `name'_ffinal = (``name'_final' * (1- (`eu22_int_gdp'/``name'_int_gdp')))
	
	}

	display `Belgium_ffinal'

use `step3', clear 

foreach name in "Belgium" "Cyprus" "Ireland" "Luxembourg" "Malta" "Netherlands" {
	replace `name' = ``name'_ffinal' if ISO3 == "ISR" | ISO3 == "COL" | ISO3 == "CRI" | ISO3 == "ROW"
	replace `name' = `name' * CDIS_col_AS if ISO3 == "ISR" | ISO3 == "COL" | ISO3 == "CRI" | ISO3 == "ROW"
	replace `name' = -`name' if `name' <0
}




//rearrange the data 

drop if ISO3 == "OFFSHO" | ISO3 == "EXT_EU28" | ISO3 == "EXT_EU_NAL"| group ==""
foreach name in "Belgium" "Cyprus" "Ireland" "Luxembourg" "Malta" "Netherlands" {
replace `name' = `name'/$USD_EUR
rename `name' `name'_int

}

order country ISO3 group EU Belgium_int Cyprus_int Ireland_int Luxembourg_int Malta_int Netherlands_int
gsort -group ISO3

tempfile step4 
save `step4', replace


//------------------------------------------
//Step 5: excess payments to non-EU havens
//------------------------------------------


//Switzerland, EU countries 

//take sum of inward and outward for other non-EU
use "$work/nonEU_debitint_nonEUhav_inward_$temp", clear
drop if geo_label=="European Union - 27 countries (from 2020)"
drop if bop_fdi6_inc$temp !=. & geo_label=="Ireland"		//keep only imputed values for ireland
keep if partner == "EXT_EU28"
keep partner geo_label imputed
rename imputed other_non_EU
tempfile other
save `other', replace

use "$work/nonEU_breakdown_debitint_nonEUhaven_outward_$temp", clear
drop if bop_fdi6_inc$temp !=. & geo_label=="Ireland"		//keep only imputed values for ireland
keep if partner == "EXT_EU28"

merge 1:1 partner geo_label using `other'
replace other_non_EU = other_non_EU + imputed 

isocodes geo_label, gen (iso3c)
rename iso3c ISO3
keep ISO3 other_non_EU

sum other_non_EU if (ISO3 != "BEL" & ISO3 != "CYP" & ISO3 != "LUX" & ISO3 != "IRL" & ISO3 != "MLT" & ISO3 != "NLD")
local other_eu22 = r(sum)



//take sum of inward and outward for Switzerland
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
keep ISO3 Switzerland

sum Switzerland if (ISO3 != "BEL" & ISO3 != "CYP" & ISO3 != "LUX" & ISO3 != "IRL" & ISO3 != "MLT" & ISO3 != "NLD")
local eu22 = r(sum)

local swiss_int_gdp = `eu22'/`GDP_Switzerland'
local other_int_gdp = `other_eu22'/`GDP_non_EU'

replace Switzerland = Switzerland - (Switzerland/(`swiss_int_gdp'/`other_int_gdp'))

//currency change for EU countries from euro to USD
replace Switzerland=Switzerland/$USD_EUR		


tempfile che
save `che', replace

//Rest, EU countries 


//take sum of inward and outward for Offshore centres
use "$work/nonEU_debitint_nonEUhav_inward_$temp", clear
drop if geo_label=="European Union - 27 countries (from 2020)"
drop if bop_fdi6_inc$temp !=. & geo_label=="Ireland"		//keep only imputed values for ireland
keep if partner == "OFFSHO"
keep partner geo_label imputed
rename imputed Rest
tempfile rest
save `rest', replace

use "$work/nonEU_breakdown_debitint_nonEUhaven_outward_$temp", clear
drop if bop_fdi6_inc$temp !=. & geo_label=="Ireland"		//keep only imputed values for ireland
keep if partner == "OFFSHO"

merge 1:1 partner geo_label using `rest'
replace Rest = Rest + imputed 

isocodes geo_label, gen (iso3c)
rename iso3c ISO3
keep ISO3 Rest

sum Rest if (ISO3 != "BEL" & ISO3 != "CYP" & ISO3 != "LUX" & ISO3 != "IRL" & ISO3 != "MLT" & ISO3 != "NLD")
local eu22 = r(sum)

local rest_int_gdp = `eu22'/`GDP_OFFSHO'
local other_int_gdp = `other_eu22'/`GDP_non_EU'

replace Rest = Rest - (Rest/(`rest_int_gdp'/`other_int_gdp'))

//currency change for EU countries from euro to USD
replace Rest=Rest/$USD_EUR		


merge 1:1 ISO3 using `che', nogen 

tempfile step5 
save `step5', replace 

use `step4', clear 
merge 1:1 ISO3 using `step5', nogen 

save `step5', replace


//Switzerland, non-EU countries 



use "$work/IMF_fdi_interest_$temp", clear
rename _ISO3C_ ISO3
keep ISO3 DI_interest_Credit
sum DI_interest_Credit if ISO3 == "CHE"
local switzerland = (r(mean)/1000000) 	//transforming from USD to USD mln
sum DI_interest_Credit
local world = (r(sum)/1000000) 			//transforming from USD to USD mln
sum DI_interest_Credit if ISO3 == "HKG"
local hkg = (r(mean)/1000000) 			//transforming from USD to USD mln


//J8 

use "$work/nonEU_debitint_nonEUhav_inward_$temp", clear
keep if partner == "CH"
keep imputed partner geo_label
drop if geo_label == "European Union - 27 countries (from 2020)"
sum imputed 
local total_ = (r(sum)/$USD_EUR)

//K8 					 

local swiss_interest = `switzerland' - `total_'


//Q8 

local Q8 = (`GDP_Switzerland'/`GDP_WLD')

//S8 

local S8 = (`switzerland'/`world')


//L8 

local L8 = (`switzerland' * (1-(`Q8'/`S8')))

//M8 

local M8 = (`L8' * (`swiss_interest'/`switzerland'))

use `step5', clear 

replace Switzerland = `M8' * CDIS_col_AC if EU!=1 
replace Switzerland = `M8' * CDIS_col_AK if ISO3 == "ISL"
save `step5', replace 

//counterpart Rest, Non-EU countries


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


//S9, S10, S11

local S9 = (`sgp'/`world')
local S10 = (`hkg'/`world')
local S11 = (`E11'/`world')

//Q9, Q10

local Q9 = (`GDP_SGP'/`GDP_WLD')
local Q10 = (`GDP_HKG'/`GDP_WLD')
local Q11 = 0		//set to zero 
local Q12 = (`GDP_PRI'/`GDP_WLD')

//L9, L10, L11, L13

local L9 = (`sgp'*(1-(`Q9'/`S9')))
local L10 = (`hkg'*(1-(`Q10'/`S10')))
local L11 = (`E11'*(1-(`Q11'/`S11')))
local L13 = `L9' + `L10' + `L11'

//M13 

local M13 = `L13' * (`K13'/`E13')

use `step5', clear 

replace Rest = `M13' * CDIS_col_AC if EU!=1 
replace Rest = `M13' * CDIS_col_AK if ISO3 == "ISL"

//reorder data and populate world total

gsort -group ISO3
drop if group ==""

rename Rest Rest_int 
rename Switzerland Switzerland_int 

foreach name in "Belgium" "Cyprus" "Ireland" "Luxembourg" "Malta" "Netherlands" "Rest" "Switzerland" {

	sum `name'_int 
	replace `name'_int = r(sum) if ISO3 == "WLD"
}

*tempfile rest 
*save `rest', replace
*use `step5', clear 
*merge 1:1 ISO3 using `rest', nogen 
save `step5', replace 

//-------------------------------------------------
//Step 6: excessive service payments to EU havens
//-------------------------------------------------


//EU countries 

use "$work/credit_EUhaven_intraEU_$temp", clear
isocodes partner_l, gen(iso3c)
rename iso3c ISO3 


//create a variable for "other eu countries" i.e. EU net of of EU tax havens
preserve 
drop if geo_label == "Belgium" |geo_label == "Cyprus" |geo_label =="Ireland"|geo_label == "Luxembourg"|geo_label == "Malta" |geo_label =="Netherlands" | geo_label=="European Union - 27 countries (from 2020)" | geo_label == "European Union - 28 countries (2013-2020)" 
collapse (sum) imputed, by (ISO3)
replace ISO3 = "EU_28" if ISO3 == ""
rename imputed other_european
tempfile other_eu
save `other_eu', replace
restore

keep if geo_label == "Belgium" |geo_label == "Cyprus" |geo_label =="Ireland"|geo_label == "Luxembourg"|geo_label == "Malta" |geo_label =="Netherlands" 

keep ISO3 geo_label imputed 
reshape wide imputed, i(ISO3) j(geo_label, string)
replace ISO3 = "EU_28" if ISO3 == ""

foreach name in "Belgium" "Cyprus" "Ireland" "Luxembourg" "Malta" "Netherlands" {
										
rename imputed`name' `name'
}
tempfile tf
save `tf', replace

merge 1:1 ISO3 using `other_eu', nogen

// generate values for EU22 (EU28 net of EU havens)

foreach name in "Belgium" "Cyprus" "Ireland" "Luxembourg" "Malta" "Netherlands" "other_european"{

	sum `name' if ISO3 == "BEL"
	local `name'_BEL = r(mean)
	sum `name' if ISO3 == "CYP"
	local `name'_CYP = r(mean)
	sum `name' if ISO3 == "IRL"
	local `name'_IRL = r(mean)
	sum `name' if ISO3 == "LUX"
	local `name'_LUX = r(mean)
	sum `name' if ISO3 == "MLT"
	local `name'_MLT = r(mean)
	sum `name' if ISO3 == "NLD"
	local `name'_NLD = r(mean)
	sum `name' if (ISO3!="GBR" & ISO3!="EU_28")
	local `name'_EU28 = r(sum)
	replace `name' = ``name'_EU28' - ``name'_BEL' - ``name'_CYP' - ``name'_IRL' - ``name'_LUX' - ``name'_MLT' - ``name'_NLD' if ISO3 == "EU_28"
}

replace ISO3 = "EU22" if ISO3 == "EU_28"
sum other_european if ISO3 == "EU22"
local other_EU22 = r(mean)

foreach name in "Belgium" "Cyprus" "Ireland" "Luxembourg" "Malta" "Netherlands"{

	sum `name' if ISO3 == "EU22"
	local `name'_EU22 = r(mean)
	replace `name'=`name' - (`name' / ((``name'_EU22'/`GDP_`name'')/(`other_EU22'/`GDP_EU22')))
	replace `name'=`name'/$USD_EUR

}
tempfile step6
save `step6', replace 

//non-EU countries 

use "$work/credit_intraEU_dodyhavens_$temp", clear 

collapse (sum) dodgy_imputed, by (partner_l)
isocodes partner_l, gen(iso3c)
rename iso3c ISO3 
keep ISO3 dodgy_imputed
tempfile tf2 
save `tf2', replace 

use "$work/credit_intraEU_dodgy_$temp", clear 
collapse (sum) dodgy_imputed, by (partner_l)
rename dodgy_imputed dodgy
isocodes partner_l, gen(iso3c)
rename iso3c ISO3 
keep ISO3 dodgy
merge 1:1 ISO3 using `tf2', nogen 
replace dodgy = dodgy - dodgy_imputed
drop dodgy_imputed

//create a few locals per tax haven group
sum dodgy
local eu28 = r(sum)
sum dodgy if (ISO3 != "BEL" & ISO3 != "CYP" & ISO3 != "LUX" & ISO3 != "IRL" & ISO3 != "MLT" & ISO3 != "NLD")
local eu22 = r(sum)
sum dodgy if ISO3 == "BEL"
local Belgium_dodgy = r(mean)
sum dodgy if ISO3 == "CYP"
local Cyprus_dodgy = r(mean)
sum dodgy if ISO3 == "LUX"
local Luxembourg_dodgy = r(mean)
sum dodgy if ISO3 == "IRL"
local Ireland_dodgy = r(mean)
sum dodgy if ISO3 == "MLT"
local Malta_dodgy = r(mean)
sum dodgy if ISO3 == "NLD"
local Netherlands_dodgy = r(mean)



use "$work/ser_other_co_loss_nonEU_$temp", clear 

keep if geo_label == "Belgium" |geo_label == "Cyprus" |geo_label =="Ireland"|geo_label == "Luxembourg"|geo_label == "Malta" |geo_label =="Netherlands" 
isocodes partner_l, gen(iso3c)
replace iso3c = "CHN" if iso3c == "HKG"
drop if iso3c == ""
rename iso3c ISO3 
rename dodgy_imputed imputed 
keep ISO3 geo_label imputed 
reshape wide imputed, i(ISO3) j(geo_label, string)

foreach name in "Belgium" "Cyprus" "Ireland" "Luxembourg" "Malta" "Netherlands" {
	rename imputed`name' `name'
	local `name'_denominator = (``name'_dodgy'/`GDP_`name'')
	local `name'_nominator = (`eu22'/`GDP_EU22')
	replace `name' = (`name' * (1-(``name'_nominator'/``name'_denominator')))
	display ``name'_nominator'
	display ``name'_denominator'

}

save `tf2', replace 
use `step6', clear
merge 1:1 ISO3 using `tf2', nogen
drop other_european

save `step6', replace 
use `step5', clear 
merge 1:1 ISO3 using `step6', nogen 
drop if group == ""
save `step6', replace 

//---------------------------------------------
//step7: compute values for ISR, CRI, COL, ROW
//---------------------------------------------

use "$work/ser_other_co_loss_nonEU_$temp", clear 
keep if geo_label == "Belgium" |geo_label == "Cyprus" |geo_label =="Ireland"|geo_label == "Luxembourg"|geo_label == "Malta" |geo_label =="Netherlands" 

isocodes partner_l, gen(iso3c)
rename iso3c ISO3
rename dodgy_imputed imputed
replace ISO3 = "CHN" if ISO3 == "HKG"
replace ISO3 = "EXT_EU28" if partner_l == "Extra-EU27 (from 2020)" | partner_l == "Extra-EU28 (2013-2020)"
replace ISO3 = "EXT_EU_NAL" if partner_l == "Extra-EU, not allocated"
replace ISO3 = "MAG" if partner_l == "Maghreb"
replace ISO3 = "MASH" if partner_l == "Mashrek"
replace ISO3 = "OFF" if partner_l == "Offshore financial centers"
replace ISO3 = "ORG" if partner_l == "Non European International Organizations"	

keep ISO3 geo_label imputed 
reshape wide imputed, i(ISO3) j(geo_label, string)

foreach name in "Belgium" "Cyprus" "Ireland" "Luxembourg" "Malta" "Netherlands" {
	rename imputed`name' `name'
	local `name'_denominator = (``name'_dodgy'/`GDP_`name'')
	local `name'_nominator = (`eu22'/`GDP_EU22')
	replace `name' = (`name' * (1-(``name'_nominator'/``name'_denominator')))
	display ``name'_nominator'
	display ``name'_denominator'

}



//compute the residual service payments from non-haven countries

	//we keep all countries which do not appear in our data, the sum of all values
	//will constitute our residual service payments value used for the rest of the world
	
	foreach name in "Belgium" "Cyprus" "Ireland" "Luxembourg" "Malta" "Netherlands" {
	
	replace `name' = 0 if (`name'==. | `name' <0)
	sum `name' if ISO3 == "EXT_EU_NAL"
	local `name'_final = r(mean)
	display ``name'_final'

	}
	
	/*
	replace `name' = 0 if `name'==.
*	sum `name'
*	local `name'_tot = r(sum)
	sum `name' if  (ISO3 != "EXT_EU28" & ISO3 != "EXT_EU_NAL")
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
	keep if ISO3 == "MAR"
	local `name'_mar = `name'
	restore 
	preserve 
	keep if ISO3 == "EXT_EU_NAL"
	local `name'_ext = `name' 
	restore 
	preserve 
	keep if ISO3 == "OFF"
	local `name'_off
*	local `name'_final = (``name'_eu' + ``name'_eu'  + ``name'_mag' + ``name'_mash' + ``name'_phl' + ``name'_ext' - ``name'_tot')
*	local `name'_final = 2 * (``name'_eu'  + ``name'_mag' + ``name'_mash' + ``name'_phl') + ``name'_ext' - ``name'_tot'
	local `name'_final = ``name'_eu'  + ``name'_mag' + ``name'_mash' + ``name'_phl' + ``name'_mar' + ``name'_ext' - ``name'_tot'
	display ``name'_final'
	}
*/


use `step6', clear 

foreach name in "Belgium" "Cyprus" "Ireland" "Luxembourg" "Malta" "Netherlands" {
	replace `name' = ``name'_final' if ISO3 == "ISR" | ISO3 == "COL" | ISO3 == "CRI" | ISO3 == "ROW"
	replace `name' = `name' * CDIS_col_AS if ISO3 == "ISR" | ISO3 == "COL" | ISO3 == "CRI" | ISO3 == "ROW"

}


tempfile step7 
save `step7', replace


//-----------------------------------------------
//Step 8: excessive payments to non-EU havens 
//-----------------------------------------------


//Switzerland as counterpart

//EU countries 
//for EU countries, there are three methods possible to compute this value 



// (1) using swiss pivot data


//construct excessive exports share 
use "$work/highriskexports_$temp", clear
preserve 
keep if country == "WLD"
sum yr$temp if indicatorname == "Charges for the use of intellectual property, receipts (BoP, current US$)"
local charges = r(mean)
sum yr$temp if indicatorname == "Insurance and financial services (% of service exports, BoP)"
local percent_finance = (r(mean)/100)
sum yr$temp if indicatorname == "Service exports (BoP, current US$)"
local service = r(mean)
sum yr$temp if indicatorname == "Communications, computer, etc. (% of service exports, BoP)"
local percent_ICT = (r(mean)/100)
local wld_exports = (`charges' + (`percent_finance'+`percent_ICT')*`service')/1000000 
restore 


//F8 = E8 + C8 
local F8 = `che_exports' + `switzerland'

//R8 = F8/high-risk$H7

local R8 = `F8'/`wld_exports'

//I2 = 1-1/(R8/Q8)

local excessive_exp_share = (1 - 1/(`R8'/`Q8'))

use "$work/swiss_pivot_$temp", clear			//values already in USD million

isocodes country, gen (iso3c)
rename iso3c ISO3 
drop if ISO3 == "" 
rename sum_total Swiss
keep ISO3 Swiss
replace Swiss = Swiss * `excessive_exp_share'
tempfile swiss
save `swiss', replace

use `step7', clear
merge 1:1 ISO3 using `swiss', nogen 
tempfile step8 
save `step8', replace 

// (2) import from Eurostat service payments data 
local temp = $temp 
use "$work/debit_nonEU_`temp'CH", clear 

isocodes geo_label, gen(iso3c)
rename iso3c ISO3 
rename imputed Switzerland 
keep ISO3 Switzerland 
//currency change for EU countries  from euro to USD
replace Switzerland=Switzerland/$USD_EUR

//create value for EU22 (EU28 net of EU tax havens)
foreach name in "BEL" "CYP" "IRL" "LUX" "MLT" "NLD" {
	
	sum Switzerland if ISO3 == "`name'"
	local `name' = r(mean)
}

sum Switzerland if (ISO3!="GBR" & ISO3!="EU_28")
local EU28 = r(sum)
local eu22_che = `EU28' - `BEL' - `CYP' - `IRL' - `LUX' - `MLT' - `NLD'
local H54 = (`eu22_che'/`GDP_Switzerland')

tempfile che 
save `che', replace 


use "$work/debit_nonEU_`temp'EXT_EU28", clear 

isocodes geo_label, gen(iso3c)
rename iso3c ISO3 
rename imputed other_non_EU 
keep ISO3 other_non_EU 
//currency change for EU countries  from euro to USD
replace other_non_EU=other_non_EU/$USD_EUR

//create value for EU22 (EU28 net of EU tax havens)
foreach name in "BEL" "CYP" "IRL" "LUX" "MLT" "NLD" {
	
	sum other_non_EU if ISO3 == "`name'"
	local `name' = r(mean)
}

sum other_non_EU if (ISO3!="GBR" & ISO3!="EU_28")
local EU28 = r(sum)
local eu22_other = `EU28' - `BEL' - `CYP' - `IRL' - `LUX' - `MLT' - `NLD'
local I54 = `eu22_other'/`GDP_non_EU'

use `che', clear 
display `H54'
display `I54'
replace Switzerland = Switzerland - Switzerland/(`H54'/`I54')

use `step8', clear 
merge 1:1 ISO3 using `che', nogen 
replace Swiss = Switzerland if Swiss == . 
drop Switzerland
rename Swiss Switzerland

save `step8', replace

// (iii) //for non-EU countries, we take the product of each country's DI share as total DI in high-risk services 
//and the excessive exports residual calculated in table "non-EU tax havens"

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

use `step8', clear 

replace Switzerland = `I8' * CDIS_col_AK if Switzerland==. & CDIS_col_AK!= 0 
replace Switzerland = -Switzerland if Switzerland <0
save `step8', replace 

//Rest as counterpart

// (1) import from Eurostat service payments data 
local temp = $temp 
use "$work/debit_nonEU_`temp'OFFSHO", clear 

isocodes geo_label, gen(iso3c)
rename iso3c ISO3 
rename bop_its6_det$temp Rest 
keep ISO3 Rest 
//currency change for EU countries  from euro to USD
replace Rest=Rest/$USD_EUR
replace Rest = 0 if Rest ==.

//create value for EU22 (EU28 net of EU tax havens)
foreach name in "BEL" "CYP" "IRL" "LUX" "MLT" "NLD" {
	
	sum Rest if ISO3 == "`name'"
	local `name' = r(mean)
}

sum Rest if (ISO3!="GBR" & ISO3!="EU_28")
local EU28 = r(sum)
local eu22_rest = `EU28' - `BEL' - `CYP' - `IRL' - `LUX' - `MLT' - `NLD'
local H54 = (`eu22_rest'/`GDP_OFFSHO')

display `H54'
display `I54'


replace Rest = Rest - Rest/(`H54'/`I54')

tempfile rest 
save `rest', replace 
use `step8', clear 
merge 1:1 ISO3 using `rest', nogen
save `step8', replace

//(2)//for non-EU countries, we take the product of each country's DI share as total DI in high-risk services 
//and the excessive exports residual calculated in table "non-EU tax havens"

//compute excessive exports residual

//O13 = N13*I13/F13
//N13 = sum N9:N12
//F8 = E8 + C8 

//D12, import the value of exports of Puerto Rico for Pharamaceuticals
import excel "$rawdata/Wright_Zucman", sheet ("PRI_exports") firstrow clear 
keep y_$temp
sum y_$temp 
local D12 = r(mean)

local F9 = `sgp_exports' + `sgp'
local F10 = `hkg_exports' + `hkg'
local F11 = `E11' + `non_oecd'
local F12 = `D12' 
//R8 = F8/high-risk$H7

local R8 = `F8'/`wld_exports'
local R9 = `F9'/`wld_exports'
local R10 = `F10'/`wld_exports'
local R11 = `F11'/`wld_exports'
local R12 = `F12'/`wld_exports'

//N9 = C9 * (1-Q9/R9)

local N9 = `sgp_exports'  * (1-`Q9'/`R9')
local N10 = `hkg_exports' * (1-`Q10'/`R10')
local N11 = `non_oecd' * (1-`Q11'/`R11')
display `D12'
local N12 = `D12' * (1-`Q12'/`R12')
local N13 = `N9' + `N10' + `N11' + `N12'

//I13 = G13 + D13 - H13 
local temp = $temp 
use "$work/debit_nonEU_`temp'OFFSHO", clear 
replace bop_its6_det$temp = 0 if bop_its6_det$temp==.
sum bop_its6_det$temp
local G13 = r(sum)/$USD_EUR
local D11 = (`non_oecd' *`export_share_CHE')
local D13 = `D9' + `D10' + `D11' + `D12'

//F13 = sum F9:F12

local F13 = `F9' +`F10' + `F11' + `F12'


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

//I13 
local I13 = `G13' +`D13' - `H13'
//O13 = N13*I13/F13
local O13 = `N13'*(`I13'/`F13')
use `step8', clear
replace Rest = `O13' * CDIS_col_AC if Rest == . & CDIS_col_AC!=0
replace Rest = `O13' *CDIS_col_AK if ISO3 == "ISL" & Rest ==. 
save `step8', replace


//-----------------------------------
//Step 9: Prepare final table C2
//-----------------------------------

drop CDIS_col_AC CDIS_col_AK CDIS_col_AS
drop if group == ""

/*
set obs 51
replace country = "Non-haven total" if ISO3==""
replace ISO3 = "NHT" if ISO3 == ""
replace group = "other" if ISO3 == "NHT"
replace EU = 0 if ISO3 == "NHT"
sort group ISO3
*/

foreach name in "Belgium" "Cyprus" "Ireland" "Luxembourg" "Malta" "Netherlands" "Switzerland" "Rest" {

	replace `name' = 0 if `name'==.
	replace `name'_int = 0 if `name'_int==.
	sum `name' if ISO3 != "WLD"
	replace `name' = r(sum) if ISO3 == "WLD"
	sum `name' if (ISO3 != "BEL" & ISO3 != "CYP" & ISO3 != "LUX" & ISO3 != "IRL" & ISO3 != "MLT" & ISO3 != "NLD" & ISO3 != "WLD" )
*	replace `name' = r(sum) if ISO3 == "NHT"
	rename `name' `name'_services
*	sum `name'_int if (ISO3 != "BEL" & ISO3 != "CYP" & ISO3 != "LUX" & ISO3 != "IRL" & ISO3 != "MLT" & ISO3 != "NLD" & ISO3 != "WLD" )
*	replace `name'_int = r(sum) if ISO3 == "NHT"

}

//fix the issue of anomalies in bilateral services and interest payments which have some very high values in some instances
//for now we set the value to zero 

replace Ireland_services = 0 if ISO3 == "URY" | ISO3 == "MYS" | ISO3 == "NGA" | ISO3 == "CHL" 
replace Netherlands_services = 0 if (ISO3 == "NGA" & $temp == 2019)

gen EU_havens_int = . 
replace EU_havens_int = Belgium_int + Cyprus_int + Ireland_int + Luxembourg_int + Malta_int + Netherlands_int

gen Non_EU_havens_int = . 
replace Non_EU_havens_int = Switzerland_int + Rest_int

gen All_havens_int = . 
replace All_havens_int = Non_EU_havens_int + EU_havens_int

gen EU_havens_services = . 
replace EU_havens_services = Belgium_services + Cyprus_services + Ireland_services + Luxembourg_services + Malta_services + Netherlands_services

//fix the issue of anomalies in bilateral services and interest payments which have some very high values in some instances
//for now we set the value to zero 

replace EU_havens_services = 0 if ISO3 == "ISL" 


gen Non_EU_havens_services = . 
replace Non_EU_havens_services = Switzerland_services + Rest_services

gen All_havens_services = . 
replace All_havens_services = Non_EU_havens_services + EU_havens_services

order country ISO3 EU group Belgium_int Cyprus_int Ireland_int Luxembourg_int Malta_int Netherlands_int Switzerland_int Rest_int All_havens_int Non_EU_havens_int EU_havens_int Belgium_services Cyprus_services Ireland_services Luxembourg_services Malta_services Netherlands_services Switzerland_services Rest_services All_havens_services Non_EU_havens_services EU_havens_services

//Final reoredering and export results
gen sort_dummy=.
replace sort_dummy=1 if group=="OECD"
replace sort_dummy=2 if group=="OECD_TH"
replace sort_dummy=3 if group=="DEV"
replace sort_dummy=4 if group=="NEW_DEV"
replace sort_dummy=5 if group=="other" 
sort sort_dummy ISO3 
drop sort_dummy
tempfile step9
save `step9', replace

save "$work/table_C2_$temp", replace 
export excel using "$root/output/Part2-reallocating-profits-$temp.xlsx", firstrow(var) sheet("Table C2", replace) keepcellfmt

cd "$code"
