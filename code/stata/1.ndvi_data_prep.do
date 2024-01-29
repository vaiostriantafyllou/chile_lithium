cap log close
log using "${logfiles}/1.ndvi_data_prep.log", replace

* Prepare datasets
* Leonardo Penaloza-Pacheco, Vaios Triantafyllou, and Gonzalo Martinez
* 1.ndvi_data_prep.do 

*---------------------------------------------------------------------------*
* Purpose: Prepare datasets for NDVI and electric vehicles.

*---------------------------------------------------------------------------*

// ------------------------------------------------------------------------ //
** Create EV dataset
// ------------------------------------------------------------------------ //

import delimited "${ev_raw}/IEA-EV-dataEV salesHistoricalCars.csv", clear 
keep if parameter == "EV sales"
keep if region == "Europe" | region == "USA" |  region == "China" 
collapse (sum) value, by(year)
save "${ev_processed}/ev_data.dta", replace 

use "${ev_processed}/ev_data.dta", clear
keep if inrange(year, 2013, 2020)
gen aux=1
reshape wide value, i(aux) j(year)
save "${ev_processed}/ev_data_wide.dta", replace

// ------------------------------------------------------------------------ //
** Cluster creations
// ------------------------------------------------------------------------ //

foreach k in distances distances_individual{
	forval v = 1/20 {
		* Handle the special case for file 12
		if (`v' == 1 | `v' == 12) {
			foreach suffix in a b c {
				* Process each of the 1a, 1b, 1c, 12a, 12b, 12c files
				import delimited "${ndvi_ivas_processed}/local_`v'`suffix'_with_`k'.csv", clear 

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

				save "${ndvi_ivas_processed}/local_`v'`suffix'_with_`k'_unique.dta", replace 
			}
		}
		else {
			* Process files 2 to 11 and 13 to 20
			import delimited "${ndvi_ivas_processed}/local_`v'_with_`k'.csv", clear 

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

			save "${ndvi_ivas_processed}/local_`v'_with_`k'_unique.dta", replace 
		}
	}
}

// ------------------------------------------------------------------------ //
** Combine datasets in one
// ------------------------------------------------------------------------ //

foreach k in distances distances_individual{
	use "${ndvi_ivas_processed}/local_1a_with_`k'_unique.dta", clear 

	forval v = 1/20 {
		if (`v' == 1) {
			foreach suffix in b c {
				* Process each of the 1b, 1c files
				append using "${ndvi_ivas_processed}/local_1`suffix'_with_`k'_unique.dta"
			}
		}
		else if (`v' == 12) {
			foreach suffix in a b c {
				* Process each of the 12a, 12b, 12c files
				append using "${ndvi_ivas_processed}/local_12`suffix'_with_`k'_unique.dta"
			}
		}
		else {
			append using "${ndvi_ivas_processed}/local_`v'_with_`k'_unique.dta"
		}
	}

	save "${ndvi_ivas_processed}/all_ivas_with_`k'_unique.dta", replace 
}

// ------------------------------------------------------------------------ //
** Prepare datasets
// ------------------------------------------------------------------------ //

use "${ndvi_ivas_processed}/all_ivas_with_distances_individual_unique.dta", clear 

gen village=inrange(group,12,20)

rename _ndvi ndvi2013 
rename v2 ndvi2014
rename v3 ndvi2015
rename v4 ndvi2016
rename v5 ndvi2017
rename v6 ndvi2018
rename v7 ndvi2019
rename v8 ndvi2020

save "${ndvi_ivas_processed}/all_ivas_with_distances_individual_unique_prepared.dta", replace

log close
