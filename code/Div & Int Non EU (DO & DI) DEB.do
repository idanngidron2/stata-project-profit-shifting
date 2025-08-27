//-----------------------------------------------
//Step 5f: FDI income debit non-EU - EU 
//-----------------------------------------------

//the dofile that handles FDI income credit data where an EU country is the debitor and a non-EU country is the creditor

//------------------(i)----------------------//
//OUTWARD FDI i.e. parent income owed




use "$work/basic", clear

drop if (geo=="CH"|geo=="EA18"|geo=="EA19"|geo=="ME"|geo=="MK"|geo=="TR"|geo=="NO"|geo=="IS"|geo=="RS")
keep if stk_flow=="DEB" & direction=="DO"

keep if (partner=="EXT_EU_NAL"|partner=="EXT_EU28"|partner=="AR"|partner=="AU"|partner=="BR"|partner=="CA" /// 
|partner=="CL"|partner=="EG"|partner=="CN_X_HK"|partner=="IS"|partner=="ID"|partner=="IN"|partner=="JP" /// 
|partner=="MY"|partner=="MX"|partner=="MA"|partner=="NZ"|partner=="NG"|partner=="ORG_NEUR"|partner=="NO" /// 
|partner=="PH"|partner=="RU"|partner=="ZA"|partner=="KR"|partner=="CH"|partner=="TW"|partner=="TH" /// 
|partner=="TR"|partner=="US"|partner=="UY"|partner=="VE"|partner=="OFFSHO"|partner=="MACR"|partner=="MAGR")

gen nongroup_partner=partner!="EXT_EU28"
gen income=nongroup_partner*bop_fdi6_inc$temp


gen bop_notEU=bop_fdi6_inc$temp if geo!="EU28"



//We begin by counting the missing "partner" observations- If all countries report which partners they pay income to (temp==28 if all report). We also calculate the amount of income that is unaccounted for pr. partner by using the EU aggregate

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
gen income_no_aggregate=bop_fdi6_inc$temp if fdi_item_label!="Direct investment abroad"
gen sum_aux=bop_fdi6_inc$temp if fdi_item_label=="Direct investment abroad"
egen sum_listet_pr_partner = total(sum_aux), by(geo partner) missing
egen sum_agg_partner_est=total(income_no_aggregate), by(geo partner) 
gen res_partner=sum_listet_pr_partner-sum_agg_partner_est
drop sum_aux


replace bop_fdi6_inc$temp= res_partner if fdi_item_label!="Direct investment abroad" & bop_fdi6_inc$temp==. & count_cat==3

replace bop_fdi6_inc$temp= sum_agg_partner_est if fdi_item_label=="Direct investment abroad" & bop_fdi6_inc$temp==. & count_cat==3


//Third: what is missing from each reporter (geo) to the entire EU28 - This will give us a maximum amount of income to be imputed pr. reporter
gen internal_sum_agg_aux=bop_fdi6_inc$temp if partner=="EXT_EU28"
egen total_EXT_EU=total(internal_sum_agg_aux), by(geo fdi_item) missing

gen bop_partner_notEXT_EU=bop_fdi6_inc$temp if partner!="EXT_EU28"

egen temp2=count(bop_partner_notEXT_EU), by(fdi_item geo)

//We estimate how much fdi income is accounted for by aggregating all the reports of each individual country (within categories)
egen total_EU_est=total(income), by(geo fdi_item)

//We then calculate the difference between the sum of income from the EU and the sum of individual reports - this residual is the income that needs to be imputed pr. reporter-category (geo-fdi item) 
gen res_total_EU_geo=total_EXT_EU-total_EU_est



//Check
*bro if countvar>1 & (geo=="NL"|geo=="IE"|geo=="LU") & (partner=="CH"|partner=="OFFSHO") & income==.




gen haven=partner=="CH"|partner=="OFFSHO"

gen bop_missing=bop_fdi6_inc$temp==.

//Imputations

//Simple imputation procedure allocating the unaccounted income of each partner based on the FDI liabilities of each reporter

merge m:1 geo_label using "$rawdata/fdikeys" 
gen aux=diafdi_key if bop_missing 
egen aux2=sum(aux), by(fdi_item partner)
gen imputed=(aux/aux2)*res_EU28_percat_partner
replace imputed=bop_fdi6_inc$temp if bop_missing==0 & geo!="EU28"
egen check_aux=sum(imputed), by(fdi_item partner)
gen diff=check_aux-bop_fdi6_inc$temp if geo=="EU28"




//---------------------- Making tables ---------------------------//

//making table nonEU_fdiinc_debit_nonEUhaven_outward

foreach name in "Direct investment abroad" "Direct investment abroad; Dividends" "Direct investment abroad; Income on debt"{
preserve
	keep if geo!="EU28" & partner=="EXT_EU28" & fdi_item_l=="`name'"
	keep geo_l partner fdi_item_l bop_fdi6_inc$temp imputed bop_missing
	save "$work/`name'_A$temp", replace
restore
}

foreach name in "Direct investment abroad" "Direct investment abroad; Dividends" "Direct investment abroad; Income on debt"{
preserve
	keep if geo!="EU28" & haven==1 & fdi_item_l=="`name'"
	keep geo_l partner fdi_item_l bop_fdi6_inc$temp imputed bop_missing
	save "$work/`name'_B$temp", replace
restore
}

foreach name in "Direct investment abroad" "Direct investment abroad; Dividends" "Direct investment abroad; Income on debt"{
preserve
	keep if geo!="EU28" & partner=="CH" & fdi_item_l=="`name'"
	keep geo_l partner fdi_item_l bop_fdi6_inc$temp imputed bop_missing
	save "$work/`name'_C$temp", replace
restore
}

foreach name in "Direct investment abroad" "Direct investment abroad; Dividends" "Direct investment abroad; Income on debt"{
preserve
	keep if geo!="EU28" & partner=="OFFSHO" & fdi_item_l=="`name'"
	keep geo_l partner fdi_item_l bop_fdi6_inc$temp imputed bop_missing
	save "$work/nonEU_fdiinc_debit_nonEUhaven_outward_$temp", replace
	append using "$work/`name'_A$temp"
	append using "$work/`name'_B$temp"
	append using "$work/`name'_C$temp"
*	erase "$work/`name'_A$temp.dta"
*	erase "$work/`name'_B$temp.dta"
*	erase "$work/`name'_C$temp.dta"
restore
}


//making table nonEU_breakdown_debitint_nonEUhaven_outward

preserve
	keep if geo!="EU28" & partner!="EU28" &  (partner=="OFFSHO"|partner=="EXT_EU28"|partner=="CH") & fdi_item_l=="Direct investment abroad; Income on debt"
	keep geo_l partner fdi_item_l bop_fdi6_inc$temp imputed bop_missing
	duplicates drop geo_l partner fdi_item_l imputed, force	//drop Irish duplicates 
	drop if geo_l == "Ireland" & bop_missing==0			//drop Irish duplicates
	save "$work/nonEU_breakdown_debitint_nonEUhaven_outward_$temp", replace
restore


//------------------------(ii)------------------------//
//INWARD i.e. subsidiary reporting


use "$work/basic", clear

drop if (geo=="CH"|geo=="EA18"|geo=="EA19"|geo=="ME"|geo=="MK"|geo=="TR"|geo=="NO"|geo=="IS"|geo=="RS")
keep if stk_flow=="DEB" & direction=="DI"

keep if (partner=="EXT_EU_NAL"|partner=="EXT_EU28"|partner=="AR"|partner=="AU"|partner=="BR"|partner=="CA" /// 
|partner=="CL"|partner=="EG"|partner=="CN_X_HK"|partner=="IS"|partner=="ID"|partner=="IN"|partner=="JP" /// 
|partner=="MY"|partner=="MX"|partner=="MA"|partner=="NZ"|partner=="NG"|partner=="ORG_NEUR"|partner=="NO" /// 
|partner=="PH"|partner=="RU"|partner=="ZA"|partner=="KR"|partner=="CH"|partner=="TW"|partner=="TH" /// 
|partner=="TR"|partner=="US"|partner=="UY"|partner=="VE"|partner=="OFFSHO"|partner=="MACR"|partner=="MAGR")

gen nongroup_partner=partner!="EXT_EU28"
gen income=nongroup_partner*bop_fdi6_inc$temp


gen bop_notEU=bop_fdi6_inc$temp if geo!="EU28"



//What is missing from EU28 to partner, per category = first max

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
gen internal_sum_agg_aux=bop_fdi6_inc$temp if partner=="EXT_EU28"
egen total_EXT_EU=total(internal_sum_agg_aux), by(geo fdi_item) missing

gen bop_partner_notEXT_EU=bop_fdi6_inc$temp if partner!="EXT_EU28"

egen temp2=count(bop_partner_notEXT_EU), by(fdi_item geo)

//We estimate how much fdi income is accounted for by aggregating all the reports of each individual country (within categories)
egen total_EU_est=total(income), by(geo fdi_item)

//We then calculate the difference between the sum of income from the EU and the sum of individual reports - this residual is the income that needs to be imputed pr. reporter-category (geo-fdi item) 
gen res_total_EU_geo=total_EXT_EU-total_EU_est



//Check
*bro if countvar>1 & (geo=="NL"|geo=="IE"|geo=="LU") & (partner=="CH"|partner=="OFFSHO") & income==.

gen haven=partner=="CH"|partner=="OFFSHO"

gen bop_missing=bop_fdi6_inc$temp==.

//Imputations
//Simple imputation procedure allocating the unaccounted income of each partner based on the FDI liabilities of each reporter

merge m:1 geo_label using "$rawdata/fdikeys" 
gen aux=direfdi_key if bop_missing 
egen aux2=sum(aux), by(fdi_item partner)
gen imputed=(aux/aux2)*res_EU28_percat_partner
replace imputed=bop_fdi6_inc$temp if bop_missing==0 & geo!="EU28"
egen check_aux=sum(imputed), by(fdi_item partner)
gen diff=check_aux-bop_fdi6_inc$temp if geo=="EU28"





//---------------------- Making tables ---------------------------//

//making table nonEU_fdiincdet_debit_nonEUhav_inward

foreach name in "Direct investment in the reporting economy" "Direct investment in the reporting economy; Dividends" "Direct investment in the reporting economy; Reinvested earnings"	"Direct investment in the reporting economy; Income on debt"{
preserve
	keep if geo!="EU28" & partner=="EXT_EU28" & fdi_item_l=="`name'"
	keep geo_l partner fdi_item_l bop_fdi6_inc$temp imputed bop_missing
	save "$work/`name'_A$temp", replace
restore
}

foreach name in "Direct investment in the reporting economy" "Direct investment in the reporting economy; Dividends" "Direct investment in the reporting economy; Reinvested earnings"	"Direct investment in the reporting economy; Income on debt"{
preserve
	keep if geo!="EU28" & haven==1 & fdi_item_l=="`name'"
	keep geo_l partner fdi_item_l bop_fdi6_inc$temp imputed bop_missing
	save "$work/`name'_B$temp", replace
restore
}

foreach name in "Direct investment in the reporting economy" "Direct investment in the reporting economy; Dividends" "Direct investment in the reporting economy; Reinvested earnings"	"Direct investment in the reporting economy; Income on debt"{
preserve
	keep if geo!="EU28" & partner=="CH" & fdi_item_l=="`name'"
	keep geo_l partner fdi_item_l bop_fdi6_inc$temp imputed bop_missing
	save "$work/`name'_C$temp", replace
restore
}

foreach name in "Direct investment in the reporting economy" "Direct investment in the reporting economy; Dividends" "Direct investment in the reporting economy; Reinvested earnings"	"Direct investment in the reporting economy; Income on debt"{
preserve
	keep if geo!="EU28" & partner=="OFFSHO" & fdi_item_l=="`name'"
	keep geo_l partner fdi_item_l bop_fdi6_inc$temp imputed bop_missing
	save "$work/nonEU_fdiincdet_debit_nonEUhav_inward_$temp", replace
	append using "$work/`name'_A$temp"
	append using "$work/`name'_B$temp"
	append using "$work/`name'_C$temp"
*	erase "$work/`name'_A$temp.dta"
*	erase "$work/`name'_B$temp.dta"
*	erase "$work/`name'_C$temp.dta"
restore
}


//making table nonEU_debitint_nonEUhav_inward 

preserve
	keep if geo!="EU28" & partner!="EU28"  &(partner=="OFFSHO"|partner=="EXT_EU28"|partner=="CH") & fdi_item_l=="Direct investment in the reporting economy; Income on debt"
	keep geo_l partner fdi_item_l bop_fdi6_inc$temp imputed bop_missing
	duplicates drop geo_l partner imputed, force	//drop Irish duplicates 
	save "$work/nonEU_debitint_nonEUhav_inward_$temp", replace
restore
