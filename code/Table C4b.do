//--------------------------------------------------------
//Table C4b: country losses as a share of global losses
//--------------------------------------------------------


use "$work/table_C4_$temp", replace 

foreach name in "Belgium" "Cyprus" "Ireland" "Luxembourg" "Malta" "Netherlands" "Switzerland" "Rest" "All_havens" "EU_havens" "Non_EU_havens" {

	sum `name' if ISO3 == "NHT"
	local `name'_total = r(mean)
	replace `name' = `name'/``name'_total'
	

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

save "$work/table_C4b_$temp", replace
export excel using "$root/output/Part2-reallocating-profits-$temp.xlsx", firstrow(var) sheet("Table C4b", replace) keepcellfmt
