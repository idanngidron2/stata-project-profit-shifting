//----------------------------------
//Step 3: country-specific graphs
//----------------------------------



//generate globals: 

foreach temp in 2016 2017 2018 2019 2020 2021 2022 {

use "$work/table_C4d_`temp'", clear 

	sum revenue_loss_All_havens if ISO3!= "NHT" & ISO3 != "WLD"
	local num = r(sum)
	display `num'
	sum corptaxrev if ISO3!= "NHT" & ISO3 != "WLD"
	local den = r(sum)
	display `den'
	global revenue_loss_`temp' = `num'/`den'
}

//start graphs
clear 
global folder_name "reallocated profits" 


if $temp == 2022 {


clear 
gen year = . 
gen global_CIT_loss = . 
set obs 1
replace year = 2016 if year ==.
replace global_CIT_loss = $revenue_loss_2016 if global_CIT_loss==.
set obs 2
replace year = 2017 if year ==.
replace global_CIT_loss = $revenue_loss_2017 if global_CIT_loss==.
set obs 3
replace year = 2018 if year ==.
replace global_CIT_loss = $revenue_loss_2018 if global_CIT_loss==.
set obs 4
replace year = 2019 if year ==.
replace global_CIT_loss = $revenue_loss_2019 if global_CIT_loss==.
set obs 5
replace year = 2020 if year ==.
replace global_CIT_loss = $revenue_loss_2020 if global_CIT_loss==.
set obs 6
replace year = 2021 if year ==.
replace global_CIT_loss = $revenue_loss_2021 if global_CIT_loss==.
set obs 7
replace year = 2022 if year ==.
replace global_CIT_loss = $revenue_loss_2022 if global_CIT_loss==.

replace global_CIT_loss = global_CIT_loss *100

 graph bar global_CIT_loss, over (year) blabel(total)  ///
	title("Global average loss as a share of CIT revenue, 2016-2022") ///
	ytitle("% of CIT revenue")				///

	 graph save average_loss, replace
 graph export "$root/figures/$folder_name/average_loss.png", replace 





cd "$work"


use "table_C4_2016", clear
keep ISO3 All_havens country
rename All_havens All_havens_2016

merge 1:1 ISO3 country using "table_C4_2017", nogen
keep ISO3 country All_havens_2016 All_havens 
rename All_havens All_havens_2017

merge 1:1 ISO3 country using "table_C4_2018", nogen
keep ISO3 country All_havens_2016 All_havens All_havens_2017  
rename All_havens All_havens_2018

merge 1:1 ISO3 country using "table_C4_2019", nogen
keep ISO3 country All_havens_2016 All_havens_2017  All_havens_2018 All_havens  
rename All_havens All_havens_2019

merge 1:1 ISO3 country using "table_C4_2020", nogen
keep ISO3 country All_havens_2016 All_havens_2017 All_havens_2018 All_havens_2019 All_havens 
rename All_havens All_havens_2020

merge 1:1 ISO3 country using "table_C4_2021", nogen
keep ISO3 country All_havens_2016 All_havens_2017 All_havens_2018 All_havens_2019  All_havens_2020 All_havens 
rename All_havens All_havens_2021

merge 1:1 ISO3 country using "table_C4_2022", nogen
keep ISO3 country All_havens_2016 All_havens_2017 All_havens_2018 All_havens_2019  All_havens_2020 All_havens All_havens_2021
rename All_havens All_havens_2022



reshape long All_havens_, i(ISO3 country) j(year)
rename All_havens_ All_havens
replace All_havens = All_havens/1000	//from USD million to billion
//create country-specific graphs

cd "$root/figures/reallocated profits"
preserve 
keep if ISO3 == "USA" 	//United States
 graph bar All_havens, over (year)	nodraw ///
	title("United States") ///
	ytitle("USD Bln")				///

 graph save USA, replace 
restore
 

preserve 
keep if ISO3 == "GBR" 	//United Kingdom
 graph bar All_havens, over (year)	nodraw ///
	title("United Kingdom") ///
	ytitle("USD Bln")				///

 graph save GBR, replace
restore
 
 
 preserve 
keep if ISO3 == "NHT" 	//non-haven total
 graph bar All_havens, over (year) nodraw 	///
	title("Non-havens total") ///
	ytitle("USD Bln")				///

 graph save NHT, replace
restore
 
 
 preserve 
keep if ISO3 == "DEU" 	//Germany
 graph bar All_havens, over (year)	nodraw ///
	title("Germany") ///
	ytitle("USD Bln")				///

 graph save DEU, replace
restore
 
 
 preserve 
keep if ISO3 == "CHN" 	//China, P.R.: Mainland
 graph bar All_havens, over (year)	nodraw ///
	title("China, P.R.: Mainland") ///
	ytitle("USD Bln")				///

 graph save CHN, replace
restore
 
 
 preserve 
keep if ISO3 == "FRA" 	//France
 graph bar All_havens, over (year)	nodraw ///
	title("France") ///
	ytitle("USD Bln")				///

 graph save FRA, replace
restore
 
 
 preserve 
keep if ISO3 == "ITA" 	//Italy
 graph bar All_havens, over (year)	nodraw ///
	title("Italy") ///
	ytitle("USD Bln")				///

 graph save ITA, replace
restore
 
 preserve 
keep if ISO3 == "HUN" 	//Hungary
 graph bar All_havens, over (year)	nodraw ///
	title("Hungary") ///
	ytitle("USD Bln")				///

 graph save HUN, replace
restore
 

preserve 
keep if ISO3 == "AUS" 	//Australia
 graph bar All_havens, over (year)	nodraw ///
	title("Australia") ///
	ytitle("USD Bln")				///

 graph save AUS, replace
restore
 
 
 preserve 
keep if ISO3 == "ESP" 	//Spain
 graph bar All_havens, over (year)	nodraw ///
	title("Spain") ///
	ytitle("USD Bln")				///

 graph save ESP, replace
restore
 
 
 preserve 
keep if ISO3 == "CAN" 	//Canada
 graph bar All_havens, over (year)	nodraw ///
	title("Canada") ///
	ytitle("USD Bln")				///

 graph save CAN, replace
restore
 
 
 preserve 
keep if ISO3 == "BRA" 	//Brazil
 graph bar All_havens, over (year)	nodraw ///
	title("Brazil") ///
	ytitle("USD Bln")				///

 graph save BRA, replace
restore
 
 
 preserve 
keep if ISO3 == "IND" 	//India
 graph bar All_havens, over (year)	nodraw ///
	title("India") ///
	ytitle("USD Bln")				///

 graph save IND, replace
restore
 
 
 preserve 
keep if ISO3 == "RUS" 	//Russian Federation
 graph bar All_havens, over (year)	nodraw ///
	title("Russian Federation") ///
	ytitle("USD Bln")				///

 graph save RUS, replace
restore
 /*
  preserve 
keep if ISO3 == "PAN" 	//Panama
 graph bar shifted_profits, over (year)	nodraw ///
	title("Panama") ///
	ytitle("USD Bln")				///

 graph save PAN, replace
restore
 

 preserve 
keep if ISO3 == "CYP" 	//Cyprus
 graph bar shifted_profits, over (year)	nodraw ///
	title("Cyprus") ///
	ytitle("USD Bln")				///

 graph save CYP, replace
restore
 
 
 preserve 
keep if ISO3 == "LBN" 	//Lebanon
 graph bar shifted_profits, over (year)	nodraw ///
	title("Lebanon") ///
	ytitle("USD Bln")				///

 graph save LBN, replace
restore
 
  preserve 
keep if ISO3 == "BHR" 	//Bahrain
 graph bar shifted_profits, over (year)	nodraw ///
	title("Bahrain") ///
	ytitle("USD Bln")				///

 graph save BHR, replace
restore

  preserve 
keep if ISO3 == "BHS" 	//Bahamas
 graph bar shifted_profits, over (year)	nodraw ///
	title("Bahamas") ///
	ytitle("USD Bln")				///

 graph save BHS, replace
restore

  preserve 
keep if ISO3 == "BRB" 	//Barbados
 graph bar shifted_profits, over (year)	nodraw ///
	title("Barbados") ///
	ytitle("USD Bln")				///

 graph save BRB, replace
restore

  preserve 
keep if ISO3 == "WLD" 	//World
 graph bar shifted_profits, over (year)	nodraw ///
	title("World") ///
	ytitle("USD Bln")				///

 graph save WLD, replace
restore


 */
 
 
 
 preserve	//top 12 tax havens
  graph combine "NHT" "USA" "GBR" "CHN" "DEU" "BRA" "AUS" "FRA" "ITA" "IND" "CAN" "RUS", cols(4) 
  


 graph save top, replace
  graph export "$root/figures/$folder_name/2016-2022 top12 losers.png", replace 

restore
/*
preserve	//other tax havens
  graph combine "BHR" "LBN" "CYP" "JEY" "MAC" "CUW" "BRB" "VGB" "BMU" "PAN" "CYM" "BHS", cols(4) 
 graph save other, replace
  graph export "$root/figures/$folder_name/2016-2021 other tax havens.png", replace 

restore
*/

preserve    
keep if ISO3 == "NHT" 	//non-haven total
 graph bar All_havens, over (year) blabel(total) ///
	title("Global profit shifting losses 2016-2022") ///
	ytitle("USD Bln")				///

	 graph save WLD, replace
 graph export "$root/figures/$folder_name/2016-2022 World loss.png", replace 

restore
 

 
 
}