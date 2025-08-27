//---------------------------------------------
//Step 4e: services discrepancies EU - EU
//---------------------------------------------

//the dofile that calculates credit/debit discrepancies in EU to EU transactions
//Credit/debit discrepancies internal EU


//We first do the same excercise we did for the exports in "Internal EU credit" than for imports (debits) and we then compare the value of the transaction according to the importer vs. exporter
//See the dofile "Internal EU credit" for more detailed comments
//In the end we only compare exports /imports where both the exporter and importer reports data - implying that the imputations in the following that are not strictly logical are redundant


//------------------(i)----------------------//
//Download data, basic data cleaning, and initial imputations

local temp=$temp

use "$work/bop_its6_det", clear 

//First credits
qui {

drop if (geo=="CH"|geo=="EA18"|geo=="EA19"|geo=="ME"|geo=="MK"|geo=="TR"|geo=="NO"|geo=="IS"|geo=="RS")
gen countvar = length(bop_item)
keep if countvar<3
drop if stk_flow_la=="Debit" 

keep if (partner=="EU28"|partner=="AT"|	partner=="BE"|	partner=="BG"|	partner=="CY"|	partner=="CZ"|	partner=="DE"|	partner=="DK"|	partner=="EE"|	partner=="EL"|	partner=="ES"|	partner=="FI"|	partner=="FR"|	partner=="HR"|	partner=="HU"|	partner=="IE"|	partner=="IT"|	partner=="LT"|	partner=="LU"|	partner=="LV"|	partner=="MT"|	partner=="NL"|	partner=="PL"|	partner=="PT"|	partner=="RO"|	partner=="SE"|	partner=="SI"|	partner=="SK"|	partner=="UK")
replace bop_its6_det`temp' =0 if partner==geo & partner!="EU28"

gen nongroup_partner=partner!="EU28"
gen imports=nongroup_partner*bop_its6_det`temp'
gen bop_notEU=bop_its6_det`temp' if geo!="EU28"



//What is missing from EU28 to partner, per category

egen temp=count(bop_notEU), by(bop_item partner)

gen EU_sum_percat_partner_aux= bop_its6_det`temp' if geo=="EU28"

egen EU_sum_percat_partner=total(EU_sum_percat_partner_aux), by(partner bop_item) missing


gen imports_no_EU28=bop_its6_det`temp' if geo!="EU28"
egen EU_sum_percat_partner_est=total(imports_no_EU28), by(bop_item partner)
gen res_EU28_percat_partner=EU_sum_percat_partner-EU_sum_percat_partner_est

//First strictly logical (true) imputation based on EU28 sum and country aggregate
replace bop_its6_det`temp'=res_EU28_percat_partner if bop_its6_det`temp'==. & geo!="EU28" & temp==27

//FIlling out the blanks using how much is imported from EU28 vs. all individual partners: Total service estimated from detailed obs per geo
egen internal_sum_det=total(imports), by(geo countvar)

//Extra-EU in every observation
gen internal_sum_agg_aux=bop_its6_det`temp' if partner=="EU28"
egen total_EU=total(internal_sum_agg_aux), by(geo bop_item) missing

gen bop_partner_notEU=bop_its6_det`temp' if partner!="EU28"

egen temp2=count(bop_partner_notEU), by(bop_item geo)

//Extra-EU services estimated
egen total_EU_est=total(imports), by(geo bop_item)

//Gen residual for extra_EU per geo
gen res_total_EU_geo=total_EU-total_EU_est



//second strictly logical replacement 

replace bop_its6_det`temp'=res_total_EU_geo if bop_its6_det`temp'==. & partner!="EU28" & temp2==27

replace bop_its6_det`temp'=total_EU_est if bop_its6_det`temp'==. & partner=="EU28" & temp2==28

 
gen SN_temp=(bop_item=="SN")
egen SN= total(SN_temp), by(geo partner)
egen count_cat= count(bop_its6_det`temp'), by(geo partner)

//Second strictly logical (true) imputation based on categorytotal
gen import_no_S=bop_its6_det`temp' if bop_item!="S"
gen service_sum_aux=bop_its6_det`temp' if countvar==1
egen service_sum = total(service_sum_aux), by(geo partner) missing
egen S_est=total(import_no_S), by(geo partner) 
gen res_S_partner=service_sum-S_est


replace bop_its6_det`temp'= res_S_partner if bop_item!="S" & bop_its6_det`temp'==. & count_cat==12+SN

replace bop_its6_det`temp'= S_est if bop_item=="S" & bop_its6_det`temp'==. & count_cat==12+SN

//reiterate 
{

drop imports-res_S_partner
gen imports=nongroup_partner*bop_its6_det`temp'


gen bop_notEU=bop_its6_det`temp' if geo!="EU28"



//What is missing from EU28 to partner, per category

egen temp=count(bop_notEU), by(bop_item partner)

gen EU_sum_percat_partner_aux= bop_its6_det`temp' if geo=="EU28"

egen EU_sum_percat_partner=total(EU_sum_percat_partner_aux), by(partner bop_item) missing


gen imports_no_EU28=bop_its6_det`temp' if geo!="EU28"
egen EU_sum_percat_partner_est=total(imports_no_EU28), by(bop_item partner)
gen res_EU28_percat_partner=EU_sum_percat_partner-EU_sum_percat_partner_est

//First strictly logical (true) imputation based on EU28 sum and country aggregate
replace bop_its6_det`temp'=res_EU28_percat_partner if bop_its6_det`temp'==. & geo!="EU28" & temp==27

//FIlling out the blanks using how much is imported from EU28 vs. all individual partners:Total service estimated from detailed obs per geo
egen internal_sum_det=total(imports), by(geo countvar)

//Extra-EU in every observation
gen internal_sum_agg_aux=bop_its6_det`temp' if partner=="EU28"
egen total_EU=total(internal_sum_agg_aux), by(geo bop_item) missing

gen bop_partner_notEU=bop_its6_det`temp' if partner!="EU28"

egen temp2=count(bop_partner_notEU), by(bop_item geo)

//Extra-EU services estimated
egen total_EU_est=total(imports), by(geo bop_item)

//Gen residual for extra_EU per geo
gen res_total_EU_geo=total_EU-total_EU_est



//second strictly logical replacement 

replace bop_its6_det`temp'=res_total_EU_geo if bop_its6_det`temp'==. & partner!="EU28" & temp2==27

replace bop_its6_det`temp'=total_EU_est if bop_its6_det`temp'==. & partner=="EU28" & temp2==28

 
gen SN_temp=(bop_item=="SN")
egen SN= total(SN_temp), by(geo partner)
egen count_cat= count(bop_its6_det`temp'), by(geo partner)

//Second strictly logical (true) imputation based on categorytotal
gen import_no_S=bop_its6_det`temp' if bop_item!="S"
gen service_sum_aux=bop_its6_det`temp' if countvar==1
egen service_sum = total(service_sum_aux), by(geo partner) missing
egen S_est=total(import_no_S), by(geo partner) 
gen res_S_partner=service_sum-S_est


replace bop_its6_det`temp'= res_S_partner if bop_item!="S" & bop_its6_det`temp'==. & count_cat==12+SN

replace bop_its6_det`temp'= S_est if bop_item=="S" & bop_its6_det`temp'==. & count_cat==12+SN


}





//Biggest max: total imports less whatever is reported in rest of EU
gen totalimports_aux= bop_its6_det`temp' if partner=="EU28" & bop_item=="S"
egen totalimports=total(totalimports_aux), by(geo) missing


egen everything_reported=total(imports), by(geo countvar)

gen rest_aux= totalimports - everything_reported

egen rest= min(rest_aux), by(geo)

replace rest=. if service_sum!=.


//Big max: total imports by category
// lavet nedenfor extra_EU 



//Total service estimated from detailed obs per geo
drop internal_sum_det internal_sum_agg
egen internal_sum_det=total(imports), by(geo countvar)

//Extra-EU in every observation
gen internal_sum_agg_aux=bop_its6_det`temp' if partner=="EU28"
gen temp1=1 if partner=="EU28" & bop_its6_det`temp'==.
egen temp3=sum(temp1), by(geo partner)
replace internal_sum_agg_aux=. if temp3>0
drop temp*
egen extra_EU=total(internal_sum_agg_aux), by(geo bop_item) missing


//Extra-EU services estimated
egen extra_EU_est=total(imports), by(geo bop_item)

//Gen residual for extra_EU per geo
gen res_EXT_EU_geo=extra_EU-extra_EU_est

gen bop_missing=bop_its6_det`temp'==.

foreach var in rest service_sum totalimports extra_EU res_S_partner res_EXT_EU_geo {
replace `var'=. if `var'<0
 }



egen minof3max=rmin(rest service_sum totalimports extra_EU res_S_partner res_EU28_percat_partner res_EXT_EU_geo)



//how much is left when min max are filled for each partner-geo
sort geo partner bop_missing minof3max
by geo partner bop_missing: gen sumofsmallest=sum(minof3max)
by geo partner bop_missing: gen rank_aux=_n
by geo partner bop_missing: gen rank_N=_N
replace sumofsmallest=0 if rank_aux==rank_N
egen secondsmallest=max(sumofsmallest), by(geo partner bop_missing)

gen min_rest_internal_geo=res_S_partner-secondsmallest if rank_N==rank_aux

//forvalues x=1/14 {
//gen otherthan_`x'=minof3max if rank_aux!=`x'
//egen sumofotherthan_`x'=total(otherthan_`x'), by(geo partner bop_missing)
//replace min_rest_internal_geo=res_S_partner - sumofotherthan_`x' if rank_aux==`x'
//}


egen minof3max_cons=rmin(rest service_sum totalimports extra_EU res_S_partner res_EU28_percat_partner res_EXT_EU_geo)
replace minof3max_cons=. if bop_its6_det`temp'!=.
gen min=0


egen maxofmin_eu3=rmax(min_rest_internal_geo min)
replace maxofmin_eu3=. if bop_its6_det`temp'!=.


//-------------------------(ii)------------------------//
//Making Tables

gen max_for_table= minof3max_cons if geo!="EU28"
gen unaccounted_for_table=res_EU28_percat_partner if geo!="EU28"
gen min_for_table= maxofmin_eu3 if geo!="EU28"
replace min_for_table=bop_its6_det`temp' if bop_its6_det`temp'!=.
replace max_for_table=bop_its6_det`temp' if bop_its6_det`temp'!=.



//imputations begin:
gen min_aux=min_for_table if bop_missing
egen accountedfor_aux =sum(min_aux), by(partner bop_item)
gen unaccounted=res_EU28_percat_partner - accountedfor_aux



gen aux=service_sum if geo=="EU28" & bop_item=="S"
egen EUimportsfrompartner=total(aux), by(partner)
drop aux

gen imputed1=min_for_table+(service_sum/EUimportsfrompartner)*unaccounted if bop_missing & geo!="EU28"
gen extra_value_aux=(service_sum/EUimportsfrompartner)*unaccounted if bop_missing & geo!="EU28"
drop accountedfor_aux
egen accountedfor_aux =sum(extra_value_aux), by(partner bop_item)
replace unaccounted=unaccounted-accountedfor_aux

gen aux=(imputed1!=.|bop_missing==0)
drop totalimports_aux
gen totalimports_aux=totalimports if geo!="EU28" & aux==0
egen rest_totalimports= total(totalimports_aux), by(partner bop_item)
gen imputed2=min_for_table+(totalimports/rest_totalimports)*unaccounted if bop_missing & imputed1==. 
//minimum is already taken into account in unaccounted for sum 


egen noimputed2=total(imputed2), by(bop_item partner) missing
egen imputed1_aux=sum(imputed1), by(partner bop_item)
gen added_aux = (imputed1/imputed1_aux)*unaccounted if noimputed2==.
replace added_aux=0 if noimputed2!=.
replace imputed1=imputed1+added_aux 
drop imputed1_aux added_aux


egen imputed=rowtotal(bop_its6_det`temp' imputed1 imputed2), missing
replace imputed=min_for_table if imputed<min_for_table
replace imputed=bop_its6_det`temp' if bop_missing==0

//distributing what is lost by maxes
gen extra_cor_aux=imputed-max_for_table if imputed>max_for_table & (imputed1!=.|imputed2!=.) & bop_missing
gen max_reached=(extra_cor_aux!=.) 
egen correction=total(extra_cor_aux), by(partner bop_item)
replace imputed=max_for_table if imputed>max_for_table
egen imputed_aux=rowtotal(imputed1 imputed2) if max_reached==0 & (imputed1!=.|imputed2!=.) & partner!="EU28", missing
egen imputed_aux2=sum(imputed_aux), by(partner bop_item)
gen added_aux = (imputed_aux/imputed_aux2)*correction if max_reached==0 & (imputed1!=.|imputed2!=.)
replace added_aux=0 if added_aux==.
replace imputed=imputed +added_aux
drop extra_cor correction imputed_aux imputed_aux2 added_aux

//reiterate what is lost by maxes has to be distributed:

qui forvalues x=1/28 {
gen extra_cor_aux=imputed-max_for_table if imputed>max_for_table & (imputed1!=.|imputed2!=.) & bop_missing
gen max_aux=(extra_cor_aux!=.)
replace max_reached=max_reached+max_aux
egen correction=total(extra_cor_aux), by(partner bop_item)
replace imputed=max_for_table if imputed>max_for_table
egen imputed_aux=rowtotal(imputed1 imputed2) if max_reached==0 & (imputed1!=.|imputed2!=.) & partner!="EU28", missing
egen imputed_aux2=sum(imputed_aux), by(partner bop_item)
gen added_aux = (imputed_aux/imputed_aux2)*correction if max_reached==0 & (imputed1!=.|imputed2!=.)
replace added_aux=0 if added_aux==.
replace imputed=imputed +added_aux
drop extra_cor correction imputed_aux imputed_aux2 max_aux added_aux

}



//Preparing tables//
gen check_aux=imputed if geo!="EU28"
egen check_sum=total(check_aux), by(partner bop_item)
gen check=check_sum - EU_sum_percat_partner

gen EUhaven=(geo=="IE"|geo=="LU"|geo=="NL"|geo=="BE"|geo=="MT"|geo=="CY")



//generating miror//

keep bop_item partner geo bop_its6_det`temp' bop_its6_det2014 bop_its6_det2013 bop_its6_det2012 bop_its6_det2011 bop_its6_det2010 max_for_table imputed min_for_table
rename partner geol
rename geo partner
rename geol geo

foreach var in bop_its6_det`temp' bop_its6_det2014 bop_its6_det2013 bop_its6_det2012 bop_its6_det2011 bop_its6_det2010 max_for_table imputed min_for_table {
rename `var' mirror_`var'
}
}
save "$work/export", replace

//Then debits 
qui {
use "$work/bop_its6_det", clear 

drop if (geo=="CH"|geo=="EA18"|geo=="EA19"|geo=="ME"|geo=="MK"|geo=="TR"|geo=="NO"|geo=="IS"|geo=="RS")
gen countvar = length(bop_item)
keep if countvar<3
keep if stk_flow_la=="Debit" 

keep if (partner=="EU28"|partner=="AT"|	partner=="BE"|	partner=="BG"|	partner=="CY"|	partner=="CZ"|	partner=="DE"|	partner=="DK"|	partner=="EE"|	partner=="EL"|	partner=="ES"|	partner=="FI"|	partner=="FR"|	partner=="HR"|	partner=="HU"|	partner=="IE"|	partner=="IT"|	partner=="LT"|	partner=="LU"|	partner=="LV"|	partner=="MT"|	partner=="NL"|	partner=="PL"|	partner=="PT"|	partner=="RO"|	partner=="SE"|	partner=="SI"|	partner=="SK"|	partner=="UK")
replace bop_its6_det`temp' =0 if partner==geo & partner!="EU28"

gen nongroup_partner=partner!="EU28"
gen imports=nongroup_partner*bop_its6_det`temp'
gen bop_notEU=bop_its6_det`temp' if geo!="EU28"



//What is missing from EU28 to partner, per category

egen temp=count(bop_notEU), by(bop_item partner)

gen EU_sum_percat_partner_aux= bop_its6_det`temp' if geo=="EU28"

egen EU_sum_percat_partner=total(EU_sum_percat_partner_aux), by(partner bop_item) missing


gen imports_no_EU28=bop_its6_det`temp' if geo!="EU28"
egen EU_sum_percat_partner_est=total(imports_no_EU28), by(bop_item partner)
gen res_EU28_percat_partner=EU_sum_percat_partner-EU_sum_percat_partner_est

//First strictly logical (true) imputation based on EU28 sum and country aggregate
replace bop_its6_det`temp'=res_EU28_percat_partner if bop_its6_det`temp'==. & geo!="EU28" & temp==27

//FIlling out the blanks using how much is imported from EU28 vs. all individual partners: Total service estimated from detailed obs per geo
egen internal_sum_det=total(imports), by(geo countvar)

//Extra-EU in every observation
gen internal_sum_agg_aux=bop_its6_det`temp' if partner=="EU28"
egen total_EU=total(internal_sum_agg_aux), by(geo bop_item) missing

gen bop_partner_notEU=bop_its6_det`temp' if partner!="EU28"

egen temp2=count(bop_partner_notEU), by(bop_item geo)

//Extra-EU services estimated
egen total_EU_est=total(imports), by(geo bop_item)

//Gen residual for extra_EU per geo
gen res_total_EU_geo=total_EU-total_EU_est



//second strictly logical replacement 

replace bop_its6_det`temp'=res_total_EU_geo if bop_its6_det`temp'==. & partner!="EU28" & temp2==27

replace bop_its6_det`temp'=total_EU_est if bop_its6_det`temp'==. & partner=="EU28" & temp2==28

 
gen SN_temp=(bop_item=="SN")
egen SN= total(SN_temp), by(geo partner)
egen count_cat= count(bop_its6_det`temp'), by(geo partner)

//Second strictly logical (true) imputation based on categorytotal
gen import_no_S=bop_its6_det`temp' if bop_item!="S"
gen service_sum_aux=bop_its6_det`temp' if countvar==1
egen service_sum = total(service_sum_aux), by(geo partner) missing
egen S_est=total(import_no_S), by(geo partner) 
gen res_S_partner=service_sum-S_est


replace bop_its6_det`temp'= res_S_partner if bop_item!="S" & bop_its6_det`temp'==. & count_cat==12+SN

replace bop_its6_det`temp'= S_est if bop_item=="S" & bop_its6_det`temp'==. & count_cat==12+SN

//reiterate 
{

drop imports-res_S_partner
gen imports=nongroup_partner*bop_its6_det`temp'


gen bop_notEU=bop_its6_det`temp' if geo!="EU28"



//What is missing from EU28 to partner, per category

egen temp=count(bop_notEU), by(bop_item partner)

gen EU_sum_percat_partner_aux= bop_its6_det`temp' if geo=="EU28"

egen EU_sum_percat_partner=total(EU_sum_percat_partner_aux), by(partner bop_item) missing


gen imports_no_EU28=bop_its6_det`temp' if geo!="EU28"
egen EU_sum_percat_partner_est=total(imports_no_EU28), by(bop_item partner)
gen res_EU28_percat_partner=EU_sum_percat_partner-EU_sum_percat_partner_est

//First strictly logical (true) imputation based on EU28 sum and country aggregate
replace bop_its6_det`temp'=res_EU28_percat_partner if bop_its6_det`temp'==. & geo!="EU28" & temp==27

//FIlling out the blanks using how much is imported from EU28 vs. all individual partners:Total service estimated from detailed obs per geo
egen internal_sum_det=total(imports), by(geo countvar)

//Extra-EU in every observation
gen internal_sum_agg_aux=bop_its6_det`temp' if partner=="EU28"
egen total_EU=total(internal_sum_agg_aux), by(geo bop_item) missing

gen bop_partner_notEU=bop_its6_det`temp' if partner!="EU28"

egen temp2=count(bop_partner_notEU), by(bop_item geo)

//Extra-EU services estimated
egen total_EU_est=total(imports), by(geo bop_item)

//Gen residual for extra_EU per geo
gen res_total_EU_geo=total_EU-total_EU_est



//second strictly logical replacement 

replace bop_its6_det`temp'=res_total_EU_geo if bop_its6_det`temp'==. & partner!="EU28" & temp2==27

replace bop_its6_det`temp'=total_EU_est if bop_its6_det`temp'==. & partner=="EU28" & temp2==28

 
gen SN_temp=(bop_item=="SN")
egen SN= total(SN_temp), by(geo partner)
egen count_cat= count(bop_its6_det`temp'), by(geo partner)

//Second strictly logical (true) imputation based on categorytotal
gen import_no_S=bop_its6_det`temp' if bop_item!="S"
gen service_sum_aux=bop_its6_det`temp' if countvar==1
egen service_sum = total(service_sum_aux), by(geo partner) missing
egen S_est=total(import_no_S), by(geo partner) 
gen res_S_partner=service_sum-S_est


replace bop_its6_det`temp'= res_S_partner if bop_item!="S" & bop_its6_det`temp'==. & count_cat==12+SN

replace bop_its6_det`temp'= S_est if bop_item=="S" & bop_its6_det`temp'==. & count_cat==12+SN


}





//Biggest max: total imports less whatever is reported in rest of EU
gen totalimports_aux= bop_its6_det`temp' if partner=="EU28" & bop_item=="S"
egen totalimports=total(totalimports_aux), by(geo) missing


egen everything_reported=total(imports), by(geo countvar)

gen rest_aux= totalimports - everything_reported

egen rest= min(rest_aux), by(geo)

replace rest=. if service_sum!=.


//Big max: total imports by category
// lavet nedenfor extra_EU 



//Total service estimated from detailed obs per geo
drop internal_sum_det internal_sum_agg
egen internal_sum_det=total(imports), by(geo countvar)

//Extra-EU in every observation
gen internal_sum_agg_aux=bop_its6_det`temp' if partner=="EU28"
gen temp1=1 if partner=="EU28" & bop_its6_det`temp'==.
egen temp3=sum(temp1), by(geo partner)
replace internal_sum_agg_aux=. if temp3>0
drop temp*
egen extra_EU=total(internal_sum_agg_aux), by(geo bop_item) missing


//Extra-EU services estimated
egen extra_EU_est=total(imports), by(geo bop_item)

//Gen residual for extra_EU per geo
gen res_EXT_EU_geo=extra_EU-extra_EU_est

gen bop_missing=bop_its6_det`temp'==.

foreach var in rest service_sum totalimports extra_EU res_S_partner res_EXT_EU_geo {
replace `var'=. if `var'<0
 }



egen minof3max=rmin(rest service_sum totalimports extra_EU res_S_partner res_EU28_percat_partner res_EXT_EU_geo)



//how much is left when min max are filled for each partner-geo
sort geo partner bop_missing minof3max
by geo partner bop_missing: gen sumofsmallest=sum(minof3max)
by geo partner bop_missing: gen rank_aux=_n
by geo partner bop_missing: gen rank_N=_N
replace sumofsmallest=0 if rank_aux==rank_N
egen secondsmallest=max(sumofsmallest), by(geo partner bop_missing)

gen min_rest_internal_geo=res_S_partner-secondsmallest if rank_N==rank_aux

*forvalues x=1/14 {
*gen otherthan_`x'=minof3max if rank_aux!=`x'
*egen sumofotherthan_`x'=total(otherthan_`x'), by(geo partner bop_missing)
*replace min_rest_internal_geo=res_S_partner - sumofotherthan_`x' if rank_aux==`x'
*}


egen minof3max_cons=rmin(rest service_sum totalimports extra_EU res_S_partner res_EU28_percat_partner res_EXT_EU_geo)
replace minof3max_cons=. if bop_its6_det`temp'!=.
gen min=0


egen maxofmin_eu3=rmax(min_rest_internal_geo min)
replace maxofmin_eu3=. if bop_its6_det`temp'!=.

//-------------------------(Making tables)------------------------//

gen max_for_table= minof3max_cons if geo!="EU28"
gen unaccounted_for_table=res_EU28_percat_partner if geo!="EU28"
gen min_for_table= maxofmin_eu3 if geo!="EU28"
replace min_for_table=bop_its6_det`temp' if bop_its6_det`temp'!=.
replace max_for_table=bop_its6_det`temp' if bop_its6_det`temp'!=.



//imputations begin:
gen min_aux=min_for_table if bop_missing
egen accountedfor_aux =sum(min_aux), by(partner bop_item)
gen unaccounted=res_EU28_percat_partner - accountedfor_aux



gen aux=service_sum if geo=="EU28" & bop_item=="S"
egen EUimportsfrompartner=total(aux), by(partner)
drop aux

gen imputed1=min_for_table+(service_sum/EUimportsfrompartner)*unaccounted if bop_missing & geo!="EU28"
gen extra_value_aux=(service_sum/EUimportsfrompartner)*unaccounted if bop_missing & geo!="EU28"
drop accountedfor_aux
egen accountedfor_aux =sum(extra_value_aux), by(partner bop_item)
replace unaccounted=unaccounted-accountedfor_aux

gen aux=(imputed1!=.|bop_missing==0)
drop totalimports_aux
gen totalimports_aux=totalimports if geo!="EU28" & aux==0
egen rest_totalimports= total(totalimports_aux), by(partner bop_item)
gen imputed2=min_for_table+(totalimports/rest_totalimports)*unaccounted if bop_missing & imputed1==. 
//minimum is already taken into account in unaccounted for sum 


egen noimputed2=total(imputed2), by(bop_item partner) missing
egen imputed1_aux=sum(imputed1), by(partner bop_item)
gen added_aux = (imputed1/imputed1_aux)*unaccounted if noimputed2==.
replace added_aux=0 if noimputed2!=.
replace imputed1=imputed1+added_aux 
drop imputed1_aux added_aux


egen imputed=rowtotal(bop_its6_det`temp' imputed1 imputed2), missing
replace imputed=min_for_table if imputed<min_for_table
replace imputed=bop_its6_det`temp' if bop_missing==0

//distributing what is lost by maxes
gen extra_cor_aux=imputed-max_for_table if imputed>max_for_table & (imputed1!=.|imputed2!=.) & bop_missing
gen max_reached=(extra_cor_aux!=.) 
egen correction=total(extra_cor_aux), by(partner bop_item)
replace imputed=max_for_table if imputed>max_for_table
egen imputed_aux=rowtotal(imputed1 imputed2) if max_reached==0 & (imputed1!=.|imputed2!=.) & partner!="EU28", missing
egen imputed_aux2=sum(imputed_aux), by(partner bop_item)
gen added_aux = (imputed_aux/imputed_aux2)*correction if max_reached==0 & (imputed1!=.|imputed2!=.)
replace added_aux=0 if added_aux==.
replace imputed=imputed +added_aux
drop extra_cor correction imputed_aux imputed_aux2 added_aux

//reiterate what is lost by maxes has to be distributed:

qui forvalues x=1/28 {
gen extra_cor_aux=imputed-max_for_table if imputed>max_for_table & (imputed1!=.|imputed2!=.) & bop_missing
gen max_aux=(extra_cor_aux!=.)
replace max_reached=max_reached+max_aux
egen correction=total(extra_cor_aux), by(partner bop_item)
replace imputed=max_for_table if imputed>max_for_table
egen imputed_aux=rowtotal(imputed1 imputed2) if max_reached==0 & (imputed1!=.|imputed2!=.) & partner!="EU28", missing
egen imputed_aux2=sum(imputed_aux), by(partner bop_item)
gen added_aux = (imputed_aux/imputed_aux2)*correction if max_reached==0 & (imputed1!=.|imputed2!=.)
replace added_aux=0 if added_aux==.
replace imputed=imputed +added_aux
drop extra_cor correction imputed_aux imputed_aux2 max_aux added_aux

}



//Preparing tables//
gen check_aux=imputed if geo!="EU28"
egen check_sum=total(check_aux), by(partner bop_item)
gen check=check_sum - EU_sum_percat_partner

gen EUhaven=(geo=="IE"|geo=="LU"|geo=="NL"|geo=="BE"|geo=="MT"|geo=="CY")

gen dodgy=0
foreach name in "Services: Charges for the use of intellectual property n.i.e."	"Services: Telecommunications, computer, and information services" "Services: Other business services"	"Services: Financial services" "Services: Insurance and pension services" {
replace dodgy=1 if bop_item_l=="`name'" 
}


//generating miror

keep bop_item bop_item_l dodgy geo_l partner_l partner geo bop_its6_det`temp' bop_its6_det2014 bop_its6_det2013 bop_its6_det2012 bop_its6_det2011 bop_its6_det2010 max_for_table imputed min_for_table

}

merge 1:1 geo partner bop_item using "$work/export" 


gen discrepancy=bop_its6_det`temp'-mirror_bop_its6_det`temp'
gen imput_discrepancy= imputed - mirror_imputed
gen EUhavengeo=(geo=="IE"|geo=="LU"|geo=="NL"|geo=="BE"|geo=="MT"|geo=="CY")
gen EUhavenpartner=(partner=="IE"|partner=="LU"|partner=="NL"|partner=="BE"|partner=="MT"|partner=="CY")



replace partner_l="z. European Union (28 countries)" if partner_l=="European Union (28 countries)"
replace geo_l="z. European Union (28 countries)" if geo_l=="European Union (28 countries)"

//Save tables in Stata format

preserve
	keep if bop_item=="S" 
	keep geo_l partner_l discrepancy bop_its6_det`temp' mirror_bop_its6_det`temp' bop_item_l
	save "$work/servicediscrepancies_A_$temp", replace
restore

preserve
	keep if dodgy
	replace bop_item_l = "dodgy services"
	keep geo_l partner_l discrepancy bop_its6_det`temp' mirror_bop_its6_det`temp' bop_item_l
	save "$work/dodgyservicediscrepancies_$temp", replace	
restore

preserve
	keep if bop_item=="SI" 
	keep geo_l partner_l discrepancy bop_its6_det`temp' mirror_bop_its6_det`temp' bop_item_l
	save "$work/servicediscrepancies_$temp", replace
	append using "$work/servicediscrepancies_A_$temp"
	append using "$work/dodgyservicediscrepancies_$temp"
	save "$work/servicediscrepancies_$temp", replace
*	erase "$work/servicediscrepancies_A_$temp.dta"
*	erase "$work/dodgyservicediscrepancies_$temp.dta"
restore

	/*

tabout geo_l partner_l using servicediscrepancies.xls if bop_item=="S", append  sum c(sum discrepancy) h3(discrepancy with total services)
tabout geo_l partner_l using servicediscrepancies.xls if bop_item=="S", append  sum c(sum bop_its6_det`temp') h3(Total services as reported by importer)
tabout geo_l partner_l using servicediscrepancies.xls if bop_item=="S", append  sum c(sum mirror_bop_its6_det`temp') h3(Total services as reported by exporter)

tabout geo_l partner_l using servicediscrepancies.xls if dodgy, append  sum c(sum discrepancy) h3(discrepancy with dodgy services)

tabout geo_l partner_l using servicediscrepancies.xls if dodgy, append  sum c(sum bop_its6_det`temp') h3(dodgy services as reported by importer)
tabout geo_l partner_l using servicediscrepancies.xls if dodgy, append  sum c(sum mirror_bop_its6_det`temp') h3(dodgy services as reported by exporter)

tabout geo_l partner_l using servicediscrepancies.xls if bop_item=="SI", append  sum c(sum discrepancy) h3(discrepancy with ICT services)
tabout geo_l partner_l using servicediscrepancies.xls if bop_item=="SI", append  sum c(sum bop_its6_det`temp') h3(ICT services as reported by importer)
tabout geo_l partner_l using servicediscrepancies.xls if bop_item=="SI", append  sum c(sum mirror_bop_its6_det`temp') h3(ICT services as reported by importer)

/*
tabout geo_l partner_l using servicediscrepancies.xls if dodgy, append  sum c(sum imput_discrepancy) h3(discrepancy with dodgy services and imputed)
tabout geo_l partner_l using servicediscrepancies.xls if dodgy, append  sum c(sum imputed) h3(imputed dodgy imports)
tabout geo_l partner_l using servicediscrepancies.xls if dodgy, append  sum c(sum mirror_imputed) h3(imputed dodgy exports)

/*
