//----------------------------------------
//Step 2b: Corporate tax data
//----------------------------------------	
*ssc install wbopendata

//Downloads corporate tax statistics by country subsequently used at various stages

foreach i in 2015 2016 2017 2018 2019 2020 2021	{		//analysis done for the years 2015-2021

local temp =`i'

*(i)*
//Based on GRD database we clean and structure corporate tax data

use "$rawdata/GRD", replace
keep iso id tax_corp year

duplicates tag id year, gen(dup)
drop if dup>0
tsset id year

replace tax_corp=L1.tax_corp if tax_corp==.
keep if year==`temp'
rename tax_corp corptax_pr_gdp
replace corptax_pr_gdp=corptax_pr_gdp/100
rename iso CountryCode


merge 1:1 CountryCode year using "$work/wbdata" 

gen corptaxrev=gdp*corptax_pr_gdp/1000000000

save "$work/GRD_wb_merge_`temp'", replace

*(ii)*
//We save clean data in different files as needed


//save separate file for corporate tax revenues by country

preserve
keep if year==`temp'
keep corptaxrev CountryCode
keep if corptaxrev!=.
save "$work/globaltaxrev_`temp'", replace
restore


}


