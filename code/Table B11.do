
//---------------------------------------------//
//Table B11
//---------------------------------------------//

//Table B11 needs be run first
//Table B11 computes FDI discrepancies for host countries Ireland, Luxembourg, the Netherlands
//Data comes from Eurostat and OECD data on inward and outward FDI net income positions for those countries
//investor (partner) countries considered are the EU, USA, and Japan
//we compute FDI discrepancies using the minimum discrepancy between that obtained in OECD and Eurostat


//Using OECD data

*import excel "$rawdata/OECD_BOP_for_tableB11", clear firstrow sheet("for_stata")

*if $temp >= 2022 {
//import new OECD data post 2024 update
import delimited "$rawdata/OECD_BOP_2025_update.csv", clear  


replace obs_value = 0 if obs_value ==.
//reshape data to wide to mimic data structure pre-update
rename ref_area cou 
rename counterpart_area partner 
reshape wide obs_value, i(cou partner measure_principle) j(time_period)

gen measure = .
replace measure = 1 if measure_principle == "DI"
replace measure = 2 if measure_principle == "DO"

drop measure_principle
reshape wide obs_value2015 obs_value2016 obs_value2017 obs_value2018 obs_value2019 obs_value2020 obs_value2021 obs_value2022 obs_value2023, i(cou partner) j(measure)

rename obs_value20151 DI_2015
rename obs_value20152 DO_2015
rename obs_value20161 DI_2016
rename obs_value20162 DO_2016
rename obs_value20171 DI_2017
rename obs_value20172 DO_2017
rename obs_value20181 DI_2018
rename obs_value20182 DO_2018
rename obs_value20191 DI_2019
rename obs_value20192 DO_2019
rename obs_value20201 DI_2020
rename obs_value20202 DO_2020
rename obs_value20211 DI_2021
rename obs_value20212 DO_2021
rename obs_value20221 DI_2022
rename obs_value20222 DO_2022
rename obs_value20231 DI_2023
rename obs_value20232 DO_2023
*}
keep DI_$temp DO_$temp cou partner 

tempfile tableb11
save `tableb11', replace

//inward data as reported by host countries (Ireland Luxembourg and Netherlands)

keep if cou == "IRL"| cou == "LUX"| cou == "NLD"
keep if partner == "JPN"| partner == "USA"
drop DO_$temp

tempfile DI
save `DI', replace

//outward data as reported by investing countries (Japan and United States)

use `tableb11', clear
keep if cou == "USA"|cou=="JPN"
keep if partner == "IRL"|partner == "NLD"| partner == "LUX"
drop DI_$temp

rename partner c
rename cou partner
rename c cou 

merge 1:1 partner cou using `DI'
drop _merge

gen disc_OECD_ = DO_$temp - DI_$temp
replace disc_OECD = disc_OECD*(-1) if disc_OECD<0	//
*replace disc_OECD = 0 if disc_OECD<0	//
keep disc_OECD_ partner cou

reshape wide disc_OECD_, i(cou) j(partner, string) 

rename cou ISO3

foreach v in disc_OECD_JPN disc_OECD_USA {
	replace `v'=0 if `v'==.
}

tempfile oecd
save `oecd', replace




//Using Eurostat data

// FDI discrepancy with European non-SPEs

use "$work/Disc_EU_DI_less_DO_$temp", clear

keep if partner_label == "Netherlands" | partner_label == "Luxembourg" | partner_label == "Ireland"
keep partner_label discrepancy_excl_SPE
rename discrepancy_excl_SPE discEU

tempfile eu_disc
save `eu_disc', replace

// FDI discrepancy with Japan and USA

use "$work/Disc_EXTEU_DI_less_DO_$temp", clear

keep if partner_label == "Netherlands" | partner_label == "Luxembourg" | partner_label == "Ireland"
keep partner_label geo_label discrepancy_DI_less_DO

replace geo_label = "USA" if geo_label == "United States" 		//prepare reshape command
replace geo_label = "JPN" if geo_label == "Japan"
rename discrepancy_DI_less_DO disc

reshape wide disc, i(partner_label) j(geo_label, string)

merge 1:1 partner_label using `eu_disc'
drop _merge

gen ISO3 = ""
replace ISO3 = "IRL" if partner_label == "Ireland"
replace ISO3 = "NLD" if partner_label == "Netherlands"
replace ISO3 = "LUX" if partner_label == "Luxembourg"
drop partner_label
order ISO3 discJPN discUSA discEU
foreach v in discEU discJPN discUSA {
	
	replace `v' = `v'/$USD_EUR		//from EUR to USD
	replace `v'= 0 if `v'==. | `v'<0
*	replace `v'=-`v' if `v'<0
}

merge 1:1 ISO3 using `oecd', nogen

gen min_USA = . 	//we take the minimum value between Eurostat and OECD for USA as investor country
replace min_USA = discUSA if discUSA > 0 & discUSA != . & (disc_OECD_USA >= discUSA | disc_OECD_USA < 0 | disc_OECD_USA == .)
replace min_USA = disc_OECD_USA if disc_OECD_USA > 0 & disc_OECD_USA != . & (discUSA > disc_OECD_USA | discUSA <= 0 | discUSA == .)
replace min_USA = 0 if min_USA==.

gen min_JPN = .		//we take the minimum value between Eurostat and OECD for Japan as investor country
replace min_JPN = discJPN if discJPN > 0 & discJPN != . & (disc_OECD_JPN >= discJPN | disc_OECD_JPN < 0 | disc_OECD_JPN == .)
replace min_JPN = disc_OECD_JPN if disc_OECD_JPN > 0 & disc_OECD_JPN != . & (discJPN > disc_OECD_JPN | discJPN <= 0 | discJPN == .)
replace min_JPN = 0 if min_JPN==.


//understimation issue in Lux 2019 and 2020:

if $temp == 2019 | $temp == 2020 {

replace min_USA = disc_OECD_USA if ISO3 == "LUX" & disc_OECD_USA>discUSA
replace min_USA = discUSA if ISO3 == "LUX" & discUSA>disc_OECD_USA

replace min_JPN = disc_OECD_JPN if ISO3 == "LUX" & disc_OECD_JPN>discJPN
replace min_JPN = discJPN if ISO3 == "LUX" & discJPN>disc_OECD_JPN
}
//missing data issue for NLD in 2022
//OECD data: NLD has no data for DI from USA in 2022
//Eurostat data: NLD has negative value for DI from USA in 2022. 
//We set to zero. 
replace min_USA = 0 if ISO3 == "NLD" & $temp == 2022


gen disc_total =.		//we remove discrepancies with negative values 
foreach v in discEU min_JPN min_USA {
	replace `v'= 0 if `v' <0
}

*replace discEU = 0 if ISO3 == "NLD" & $temp == 2019	//Eurostat data beyond 2019 is missing or inconsistent from Brexit onwards for the Netherlands
replace disc_total = min_JPN + min_USA + discEU 

save "$work/TableB11_$temp", replace
export excel using "$root/output/Part1-profit-shifting-$temp.xlsx", firstrow(var) sheet("Table B11", replace) keepcellfmt 

