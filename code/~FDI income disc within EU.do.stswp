
//----------------------------------------
//Step 5f: Eurostat FDI disc within EU
//----------------------------------------


use "$work/basic", clear


drop if (geo=="CH"|geo=="EA18"|geo=="EA19"|geo=="ME"|geo=="MK"|geo=="TR"|geo=="NO"|geo=="IS"|geo=="RS"|geo=="US"|geo=="XK"|geo=="JP"|geo=="AL")
keep if stk_flow=="II" & direction=="DI"

/*	
if $temp >= 2019 {	
	keep if partner=="EU27_2020"
}

if $temp == 2016 |$temp == 2017 |$temp == 2018   {
	keep if partner=="EU28"
	
}
*/

keep if partner=="EU28"

keep if fdi_item_label=="Direct investment in the reporting economy"

save "$work/IIDI_EU_$temp", replace

use "$work/basic", clear

local temp=$temp

keep if stk_flow=="IO" & direction=="DO"
keep if fdi_item_label=="Direct investment abroad"

/*

if $temp >= 2019 {	
	keep if (partner=="EU27_2020"|partner=="AT"|	partner=="BE"|	partner=="BG"|	partner=="CY"|	partner=="CZ"|	partner=="DE"|	partner=="DK"|	partner=="EE"|	partner=="EL"|	partner=="ES"|	partner=="FI"|	partner=="FR"|	partner=="HR"|	partner=="HU"|	partner=="IE"|	partner=="IT"|	partner=="LT"|	partner=="LU"|	partner=="LV"|	partner=="MT"|	partner=="NL"|	partner=="PL"|	partner=="PT"|	partner=="RO"|	partner=="SE"|	partner=="SI"|	partner=="SK"|	partner=="UK")
}

if $temp == 2016 |$temp == 2017 |$temp == 2018  {
	keep if (partner=="EU28"|partner=="AT"|	partner=="BE"|	partner=="BG"|	partner=="CY"|	partner=="CZ"|	partner=="DE"|	partner=="DK"|	partner=="EE"|	partner=="EL"|	partner=="ES"|	partner=="FI"|	partner=="FR"|	partner=="HR"|	partner=="HU"|	partner=="IE"|	partner=="IT"|	partner=="LT"|	partner=="LU"|	partner=="LV"|	partner=="MT"|	partner=="NL"|	partner=="PL"|	partner=="PT"|	partner=="RO"|	partner=="SE"|	partner=="SI"|	partner=="SK"|	partner=="UK")

}

*/
keep if (partner=="EU28"|partner=="AT"|	partner=="BE"|	partner=="BG"|	partner=="CY"|	partner=="CZ"|	partner=="DE"|	partner=="DK"|	partner=="EE"|	partner=="EL"|	partner=="ES"|	partner=="FI"|	partner=="FR"|	partner=="HR"|	partner=="HU"|	partner=="IE"|	partner=="IT"|	partner=="LT"|	partner=="LU"|	partner=="LV"|	partner=="MT"|	partner=="NL"|	partner=="PL"|	partner=="PT"|	partner=="RO"|	partner=="SE"|	partner=="SI"|	partner=="SK"|	partner=="UK")


rename bop_fdi6_inc$temp mirror
rename geo partn
rename partner geo
rename partn partner

merge 1:1 geo partner using "$work/IIDI_EU_$temp"

gen disc_FDI=.
replace disc_FDI = mirror - bop_fdi6_inc$temp


save "$work/disc_FDI_EU_$temp", replace 

//------------------SPE Only-------------------//

use "$work/bop_fdi6_inc", replace
gen direction=substr(fdi_item,1,2)
drop if nace_r2!="FDI"
drop if entity!="SPE"

drop if  (geo=="CH"|geo=="EA18"|geo=="EA19"|geo=="ME"|geo=="MK"|geo=="TR"|geo=="NO"|geo=="IS"|geo=="RS"|geo=="US"|geo=="XK"|geo=="JP"|geo=="AL")
keep if stk_flow=="II" & direction=="DI"

/*
if $temp >= 2019 {	
	keep if partner=="EU27_2020"
}

if $temp == 2016 |$temp == 2017 |$temp == 2018   {
	keep if partner=="EU28"
	
}
*/
keep if partner=="EU28"

keep if fdi_item_label=="Direct investment in the reporting economy"

save "$work/IIDI_EU_$temp", replace

use "$work/bop_fdi6_inc", replace
gen direction=substr(fdi_item,1,2)
drop if nace_r2!="FDI"
drop if entity!="SPE"
keep if stk_flow=="IO" & direction=="DO"
keep if fdi_item_label=="Direct investment abroad"

local temp=$temp
/*
if $temp >= 2019 {	
	keep if geo=="EU27_2020"
}

if $temp == 2016 |$temp == 2017 |$temp == 2018   {
	keep if geo=="EU28"
	
}
*/
keep if geo=="EU28"

/*
	
if $temp >= 2019 {	
	keep if (partner=="EU27_2020"|partner=="AT"|	partner=="BE"|	partner=="BG"|	partner=="CY"|	partner=="CZ"|	partner=="DE"|	partner=="DK"|	partner=="EE"|	partner=="EL"|	partner=="ES"|	partner=="FI"|	partner=="FR"|	partner=="HR"|	partner=="HU"|	partner=="IE"|	partner=="IT"|	partner=="LT"|	partner=="LU"|	partner=="LV"|	partner=="MT"|	partner=="NL"|	partner=="PL"|	partner=="PT"|	partner=="RO"|	partner=="SE"|	partner=="SI"|	partner=="SK"|	partner=="UK")
}

if $temp == 2016 |$temp == 2017 |$temp == 2018   {
	keep if (partner=="EU28"|partner=="AT"|	partner=="BE"|	partner=="BG"|	partner=="CY"|	partner=="CZ"|	partner=="DE"|	partner=="DK"|	partner=="EE"|	partner=="EL"|	partner=="ES"|	partner=="FI"|	partner=="FR"|	partner=="HR"|	partner=="HU"|	partner=="IE"|	partner=="IT"|	partner=="LT"|	partner=="LU"|	partner=="LV"|	partner=="MT"|	partner=="NL"|	partner=="PL"|	partner=="PT"|	partner=="RO"|	partner=="SE"|	partner=="SI"|	partner=="SK"|	partner=="UK")

}
	
*/
keep if (partner=="EU28"|partner=="AT"|	partner=="BE"|	partner=="BG"|	partner=="CY"|	partner=="CZ"|	partner=="DE"|	partner=="DK"|	partner=="EE"|	partner=="EL"|	partner=="ES"|	partner=="FI"|	partner=="FR"|	partner=="HR"|	partner=="HU"|	partner=="IE"|	partner=="IT"|	partner=="LT"|	partner=="LU"|	partner=="LV"|	partner=="MT"|	partner=="NL"|	partner=="PL"|	partner=="PT"|	partner=="RO"|	partner=="SE"|	partner=="SI"|	partner=="SK"|	partner=="UK")


rename bop_fdi6_inc$temp mirror
rename geo partn
rename partner geo
rename partn partner


merge 1:1 geo partner using "$work/IIDI_EU_$temp"

gen disc_SPE=.
replace disc_SPE = mirror - bop_fdi6_inc$temp




merge 1:1 geo partner using "$work/disc_FDI_EU_$temp", gen(merge2)

gen discrepancy_excl_SPE=.
replace disc_SPE=0 if disc_SPE==.
replace discrepancy_excl_SPE = disc_FDI - disc_SPE


	keep partner_l discrepancy_excl_SPE disc_FDI
	duplicates drop partner_l, force

	save "$work/Disc_EU_DI_less_DO_$temp", replace


********** DO less DI***********

use "$work/basic", clear


drop if ( geo=="CH"|geo=="EA18"|geo=="EA19"|geo=="ME"|geo=="MK"|geo=="TR"|geo=="NO"|geo=="IS"|geo=="RS"|geo=="US"|geo=="XK"|geo=="JP"|geo=="AL")
keep if stk_flow=="IO" & direction=="DO"

/*
if $temp >= 2019 {	
	keep if partner=="EU27_2020"
}

if $temp == 2016 |$temp == 2017 |$temp == 2018   {
	keep if partner=="EU28"
	
}
*/

keep if partner=="EU28"


keep if fdi_item_label=="Direct investment abroad"

save "$work/IODO_EU_$temp", replace

use "$work/basic", clear
local temp=$temp
keep if fdi_item_label=="Direct investment in the reporting economy"
keep if stk_flow=="II" & direction=="DI"

/*
if $temp >= 2019 {	
	keep if (partner=="EU27_2020"|partner=="AT"|	partner=="BE"|	partner=="BG"|	partner=="CY"|	partner=="CZ"|	partner=="DE"|	partner=="DK"|	partner=="EE"|	partner=="EL"|	partner=="ES"|	partner=="FI"|	partner=="FR"|	partner=="HR"|	partner=="HU"|	partner=="IE"|	partner=="IT"|	partner=="LT"|	partner=="LU"|	partner=="LV"|	partner=="MT"|	partner=="NL"|	partner=="PL"|	partner=="PT"|	partner=="RO"|	partner=="SE"|	partner=="SI"|	partner=="SK"|	partner=="UK")
}

if $temp == 2016 |$temp == 2017 |$temp == 2018   {
	keep if (partner=="EU28"|partner=="AT"|	partner=="BE"|	partner=="BG"|	partner=="CY"|	partner=="CZ"|	partner=="DE"|	partner=="DK"|	partner=="EE"|	partner=="EL"|	partner=="ES"|	partner=="FI"|	partner=="FR"|	partner=="HR"|	partner=="HU"|	partner=="IE"|	partner=="IT"|	partner=="LT"|	partner=="LU"|	partner=="LV"|	partner=="MT"|	partner=="NL"|	partner=="PL"|	partner=="PT"|	partner=="RO"|	partner=="SE"|	partner=="SI"|	partner=="SK"|	partner=="UK")

}
*/

keep if (partner=="EU28"|partner=="AT"|	partner=="BE"|	partner=="BG"|	partner=="CY"|	partner=="CZ"|	partner=="DE"|	partner=="DK"|	partner=="EE"|	partner=="EL"|	partner=="ES"|	partner=="FI"|	partner=="FR"|	partner=="HR"|	partner=="HU"|	partner=="IE"|	partner=="IT"|	partner=="LT"|	partner=="LU"|	partner=="LV"|	partner=="MT"|	partner=="NL"|	partner=="PL"|	partner=="PT"|	partner=="RO"|	partner=="SE"|	partner=="SI"|	partner=="SK"|	partner=="UK")
	
/*	
if $temp >= 2019 {	
	keep if geo=="EU27_2020"
}

if $temp == 2016 |$temp == 2017 |$temp == 2018   {
	keep if geo=="EU28"
	
}
*/


keep if geo=="EU28"


rename bop_fdi6_inc$temp mirror
rename geo partn
rename partner geo
rename partn partner


merge 1:1 geo partner using "$work/IODO_EU_$temp"

gen disc_FDI=.
replace disc_FDI = mirror - bop_fdi6_inc$temp


save "$work/disc_FDI_EU_$temp", replace 

//------------------SPE Only-------------------//

use "$work/bop_fdi6_inc", replace
gen direction=substr(fdi_item,1,2)
drop if nace_r2!="FDI"
drop if entity!="SPE"
keep if fdi_item_label=="Direct investment abroad"

drop if ( geo=="CH"|geo=="EA18"|geo=="EA19"|geo=="ME"|geo=="MK"|geo=="TR"|geo=="NO"|geo=="IS"|geo=="RS"|geo=="US"|geo=="XK"|geo=="JP"|geo=="AL")
keep if stk_flow=="IO" & direction=="DO"


/*	
if $temp >= 2019 {	
	keep if partner=="EU27_2020"
}

if $temp == 2016 |$temp == 2017 |$temp == 2018   {
	keep if partner=="EU28"
	
}
*/

keep if partner=="EU28"




save "$work/IODO_EU_$temp", replace

use "$work/bop_fdi6_inc", replace
gen direction=substr(fdi_item,1,2)
drop if nace_r2!="FDI"
drop if entity!="SPE"
keep if stk_flow=="II" & direction=="DI"
keep if fdi_item_label=="Direct investment in the reporting economy"

local temp=$temp

/*
	
if $temp >= 2019 {	
	keep if (partner=="EU27_2020"|partner=="AT"|	partner=="BE"|	partner=="BG"|	partner=="CY"|	partner=="CZ"|	partner=="DE"|	partner=="DK"|	partner=="EE"|	partner=="EL"|	partner=="ES"|	partner=="FI"|	partner=="FR"|	partner=="HR"|	partner=="HU"|	partner=="IE"|	partner=="IT"|	partner=="LT"|	partner=="LU"|	partner=="LV"|	partner=="MT"|	partner=="NL"|	partner=="PL"|	partner=="PT"|	partner=="RO"|	partner=="SE"|	partner=="SI"|	partner=="SK"|	partner=="UK")
}

if $temp == 2016 |$temp == 2017 |$temp == 2018   {
	keep if (partner=="EU28"|partner=="AT"|	partner=="BE"|	partner=="BG"|	partner=="CY"|	partner=="CZ"|	partner=="DE"|	partner=="DK"|	partner=="EE"|	partner=="EL"|	partner=="ES"|	partner=="FI"|	partner=="FR"|	partner=="HR"|	partner=="HU"|	partner=="IE"|	partner=="IT"|	partner=="LT"|	partner=="LU"|	partner=="LV"|	partner=="MT"|	partner=="NL"|	partner=="PL"|	partner=="PT"|	partner=="RO"|	partner=="SE"|	partner=="SI"|	partner=="SK"|	partner=="UK")

}
	*/
	
keep if (partner=="EU28"|partner=="AT"|	partner=="BE"|	partner=="BG"|	partner=="CY"|	partner=="CZ"|	partner=="DE"|	partner=="DK"|	partner=="EE"|	partner=="EL"|	partner=="ES"|	partner=="FI"|	partner=="FR"|	partner=="HR"|	partner=="HU"|	partner=="IE"|	partner=="IT"|	partner=="LT"|	partner=="LU"|	partner=="LV"|	partner=="MT"|	partner=="NL"|	partner=="PL"|	partner=="PT"|	partner=="RO"|	partner=="SE"|	partner=="SI"|	partner=="SK"|	partner=="UK")

/*	
if $temp >= 2019 {	
	keep if geo=="EU27_2020"
}

if $temp == 2016 |$temp == 2017 |$temp == 2018   {
	keep if geo=="EU28"
	
}
*/
keep if geo=="EU28"

rename bop_fdi6_inc$temp mirror
rename geo partn
rename partner geo
rename partn partner


merge 1:1 geo partner using "$work/IODO_EU_$temp"

gen disc_SPE=.
replace disc_SPE = mirror - bop_fdi6_inc$temp




merge 1:1 geo partner using "$work/disc_FDI_EU_$temp", gen(merge2)

gen discrepancy_excl_SPE=.
replace discrepancy_excl_SPE = disc_FDI - disc_SPE
keep partner_l discrepancy_excl_SPE disc_FDI


	save "$work/Disc_EU_DO_less_DI_$temp", replace

