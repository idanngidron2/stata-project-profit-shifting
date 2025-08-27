//------------------------------------------------------------------------------
//Table C4d: country losses as a share of CIT revenue and total revenue losses
//------------------------------------------------------------------------------

//import CIT rates 

import excel "$rawdata/CIT rates", firstrow sheet ("Sheet1")clear

isocodes LOCATION, gen (iso3c)
replace iso3c = "ROW" if LOCATION == "Global average"
drop if iso3c == ""

tempfile tf
save `tf', replace 
import excel "$rawdata/CIT rates_2021_24.xlsx", firstrow clear
rename ISO3 iso3c
reshape wide CIT_rate, i(iso3c) j(year)
rename CIT_rate2021 y_2021
rename CIT_rate2022 y_2022
rename CIT_rate2023 y_2023
rename CIT_rate2024 y_2024
drop if iso3c == ""

*import excel "$rawdata/CIT rates", firstrow sheet("Sheet2") clear
*isocodes A, gen (iso3c)
*drop if iso3c == ""
*rename C y_2021
*rename D y_2022
*tempfile tf2 
*keep iso3c y_2021 y_2022
tempfile tf2
save `tf2', replace 
use `tf', clear
merge m:m iso3c using `tf2', nogen force
drop I
drop if LOCATION == ""
destring y_2021, replace
*rename H y_2020
*rename G y_2019
*rename F y_2018
*rename E y_2017
*rename D y_2016
replace y_2021 = y_2020 if iso3c == "ROW"
replace y_2022 = y_2020 if iso3c == "ROW"
save "$work/CIT rates", replace 

//import corporate tax revenue values

*use "$work/globaltaxrev_$temp", clear 							//UN GRD database

use "$work/corptaxrev_comprehensive_$temp", clear 				//Bachas et al ETR database

rename CountryCode ISO3
*replace corptaxrev = corptaxrev*1000 if ISO3=="KOR" 			//correct for error in computation for Korea
replace corptaxrev = 0.4455 if ISO3 == "LVA" & $temp == 2019 	//replace the value for LVA in 2019 to the average 2014-2018 to adjust for low value from corp tax reform in LVA
replace corptaxrev = corptaxrev * 1000		//bln to mln 

tempfile taxrev
save `taxrev', replace



use "$work/shifted_profits_U1_$temp", clear 

replace corptaxrev = corptaxrev * 1000		//bln to mln 
keep ISO3 corptaxrev

tempfile tf 
save `tf', replace 

use `taxrev', clear 
merge m:m ISO3 using `tf', nogen 
save `taxrev', replace 


use "$work/CIT rates", clear 

keep y_$temp iso3c 
rename iso3c ISO3 
rename y_$temp CIT_rate
replace CIT_rate = CIT_rate/100
tempfile tf2
save `tf2', replace 

use `taxrev', clear
merge m:m ISO3 using `tf2', nogen
drop if corptaxrev == .

save `tf2', replace 

use "$work/table_C4_$temp", clear 
merge m:m ISO3 using `tf2', nogen
replace corptaxrev = 0 if group == "OECD_TH"
replace CIT_rate = 0 if group == "OECD_TH"
drop if group == ""


keep All_havens Non_EU_havens EU_havens corptaxrev CIT_rate group ISO3 country EU

foreach name in "All_havens" "Non_EU_havens" "EU_havens" {
	
	gen revenue_loss_`name'=.
	gen loss_as_share_`name'=. 
	replace revenue_loss_`name' = `name' * CIT_rate
	replace loss_as_share_`name' = revenue_loss_`name'/corptaxrev
	sum revenue_loss_`name' if (group != "OECD_TH" & ISO3 != "NHT" & ISO3!= "WLD")
	local numerator = r(sum)
	sum corptaxrev if (group != "OECD_TH" & ISO3 != "NHT" & ISO3!= "WLD")
	local denominator = r(sum)
	replace revenue_loss_`name' = `numerator'/`denominator' if ISO3 == "NHT"
}

	sum revenue_loss_All_havens if ISO3!= "NHT" & ISO3 != "WLD"
	local num = r(sum)
	display `num'
	sum corptaxrev if ISO3!= "NHT" & ISO3 != "WLD"
	local den = r(sum)
	display `den'
	global revenue_loss_$temp = `num'/`den'
	display $revenue_loss_$temp
*sum loss_as_share_All_havens if (ISO3 != "BEL" & ISO3 != "CYP" & ISO3 != "LUX" & ISO3 != "IRL" & ISO3 != "MLT" & ISO3 != "NLD" & ISO3 != "WLD")
//Final reoredering and export results
gen sort_dummy=.
replace sort_dummy=1 if group=="OECD"
replace sort_dummy=2 if group=="OECD_TH"
replace sort_dummy=3 if group=="DEV"
replace sort_dummy=4 if group=="NEW_DEV"
replace sort_dummy=5 if group=="other" 
sort sort_dummy ISO3 
drop sort_dummy


save "$work/table_C4d_$temp", replace
export excel using "$root/output/Part2-reallocating-profits-$temp.xlsx", firstrow(var) sheet("Table C4d", replace) keepcellfmt
	

	
	
	
	
	
	