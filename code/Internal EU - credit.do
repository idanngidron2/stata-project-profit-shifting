//---------------------------------------------
//Step 4d: service credit EU export to EU
//---------------------------------------------


// the dofile that handles (including imputations) service credit data from EU (EU countries exporting to EU countries)
//Credit only and only internal EU

//------------------(i)----------------------//
//Download data, basic data cleaning, and initial imputations

local temp=$temp

use "$work/bop_its6_det", clear 


drop if (geo=="CH"|geo=="EA18"|geo=="EA19"|geo=="ME"|geo=="MK"|geo=="TR"|geo=="NO"|geo=="IS"|geo=="RS"| geo=="EU27_2020")
gen countvar = length(bop_item)
keep if countvar<3
keep if stk_flow_la=="Credit" 

keep if (partner=="EU28"|partner=="AT"|	partner=="BE"|	partner=="BG"|	partner=="CY"|	partner=="CZ"|	partner=="DE"|	partner=="DK"|	partner=="EE"|	partner=="EL"|	partner=="ES"|	partner=="FI"|	partner=="FR"|	partner=="HR"|	partner=="HU"|	partner=="IE"|	partner=="IT"|	partner=="LT"|	partner=="LU"|	partner=="LV"|	partner=="MT"|	partner=="NL"|	partner=="PL"|	partner=="PT"|	partner=="RO"|	partner=="SE"|	partner=="SI"|	partner=="SK"|	partner=="UK")

//use values of 2017 for Malta in 2016, since 2016 is missing.
replace bop_its6_det2016 = bop_its6_det2017 if geo == "MT"

replace bop_its6_det`temp' =0 if partner==geo & partner!="EU28"

gen nongroup_partner=partner!="EU28"
gen exports=nongroup_partner*bop_its6_det`temp'
gen bop_notEU=bop_its6_det`temp' if geo!="EU28"



//We begin by counting the missing "partner" observations- If all countries report which partners they export from (temp==28 if all report). We also calculate the value of exports that is unaccounted for pr. partner by using the EU aggregate

egen temp=count(bop_notEU), by(bop_item partner)

gen EU_sum_percat_partner_aux= bop_its6_det`temp' if geo=="EU28"

egen EU_sum_percat_partner=total(EU_sum_percat_partner_aux), by(partner bop_item) missing


gen exports_no_EU28=bop_its6_det`temp' if geo!="EU28"
egen EU_sum_percat_partner_est=total(exports_no_EU28), by(bop_item partner)
gen res_EU28_percat_partner=EU_sum_percat_partner-EU_sum_percat_partner_est

//First strictly logical (true) imputation based on EU28 sum and country aggregate (i.e. if all countries but one is reporting their partners we can use the EU aggregate and perfectly impute the last country)
replace bop_its6_det`temp'=res_EU28_percat_partner if bop_its6_det`temp'==. & geo!="EU28" & temp==27

egen internal_sum_det=total(exports), by(geo countvar)

//Second strictly logical (true) imputation based on EU28 sum and country aggregate (i.e. if all countries but if all partners but one are reported by a single countries we can use the EU aggregate and perfectly impute the last country)
gen internal_sum_agg_aux=bop_its6_det`temp' if partner=="EU28"
egen total_EU=total(internal_sum_agg_aux), by(geo bop_item) missing

gen bop_partner_notEU=bop_its6_det`temp' if partner!="EU28"

egen temp2=count(bop_partner_notEU), by(bop_item geo)

egen total_EU_est=total(exports), by(geo bop_item)

gen res_total_EU_geo=total_EU-total_EU_est


replace bop_its6_det`temp'=res_total_EU_geo if bop_its6_det`temp'==. & partner!="EU28" & temp2==27

replace bop_its6_det`temp'=total_EU_est if bop_its6_det`temp'==. & partner=="EU28" & temp2==28

//Third strictly logical (true) imputation based on all categories having to sum up to total (same logic as above: there are 12 income categories (plus an extra unknown SN category in some cases) - they all have to sum up to the total)


gen SN_temp=(bop_item=="SN")
egen SN= total(SN_temp), by(geo partner)
egen count_cat= count(bop_its6_det`temp'), by(geo partner)

gen export_no_S=bop_its6_det`temp' if bop_item!="S"
gen service_sum_aux=bop_its6_det`temp' if countvar==1
egen service_sum = total(service_sum_aux), by(geo partner) missing
egen S_est=total(export_no_S), by(geo partner) 
gen res_S_partner=service_sum-S_est


replace bop_its6_det`temp'= res_S_partner if bop_item!="S" & bop_its6_det`temp'==. & count_cat==12+SN

replace bop_its6_det`temp'= S_est if bop_item=="S" & bop_its6_det`temp'==. & count_cat==12+SN

//reiterate all strictly logical imputations
{

drop exports-res_S_partner
gen exports=nongroup_partner*bop_its6_det`temp'


gen bop_notEU=bop_its6_det`temp' if geo!="EU28"



//What is missing from EU28 to partner, per category

egen temp=count(bop_notEU), by(bop_item partner)

gen EU_sum_percat_partner_aux= bop_its6_det`temp' if geo=="EU28"

egen EU_sum_percat_partner=total(EU_sum_percat_partner_aux), by(partner bop_item) missing


gen exports_no_EU28=bop_its6_det`temp' if geo!="EU28"
egen EU_sum_percat_partner_est=total(exports_no_EU28), by(bop_item partner)
gen res_EU28_percat_partner=EU_sum_percat_partner-EU_sum_percat_partner_est

//First strictly logical (true) imputation based on EU28 sum and country aggregate
replace bop_its6_det`temp'=res_EU28_percat_partner if bop_its6_det`temp'==. & geo!="EU28" & temp==27

//Filling out the blanks using how much is exported from EU28 vs. all individual partners:Total service estimated from detailed obs per geo
egen internal_sum_det=total(exports), by(geo countvar)

//Extra-EU in every observation
gen internal_sum_agg_aux=bop_its6_det`temp' if partner=="EU28"
egen total_EU=total(internal_sum_agg_aux), by(geo bop_item) missing

gen bop_partner_notEU=bop_its6_det`temp' if partner!="EU28"

egen temp2=count(bop_partner_notEU), by(bop_item geo)

//Extra-EU services estimated
egen total_EU_est=total(exports), by(geo bop_item)

//Gen residual for extra_EU per geo
gen res_total_EU_geo=total_EU-total_EU_est



//second strictly logical replacement 

replace bop_its6_det`temp'=res_total_EU_geo if bop_its6_det`temp'==. & partner!="EU28" & temp2==27

replace bop_its6_det`temp'=total_EU_est if bop_its6_det`temp'==. & partner=="EU28" & temp2==28

 
gen SN_temp=(bop_item=="SN")
egen SN= total(SN_temp), by(geo partner)
egen count_cat= count(bop_its6_det`temp'), by(geo partner)

//Second strictly logical (true) imputation based on categorytotal
gen export_no_S=bop_its6_det`temp' if bop_item!="S"
gen service_sum_aux=bop_its6_det`temp' if countvar==1
egen service_sum = total(service_sum_aux), by(geo partner) missing
egen S_est=total(export_no_S), by(geo partner) 
gen res_S_partner=service_sum-S_est


replace bop_its6_det`temp'= res_S_partner if bop_item!="S" & bop_its6_det`temp'==. & count_cat==12+SN

replace bop_its6_det`temp'= S_est if bop_item=="S" & bop_its6_det`temp'==. & count_cat==12+SN


}




//We now attempt to bound the unreported exports by finding the minimum of all possible stricly logical maximas
//Biggest max: total exports less whatever is reported in rest of EU
gen totalexports_aux= bop_its6_det`temp' if partner=="EU28" & bop_item=="S"
egen totalexports=total(totalexports_aux), by(geo) missing


egen everything_reported=total(exports), by(geo countvar)

gen rest_aux= totalexports - everything_reported

egen rest= min(rest_aux), by(geo)

replace rest=. if service_sum!=.






//Total service estimated from detailed obs per geo
drop internal_sum_det internal_sum_agg
egen internal_sum_det=total(exports), by(geo countvar)

//What is missing from each reporter (geo) to the entire outside world - This will give us a maximum amount of exports to be imputed pr. reporter
gen internal_sum_agg_aux=bop_its6_det`temp' if partner=="EU28"
gen temp1=1 if partner=="EU28" & bop_its6_det`temp'==.
egen temp3=sum(temp1), by(geo partner)
replace internal_sum_agg_aux=. if temp3>0
drop temp*
egen extra_EU=total(internal_sum_agg_aux), by(geo bop_item) missing


//We estimate the export value that is accounted for by aggregating all the reports of each individual country (within categories)
egen extra_EU_est=total(exports), by(geo bop_item)

//We then calculate the difference between the sum of exports from rest of the world and the sum of individual reports - this residual is the exports that needs to be imputed pr. reporter-category (geo- bop item) 
gen res_EXT_EU_geo=extra_EU-extra_EU_est

gen bop_missing=bop_its6_det`temp'==.

foreach var in rest service_sum totalexports extra_EU res_S_partner res_EXT_EU_geo {
replace `var'=. if `var'<0
 }



egen minof3max=rmin(rest service_sum totalexports extra_EU res_S_partner res_EU28_percat_partner res_EXT_EU_geo)



//How much is left when maximum of others is used for each partner-geo => this creates a minimum value of exports pr geo-partner-category observation
sort geo partner bop_missing minof3max
by geo partner bop_missing: gen sumofsmallest=sum(minof3max)
by geo partner bop_missing: gen rank_aux=_n
by geo partner bop_missing: gen rank_N=_N
replace sumofsmallest=0 if rank_aux==rank_N
egen secondsmallest=max(sumofsmallest), by(geo partner bop_missing)

gen min_rest_internal_geo=res_S_partner-secondsmallest if rank_N==rank_aux



egen minof3max_cons=rmin(rest service_sum totalexports extra_EU res_S_partner res_EU28_percat_partner res_EXT_EU_geo)
replace minof3max_cons=. if bop_its6_det`temp'!=.
gen min=0

//We now add the minimum to create a lower bound estimate

egen maxofmin_eu3=rmax(min_rest_internal_geo min)
replace maxofmin_eu3=. if bop_its6_det`temp'!=.



//-------------------------(ii)------------------------//
//Real imputations begin


gen max_for_table= minof3max_cons if geo!="EU28"
gen unaccounted_for_table=res_EU28_percat_partner if geo!="EU28"
gen min_for_table= maxofmin_eu3 if geo!="EU28"
replace min_for_table=bop_its6_det`temp' if bop_its6_det`temp'!=.
replace max_for_table=bop_its6_det`temp' if bop_its6_det`temp'!=.



//Within the bounds of min/max we will allocate the missing exports according to the missing exports of each country
gen min_aux=min_for_table if bop_missing
egen accountedfor_aux =sum(min_aux), by(partner bop_item)
gen unaccounted=res_EU28_percat_partner - accountedfor_aux



gen aux=service_sum if geo=="EU28" & bop_item=="S"
egen EUexportsfrompartner=total(aux), by(partner)
drop aux

gen imputed1=min_for_table+(service_sum/EUexportsfrompartner)*unaccounted if bop_missing & geo!="EU28"
gen extra_value_aux=(service_sum/EUexportsfrompartner)*unaccounted if bop_missing & geo!="EU28"
drop accountedfor_aux
egen accountedfor_aux =sum(extra_value_aux), by(partner bop_item)
replace unaccounted=unaccounted-accountedfor_aux

gen aux=(imputed1!=.|bop_missing==0)
drop totalexports_aux
gen totalexports_aux=totalexports if geo!="EU28" & aux==0
egen rest_totalexports= total(totalexports_aux), by(partner bop_item)
gen imputed2=min_for_table+(totalexports/rest_totalexports)*unaccounted if bop_missing & imputed1==. 
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

//distributing what is lost by maxes (i.e. what is still unaccounted for) 
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



//--------------------------(iii)---------------------------//
//save total services to Ext EU28 data in stata files formatted for further computations

gen check_aux=imputed if geo!="EU28"
egen check_sum=total(check_aux), by(partner bop_item)
gen check=check_sum - EU_sum_percat_partner
*replace imputed = -imputed if imputed <0 	//ensure imputed values are nonnegative
*replace imputed = 0 if imputed <0 	//ensure imputed values are nonnegative


gen EUhaven=(geo=="IE"|geo=="LU"|geo=="NL"|geo=="BE"|geo=="MT"|geo=="CY")

//total services to EU28

preserve
keep if bop_item=="S" & partner=="EU28" & geo!="EU28"
keep geo_l partner bop_its6_det`temp' imputed min_for_table max_for_table bop_missing
save "$work/serviceexports_eu_$temp", replace
restore



//total services to Havens


preserve
keep if bop_item=="S" & EUhaven & partner!="EU28"
keep partner_l bop_its6_det`temp' imputed min_for_table max_for_table bop_missing
gen geo_title = "geo EU haven"
save "$work/credit_havens_intraEU_$temp", replace
restore


//total services from EU28

preserve
keep if bop_item=="S" & geo=="EU28" & partner!="EU28"
keep partner_l bop_its6_det`temp' imputed min_for_table max_for_table bop_missing
gen geo_title= "geo EU28"
save "$work/credit_EU28_intraEU_$temp", replace
restore


//--------------------------(iv)---------------------------//
//compute the sum of dodgy (high risk payments)
//save in separate stata files for further computations


gen dodgy=0
foreach name in "Services: Charges for the use of intellectual property n.i.e."	"Services: Telecommunications, computer, and information services" "Services: Other business services"	"Services: Financial services" "Services: Insurance and pension services" {
replace dodgy=1 if bop_item_l=="`name'" 
}

//Total dodgy EU exports 

preserve
keep if dodgy & geo=="EU28" & partner!="EU28"
keep partner_l bop_its6_det`temp' imputed min_for_table max_for_table bop_missing
gen geo_title= "geo EU28"
save "$work/creditdodgy_EU28_intraEU_$temp", replace
restore


//misc creadit intra EU

preserve
keep if dodgy & partner=="EU28" & geo!="EU28"
keep geo_l partner bop_its6_det`temp' imputed min_for_table max_for_table bop_missing
save "$work/misc_credit_intraEU_$temp", replace
restore



//matrix with services

preserve
keep if bop_item=="S" & partner!="EU28" & geo!="EU28"
keep partner_l geo_l imputed
save "$work/credit_intraEU_allservices_$temp", replace
restore


preserve
*keep if bop_item=="S" & EUhaven & partner!="EU28"
keep if bop_item=="S" 
keep partner_l geo_l imputed
save "$work/credit_EUhaven_intraEU_$temp", replace
restore








//Creating help variable to limit dodgy to total imputed services
drop aux*
gen aux=1 if service_sum==. 
egen aux2=sum(aux), by(geo partner)
gen aux3=imputed if bop_item=="S"
egen aux4=sum(aux3), by(geo partner)
replace service_sum=aux4 if aux2>0 & aux2!=.
drop aux*




//accummulating dodgy stuff

egen dodgy_imputed=total(imputed), by(geo partner dodgy)
egen dodgy_nonimputed=total(bop_its6_det`temp'), by(geo partner dodgy)
egen dodgy_missing=sum(bop_missing), by(geo partner dodgy)
replace dodgy_nonimputed=. if dodgy==0
replace dodgy_imputed=. if dodgy==0
gen extra_imputed=dodgy_imputed-dodgy_nonimputed 


//constraints on extra imputed: res_S_partner 

gen correction1=extra_imputed-res_S_partner if extra_imputed>res_S_partner 
replace correction1=0 if correction1==.



replace dodgy_imputed=dodgy_imputed-correction1
replace extra_imputed=extra_imputed-correction1


//second constraint: there can't be more going to havens then what is going to the world
egen dodgy_extra_EU=total(internal_sum_agg_aux), by(geo dodgy) missing

//third: there can't be going more to haven than service_sum (exports from partner), total exports, or everything extra
egen max_dodgy_pr_partner=rmin(service_sum totalexports rest dodgy_extra_EU)
replace max_dodgy_pr_partner=res_S_partner+dodgy_nonimputed if res_S_partner+dodgy_nonimputed<max_dodgy_pr_partner 

gen correction2=dodgy_imputed - max_dodgy_pr_partner if dodgy_imputed > max_dodgy_pr_partner & dodgy_missing>0 & dodgy_missing!=.
replace dodgy_imputed = max_dodgy_pr_partner if dodgy_imputed > max_dodgy_pr_partner
replace extra_imputed=extra_imputed-correction2 if dodgy_imputed > max_dodgy_pr_partner

egen correction_aux=rmax(correction2 correction1)
gen max_met=(correction_aux!=0 & correction_aux!=.)


//minimum for dodgy
gen max_non_dodgy_aux=max_for_table*(1-dodgy) if bop_item!="S" 
egen max_non_dodgy=total(max_non_dodgy_aux), by(geo partner)
egen min_dodgy_aux1=total(min_for_table) if dodgy==1, by(geo partner dodgy)
gen min_dodgy_aux2=dodgy_nonimputed+res_S_partner - max_non_dodgy 
egen min_dodgy=rmax(min_dodgy_aux1 min_dodgy_aux2)
replace min_dodgy=0 if min_dodgy<0|min_dodgy==.

gen correction3=dodgy_imputed - min_dodgy if min_dodgy>dodgy_imputed & dodgy_missing>0 & dodgy_missing!=.
replace dodgy_imputed=min_dodgy if min_dodgy>dodgy_imputed & dodgy_missing>0 & dodgy_missing!=.
replace extra_imputed=extra_imputed-correction3 if min_dodgy>dodgy_imputed & dodgy_missing>0 & dodgy_missing!=.


//correction to ensure that maximas are not overstepped and the reduction due to maximimas is then redistributed- I'll use SH to do this (could have been any subcategory as we are summing up the dodgy payments)
egen correction_aux2=rowtotal(correction3 correction_aux)
egen correction=total(correction_aux2), by(partner bop_item)
gen imputed_aux=dodgy_imputed if max_met==0 & extra_imputed!=0 & dodgy_missing>0 & dodgy_missing!=.
egen imputed_aux2=sum(imputed_aux) if bop_item=="SH" & partner!="EU28", by(partner bop_item)
gen added_aux = (imputed_aux/imputed_aux2)*correction if max_met==0
replace added_aux=0 if added_aux==.
replace extra_imputed=extra_imputed+added_aux
replace dodgy_imputed=dodgy_imputed +added_aux
drop correction* imputed_aux imputed_aux2 added_aux



//correction again
qui forvalues x=1/28 {
gen correction1= extra_imputed - res_S_partner if extra_impute > res_S_partner 
gen correction2=dodgy_imputed - max_dodgy_pr_partner if dodgy_imputed > max_dodgy_pr_partner
egen correction_aux=rowmax(correction1 correction2)
replace correction_aux=0 if correction_aux==.
replace dodgy_imputed = dodgy_imputed - correction_aux if correction_aux!=0
replace extra_imputed=extra_imputed- correction_aux if correction_aux!=0
egen correction=total(correction_aux), by(partner bop_item)
gen max_aux=(correction_aux!=0 & correction_aux!=.)
replace max_met=max_met+max_aux
gen imputed_aux=dodgy_imputed if max_met==0 & extra_imputed!=0 & partner!="EU28" & dodgy_missing>0 & dodgy_missing!=.
egen imputed_aux2=sum(imputed_aux) if bop_item=="SH", by(partner bop_item)
gen added_aux = (imputed_aux/imputed_aux2)*correction if max_met==0
replace added_aux=0 if added_aux==.
replace extra_imputed=extra_imputed+added_aux
replace dodgy_imputed=dodgy_imputed +added_aux
drop correction* imputed_aux imputed_aux2 max_aux added_aux
}


//Check that maxes are in line

drop check_aux check_sum
gen check_aux=dodgy_nonimputed if geo=="EU28"
egen check_sum=total(check_aux), by(partner bop_item)
gen check_aux2=dodgy_imputed if geo!="EU28"
egen check_sum2=total(check_aux2), by(partner bop_item)
gen check2=check_sum2 - check_sum
*replace dodgy_imputed = -dodgy_imputed if dodgy_imputed <0 	//ensure imputed values are nonnegative
*replace dodgy_imputed = 0 if dodgy_imputed <0 	//ensure imputed values are nonnegative



//Generate dodgy tables*


//the matrices with all and only haven

preserve
keep if bop_item=="SH" & partner!="EU28" & geo!="EU28"
keep partner_l geo_l dodgy_imputed
save "$work/credit_intraEU_dodgy_$temp", replace
restore

preserve
keep if bop_item=="SH" & EUhaven & partner!="EU28" & geo!="EU28"
keep partner_l geo_l dodgy_imputed
save "$work/credit_intraEU_dodyhavens_$temp", replace
restore


keep if EUhaven & bop_item=="SH"

egen max=rowmin(max_dodgy_pr_partner service_sum)

drop min
gen min=min_dodgy
replace min=dodgy_imputed if dodgy_missing==0
replace max=dodgy_imputed if dodgy_missing==0





