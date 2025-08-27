//----------------------------------------
//Graphs do file
//----------------------------------------

//prepares graphical output per year for variables of interest

//----------------------------------
//Step 1: top 10 tax haven winners
//----------------------------------

cd "$work"

*global folder_name "NLD_offshore_funds=0"
global folder_name "standard"

use "shifted_profits_U1_$temp", clear

sum shifted_profits if country=="World"
local wld_tot = r(mean)
gen wld_tot =.
replace wld_tot = `wld_tot'
replace wld_tot = round(wld_tot, 1)
sum wld_tot if country == "World"
local wld_tot2 = r(sum)

display `wld_tot2'

sum pre_tax_foreign_profits if country=="World"
local denom = r(mean)

local rratio = (`wld_tot'/`denom')*100
gen rratio = `rratio'
replace rratio = round(rratio, 1) 
sum rratio if country == "World"
local rratio2 = r(sum)

display `rratio2'

keep if tax_haven == 1 
*keep ISO3 shifted_profits 


// Sort the dataset in descending order based on the variable of interest
gsort -shifted_profits
egen rank = rank(-shifted_profits)
keep if rank<=10
sort rank
sum shifted_profits if rank==1
local top = r(mean)
drop rank
replace country = "Hong Kong" if ISO3 == "HKG"
replace country = "The Netherlands" if ISO3 == "NLD"
replace country = "Virgin Islands (GBR)" if ISO3 == "VGB"

 graph bar (mean) shifted_profits, over(country, label(labsize(1.6)) sort(shifted_profits) descending)  ///
	title("Profits shifted by country $temp") ///
	subtitle("list of top 10 tax havens")		///
	ytitle("USD Bln")				///
	text (`top' 90					///
	"world total: `wld_tot2' USD bln"		///
	"i.e. `rratio2'% of foreign profits", size(small)) ///
	bar(1, color(orange))            ///
	bar(2, color(orange*0.9))        ///
	bar(3, fcolor(blue*0.8) lw(none))       ///
	bar(4, fcolor(blue*0.7) lw(none))       ///
	bar(5, fcolor(blue*0.6) lw(none))       ///
	bar(6, fcolor(blue*0.5) lw(none))       ///
	bar(7, fcolor(blue*0.4) lw(none))       ///
	bar(8, fcolor(blue*0.3) lw(none))       ///
	bar(9, fcolor(blue*0.2) lw(none))       ///
	bar(10, fcolor(blue*0.1) lw(none))       ///

		
 * name(somegraph, replace)
  
//no title graph
  
*  xlabel("world: `wld_tot2' USD bln; `rratio2'% of foreign profits")
 
 graph save graph1, replace
 graph export "$root/figures/$folder_name/top-10-$temp.png", replace 
 
  graph bar (mean) shifted_profits, over(country, label(angle(45) labsize(2.5)) sort(shifted_profits) descending)  ///
	ytitle("USD Bln")				///
	bar(1, color(orange))            ///
	bar(2, color(orange*0.9))        ///
	bar(3, fcolor(blue*0.8) lw(none))       ///
	bar(4, fcolor(blue*0.7) lw(none))       ///
	bar(5, fcolor(blue*0.6) lw(none))       ///
	bar(6, fcolor(blue*0.5) lw(none))       ///
	bar(7, fcolor(blue*0.4) lw(none))       ///
	bar(8, fcolor(blue*0.3) lw(none))       ///
	bar(9, fcolor(blue*0.2) lw(none))       ///
	bar(10, fcolor(blue*0.1) lw(none))       ///

		
 * name(somegraph, replace)
  

  
*  xlabel("world: `wld_tot2' USD bln; `rratio2'% of foreign profits")
 
 graph save graph3, replace
 graph export "$root/figures/$folder_name/no-title-top-10-$temp.png", replace 
 
 
//----------------------------------
//Step 2: top 15 tax haven winners
//----------------------------------

cd "$work"


use "shifted_profits_U1_$temp", clear

sum shifted_profits if country=="World"
local wld_tot = r(mean)
gen wld_tot =.
replace wld_tot = `wld_tot'
replace wld_tot = round(wld_tot, 1)
sum wld_tot if country == "World"
local wld_tot2 = r(sum)

display `wld_tot2'

sum pre_tax_foreign_profits if country=="World"
local denom = r(mean)

local rratio = (`wld_tot'/`denom')*100
gen rratio = `rratio'
replace rratio = round(rratio, 1) 
sum rratio if country == "World"
local rratio2 = r(sum)

display `rratio2'

keep if tax_haven == 1 
*keep ISO3 shifted_profits 


// Sort the dataset in descending order based on the variable of interest
gsort -shifted_profits
egen rank = rank(-shifted_profits)
keep if rank<=15
sort rank
sum shifted_profits if rank==1
local top = r(mean)
drop rank
replace country = "Hong Kong" if ISO3 == "HKG"
replace country = "The Netherlands" if ISO3 == "NLD"
replace country = "Virgin Islands (GBR)" if ISO3 == "VGB"

 graph bar (mean) shifted_profits, over(ISO3, label(labsize(1.6)) sort(shifted_profits) descending)  ///
	title("Profits shifted by country $temp") ///
	subtitle("list of top 15 tax havens")		///
	ytitle("USD Bln")				///
	text (`top' 90					///
	"world total: `wld_tot2' USD bln"		///
	"i.e. `rratio2'% of foreign profits", size(small)) ///
	bar(1, color(orange))            ///
	bar(2, color(orange*0.9))        ///
	bar(3, fcolor(blue*0.8) lw(none))       ///
	bar(4, fcolor(blue*0.7) lw(none))       ///
	bar(5, fcolor(blue*0.6) lw(none))       ///
	bar(6, fcolor(blue*0.5) lw(none))       ///
	bar(7, fcolor(blue*0.4) lw(none))       ///
	bar(8, fcolor(blue*0.3) lw(none))       ///
	bar(9, fcolor(blue*0.2) lw(none))       ///
	bar(10, fcolor(blue*0.1) lw(none))       ///

 graph save graph2, replace
		
 graph export "$root/figures/$folder_name/top-15-$temp.png", replace 
 
 
 //no title graph

  graph bar (mean) shifted_profits, over(ISO3,  label(angle(45) labsize(2.5)) sort(shifted_profits) descending)  ///
	ytitle("USD Bln")				///
	bar(1, color(orange))            ///
	bar(2, color(orange*0.9))        ///
	bar(3, fcolor(blue*0.8) lw(none))       ///
	bar(4, fcolor(blue*0.7) lw(none))       ///
	bar(5, fcolor(blue*0.6) lw(none))       ///
	bar(6, fcolor(blue*0.5) lw(none))       ///
	bar(7, fcolor(blue*0.4) lw(none))       ///
	bar(8, fcolor(blue*0.3) lw(none))       ///
	bar(9, fcolor(blue*0.2) lw(none))       ///
	bar(10, fcolor(blue*0.1) lw(none))       ///

 graph save graph4, replace
		
 graph export "$root/figures/$folder_name/no-title-top-15-$temp.png", replace 



 
 
//----------------------------------
//Step 3: country-specific graphs
//----------------------------------

if $temp >= 2022 {

cd "$work"


use "shifted_profits_U1_2016", clear
keep ISO3 shifted_profits country
rename shifted_profits shifted_profits_2016

merge 1:1 ISO3 country using "shifted_profits_U1_2017", nogen
keep ISO3 country shifted_profits_2016 shifted_profits 
rename shifted_profits shifted_profits_2017

merge 1:1 ISO3 country using "shifted_profits_U1_2018", nogen
keep ISO3 country shifted_profits_2016 shifted_profits_2017 shifted_profits 
rename shifted_profits shifted_profits_2018

merge 1:1 ISO3 country using "shifted_profits_U1_2019", nogen
keep ISO3 country shifted_profits_2016 shifted_profits_2017 shifted_profits_2018 shifted_profits
rename shifted_profits shifted_profits_2019

merge 1:1 ISO3 country using "shifted_profits_U1_2020", nogen
keep ISO3 country shifted_profits_2016 shifted_profits_2017 shifted_profits_2018 shifted_profits_2019 shifted_profits 
rename shifted_profits shifted_profits_2020

merge 1:1 ISO3 country using "shifted_profits_U1_2021", nogen
keep ISO3 country shifted_profits_2016 shifted_profits_2017 shifted_profits_2018 shifted_profits_2019 shifted_profits_2020 shifted_profits 
rename shifted_profits shifted_profits_2021

merge 1:1 ISO3 country using "shifted_profits_U1_2022", nogen
keep ISO3 country shifted_profits_2016 shifted_profits_2017 shifted_profits_2018 shifted_profits_2019 shifted_profits_2020 shifted_profits_2021 shifted_profits 
rename shifted_profits shifted_profits_2022

reshape long shifted_profits_, i(ISO3 country) j(year)

//create country-specific graphs

cd "$root/figures/data"

preserve 
keep if ISO3 == "IRL" 	//Ireland
 graph bar shifted_profits, over (year)	nodraw ///
	title("Ireland") ///
	ytitle("USD Bln")				///
	bar(1, color(orange))            ///
	
graph save IRL, replace 
restore



preserve 
keep if ISO3 == "NLD" 	//Netherlands
 graph bar shifted_profits, over (year)	nodraw ///
	title("Netherlands") ///
	ytitle("USD Bln")				///
	bar(1, color(orange))            ///

 graph save NLD, replace
restore
 
 
 preserve 
keep if ISO3 == "CHE" 	//Switzerland
 graph bar shifted_profits, over (year) nodraw 	///
	title("Switzerland") ///
	ytitle("USD Bln")				///
	bar(1, color(orange))            ///

 graph save CHE, replace
restore
 
 
 preserve 
keep if ISO3 == "LUX" 	//Luxembourg
 graph bar shifted_profits, over (year)	nodraw ///
	title("Luxembourg") ///
	ytitle("USD Bln")				///
	bar(1, color(orange))            ///

 graph save LUX, replace
restore
 
 
 preserve 
keep if ISO3 == "BEL" 	//Belgium
 graph bar shifted_profits, over (year)	nodraw ///
	title("Belgium") ///
	ytitle("USD Bln")				///
	bar(1, color(orange))            ///

 graph save BEL, replace
restore
 
 
 preserve 
keep if ISO3 == "HKG" 	//Hong Kong
 graph bar shifted_profits, over (year)	nodraw ///
	title("Hong Kong") ///
	ytitle("USD Bln")				///
	bar(1, color(orange))            ///

 graph save HKG, replace
restore
 
 
 preserve 
keep if ISO3 == "SGP" 	//Singapore
 graph bar shifted_profits, over (year)	nodraw ///
	title("Singapore") ///
	ytitle("USD Bln")				///
	bar(1, color(orange))            ///

 graph save SGP, replace
restore
 
 preserve 
keep if ISO3 == "PRI" 	//Puerto Rico
 graph bar shifted_profits, over (year)	nodraw ///
	title("Puerto Rico") ///
	ytitle("USD Bln")				///
	bar(1, color(orange))            ///

 graph save PRI, replace
restore
 

preserve 
keep if ISO3 == "BMU" 	//Bermuda
 graph bar shifted_profits, over (year)	nodraw ///
	title("Bermuda") ///
	ytitle("USD Bln")				///
	bar(1, color(orange))            ///

 graph save BMU, replace
restore
 
 
 preserve 
keep if ISO3 == "VGB" 	//British Virgin Islands
 graph bar shifted_profits, over (year)	nodraw ///
	title("British Virgin Islands") ///
	ytitle("USD Bln")				///
	bar(1, color(orange))            ///

 graph save VGB, replace
restore
 
 
 preserve 
keep if ISO3 == "CYM" 	//Cayman Islands
 graph bar shifted_profits, over (year)	nodraw ///
	title("Cayman Islands") ///
	ytitle("USD Bln")				///
	bar(1, color(orange))            ///

 graph save CYM, replace
restore
 
 
 preserve 
keep if ISO3 == "CUW" 	//Curacao
 graph bar shifted_profits, over (year)	nodraw ///
	title("Curacao") ///
	ytitle("USD Bln")				///
	bar(1, color(orange))            ///

 graph save CUW, replace
restore
 
 
 preserve 
keep if ISO3 == "MAC" 	//Macao
 graph bar shifted_profits, over (year)	nodraw ///
	title("Macao") ///
	ytitle("USD Bln")				///
	bar(1, color(orange))            ///

 graph save MAC, replace
restore
 
 
 preserve 
keep if ISO3 == "JEY" 	//Jersey
 graph bar shifted_profits, over (year)	nodraw ///
	title("Jersey") ///
	ytitle("USD Bln")				///
	bar(1, color(orange))            ///

 graph save JEY, replace
restore
 
  preserve 
keep if ISO3 == "PAN" 	//Panama
 graph bar shifted_profits, over (year)	nodraw ///
	title("Panama") ///
	ytitle("USD Bln")				///
	bar(1, color(orange))            ///

 graph save PAN, replace
restore
 

 preserve 
keep if ISO3 == "CYP" 	//Cyprus
 graph bar shifted_profits, over (year)	nodraw ///
	title("Cyprus") ///
	ytitle("USD Bln")				///
	bar(1, color(orange))            ///

 graph save CYP, replace
restore
 
 
 preserve 
keep if ISO3 == "LBN" 	//Lebanon
 graph bar shifted_profits, over (year)	nodraw ///
	title("Lebanon") ///
	ytitle("USD Bln")				///
	bar(1, color(orange))            ///

 graph save LBN, replace
restore
 
  preserve 
keep if ISO3 == "BHR" 	//Bahrain
 graph bar shifted_profits, over (year)	nodraw ///
	title("Bahrain") ///
	ytitle("USD Bln")				///
	bar(1, color(orange))            ///

 graph save BHR, replace
restore

  preserve 
keep if ISO3 == "BHS" 	//Bahamas
 graph bar shifted_profits, over (year)	nodraw ///
	title("Bahamas") ///
	ytitle("USD Bln")				///
	bar(1, color(orange))            ///

 graph save BHS, replace
restore

  preserve 
keep if ISO3 == "BRB" 	//Barbados
 graph bar shifted_profits, over (year)	nodraw ///
	title("Barbados") ///
	ytitle("USD Bln")				///
	bar(1, color(orange))            ///

 graph save BRB, replace
restore

  preserve 
keep if ISO3 == "WLD" 	//World
 graph bar shifted_profits, over (year)	nodraw ///
	title("Tax havens total") ///
	ytitle("USD Bln")				///
	bar(1, color(orange))            ///

 graph save WLD, replace
restore


 
 
 
 
 preserve	//top 12 tax havens
  graph combine "WLD" "IRL" "NLD" "CHE" "LUX" "BEL" "HKG" "SGP" "VGB" "BMU" "PRI" "CYM", cols(4) 
  


 graph save top, replace
  graph export "$root/figures/$folder_name/2016-2022 top12.png", replace 

restore

preserve	//other tax havens
  graph combine "BHR" "LBN" "CYP" "JEY" "MAC" "CUW" "BRB" "VGB" "BMU" "PAN" "CYM" "BHS", cols(4) 
 graph save other, replace
  graph export "$root/figures/$folder_name/2016-2022 other tax havens.png", replace 

restore
*/

preserve    
keep if ISO3 == "WLD" 	//World

graph bar shifted_profits, over(year, label(labsize(small))) blabel(total) ///
    ytitle("USD Bln", size(small)) ///
    ylabel(, labsize(small)) ///
    bar(1, color(orange))
	
	graph save WLD, replace
graph export "$root/figures/$folder_name/2016-2022 World.png", replace 

restore


//---------------------------------------------------------
//graph reporting DI income invested from USA to Ireland
//---------------------------------------------------------

import delimited "$rawdata/OECD_BOP_2025_update.csv", clear  

rename time_period year
replace obs_value = 0 if obs_value ==.

rename ref_area cou 
rename counterpart_area partner 
keep if cou == "IRL"| cou =="USA"
keep if (cou == "IRL" & partner == "USA" & & measure_principle == "DI") | (cou == "USA" & partner == "IRL" & measure_principle == "DO")


replace obs_value = round(obs_value,1)
//Graph for USA & IRL combined
/*
 graph bar obs_value, over(year) over(cou) blabel(bar, format(%12.0gc)) ///
    title("Inward income from USA reported by Ireland (2015-2023)", size(medium)) ///
    subtitle("OECD FDI data, table BMD4", size(small)) ///
    ytitle("USD Million", size(small)) ylabel(, format(%12.0gc)) ///
    bar(1, color(orange_red%80))  ///
    legend(off) 
*/
//Graph showing only IRL inward data

drop if cou == "USA"

//graph with title
/*
 graph bar obs_value, over(year) blabel(bar, format(%12.0gc)) ///
    title("Inward income from USA reported by Ireland (2015-2023)", size(medium)) ///
    subtitle("OECD FDI data, table BMD4", size(small)) ///
    ytitle("USD Million", size(small)) ylabel(, format(%12.0gc)) ///
    bar(1, color(orange_red%80))  ///
    legend(off)
*/

//graph without title
	graph bar obs_value, over(year, label(angle(45) labsize(small))) /// 
    blabel(bar, format(%12.0gc) size(vsmall) color(black)) /// 
    ytitle("USD Million", size(small)) ylabel(, format(%12.0gc) grid) /// 
    bar(1, color(orange_red%80) lcolor(black) lwidth(medium)) /// 
    legend(off)


graph save reported_DI_IRL_USA, replace
graph export "$root/figures/$folder_name/reported_DI_IRL_USA.png", replace width(1000) height(700)



 */
//----------------------------------
//Step 4: Global tax revenue losses
//----------------------------------

//import table C4d tax losses for each year and save the estimate in local

use "$work/table_C4d_2016.dta", clear
sum revenue_loss_All_havens
global loss_2016 = r(sum)

use "$work/table_C4d_2017.dta", clear
sum revenue_loss_All_havens
global loss_2017 = r(sum)

use "$work/table_C4d_2018.dta", clear
sum revenue_loss_All_havens
global loss_2018 = r(sum)

use "$work/table_C4d_2019.dta", clear
sum revenue_loss_All_havens
global loss_2019 = r(sum)

use "$work/table_C4d_2020.dta", clear
sum revenue_loss_All_havens
global loss_2020 = r(sum)

use "$work/table_C4d_2021.dta", clear
sum revenue_loss_All_havens
global loss_2021 = r(sum)

use "$work/table_C4d_2022.dta", clear
sum revenue_loss_All_havens
global loss_2022 = r(sum)

clear 
gen year = . 
gen global_CIT_loss = . 
set obs 1
replace year = 2016 if year ==.
replace global_CIT_loss = $loss_2016 if global_CIT_loss==.
set obs 2
replace year = 2017 if year ==.
replace global_CIT_loss = $loss_2017 if global_CIT_loss==.
set obs 3
replace year = 2018 if year ==.
replace global_CIT_loss = $loss_2018 if global_CIT_loss==.
set obs 4
replace year = 2019 if year ==.
replace global_CIT_loss = $loss_2019 if global_CIT_loss==.
set obs 5
replace year = 2020 if year ==.
replace global_CIT_loss = $loss_2020 if global_CIT_loss==.
set obs 6
replace year = 2021 if year ==.
replace global_CIT_loss = $loss_2021 if global_CIT_loss==.
set obs 7
replace year = 2022 if year ==.
replace global_CIT_loss = $loss_2022 if global_CIT_loss==.

replace global_CIT_loss = global_CIT_loss/1000

replace global_CIT_loss = round(global_CIT_loss)

graph bar global_CIT_loss, over(year, label(labsize(small))) blabel(total) ///
    ytitle("USD Bln", size(small)) ///
    ylabel(, labsize(small))

	graph save global_loss, replace
 graph export "$root/figures/$folder_name/global_tax_loss.png", replace 




}