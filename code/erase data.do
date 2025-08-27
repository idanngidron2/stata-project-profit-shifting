//-----------------------------------------------
//Step 7: Erase unnecessary data
//-----------------------------------------------

//the dofile erases unecessary data files that are not used further in the 
//analysis. This is to ensure the storage space is not over-used. 



foreach name in "Direct investment abroad" "Direct investment abroad; Dividends"	"Direct investment abroad; Reinvested earnings"	"Direct investment abroad; Income on debt" {
	erase "$work/`name'_EU28_$temp.dta"
	erase "$work/`name'_EU_TH_$temp.dta" 
}




foreach name in "Direct investment in the reporting economy"	"Direct investment in the reporting economy; Income on debt" "Direct investment in the reporting economy; Dividends"{
	erase "$work/`name'_EU_TH_$temp.dta"
	erase "$work/`name'_EU_28_$temp.dta"
	erase "$work/`name'_havens_$temp.dta"

}



foreach name in "Direct investment abroad" "Direct investment abroad; Dividends" "Direct investment abroad; Reinvested earnings" "Direct investment abroad; Income on debt" {
	erase "$work/`name'$temp.dta"
}


foreach name in "Direct investment abroad; Income on debt" {
	erase "$work/`name'_havens$temp.dta"
	erase "$work/`name'_EU28$temp.dta"
}



foreach name in "Direct investment in the reporting economy; Income on debt" {
	erase "$work/`name'_$temp.dta"
}



foreach name in "Direct investment abroad" "Direct investment abroad; Dividends"	"Direct investment abroad; Reinvested earnings"	"Direct investment abroad; Income on debt"{
	erase "$work/`name'_A$temp.dta"
	erase "$work/`name'_B$temp.dta"
	erase "$work/`name'_C$temp.dta"
}


foreach name in "Direct investment in the reporting economy" "Direct investment in the reporting economy; Dividends" "Direct investment in the reporting economy; Reinvested earnings"	"Direct investment in the reporting economy; Income on debt"{
	erase "$work/`name'_A$temp.dta"
	erase "$work/`name'_B$temp.dta"
	erase "$work/`name'_C$temp.dta"
}






