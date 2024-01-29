cap log close
log using "${logfiles}/1.nighttime_data_prep.log", replace

* Prepare datasets
* Leonardo Penaloza-Pacheco, Vaios Triantafyllou, and Gonzalo Martinez
* 1.nighttime_data_prep.do 

*---------------------------------------------------------------------------*
* Purpose: Prepare datasets for nighttime lights.
*---------------------------------------------------------------------------*

// ------------------------------------------------------------------------ //
** Cluster creations
// ------------------------------------------------------------------------ //

foreach k in distances_and_elevation distances_individual{
	forval v = 1/20 {
		* Handle the special case for file 12
		if (`v' == 1 | `v' == 12) {
			foreach suffix in a b c {
				* Process each of the 1a, 1b, 1c, 12a, 12b, 12c files
				import delimited "${nighttime_ivas_processed}/local_`v'`suffix'_with_`k'.csv", clear 

				* Rest of the processing steps
				duplicates tag east west south north, gen(aux)
				tab aux
				keep if aux==0
				drop aux

				sort west south

				* Loop through to create groups of different sizes
				forval i = 1/3 {
					bysort south: gen temp_west_seq = _n
					gen west_group`i' = ceil(temp_west_seq / (4 * `i'))

					bysort west: gen temp_south_seq = _n
					gen south_group`i' = ceil(temp_south_seq / (4 * `i'))

					egen group_id`i' = group(west_group`i' south_group`i')

					drop temp_west_seq temp_south_seq south_group* west_group*
				}

				save "${nighttime_ivas_processed}/local_`v'`suffix'_with_`k'_unique.dta", replace 
			}
		}
		else {
			* Process files 2 to 11 and 13 to 20
			import delimited "${nighttime_ivas_processed}/local_`v'_with_`k'.csv", clear 

			* Rest of the processing steps
			duplicates tag east west south north, gen(aux)
			tab aux
			keep if aux==0
			drop aux

			sort west south

			* Loop through to create groups of different sizes
			forval i = 1/3 {
				bysort south: gen temp_west_seq = _n
				gen west_group`i' = ceil(temp_west_seq / (4 * `i'))

				bysort west: gen temp_south_seq = _n
				gen south_group`i' = ceil(temp_south_seq / (4 * `i'))

				egen group_id`i' = group(west_group`i' south_group`i')

				drop temp_west_seq temp_south_seq south_group* west_group*
			}

			save "${nighttime_ivas_processed}/local_`v'_with_`k'_unique.dta", replace 
		}
	}
}

// ------------------------------------------------------------------------ //
** Combine datasets in one
// ------------------------------------------------------------------------ //

foreach k in distances_and_elevation distances_individual{
	use "${nighttime_ivas_processed}/local_1a_with_`k'_unique.dta", clear 

	forval v = 1/20 {
		if (`v' == 1) {
			foreach suffix in b c {
				* Process each of the 1b, 1c files
				append using "${nighttime_ivas_processed}/local_1`suffix'_with_`k'_unique.dta"
			}
		}
		else if (`v' == 12) {
			foreach suffix in a b c {
				* Process each of the 12a, 12b, 12c files
				append using "${nighttime_ivas_processed}/local_12`suffix'_with_`k'_unique.dta"
			}
		}
		else {
			append using "${nighttime_ivas_processed}/local_`v'_with_`k'_unique.dta"
		}
	}

	save "${nighttime_ivas_processed}/all_ivas_with_`k'_unique.dta", replace 
}

// ------------------------------------------------------------------------ //
** Prepare datasets
// ------------------------------------------------------------------------ //

use "${nighttime_ivas_processed}/all_ivas_with_distances_individual_unique.dta", clear 

gen village=inrange(group,12,20)

rename _average nighttime_average2013 
rename _average_masked nighttime_average_masked2013 
rename _cf_cvg nighttime_cf_cvg2013 
rename _cvg nighttime_cvg2013 
rename _maximum nighttime_maximum2013 
rename _median nighttime_median2013 
rename _median_masked nighttime_median_masked2013 
rename _minimum nighttime_minimum2013 

rename v9 nighttime_average2014 
rename v10 nighttime_average_masked2014 
rename v11 nighttime_cf_cvg2014
rename v12 nighttime_cvg2014 
rename v13 nighttime_maximum2014 
rename v14 nighttime_median2014 
rename v15 nighttime_median_masked2014 
rename v16 nighttime_minimum2014 

rename v17 nighttime_average2015 
rename v18 nighttime_average_masked2015 
rename v19 nighttime_cf_cvg2015
rename v20 nighttime_cvg2015 
rename v21 nighttime_maximum2015 
rename v22 nighttime_median2015
rename v23 nighttime_median_masked2015 
rename v24 nighttime_minimum2015 

rename v25 nighttime_average2016 
rename v26 nighttime_average_masked2016 
rename v27 nighttime_cf_cvg2016
rename v28 nighttime_cvg2016 
rename v29 nighttime_maximum2016 
rename v30 nighttime_median2016
rename v31 nighttime_median_masked2016 
rename v32 nighttime_minimum2016 

rename v33 nighttime_average2017 
rename v34 nighttime_average_masked2017 
rename v35 nighttime_cf_cvg2017
rename v36 nighttime_cvg2017 
rename v37 nighttime_maximum2017 
rename v38 nighttime_median2017
rename v39 nighttime_median_masked2017 
rename v40 nighttime_minimum2017 

rename v41 nighttime_average2018
rename v42 nighttime_average_masked2018 
rename v43 nighttime_cf_cvg2018
rename v44 nighttime_cvg2018 
rename v45 nighttime_maximum2018 
rename v46 nighttime_median2018
rename v47 nighttime_median_masked2018 
rename v48 nighttime_minimum2018 

rename v49 nighttime_average2019
rename v50 nighttime_average_masked2019 
rename v51 nighttime_cf_cvg2019
rename v52 nighttime_cvg2019 
rename v53 nighttime_maximum2019 
rename v54 nighttime_median2019
rename v55 nighttime_median_masked2019 
rename v56 nighttime_minimum2019 

rename v57 nighttime_average2020
rename v58 nighttime_average_masked2020 
rename v59 nighttime_cf_cvg2020
rename v60 nighttime_cvg2020 
rename v61 nighttime_maximum2020 
rename v62 nighttime_median2020
rename v63 nighttime_median_masked2020 
rename v64 nighttime_minimum2020 

save "${nighttime_ivas_processed}/all_ivas_with_distances_individual_unique_prepared.dta", replace

log close
