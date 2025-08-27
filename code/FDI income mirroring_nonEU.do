//----------------------------------------------------
//Step 5f: Eurostat FDI disc mirroring non-EU
//----------------------------------------------------


use "$work/basic", clear


keep if stk_flow=="II" & direction=="DI"


keep if fdi_item_l=="Direct investment in the reporting economy"


save "$work/IIDI_noEUcountries_$temp", replace

***************************************MAKING TABLES***************************************************
*******************************************************************************************************
*******************************************************************************************************

use "$work/basic", clear


keep if stk_flow=="IO" & direction=="DO"


keep if fdi_item_l=="Direct investment abroad"

rename bop_fdi6_inc$temp mirror
rename geo partn
rename partner geo
rename partn partner

merge 1:1 geo partner using "$work/IIDI_noEUcountries_$temp"

keep if _merge==3
gen discrepancy=mirror-bop_fdi6_inc$temp

//making table Disc_nonEUcountries

preserve
	keep if fdi_item_l=="Direct investment abroad"
	keep partner_l geo_l fdi_item_l disc
	save "$work/Disc_nonEUcountries_$temp", replace
restore

