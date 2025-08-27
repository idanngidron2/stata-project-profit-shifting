// --------------------------------------------- //
// Build summary statistics table
// --------------------------------------------- // 

//In this do file we import the final output for years of interest and build 
//summary statistics table. 

//------------------------------------- // 
//summary table B10 
// ------------------------------------ //
use "$work/tableB10_2016", clear

keep Inward_DI_country_IMF missing_income DI_equity_income_surplus Outward_DI_country_IMF reallocation correction gap_outward gap_inward

collapse (sum) Inward_DI_country_IMF missing_income DI_equity_income_surplus Outward_DI_country_IMF reallocation correction gap_outward gap_inward

gen total_DI_discrepancy = Outward_DI_country_IMF - Inward_DI_country_IMF
gen step_1_missing_income = total_DI_discrepancy + correction - missing_income
gen step_2_stock_data = step_1_missing_income - DI_equity_income_surplus 
gen step_3_reallocation = step_2_stock_data - reallocation
gen year = 2016 
order year 

save "$work/summary_table_B10", replace

use "$work/tableB10_2017", clear

keep Inward_DI_country_IMF missing_income DI_equity_income_surplus Outward_DI_country_IMF reallocation correction gap_outward gap_inward

collapse (sum) Inward_DI_country_IMF missing_income DI_equity_income_surplus Outward_DI_country_IMF reallocation correction gap_outward gap_inward

gen total_DI_discrepancy = Outward_DI_country_IMF - Inward_DI_country_IMF
gen step_1_missing_income = total_DI_discrepancy + correction - missing_income
gen step_2_stock_data = step_1_missing_income - DI_equity_income_surplus 
gen step_3_reallocation = step_2_stock_data - reallocation
gen year = 2017
order year 

tempfile tf 
save `tf', replace 

use "$work/summary_table_B10", clear 
append using `tf'

save "$work/summary_table_B10", replace

use "$work/tableB10_2018", clear

keep Inward_DI_country_IMF missing_income DI_equity_income_surplus Outward_DI_country_IMF reallocation correction gap_outward gap_inward

collapse (sum) Inward_DI_country_IMF missing_income DI_equity_income_surplus Outward_DI_country_IMF reallocation correction gap_outward gap_inward

gen total_DI_discrepancy = Outward_DI_country_IMF - Inward_DI_country_IMF
gen step_1_missing_income = total_DI_discrepancy + correction - missing_income
gen step_2_stock_data = step_1_missing_income - DI_equity_income_surplus 
gen step_3_reallocation = step_2_stock_data - reallocation
gen year = 2018
order year 

tempfile tf 
save `tf', replace 

use "$work/summary_table_B10", clear 
append using `tf'

save "$work/summary_table_B10", replace

use "$work/tableB10_2019", clear

keep Inward_DI_country_IMF missing_income DI_equity_income_surplus Outward_DI_country_IMF reallocation correction gap_outward gap_inward

collapse (sum) Inward_DI_country_IMF missing_income DI_equity_income_surplus Outward_DI_country_IMF reallocation correction gap_outward gap_inward

gen total_DI_discrepancy = Outward_DI_country_IMF - Inward_DI_country_IMF
gen step_1_missing_income = total_DI_discrepancy + correction - missing_income
gen step_2_stock_data = step_1_missing_income - DI_equity_income_surplus 
gen step_3_reallocation = step_2_stock_data - reallocation
gen year = 2019
order year 

tempfile tf 
save `tf', replace 

use "$work/summary_table_B10", clear 
append using `tf'

save "$work/summary_table_B10", replace

use "$work/tableB10_2020", clear

keep Inward_DI_country_IMF missing_income DI_equity_income_surplus Outward_DI_country_IMF reallocation correction gap_outward gap_inward

collapse (sum) Inward_DI_country_IMF missing_income DI_equity_income_surplus Outward_DI_country_IMF reallocation correction gap_outward gap_inward

gen total_DI_discrepancy = Outward_DI_country_IMF - Inward_DI_country_IMF
gen step_1_missing_income = total_DI_discrepancy + correction - missing_income
gen step_2_stock_data = step_1_missing_income - DI_equity_income_surplus 
gen step_3_reallocation = step_2_stock_data - reallocation
gen year = 2020
order year 

tempfile tf 
save `tf', replace 

use "$work/summary_table_B10", clear 
append using `tf'

save "$work/summary_table_B10", replace

use "$work/tableB10_2021", clear

keep Inward_DI_country_IMF missing_income DI_equity_income_surplus Outward_DI_country_IMF reallocation correction gap_outward gap_inward

collapse (sum) Inward_DI_country_IMF missing_income DI_equity_income_surplus Outward_DI_country_IMF reallocation correction gap_outward gap_inward

gen total_DI_discrepancy = Outward_DI_country_IMF - Inward_DI_country_IMF
gen step_1_missing_income = total_DI_discrepancy + correction - missing_income
gen step_2_stock_data = step_1_missing_income - DI_equity_income_surplus 
gen step_3_reallocation = step_2_stock_data - reallocation
gen year = 2021
order year 

tempfile tf 
save `tf', replace 

use "$work/summary_table_B10", clear 
append using `tf'

replace step_3_reallocation = round(step_3_reallocation,0.1)

save "$work/summary_table_B10", replace

label variable Outward_DI_country_IMF "Income received on outward DI as reported by country (IMF)"
label variable Inward_DI_country_IMF "Income paid on inward DI as reported by country (IMF)"
label variable total_DI_discrepancy "DI income total discrepancy (outward income received - inward income paid)"
label variable missing_income "Missing income paid reported by partners (incl. values for NLD IRL LUX from B11)"
label variable DI_equity_income_surplus "Stock data (when no partner data available)"
label variable correction "Missing income received reported by partners"
label variable gap_inward "Gap in income paid (country report - partner report)"
label variable gap_outward "Gap in income received (country report - partner report)"
label variable reallocation "Reallocating the residual DI income gap based on country-specific income gaps"
label variable step_1_missing_income "Step 1: total DI discrepancy - net missing income (missing income received - missing income paid)"
label variable step_2_stock_data "Step 2: Step 1 - income from stock data"
label variable step_3_reallocation "Step 3: Step 2 - total reallocated value (= 0 for full reallocation of DI disc)"


export excel using "$root/output/summary_table_B10.xlsx", firstrow(varl) sheet("Table B10", replace) keepcellfmt 


// ------------------------------------ // 
//summary table U1
// ------------------------------------ //

use "$work/shifted_profits_U1_2016", clear

drop if ISO3 == "ROW"

drop country ISO3 tax_haven

collapse (sum) GDP corp_wage local_corp_wage foreign_corp_wage pre_tax_corp_profits tax_prof profit_correction corptaxrev pre_tax_local_profits pre_tax_foreign_profits net_op_profit SPE_profits unrecorded_foreign_profits foreign_corptaxrev profits_offshore_mutual_funds shifted_profits (mean) corporate_ETR profit_wage_ratio_all profit_wage_ratio_local profit_wage_ratio_foreign US_outward_P_W_ratio, by(group)

replace group = "Major developing countries" if group == "DEV"
replace group = "OECD countries" if group == "OECD"
replace group = "OECD tax havens" if group == "OECD_TH"
replace group = "Non-OECD tax havens" if group == "TH"
replace group = "World total" if group == "other"

sum pre_tax_foreign_profits if group == "World total"
local wld_fp = r(mean)

gen year = 2016 
gen shifted_profits_ratio_fp = shifted_profits / `wld_fp'
gen net_op_profit_ratio_fp = net_op_profit / `wld_fp'
gen unrecorded_fp_ratio_fp = unrecorded_foreign_profits / `wld_fp'
gen foreign_corptaxrev_ratio_fp = foreign_corptaxrev / `wld_fp'

order year 

save "$work/summary_table_U1", replace 


use "$work/shifted_profits_U1_2017", clear

drop if ISO3 == "ROW"

drop country ISO3 tax_haven

collapse (sum) GDP corp_wage local_corp_wage foreign_corp_wage pre_tax_corp_profits tax_prof profit_correction corptaxrev pre_tax_local_profits pre_tax_foreign_profits net_op_profit SPE_profits unrecorded_foreign_profits foreign_corptaxrev profits_offshore_mutual_funds shifted_profits (mean) corporate_ETR profit_wage_ratio_all profit_wage_ratio_local profit_wage_ratio_foreign US_outward_P_W_ratio, by(group)

replace group = "Major developing countries" if group == "DEV"
replace group = "OECD countries" if group == "OECD"
replace group = "OECD tax havens" if group == "OECD_TH"
replace group = "Non-OECD tax havens" if group == "TH"
replace group = "World total" if group == "other"

sum pre_tax_foreign_profits if group == "World total"
local wld_fp = r(mean)

gen year = 2017 
gen shifted_profits_ratio_fp = shifted_profits / `wld_fp'
gen net_op_profit_ratio_fp = net_op_profit / `wld_fp'
gen unrecorded_fp_ratio_fp = unrecorded_foreign_profits / `wld_fp'
gen foreign_corptaxrev_ratio_fp = foreign_corptaxrev / `wld_fp'

order year 

tempfile tf1 
save `tf1', replace 

use "$work/summary_table_U1", clear
append using `tf1'

save "$work/summary_table_U1", replace 


use "$work/shifted_profits_U1_2018", clear

drop if ISO3 == "ROW"

drop country ISO3 tax_haven

collapse (sum) GDP corp_wage local_corp_wage foreign_corp_wage pre_tax_corp_profits tax_prof profit_correction corptaxrev pre_tax_local_profits pre_tax_foreign_profits net_op_profit SPE_profits unrecorded_foreign_profits foreign_corptaxrev profits_offshore_mutual_funds shifted_profits (mean) corporate_ETR profit_wage_ratio_all profit_wage_ratio_local profit_wage_ratio_foreign US_outward_P_W_ratio, by(group)

replace group = "Major developing countries" if group == "DEV"
replace group = "OECD countries" if group == "OECD"
replace group = "OECD tax havens" if group == "OECD_TH"
replace group = "Non-OECD tax havens" if group == "TH"
replace group = "World total" if group == "other"

sum pre_tax_foreign_profits if group == "World total"
local wld_fp = r(mean)

gen year = 2018
gen shifted_profits_ratio_fp = shifted_profits / `wld_fp'
gen net_op_profit_ratio_fp = net_op_profit / `wld_fp'
gen unrecorded_fp_ratio_fp = unrecorded_foreign_profits / `wld_fp'
gen foreign_corptaxrev_ratio_fp = foreign_corptaxrev / `wld_fp'

order year 

tempfile tf1 
save `tf1', replace 

use "$work/summary_table_U1", clear
append using `tf1'

save "$work/summary_table_U1", replace

use "$work/shifted_profits_U1_2019", clear

drop if ISO3 == "ROW"

drop country ISO3 tax_haven

collapse (sum) GDP corp_wage local_corp_wage foreign_corp_wage pre_tax_corp_profits tax_prof profit_correction corptaxrev pre_tax_local_profits pre_tax_foreign_profits net_op_profit SPE_profits unrecorded_foreign_profits foreign_corptaxrev profits_offshore_mutual_funds shifted_profits (mean) corporate_ETR profit_wage_ratio_all profit_wage_ratio_local profit_wage_ratio_foreign US_outward_P_W_ratio, by(group)

replace group = "Major developing countries" if group == "DEV"
replace group = "OECD countries" if group == "OECD"
replace group = "OECD tax havens" if group == "OECD_TH"
replace group = "Non-OECD tax havens" if group == "TH"
replace group = "World total" if group == "other"

sum pre_tax_foreign_profits if group == "World total"
local wld_fp = r(mean)

gen year = 2019
gen shifted_profits_ratio_fp = shifted_profits / `wld_fp'
gen net_op_profit_ratio_fp = net_op_profit / `wld_fp'
gen unrecorded_fp_ratio_fp = unrecorded_foreign_profits / `wld_fp'
gen foreign_corptaxrev_ratio_fp = foreign_corptaxrev / `wld_fp'

order year 

tempfile tf1 
save `tf1', replace 

use "$work/summary_table_U1", clear
append using `tf1'

save "$work/summary_table_U1", replace


use "$work/shifted_profits_U1_2020", clear

drop if ISO3 == "ROW"

drop country ISO3 tax_haven

collapse (sum) GDP corp_wage local_corp_wage foreign_corp_wage pre_tax_corp_profits tax_prof profit_correction corptaxrev pre_tax_local_profits pre_tax_foreign_profits net_op_profit SPE_profits unrecorded_foreign_profits foreign_corptaxrev profits_offshore_mutual_funds shifted_profits (mean) corporate_ETR profit_wage_ratio_all profit_wage_ratio_local profit_wage_ratio_foreign US_outward_P_W_ratio, by(group)

replace group = "Major developing countries" if group == "DEV"
replace group = "OECD countries" if group == "OECD"
replace group = "OECD tax havens" if group == "OECD_TH"
replace group = "Non-OECD tax havens" if group == "TH"
replace group = "World total" if group == "other"

sum pre_tax_foreign_profits if group == "World total"
local wld_fp = r(mean)

gen year = 2020
gen shifted_profits_ratio_fp = shifted_profits / `wld_fp'
gen net_op_profit_ratio_fp = net_op_profit / `wld_fp'
gen unrecorded_fp_ratio_fp = unrecorded_foreign_profits / `wld_fp'
gen foreign_corptaxrev_ratio_fp = foreign_corptaxrev / `wld_fp'

order year 

tempfile tf1 
save `tf1', replace 

use "$work/summary_table_U1", clear
append using `tf1'

save "$work/summary_table_U1", replace



use "$work/shifted_profits_U1_2021", clear

drop if ISO3 == "ROW"

drop country ISO3 tax_haven

collapse (sum) GDP corp_wage local_corp_wage foreign_corp_wage pre_tax_corp_profits tax_prof profit_correction corptaxrev pre_tax_local_profits pre_tax_foreign_profits net_op_profit SPE_profits unrecorded_foreign_profits foreign_corptaxrev profits_offshore_mutual_funds shifted_profits (mean) corporate_ETR profit_wage_ratio_all profit_wage_ratio_local profit_wage_ratio_foreign US_outward_P_W_ratio, by(group)

replace group = "Major developing countries" if group == "DEV"
replace group = "OECD countries" if group == "OECD"
replace group = "OECD tax havens" if group == "OECD_TH"
replace group = "Non-OECD tax havens" if group == "TH"
replace group = "World total" if group == "other"

sum pre_tax_foreign_profits if group == "World total"
local wld_fp = r(mean)

gen year = 2021
gen shifted_profits_ratio_fp = shifted_profits / `wld_fp'
gen net_op_profit_ratio_fp = net_op_profit / `wld_fp'
gen unrecorded_fp_ratio_fp = unrecorded_foreign_profits / `wld_fp'
gen foreign_corptaxrev_ratio_fp = foreign_corptaxrev / `wld_fp'

order year 

tempfile tf1 
save `tf1', replace 

use "$work/summary_table_U1", clear
append using `tf1'

save "$work/summary_table_U1", replace

label variable group "Country group"
label variable GDP "Gross domestic product"
label variable corp_wage "Total corporate wage"
label variable local_corp_wage "Corporate wage domestic sector"
label variable foreign_corp_wage "Corporate wage foreign sector"
label variable pre_tax_corp_profits "Total corporate profits (pre-tax)"
label variable tax_prof "Total corporate profits (OECD 14a)"
label variable profit_correction "Correcting profits (offshore mutual funds)"
label variable corptaxrev "Corporate tax revenue"
label variable corporate_ETR "Corporate effective tax rate"
label variable pre_tax_local_profits "Local corporate profits (pre-tax)"
label variable pre_tax_foreign_profits "Foreign corporate profits (pre-tax)"
label variable net_op_profit "FDI equity income of operating units"
label variable SPE_profits "Profits of special purpose entities"
label variable unrecorded_foreign_profits "Unrecorded profits imputed from FDI discrepancies (table B10)"
label variable foreign_corptaxrev "Corporate tax paid on foreign profits"
label variable profits_offshore_mutual_funds "Profits of offshore mutual funds"
label variable profit_wage_ratio_all "Profit-to-wage ratio (all sectors)"
label variable profit_wage_ratio_local "Profit-to-wage ratio (local sector)"
label variable profit_wage_ratio_foreign "Profit-to-wage ratio (foreign sector)"
label variable US_outward_P_W_ratio "Profit-to-wage ratio of US MNE foreign entities"
label variable shifted_profits "Total profits shifted by tax haven" 
label variable shifted_profits_ratio_fp "Ratio shifted profits over total foreign profits"
label variable net_op_profit_ratio_fp "Ratio net operating profits over total foreign profits"
label variable unrecorded_fp_ratio_fp "Ratio unrecorded foreign profits over total foreign profits"
label variable foreign_corptaxrev_ratio_fp "Ratio foreign tax revenue over total foreign profits"

* Define the Excel file path
local excel_file = "$root/output/summary_table_U1.xlsx"

* Open the existing Excel file
putexcel set "`excel_file'", modify

*export excel using "$root/output/summary_table_U1.xlsx", firstrow(varl) sheet("Table U1", replace) keepcellfmt 

