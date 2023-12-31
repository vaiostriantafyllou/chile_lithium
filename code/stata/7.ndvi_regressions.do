cap log close
log using "${logfiles}/7.regressions_ndvi.log", replace

* NDVI Regressions
* Leonardo Penaloza-Pacheco, Vaios Triantafyllou, and Gonzalo Martinez
* 7.regressions_ndvi.do 

*---------------------------------------------------------------------------*
* Purpose: Run relevant regressions for NDVI.

* This file takes the processed NDVI data, combines it with the instrument and runs the relevant regressions.
*---------------------------------------------------------------------------*

// ------------------------------------------------------------------------ //
** Effect on NDVI
// ------------------------------------------------------------------------ //

use  "${ndvi_ivas_processed}/all_ivas_with_distances_individual_unique_prepared.dta" , clear

egen min_distance=rowmin(distance_ca2015 distance_socaire5 distance_allana1 distance_camar2 distance_mullay1)

keep if min_distance<=50

gen id=_n

keep ndvi* id distance group* latitude longitude distance_ca2015 distance_socaire5 distance_allana1 distance_camar2 distance_mullay1 min_distance

gen aux=1

merge m:1 aux using "${ev_processed}/ev_data_wide.dta", keep(3) nogen

forvalues i=2013/2020 {
gen inst`i'=min_distance/(value`i')
}

keep ndvi* id inst* group* longitude latitude

reshape long ndvi inst , i(id longitude latitude) j(year)

merge m:1 year using "${ev_processed}/ev_data.dta", keep(3) nogen

summ ndvi
replace ndvi=(ndvi-r(mean))/r(sd)

summ inst
replace inst=(inst-r(mean))/r(sd)

gen village=inrange(group,12,20)

gen inst_vill=inst*village

eststo clear

eststo m_var_1: reghdfe ndvi inst, cluster(id) absorb(year id)
	estadd local control1 "Yes"
	estadd local control2 "Yes"
	estadd local control3 "No"
	

eststo m_var_2: reghdfe ndvi inst, cluster(id) absorb(id c.longitude#i.year c.latitude#i.year)
	estadd local control1 "Yes"
	estadd local control2 "Yes"
	estadd local control3 "Yes"

	
eststo n_var_1: reghdfe ndvi inst if village==1, cluster(id) absorb(year id)
	estadd local control1 "Yes"
	estadd local control2 "Yes"
	estadd local control3 "No"
	

eststo n_var_2: reghdfe ndvi inst if village==1, cluster(id) absorb(id c.longitude#i.year c.latitude#i.year)
	estadd local control1 "Yes"
	estadd local control2 "Yes"
	estadd local control3 "Yes"

eststo o_var_1: reghdfe ndvi inst if village==0, cluster(id) absorb(year id)
	estadd local control1 "Yes"
	estadd local control2 "Yes"
	estadd local control3 "No"
	

eststo o_var_2: reghdfe ndvi inst if village==0, cluster(id) absorb(id c.longitude#i.year c.latitude#i.year)
	estadd local control1 "Yes"
	estadd local control2 "Yes"
	estadd local control3 "Yes"


esttab m_* using "$results_tab/reg_res.tex", ///
			 style(tex) keep(inst) c(b(star fmt(3)) se(par fmt(3))) ///
			 stats(q N k control1 control2 control3, fmt(%12.3fc %12.0fc %12.2fc %12.0fc %12.0fc) ///
			 labels("\addlinespace\midrule \vspace{-0.4cm}" "Observations" ///
			 "\addlinespace\midrule \vspace{-0.4cm}" "Year FE" "Location FE" "Location x Year FE")) ///
			 collabels(none) eqlabels(none)  ///
			 varlabels(inst "Overall")  ///
			 prehead(\begin{tabular}{lccc}\toprule) posthead(\midrule) ///
			  mlabels(none) mgroups(none) ///
			 postfoot(\bottomrule) replace starlevels(* 0.1 ** 0.05 *** 0.01)  booktabs nolines 

esttab n_* using "$results_tab/reg_res.tex", ///
			 style(tex) keep(inst) c(b(star fmt(3)) se(par fmt(3))) ///
			 stats(q N k control1 control2 control3, fmt(%12.3fc %12.0fc %12.2fc %12.0fc %12.0fc) ///
			 labels("\addlinespace\midrule \vspace{-0.4cm}" "Observations" ///
			 "\addlinespace\midrule \vspace{-0.4cm}" "Year FE" "Location FE" "Location x Year FE")) ///
			 collabels(none) eqlabels(none)  ///
			 varlabels(inst "Villages")  ///
			 prehead(\toprule) posthead(\midrule) ///
			  mlabels(none) mgroups(none) ///
			 postfoot(\bottomrule) append starlevels(* 0.1 ** 0.05 *** 0.01)  booktabs nolines 

esttab o_* using "$results_tab/reg_res.tex", ///
			 style(tex) keep(inst) c(b(star fmt(3)) se(par fmt(3))) ///
			 stats(q N k control1 control2 control3, fmt(%12.3fc %12.0fc %12.2fc %12.0fc %12.0fc) ///
			 labels("\addlinespace\midrule \vspace{-0.4cm}" "Observations" ///
			 "\addlinespace\midrule \vspace{-0.4cm}" "Year FE" "Location FE" "Location x Year FE")) ///
			 collabels(none) eqlabels(none)  ///
			 varlabels(inst "Reserves")  ///
			 prehead(\toprule) posthead(\midrule) ///
			  mlabels(none) mgroups(none) ///
			 postfoot(\bottomrule\end{tabular} @note) append starlevels(* 0.1 ** 0.05 *** 0.01)  booktabs nolines 
			 
			 
** Repeat, clustering at different levels
forval v = 1/3 {
	eststo clear

	eststo m_var_1: reghdfe ndvi inst, cluster(group_id`v') absorb(year id)
		estadd local control1 "Yes"
		estadd local control2 "Yes"
		estadd local control3 "No"
		

	eststo m_var_2: reghdfe ndvi inst, cluster(group_id`v') absorb(id c.longitude#i.year c.latitude#i.year)
		estadd local control1 "Yes"
		estadd local control2 "Yes"
		estadd local control3 "Yes"

		
	eststo n_var_1: reghdfe ndvi inst if village==1, cluster(group_id`v') absorb(year id)
		estadd local control1 "Yes"
		estadd local control2 "Yes"
		estadd local control3 "No"
		

	eststo n_var_2: reghdfe ndvi inst if village==1, cluster(group_id`v') absorb(id c.longitude#i.year c.latitude#i.year)
	    estadd local control1 "Yes"
		estadd local control2 "Yes"
		estadd local control3 "Yes"

	eststo o_var_1: reghdfe ndvi inst if village==0, cluster(group_id`v') absorb(year id)
		estadd local control1 "Yes"
		estadd local control2 "Yes"
		estadd local control3 "No"
		

	eststo o_var_2: reghdfe ndvi inst if village==0, cluster(group_id`v') absorb(id c.longitude#i.year c.latitude#i.year)
		estadd local control1 "Yes"
		estadd local control2 "Yes"
		estadd local control3 "Yes"


		
	esttab m_* using "$results_tab/reg_res`v'", ///
				 style(tex) keep(inst) c(b(star fmt(3)) se(par fmt(3))) ///
				 stats(q N k control1 control2 control3, fmt(%12.3fc %12.0fc %12.2fc %12.0fc %12.0fc) ///
				 labels("\addlinespace\midrule \vspace{-0.4cm}" "Observations" ///
				 "\addlinespace\midrule \vspace{-0.4cm}" "Year FE" "Location FE" "Location x Year FE")) ///
				 collabels(none) eqlabels(none)  ///
				 varlabels(inst "Villages")  ///
				 prehead(\begin{tabular}{lccc}\toprule) posthead(\midrule) ///
				  mlabels(none) mgroups(none) ///
				 postfoot(\bottomrule) replace starlevels(* 0.1 ** 0.05 *** 0.01)  booktabs nolines 

	esttab n_* using "$results_tab/reg_res`v'.tex", ///
				 style(tex) keep(inst) c(b(star fmt(3)) se(par fmt(3))) ///
				 stats(q N k control1 control2 control3, fmt(%12.3fc %12.0fc %12.2fc %12.0fc %12.0fc) ///
				 labels("\addlinespace\midrule \vspace{-0.4cm}" "Observations" ///
				 "\addlinespace\midrule \vspace{-0.4cm}" "Year FE" "Location FE" "Location x Year FE")) ///
				 collabels(none) eqlabels(none)  ///
				 varlabels(inst "Overall")  ///
				 prehead(\toprule) posthead(\midrule) ///
				  mlabels(none) mgroups(none) ///
				 postfoot(\bottomrule) append starlevels(* 0.1 ** 0.05 *** 0.01)  booktabs nolines 

	esttab o_* using "$results_tab/reg_res`v'.tex", ///
				 style(tex) keep(inst) c(b(star fmt(3)) se(par fmt(3))) ///
				 stats(q N k control1 control2 control3, fmt(%12.3fc %12.0fc %12.2fc %12.0fc %12.0fc) ///
				 labels("\addlinespace\midrule \vspace{-0.4cm}" "Observations" ///
				 "\addlinespace\midrule \vspace{-0.4cm}" "Year FE" "Location FE" "Location x Year FE")) ///
				 collabels(none) eqlabels(none)  ///
				 varlabels(inst "Reserves")  ///
				 prehead(\toprule) posthead(\midrule) ///
				  mlabels(none) mgroups(none) ///
				 postfoot(\bottomrule\end{tabular} @note) append starlevels(* 0.1 ** 0.05 *** 0.01)  booktabs nolines 
}	 



// -------------------------------------------------------------------------- //
** Effect on NDVI by group
// -------------------------------------------------------------------------- //

use  "${ndvi_ivas_processed}/all_ivas_with_distances_individual_unique_prepared.dta" , clear

egen min_distance=rowmin(distance_ca2015 distance_socaire5 distance_allana1 distance_camar2 distance_mullay1)

keep if min_distance<=50

gen id=_n

keep ndvi* id distance group* latitude longitude distance_ca2015 distance_socaire5 distance_allana1 distance_camar2 distance_mullay1 min_distance

gen aux=1

merge m:1 aux using "${ev_processed}/ev_data_wide.dta", keep(3) nogen

forvalues i=2013/2020 {
gen inst`i'=min_distance/(value`i')
}

keep ndvi* id inst* group* longitude latitude

reshape long ndvi inst , i(id longitude latitude) j(year)

merge m:1 year using "${ev_processed}/ev_data.dta", keep(3) nogen

forvalues i = 12(1)20 {
	
	summ ndvi if group ==`i'
	replace ndvi=(ndvi-r(mean))/r(sd) if group ==`i'
	
	summ inst if group ==`i'
	replace inst=(inst-r(mean))/r(sd) if group ==`i'

}

eststo clear

eststo m_var_1: reghdfe ndvi inst if group==12, cluster(id) absorb(year id)
		estadd local control1 "Yes"
		estadd local control2 "Yes"
		estadd local control3 "No"
		

	eststo m_var_2: reghdfe ndvi inst if group==12, cluster(id) absorb(id c.longitude#i.year c.latitude#i.year)
		estadd local control1 "Yes"
		estadd local control2 "Yes"
		estadd local control3 "Yes"
		
	
	esttab m_* using "$results_tab/reg_res_by_iva.tex", ///
				 style(tex) keep(inst) c(b(star fmt(3)) se(par fmt(3))) ///
				 stats(q N k control1 control2 control3, fmt(%12.3fc %12.0fc %12.2fc %12.0fc %12.0fc) ///
				 labels("\addlinespace\midrule \vspace{-0.4cm}" "Observations" ///
				 "\addlinespace\midrule \vspace{-0.4cm}" "Year FE" "Location FE" "Location x Year FE")) ///
				 collabels(none) eqlabels(none)  ///
				 varlabels(inst "Effect on group 12")  ///
				 prehead(\begin{tabular}{lccc}\toprule) posthead(\midrule) ///
				  mlabels(none) mgroups(none) ///
				 postfoot(\bottomrule) replace starlevels(* 0.1 ** 0.05 *** 0.01)  booktabs 

forvalues i = 13(1)20 {
	
	eststo clear
	
	eststo m_var_1: reghdfe ndvi inst if group==`i', cluster(id) absorb(year id)
		estadd local control1 "Yes"
		estadd local control2 "Yes"
		estadd local control3 "No"
		

	eststo m_var_2: reghdfe ndvi inst if group==`i', cluster(id) absorb(id c.longitude#i.year c.latitude#i.year)
		estadd local control1 "Yes"
		estadd local control2 "Yes"
		estadd local control3 "Yes"
		
	
	esttab m_* using "$results_tab/reg_res_by_iva.tex", ///
				 style(tex) keep(inst) c(b(star fmt(3)) se(par fmt(3))) ///
				 stats(q N k control1 control2 control3, fmt(%12.3fc %12.0fc %12.2fc %12.0fc %12.0fc) ///
				 labels("\addlinespace\midrule \vspace{-0.4cm}" "Observations" ///
				 "\addlinespace\midrule \vspace{-0.4cm}" "Year FE" "Location FE" "Location x Year FE")) ///
				 collabels(none) eqlabels(none)  ///
				 varlabels(inst "Effect on group `i'")  ///
				 prehead(\begin{tabular}{lccc}\toprule) posthead(\midrule) ///
				  mlabels(none) mgroups(none) ///
				 postfoot(\bottomrule) append starlevels(* 0.1 ** 0.05 *** 0.01)  booktabs nolines 

}



*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*

// -------------------------------------------------------------------------- //
** Effect on NDVI for different thresholds
// -------------------------------------------------------------------------- //

use  "$ndvi_processed/local_all_with_distance_wells.dta" , clear
egen min_distance=rowmin(distance_ca2015 distance_socaire5 distance_allana1 distance_camar2 distance_mullay1)

keep if min_distance<=

rename _ndvi ndvi2013
rename v4 ndvi2014
rename v5 ndvi2015
rename v6 ndvi2016
rename v7 ndvi2017
rename v8 ndvi2018
rename v9 ndvi2019
rename v10 ndvi2020

gen id=_n


keep ndvi* id distance group latitude longitude distance_ca2015 distance_socaire5 distance_allana1 distance_camar2 distance_mullay1 max_distance min_distance

gen aux=1

merge m:1 aux using "${path_ev_output}/ev_data_wide.dta", keep(3) nogen

forvalues i=2013/2020 {
gen inst`i'=min_distance/(value`i')
}


keep ndvi* id inst* group longitude latitude max_distance min_distance


reshape long ndvi inst, i(id) j(year)

merge m:1 year using "${path_ev_output}/ev_data.dta", keep(3) nogen


summ ndvi
replace ndvi=(ndvi-r(mean))/r(sd)


summ inst
replace inst=(inst-r(mean))/r(sd)

gen village=inrange(group,12,20)


eststo clear 

local values "75 70 65 60"
foreach i of local values {


eststo m_var_`i'_1: reghdfe ndvi inst if min_distance<=`i', cluster(id) absorb(year id)
	estadd local control1 "Yes"
	estadd local control2 "Yes"
	estadd local control3 "No"
	

eststo m_var_`i'_2: reghdfe ndvi inst if min_distance<=`i', cluster(id) absorb(id c.longitude#i.year c.latitude#i.year)
	estadd local control1 "Yes"
	estadd local control2 "Yes"
	estadd local control3 "Yes"

	
eststo n_var_`i'_1: reghdfe ndvi inst if village==1 & min_distance<=`i', cluster(id) absorb(year id)
	estadd local control1 "Yes"
	estadd local control2 "Yes"
	estadd local control3 "No"
	

eststo n_var_`i'_2: reghdfe ndvi inst if village==1 & min_distance<=`i', cluster(id) absorb(id c.longitude#i.year c.latitude#i.year)
	estadd local control2 "Yes"
	estadd local control3 "Yes"

eststo o_var_`i'_1: reghdfe ndvi inst if village==0 & min_distance<=`i', cluster(id) absorb(year id)
	estadd local control1 "Yes"
	estadd local control2 "Yes"
	estadd local control3 "No"
	

eststo o_var_`i'_2: reghdfe ndvi inst if village==0 & min_distance<=`i', cluster(id) absorb(id c.longitude#i.year c.latitude#i.year)
	estadd local control1 "Yes"
	estadd local control2 "Yes"
	estadd local control3 "Yes"

}


local values "75 70 65 60"
foreach i of local values {

esttab m_var_`i'* using "$results_tab/reg_res_robust_`i'.tex", ///
			 style(tex) keep(inst) c(b(star fmt(3)) se(par fmt(3))) ///
			 stats(q N k control1 control2 control3, fmt(%12.3fc %12.0fc %12.2fc %12.0fc %12.0fc) ///
			 labels("\addlinespace\midrule \vspace{-0.4cm}" "Observations" ///
			 "\addlinespace\midrule \vspace{-0.4cm}" "Year FE" "Location FE" "Location x Year FE")) ///
			 collabels(none) eqlabels(none)  ///
			 varlabels(inst "Exposure to extraction")  ///
			 prehead(\begin{tabular}{lccc}\toprule) posthead(\midrule) ///
			  mlabels(none) mgroups(none) ///
			 postfoot(\bottomrule) replace starlevels(* 0.1 ** 0.05 *** 0.01)  booktabs nolines 

esttab n_var_`i'* using "$results_tab/reg_res_robust_`i'.tex", ///
			 style(tex) keep(inst) c(b(star fmt(3)) se(par fmt(3))) ///
			 stats(q N k control1 control2 control3, fmt(%12.3fc %12.0fc %12.2fc %12.0fc %12.0fc) ///
			 labels("\addlinespace\midrule \vspace{-0.4cm}" "Observations" ///
			 "\addlinespace\midrule \vspace{-0.4cm}" "Year FE" "Location FE" "Location x Year FE")) ///
			 collabels(none) eqlabels(none)  ///
			 varlabels(inst "Exposure to extraction")  ///
			 prehead(\toprule) posthead(\midrule) ///
			  mlabels(none) mgroups(none) ///
			 postfoot(\bottomrule) append starlevels(* 0.1 ** 0.05 *** 0.01)  booktabs nolines 
						
			 
esttab o_var_`i'* using "$results_tab/reg_res_robust_`i'.tex", ///
			 style(tex) keep(inst) c(b(star fmt(3)) se(par fmt(3))) ///
			 stats(q N k control1 control2 control3, fmt(%12.3fc %12.0fc %12.2fc %12.0fc %12.0fc) ///
			 labels("\addlinespace\midrule \vspace{-0.4cm}" "Observations" ///
			 "\addlinespace\midrule \vspace{-0.4cm}" "Year FE" "Location FE" "Location x Year FE")) ///
			 collabels(none) eqlabels(none)  ///
			 varlabels(inst "Exposure to extraction")  ///
			 prehead(\toprule) posthead(\midrule) ///
			  mlabels(none) mgroups(none) ///
			 postfoot(\bottomrule\end{tabular} @note) append starlevels(* 0.1 ** 0.05 *** 0.01)  booktabs nolines 


}
// -------------------------------------------------------------------------- //
** Non-parametric relationship between distance to Atacama Flat and NDVI change
// -------------------------------------------------------------------------- //

use  "$ndvi_processed/local_all_with_distance_wells.dta" , clear

rename _ndvi ndvi2013
rename v4 ndvi2014
rename v5 ndvi2015
rename v6 ndvi2016
rename v7 ndvi2017
rename v8 ndvi2018
rename v9 ndvi2019
rename v10 ndvi2020


gen id=_n

egen mean_distance=rowmean(distance_ca2015 distance_socaire5 distance_allana1 distance_camar2 distance_mullay1)

keep if mean_distance<=80


keep ndvi2013 ndvi2020 id mean_distance group


summ ndvi2013
replace ndvi2013=(ndvi2013-r(mean))/r(sd)

summ ndvi2020
replace ndvi2020=(ndvi2020-r(mean))/r(sd)



gen var_ndvi=(ndvi2020)-(ndvi2013)


twoway (lpolyci  var_ndvi mean_distance, acolor("red") clcolor("red") fintensity(inten20)) ///
	   (pci 0 5 0 80, lcolor(green) lpattern(dash)),  ///
	ylabel(, angle(horizontal)) legend(off) xtitle("Distance in KMs", size(*0.7))  scheme(white_tableau) ///
	subtitle("NDVI difference in SD", position(11) justification(left) size(*0.7)) ytitle("", size(*0)) plotregion(margin(-2)) xlabel(5(10)80, labsize(*0.7))  ylabel(, labsize(*0.7))
graph export "$results_fig/lpolyci_ndvi_distance.png", replace as(png)

twoway (lpolyci  var_ndvi mean_distance if inrange(group, 12,20), acolor("red") clcolor("red") fintensity(inten20)) ///
	   (pci 0 5 0 50, lcolor(green) lpattern(dash)),  ///
	ylabel(, angle(horizontal)) legend(off) xtitle("Distance in KMs", size(*0.7))  scheme(white_tableau) ///
	subtitle("NDVI difference in SD", position(11) justification(left) size(*0.7)) ytitle("", size(*0)) plotregion(margin(-2)) xlabel(5(10)50, labsize(*0.7))  ylabel(, labsize(*0.7))
graph export "$results_fig/lpolyci_ndvi_distance_old_IVAs.png", replace as(png)


// -------------------------------------------------------------------------- //
** Heterogeneous effects by baseline NDVI
// -------------------------------------------------------------------------- //

use  "$ndvi_processed/local_all_with_distance_correct.dta" , clear
keep if distance<=80

gen id=_n

reshape long ndvi, i(id) j(year)

merge m:1 year using "${path_ev_output}/ev_data.dta", keep(3) nogen

merge m:1 year using "${path_australia_output}/value_australia.dta", keep(3) nogen


gen inst=value/distance
gen inst2=value_australia/distance

summ ndvi
replace ndvi=(ndvi-r(mean))/r(sd)


summ inst
replace inst=(inst-r(mean))/r(sd)

summ inst2
replace inst2=(inst2-r(mean))/r(sd)

gen inst_vill=inst*village
gen inst2_vill=inst2*village

gen aux=ndvi if year==2013
bys id: egen ndvi2013=max(aux)

matrix a = J(100, 4, .)

reghdfe ndvi c.inst##c.ndvi2013, vce(robust) absorb(year id c.longitude#i.year c.latitude#i.year)

pctile percentile=ndvi2013, n(100)

forvalues i = 1(1)99 {
	qui summ percentile if _n==`i', d
	local p`i' = r(mean)
	
		lincom inst+c.inst#c.ndvi2013*(`p`i''), level(95)
		local beta=r(estimate)
		local lb = r(estimate)-1.96*r(se)
		local ub = r(estimate)+1.96*r(se)

		
		matrix a[`i',1] = `i' , `beta', `lb', `ub'
}

preserve
clear
svmat a
rename a1 percentil
rename a2 beta
rename a3 lb
rename a4 ub

label var percentil "Percentiles of initial level of heterogeneity variable"
label var beta "Estimated Effect"
twoway 	(rarea lb ub percentil, sort lcolor("red*.2") fcolor("red*.2")) ///
	(line beta percentil, lcolor("red") mfcolor("red") mlcolor("red")) (pci 0 0 0 100, lcolor(gs5) lpattern(dash)), ///
	ylabel(, angle(horizontal) labsize(*1.2)) legend(off)  ytitle(" ") xtitle("Percentiles of initial NDVI", size(*1.5)) scheme(white_tableau) subtitle("Effect of Lithium Extraction", position(11) justification(left) size(*1.1)) xlab(, labsize(*1.2))
graph export "$results_fig/het_ndvi.png", replace as(png)




clear
local values "9 10 11 12 14 15 16 19 23 25 26 27 28 29 31"
foreach i of local values {

append using "${ndvi_processed}/other_salars_with_distance_`i'.dta"

}

gen atacama=0

keep if distance<=50
rename _ndvi ndvi2013
rename v3 ndvi2014
rename v4 ndvi2015
rename v5 ndvi2016
rename v6 ndvi2017
rename v7 ndvi2018
rename v8 ndvi2019
rename v9 ndvi2020

keep ndvi2013 ndvi2014 ndvi2015 ndvi2016 ndvi2017 ndvi2018 ndvi2019 ndvi2020 longitude latitude distance atacama


gen id=_n

reshape long ndvi, i(id longitude latitude distance) j(year)


append using "$ndvi_processed/salar_1.dta"



log close
