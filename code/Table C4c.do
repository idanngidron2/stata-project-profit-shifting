//----------------------------------------------------------
//Table C4c: country losses as a share of corporate profits
//----------------------------------------------------------


use "$work/shifted_profits_U1_$temp", clear 


keep ISO3 pre_tax_corp_profits
replace pre_tax_corp_profits =pre_tax_corp_profits * 1000 
tempfile tf
save `tf', replace 

use "$work/table_C4_$temp", clear 
merge 1:1 ISO3 using `tf', nogen 

drop if group == "" | group == "NEW_DEV"

sum pre_tax_corp_profits if (ISO3 != "BEL" & ISO3 != "CYP" & ISO3 != "LUX" & ISO3 != "IRL" & ISO3 != "MLT" & ISO3 != "NLD" & ISO3 != "WLD")
replace pre_tax_corp_profits = r(sum) if ISO3 == "NHT"

foreach name in "Belgium" "Cyprus" "Ireland" "Luxembourg" "Malta" "Netherlands" "Switzerland" "Rest" "All_havens" "EU_havens" "Non_EU_havens" {

	replace `name' = `name'/pre_tax_corp_profits
	

}

//Final reoredering and export results
gen sort_dummy=.
replace sort_dummy=1 if group=="OECD"
replace sort_dummy=2 if group=="OECD_TH"
replace sort_dummy=3 if group=="DEV"
replace sort_dummy=4 if group=="NEW_DEV"
replace sort_dummy=5 if group=="other" 
sort sort_dummy ISO3 
drop sort_dummy


save "$work/table_C4c_$temp", replace
export excel using "$root/output/Part2-reallocating-profits-$temp.xlsx", firstrow(var) sheet("Table C4c", replace) keepcellfmt
