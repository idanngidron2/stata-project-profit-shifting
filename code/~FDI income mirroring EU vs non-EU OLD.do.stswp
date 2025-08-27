
//----------------------------------------------------
//Step 5f: Eurostat FDI disc mirroring EU vs non-EU
//----------------------------------------------------


use "$work/basic_$temp", clear



drop if (geo=="CH"|geo=="EA18"|geo=="EA19"|geo=="ME"|geo=="MK"|geo=="TR"|geo=="NO"|geo=="IS"|geo=="RS"|geo=="US"|geo=="XK"|geo=="JP"|geo=="AL")
keep if stk_flow=="II" & direction=="DI"

//we condition on the year 2019 to account for the exit of the UK in Eurostat data

// first we fill in missing values for EU28 as the sum of all european countries

if $temp >= 2019 {
	local european_countries "AT BE BG CY CZ DE DK EE EL ES FI FR HR HU IE IT LT LU LV MT NL PL PT RO SE SI SK UK"	
	foreach c in `european_countries' {	
			foreach name in "Direct investment in the reporting economy"	"Direct investment in the reporting economy; Income on debt" "Direct investment in the reporting economy; Dividends" "Direct investment in the reporting economy; Reinvested earnings" {

		sum bop_fdi6_inc$temp if (partner == "`c'" & fdi_item_label == "`name'")
		local totalEU = r(sum)
		display `totalEU'
		replace bop_fdi6_inc$temp = `totalEU' if (geo == "EU28" & partner == "`c'" & fdi_item_label == "`name'")
	}	
	}

}

//second we allow for different partner code name post-2019

if $temp < 2019 {
	
keep if (partner=="EU28"|partner=="EXT_EU28"|partner=="US"|partner=="JP")

gen nongroup_partner=partner!="EXT_EU28"
gen income=nongroup_partner*bop_fdi6_inc$temp

}

if $temp >= 2019 {
	
keep if (partner=="EU27_2020"|partner=="EXT_EU27_2020"|partner=="US"|partner=="JP")

gen nongroup_partner=partner!="EXT_EU27_2020"
gen income=nongroup_partner*bop_fdi6_inc$temp

}




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


gen bop_missing=bop_fdi6_inc$temp==.

//Imputations
//Simple imputation procedure allocating the unaccounted income of each partner based on the FDI assets of each reporter

if $temp < 2019 {
	gen temp2=bop_fdi6_inc$temp if partner=="EXT_EU28" & stk_flow=="II" & direction=="DI" & fdi_item_l=="Direct investment in the reporting economy"

}
if $temp >= 2019 {
	gen temp2=bop_fdi6_inc$temp if partner=="EXT_EU27_2020" & stk_flow=="II" & direction=="DI" & fdi_item_l=="Direct investment in the reporting economy"

}
egen aux=total(temp2), by(geo)
replace aux=. if bop_missing!=1
egen aux2=sum(aux), by(fdi_item partner)
gen imputed=(aux/aux2)*res_EU28_percat_partner
replace imputed=bop_fdi6_inc$temp if bop_missing==0 & geo!="EU28"
egen check_aux=sum(imputed), by(fdi_item partner)
gen diff=check_aux-bop_fdi6_inc$temp if geo=="EU28"

//---------------------- Making tables ---------------------------//

// Making table IIDI_EXTEU


keep if fdi_item_l=="Direct investment in the reporting economy"
keep geo_label geo partner imputed fdi_item_label bop_fdi6_inc$temp
save "$work/IIDI_EXTEU_$temp", replace



keep if fdi_item_l=="Direct investment in the reporting economy"
if $temp < 2019 {

drop if partner=="EU28"
}

if $temp >= 2019 {
	
	drop if partner=="EU27_2020"| partner=="EU28"
}


save "$work/IIDI_EXTEU_$temp", replace


use "$work/basic_$temp", clear
local temp=$temp

keep if stk_flow=="IO" & direction=="DO"

keep if (geo=="US"|geo=="JP")

if $temp < 2019 {

keep if (partner=="EU28"|partner=="AT"|	partner=="BE"|	partner=="BG"|	partner=="CY"|	partner=="CZ"|	partner=="DE"|	partner=="DK"|	partner=="EE"|	partner=="EL"|	partner=="ES"|	partner=="FI"|	partner=="FR"|	partner=="HR"|	partner=="HU"|	partner=="IE"|	partner=="IT"|	partner=="LT"|	partner=="LU"|	partner=="LV"|	partner=="MT"|	partner=="NL"|	partner=="PL"|	partner=="PT"|	partner=="RO"|	partner=="SE"|	partner=="SI"|	partner=="SK"|	partner=="UK")
}

if $temp >= 2019 {
	
keep if (partner=="EU27_2020"|partner=="AT"|	partner=="BE"|	partner=="BG"|	partner=="CY"|	partner=="CZ"|	partner=="DE"|	partner=="DK"|	partner=="EE"|	partner=="EL"|	partner=="ES"|	partner=="FI"|	partner=="FR"|	partner=="HR"|	partner=="HU"|	partner=="IE"|	partner=="IT"|	partner=="LT"|	partner=="LU"|	partner=="LV"|	partner=="MT"|	partner=="NL"|	partner=="PL"|	partner=="PT"|	partner=="RO"|	partner=="SE"|	partner=="SI"|	partner=="SK"|	partner=="UK")
}



keep if fdi_item_l=="Direct investment abroad"

rename bop_fdi6_inc$temp mirror
rename geo partn
rename partner geo
rename partn partner

merge 1:1 geo partner using "$work/IIDI_EXTEU_$temp"

gen discrepancy_DI_less_DO=.
replace discrepancy_DI_less_DO = mirror - imputed

//making table Disc_EXTEU_DI_less_DO

preserve
	keep if fdi_item_l=="Direct investment abroad"
	keep partner_l geo_l disc fdi_item_l
	save "$work/Disc_EXTEU_DI_less_DO_$temp", replace
restore


//---------------------- Reverse ---------------------------//


use "$work/basic_$temp", clear
local temp=$temp

drop if (geo=="CH"|geo=="EA18"|geo=="EA19"|geo=="ME"|geo=="MK"|geo=="TR"|geo=="NO"|geo=="IS"|geo=="RS"|geo=="US"|geo=="XK"|geo=="JP"|geo=="AL")
keep if stk_flow=="IO" & direction=="DO"

//we condition on the year 2019 to account for the exit of the UK in Eurostat data

// first we fill in missing values for EU28 as the sum of all european countries

if $temp >= 2019 {
	local european_countries "AT BE BG CY CZ DE DK EE EL ES FI FR HR HU IE IT LT LU LV MT NL PL PT RO SE SI SK UK"	
	foreach c in `european_countries' {	
			foreach name in "Direct investment in the reporting economy"	"Direct investment in the reporting economy; Income on debt" "Direct investment in the reporting economy; Dividends" "Direct investment in the reporting economy; Reinvested earnings" {

		sum bop_fdi6_inc$temp if (partner == "`c'" & fdi_item_label == "`name'")
		local totalEU = r(sum)
		display `totalEU'
		replace bop_fdi6_inc$temp = `totalEU' if (geo == "EU28" & partner == "`c'" & fdi_item_label == "`name'")
	}	
	}

}

//second we allow for different partner code name post-2019


if $temp < 2019 {
	
keep if (partner=="EU28"|partner=="EXT_EU28"|partner=="US"|partner=="JP")

gen nongroup_partner=partner!="EXT_EU28"
gen income=nongroup_partner*bop_fdi6_inc$temp

}

if $temp >= 2019 {
	
keep if (partner=="EU27_2020"|partner=="EXT_EU27_2020"|partner=="US"|partner=="JP")

gen nongroup_partner=partner!="EXT_EU27_2020"
gen income=nongroup_partner*bop_fdi6_inc$temp

}


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
gen income_no_aggregate=bop_fdi6_inc$temp if fdi_item_label!="Direct investment abroad"
gen sum_aux=bop_fdi6_inc$temp if fdi_item_label=="Direct investment abroad"
egen sum_listet_pr_partner = total(sum_aux), by(geo partner) missing
egen sum_agg_partner_est=total(income_no_aggregate), by(geo partner) 
gen res_partner=sum_listet_pr_partner-sum_agg_partner_est
drop sum_aux


replace bop_fdi6_inc$temp= res_partner if fdi_item_label!="Direct investment abroad" & bop_fdi6_inc$temp==. & count_cat==3

replace bop_fdi6_inc$temp= sum_agg_partner_est if fdi_item_label=="Direct investment abroad" & bop_fdi6_inc$temp==. & count_cat==3


gen bop_missing=bop_fdi6_inc$temp==.

//Imputations
//Simple imputation procedure allocating the unaccounted income of each partner based on the FDI assets of each reporter

if $temp < 2019 {

gen temp2=bop_fdi6_inc$temp if partner=="EXT_EU28" & stk_flow=="II" & direction=="DI" & fdi_item_l=="Direct investment abroad"
	}
	
if $temp >= 2019 {

gen temp2=bop_fdi6_inc$temp if partner=="EXT_EU27_2020" & stk_flow=="II" & direction=="DI" & fdi_item_l=="Direct investment abroad"
	}	

egen aux=total(temp2), by(geo)
replace aux=. if bop_missing!=1
egen aux2=sum(aux), by(fdi_item partner)
gen imputed=(aux/aux2)*res_EU28_percat_partner
replace imputed=bop_fdi6_inc$temp if bop_missing==0 & geo!="EU28"
egen check_aux=sum(imputed), by(fdi_item partner)
gen diff=check_aux-bop_fdi6_inc$temp if geo=="EU28"


keep if fdi_item_l=="Direct investment abroad"

drop if partner=="EU28"

save "$work/IIDI_EXTEU_$temp", replace

//---------------------- Making tables ---------------------------//
*/
use "$work/basic_$temp", clear


keep if stk_flow=="II" & direction=="DI"

keep if (geo=="US"|geo=="JP")

if $temp < 2019 {

keep if (partner=="EU28"|partner=="AT"|	partner=="BE"|	partner=="BG"|	partner=="CY"|	partner=="CZ"|	partner=="DE"|	partner=="DK"|	partner=="EE"|	partner=="EL"|	partner=="ES"|	partner=="FI"|	partner=="FR"|	partner=="HR"|	partner=="HU"|	partner=="IE"|	partner=="IT"|	partner=="LT"|	partner=="LU"|	partner=="LV"|	partner=="MT"|	partner=="NL"|	partner=="PL"|	partner=="PT"|	partner=="RO"|	partner=="SE"|	partner=="SI"|	partner=="SK"|	partner=="UK")

}
if $temp >= 2019 {

keep if (partner=="EU27_2020"|partner=="AT"|	partner=="BE"|	partner=="BG"|	partner=="CY"|	partner=="CZ"|	partner=="DE"|	partner=="DK"|	partner=="EE"|	partner=="EL"|	partner=="ES"|	partner=="FI"|	partner=="FR"|	partner=="HR"|	partner=="HU"|	partner=="IE"|	partner=="IT"|	partner=="LT"|	partner=="LU"|	partner=="LV"|	partner=="MT"|	partner=="NL"|	partner=="PL"|	partner=="PT"|	partner=="RO"|	partner=="SE"|	partner=="SI"|	partner=="SK"|	partner=="UK")

}


keep if fdi_item_l=="Direct investment in the reporting economy"

rename bop_fdi6_inc$temp mirror
rename geo partn
rename partner geo
rename partn partner

merge 1:1 geo partner using "$work/IIDI_EXTEU_$temp"

gen discrepancy_DO_less_DI=.
replace discrepancy_DO_less_DI = mirror - imputed

preserve
	keep if fdi_item_l=="Direct investment in the reporting economy"
	keep partner_l geo_l fdi_item_l disc
	save "$work/Disc_EXTEU_DO_less_DI_$temp", replace
restore








