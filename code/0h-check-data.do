//----------------------------------------
//Check data do file
//----------------------------------------

//----------------------------------------
//Purpose of the do file
//----------------------------------------

//Compares estimates of tables B11, B10 and U1 between Stata output and missingprofits output. 
//Comparison made for years 2016-2019


//Start with 2016-2018, 2019 is below

if $temp == 2016 | $temp == 2017 | $temp == 2018 {
	
	
//start with uploading data frame	
	
use "$work/shifted_profits_U1_$temp", clear

keep country ISO3

tempfile structure
save `structure', replace

//upload values from missing profits 

import excel "$rawdata/missingprofits_$temp", firstrow sheet("Table U1") cellrange(A6:AD90) clear

//reorganise data to match with Stata output

rename A ISO3
rename B country
rename CorpTaxpaid MP_corptaxrev
rename GDP MP_GDP
rename Effectivecorporatetaxrate MP_corporate_ETR
rename Compensationofemployees MP_corp_wage
rename I MP_local_corp_wage
rename J MP_foreign_corp_wage
rename Reportedprofits MP_pre_tax_corp_profits
rename Totalcorporateprofitscorrect MP_tax_prof
rename Unrecordedprofits MP_profit_correction
rename Totalprofitsofforeigncorp MP_pre_tax_foreign_profits 
rename RecordedprofitsofSPEsnet MP_SPE_profits
rename Missingprofitoutflows MP_unrecorded_foreign_profits
rename Profitsofholdingcompanies MP_profits_offshore_funds
rename Equityincomeofoperatingunits MP_net_op_profit
rename Taxableprofitscompensation MP_profit_wage_ratio_all 
rename AA MP_profit_wage_ratio_local
rename AB MP_profit_wage_ratio_foreign
rename AC MP_US_outward_P_W_ratio
rename Artificiallyshiftedprofits MP_shifted_profits
rename Totallocalprofitscorrected MP_pre_tax_local_profits
rename S MP_foreign_corptaxrev


drop F G Z Profitsofoperatingunits Interestincome Localprofits Effectivecorporatetaxrateco

replace ISO3 = "BHR" if country == "Bahrain"
replace ISO3 = "VGB" if country == "British Virgin Islands"
replace ISO3 = "HKG" if country == "Hong Kong"
replace ISO3 = "MAC" if country == "Macau"
replace ISO3 = "MHL" if country == "Marshall Islands"
replace ISO3 = "ROW" if country == "Rest of world"
replace ISO3 = "WLD" if country == "World total"


drop if country == ""
drop if ISO3==""

tempfile missingprofits
save `missingprofits', replace

//merge missing profits data to structure using ISO codes

use `structure', replace
merge 1:1 ISO3 using `missingprofits', nogen



foreach v in MP_corporate_ETR MP_corp_wage MP_local_corp_wage MP_foreign_corp_wage MP_profit_wage_ratio_all MP_profit_wage_ratio_local MP_profit_wage_ratio_foreign MP_US_outward_P_W_ratio MP_pre_tax_corp_profits MP_tax_prof MP_profit_correction{
	destring `v', replace
}

//merge Stata output data

merge 1:1 ISO3 using "$work/shifted_profits_U1_$temp", nogen

rename profits_offshore_mutual_funds profits_offshore_funds

//reorder and prepare data for comparison

replace MP_shifted_profits = 0 if tax_haven == 0 & ISO3 != "WLD"

gen sorting = . 
replace sorting = 0 if group == "OECD"
replace sorting = 1 if group == "OECD_TH"
replace sorting = 2 if group == "DEV"
replace sorting = 3 if group == "TH"
replace sorting = 4 if group == "other"
sort sorting ISO3
drop sorting

//generate delta between Stata output and missing profits 

foreach v in GDP corp_wage local_corp_wage foreign_corp_wage pre_tax_corp_profits tax_prof profit_correction corptaxrev corporate_ETR pre_tax_local_profits pre_tax_foreign_profits net_op_profit SPE_profits unrecorded_foreign_profits foreign_corptaxrev profits_offshore_funds profit_wage_ratio_all profit_wage_ratio_local profit_wage_ratio_foreign US_outward_P_W_ratio shifted_profits {
	
	gen MPd_`v'=.
	replace MPd_`v' = `v' - MP_`v'
	replace MPd_`v' = round(MPd_`v',0.01) 

}

gen ISO3a = ISO3
gen ISO3b = ISO3
gen ISO3c = ISO3
gen ISO3d = ISO3
gen ISO3e = ISO3
gen ISO3f = ISO3
gen ISO3g = ISO3


*order country ISO3 group tax_haven GDP GDP_ch d_GDP corptaxrev corptaxrev_ch d_corptaxrev  corporate_ETR corporate_ETR_ch d_corporate_ETR foreign_corp_wage foreign_corp_wage_ch d_foreign_corp_wage ISO3a foreign_corptaxrev foreign_corptaxrev_ch d_foreign_corptaxrev corp_wage corp_wage_ch d_corp_wage local_corp_wage local_corp_wage_ch d_local_corp_wage ISO3b net_op_profit net_op_profit_ch d_net_op_profit pre_tax_corp_profits pre_tax_corp_profits_ch d_pre_tax_corp_profits ISO3c pre_tax_foreign_profits pre_tax_foreign_profits_ch d_pre_tax_foreign_profits pre_tax_local_profits pre_tax_local_profits_ch d_pre_tax_local_profits ISO3d profit_correction profit_correction_ch d_profit_correction  ISO3e profit_wage_ratio_local profit_wage_ratio_local_ch d_profit_wage_ratio_local SPE_profits SPE_profits_ch d_SPE_profits tax_prof tax_prof_ch d_tax_prof ISO3f unrecorded_foreign_profits unrecorded_foreign_profits_ch d_unrecorded_foreign_profits profits_offshore_funds profits_offshore_funds_ch d_profits_offshore_funds profit_wage_ratio_all profit_wage_ratio_all_ch ISO3g d_profit_wage_ratio_all profit_wage_ratio_foreign profit_wage_ratio_foreign_ch d_profit_wage_ratio_foreign US_outward_P_W_ratio US_outward_P_W_ratio_ch d_US_outward_P_W_ratio shifted_profits shifted_profits_ch d_shifted_profits

tempfile step2
save `step2', replace

}




//--------------------------------------------------------
//repeat code with changes to adapt for 2019 structure
//--------------------------------------------------------

//reason being that in 2019 missing profits use different structure


else if $temp == 2019 {
	
	use "$work/shifted_profits_U1_$temp", clear

keep country ISO3

tempfile structure
save `structure', replace

//upload values from missing profits 

import excel "$rawdata/missingprofits_$temp", firstrow sheet("Table U1") cellrange(A6:W90) clear

//reorganise data to match with Stata output

rename A ISO3
rename B country
rename Corporatetaxpaid MP_corptaxrev
rename GDP MP_GDP
rename Effectivetaxrate MP_corporate_ETR
rename Compensationofemployeesincop MP_corp_wage
rename E MP_local_corp_wage
rename F MP_foreign_corp_wage
rename Pretaxcorporateprofits MP_pre_tax_corp_profits
rename H MP_tax_prof
rename I MP_profit_correction
rename Pretaxforeignprofits MP_pre_tax_foreign_profits
rename ProfitsofSPEsnet MP_SPE_profits
rename Unrecordednetoftaxforeignpr MP_unrecorded_foreign_profits
rename Profitsofoffshoremutualfunds MP_profits_offshore_funds
rename Netoftaxprofitofoperatingu MP_net_op_profit
rename Pretaxprofitscompensation MP_profit_wage_ratio_all
rename T MP_profit_wage_ratio_local
rename U MP_profit_wage_ratio_foreign
rename V MP_US_outward_P_W_ratio
rename Shiftedprofits MP_shifted_profits
rename Pretaxlocalprofits MP_pre_tax_local_profits
rename Corporatetaxpaidonforeignpr MP_foreign_corptaxrev


replace ISO3 = "BHR" if country == "Bahrain"
replace ISO3 = "VGB" if country == "British Virgin Islands"
replace ISO3 = "HKG" if country == "Hong Kong"
replace ISO3 = "MAC" if country == "Macau"
replace ISO3 = "MHL" if country == "Marshall Islands"
replace ISO3 = "ROW" if country == "Rest of world"
replace ISO3 = "WLD" if country == "World total"
	
drop if country == ""
drop if ISO3==""

tempfile missingprofits
save `missingprofits', replace

//merge missing profits data to structure using ISO codes

use `structure', replace
merge 1:1 ISO3 using `missingprofits', nogen



foreach v in MP_corporate_ETR MP_corp_wage MP_local_corp_wage MP_foreign_corp_wage MP_profit_wage_ratio_all MP_profit_wage_ratio_local MP_profit_wage_ratio_foreign MP_US_outward_P_W_ratio MP_pre_tax_corp_profits MP_tax_prof MP_profit_correction{
	destring `v', replace
}

//merge Stata output data

merge 1:1 ISO3 using "$work/shifted_profits_U1_$temp", nogen

rename profits_offshore_mutual_funds profits_offshore_funds

//reorder and prepare data for comparison

replace MP_shifted_profits = 0 if tax_haven == 0 & ISO3 != "WLD"

gen sorting = . 
replace sorting = 0 if group == "OECD"
replace sorting = 1 if group == "OECD_TH"
replace sorting = 2 if group == "DEV"
replace sorting = 3 if group == "TH"
replace sorting = 4 if group == "other"
sort sorting ISO3
drop sorting

//generate delta between Stata output and missing profits 

foreach v in GDP corp_wage local_corp_wage foreign_corp_wage pre_tax_corp_profits tax_prof profit_correction corptaxrev corporate_ETR pre_tax_local_profits pre_tax_foreign_profits net_op_profit SPE_profits unrecorded_foreign_profits foreign_corptaxrev profits_offshore_funds profit_wage_ratio_all profit_wage_ratio_local profit_wage_ratio_foreign US_outward_P_W_ratio shifted_profits {
	
	gen MPd_`v'=.
	replace MPd_`v' = `v' - MP_`v'
	replace MPd_`v' = round(MPd_`v',0.01) 

}

gen ISO3a = ISO3
gen ISO3b = ISO3
gen ISO3c = ISO3
gen ISO3d = ISO3
gen ISO3e = ISO3
gen ISO3f = ISO3
gen ISO3g = ISO3


*order country ISO3 group tax_haven GDP GDP_ch d_GDP corptaxrev corptaxrev_ch d_corptaxrev  corporate_ETR corporate_ETR_ch d_corporate_ETR foreign_corp_wage foreign_corp_wage_ch d_foreign_corp_wage ISO3a foreign_corptaxrev foreign_corptaxrev_ch d_foreign_corptaxrev corp_wage corp_wage_ch d_corp_wage local_corp_wage local_corp_wage_ch d_local_corp_wage ISO3b net_op_profit net_op_profit_ch d_net_op_profit pre_tax_corp_profits pre_tax_corp_profits_ch d_pre_tax_corp_profits ISO3c pre_tax_foreign_profits pre_tax_foreign_profits_ch d_pre_tax_foreign_profits pre_tax_local_profits pre_tax_local_profits_ch d_pre_tax_local_profits ISO3d profit_correction profit_correction_ch d_profit_correction  ISO3e profit_wage_ratio_local profit_wage_ratio_local_ch d_profit_wage_ratio_local SPE_profits SPE_profits_ch d_SPE_profits tax_prof tax_prof_ch d_tax_prof ISO3f unrecorded_foreign_profits unrecorded_foreign_profits_ch d_unrecorded_foreign_profits profits_offshore_funds profits_offshore_funds_ch d_profits_offshore_funds profit_wage_ratio_all profit_wage_ratio_all_ch ISO3g d_profit_wage_ratio_all profit_wage_ratio_foreign profit_wage_ratio_foreign_ch d_profit_wage_ratio_foreign US_outward_P_W_ratio US_outward_P_W_ratio_ch d_US_outward_P_W_ratio shifted_profits shifted_profits_ch d_shifted_profits

tempfile step2
save `step2', replace

}


//---------import Atlas results--------------//

//the final step is to import the Atlas results for comparison

import excel "$rawdata/Atlas_results_U1", firstrow sheet("$temp") cellrange(A1:Y81) clear

//reorganise data to match with Stata output


rename country_group group
rename code ISO3
rename GDP_1 Atlas_GDP
rename corpwage_all_2 Atlas_corp_wage
rename corpwage_local_3 Atlas_local_corp_wage
rename corpwage_foreign_4 Atlas_foreign_corp_wage
rename pre_tax_CP_5 Atlas_pre_tax_corp_profits
rename taxprof_6 Atlas_tax_prof
rename profit_corr_7 Atlas_profit_correction
rename corptaxrev_8 Atlas_corptaxrev
rename ETR_9 Atlas_corporate_ETR
rename pre_tax_LP_10 Atlas_pre_tax_local_profits
rename pre_tax_FP_11 Atlas_pre_tax_foreign_profits
rename net_op_profit_12 Atlas_net_op_profit
rename SPE_profits_net_13 Atlas_SPE_profits
rename unrecorded_profits_14 Atlas_unrecorded_foreign_profits
rename corp_tax_paid_FP_15 Atlas_foreign_corptaxrev
rename mutual_funds_OP_16 Atlas_profits_offshore_funds
rename profit_wage_ratio_all_17 Atlas_profit_wage_ratio_all
rename profit_wage_ratio_local_18 Atlas_profit_wage_ratio_local
rename profit_wage_ratio_foreign_19 Atlas_profit_wage_ratio_foreign
rename profit_wage_ratio_20 Atlas_US_outward_P_W_ratio
rename shifted_profits_21 Atlas_shifted_profits

replace group = "OECD_TH" if (group=="OECD" & tax_haven==1)
replace group = "TH" if group=="TH non-OECD"

tempfile atlas
save `atlas', replace

use `structure', clear
merge 1:1 ISO3 using `atlas', nogen


//merge Stata output

merge 1:1 ISO3 using "`step2'", nogen

//reorder and prepare data for comparison

replace Atlas_shifted_profits = 0 if tax_haven == 0 & ISO3 != "WLD"

gen sorting = . 
replace sorting = 0 if group == "OECD"
replace sorting = 1 if group == "OECD_TH"
replace sorting = 2 if group == "DEV"
replace sorting = 3 if group == "TH"
replace sorting = 4 if group == "other"
sort sorting ISO3
drop sorting

//generate delta between Stata output and atlas

foreach v in GDP corp_wage local_corp_wage foreign_corp_wage pre_tax_corp_profits tax_prof profit_correction corptaxrev corporate_ETR pre_tax_local_profits pre_tax_foreign_profits net_op_profit SPE_profits unrecorded_foreign_profits foreign_corptaxrev profits_offshore_funds profit_wage_ratio_all profit_wage_ratio_local profit_wage_ratio_foreign US_outward_P_W_ratio shifted_profits {
	
	gen Ad_`v'=.
	replace Ad_`v' = `v' - Atlas_`v'
	replace Ad_`v' = round(Ad_`v',0.01) 
	
	
}


order country ISO3 group tax_haven GDP MP_GDP MPd_GDP Atlas_GDP Ad_GDP corptaxrev MP_corptaxrev MPd_corptaxrev  Atlas_corptaxrev Ad_corptaxrev  corporate_ETR MP_corporate_ETR MPd_corporate_ETR Atlas_corporate_ETR Ad_corporate_ETR foreign_corp_wage MP_foreign_corp_wage MPd_foreign_corp_wage Atlas_foreign_corp_wage Ad_foreign_corp_wage ISO3a foreign_corptaxrev MP_foreign_corptaxrev MPd_foreign_corptaxrev Atlas_foreign_corptaxrev Ad_foreign_corptaxrev corp_wage MP_corp_wage MPd_corp_wage Atlas_corp_wage Ad_corp_wage local_corp_wage MP_local_corp_wage MPd_local_corp_wage Atlas_local_corp_wage Ad_local_corp_wage ISO3b net_op_profit MP_net_op_profit MPd_net_op_profit Atlas_net_op_profit Ad_net_op_profit pre_tax_corp_profits MP_pre_tax_corp_profits MPd_pre_tax_corp_profits Atlas_pre_tax_corp_profits Ad_pre_tax_corp_profits ISO3c pre_tax_foreign_profits MP_pre_tax_foreign_profits MPd_pre_tax_foreign_profits Atlas_pre_tax_foreign_profits Ad_pre_tax_foreign_profits pre_tax_local_profits MP_pre_tax_local_profits MPd_pre_tax_local_profits Atlas_pre_tax_local_profits Ad_pre_tax_local_profits ISO3d profit_correction MP_profit_correction MPd_profit_correction Atlas_profit_correction Ad_profit_correction ISO3e profit_wage_ratio_local MP_profit_wage_ratio_local MPd_profit_wage_ratio_local Atlas_profit_wage_ratio_local Ad_profit_wage_ratio_local SPE_profits MP_SPE_profits MPd_SPE_profits Atlas_SPE_profits Ad_SPE_profits tax_prof MP_tax_prof MPd_tax_prof Atlas_tax_prof Ad_tax_prof ISO3f unrecorded_foreign_profits MP_unrecorded_foreign_profits MPd_unrecorded_foreign_profits Atlas_unrecorded_foreign_profits Ad_unrecorded_foreign_profits profits_offshore_funds MP_profits_offshore_funds MPd_profits_offshore_funds Atlas_profits_offshore_funds Ad_profits_offshore_funds profit_wage_ratio_all MP_profit_wage_ratio_all MPd_profit_wage_ratio_all Atlas_profit_wage_ratio_all Ad_profit_wage_ratio_all ISO3g profit_wage_ratio_foreign MP_profit_wage_ratio_foreign MPd_profit_wage_ratio_foreign Atlas_profit_wage_ratio_foreign Ad_profit_wage_ratio_foreign US_outward_P_W_ratio MP_US_outward_P_W_ratio MPd_US_outward_P_W_ratio Atlas_US_outward_P_W_ratio Ad_US_outward_P_W_ratio shifted_profits MP_shifted_profits MPd_shifted_profits Atlas_shifted_profits Ad_shifted_profits



save "$root/verification/verification_data_$temp", replace


//generate verification graphs


	


cd "$root/figures/TWZ_vs_stata"

keep ISO3 shifted_profits MP_shifted_profits Atlas_shifted_profits
rename shifted_profits shifted_profits_stata
rename MP_shifted_profits shifted_profits_TWZ
rename Atlas_shifted_profits shifted_profits_atlas

replace shifted_profits_stata = 0 if shifted_profits_stata == . 
reshape long shifted_profits_, i(ISO3) j(source, string)

drop if source == "atlas"

if $temp == 2016 {
gen year = 16
}

if $temp == 2017 {
gen year = 17
}

if $temp == 2018 {
gen year = 18
}

if $temp == 2019 {
gen year = 19
}



save "$work/verification_figures_$temp", replace

if $temp == 2019 {
use "$work/verification_figures_2016", clear

append using "$work/verification_figures_2017"
append using "$work/verification_figures_2018"
append using "$work/verification_figures_2019"


preserve 
keep if ISO3 == "IRL" 	//Ireland
 graph bar shifted_profits_, asyvars over (source) over (year) bar(1, color(orange*0.8)) bar(2, color(blue*0.8)) nodraw   ///
	title("Ireland") ///
	ytitle("USD Bln")				///
		

 graph save IRL, replace 
restore
 

preserve 
keep if ISO3 == "NLD" 	//Netherlands
 graph bar shifted_profits_, asyvars over (source) over (year) bar(1, color(orange*0.8)) bar(2, color(blue*0.8)) nodraw   ///
	title("Netherlands") ///
	ytitle("USD Bln")				///

 graph save NLD, replace
restore
 
 
 preserve 
keep if ISO3 == "CHE" 	//Switzerland
 graph bar shifted_profits_, asyvars over (source) over (year) bar(1, color(orange*0.8)) bar(2, color(blue*0.8)) nodraw   ///
	title("Switzerland") ///
	ytitle("USD Bln")				///

 graph save CHE, replace
restore
 
 
 preserve 
keep if ISO3 == "LUX" 	//Luxembourg
 graph bar shifted_profits_, asyvars over (source) over (year) bar(1, color(orange*0.8)) bar(2, color(blue*0.8)) nodraw   ///
	title("Luxembourg") ///
	ytitle("USD Bln")				///

 graph save LUX, replace
restore
 
 
 preserve 
keep if ISO3 == "BEL" 	//Belgium
 graph bar shifted_profits_, asyvars over (source) over (year) bar(1, color(orange*0.8)) bar(2, color(blue*0.8)) nodraw   ///
	title("Belgium") ///
	ytitle("USD Bln")				///

 graph save BEL, replace
restore
 
 
 preserve 
keep if ISO3 == "HKG" 	//Hong Kong
 graph bar shifted_profits_, asyvars over (source) over (year) bar(1, color(orange*0.8)) bar(2, color(blue*0.8)) nodraw   ///
	title("Hong Kong") ///
	ytitle("USD Bln")				///

 graph save HKG, replace
restore
 
 
 preserve 
keep if ISO3 == "SGP" 	//Singapore
 graph bar shifted_profits_, asyvars over (source) over (year) bar(1, color(orange*0.8)) bar(2, color(blue*0.8)) nodraw   ///
	title("Singapore") ///
	ytitle("USD Bln")				///

 graph save SGP, replace
restore
 
 preserve 
keep if ISO3 == "PRI" 	//Puerto Rico
 graph bar shifted_profits_, asyvars over (source) over (year) bar(1, color(orange*0.8)) bar(2, color(blue*0.8)) nodraw   ///
	title("Puerto Rico") ///
	ytitle("USD Bln")				///

 graph save PRI, replace
restore
 

preserve 
keep if ISO3 == "BMU" 	//Bermuda
 graph bar shifted_profits_, asyvars over (source) over (year) bar(1, color(orange*0.8)) bar(2, color(blue*0.8)) nodraw   ///
	title("Bermuda") ///
	ytitle("USD Bln")				///

 graph save BMU, replace
restore
 
 
 preserve 
keep if ISO3 == "VGB" 	//British Virgin Islands
 graph bar shifted_profits_, asyvars over (source) over (year) bar(1, color(orange*0.8)) bar(2, color(blue*0.8)) nodraw   ///
	title("British Virgin Islands") ///
	ytitle("USD Bln")				///

 graph save VGB, replace
restore
 
 
 preserve 
keep if ISO3 == "CYM" 	//Cayman Islands
 graph bar shifted_profits_, asyvars over (source) over (year) bar(1, color(orange*0.8)) bar(2, color(blue*0.8)) nodraw   ///
	title("Cayman Islands") ///
	ytitle("USD Bln")				///

 graph save CYM, replace
restore
 
 
 preserve 
keep if ISO3 == "CUW" 	//Curacao
 graph bar shifted_profits_, asyvars over (source) over (year) bar(1, color(orange*0.8)) bar(2, color(blue*0.8)) nodraw   ///
	title("Curacao") ///
	ytitle("USD Bln")				///

 graph save CUW, replace
restore
 
 
 preserve 
keep if ISO3 == "MAC" 	//Macao
 graph bar shifted_profits_, asyvars over (source) over (year) bar(1, color(orange*0.8)) bar(2, color(blue*0.8)) nodraw   ///
	title("Macao") ///
	ytitle("USD Bln")				///

 graph save MAC, replace
restore
 
 
 preserve 
keep if ISO3 == "JEY" 	//Jersey
 graph bar shifted_profits_, asyvars over (source) over (year) bar(1, color(orange*0.8)) bar(2, color(blue*0.8)) nodraw   ///
	title("Jersey") ///
	ytitle("USD Bln")				///

 graph save JEY, replace
restore
 
  preserve 
keep if ISO3 == "PAN" 	//Panama
 graph bar shifted_profits_, asyvars over (source) over (year) bar(1, color(orange*0.8)) bar(2, color(blue*0.8)) nodraw   ///
	title("Panama") ///
	ytitle("USD Bln")				///

 graph save PAN, replace
restore
 

 preserve 
keep if ISO3 == "CYP" 	//Cyprus
 graph bar shifted_profits_, asyvars over (source) over (year) bar(1, color(orange*0.8)) bar(2, color(blue*0.8)) nodraw   ///
	title("Cyprus") ///
	ytitle("USD Bln")				///

 graph save CYP, replace
restore
 
 
 preserve 
keep if ISO3 == "LBN" 	//Lebanon
 graph bar shifted_profits_, asyvars over (source) over (year) bar(1, color(orange*0.8)) bar(2, color(blue*0.8)) nodraw   ///
	title("Lebanon") ///
	ytitle("USD Bln")				///

 graph save LBN, replace
restore
 
  preserve 
keep if ISO3 == "BHR" 	//Bahrain
 graph bar shifted_profits_, asyvars over (source) over (year) bar(1, color(orange*0.8)) bar(2, color(blue*0.8)) nodraw   ///
	title("Bahrain") ///
	ytitle("USD Bln")				///

 graph save BHR, replace
restore

  preserve 
keep if ISO3 == "BHS" 	//Bahamas
 graph bar shifted_profits_, asyvars over (source) over (year) bar(1, color(orange*0.8)) bar(2, color(blue*0.8)) nodraw   ///
	title("Bahamas") ///
	ytitle("USD Bln")				///

 graph save BHS, replace
restore

  preserve 
keep if ISO3 == "BRB" 	//Barbados
 graph bar shifted_profits_, asyvars over (source) over (year) bar(1, color(orange*0.8)) bar(2, color(blue*0.8)) nodraw   ///
	title("Barbados") ///
	ytitle("USD Bln")				///

 graph save BRB, replace
restore
 
 
   preserve 
keep if ISO3 == "WLD" 	//World
 graph bar shifted_profits_, asyvars over (source) over (year) bar(1, color(orange*0.8)) bar(2, color(blue*0.8)) nodraw   ///
	title("World") ///
	ytitle("USD Bln")				///

 graph save WLD, replace
restore
 
 
 
 
 preserve	//top 12 tax havens
  graph combine "WLD" "IRL" "NLD" "CHE" "LUX" "BEL" "HKG" "SGP" "VGB" "BMU" "PRI" "CYM", cols(4) 
  


 graph save top, replace
  graph export "$root/figures/TWZ_vs_stata/2016-2019 top12.png", replace 

restore

preserve	//other tax havens
  graph combine "BHR" "LBN" "CYP" "JEY" "MAC" "CUW" "BRB" "VGB" "BMU" "PRI" "PAN" "BHS", cols(4) 
 graph save other, replace
  graph export "$root/figures/TWZ_vs_stata/2016-2019 other tax havens.png", replace 

restore
}

