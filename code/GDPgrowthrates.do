//----------------------------------------
//Step 2c: Structure GDP growth
//----------------------------------------	

//this do file structures wb GDP data by country for further analysis

//(i)//
//download and clean data

use "$work/wbdata", clear
 rename gdp GDP
 rename CountryCode location
 rename year time
 replace GDP=GDP/1000000

* ssc instal _gwtmean
 gen GDP$temp=GDP if time==$temp
 egen inc_group_temp=cut(GDP$temp), group(4)
 egen inc_group=total(inc_group), by(location)
 encode location, gen(id)
 tsset id time
 gen GDPgrowth15to$temp=GDP/L1.GDP if time==$temp
 egen WTGDPgrowth15to$temp=wtmean(GDPgrowth), weight(GDP$temp) by(inc_group time)
 
 drop if GDP==.
 
// upload data from 2015 and accout for GDP growth for missing countries


 

insobs 1 
replace location = "AIA" if location ==""							
replace GDP = 291.932109 if location == "AIA"				//Anguilla
replace GDP = GDP * $world_growth if location == "AIA"
replace time = $temp if location == "AIA"

insobs 1
replace location = "BES" if location == ""
replace GDP = 415.64614 if location == "BES"				//Bonaire
replace GDP = GDP * $world_growth if location == "BES"
replace time = $temp if location == "BES"

insobs 1
replace location = "GGY" if location == ""
replace GDP = 4402.115488 if location == "GGY"				//Guernsey
replace GDP = GDP * $world_growth if location == "GGY"
replace time = $temp if location == "GGY"

insobs 1
replace location = "GIB" if location == ""
replace GDP = 2588.7638 if location == "GIB"				//Gibraltar
replace GDP = GDP * $world_growth if location == "GIB"	
replace time = $temp if location == "GIB"

insobs 1
replace location = "JEY" if location == ""
replace GDP = 6360.180105 if location == "JEY"				//Jersey
replace GDP = GDP  * $world_growth if location == "JEY"
replace time = $temp if location == "JEY"

insobs 1
replace location = "VGB" if location == ""
replace GDP = 928.242 if location == "VGB"					//British Virgin Islands
replace GDP = GDP * $world_growth if location == "VGB"
replace time = $temp if location == "VGB"


//GDP value missing for Isle of Man in 2021

if $temp >= 2021{
insobs 1
replace location = "IMN" if location == ""
replace GDP = 6792.42 if location == "IMN"					//Isle of Man
replace GDP = GDP * $world_growth if location == "IMN"
replace time = $temp if time==. & location == "IMN"
}



 
*(ii)*
//save data in separate Stata file 

preserve
keep if time==$temp
keep location GDPgrowth15to$temp GDP 
save "$work/GDPgrowth_$temp", replace
restore


