/turf/unsimulated/typhon
	icon = 'icons/misc/mars_outpost.dmi'
	name = "Typhon"
	desc = "Take a stroll on the corpse of a dead god."
	icon_state = "t4"
	fullbright = FALSE
	temperature = 320
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 700000
	mat_changename = FALSE
	mat_changedesc = FALSE
	/*oxygen = 0 disabled while I test for ease
	nitrogen = ONE_ATMOSPHERE * 5
	carbon_dioxide = ONE_ATMOSPHERE * 15
	toxins = ONE_ATMOSPHERE * 30
	*/


/turf/simulated/wall/auto/asteroid/typhon
	name = "typhon rock"
	desc = "Is that bone?"
	fullbright = FALSE
	color = "#e0c4dc"
	stone_color = "#ea99f5"
	replace_type = /turf/unsimulated/typhon
