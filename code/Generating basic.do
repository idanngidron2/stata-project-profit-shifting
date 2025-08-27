//-----------------------------------------------
//Step 5b: Eurostat FDI income basic cleaning
//-----------------------------------------------


*ssc install eurostatuse, replace
/*
if $temp <= 2018 {

use "$work/bop_fdi6_inc", clear

}

else if $temp >2018 {
	
use "$work/bop_fdi6_inc_new", clear
	
}
*/

use "$work/bop_fdi6_inc", clear


drop if nace_r2!="FDI"
drop if entity=="SPE"


gen keep=0
foreach name in "Direct investment in the reporting economy"	"Direct investment in the reporting economy; income on debt"	"Direct investment abroad; dividends"	"Direct investment abroad; reinvested earnings"	"Direct investment abroad"	"Direct investment abroad; Income on debt"	"Direct investment in the reporting economy; dividends"	"Direct investment in the reporting economy; reinvested earnings"	"Direct investment in the reporting economy"	"Direct investment in the reporting economy; income on debt" {
replace keep=1 if fdi_item_l=="`name'"
}

drop if keep==0
drop keep

//Adjust variable names of new bop data
replace fdi_item_l = "Direct investment in the reporting economy; Income on debt" if fdi_item_l == "Direct investment in the reporting economy; income on debt"
replace fdi_item_l = "Direct investment in the reporting economy; Dividends" if fdi_item_l == "Direct investment in the reporting economy; dividends"
replace fdi_item_l = "Direct investment in the reporting economy; Reinvested earnings" if fdi_item_l == "Direct investment in the reporting economy; reinvested earnings"
*replace fdi_item_l = "Direct investment abroad; Income on debt" if fdi_item_l == "Direct investment abroad; income on debt"
replace fdi_item_l = "Direct investment abroad; Dividends" if fdi_item_l == "Direct investment abroad; dividends"
replace fdi_item_l = "Direct investment abroad; Reinvested earnings" if fdi_item_l == "Direct investment abroad; reinvested earnings"

//First strictly logical replacement 3rd variable when net and credit exists and so on...
sort geo partner fdi_item_l
by geo partner fdi_item_l: gen count_aux=1 if bop_fdi6_inc$temp!=.
by geo partner fdi_item_l: gen count_aux2=1
egen sum_aux= sum(count_aux), by(geo partner fdi_item_l)
egen sum_aux2= sum(count_aux2), by(geo partner fdi_item_l)

gen credit_aux=bop_fdi6_inc$temp if stk_flow=="CRE"
gen debit_aux=bop_fdi6_inc$temp if stk_flow=="DEB"
gen netIO_aux= bop_fdi6_inc$temp if stk_flow=="IO"
gen netII_aux= bop_fdi6_inc$temp if stk_flow=="II"

gen direction=substr(fdi_item,1,2)


egen sum_credit_aux= sum(credit_aux), by(geo partner fdi_item_l)
egen sum_debit_aux= sum(debit_aux), by(geo partner fdi_item_l)
egen sum_netIO_aux= sum(netIO_aux), by(geo partner fdi_item_l)
egen sum_netII_aux= sum(netII_aux), by(geo partner fdi_item_l)


//net=credit - debit when abroad <=> credit = debit+net
gen test=sum_debit_aux + sum_netIO_aux
replace bop_fdi6_inc$temp=test if bop_fdi6_inc$temp==. & sum_aux==2 & sum_aux2==3 & stk_flow =="CRE" & direction=="DO"
drop test

//net=debit- credit when DIR<=> credit= debit-net
gen test =sum_debit_aux - sum_netII_aux
replace bop_fdi6_inc$temp =test if bop_fdi6_inc$temp==. & sum_aux==2 & sum_aux2==3 & stk_flow =="CRE" & direction=="DI"
drop test


//reinvested earnings can only be in the country where the investment is ==> DIA only Credit and IO exists and for DIR only Debit and IO exists

gen test= sum_netIO_aux
replace bop_fdi6_inc$temp=test if bop_fdi6_inc$temp==. & sum_aux==1 & sum_aux2==2 & stk_flow=="CRE" & fdi_item_label=="Direct investment abroad; Reinvested earnings"
drop test

gen test= sum_netII_aux
replace bop_fdi6_inc$temp=test if bop_fdi6_inc$temp==. & sum_aux==1 & sum_aux2==2 & stk_flow=="DEB" & fdi_item_label=="Direct investment in the reporting economy; Reinvested earnings"
drop test

//net=credit - debit when abroad <=> debit = credit - net
gen test=sum_credit_aux - sum_netIO_aux
replace bop_fdi6_inc$temp=test if bop_fdi6_inc$temp==. & sum_aux==2 & sum_aux2==3 & stk_flow =="DEB" & direction=="DO"
drop test

//net=debit - credit when in reporting  <=> debit = credit + net
gen test=sum_credit_aux + sum_netII_aux
replace bop_fdi6_inc$temp=test if bop_fdi6_inc$temp==. & sum_aux==2 & sum_aux2==3 & stk_flow =="DEB" & direction=="DI"
drop test

drop count_aux count_aux2 sum_aux sum_aux2 credit_aux debit_aux netIO_aux netII_aux sum_credit_aux sum_debit_aux sum_netIO_aux sum_netII_aux


//making blank observations for Ireland as they only report "net flows" and renaming IO CRE etc.

replace stk_flow="CRE" if stk_flow=="IO" & geo=="IE"
replace stk_flow="DEB" if stk_flow=="II" & geo=="IE"
expand 2 if geo=="IE"

sort stk_flow geo partner bop_fdi6_inc$temp fdi_item
by stk_flow geo partner bop_fdi6_inc$temp fdi_item: gen iedup= _n

replace bop_fdi6_inc$temp=0 if iedup==2 
replace stk_flow="DEB" if stk_flow=="CRE" & geo=="IE" & direction=="DO" & iedup==2
replace stk_flow="CRE" if stk_flow=="DEB" & geo=="IE" & direction=="DI"  & iedup==2

//Strictly logical imputations following bookkeeping identities:


// adjust the geo and partner varaibles for EU_total for years 2019 onwards due to Brexit

if $temp >= 2019 {
	
	drop if geo == "EU28"
	replace geo = "EU28" if geo == "EU27_2020"
	drop if partner == "EU28"
	replace partner = "EU28" if partner == "EU27_2020"
	drop if geo == "EXT_EU28"
	replace geo = "EXT_EU28" if geo == "EXT_EU27_2020"
	drop if partner == "EXT_EU28"
	replace partner = "EXT_EU28" if partner == "EXT_EU27_2020"
}

keep if (geo == "EU28"| geo=="AT"|	geo=="BE"|	geo=="BG"|	geo=="CY"|	geo=="CZ"|	geo=="DE"|	geo=="DK"|	geo=="EE"|	geo=="EL"|	geo=="ES"|	geo=="FI"|	geo=="FR"|	geo=="HR"|	geo=="HU"|	geo=="IE"|	geo=="IT"|	geo=="LT"|	geo=="LU"|	geo=="LV"|	geo=="MT"|	geo=="NL"|	geo=="PL"|	geo=="PT"|	geo=="RO"|	geo=="SE"|	geo=="SI"|	geo=="SK"|	geo=="UK" | geo == "US" | geo == "JP")

save "$work/basic", replace

