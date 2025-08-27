
//---------------------------------------------//
//Table B10
//---------------------------------------------//

//Table B10 needs be run second after B11
//This table updates and structures direct investment income data



//-------------------------------------------------//
//Step 1: OECD inward DI data (partners)
//-------------------------------------------------//

//we start with inward direct investment data 
//the first step is to look at the outward DI as reported by partners of OECD countries

//store the values of Guernsey and Jersey for 2021 to use in 2022
//this is to solve missing data for UK investment in JEY and GEY in 2022
if $temp == 2022{
use "$work/OECD_COUNTERDO_INCOME_2021", clear
sum value2 if counterpart_area == "JEY"
local JEY = r(mean)
sum value2 if counterpart_area == "GGY"
local GGY = r(mean)
}

use "$work/OECD_COUNTERDO_INCOME_$temp", clear

rename counterpart_area ISO3
rename value2 Inward_DI_partners_OECD
keep ISO3 Inward_DI_partners_OECD

if $temp == 2022{
replace Inward_DI_partners_OECD = `JEY' if ISO3 == "JEY"
replace Inward_DI_partners_OECD = `GGY' if ISO3 == "GGY"
}

tempfile oecd
save `oecd', replace


//-------------------------------------------------//
//Step 2: IMF inward DI data (country)
//-------------------------------------------------//

//we continue with inward DI data as reported by the country in IMF

use "$work/IMF_fdi_credit_debitinc_$temp", clear

rename n_country country
rename _ISO ISO3

rename TotalDI_Debit Inward_DI_country_IMF
replace Inward_DI_country_IMF = Inward_DI_country_IMF/1000000	//adjust to same unit as OECD data (USD Bln)
keep country ISO3 Inward_DI_country_IMF

//fill in missing ISO codes
replace ISO3="TCA" if country == "Turks and Caicos Islands"
replace ISO3="CUW" if country == "Curaçao, Kingdom of the Netherlands"
replace ISO3="SXM" if country == "Sint Maarten, Kingdom of the Netherlands"
replace ISO3="XKO" if country == "Kosovo, Rep. of"
replace ISO3="AND" if country == "Andorra, Principality of"
replace ISO3="SSD" if country == "South Sudan, Rep. of"
replace ISO3="SRB" if country == "Serbia, Rep. of"
replace ISO3="PSE" if country == "West Bank and Gaza"


merge m:m ISO3 using `oecd'

//fill in missing country names
replace country = "Bonaire" if ISO3=="BES"
replace country = "Cuba" if ISO3=="CUB"
replace country = "Guernsey" if ISO3=="GGY"
replace country = "Gibraltar" if ISO3=="GIB"
replace country = "Isle of Man" if ISO3=="IMN"
replace country = "Jersey" if ISO3=="JEY"
replace country = "Liechtenstein" if ISO3=="LIE"
replace country = "Samoa" if ISO3=="ASM"
replace country = "Guam" if ISO3=="GUM"
replace country = "Romania" if ISO3=="ROM"
replace country = "San Marino" if ISO3=="SMR"
replace country = "Taiwan" if ISO3=="TWN"
replace country = "British Virgin Islands" if ISO3=="VGB"


replace Inward_DI_country_IMF = 0 if Inward_DI_country_IMF==.

drop _merge
drop if ISO3==""
drop if country==""


tempfile tf1
save `tf1', replace


//special cases China and Singapore

//update Singapore value official Singapore statistics

import excel "$rawdata/Singapore", cellrange (A11:H58) firstrow clear
keep y_$temp DataSeries
destring y_$temp, replace
replace y_$temp = y_$temp /$SGP_USD
sum y_$temp if DataSeries == "Total"
local sgp = r(mean)


//update China value using official Chinese BOP data

import excel "$rawdata/china-bop-1950-2022", sheet ("annual(USD)") firstrow clear
keep if ID==62
destring y_$temp, replace
sum y_$temp
local abc = r(mean)
local chn = -`abc'*100*0.5

use `tf1', clear
replace Inward_DI_country_IMF = `sgp' if ISO3 == "SGP"
replace Inward_DI_country_IMF = `chn' if ISO3 == "CHN"

tempfile step2
save `step2', replace


//-------------------------------------------------//
//Step 3: OECD inward DI data (country)
//-------------------------------------------------//

//we continue with inward DI data as reported by the country in OECD

use "$work/OECD_DI_INCOME_$temp", clear
rename cou ISO3
rename value Inward_DI_country_OECD

merge m:m ISO3 using `step2'
drop _merge



replace Inward_DI_country_OECD = Inward_DI_country_IMF if Inward_DI_country_OECD ==.		//complete missing values in OECD data with the IMF data
order country ISO3 Inward_DI_country_OECD Inward_DI_country_IMF Inward_DI_partners_OECD
sort country


//-------------------------------------------------//
//Step 4: Gap in inward DI data
//-------------------------------------------------//

// we now compute the gap in direct investment data between the inward value reported by the country and the outward value reported by the partners

gen gap_inward=.
replace gap_inward = Inward_DI_country_OECD - Inward_DI_partners_OECD

tempfile step4
save `step4', replace

//-------------------------------------------------//
//Step 5: Bilateral DI income discrepancies
//-------------------------------------------------//


// import DI income discrepancies from table B11

use "$work/TableB11_$temp", clear

sum disc_total if ISO3 == "IRL"
local irl = r(mean)
sum disc_total if ISO3 == "NLD"
local nld = r(mean)
sum disc_total if ISO3 == "LUX"
local lux = r(mean)

use `step4', clear
gen missing_income =.
replace missing_income = `irl' if ISO3 == "IRL"
replace missing_income = `nld' if ISO3 == "NLD"
replace missing_income = `lux' if ISO3 == "LUX"


// order and sort, and add country groups to facilitate further analysis



gen group = "other"
replace group = "OECD" if ISO3=="AUS" | ISO3=="AUT" | ISO3=="BEL" | ISO3=="CAN" | ISO3=="CHL" | ISO3=="CZE" | ISO3=="DNK" | ISO3=="EST" | ISO3=="FIN" | ISO3=="FRA" | ISO3=="DEU" | ISO3=="GRC" | ISO3=="HUN" | ISO3=="ISL" | ISO3=="IRL" | ISO3=="ISR" | ISO3=="ITA" | ISO3=="JPN" | ISO3=="KOR" | ISO3=="LVA" | ISO3=="LUX" | ISO3=="MEX" | ISO3=="NLD" | ISO3=="NZL" | ISO3=="NOR" | ISO3=="POL" | ISO3=="PRT" | ISO3=="SVK" | ISO3=="SVN" | ISO3=="ESP" | ISO3=="SWE" | ISO3=="CHE" | ISO3=="TUR" | ISO3=="GBR" | ISO3=="USA"
replace group = "OECD_TH" if ISO3=="BEL" |ISO3=="IRL" | ISO3=="LUX" | ISO3=="NLD" |ISO3=="CHE" 
replace group = "DEV" if  ISO3=="BRA" | ISO3=="CHN" | ISO3=="COL" | ISO3=="CRI" | ISO3=="IND" | ISO3=="RUS" | ISO3=="ZAF" 
replace group = "TH" if ISO3=="AND" | ISO3=="AIA" | ISO3=="ATG" | ISO3=="ABW" | ISO3=="BHS" | ISO3=="BHR" | ISO3=="BRB" | ISO3=="BLZ" | ISO3=="BMU" | ISO3=="BES" | ISO3=="VGB" | ISO3=="CYM" | ISO3=="CUW" | ISO3=="CYP" | ISO3=="GIB" | ISO3=="GRD" | ISO3=="GGY" | ISO3=="HKG" | ISO3=="IMN" | ISO3=="JEY" | ISO3=="LBN" | ISO3=="LIE" | ISO3=="MAC" | ISO3=="MLT" | ISO3=="MHL" | ISO3=="MUS" | ISO3=="MCO" | ISO3=="PAN" | ISO3=="PRI" | ISO3=="SYC" | ISO3=="SGP" | ISO3=="SXM" | ISO3=="KNA" | ISO3=="LCA" | ISO3=="VCT" | ISO3=="TCA"
*replace group = "other" if ISO3 == "ROW"| ISO3=="WLD"

gen tax_haven = 0
replace tax_haven = 1 if group == "OECD_TH"|group=="TH"

sort group ISO3 
order country ISO3 group tax_haven 

//back to missing income

replace missing_income = -gap_inward if gap_inward <0 & group == "TH"
replace missing_income = 0 if gap_inward >=0 & group == "TH"

tempfile tableB10
save `tableB10', replace


//-------------------------------------------------//
//Step 6: computing missing income using stock data
//-------------------------------------------------//


// here we use manually downloaded values from IMF summarised in an excel table



import excel "$rawdata/Imputed DI income using stocks", sheet ("2015") firstrow clear			//we use 2015 stock FDI data for all years 

*import excel "$rawdata/Imputed DI income using stocks", sheet ("$temp") firstrow clear			//we use 2020 stock FDI data for years beyond 2020 due to data inconsistencies beyond 2020

keep DI_equity_income_surplus ISO3
tempfile stockdata
save `stockdata', replace
//----------------------------------------------------------
preserve 
keep if ISO3 == "VGB" | ISO3 == "TCA"
sum DI_equity_income_surplus 
local total_stock_surplus = r(sum)
restore 
//----------------------------------------------------------

use `tableB10', clear
merge m:m ISO3 using `stockdata'
drop if _merge ==2
drop _merge

save `tableB10', replace


//-------------------------------------------------//
//Step 7: OECD outward DI data (partners)
//-------------------------------------------------//

//we continue with outward direct investment data 
//the first step is to look at the inward DI as reported by partners of OECD countries

use "$work/OECD_COUNTERDI_INCOME_$temp", clear

rename counterpart_area ISO3
rename value2 Outward_DI_partners_OECD
keep ISO3 Outward_DI_partners_OECD

tempfile oecd2
save `oecd2', replace

//-------------------------------------------------//
//Step 8: IMF outward DI data (country)
//-------------------------------------------------//

//we continue with outward DI data as reported by the country in IMF

use "$work/IMF_fdi_credit_debitinc_$temp", clear

rename n_country country
rename _ISO ISO3

rename TotalDI_Credit Outward_DI_country_IMF
replace Outward_DI_country_IMF = Outward_DI_country_IMF/1000000	//adjust to same unit as OECD data (USD Bln)
keep country ISO3 Outward_DI_country_IMF

//fill in missing ISO codes
replace ISO3="TCA" if country == "Turks and Caicos Islands"
replace ISO3="CUW" if country == "Curaçao, Kingdom of the Netherlands"
replace ISO3="SXM" if country == "Sint Maarten, Kingdom of the Netherlands"
replace ISO3="XKO" if country == "Kosovo, Rep. of"
replace ISO3="AND" if country == "Andorra, Principality of"
replace ISO3="SSD" if country == "South Sudan, Rep. of"
replace ISO3="SRB" if country == "Serbia, Rep. of"
replace ISO3="PSE" if country == "West Bank and Gaza"


merge m:m ISO3 using `oecd2'

//fill in missing country names
replace country = "Bonaire" if ISO3=="BES"
replace country = "Cuba" if ISO3=="CUB"
replace country = "Guernsey" if ISO3=="GGY"
replace country = "Gibraltar" if ISO3=="GIB"
replace country = "Isle of Man" if ISO3=="IMN"
replace country = "Jersey" if ISO3=="JEY"
replace country = "Liechtenstein" if ISO3=="LIE"
replace country = "Samoa" if ISO3=="ASM"
replace country = "Guam" if ISO3=="GUM"
replace country = "Romania" if ISO3=="ROM"
replace country = "San Marino" if ISO3=="SMR"
replace country = "Taiwan" if ISO3=="TWN"
replace country = "British Virgin Islands" if ISO3=="VGB"


replace Outward_DI_country_IMF = 0 if Outward_DI_country_IMF==.

drop _merge
drop if ISO3==""
drop if country==""


tempfile tf1
save `tf1', replace


//special cases China and Singapore

//update Singapore value official Singapore statistics

import excel "$rawdata/Singapore", cellrange (A11:H58) firstrow clear
keep y_$temp DataSeries
destring y_$temp, replace
replace y_$temp = y_$temp /$SGP_USD
sum y_$temp if DataSeries == "Total"
local abc = r(mean)
local sgp = (2/3)*`abc'


//update China value using official Chinese BOP data

import excel "$rawdata/china-bop-1950-2022", sheet ("annual(USD)") firstrow clear
keep if ID==61
destring y_$temp, replace
sum y_$temp
local abcd = r(mean)
local chn = `abcd'*100*0.5

use `tf1', clear
replace Outward_DI_country_IMF = `sgp' if ISO3 == "SGP"
replace Outward_DI_country_IMF = `chn' if ISO3 == "CHN"

tempfile step8
save `step8', replace

//-------------------------------------------------//
//Step 9: OECD inward DI data (country)
//-------------------------------------------------//

//we continue with outward DI data as reported by the country in OECD

use "$work/OECD_DO_INCOME_$temp", clear
rename cou ISO3
rename value Outward_DI_country_OECD

merge m:m ISO3 using `step8'
drop _merge

replace Outward_DI_country_OECD = Outward_DI_country_IMF if Outward_DI_country_OECD==.
order country ISO3 Outward_DI_country_OECD Outward_DI_country_IMF Outward_DI_partners_OECD
sort country


merge 1:1 ISO3 using `tableB10', nogen

order country ISO3 group tax_haven Inward_DI_country_OECD Inward_DI_country_IMF Inward_DI_partners_OECD gap_inward missing_income DI_equity_income_surplus Outward_DI_country_OECD Outward_DI_country_IMF Outward_DI_partners_OECD

tempfile step9
save `step9', replace

//-------------------------------------------------//
//Step 10: Gap in outward DI data
//-------------------------------------------------//

// we now compute the gap in direct investment data between the outward value reported by the country and the inward value reported by the partners

gen gap_outward=.
replace gap_outward = Outward_DI_country_OECD - Outward_DI_partners_OECD

save `tableB10', replace


//-------------------------------------------------//
//Step 11: Correct gap in outward DI data
//-------------------------------------------------//


use "$work/totaldisc_DO_less_DI_$temp", clear
rename cou ISO3
rename totaldisc_DO_less_DI correction 
keep if correction <0
replace correction = -correction

merge m:m ISO3 using `tableB10'

replace correction = -gap_outward if group == "TH" & gap_outward <0 
*gen net_income = .		//we set the net FDI income gap to zero if outward gap is larger than the inward gap 
*replace net_income = missing_income - correction
*replace correction = 0 if net_income <0 & group == "TH"
*replace missing_income = 0 if net_income <0 & group == "TH"
*drop net_income
*if (net_income<0 & group == "TH") {
*	replace correction = 0 
*	replace missing_income = 0
*}
*if (-gap_outward >missing_income & group == "TH") | (gap_outward >missing_income & group == "TH") {
*	replace correction = 0 
*	replace missing_income = 0
*}
*replace correction = 0 if (-gap_outward >missing_income & group == "TH")	//jersey & co correction
*replace correction = 0 if (gap_outward >missing_income & group == "TH")		//jersey & co correction

order country ISO3 group tax_haven Inward_DI_country_OECD Inward_DI_country_IMF Inward_DI_partners_OECD gap_inward missing_income DI_equity_income_surplus Outward_DI_country_OECD Outward_DI_country_IMF Outward_DI_partners_OECD gap_outward correction 
sort group ISO3

drop _merge

save `tableB10', replace



//-------------------------------------------------//
//Step 12: allocate the residual DI income gap 
//-------------------------------------------------//

// in the final step we allocate the residual global DI income gap 

//we first take the difference between outward and inward DI from IMF

sum Inward_DI_country_IMF
local in_imf = r(sum)

sum Outward_DI_country_IMF
local out_imf = r(sum)
local calc1 = `out_imf' - `in_imf' 

//we add the income in the holdings sector which is deducted for the Netherlands 

use "$work/holdings_income_$temp", clear 

sum ROU_holdings 
local holdings = r(sum)

//we add interest inward income which was deducted in preparing income in operating units 

use "$work/interest_income_$temp", clear 

sum ROU_interest
local interest = r(sum)


// we substract missing income computed in step 5

use `tableB10', replace


sum missing_income
local missing = r(sum)

local calc2 = `calc1' + `holdings' + `interest' - `missing'

// we add corrected gap in outward DI data computed in step 11

sum correction
local correct = r(sum)

local calc3 = `calc2' + `correct'

// we substract DI equity income surplus as calculated in step 6

sum DI_equity_income_surplus
local equity = r(sum)

local residual = `calc3' - `equity'		// the value obtained is the residual DI income gap that we now allocate to tax havens

// the next step is to compute the denominator used in the reallocation

sum Inward_DI_country_IMF if group == "TH" & (ISO3!= "CUW" & ISO3!= "VGB" & ISO3!= "KNA" & ISO3!= "TCA")
local denom1 = r(sum)

sum missing_income if group == "TH" & (ISO3!= "CUW" & ISO3!= "VGB" & ISO3!= "KNA" & ISO3!= "TCA")
local denom2 = r(sum)

local denom = `denom1' + `denom2'


// reallocation of residual DI income gap

gen reallocation = . 
replace reallocation = (`residual' * (Inward_DI_country_IMF + missing_income))/`denom' if group == "TH" & (ISO3!= "CUW" & ISO3!= "VGB" & ISO3!= "KNA" & ISO3!= "TCA")



// final cleaning steps to enable further computations
replace DI_equity_income_surplus = 0 if DI_equity_income_surplus == . & group == "TH"
replace correction = 0 if correction == . & group == "TH"
replace reallocation = 0 if reallocation == . & group == "TH"



save "$work/TableB10_$temp", replace
export excel using "$root/output/Part1-profit-shifting-$temp.xlsx", firstrow(var) sheet("Table B10", replace) keepcellfmt 

// build table B10 verification table



preserve 

use "$root/verification/B10_verification", clear

replace step1 = `calc1' if year==$temp
replace step2 = `calc2' if year==$temp
replace step3 = `calc3' if year==$temp
replace residual = `residual' if year==$temp

save "$root/verification/B10_verification", replace


restore


