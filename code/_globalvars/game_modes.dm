GLOBAL_VAR(common_report) //Contains common part of roundend report
GLOBAL_VAR(survivor_report) //Contains shared survivor report for roundend report (part of personal report)


GLOBAL_VAR_INIT(wavesecret, 0) // meteor mode, delays wave progression, terrible name
GLOBAL_DATUM(start_state, /datum/station_state) // Used in round-end report

/// We want reality_smash_tracker to exist only once and be accessible from anywhere.
GLOBAL_DATUM_INIT(reality_smash_track, /datum/reality_smash_tracker, new)

//Massmeta edit
GLOBAL_VAR_INIT(required_succs, 15)
GLOBAL_VAR_INIT(sacrament_done, FALSE)

GLOBAL_LIST_EMPTY(servants_of_ratvar)
