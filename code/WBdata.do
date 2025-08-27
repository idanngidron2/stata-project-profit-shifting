//----------------------------------------
//Step 2a: World bank data
//----------------------------------------	

//This do file downloads and structures GDP and depreciation by country


wbopendata, indicator(ny.adj.dkap.cd; NY.GDP.MKTP.CD; GC.XPN.COMP.CN; PA.NUS.FCRF) clear long 
keep if year>2011

rename ny_gdp_mktp_cd gdp
rename ny_adj_dkap_cd depreciation
gen comp_emp=gc_xpn_comp_cn/pa_nus_fcrf
rename countryname CountryName
rename countrycode CountryCode

save "$work/wbdata", replace

//save separate file for GDP values 

use "$work/wbdata", clear
rename gdp GDP
rename CountryCode location
rename Country country
rename year time

keep time location country GDP

save "$work/GDPforOECD", replace