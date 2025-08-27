//----------------------------------------
//Step 3c: OECD Table 14a
//----------------------------------------

//The OECD table 14a data is SNA data used to calculate domestic profits
//this do file structures this data for OECD economies and several other large economies
//also includes corporate tax data for the same countries using SNA table 4a 

*ssc install kountry
*ssc inst _gwtmean

//-----------------(i)-------------------//
//corporate tax data using SNA Table 4a

//current data available until 2023, this will have to be uploaded again for 
//years beyond 2023

/*
sdmxuse data OECD, clear dataset(SNA_TABLE4) dimensions(AUS+AUT+BEL+CAN+CHL+COL+CRI+CZE+DNK+EST+FIN+FRA+DEU+GRC+HUN+ISL+IRL+ISR+ITA+JPN+KOR+LVA+LTU+LUX+MEX+NLD+NZL+NOR+POL+PRT+SVK+SVN+ESP+SWE+CHE+TUR+GBR+USA+EA19+EU27_2020+NMEC+ARG+BRA+BGR+CHN+HRV+CYP+IND+IDN+MLT+ROU+RUS+SAU+ZAF.EXC.CD) panel(location)

drop transact measure

rename value EXC_CD

destring time, replace

save "$work/OECD EXC_CD", replace
*/

/* OLD code: now uploaded in R script OECD_BOP_R_Download

set timeout1 1500

sdmxuse data OECD, clear dataset(REV)
*/

//After OECD data explorer 2024 change: upload the version downloaded via R

import delimited "$rawdata/OECD_REV_2016_2023.csv", clear
rename ref_area cou 
rename time_period time 
rename revenue_code tax 
rename obsvalue corptaxrev 


destring time, force replace
*keep if var=="TAXNAT"
*rename value corptaxrev
keep if time==$temp
*keep if gov=="NES"
*keep if tax=="1200"
keep if tax== 1200
keep corp cou time

destring corp, replace force

save "$work/OECDcorptax_$temp", replace

//-----------------(ii)-------------------//
//corporate profits

*sdmxuse data OECD, clear dataset(SNA_TABLE14A) dimensions(AUS+AUT+BEL+CAN+CHL+COL+CRI+CZE+DNK+EST+FIN+FRA+DEU+GRC+HUN+ISL+IRL+ISR+ITA+JPN+KOR+LVA+LTU+LUX+MEX+NLD+NZL+NOR+POL+PRT+SVK+SVN+ESP+SWE+CHE+TUR+GBR+USA+EA19+EU27_2020+NMEC+BRA+CHN+IND+IDN+RUS+ZAF.NFB1GP+NFB2GP+NFD1P+NFD41P+NFD41R+NFK1MP+NFD44P.S12+S11+S1.C) panel(location)


//Translating former OECD codes of SNA Table 14a to post-2024 codes:
//NFD44P = D44(D) Property income attributed to insurance policy holders  
//NFK1MP = P51C: Consumption of fixed capital
//NFD1P = D1: Compensation of employees
//NFB1GP = B1G: Gross value added
//NFD41P = D41(D): Interest income (payable)
//NFD41R = D41(C): Interest income (receivable)
//NFB2GP = B2G: Gross operating surplus

//After OECD data explorer 2024 change: upload the version downloaded via R
import delimited "$rawdata/OECD_SNA_Tab14a_2016_2023.csv", clear

sort ref_area transaction time_period

//drop unnecessary observations, due to separation of data into revenue and expenditure

drop if accounting_entry == "C" & transaction == "D44" //remove receivables for property income
drop if accounting_entry == "C" & transaction == "D1"  //remove receivables for compensation of employees
drop if accounting_entry == "C" & transaction == "B1G"  //remove receivables for gross value added
drop if accounting_entry == "C" & transaction == "B2G"  //remove receivables for gross value added
drop if transaction == "D7"


//translate transaction to former coding standard

replace transaction = "NFD44P" if transaction == "D44"
replace transaction = "NFK1MP" if transaction == "P51C"
replace transaction = "NFD1P" if transaction == "D1"
replace transaction = "NFB1GP" if transaction == "B1G"
replace transaction = "NFD41P" if transaction == "D41" & accounting_entry == "D"
replace transaction = "NFD41R" if transaction == "D41" & accounting_entry == "C"
replace transaction = "NFB2GP" if transaction == "B2G"

//some more recoding to mimic previous data structure

replace transaction = "NFD44P_S1" if transaction == "NFD44P" & sector == "S1"
replace transaction = "NFD44P_S11" if transaction == "NFD44P" & sector == "S11"
replace transaction = "NFD44P_S12" if transaction == "NFD44P" & sector == "S12"

replace transaction = "NFK1MP_S1" if transaction == "NFK1MP" & sector == "S1"
replace transaction = "NFK1MP_S11" if transaction == "NFK1MP" & sector == "S11"
replace transaction = "NFK1MP_S12" if transaction == "NFK1MP" & sector == "S12"

replace transaction = "NFD1P_S1" if transaction == "NFD1P" & sector == "S1"
replace transaction = "NFD1P_S11" if transaction == "NFD1P" & sector == "S11"
replace transaction = "NFD1P_S12" if transaction == "NFD1P" & sector == "S12"

replace transaction = "NFB1GP_S1" if transaction == "NFB1GP" & sector == "S1"
replace transaction = "NFB1GP_S11" if transaction == "NFB1GP" & sector == "S11"
replace transaction = "NFB1GP_S12" if transaction == "NFB1GP" & sector == "S12"

replace transaction = "NFB2GP_S1" if transaction == "NFB2GP" & sector == "S1"
replace transaction = "NFB2GP_S11" if transaction == "NFB2GP" & sector == "S11"
replace transaction = "NFB2GP_S12" if transaction == "NFB2GP" & sector == "S12"

replace transaction = "NFD41P_S1" if transaction == "NFD41P" & sector == "S1"
replace transaction = "NFD41P_S11" if transaction == "NFD41P" & sector == "S11"
replace transaction = "NFD41P_S12" if transaction == "NFD41P" & sector == "S12"

replace transaction = "NFD41R_S1" if transaction == "NFD41R" & sector == "S1"
replace transaction = "NFD41R_S11" if transaction == "NFD41R" & sector == "S11"
replace transaction = "NFD41R_S12" if transaction == "NFD41R" & sector == "S12"


//keep relevant variables
rename time_period time
rename ref_area location 
keep time location transaction obsvalue


//destring transaction for reshape 
gen t2 = .
replace t2 = 1 if transaction  ==  "NFD44P_S1" 
replace t2 = 2 if transaction  ==  "NFD44P_S11" 
replace t2 = 3 if transaction  ==  "NFD44P_S12" 
replace t2 = 4 if transaction  ==  "NFK1MP_S1" 
replace t2 = 5 if transaction  ==  "NFK1MP_S11" 
replace t2 = 6 if transaction  ==  "NFK1MP_S12" 
replace t2 = 7 if transaction  ==  "NFD1P_S1" 
replace t2 = 8 if transaction  ==  "NFD1P_S11" 
replace t2 = 9 if transaction  ==  "NFD1P_S12" 
replace t2 = 10 if transaction  ==  "NFB1GP_S1" 
replace t2 = 11 if transaction  ==  "NFB1GP_S11" 
replace t2 = 12 if transaction  ==  "NFB1GP_S12" 
replace t2 = 13 if transaction  ==  "NFB2GP_S1" 
replace t2 = 14 if transaction  ==  "NFB2GP_S11" 
replace t2 = 15 if transaction  ==  "NFB2GP_S12" 
replace t2 = 16 if transaction  ==  "NFD41P_S1" 
replace t2 = 17 if transaction  ==  "NFD41P_S11" 
replace t2 = 18 if transaction  ==  "NFD41P_S12" 
replace t2 = 19 if transaction  ==  "NFD41R_S1" 
replace t2 = 20 if transaction  ==  "NFD41R_S11" 
replace t2 = 21 if transaction  ==  "NFD41R_S12" 

drop transaction

//reshape 
reshape wide obsvalue, i(location time) j(t2)  

rename obsvalue1 NFD44P_S1
rename obsvalue2 NFD44P_S11
rename obsvalue3 NFD44P_S12
rename obsvalue4 NFK1MP_S1
rename obsvalue5 NFK1MP_S11
rename obsvalue6 NFK1MP_S12
rename obsvalue7 NFD1P_S1
rename obsvalue8 NFD1P_S11
rename obsvalue9 NFD1P_S12
rename obsvalue10 NFB1GP_S1
rename obsvalue11 NFB1GP_S11
rename obsvalue12 NFB1GP_S12
rename obsvalue13 NFB2GP_S1
rename obsvalue14 NFB2GP_S11
rename obsvalue15 NFB2GP_S12
rename obsvalue16 NFD41P_S1
rename obsvalue17 NFD41P_S11
rename obsvalue18 NFD41P_S12
rename obsvalue19 NFD41R_S1
rename obsvalue20 NFD41R_S11
rename obsvalue21 NFD41R_S12


 
save "$work/OECD Table 14a_new", replace


//---------------------------
//update country year list
//---------------------------
use "$rawdata/countryyearlist", replace 
replace time = 2019
duplicates drop location, force
tempfile tf 
save `tf', replace 
replace time = 2020
tempfile tf2 
save `tf2', replace 
replace time = 2021
tempfile tf3 
save `tf3', replace 
replace time = 2022
tempfile tf4 
save `tf4', replace 
replace time = 2023
tempfile tf5 
save `tf5', replace 

use "$rawdata/countryyearlist", clear 
append using `tf'
append using `tf2'
append using `tf3'
append using `tf4'
append using `tf5'
sort location time
save "$rawdata/countryyearlist_2023", replace


use "$work/OECD Table 14a_new", clear

merge 1:1 location time using "$rawdata/countryyearlist_2023", gen(merge2)

kountry location, from(iso3c) to(iso3n)
rename _ISO locnum
replace locnum=100019 if location=="EA19"
replace locnum=100027 if location=="EU27_2020"
sort location time


foreach x in _S11 _S12 _S1{

label var NFB1GP`x' "gva`x'"
label var NFB2GP`x' "gross_op_surplus`x'"
label var NFD41P`x' "interest_uses`x'"
label var NFD41R`x' "interest_res`x'"
label var NFK1MP`x' "depreciation`x'"
label var NFD1P`x' "Compensation of employees `x'"
}





*S1 = Total economy , S11 = Financial corp, S12 = Non financial corp
merge 1:1  location time using "$work/OECD EXC_CD", gen(merge1)
drop if merge1==2
drop merge1

foreach x in NFB1GP_S11 NFB1GP_S12 NFB1GP_S1 NFB2GP_S11 NFB2GP_S12 NFB2GP_S1 NFD41P_S11 NFD41P_S12 NFD41P_S1 NFD41R_S11 NFD41R_S12 NFD41R_S1 NFK1MP_S11 NFK1MP_S12 NFK1MP_S1 NFD1P_S11 NFD1P_S12 NFD1P_S1 NFD44P_S11 NFD44P_S12 NFD44P_S1{
replace `x'=`x'/EXC_CD
}


merge 1:1  location time using "$rawdata/GDP_per_cap", gen(mergeGDPprcap)
drop if mergeGDPprcap==2
drop mergeGDPprcap

*duplicates drop location time, force
drop if locnum ==.
tsset locnum time

replace GDPprCap=L1.GDPprCap if GDPprCap==.

egen rank=rank(GDPprCap), by(time)
egen maxrank=max(rank), by(time)
gen pcttile=rank/maxrank


egen inc_group=cut(pcttile), group(4)



gen corp_wage=NFD1P_S11+NFD1P_S12

gen corp_va = NFB1GP_S11+ NFB1GP_S12 
gen corp_va_share=corp_va/NFB1GP_S1

gen corp_OS = NFB2GP_S11 + NFB2GP_S12
gen net_int = NFD41P_S11 + NFD41P_S12  - NFD41R_S11 - NFD41R_S12

gen depreciation= NFK1MP_S11 + NFK1MP_S12
gen tax_prof=corp_OS - net_int - depr

egen totaltax_prof=sum(tax_prof),by(time)

**

foreach var in NFB1GP_S11  NFB1GP_S12  NFB1GP_S1  NFB2GP_S11  NFB2GP_S12  NFB2GP_S1  NFD41P_S11  NFD41P_S12  NFD41P_S1  NFD41R_S11  NFD41R_S12  NFD41R_S1  NFK1MP_S11  NFK1MP_S12  NFK1MP_S1  {
gen missing_`var'=1 if `var'==.
}


//-----------------(iii)-------------------//
//the following code imputes missing values based on various strategies
//we start with imputing based on past year(s) and accounting for GDP growth


merge 1:1 location time using "$work/GDPforOECD", gen(merge3)
drop if merge3==2
replace NFB1GP_S1=GDP/1000000 if NFB1GP_S1==.

tsset locnum time
foreach var in NFB1GP_S11  NFB1GP_S12  NFB1GP_S1  NFB2GP_S11  NFB2GP_S12  NFB2GP_S1 NFD1P_S1 NFD1P_S12 NFD1P_S11 NFD41P_S11  NFD41P_S12  NFD41P_S1  NFD41R_S11  NFD41R_S12  NFD41R_S1  NFK1MP_S11  NFK1MP_S12  NFK1MP_S1  {
replace `var'=L1.`var'*(NFB1GP_S1/L1.NFB1GP_S1) if `var'==.
}

foreach var in NFB1GP_S11  NFB1GP_S12  NFB1GP_S1  NFB2GP_S11  NFB2GP_S12  NFB2GP_S1 NFD1P_S1 NFD1P_S12 NFD1P_S11 NFD41P_S11  NFD41P_S12  NFD41P_S1  NFD41R_S11  NFD41R_S12  NFD41R_S1  NFK1MP_S11  NFK1MP_S12  NFK1MP_S1  {
replace `var'=L1.`var'*(NFB1GP_S1/L1.NFB1GP_S1) if `var'==.
}

replace corp_wage=NFD1P_S11+NFD1P_S12

replace corp_va = NFB1GP_S11+ NFB1GP_S12 
replace corp_va_share=corp_va/NFB1GP_S1

replace corp_OS = NFB2GP_S11 + NFB2GP_S12
replace net_int = NFD41P_S11 + NFD41P_S12  - NFD41R_S11 - NFD41R_S12

replace depreciation= NFK1MP_S11 + NFK1MP_S12
replace tax_prof=corp_OS - net_int - depr



//countries missing value added entirely imputed using fraction of GDP to va (weighted and within income groups)

gen vashare_S11=NFB1GP_S11/NFB1GP_S1 
gen vashare_S12=NFB1GP_S12/NFB1GP_S1 

egen mean_vashare_S11=wtmean(vashare_S11), weight(NFB1GP_S1) by(time inc_group)
egen mean_vashare_S12=wtmean(vashare_S12), weight(NFB1GP_S1) by(time inc_group)

replace NFB1GP_S11=mean_vashare_S11*NFB1GP_S1 if NFB1GP_S11==.
replace NFB1GP_S12=mean_vashare_S12*NFB1GP_S1 if NFB1GP_S12==.
replace corp_va = NFB1GP_S11+ NFB1GP_S12 if corp_va==.

//countries missing total operating surplus entirely imputed using fraction of os to va (weighted and within income groups)

gen tempNFB2GP_S11=NFB2GP_S11 if NFB1GP_S11!=.
gen tempNFB1GP_S11=NFB1GP_S11 if NFB2GP_S11!=.

gen tempNFB2GP_S12=NFB2GP_S12 if NFB1GP_S12!=.
gen tempNFB1GP_S12=NFB1GP_S12 if NFB2GP_S12!=.

egen temptotalNFB2GP_S11=total(tempNFB2GP_S11), by(time inc_group)
egen temptotalNFB1GP_S11=total(tempNFB1GP_S11), by(time inc_group)

gen mean_os_pr_va11=temptotalNFB2GP_S11/temptotalNFB1GP_S11

egen temptotalNFB2GP_S12=total(tempNFB2GP_S12), by(time inc_group)
egen temptotalNFB1GP_S12=total(tempNFB1GP_S12), by(time inc_group)

gen mean_os_pr_va12=temptotalNFB2GP_S12/temptotalNFB1GP_S12

replace NFB2GP_S11=NFB1GP_S11*mean_os_pr_va11 if NFB2GP_S11==.
replace NFB2GP_S12=NFB1GP_S12*mean_os_pr_va12 if NFB2GP_S12==.


replace corp_OS = NFB2GP_S11 + NFB2GP_S12 if corp_OS==.
drop temp*


//Imputing net interest paid relative to operating surplus (weighted and within income groups)

gen interestpaid_shareOS_S11=NFD41P_S11/NFB2GP_S11
gen interestpaid_shareOS_S12=NFD41P_S12/NFB2GP_S12
gen interestreceived_shareOS_S11=NFD41R_S11/NFB2GP_S11
gen interestreceived_shareOS_S12=NFD41R_S12/NFB2GP_S12

gen temp_ipaid_s11=NFD41P_S11 if interestpaid_shareOS_S11!=.
gen tempNFB2GP_S11p=NFB2GP_S11 if interestpaid_shareOS_S11!=.

gen temp_irec_s11=NFD41R_S11 if interestreceived_shareOS_S11!=.
gen tempNFB2GP_S11r=NFB2GP_S11 if interestreceived_shareOS_S11!=.

gen temp_ipaid_s12=NFD41P_S12 if interestpaid_shareOS_S12!=.
gen tempNFB2GP_S12p=NFB2GP_S12 if interestpaid_shareOS_S12!=.

gen temp_irec_s12=NFD41R_S12 if interestreceived_shareOS_S12!=.
gen tempNFB2GP_S12r=NFB2GP_S12 if interestreceived_shareOS_S12!=.


egen total_interestpaid_S11=mean(temp_ipaid_s11), by(time inc_group)
egen total_interestpaid_S12=mean(temp_ipaid_s12), by(time inc_group)
egen total_interestrec_S11=mean(temp_irec_s11), by(time inc_group)
egen total_interestrec_S12=mean(temp_irec_s12), by(time inc_group)

egen total_NFB2GP_S11p=mean(tempNFB2GP_S11p), by(time inc_group)
egen total_NFB2GP_S11r=mean(tempNFB2GP_S11r), by(time inc_group)
egen total_NFB2GP_S12p=mean(tempNFB2GP_S12p), by(time inc_group)
egen total_NFB2GP_S12r=mean(tempNFB2GP_S12r), by(time inc_group)

gen mean_interestpaid_shareOS_S11=total_interestpaid_S11/total_NFB2GP_S11p
gen mean_interestpaid_shareOS_S12=total_interestpaid_S12/total_NFB2GP_S12p

gen mean_interestreceived_S11=total_interestrec_S11/total_NFB2GP_S11r
gen mean_interestreceived_S12=total_interestrec_S12/total_NFB2GP_S12r


replace NFD41P_S11= mean_interestpaid_shareOS_S11*NFB2GP_S11 if NFD41P_S11==.
replace NFD41P_S12= mean_interestpaid_shareOS_S12*NFB2GP_S12 if NFD41P_S12==.
replace NFD41R_S11= mean_interestreceived_S11*NFB2GP_S11 if NFD41R_S11==.
replace NFD41R_S12= mean_interestreceived_S12*NFB2GP_S12 if NFD41R_S12==.

replace net_int = NFD41P_S11 + NFD41P_S12  - NFD41R_S11 - NFD41R_S12 if net_int==.


drop temp*


//Inputing depreciation using ratio's in same economy 5 years before or after when available

gen shareofcorpdep11=NFK1MP_S11/NFB2GP_S11
gen shareofcorpdep12=NFK1MP_S12/NFB2GP_S12


qui forval y=1/10 {
	local i=1+`y'
	tssmooth ma help`y' = shareofcorpdep11, weights( 1/`y' <`i'> `y'/1)
}

qui forval y=1/10 {
replace shareofcorpdep11=help`y' if shareofcorpdep11==.
}

drop help*

//Impute using 5 times before or after S12

qui forval y=1/10 {
	local i=1+`y'
	tssmooth ma help`y' = shareofcorpdep12, weights( 1/`y' <`i'> `y'/1)
}

qui forval y=1/10 {
replace shareofcorpdep12=help`y' if shareofcorpdep12==.
}

drop help*

//Impute rest of depreciation using weighted mean with respect to OS (within income groups)

egen mean_shareofcorpdep11=wtmean(shareofcorpdep11), weight(NFB2GP_S11) by(time inc_group)
egen mean_shareofcorpdep12=wtmean(shareofcorpdep12), weight(NFB2GP_S12) by(time inc_group)


replace shareofcorpdep11=mean_shareofcorpdep11 if shareofcorpdep11==.
replace shareofcorpdep12=mean_shareofcorpdep12 if shareofcorpdep12==.

replace NFK1MP_S11=shareofcorpdep11*NFB2GP_S11 if NFK1MP_S11==.
replace NFK1MP_S12=shareofcorpdep12*NFB2GP_S12 if NFK1MP_S12==.

replace depreciation=NFK1MP_S12+NFK1MP_S11 if depreciation ==. 



//Impute corporate wages (Australia, Canada, Japan) using weighted mean with respect to OS (within income groups)


gen shareofcorpwa_S11=NFD1P_S11/NFB2GP_S11
egen mean_wageprOS11=wtmean(shareofcorpwa_S11), weight(NFB2GP_S11) by(time inc_group)

gen shareofcorpwa_S12=NFD1P_S12/NFB2GP_S12
egen mean_wageprOS12=wtmean(shareofcorpwa_S12), weight(NFB2GP_S12) by(time inc_group)


replace NFD1P_S11=mean_wageprOS11*NFB2GP_S11 if NFD1P_S11==.
replace NFD1P_S12=mean_wageprOS12*NFB2GP_S12 if NFD1P_S12==.

replace corp_wage=NFD1P_S11+NFD1P_S12

//Summing it all up:

replace tax_prof = corp_OS - net_int -depreciation if tax_prof==.
gen EBTDA=corp_OS - net_int
gen EBTDA_pr_Wage= EBTDA/corp_wage
gen taxprof_pr_wage=tax_prof/corp_wage

gen cou=location

merge 1:1 cou time using "$work/OECDcorptax_$temp", gen(mergetax)
replace corptax=1000*corptax/EXC


save "$work/tax_prof", replace
use "$work/tax_prof", clear

gen GDPofnonmissing=NFB1GP_S1 if tax_prof!=.


//-----------------(iv)-------------------//
//saving in separate stata file

preserve
keep if time==$temp
keep country tax_prof corptaxrev corp_va corp_OS net_int depreciation corp_wage EBTDA EBTDA_p taxprof_pr NFB1GP_S1 NFK1MP_S1 NFD44P_S12
save "$work/OECD_table14a_$temp", replace




