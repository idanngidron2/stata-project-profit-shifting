//-----------------------------------------------
//Step 5d: FDI income credit EU - EU 
//-----------------------------------------------

//the dofile that handles FDI income credit data where both parties are EU countries


//------------------(i)----------------------//
//OUTWARD FDI i.e. parent income owed


//Basic data cleaning, and initial imputations


use "$work/basic", clear


drop if (geo=="CH"|geo=="EA18"|geo=="EA19"|geo=="ME"|geo=="MK"|geo=="TR"|geo=="NO"|geo=="IS"|geo=="RS")
keep if stk_flow=="CRE" & direction=="DO"

keep if (partner=="EU28"|partner=="AT"|	partner=="BE"|	partner=="BG"|	partner=="CY"|	partner=="CZ"|	partner=="DE"|	partner=="DK"|	partner=="EE"|	partner=="EL"|	partner=="ES"|	partner=="FI"|	partner=="FR"|	partner=="HR"|	partner=="HU"|	partner=="IE"|	partner=="IT"|	partner=="LT"|	partner=="LU"|	partner=="LV"|	partner=="MT"|	partner=="NL"|	partner=="PL"|	partner=="PT"|	partner=="RO"|	partner=="SE"|	partner=="SI"|	partner=="SK"|	partner=="UK")
replace bop_fdi6_inc$temp =0 if partner==geo & partner!="EU28"

gen nongroup_partner=partner!="EU28"
gen income=nongroup_partner*bop_fdi6_inc$temp


gen bop_notEU=bop_fdi6_inc$temp if (geo!="EU28" & geo!="EU27_2020")


//We begin by counting the missing "partner" observations- If all countries report which partners they earn income from (temp==28 if all report). We also calculate the amount of income that is unaccounted for pr. partner by using the EU aggregate

egen temp=count(bop_notEU), by(fdi_item partner)
gen EU_sum_percat_partner_aux= bop_fdi6_inc$temp if geo=="EU28"
egen EU_sum_percat_partner=total(EU_sum_percat_partner_aux), by(partner fdi_item) missing


gen income_no_EU28=bop_fdi6_inc$temp if (geo!="EU28" & geo!="EU27_2020")
egen EU_sum_percat_partner_est=total(income_no_EU28), by(fdi_item partner)
gen res_EU28_percat_partner=EU_sum_percat_partner-EU_sum_percat_partner_est

//First strictly logical (true) imputation based on EU28 sum and country aggregate (i.e. if all countries but one is reporting their partners we can use the EU aggregate and perfectly impute the last country)
replace bop_fdi6_inc$temp=res_EU28_percat_partner if bop_fdi6_inc$temp==. & (geo!="EU28" & geo!="EU27_2020") & temp==27


egen count_cat= count(bop_fdi6_inc$temp), by(geo partner)

//Second strictly logical (true) imputation based on all categories having to sum up to total (same logic: their are 4 income categories - they have to sum up to the total)
gen income_no_aggregate=bop_fdi6_inc$temp if fdi_item_label!="Direct investment abroad"
gen sum_aux=bop_fdi6_inc$temp if fdi_item_label=="Direct investment abroad"
egen sum_listet_pr_partner = total(sum_aux), by(geo partner) missing
egen sum_agg_partner_est=total(income_no_aggregate), by(geo partner) 
gen res_partner=sum_listet_pr_partner-sum_agg_partner_est
drop sum_aux


replace bop_fdi6_inc$temp= res_partner if fdi_item_label!="Direct investment abroad" & bop_fdi6_inc$temp==. & count_cat==3

replace bop_fdi6_inc$temp= sum_agg_partner_est if fdi_item_label=="Direct investment abroad" & bop_fdi6_inc$temp==. & count_cat==3


//Third: what is missing from each reporter (geo) to the entire EU28 - This will give us a maximum amount of income to be imputed pr. reporter
gen internal_sum_agg_aux=bop_fdi6_inc$temp if partner=="EU28"
egen total_EXT_EU=total(internal_sum_agg_aux), by(geo fdi_item) missing

gen bop_partner_notEXT_EU=bop_fdi6_inc$temp if partner!="EU28"

egen temp2=count(bop_partner_notEXT_EU), by(fdi_item geo)

//We estimate how much fdi income is accounted for by aggregating all the reports of each individual country (within categories)
egen total_EU_est=total(income), by(geo fdi_item)

//We then calculate the difference between the sum of income from the EU and the sum of individual reports - this residual is the income that needs to be imputed pr. reporter-category (geo-fdi item) 
gen res_total_EU_geo=total_EXT_EU-total_EU_est


gen bop_missing=bop_fdi6_inc$temp==.


//Imputations

//Simple imputation procedure allocating the unaccounted income of each partner based on the FDI assets of each reporter
merge m:1 geo_label using "$rawdata/fdikeys" 
gen aux=diafdi_key_ass if bop_missing 
egen aux2=sum(aux), by(fdi_item partner)
gen imputed=(aux/aux2)*res_EU28_percat_partner
replace imputed=bop_fdi6_inc$temp if bop_missing==0 & (geo!="EU28" & geo!="EU27_2020")
egen check_aux=sum(imputed), by(fdi_item partner)
gen diff=check_aux-bop_fdi6_inc$temp if geo=="EU28"

replace imputed=. if geo=="IE"
replace bop_fdi6_inc$temp=. if geo=="IE",,
*replace imputed = -imputed if imputed <0 	//ensure imputed values are nonnegative
*replace imputed = 0 if imputed <0 	//ensure imputed values are nonnegative


//remove duplicates to enable merge with Ireland mirror data
sort geo partner fdi_item_l
quietly by geo partner fdi_item_l: gen dup = cond(_N==1,0,_n)
drop if dup>1
merge 1:1 geo partner fdi_item_l using "$work/mirror_IE_CRE_DIA_$temp", update gen(merge_ie) 			




//---------------------- Making tables ---------------------------// 
//Save stata files in format for further analysis


gen EUhaven=1 if (partner=="MT"|partner=="CY"|partner=="BE"|partner=="IE"|partner=="LU"|partner=="NL")

foreach name in "Direct investment abroad" "Direct investment abroad; Dividends"	"Direct investment abroad; Reinvested earnings"	"Direct investment abroad; Income on debt" {
preserve
keep if geo!="EU28" & EUhaven==1 & fdi_item_l=="`name'"
keep geo_l bop_fdi6_inc$temp imputed bop_missing partner_l fdi_item_l
save "$work/`name'_EU_TH_$temp", replace
restore 
}


foreach name in "Direct investment abroad" "Direct investment abroad; Dividends"	"Direct investment abroad; Reinvested earnings"	"Direct investment abroad; Income on debt" {
preserve
keep if geo!="EU28" & partner=="EU28" & fdi_item_l=="`name'"
keep geo_l bop_fdi6_inc$temp imputed bop_missing partner_l fdi_item_l
save "$work/`name'_EU28_$temp", replace
restore
}

foreach name in "Direct investment abroad" "Direct investment abroad; Dividends"	"Direct investment abroad; Reinvested earnings"	"Direct investment abroad; Income on debt" {
preserve
use "$work/`name'_EU_TH_$temp", clear
append using "$work/`name'_EU28_$temp"
save "$work/`name'$temp", replace
*erase "$work/`name'_EU28_$temp.dta"
*erase "$work/`name'_EU_TH_$temp.dta" 
restore
}

preserve
use "$work/Direct investment abroad$temp", clear
save "$work/intra_eu_fdiincdetailed_credit_outward_$temp", replace
*erase "$work/Direct investment abroad$temp.dta"
restore

foreach name in "Direct investment abroad; Dividends"	"Direct investment abroad; Reinvested earnings"	"Direct investment abroad; Income on debt" {
preserve
use "$work/intra_eu_fdiincdetailed_credit_outward_$temp", clear
append using "$work/`name'$temp"
save "$work/intra_eu_fdiincdetailed_credit_outward_$temp", replace
*erase "$work/`name'$temp.dta"
restore
}




foreach name in "Direct investment abroad; Income on debt" {
preserve
*keep if (geo=="MT"|geo=="CY"|geo=="BE"|geo=="IE"|geo=="LU"|geo=="NL") & partner!="EU28" & fdi_item_l=="`name'"
keep if (geo=="MT"|geo=="CY"|geo=="BE"|geo=="IE"|geo=="LU"|geo=="NL") & fdi_item_l=="`name'"
keep geo_l bop_fdi6_inc$temp imputed bop_missing partner_l fdi_item_l
save "$work/`name'$temp", replace
use "$work/intra_eu_fdiincdetailed_credit_outward_$temp", clear
append using "$work/`name'$temp"
save "$work/intra_eu_fdiincdetailed_credit_outward_$temp", replace
erase "$work/`name'$temp.dta"
restore
}



foreach name in "Direct investment abroad; Income on debt" {
preserve
*keep if geo=="EU28" & partner!="EU28" & fdi_item_l=="`name'"
keep if fdi_item_l=="`name'"
keep geo_l bop_fdi6_inc$temp imputed bop_missing partner_l fdi_item_l
save "$work/`name'$temp", replace
use "$work/intra_eu_fdiincdetailed_credit_outward_$temp", clear
append using "$work/`name'$temp"
save "$work/intra_eu_fdiincdetailed_credit_outward_$temp", replace
erase "$work/`name'$temp.dta"
restore
}


foreach name in "Direct investment abroad; Income on debt" {
preserve
*keep if (geo=="MT"|geo=="CY"|geo=="BE"|geo=="IE"|geo=="LU"|geo=="NL") & partner!="EU28" & fdi_item_l=="`name'"
keep if fdi_item_l=="`name'"
keep geo_l bop_fdi6_inc$temp imputed bop_missing partner_l fdi_item_l
save "$work/`name'$temp", replace
restore
}

foreach name in "Direct investment abroad; Income on debt" {
preserve
*keep if geo!="EU28" & partner!="EU28" & fdi_item_l=="`name'"
keep if  fdi_item_l=="`name'"
keep geo_l bop_fdi6_inc$temp imputed bop_missing partner_l fdi_item_l
save "$work/intra_eu_breakdown_credit_outward_$temp", replace
*append using "$work/`name'$temp"
save "$work/intra_eu_breakdown_credit_outward_$temp", replace
*erase "$work/`name'$temp.dta"
restore
}

//import data for Ireland 

use "$work/mirror_IE_CRE_DIA_$temp", clear
keep if fdi_item_label == "Direct investment abroad; Income on debt"
keep partner_label geo_label imputed bop_fdi6_inc$temp
tempfile ireland
save `ireland', replace

use "$work/intra_eu_breakdown_credit_outward_$temp", clear
keep partner_label geo_label imputed bop_fdi6_inc$temp
drop if geo_label=="Ireland" 
append using `ireland'

save "$work/intra_eu_breakdown_credit_outward_$temp", replace





//------------------(ii)----------------------//
//INWARD i.e. subsidiary income


use "$work/basic", clear

drop if (geo=="CH"|geo=="EA18"|geo=="EA19"|geo=="ME"|geo=="MK"|geo=="TR"|geo=="NO"|geo=="IS"|geo=="RS")
keep if stk_flow=="CRE" & direction=="DI"

keep if (partner=="EU28"|partner=="AT"|	partner=="BE"|	partner=="BG"|	partner=="CY"|	partner=="CZ"|	partner=="DE"|	partner=="DK"|	partner=="EE"|	partner=="EL"|	partner=="ES"|	partner=="FI"|	partner=="FR"|	partner=="HR"|	partner=="HU"|	partner=="IE"|	partner=="IT"|	partner=="LT"|	partner=="LU"|	partner=="LV"|	partner=="MT"|	partner=="NL"|	partner=="PL"|	partner=="PT"|	partner=="RO"|	partner=="SE"|	partner=="SI"|	partner=="SK"|	partner=="UK")
replace bop_fdi6_inc$temp =0 if partner==geo & partner!="EU28"

gen nongroup_partner=partner!="EU28"
gen income=nongroup_partner*bop_fdi6_inc$temp


gen bop_notEU=bop_fdi6_inc$temp if geo!="EU28"



//We begin by counting the missing "partner" observations- If all countries report which partners they earn income from (temp==28 if all report). We also calculate the amount of income that is unaccounted for pr. partner by using the EU aggregate

egen temp=count(bop_notEU), by(fdi_item partner)

gen EU_sum_percat_partner_aux= bop_fdi6_inc$temp if geo=="EU28"

egen EU_sum_percat_partner=total(EU_sum_percat_partner_aux), by(partner fdi_item) missing


gen income_no_EU28=bop_fdi6_inc$temp if geo!="EU28"
egen EU_sum_percat_partner_est=total(income_no_EU28), by(fdi_item partner)
gen res_EU28_percat_partner=EU_sum_percat_partner-EU_sum_percat_partner_est

//First strictly logical (true) imputation based on EU28 sum and country aggregate (i.e. if all countries but one is reporting their partners we can use the EU aggregate and perfectly impute the last country)
replace bop_fdi6_inc$temp=res_EU28_percat_partner if bop_fdi6_inc$temp==. & geo!="EU28" & temp==27

 
egen count_cat= count(bop_fdi6_inc$temp), by(geo partner)

//Second strictly logical (true) imputation based on all categories having to sum up to total (same logic: their are 4 income categories - they have to sum up to the total)
gen income_no_aggregate=bop_fdi6_inc$temp if fdi_item_label!="Direct investment in the reporting economy"
gen sum_aux=bop_fdi6_inc$temp if fdi_item_label=="Direct investment in the reporting economy"
egen sum_listet_pr_partner = total(sum_aux), by(geo partner) missing
egen sum_agg_partner_est=total(income_no_aggregate), by(geo partner) 
gen res_partner=sum_listet_pr_partner-sum_agg_partner_est
drop sum_aux


replace bop_fdi6_inc$temp= res_partner if fdi_item_label!="Direct investment in the reporting economy" & bop_fdi6_inc$temp==. & count_cat==3

replace bop_fdi6_inc$temp= sum_agg_partner_est if fdi_item_label=="Direct investment in the reporting economy" & bop_fdi6_inc$temp==. & count_cat==3


//Third: what is missing from each reporter (geo) to the entire EU28 - This will give us a maximum amount of income to be imputed pr. reporter
gen internal_sum_agg_aux=bop_fdi6_inc$temp if partner=="EU28"
egen total_EXT_EU=total(internal_sum_agg_aux), by(geo fdi_item) missing

gen bop_partner_notEXT_EU=bop_fdi6_inc$temp if partner!="EU28"

egen temp2=count(bop_partner_notEXT_EU), by(fdi_item geo)

//We estimate how much fdi income is accounted for by aggregating all the reports of each individual country (within categories)
egen total_EU_est=total(income), by(geo fdi_item)

//We then calculate the difference between the sum of income from the EU and the sum of individual reports - this residual is the income that needs to be imputed pr. reporter-category (geo-fdi item) 
gen res_total_EU_geo=total_EXT_EU-total_EU_est

gen bop_missing=bop_fdi6_inc$temp==.


//Imputations

//Simple imputation procedure allocating the unaccounted income of each partner based on the FDI assets of each reporter
merge m:1 geo_label using "$rawdata/fdikeys" 
gen aux=direfdi_key_ass if bop_missing 
egen aux2=sum(aux), by(fdi_item partner)
gen imputed=(aux/aux2)*res_EU28_percat_partner
replace imputed=bop_fdi6_inc$temp if bop_missing==0 & geo!="EU28"
egen check_aux=sum(imputed), by(fdi_item partner)
gen diff=check_aux-bop_fdi6_inc$temp if geo=="EU28"

replace imputed=. if geo=="IE"
replace bop_fdi6_inc$temp=. if geo=="IE"
*replace imputed = -imputed if imputed <0 	//ensure imputed values are nonnegative
*replace imputed = 0 if imputed <0 	//ensure imputed values are nonnegative

sort geo partner fdi_item_l
quietly by geo partner fdi_item_l: gen dup = cond(_N==1,0,_n)
drop if dup>1
merge 1:1 geo partner fdi_item_l using "$work/mirror_IE_CRE_DIRE_$temp", update gen(merge_ie) 



//---------------------- Making tables ---------------------------//

gen EUhaven=1 if (partner=="MT"|partner=="CY"|partner=="BE"|partner=="IE"|partner=="LU"|partner=="NL") 

//Making intra_eu_fdiincdetailed_credit_inward_$temp

foreach name in "Direct investment in the reporting economy"	"Direct investment in the reporting economy; Income on debt" "Direct investment in the reporting economy; Dividends"{
preserve
	keep if geo!="EU28" & EUhaven==1 & fdi_item_l=="`name'"
	keep geo_l bop_fdi6_inc$temp imputed bop_missing partner
	save "$work/`name'_EU_TH_$temp", replace
restore
}

foreach name in "Direct investment in the reporting economy"	"Direct investment in the reporting economy; Income on debt" "Direct investment in the reporting economy; Dividends"{
preserve
	keep if geo!="EU28" & partner=="EU28" & fdi_item_l=="`name'"
	keep geo_l bop_fdi6_inc$temp imputed bop_missing partner
	save "$work/`name'_EU_28_$temp", replace
restore
}

foreach name in "Direct investment in the reporting economy"	"Direct investment in the reporting economy; Income on debt" "Direct investment in the reporting economy; Dividends"{
preserve
	keep if (geo=="MT"|geo=="CY"|geo=="BE"|geo=="IE"|geo=="LU"|geo=="NL") & partner!="EU28" & fdi_item_l=="`name'"
	keep geo_l bop_fdi6_inc$temp imputed bop_missing partner
	save "$work/`name'_havens_$temp", replace
restore
}

foreach name in "Direct investment in the reporting economy"	"Direct investment in the reporting economy; Income on debt" "Direct investment in the reporting economy; Dividends"{
	preserve
	use "$work/`name'_EU_TH_$temp", clear
	append using "$work/`name'_EU_28_$temp"
	append using "$work/`name'_havens_$temp"
	save "$work/intra_eu_fdiincdetailed_credit_inward_$temp", replace
restore
}
/*
foreach name in "Direct investment in the reporting economy; Income on debt"{
	preserve
	use "$work/intra_eu_fdiincdetailed_credit_inward_$temp", clear
	append using "$work/`name'_EU_TH_$temp"
	append using "$work/`name'_EU_28_$temp"
	append using "$work/`name'_havens_$temp"
	save "$work/intra_eu_fdiincdetailed_credit_inward_$temp", replace
restore
}

foreach name in "Direct investment in the reporting economy; Dividends"{
	preserve
	use "$work/intra_eu_fdiincdetailed_credit_inward_$temp", clear
	append using "$work/`name'_EU_TH_$temp"
	append using "$work/`name'_EU_28_$temp"
	append using "$work/`name'_havens_$temp"
	save "$work/intra_eu_fdiincdetailed_credit_inward_$temp", replace
	erase "$work/`name'_EU_TH_$temp.dta"
	erase "$work/`name'_EU_28_$temp.dta"
	erase "$work/`name'_havens_$temp.dta"
restore
}
*/
foreach name in "Direct investment in the reporting economy; Income on debt" {
preserve	
	*keep if geo=="EU28" & partner!="EU28" & fdi_item_l=="`name'"
keep if geo=="EU28" & fdi_item_l=="`name'"
	keep geo_l bop_fdi6_inc$temp imputed bop_missing partner
	save "$work/`name'$temp", replace
	use "$work/intra_eu_fdiincdetailed_credit_inward_$temp", clear
	append using "$work/`name'$temp"
	duplicates drop partner geo_label bop_fdi6_inc$temp, force
	sort geo_label
	save "$work/intra_eu_fdiincdetailed_credit_inward_$temp", replace
*	erase "$work/`name'$temp.dta"
	restore
}

//making intra_eu_breakdown_credit_inward_$temp

foreach name in  "Direct investment in the reporting economy"	"Direct investment in the reporting economy; Income on debt" "Direct investment in the reporting economy; Dividends" {
preserve	
*	keep if (geo=="MT"|geo=="CY"|geo=="BE"|geo=="IE"|geo=="LU"|geo=="NL") & partner!="EU28" & fdi_item_l=="`name'"
keep if fdi_item_l=="`name'"
	keep geo_l bop_fdi6_inc$temp imputed bop_missing partner
	save "$work/`name'$temp", replace
restore	
}



foreach name in  "Direct investment in the reporting economy; Income on debt"{
preserve	
	keep if geo=="EU28" & partner!="EU28" & fdi_item_l=="`name'"
	keep if fdi_item_l=="`name'"
	keep geo_l bop_fdi6_inc$temp imputed bop_missing partner
	append using "$work/`name'$temp"
	save "$work/intra_eu_breakdown_credit_inward_$temp", replace
	erase "$work/`name'$temp.dta"
restore	
}






//import data for Ireland 

use "$work/mirror_IE_CRE_DIRE_$temp", clear	//ONLY EU partners

keep if fdi_item_label == "Direct investment in the reporting economy; Income on debt"
keep partner geo_label imputed bop_fdi6_inc$temp
tempfile ireland
save `ireland', replace

use "$work/intra_eu_breakdown_credit_inward_$temp", clear
keep partner geo_label imputed bop_fdi6_inc$temp
drop if geo_label=="Ireland" 
append using `ireland'
duplicates drop partner geo_label bop_fdi6_inc$temp, force
save "$work/intra_eu_breakdown_credit_inward_$temp", replace





