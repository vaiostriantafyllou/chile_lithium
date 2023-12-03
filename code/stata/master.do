* Master file
* Leonardo Penaloza-Pacheco, Vaios Triantafyllou, and Gonzalo Martinez
* master.do 

// -------------------------------------------------------------------------- //
** Set directories
// -------------------------------------------------------------------------- //

if substr("`c(pwd)'",1,26)=="/Users/vaiostriantafyllou/"{
	global computer "/Users/vaiostriantafyllou/Desktop"
}

if substr("`c(pwd)'",1,20)=="C:\Users\UserLenovo\" {
	global computer "C:/Users/UserLenovo/Box"
}

global dir "${computer}/chile_lithium"

// -------------------------------------------------------------------------- //
** Set individual paths to folders
// -------------------------------------------------------------------------- //

global code "${dir}/code/stata"
global ev_raw "${dir}/data/raw_data/electric_vehicles"
global ev_processed "${dir}/data/processed_data/electric_vehicles"
global ndvi_ivas_processed "${dir}/data/processed_data/ndvi/ivas"

global results_tab "${dir}/output/tables"
global results_fig "${dir}/output/figures"


// -------------------------------------------------------------------------- //
** Run the do files
// -------------------------------------------------------------------------- //

do "${code}/1.ndvi_cluster_creation.do"

do "${code}/7.ndvi_regressions.do"
