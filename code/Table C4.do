//-----------------------------------------------
//Table C4: Computes reallocated profits 
//-----------------------------------------------

//Table C4 has two components, one reallocates profits to source countries 
//the second computes the ultimate ownership of profits shifted 

//-------------------------------------------------
//Part 1: reallocating profits to source countries
//-------------------------------------------------

//essentially we rescale values from Table C2 to global profit shifting values obtained in table U1

use "$work/shifted_profits_U1_$temp", clear 

sum shifted_profits if ISO3=="WLD"
local WLD_shifted_profits = r(mean)


use "$work/table_C2_$temp", clear 
foreach name in "Belgium" "Cyprus" "Ireland" "Luxembourg" "Malta" "Netherlands" "Switzerland" "Rest" "All_havens" "EU_havens" "Non_EU_havens" {
	replace `name'_int = 0 if group == "OECD_TH" 
	replace `name'_services = 0 if group == "OECD_TH" 
}
sum All_havens_int if (ISO3 != "BEL" & ISO3 != "CYP" & ISO3 != "LUX" & ISO3 != "IRL" & ISO3 != "MLT" & ISO3 != "NLD" & ISO3 != "WLD" )
*sum All_havens_int if ISO3=="NHT"
local total_a = r(sum)
sum All_havens_services if (ISO3 != "BEL" & ISO3 != "CYP" & ISO3 != "LUX" & ISO3 != "IRL" & ISO3 != "MLT" & ISO3 != "NLD" & ISO3 != "WLD" )
*sum All_havens_services if ISO3=="NHT"
local total_b = r(sum)


**changed 52 to 51
set obs 51
replace country = "Non-haven total" if ISO3==""
replace ISO3 = "NHT" if ISO3 == ""
replace group = "other" if ISO3 == "NHT"
replace EU = 0 if ISO3 == "NHT"
sort group ISO3

foreach name in "Belgium" "Cyprus" "Ireland" "Luxembourg" "Malta" "Netherlands" "Switzerland" "Rest" "All_havens" "EU_havens" "Non_EU_havens" {
*	replace `name'_int = 0 if group == "OECD_TH" 
*	replace `name'_services = 0 if group == "OECD_TH" 
	gen `name' = . 
	replace `name' = (1000 * `WLD_shifted_profits') * ((`name'_int + `name'_services)/(`total_a'+`total_b'))

	sum `name' if ISO3 != "WLD"
	display r(sum)
	sum `name' if (ISO3 != "BEL" & ISO3 != "CYP" & ISO3 != "LUX" & ISO3 != "IRL" & ISO3 != "MLT" & ISO3 != "NLD" & ISO3 != "WLD")
	replace `name' = r(sum) if ISO3 == "NHT"

}

keep ISO3 country group EU Belgium Cyprus Ireland Luxembourg Malta Netherlands Switzerland Rest All_havens EU_havens Non_EU_havens

sum All_havens if (ISO3 != "BEL" & ISO3 != "CYP" & ISO3 != "LUX" & ISO3 != "IRL" & ISO3 != "MLT" & ISO3 != "NLD" & ISO3 != "WLD")
display r(sum) 
display `WLD_shifted_profits' *1000

//Final reoredering and export results
gen sort_dummy=.
replace sort_dummy=1 if group=="OECD"
replace sort_dummy=2 if group=="OECD_TH"
replace sort_dummy=3 if group=="DEV"
replace sort_dummy=4 if group=="NEW_DEV"
replace sort_dummy=5 if group=="other" 
sort sort_dummy ISO3 
drop sort_dummy
order country ISO3 EU group 

duplicates drop country ISO3, force

save "$work/table_C4_$temp", replace 
export excel using "$root/output/Part2-reallocating-profits-$temp.xlsx", firstrow(var) sheet("Table C4", replace) keepcellfmt



