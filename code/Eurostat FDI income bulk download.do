//-----------------------------------------------
//Step 5a: Eurostat FDI income data bluk download
//-----------------------------------------------	

set timeout1 500
eurostatuse bop_fdi6_inc, clear 		//bulk download of FDI income transactions
save "$work/bop_fdi6_inc", replace
use "$work/bop_fdi6_inc", replace
*drop if partner=="EU27" 				//drop new additional partners so rest of old code works
*drop if partner=="EU28" 				//drop new additional partners so rest of old code works
*drop if partner_l=="Albania" 			//drop new additional partners so rest of old code works
save "$work/bop_fdi6_inc", replace

