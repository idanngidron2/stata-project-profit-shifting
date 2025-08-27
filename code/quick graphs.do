//quick graphs do 

use "$work/table_C1_2016", clear 

keep if ISO3 == "DEU"| ISO3 == "FRA" | ISO3 == "NLD" | ISO3 == "LUX" | ISO3 == "USA" | ISO3 == "CHN" | ISO3 == "ROW" | ISO3 == "WLD"

keep Belgium 