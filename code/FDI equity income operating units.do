//----------------------------------------
//Step 3a: OECD BOP & FDI data
//----------------------------------------

//downloads BOP data for OECD countries

*(i)*
//download and clean data 
/*
set timeout1 500
sdmxuse data OECD, dataset(FDI_INC_AGGR) start(2016) clear	// no longer works with new OECD data 

save "$work/FDI_INC_AGGR", replace
use "$work/FDI_INC_AGGR", replace
*/

import delimited "$rawdata/FDI_INC_AGGR_raw", delimiter(",") clear

*destring time, replace force

keep if time_period==$temp

keep if currency=="USD"

keep if accounting_entry=="NET_FDI"

keep if measure_principle=="DI"

replace measure="_FDI_income" if measure=="T_D4P_F"

replace measure="_Equity_income" if measure=="T_D4S_F5"

replace measure="_Interest_income" if measure=="T_D4Q_FL"

keep if (measure=="_FDI_income"|measure=="_Equity_income"|measure=="_Interest_income")

*reshape wide obs_value, i(ref_area measure) j(type_entity ) string
keep ref_area obs_value measure 

sort ref_area
reshape wide obs_value, string i(ref_area) j(measure)

// obtain OECD-wide ratio of equity income as a share of total fdi income 

preserve 
drop if obs_value_Equity_income ==. | obs_value_FDI_income ==. |obs_value_Interest_income == . 
collapse (sum) obs_value_Equity_income obs_value_FDI_income obs_value_Interest_income
gen equity_ratio = obs_value_Equity_income/obs_value_FDI_income
sum equity_ratio
local equity_ratio = r(mean)
display `equity_ratio'
restore 


/*
gen shareofFDIincRSP=valueRSP_F/valueALL_F
replace valueROU_E=(1-shareofFDIincRSP)*valueALL_Equity_income if valueROU_E==.


*ssc install _gwtmean

gen shareofEquityprFDI=valueALL_E/valueALL_F
egen w_shareofEquityprFDI= wtmean(shareofEquityprFDI), weight(valueALL_F)
replace valueALL_E=w_shareofEquityprFDI*valueALL_F if valueALL_E==.

replace valueROU_E=valueALL_E if valueROU_E==.

replace valueRSP_E=valueALL_E-valueROU_E

*/

replace obs_value_Equity_income = (obs_value_FDI_income * `equity_ratio') if obs_value_Equity_income == . 
replace obs_value_Interest_income = obs_value_FDI_income - obs_value_Equity_income if obs_value_Interest_income == . 



rename ref_area cou
rename obs_value_Equity_income valueROU_E
save "$work/FDI_INC_AGGR", replace

*(ii)*
//save data in separate Stata files 

preserve
keep cou valueROU_E
save "$work/ROU_E_$temp", replace
restore


*(iii)*
//Finally, we remove inward DI income in the holdings sector and inward DI interest income

//First, we remove inward DI income in the holdings sector (treated the same as SPE income i.e. as conduit income)
*set timeout1 500
*sdmxuse data OECD, dataset(FDI_INC_IND) start(2016) clear
*save "$work/ROU_holdings", replace
use "$work/ROU_holdings", clear

destring time, replace
keep if counterpart == "W0"
keep if measure == "USD"
keep if eco_act == "K642" 
keep if measure_pr == "DI"
keep if type_entity == "ROU"
keep if fdi_type == "T_D4P_F"
keep if time == $temp


rename value ROU_holdings
keep ROU_holdings cou

tempfile holdings
save `holdings', replace

save "$work/holdings_income_$temp", replace

//Second, we remove inward DI interest income of residential operating units 
import delimited "$rawdata/FDI_INC_AGGR_raw_SPE_ROU_TH", delimiter(",") clear
// this is only for tax haven countries at the moment


keep if time_period == $temp
keep if currency == "USD"
keep if measure_principle == "DI"
keep if measure == "T_D4Q_FL" 	//interest income
keep if type_entity == "ROU" 	//only residential operating units
keep if counterpart_area == "W"
keep if activity == "_T"

rename ref_area cou

keep obs_value cou
rename obs_value ROU_interest

tempfile interest
save `interest', replace

save "$work/interest_income_$temp", replace


//replace inward DI income of operating units net of inward DI income in holdings and inward DI interest income

use "$work/ROU_E_$temp", clear

merge 1:1 cou using `holdings', nogen
merge 1:1 cou using `interest', nogen

replace ROU_interest = 0 if ROU_interest <0 | ROU_interest==.
replace ROU_holdings = 0 if ROU_holdings <0 | ROU_holdings==.
rename valueROU_E ROU_gross


gen valueROU_Equity_income = ROU_gross - ROU_holdings - ROU_interest
save "$work/ROU_E_$temp", replace

*}
