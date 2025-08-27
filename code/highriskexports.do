//-------------------------------------------
//Step 2d: high risk fdi - selected countries
//-------------------------------------------

//this do file prepares high risk export data for selected countries 
//Hong Kong, Switzerland, Singapore, and the World
//used in the second part of the analysis - reallocation of shifted profits

*ssc install wbopendata

wbopendata, indicator(BX.GSR.ROYL.CD; BX.GSR.INSF.ZS; BX.GSR.NFSV.CD; BX.GSR.CMCP.ZS) clear  

keep if (countrycode=="HKG"|countrycode=="CHE"|countrycode=="SGP"|countrycode=="WLD")

save "$work/highriskimports", replace

preserve
use "$work/highriskimports", clear
keep countrycode indicatorname yr$temp
save "$work/highriskexports_$temp", replace
restore










