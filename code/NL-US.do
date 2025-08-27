//quick do to isolate FDI through SPEs as reported by NL and partner being USA

 use "$work/bop_fdi6_inc", replace
 
 * drop if entity!="SPE"
  
   keep if partner == "US"
   
   keep if geo == "LU"
   
   keep if nace_r2 == "FDI"
   
  * keep if stk_flow_label == "Net income on outward FDI" | stk_flow_label == "Net income on inward FDI" 
  keep if stk_flow_label == "Net income on inward FDI" 
  
  keep if fdi_item == "DI__D4P__D__F"
  
  foreach i in 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022{
  	sum bop_fdi6_inc`i' if entity == "SPE"
	local spe = r(mean)
	sum bop_fdi6_inc`i' if entity == "TOTAL"
	local total = r(mean)
	gen ratio_spe_tot_`i' = . 
	replace ratio_spe_tot_`i' = `spe'/`total'
	drop flags_bop_fdi6_inc`i' bop_fdi6_inc`i'  
	*drop if ratio_spe_tot_`i'==.
  }
  drop if entity == "SPE"
  drop geo_label partner_label currency currency_l nace_r2 nace_r2_l stk_flow stk_flow_l entity entity_l fdi_item fdi_item_l 
  
  reshape long ratio_spe_tot_, i(geo partner) j(year)
  drop if ratio_spe_tot_==.
  sum ratio_spe_tot_
  local nl_spe_ratio = r(mean)
  display `nl_spe_ratio'