//---------------------------------------------
//Step 4a: Eurostat service data bluk download
//---------------------------------------------	

//This do file downloads the most recent available raw data of service transactions
//if you want to replicate our findings precisely you shouldn't run this do file
//instead, just run the from the first do "non EU - debit" 


	eurostatuse bop_its6_det, clear // bulk download of service transactions
	drop if (geo=="CH"|geo=="EA18"|geo=="EA19"|geo=="ME"|geo=="MK"|geo=="TR"|geo=="NO"|geo=="IS"|geo=="RS"|geo=="XK"|geo=="BA")
	drop if stk_flow_l=="BAL"
if $temp >= 2019 {		//drop new additional geo/partners  so rest of old code works
	
	drop if geo == "EU28"
	replace geo = "EU28" if geo == "EU27_2020"
	drop if partner == "EU28"
	replace partner = "EU28" if partner == "EU27_2020"
	drop if geo == "EXT_EU28"
	replace geo = "EXT_EU28" if geo == "EXT_EU27_2020"
	drop if partner == "EXT_EU28"
	replace partner = "EXT_EU28" if partner == "EXT_EU27_2020"
}
	drop if partner_l=="Albania" 	//drop new additional geo/partners  so rest of old code works
	drop if geo_l=="Albania" 		//drop new additional geo/partners  so rest of old code works
	save "$work/bop_its6_det", replace 

	