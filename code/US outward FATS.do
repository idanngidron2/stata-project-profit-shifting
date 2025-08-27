//----------------------------------------
//Step 6a: US FATS data
//----------------------------------------

// used to compute the profit/wage ratio for affiliates of US multinationals outside the US	
/*
if $temp <=2020 {
	
	local temp = $temp
}
else if $temp > 2020 {				//beyond 2020 we keep 2020 values 
	
	local temp = 2020
}
*/

//Import raw data downloaded from BEA

import excel "$rawdata/US_outward_FATS", sheet ("$temp") cellrange (A5:G92) firstrow clear

rename A country
drop if country == ""

//create profits to employee compensation ratio 
//this will give a first idea of the profits to wage ratio in the foreign sector - a key statistic for the analysis

keep country Profittypereturn1 Compensationofemployees
foreach v in Compensationofemployees Profittypereturn1 {

	destring `var', replace	
	
}

gen US_outward_P_W_ratio =.
replace US_outward_P_W_ratio = Profittypereturn1/Compensationofemployees

//replace BEA value for Country by Country report value for cases where BEA has misleading values

replace US_outward_P_W_ratio = 0.683653889 if country == "Bermuda" 		//using CBC 2018 value
replace US_outward_P_W_ratio = 2.937717840 if country == "Hong Kong" 	//using CBC 2018 value

// Save in Stata format

keep US_outward_P_W_ratio country Compensationofemployees
save "$work/US_outward_FATS_$temp", replace



