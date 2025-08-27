//----------------------------------------
//Step 3b: OECD BOP discrepancies data
//----------------------------------------

//downloads global BOP data 
//structures BOP into measurement principles (direction inward or outward)
//enables analysis of global FDI discrepancies
//discrepancies = globally there is a direct income surplus
//used to correct profit shifting estimates accordingly


*(i)*
//downloand and basic cleaning steps


/* OLD call for direct upload to Stata

set timeout1 500
sdmxuse data OECD, clear dataset(FDI_CTRY_IND_SUMM) start($temp) end ($temp)

*/
//Since 2024, OECD data explorer no longer allows for direct download using Stata
//The data is downloaded separately in R instead.


if $temp >= 2021{
local temp = $temp

import delimited "$rawdata/OECD_BOP_`temp'.csv", clear 
}

cd "$work"


//Reframe data so that it matches previous versions 

rename ref_area cou 
rename obsvalue value
rename measure fdi_type
rename currency measure 
rename time_period time
rename activity eco_act 
replace eco_act = "FDI_T" if eco_act == "_T"

keep if fdi_type == "T_D4P_F"
keep if eco_act == "FDI_T"

keep cou value fdi_type measure time eco_act measure_principle counterpart_area

keep if cou == "AUS" | cou == "AUT" | cou == "BEL" | cou == "CAN" | cou == "CHL" | cou == "CZE" | cou == "DNK" | cou == "EST" | cou == "FIN" | cou == "FRA" | cou == "DEU" | cou == "GRC" | cou == "HUN" | cou == "ISL" | cou == "IRL" | cou == "ISR" | cou == "ITA" | cou == "JPN" | cou == "KOR" | cou == "LVA" | cou == "LTU" | cou == "LUX" | cou == "MEX" | cou == "NLD" | cou == "NZL" | cou == "NOR" | cou == "POL" | cou == "PRT" | cou == "SVK" | cou == "SVN" | cou == "ESP" | cou == "SWE" | cou == "CHE" | cou == "TUR" | cou == "GBR" | cou == "USA"

keep if counterpart_area == "W" | counterpart_area == "AUS" | counterpart_area == "AUT" | counterpart_area == "BEL" | counterpart_area == "CAN" | counterpart_area == "CHL" | counterpart_area == "CZE" | counterpart_area == "DNK" | counterpart_area == "EST" | counterpart_area == "FIN" | counterpart_area == "FRA" | counterpart_area == "DEU" | counterpart_area == "GRC" | counterpart_area == "HUN" | counterpart_area == "ISL" | counterpart_area == "IRL" | counterpart_area == "ISR" | counterpart_area == "ITA" | counterpart_area == "JPN" | counterpart_area == "KOR" | counterpart_area == "LVA" | counterpart_area == "LUX" | counterpart_area == "MEX" | counterpart_area == "NLD" | counterpart_area == "NZL" | counterpart_area == "NOR" | counterpart_area == "POL" | counterpart_area == "PRT" | counterpart_area == "SVK" | counterpart_area == "SVN" | counterpart_area == "ESP" | counterpart_area == "SWE" | counterpart_area == "CHE" | counterpart_area == "TUR" | counterpart_area == "GBR" | counterpart_area == "USA" | counterpart_area == "R1" | counterpart_area == "E1" | counterpart_area == "E19" | counterpart_area == "E1X" | counterpart_area == "ALB" | counterpart_area == "AND" | counterpart_area == "BLR" | counterpart_area == "BIH" | counterpart_area == "BGR" | counterpart_area == "HRV" | counterpart_area == "CYP" | counterpart_area == "FRO" | counterpart_area == "GIB" | counterpart_area == "GGY" | counterpart_area == "VAT" | counterpart_area == "IMN" | counterpart_area == "JEY" | counterpart_area == "XKO" | counterpart_area == "LIE" | counterpart_area == "LTU" | counterpart_area == "MKD" | counterpart_area == "MLT" | counterpart_area == "MDA" | counterpart_area == "MNE" | counterpart_area == "ROM" | counterpart_area == "RUS" | counterpart_area == "SMR" | counterpart_area == "SRB" | counterpart_area == "SCG" | counterpart_area == "UKR" | counterpart_area == "F1" | counterpart_area == "F19" | counterpart_area == "F4" | counterpart_area == "DZA" | counterpart_area == "EGY" | counterpart_area == "LBY" | counterpart_area == "MAR" | counterpart_area == "TUN" | counterpart_area == "F2" | counterpart_area == "AGO" | counterpart_area == "BEN" | counterpart_area == "BWA" | counterpart_area == "IOT" | counterpart_area == "BFA" | counterpart_area == "BDI" | counterpart_area == "CMR" | counterpart_area == "CPV" | counterpart_area == "CAF" | counterpart_area == "TCD" | counterpart_area == "COM" | counterpart_area == "COG" | counterpart_area == "COD" | counterpart_area == "CIV" | counterpart_area == "DJI" | counterpart_area == "GNQ" | counterpart_area == "ERI" | counterpart_area == "ETH" | counterpart_area == "GAB" | counterpart_area == "GMB" | counterpart_area == "GHA" | counterpart_area == "GIN" | counterpart_area == "GNB" | counterpart_area == "KEN" | counterpart_area == "LSO" | counterpart_area == "LBR" | counterpart_area == "MDG" | counterpart_area == "MWI" | counterpart_area == "MLI" | counterpart_area == "MRT" | counterpart_area == "MUS" | counterpart_area == "MOZ" | counterpart_area == "NAM" | counterpart_area == "NER" | counterpart_area == "NGA" | counterpart_area == "RWA" | counterpart_area == "SHN" | counterpart_area == "STP" | counterpart_area == "SEN" | counterpart_area == "SYC" | counterpart_area == "SLE" | counterpart_area == "SOM" | counterpart_area == "ZAF" | counterpart_area == "SSD" | counterpart_area == "SDN" | counterpart_area == "SWZ" | counterpart_area == "TZA" | counterpart_area == "TGO" | counterpart_area == "UGA" | counterpart_area == "ZMB" | counterpart_area == "ZWE" | counterpart_area == "A1" | counterpart_area == "A19" | counterpart_area == "A1X" | counterpart_area == "A2" | counterpart_area == "A2X" | counterpart_area == "GRL" | counterpart_area == "A5" | counterpart_area == "A5X" | counterpart_area == "AIA" | counterpart_area == "ATG" | counterpart_area == "ABW" | counterpart_area == "BHS" | counterpart_area == "BRB" | counterpart_area == "BLZ" | counterpart_area == "BMU" | counterpart_area == "BES" | counterpart_area == "CYM" | counterpart_area == "CRI" | counterpart_area == "CUB" | counterpart_area == "CUW" | counterpart_area == "DMA" | counterpart_area == "DOM" | counterpart_area == "SLV" | counterpart_area == "GRD" | counterpart_area == "GTM" | counterpart_area == "HTI" | counterpart_area == "HND" | counterpart_area == "JAM" | counterpart_area == "MSR" | counterpart_area == "ANT" | counterpart_area == "NIC" | counterpart_area == "PAN" | counterpart_area == "KNA" | counterpart_area == "LCA" | counterpart_area == "VCT" | counterpart_area == "SXM" | counterpart_area == "TTO" | counterpart_area == "TCA" | counterpart_area == "VGB" | counterpart_area == "VIR" | counterpart_area == "A7" | counterpart_area == "A7X" | counterpart_area == "ARG" | counterpart_area == "BOL" | counterpart_area == "BRA" | counterpart_area == "COL" | counterpart_area == "ECU" | counterpart_area == "FLK" | counterpart_area == "GUY" | counterpart_area == "PRY" | counterpart_area == "PER" | counterpart_area == "SUR" | counterpart_area == "URY" | counterpart_area == "VEN" | counterpart_area == "S1" | counterpart_area == "S19" | counterpart_area == "S1X" | counterpart_area == "S3" | counterpart_area == "S3X" | counterpart_area == "S35" | counterpart_area == "BHR" | counterpart_area == "IRQ" | counterpart_area == "KWT" | counterpart_area == "OMN" | counterpart_area == "QAT" | counterpart_area == "SAU" | counterpart_area == "ARE" | counterpart_area == "YEM" | counterpart_area == "S37" | counterpart_area == "S37X" | counterpart_area == "ARM" | counterpart_area == "AZE" | counterpart_area == "GEO" | counterpart_area == "JOR" | counterpart_area == "LBN" | counterpart_area == "PSE" | counterpart_area == "SYR" | counterpart_area == "S6" | counterpart_area == "AFG" | counterpart_area == "BGD" | counterpart_area == "BTN" | counterpart_area == "BRN" | counterpart_area == "KHM" | counterpart_area == "CHN" | counterpart_area == "HKG" | counterpart_area == "IND" | counterpart_area == "IDN" | counterpart_area == "IRN" | counterpart_area == "KAZ" | counterpart_area == "PRK" | counterpart_area == "KGZ" | counterpart_area == "LAO" | counterpart_area == "MAC" | counterpart_area == "MYS" | counterpart_area == "MDV" | counterpart_area == "MNG" | counterpart_area == "MMR" | counterpart_area == "NPL" | counterpart_area == "PAK" | counterpart_area == "PHL" | counterpart_area == "SGP" | counterpart_area == "LKA" | counterpart_area == "TWN" | counterpart_area == "TJK" | counterpart_area == "THA" | counterpart_area == "TLS" | counterpart_area == "TKM" | counterpart_area == "UZB" | counterpart_area == "VNM" | counterpart_area == "O1" | counterpart_area == "O19" | counterpart_area == "O1X0" | counterpart_area == "ASM" | counterpart_area == "ATA" | counterpart_area == "BVT" | counterpart_area == "CXR" | counterpart_area == "CCK" | counterpart_area == "COK" | counterpart_area == "FJI" | counterpart_area == "PYF" | counterpart_area == "ATF" | counterpart_area == "GUM" | counterpart_area == "HMD" | counterpart_area == "KIR" | counterpart_area == "MHL" | counterpart_area == "FSM" | counterpart_area == "NRU" | counterpart_area == "NCL" | counterpart_area == "NIU" | counterpart_area == "NFK" | counterpart_area == "MNP" | counterpart_area == "PLW" | counterpart_area == "PNG" | counterpart_area == "PCN" | counterpart_area == "WSM" | counterpart_area == "SLB" | counterpart_area == "SGS" | counterpart_area == "TKL" | counterpart_area == "TON" | counterpart_area == "TUV" | counterpart_area == "UMI" | counterpart_area == "VUT" | counterpart_area == "WLF" | counterpart_area == "ECO_ZONES" | counterpart_area == "B5" | counterpart_area == "B4" | counterpart_area == "B3" | counterpart_area == "B2" | counterpart_area == "R4" | counterpart_area == "R220" | counterpart_area == "R221" | counterpart_area == "R222" | counterpart_area == "F98" | counterpart_area == "R25" | counterpart_area == "R251" | counterpart_area == "R252" | counterpart_area == "R253" | counterpart_area == "R254" | counterpart_area == "R255" | counterpart_area == "P4" | counterpart_area == "P1" | counterpart_area == "P00"


replace value = "0" if value =="NA"
destring value, force replace
destring time, force replace
keep if time==$temp


save "$work/FDI_CTRY_IND_SUMM_$temp", replace
cd "$code"


*(ii)* 
//save data into separate stata files by directional principle

*/

//directional principle: Inward

use "$work/FDI_CTRY_IND_SUMM_$temp", clear

keep if measure_=="DI"

preserve 
keep if counter=="W"
keep cou value
save "$work/OECD_DI_INCOME_$temp", replace
restore

local allcountries "AUS AUT BEL CAN CHL CZE DNK EST FIN FRA DEU GRC HUN ISL IRL ISR ITA JPN KOR LVA LTU LUX MEX NLD NZL NOR POL PRT SVK SVN ESP SWE CHE TUR GBR USA W R1 E1 E19 E1X ALB AND BLR BIH BGR HRV CYP FRO GIB GGY VAT IMN JEY XKO LIE LTU MKD MLT MDA MNE ROM RUS SMR SRB SCG UKR F1 F19 F4 DZA EGY LBY MAR TUN F2 AGO BEN BWA IOT BFA BDI CMR CPV CAF TCD COM COG COD CIV DJI GNQ ERI ETH GAB GMB GHA GIN GNB KEN LSO LBR MDG MWI MLI MRT MUS MOZ NAM NER NGA RWA SHN STP SEN SYC SLE SOM ZAF SSD SDN SWZ TZA TGO UGA ZMB ZWE A1 A19 A1X A2 A2X GRL A5 A5X AIA ATG ABW BHS BRB BLZ BMU BES CYM CRI CUB CUW DMA DOM SLV GRD GTM HTI HND JAM MSR ANT NIC PAN KNA LCA VCT SXM TTO TCA VGB VIR A7 A7X ARG BOL BRA COL ECU FLK GUY PRY PER SUR URY VEN S1 S19 S1X S3 S3X S35 BHR IRQ KWT OMN QAT SAU ARE YEM S37 S37X ARM AZE GEO JOR LBN PSE SYR S6 S6X AFG BGD BTN BRN KHM CHN HKG IND IDN IRN KAZ PRK KGZ LAO MAC MYS MDV MNG MMR NPL PAK PHL SGP LKA TWN TJK THA TLS TKM UZB VNM O1 O19 O1X0 ASM ATA BVT CXR CCK COK FJI PYF ATF GUM HMD KIR MHL FSM NRU NCL NIU NFK MNP PLW PNG PCN WSM SLB SGS TKL TON TUV UMI VUT WLF ECO_ZONES B5 B4 B3 B2 R4 R220 R221 R222 F98 R25 R251 R252 R253 R254 R255 P4 P1 P00"

preserve
*keep if counter=="W0"

keep counterpart_area value
gen value2=.
foreach c in `allcountries' {
	
	sum value if counterpart_area=="`c'"
	replace value2= r(sum) if counterpart_area=="`c'"
}
drop value
sort counterpart_area value2
quietly by counterpart_area value2: gen dup = cond(_N==1,0,_n)
drop if dup>1
drop dup 

save "$work/OECD_COUNTERDI_INCOME_$temp", replace
restore

save "$work/DI_$temp", replace


//directional principle: Outward

use "$work/FDI_CTRY_IND_SUMM_$temp", replace

keep if measure_=="DO"



preserve
keep if counter=="W"
keep cou value
save "$work/OECD_DO_INCOME_$temp", replace
restore

preserve
*keep if counter=="W0"
keep counterpart_area value
gen value2=.
foreach c in `allcountries' {
	
	sum value if counterpart_area=="`c'"
	replace value2= r(sum) if counterpart_area=="`c'"
}
drop value
sort counterpart_area value2
quietly by counterpart_area value2: gen dup = cond(_N==1,0,_n)
drop if dup>1
drop dup 

save "$work/OECD_COUNTERDO_INCOME_$temp", replace
restore

save "$work/DO_$temp", replace 



*(iii)*
//calculate discrepancies as country outward - counterpart inward

rename cou c
rename counterpart_area cou 
rename c counterpart_area

rename value mirror

merge 1:1 counterpart_are cou using "$work/DI_$temp"
*merge m:m counterpart_area cou using "$work/DI_$temp"

keep if _merge==3
drop _merge

destring mirror value, force replace

gen disc= mirror-value


egen totaldisc_DI_less_DO=total(disc), by(cou)
egen totaldisc_DO_less_DI=total(disc), by(counterpart)

egen totalmirror=total(mirror), by(cou)

//no counterpart data is available for luxembourg, imputed based on world mirror
gen globaldisc=value-totalmirror if counterpart=="W0"

gen ratio_world_to_mirror=globaldisc/value

egen weighted_worldtomirror=wtmean(ratio_world_to_mirror), weight(value)

gen correction=(ratio_world_to_mirror-weighted_worldtomirror)*value

replace totaldisc_DI_less_DO=-correction-globaldisc if cou=="LUX"

*(iv)*
//save separate files of discrepancies in stata format


preserve
keep if counterpart=="W" 
keep cou totaldisc_DI_less_DO
save "$work/totaldisc_DI_less_DO_$temp", replace
restore 

preserve 
keep if counterpart==cou 
keep cou totaldisc_DO_less_DI
save "$work/totaldisc_DO_less_DI_$temp", replace
restore




*(v)*
//use to make known discrepancies


gen EU_country=0
foreach v in AUT BEL CZE DEU DNK ESP EST FIN FRA GBR GRC HUN IRL ITA LTU LUX LVA NLD NOR POL SVK SVN SWE{
replace EU=1 if cou=="`v'"
}

gen EU_counterpart=0
foreach value in AUT BEL CZE DEU DNK ESP EST FIN FRA GBR GRC HUN IRL ITA LTU LUX LVA NLD NOR POL SVK SVN SWE{
replace EU_counter=1 if counter=="`v'"
}

drop if EU_country==1
drop if EU_counter==1
*keep if _merge==3

preserve
keep counterpart_are cou disc
save "$work/Disc_OECD_$temp", replace
restore




