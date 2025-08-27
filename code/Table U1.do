
//---------------------------------------------//
//Table U1
//---------------------------------------------//

//Prepares estimates of global profit shifting
//note that the order of steps is chosen because variables created are used as building blocks
//i.e., future variables down the road will be imputed using some of the data imported previously

//---------------------------------------------//
//Step 1: GDP
//---------------------------------------------//

//we start by importing GDP values for each country 

use "$work/GDPgrowth_$temp", clear

replace GDP = GDP/1000
rename location ISO3

//restrict to sample of the analysis 

keep if ISO3=="AUS" | ISO3=="AUT" | ISO3=="BEL" | ISO3=="CAN" | ISO3=="CHL" | ISO3=="CZE" | ISO3=="DNK" | ISO3=="EST" | ISO3=="FIN" | ISO3=="FRA" | ISO3=="DEU" | ISO3=="GRC" | ISO3=="HUN" | ISO3=="ISL" | ISO3=="IRL" | ISO3=="ISR" | ISO3=="ITA" | ISO3=="JPN" | ISO3=="KOR" | ISO3=="LVA" | ISO3=="LUX" | ISO3=="MEX" | ISO3=="NLD" | ISO3=="NZL" | ISO3=="NOR" | ISO3=="POL" | ISO3=="PRT" | ISO3=="SVK" | ISO3=="SVN" | ISO3=="ESP" | ISO3=="SWE" | ISO3=="CHE" | ISO3=="TUR" | ISO3=="GBR" | ISO3=="USA" | ISO3=="BRA" | ISO3=="CHN" | ISO3=="COL" | ISO3=="CRI" | ISO3=="IND" | ISO3=="RUS" | ISO3=="ZAF" | ISO3=="AND" | ISO3=="AIA" | ISO3=="ATG" | ISO3=="ABW" | ISO3=="BHS" | ISO3=="BHR" | ISO3=="BRB" | ISO3=="BLZ" | ISO3=="BMU" | ISO3=="BES" | ISO3=="VGB" | ISO3=="CYM" | ISO3=="CUW" | ISO3=="CYP" | ISO3=="GIB" | ISO3=="GRD" | ISO3=="GGY" | ISO3=="HKG" | ISO3=="IMN" | ISO3=="JEY" | ISO3=="LBN" | ISO3=="LIE" | ISO3=="MAC" | ISO3=="MLT" | ISO3=="MHL" | ISO3=="MUS" | ISO3=="MCO" | ISO3=="PAN" | ISO3=="PRI" | ISO3=="SYC" | ISO3=="SGP" | ISO3=="SXM" | ISO3=="KNA" | ISO3=="LCA" | ISO3=="VCT" | ISO3=="TCA" | ISO3=="ROW" | ISO3=="WLD"

//compute GDP for rest of the world

insobs 1
replace ISO3 = "ROW" if ISO3 == ""
sum GDP if ISO3!="WLD" 
local sample_check = r(sum)
sum GDP if ISO=="WLD" 
local wld_check = r(sum)
replace GDP = `wld_check'-`sample_check' if ISO3=="ROW"


//Check GDP computations
sum GDP if ISO3=="WLD"
local wld_check = r(mean)
sum GDP if ISO3!="WLD"
local sample_check = r(sum)
display `sample_check'
display `wld_check'
assert `wld_check'==`sample_check'

drop GDPgrowth15to$temp



//---------------------------------------------//
//Step 2: Structure data
//---------------------------------------------//

// add country variable 

kountry ISO3, from (iso3c)
rename NAMES_STD country
replace country = "Bonaire" if ISO3 == "BES"
replace country = "Curacao" if ISO3 == "CUW"
replace country = "Guernsey" if ISO3 == "GGY"
replace country = "Isle of Man" if ISO3 == "IMN"
replace country = "Jersey" if ISO3 == "JEY"
replace country = "Rest of the world" if ISO3 == "ROW"
replace country = "Sint Maarten" if ISO3 == "SXM"
replace country = "World" if ISO3 == "WLD"

// order and sort, and add country groups to facilitate further analysis

sort ISO3
order ISO3 country GDP

gen group = "OECD"
replace group = "OECD_TH" if ISO3=="BEL" |ISO3=="IRL" | ISO3=="LUX" | ISO3=="NLD" |ISO3=="CHE" 
replace group = "DEV" if  ISO3=="BRA" | ISO3=="CHN" | ISO3=="COL" | ISO3=="CRI" | ISO3=="IND" | ISO3=="RUS" | ISO3=="ZAF" 
replace group = "TH" if ISO3=="AND" | ISO3=="AIA" | ISO3=="ATG" | ISO3=="ABW" | ISO3=="BHS" | ISO3=="BHR" | ISO3=="BRB" | ISO3=="BLZ" | ISO3=="BMU" | ISO3=="BES" | ISO3=="VGB" | ISO3=="CYM" | ISO3=="CUW" | ISO3=="CYP" | ISO3=="GIB" | ISO3=="GRD" | ISO3=="GGY" | ISO3=="HKG" | ISO3=="IMN" | ISO3=="JEY" | ISO3=="LBN" | ISO3=="LIE" | ISO3=="MAC" | ISO3=="MLT" | ISO3=="MHL" | ISO3=="MUS" | ISO3=="MCO" | ISO3=="PAN" | ISO3=="PRI" | ISO3=="SYC" | ISO3=="SGP" | ISO3=="SXM" | ISO3=="KNA" | ISO3=="LCA" | ISO3=="VCT" | ISO3=="TCA"
replace group = "other" if ISO3 == "ROW"| ISO3=="WLD"

gen tax_haven = 0
replace tax_haven = 1 if group == "OECD_TH"|group=="TH"

tempfile structureddata
save `structureddata', replace


//---------------------------------------------//
//Step 3: Compensation of employees
//---------------------------------------------//

//import compensation of employees using OECD table 14a

*use "$work/OECD_table14a_$temp", clear

merge m:m country using "$work/OECD_table14a_$temp"
keep if _merge == 3
drop _merge

keep ISO3 GDP country corp_wage
replace corp_wage = corp_wage/1000

merge m:m country ISO3 using `structureddata'

//compute missing values using assumed employee shares to GDP
gen corpwage_ratio = 0.35														//When there is no data, compensation of employees is imputed as 35% of GDP for OECD countries (the OECD country average) 
replace corpwage_ratio = 0.3 if group=="other" | group=="DEV" | group=="TH"		//30% of GDP for non-OECD non-haven countries (the non-OECD average) and for non-OECD tax havens 

replace corp_wage = GDP * corpwage_ratio if corp_wage==.
drop corpwage_ratio
drop _merge

order ISO3 country group tax_haven GDP corp_wage

tempfile step3
save `step3', replace

//compute Puerto Rico values using external sources (Wright and Zucman)
import excel "$rawdata/Wright_Zucman", sheet ("PRI") cellrange(A77:S82) clear
rename A year
rename S corpwagePRI
keep year corpwagePRI
gen ISO3 ="PRI"
keep if year == $temp

merge m:m ISO3 using `step3', nogen
replace corp_wage = corpwagePRI if ISO3 == "PRI"
drop year corpwagePRI
sort ISO3

//compute world compensation for employees
sum corp_wage if ISO3!="WLD"
local wld_corpwage = r(sum)
replace corp_wage = `wld_corpwage' if ISO3=="WLD"


//------------------------------------------------------------//
//Step 4: Pre-tax profit/compensation ratio for US affiliates
//------------------------------------------------------------//

//In step 4 we import US outward foreign affiliates statistics (FATS) from BEA

merge m:m country using "$work/US_outward_FATS_$temp"

//Impute profit wage ratio for missing other western hemisphere countries

qui summarize US_outward_P_W_ratio if country == "Other Western Hemisphere"
local value = r(mean) 
local owh "AIA ATG ABW BHS BES CUW GRD SXM KNA LCA VCT" 		//Other western hemisphere countries
foreach c in `owh' {
replace US_outward_P_W_ratio = `value' if ISO3 =="`c'"
}
 

//Impute profit wage ratio of Caribbean UK islands

qui summarize US_outward_P_W_ratio if country == "United Kingdom Islands, Caribbean"
local value_2 = r(mean) 
local cuki "VGB CYM TCA" 										//Caribbean UK islands
foreach c in `cuki' {
replace US_outward_P_W_ratio = `value_2' if ISO3 =="`c'"
}

//Impute profit wage ratio of World total

qui summarize US_outward_P_W_ratio if country == "All countries"
local value_3 = r(mean) 
replace US_outward_P_W_ratio = `value_3' if ISO3 =="WLD"		//World

tempfile tf1
save `tf1', replace

//Impute profit wage ratio of non-OECD tax havens and of "rest of the world"

import excel "$rawdata/Wright_Zucman", sheet ("dataF3") cellrange(A1:AJ52) clear


keep A AJ
rename A year
rename AJ US_outward_P_W_ratio					
drop if year==.|US_outward_P_W_ratio==""
destring US_outward_P_W_ratio, replace
summarize US_outward_P_W_ratio if year == $temp
local value_4 = r(mean) 

use `tf1', clear
local noth "AND BHR BLZ CYP JEY GGY GIB IMN LBN LIE MAC MLT MHL MCO MUS SYC ROW" 		//Non-OECD tax havens and "rest of the world"
foreach c in `noth' {
replace US_outward_P_W_ratio = `value_4' if ISO3 =="`c'"
}

save `tf1', replace

//Impute profit wage ratio of OECD countries for which data is missing

if $temp <=2020 {
	
	local temp = $temp
}
else if $temp > 2020 {				//beyond 2020 we keep 2020 values (see Wright_Zucman for more details)
	
	local temp = 2020
}


import excel "$rawdata/Wright_Zucman", sheet ("dataF3") cellrange(A1:AK52) clear
keep A AK
rename A year
rename AK US_outward_P_W_ratio
drop if year==.|US_outward_P_W_ratio==""
destring US_outward_P_W_ratio, replace
summarize US_outward_P_W_ratio if year == `temp'
local value_5 = r(mean) 

use `tf1', clear
local roc "EST ISL KOR LVA SVK SVN" 		//Remaining OECD countries
foreach c in `roc' {
replace US_outward_P_W_ratio = `value_5' if ISO3 =="`c'"
}

save `tf1', replace

//Impute profit wage ratio of Puerto Rico

import excel "$rawdata/Wright_Zucman", sheet ("PRI") cellrange(A26:X82) clear
keep A X
rename A year
rename X US_outward_P_W_ratio
drop if year==.|US_outward_P_W_ratio==.

if $temp <=2020 {
	
	local temp = $temp
}
else if $temp > 2020 {				//beyond 2020 for PRI we keep 2020 values (see Wright_Zucman for more details)
	
	local temp = 2020
}

summarize US_outward_P_W_ratio if year == `temp'
local value_6 = r(mean) 

use `tf1', clear
replace US_outward_P_W_ratio = `value_6' if ISO3 =="PRI"		//Puerto Rico

drop if ISO3==""
drop _merge
save `tf1', replace

//----------------------------------------------------//
//Step 5: Import net-of-tax profit of operating units
//----------------------------------------------------//

// Here we collect up-to-date data on FDI equity income paid by operating units from the OECD
// see program OECD "FDI equity income operating units.do" for complete details. 


// we start with countries for which we have OECD data

use "$work/ROU_E_$temp", clear
rename cou ISO3
rename valueROU_Equity_income net_op_profit
keep ISO3 net_op_profit

merge m:m ISO3 using `tf1', nogen
drop if ISO3 == "OECD"|ISO3=="LTU"
replace net_op_profit = net_op_profit/1000

// assume net operating profits = 15% of GDP for non-OECD tax havens

replace net_op_profit = 0.15*GDP if group=="TH"

tempfile tf3
save `tf3', replace

// import values for major developing countries and other missing values from table B10 

use "$work/TableB10_$temp", clear

keep ISO3 country group Inward_DI_country_OECD 
replace Inward_DI_country_OECD=Inward_DI_country_OECD/1000
sum Inward_DI_country_OECD if group == "other"
local row = r(sum)

drop if group == "other"
merge m:m ISO3 using `tf3', nogen
replace net_op_profit = Inward_DI_country_OECD if net_op_profit ==.
replace net_op_profit = `row' if ISO3 == "ROW"
sum net_op_profit if ISO3!= "WLD"
local wld = r(sum)
replace net_op_profit = `wld' if ISO3 == "WLD"
drop Inward_DI_country_OECD

tempfile tf3
save `tf3', replace

// import value for Puerto Rico from Wright_Zucman

import excel "$rawdata/Wright_Zucman", sheet ("PRI") cellrange(A26:Y82) clear

keep A P Y
rename A year
rename P PRI_profits
rename Y Cash_tax_paid

drop if year==.|PRI_profits==.|Cash_tax_paid==.
gen net_op_profit= PRI_profits - Cash_tax_paid
summarize net_op_profit if year == `temp'
local value_5 = r(mean) 

use `tf3', clear
replace net_op_profit = `value_5' if ISO3 =="PRI"
drop if ISO3==""|country==""
save `tf3', replace


//----------------------------------------------------//
//Step 6: Import profits of SPEs
//----------------------------------------------------//

// here we compute the difference between inward and outward FDI income for special purpose entities (SPEs)
// data used from OECD FDI statistics 

import excel "$rawdata/SPE profits", sheet ("for_stata") firstrow clear

keep country ISO3 inward_$temp outward_$temp 
gen SPE_profits=.

foreach v in inward_$temp outward_$temp {
	replace `v' = "0" if `v'== ".."
	destring `v', replace	
}

replace SPE_profits = inward_$temp - outward_$temp
keep ISO3 SPE_profits

tempfile SPEs
save `SPEs', replace

use `tf3', clear
merge 1:1 ISO3 using `SPEs'
replace SPE_profits=SPE_profits/1000 		//from million USD to billion USD
drop if _merge == 2
drop _merge
sort group ISO3
sum SPE_profits if ISO3!= "WLD"
local wld = r(sum)
replace SPE_profits = `wld' if ISO3 == "WLD"
replace SPE_profits = 0		//test for now
save `tf3', replace

//----------------------------------------------------//
//Step 7: Unrecorded net-of-tax foreign profits
//----------------------------------------------------//

// we import data from table B10 to compute unrecorded foreign profits for tax haven countries

use "$work/TableB10_$temp", clear
gen unrecorded_foreign_profits=.
replace unrecorded_foreign_profits = missing_income if group == "OECD_TH"
replace unrecorded_foreign_profits = missing_income - correction + DI_equity_income_surplus + reallocation if group == "TH"


keep unrecorded_foreign_profits ISO3 
tempfile unrecorded
save `unrecorded', replace

use `tf3', clear
merge 1:1 ISO3 using `unrecorded'
replace unrecorded_foreign_profits = unrecorded_foreign_profits/1000 		//from million USD to billion USD
drop if _merge == 2
drop _merge
sort group ISO3
sum unrecorded_foreign_profits if ISO3!= "WLD"
local wld = r(sum)
replace unrecorded_foreign_profits = `wld' if ISO3 == "WLD"

save `tf3', replace


//-------------------------------------------------------//
//Step 8: Recorded corporate profits in national accounts
//-------------------------------------------------------//

// we import corporate profits from OECD table 14a 

use "$work/OECD_table14a_$temp", clear
keep country tax_prof
replace tax_prof = tax_prof/1000

//match country names
replace country = "Estonia, Rep. of" if country == "Estonia"
replace country = "Czech Rep." if country == "Czech Republic"
replace country = "Korea, Rep. of" if country == "Korea, Rep"
replace country = "Netherlands, The" if country == "Netherlands"
replace country = "Poland, Rep. of" if country == "Poland"
replace country = "Slovak Rep." if country == "Slovak Republic"
replace country = "Slovenia, Rep. of" if country == "Slovenia"

tempfile recorded
save `recorded', replace

use `tf3', clear
merge m:m country using `recorded'
drop if _merge == 2
drop _merge

replace tax_prof = 0.15*GDP if tax_prof==. & (group=="OECD" | group=="OECD_TH") //recorded corporate profits are imputed as 15% of GDP for OECD countries (the OECD country average)
replace tax_prof = 0.20*GDP if tax_prof==. & group=="DEV" 						//recorded corporate profits are imputed as 20% of GDP for major developing countries
replace tax_prof = 0.20*GDP if tax_prof==. & ISO3=="ROW"						//recorded corporate profits are imputed as 20% of GDP for rest of the world
																				//Variable is left blank for non-OECD tax havens

sum tax_prof if ISO3!= "WLD"
local wld = r(sum)
replace tax_prof = `wld' if ISO3 == "WLD" 
save `tf3', replace																				
																				

//-------------------------------------------------------//
//Step 9a: Corporate tax paid (part 1)
//-------------------------------------------------------//

// we continue with importing corporate tax paid data from UNU wider
// note that this is done in two steps as for missing values, the rate is imputed based on variables built further below

*use "$work/globaltaxrev_$temp", clear 							//UN GRD database

//new data import using 2022 data from OECD instead. 

if $temp == 2022 {
import delimited "$rawdata/OECD_global_tax_rev.csv", clear

rename obs_value corptaxrev 
rename ref_area CountryCode
rename multiplicateurdunité unit
rename time_period year

replace corptaxrev = corptaxrev/1000 if unit == "Millions"
drop unit 
keep if year == 2022 
keep CountryCode corptaxrev 

save "$work/corptaxrev_comprehensive_2022", replace
}

use "$work/corptaxrev_comprehensive_$temp", clear 				//Bachas et al ETR database


rename CountryCode ISO3
*replace corptaxrev = corptaxrev*1000 if ISO3=="KOR" 			//correct for error in computation for Korea
replace corptaxrev = 0.4455 if ISO3 == "LVA" & $temp == 2019 	//replace the value for LVA in 2019 to the average 2014-2018 to adjust for low value from corp tax reform in LVA

tempfile taxrev
save `taxrev', replace

use `tf3', clear
merge 1:1 ISO3 using `taxrev'
drop if _merge == 2
drop _merge

replace corptaxrev = 0.18*tax_prof if corptaxrev ==. & (group=="OECD" | group=="OECD_TH" | group=="DEV" | ISO3 == "ROW") // for missing values we impute corporate taxes paid as 18% of corporate profits recorded in the national accounts (the global average effective tax rate in 2015-2020)

sum corptaxrev if ISO3!= "WLD"
local wld = r(sum)
replace corptaxrev = `wld' if ISO3 == "WLD" 
save `tf3', replace




//-------------------------------------------------------//
//Step 10: Corporate tax paid on foreign profits
//-------------------------------------------------------//

use `tf3', clear
gen foreign_corptaxrev=.
replace foreign_corptaxrev= (max(net_op_profit, 0) + max(0, unrecorded_foreign_profits)) * 0.05 / (1 - 0.05) if group=="TH" | ISO3=="CHE" 
replace foreign_corptaxrev= (max(net_op_profit, 0))*(corptaxrev/tax_prof)/(1-corptaxrev/tax_prof) + (max(0, unrecorded_foreign_profits)) * 0.05 / (1 - 0.05) if (group!="TH" & ISO3!="CHE") 
save ` tf3', replace

//Puerto Rico
import excel "$rawdata/Wright_Zucman", sheet ("PRI") cellrange(A78:Y82) clear

rename A year
sum Y if year== `temp'			
local value_5 = r(mean)
use `tf3', clear
replace foreign_corptaxrev = `value_5' if ISO3 =="PRI" 
save `tf3', replace


sum foreign_corptaxrev if ISO3!= "WLD"
local wld = r(sum)
replace foreign_corptaxrev = `wld' if ISO3 == "WLD" 
save `tf3', replace


//-------------------------------------------------------//
//Step 11: Pre-tax foreign profits
//-------------------------------------------------------//

use `tf3', clear

replace net_op_profit = 0 if net_op_profit ==.
replace SPE_profits = 0 if SPE_profits ==.
replace unrecorded_foreign_profits = 0 if unrecorded_foreign_profits ==.
replace foreign_corptaxrev = 0 if foreign_corptaxrev ==.

gen pre_tax_foreign_profits=.
replace pre_tax_foreign_profits = net_op_profit + SPE_profits + unrecorded_foreign_profits + foreign_corptaxrev
save `tf3', replace


//-------------------------------------------------------//
//Step 12: Profits of offshore mutual funds
//-------------------------------------------------------//


use "$work/OECD_table14a_$temp", clear

keep NFD44P_S12 country 
keep if country == "Ireland"| country=="Luxembourg"| country == "Netherlands" 
rename NFD44P_S12 profits_offshore_mutual_funds
replace profits_offshore_mutual_funds = profits_offshore_mutual_funds*0.75 if country == "Ireland" //For Ireland, 75% of portfolio investment income in the financial sector is assumed to reflect profit of offshore funds
replace profits_offshore_mutual_funds = profits_offshore_mutual_funds*0.35 if country=="Luxembourg"| country == "Netherlands" //For Luxembourg and Netherlands, 35% of portfolio investment income in the financial sector is assumed to reflect profit of offshore funds
replace profits_offshore_mutual_funds = profits_offshore_mutual_funds/1000
replace profits_offshore_mutual_funds = 0 if profits_offshore_mutual_funds==.

replace country = "Netherlands, The" if country == "Netherlands"
*replace profits_offshore_mutual_funds = 0 if country == "Netherlands, The"	//preliminary solution: we remove profits from offshore mutual funds for the Netherlands
tempfile step12
save `step12', replace


use `tf3', clear
merge 1:1 country using `step12', nogen

//-------------------------------------------------------//
//Step 13: Profit correction
//-------------------------------------------------------//

gen profit_correction =.
replace profit_correction = unrecorded_foreign_profits/(1-0.05) - profits_offshore_mutual_funds if group=="OECD"| group=="DEV" | group == "OECD_TH" // For all countries other than non-OECD tax havens: equal to unrecorded net-of-tax foreign profits grossed up by an assumed effective tax rate of 5%, minus profits of offshore mutual funds
replace profit_correction = 0 if profit_correction <0 	//tbc
save `tf3', replace

//-------------------------------------------------------//
//Step 14a: Pre-tax profits of local firms (part 1)
//-------------------------------------------------------//

//these next few steps have to be run in this specific order

gen pre_tax_local_profits =0
replace pre_tax_local_profits = 0.1*GDP if group=="TH" //For non-OECD havens assumed to be equal to 10% of GDP (consistent with TWZ). 
save `tf3', replace

//-------------------------------------------------------//
//Step 15a: Pre-tax corporate profits (part 1)
//-------------------------------------------------------//

gen pre_tax_corp_profits = 0
replace tax_prof=0 if tax_prof==.
replace profit_correction= 0 if profit_correction==.
replace pre_tax_corp_profits = tax_prof + profit_correction if group=="OECD"| group=="DEV" | group == "OECD_TH" |ISO3 == "ROW" //Sum of recorded profits (col. 6) and profit correction (col. 7)

save `tf3', replace

//-------------------------------------------------------//
//Step 14b: Pre-tax profits of local firms (part 2)
//-------------------------------------------------------//

replace pre_tax_local_profits = pre_tax_corp_profits - pre_tax_foreign_profits if group=="OECD"| group=="DEV" | group == "OECD_TH" |ISO3 == "ROW"
*replace pre_tax_local_profits = 0 if pre_tax_local_profits<0	//tbc if we keep this or not. 	
save `tf3', replace

//-------------------------------------------------------//
//Step 15b: Pre-tax corporate profits (part 2)
//-------------------------------------------------------//


replace pre_tax_corp_profits = pre_tax_local_profits + pre_tax_foreign_profits if group=="TH"
save `tf3', replace


//-------------------------------------------------------//
//Step 9b: Corporate tax paid (part 2)
//-------------------------------------------------------//


replace corptaxrev = 0.05*pre_tax_corp_profits if group=="TH"	//For non-OECD tax havens, we impute corporate taxes paid as 5% of corporate profits. 
save `tf3', replace

//---------------------------------------------------------//
//Step 16a: Compensation of employees: foreign corp (part 1)
//---------------------------------------------------------//

import excel "$rawdata/Eurostat personel cost", sheet ("for_stata") firstrow clear

local temp = $temp


keep country world_`temp' all_`temp'

foreach v in world_`temp' all_`temp' {
	drop if `v'==":"
	destring `v', replace	
}


gen foreign_ratio = .

replace foreign_ratio = world_`temp' / all_`temp'

replace country = "Netherlands, The" if country == "Netherlands"
replace country = "Poland, Rep. of" if country == "Poland"
replace country = "Czech Rep." if country == "Czechia"
replace country = "Slovak Rep." if country == "Slovakia"
replace country = "Slovenia, Rep. of" if country == "Slovenia"
replace country = "Estonia, Rep. of" if country == "Estonia"

keep country foreign_ratio

tempfile personel
save `personel', replace

use `tf3', clear

merge 1:1 country using `personel'
drop if _merge == 2
drop _merge

//generate foreign corporate wage for OECD and main DEV countries

gen foreign_corp_wage =.

replace  foreign_corp_wage = foreign_ratio*corp_wage

replace foreign_corp_wage = max(pre_tax_foreign_profits/US_outward_P_W_ratio,0) if (group=="OECD"|group == "OECD_TH" | group == "DEV" | ISO3 == "ROW") & (foreign_corp_wage==.|foreign_corp_wage==0)

drop Compensationofemployees foreign_ratio

save `tf3', replace

//United States


use "$work/US_outward_FATS_$temp", clear
sum Compensationofemployees if country == "All countries"
local usa = r(mean) /1000
drop Compensationofemployees 

use `tf3', clear
replace foreign_corp_wage = `usa' if ISO3 == "USA"
save `tf3', replace

//---------------------------------------------------------//
//Step 17a: Compensation of employees: local corp (part 1)
//---------------------------------------------------------//

gen local_corp_wage = . 
replace local_corp_wage = corp_wage - foreign_corp_wage if group == "OECD_TH" | group == "OECD" | group == "DEV" | ISO3 == "ROW"

//compute world average profit to wage ratio in the local sector as world pre-tax profits / world local compensation 

sum local_corp_wage if group == "OECD_TH" | group == "OECD" | group == "DEV" | ISO3 == "ROW"
local local_comp_world = r(sum)

sum pre_tax_local_profits if group == "OECD_TH" | group == "OECD" | group == "DEV" | ISO3 == "ROW"
local local_profits_world = r(sum)

local p_w_ratio_world = `local_profits_world'/`local_comp_world'

*sum US_outward_P_W_ratio if ISO3 == "ROW"
*local wld_average = r(mean) 	// compute the US outward FATS profit to wage ratio for rest of the world to be used as a world average

*local wld_average = 0.

*sum pre_tax_local_profits if ISO3 != "WLD" | ISO3 != "ROW"
*local local_profits = r(sum)


replace local_corp_wage =  pre_tax_local_profits/`p_w_ratio_world' if local_corp_wage==. 

save `tf3', replace

//---------------------------------------------------------//
//Step 16b: Compensation of employees: foreign corp (part 2)
//---------------------------------------------------------//


replace foreign_corp_wage = corp_wage - local_corp_wage if foreign_corp_wage==. 
save `tf3', replace

//Puerto Rico


if $temp <=2020 {
		
	local temp = $temp

}
else if $temp > 2020 {				//beyond 2020 we keep 2020 values due to data limitations in Eurostat
	
	local temp = 2020
}
*/

import excel "$rawdata/Wright_Zucman", sheet ("PRI") cellrange(A78:W82) clear
rename A year
sum W if year== `temp'			
local value_5 = r(mean)

use `tf3', clear
replace foreign_corp_wage = `value_5' if ISO3 =="PRI" 
save `tf3', replace

//---------------------------------------------------------//
//Step 17b: Compensation of employees: local corp (part 2)
//---------------------------------------------------------//


*We can now compute for Puerto Rico

replace local_corp_wage = corp_wage - foreign_corp_wage if ISO3 == "PRI"
save `tf3', replace


//---------------------------------------------------------//
//Step 18: Effective corporate tax rate
//---------------------------------------------------------//

gen corporate_ETR = . 
replace corporate_ETR = corptaxrev/pre_tax_corp_profits
save `tf3', replace


//---------------------------------------------------------//
//Step 19: Profit-to-wage ratios
//---------------------------------------------------------//


//all

gen profit_wage_ratio_all=.
replace profit_wage_ratio_all = pre_tax_corp_profits/corp_wage


//local
gen profit_wage_ratio_local=.
replace profit_wage_ratio_local = `p_w_ratio_world' if group == "TH"
replace profit_wage_ratio_local = pre_tax_local_profits /local_corp_wage if group == "OECD" | group == "OECD_TH" | group == "DEV" | ISO3 == "ROW"

//foreign

gen profit_wage_ratio_foreign=. 
replace profit_wage_ratio_foreign = pre_tax_foreign_profits/foreign_corp_wage

save `tf3', replace

//---------------------------------------------------------//
//Step 20: Shifted profits
//---------------------------------------------------------//

gen shifted_profits = . 
replace shifted_profits = max((profit_wage_ratio_foreign-profit_wage_ratio_local)*foreign_corp_wage,0) if tax_haven==1


//order, sort and clean 

gen sorting = . 
replace sorting = 0 if group == "OECD"
replace sorting = 1 if group == "OECD_TH"
replace sorting = 2 if group == "DEV"
replace sorting = 3 if group == "TH"
replace sorting = 4 if group == "other"
sort sorting ISO3
drop sorting

order country ISO3 group tax_haven GDP corp_wage local_corp_wage foreign_corp_wage pre_tax_corp_profits tax_prof profit_correction corptaxrev corporate_ETR pre_tax_local_profits pre_tax_foreign_profits net_op_profit SPE_profits unrecorded_foreign_profits foreign_corptaxrev profits_offshore_mutual_funds profit_wage_ratio_all profit_wage_ratio_local profit_wage_ratio_foreign US_outward_P_W_ratio shifted_profits

// compute world missing values

foreach v in GDP corp_wage local_corp_wage foreign_corp_wage pre_tax_corp_profits tax_prof profit_correction corptaxrev pre_tax_local_profits pre_tax_foreign_profits net_op_profit SPE_profits unrecorded_foreign_profits foreign_corptaxrev profits_offshore_mutual_funds shifted_profits {
	sum `v' if ISO3 != "WLD"
	local wldtotal = r(sum) 
	replace `v' = `wldtotal' if ISO3 == "WLD"

}

replace profit_wage_ratio_local = pre_tax_local_profits /local_corp_wage if ISO3 == "WLD"
replace profit_wage_ratio_foreign = pre_tax_foreign_profits/foreign_corp_wage if ISO3 == "WLD"
replace profit_wage_ratio_all = pre_tax_corp_profits/corp_wage if ISO3 == "WLD"
replace corporate_ETR = corptaxrev/pre_tax_corp_profits if ISO3 == "WLD"


// Label variables 

label variable ISO3 "Isocode"
label variable group "Country group"
label variable tax_haven "Tax haven dummy"
label variable GDP "Gross domestic product"
label variable corp_wage "Total corporate wage"
label variable local_corp_wage "Corporate wage domestic sector"
label variable foreign_corp_wage "Corporate wage foreign sector"
label variable pre_tax_corp_profits "Total corporate profits (pre-tax)"
label variable tax_prof "Total corporate profits (OECD 14a)"
label variable profit_correction "Correcting profits (offshore mutual funds)"
label variable corptaxrev "Corporate tax revenue"
label variable corporate_ETR "Corporate effective tax rate"
label variable pre_tax_local_profits "Local corporate profits (pre-tax)"
label variable pre_tax_foreign_profits "Foreign corporate profits (pre-tax)"
label variable net_op_profit "FDI equity income of operating units"
label variable SPE_profits "Profits of special purpose entities"
label variable unrecorded_foreign_profits "Unrecorded profits imputed from FDI discrepancies (table B10)"
label variable foreign_corptaxrev "Corporate tax paid on foreign profits"
label variable profits_offshore_mutual_funds "Profits of offshore mutual funds"
label variable profit_wage_ratio_all "Profit-to-wage ratio (all sectors)"
label variable profit_wage_ratio_local "Profit-to-wage ratio (local sector)"
label variable profit_wage_ratio_foreign "Profit-to-wage ratio (foreign sector)"
label variable US_outward_P_W_ratio "Profit-to-wage ratio of US MNE foreign entities"
label variable shifted_profits "Total profits shifted by tax haven" 
 
save "$work/shifted_profits_U1_$temp", replace
export excel using "$root/output/Part1-profit-shifting-$temp.xlsx", firstrow(varl) sheet("Table U1", replace) keepcellfmt 


sum shifted_profits 
display r(sum)