*Set year Macros

forval i = 2015/2020 {
	
global temp = `i'

***Import values for ROW revenue loss as a share of CIT collected***

cd "C:\Users\i.gidron\Dropbox\EUTO\09. Global Data Repository\02. Repository\Profit Shifting\preliminary_results\finalise results Atlas launch"
use "PS_results_for_Atlas", clear

sum value if iso3=="ROW" & year==$temp & indicator=="corp_tax_lost" & counterpart =="World" 
local world_ROW_$temp = r(mean)
display `world_ROW_$temp'

sum value if iso3=="ROW" & year==$temp & indicator=="corp_tax_lost" & counterpart =="EU_Havens" 
local EU_ROW_$temp = r(mean)
display `EU_ROW_$temp'

sum value if iso3=="ROW" & year==$temp & indicator=="corp_tax_lost" & counterpart =="Non_EU_Havens" 
local nonEU_ROW_$temp = r(mean)

***Import values for ROW total profits shifted***
sum value if iso3=="ROW" & year==$temp & indicator=="profits_shifted" & counterpart=="World" 
local world_ROW_profits_$temp = r(mean)
display `world_ROW_profits_$temp'

sum value if iso3=="ROW" & year==$temp & indicator=="profits_shifted" & counterpart=="EU_Havens" 
local EU_ROW_profits_$temp = r(mean)

sum value if iso3=="ROW" & year==$temp & indicator=="profits_shifted" & counterpart=="Non_EU_Havens" 
local nonEU_ROW_profits_$temp = r(mean)


***Import structure***

cd "C:\Users\i.gidron\Dropbox\EUTO\09. Global Data Repository\02. Repository\Profit Shifting\TWZ2020Programs\ZW_instructions\output"

use "Table B10 2016", clear

keep code country country_group

tempfile tf1
save `tf1', replace

***Import corp tax rev and STRs***

cd "C:\Users\i.gidron\Dropbox\EUTO\09. Global Data Repository\02. Repository\Profit Shifting\TWZ2020Programs\ZW_instructions"

import excel "RawData$temp", sheet ("globaltaxrev") cellrange (A2:B170) firstrow clear
rename iso code
destring corptaxrev, replace

tempfile tf2
save `tf2', replace

use `tf1', clear
merge m:m code using `tf2', nogen
replace country="Uzbekistan" if code == "UZB"
replace country="Serbia" if code == "SRB"
replace country="Swaziland" if code == "SWZ"
replace country= "Sri Lanka" if code == "LKA"
replace country="Turkmenistan" if code == "TKM"
replace country_group="other" if code=="UZB"|code=="SRB"| code == "SWZ"| code == "LKA"| code == "TKM"

save `tf1', replace

import excel "RawData$temp", sheet ("Data C 2,4") cellrange (A1:I184) firstrow clear
keep LOCATION y_$temp
rename LOCATION country
rename y_$temp Corporate_tax_rate
replace country="Afghanistan, Islamic Republic of" if country=="Afghanistan"
replace country="Armenia, Republic of" if country=="Armenia"
replace country="Azerbaijan, Republic of" if country=="Azerbaijan"
replace country="Congo, Republic of" if country=="Congo"
replace country="Congo, Democratic Republic of" if country=="Congo (Democratic Republic of the)"
replace country="Gambia, The" if country=="Gambia"
replace country="Cote d'Ivoire" if country=="Ivory Coast"
replace country="Macedonia, FYR" if country=="Macedonia"
replace country="Syrian Arab Republic" if country=="Syria"
 

save `tf2', replace

use `tf1', clear
merge m:m country using `tf2', nogen

keep if country_group=="other"
drop if corptaxrev ==.| Corporate_tax_rate==.

*Remove countries for which we already have data

drop if code == "ARG"|code=="EGY" | code=="URY"|code=="THA"|code=="IDN"| code=="MYS"|code=="NGA"| code=="VEN"	//already have data
drop if code=="SAU" 	//no corptaxrevenue data

*GENERATE VARIABLES OF INTEREST


gen year = $temp

**Corporate tax loss as a % of total corporate tax revenue collected

gen World_corp_tax_lost = .
replace World_corp_tax_lost = `world_ROW_$temp'
gen EU_corp_tax_lost = .
replace EU_corp_tax_lost = `EU_ROW_$temp'
gen nonEU_corp_tax_lost = .
replace nonEU_corp_tax_lost = `nonEU_ROW_$temp'


**Tax revenue lost

gen World_tax_lost = .
replace World_tax_lost= World_corp_tax_lost*corptaxrev

gen EU_tax_lost = .
replace EU_tax_lost = EU_corp_tax_lost*corptaxrev

gen nonEU_tax_lost =.
replace nonEU_tax_lost = nonEU_corp_tax_lost*corptaxrev

**Profits shifted

*1) generate the total profits shifted should these countries have had tax loss = STR * profits shifted

gen World_profits_shifted_2 =.
replace World_profits_shifted_2= World_tax_lost/(Corporate_tax_rate/100)

sum World_profits_shifted_2
local World_total_profits = r(sum)
display `World_total_profits'

gen EU_profits_shifted_2 =.
replace EU_profits_shifted_2= EU_tax_lost/(Corporate_tax_rate/100)

sum EU_profits_shifted_2
local EU_total_profits = r(sum)
display `EU_total_profits'
gen nonEU_profits_shifted_2 =.
replace nonEU_profits_shifted_2= nonEU_tax_lost/(Corporate_tax_rate/100)

sum nonEU_profits_shifted_2
local nonEU_total_profits = r(sum)
display `nonEU_total_profits'

*2) generate weights as the share of each country to the total profits shifted

gen World_weights=.
replace World_weights=World_profits_shifted_2/`World_total_profits' 

gen EU_weights=.
replace EU_weights=EU_profits_shifted_2/`EU_total_profits' 

gen nonEU_weights=.
replace nonEU_weights=nonEU_profits_shifted_2/`nonEU_total_profits' 


*3) compute profits shifted using weights and ROW value for the given year
gen World_profits_shifted =.
replace World_profits_shifted = World_weights * `world_ROW_profits_$temp'
drop World_profits_shifted_2

gen EU_profits_shifted =.
replace EU_profits_shifted = EU_weights * `EU_ROW_profits_$temp'
drop EU_profits_shifted_2

gen nonEU_profits_shifted =.
replace nonEU_profits_shifted = nonEU_weights * `nonEU_ROW_profits_$temp'
drop nonEU_profits_shifted_2


rename code iso3
rename corptaxrev CIT_rev

cd "C:\Users\i.gidron\Dropbox\EUTO\09. Global Data Repository\02. Repository\Profit Shifting\preliminary_results\finalise results Atlas launch"
save "ROW_results_temp_$temp", replace

*---------------------------------
*PART 2: ARRANGE RESULTS FOR ATLAS
*---------------------------------
tempfile tf3
save `tf3', replace

*Counterpart = World

use `tf3', clear
gen counterpart = "World"
keep iso3 World_profits_shifted year counterpart country_group CIT_rev
gen indicator = "profits_shifted"
rename World_profits_shifted value

tempfile world_profits_shifted$temp
save `world_profits_shifted$temp', replace

use `tf3', clear
gen counterpart = "World"
keep iso3 World_tax_lost year counterpart country_group CIT_rev
gen indicator = "tax_lost"
rename World_tax_lost value

tempfile world_tax_lost$temp
save `world_tax_lost$temp', replace

use `tf3', clear
gen counterpart = "World"
keep iso3 World_corp_tax_lost year counterpart country_group CIT_rev
gen indicator = "corp_tax_lost"
rename World_corp_tax_lost value

tempfile world_share_CIT_loss$temp
save `world_share_CIT_loss$temp', replace

use `world_profits_shifted$temp', clear
append using `world_share_CIT_loss$temp'
append using `world_tax_lost$temp'
tempfile world$temp 
save `world$temp', replace

*Counterpart = EU havens

use `tf3', clear
gen counterpart = "EU_Havens"
keep iso3 EU_profits_shifted year counterpart country_group CIT_rev
gen indicator = "profits_shifted"
rename EU_profits_shifted value

tempfile EU_profits_shifted$temp
save `EU_profits_shifted$temp', replace

use `tf3', clear
gen counterpart = "EU_Havens"
keep iso3 EU_tax_lost year counterpart country_group CIT_rev
gen indicator = "tax_lost"
rename EU_tax_lost value

tempfile EU_tax_lost$temp
save `EU_tax_lost$temp', replace

use `tf3', clear
gen counterpart = "EU_Havens"
keep iso3 EU_corp_tax_lost year counterpart country_group CIT_rev
gen indicator = "corp_tax_lost"
rename EU_corp_tax_lost value

tempfile EU_share_CIT_loss$temp
save `EU_share_CIT_loss$temp', replace

use `EU_profits_shifted$temp', clear
append using `EU_share_CIT_loss$temp'
append using `EU_tax_lost$temp'
tempfile EU$temp 
save `EU$temp', replace

*Counterpart = Non-EU havens

use `tf3', clear
gen counterpart = "Non_EU_Havens"
keep iso3 nonEU_profits_shifted year counterpart country_group CIT_rev
gen indicator = "profits_shifted"
rename nonEU_profits_shifted value

tempfile NonEU_profits_shifted$temp
save `NonEU_profits_shifted$temp', replace

use `tf3', clear
gen counterpart = "Non_EU_Havens"
keep iso3 nonEU_tax_lost year counterpart country_group CIT_rev
gen indicator = "tax_lost"
rename nonEU_tax_lost value

tempfile NonEU_tax_lost$temp
save `NonEU_tax_lost$temp', replace

use `tf3', clear
gen counterpart = "Non_EU_Havens"
keep iso3 nonEU_corp_tax_lost year counterpart country_group CIT_rev
gen indicator = "corp_tax_lost"
rename nonEU_corp_tax_lost value

tempfile NonEU_share_CIT_loss$temp
save `NonEU_share_CIT_loss$temp', replace

use `NonEU_profits_shifted$temp', clear
append using `NonEU_share_CIT_loss$temp'
append using `NonEU_tax_lost$temp'
tempfile NonEU$temp 
save `NonEU$temp', replace

*Combine Losers
use `world$temp', clear
append using `EU$temp'
append using `NonEU$temp'

cd "C:\Users\i.gidron\Dropbox\EUTO\09. Global Data Repository\02. Repository\Profit Shifting\preliminary_results\finalise results Atlas launch"
save "ROW_results_$temp", replace

}

*combine all years into one file

use "ROW_results_2015", clear

forval i = 2016/2020 {
	
	append using "ROW_results_`i'"
	
}
sort year indicator counterpart iso3
drop country_group
save "ROW_results_ALL", replace


*Append into PS results for Atlas

use "PS_results_for_Atlas", clear
append using "ROW_results_ALL"
sort year indicator counterpart iso3
export excel "PS_results_for_download_data_atlas", replace firstrow(var) keepcellfmt


replace value = 0 if iso3=="ROW"
save "PS_results_for_Atlas_with_ROW", replace
export excel "PS_results_for_atlas_with_ROW", replace firstrow(var) keepcellfmt



