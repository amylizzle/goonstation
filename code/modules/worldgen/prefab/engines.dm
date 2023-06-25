TYPEINFO(/datum/mapPrefab/engine_room)
	folder = "engine_rooms"

/datum/mapPrefab/engine_room
	name = null
	maxNum = 1

	post_cleanup(turf/target, datum/loadedProperties/props)
		. = ..()
		var/comp1type = null
		var/comp2type = null
		var/engine_type = filename_from_path(src.prefabPath, strip_extension=TRUE)
		switch(engine_type)
			if("none")
				comp1type = /obj/machinery/engine_selector //type select computer
				comp2type = /obj/landmark/engine_computer/two
			if("nuclear")
				comp1type = /obj/machinery/power/nuclear/reactor_control
				comp2type = /obj/machinery/power/nuclear/turbine_control
			if("TEG")
				comp1type = /obj/machinery/computer/power_monitor
				comp2type = /obj/machinery/power/reactor_stats
			if("singularity")
				comp1type = /obj/machinery/computer3/generic/engine
				comp2type = /obj/machinery/computer/power_monitor

		for_by_tcl(comp, /obj/landmark/engine_computer)
			if(istype(comp, /obj/landmark/engine_computer/one))
				comp.replaceWith(comp1type)
			else
				comp.replaceWith(comp2type)


			for(var/obj/O in bounds(target, -1, -1, props.maxX+2, props.maxY+2))
				O.initialize()
				O.UpdateIcon()
			makepowernets()


/obj/landmark/engine_room
	var/size = null
#ifdef IN_MAP_EDITOR
	icon = 'icons/effects/mapeditor/engine_room.dmi'
	icon_state = "11x11engine_room"
#else
	icon = null
	icon_state = null
#endif
	deleted_on_start = FALSE
	add_to_landmarks = FALSE
	opacity = 1
	invisibility = 0
	plane = PLANE_FLOOR

	New()
		..()
		START_TRACKING

	disposing()
		STOP_TRACKING
		..()

	proc/apply(var/type_force = "none")
		var/list/datum/mapPrefab/engine_room/prefab_list = get_map_prefabs(/datum/mapPrefab/engine_room)
		//filter by map and rename
		var/list/datum/mapPrefab/engine_room/room_prefabs = list()
		for(var/name in prefab_list)
			var/datum/mapPrefab/prefab = prefab_list[name]
			if(lowertext(map_settings.name) in prefab.tags)
				prefab.generate_default_name()
				room_prefabs[prefab.name] = prefab
		if(isnull(room_prefabs))
			CRASH("No engine room prefab found for map: " + lowertext(map_settings.name))
		var/datum/mapPrefab/engine_room/room_prefab = room_prefabs[type_force] ? room_prefabs[type_force] : pick(room_prefabs)
		room_prefab.applyTo(src.loc, DMM_OVERWRITE_OBJS)
		logTheThing(LOG_DEBUG, null, "Applied engine room prefab: [room_prefab] to [log_loc(src)]")
		qdel(src)

/obj/landmark/engine_computer
	deleted_on_start = FALSE
	add_to_landmarks = FALSE

	New()
		..()
		START_TRACKING

	disposing()
		STOP_TRACKING
		..()

	proc/replaceWith(var/type)
		if(!type)
			qdel(src)
			return
		var/obj/comp = new type(src.loc)
		comp.initialize()
		qdel(src)

/obj/landmark/engine_computer/one
	name = "comp1"

/obj/landmark/engine_computer/two
	name = "comp2"

/obj/machinery/engine_selector
	name = "Engine Teleport Request Computer"
	icon = 'icons/obj/computer.dmi'
	icon_state = "teleport"
	desc = "A computer for requesting teleportation and installation of an engine"
	density = TRUE
	anchored = ANCHORED

	attack_hand(mob/user)
		. = ..()
		var/list/datum/mapPrefab/engine_room/prefab_list = get_map_prefabs(/datum/mapPrefab/engine_room)
		//filter by map and rename
		var/list/choices = list()
		for(var/name in prefab_list)
			var/datum/mapPrefab/prefab = prefab_list[name]
			if(lowertext(map_settings.name) in prefab.tags)
				prefab.generate_default_name()
				choices += prefab.name
		var/engine_choice = tgui_input_list(user, "Choose an engine type!", "Engine Selector", choices)
		new /obj/landmark/engine_computer/one(src.loc) //replace our computer landmark so it can be swapped out
		for_by_tcl(landmark, /obj/landmark/engine_room)
			landmark.apply(engine_choice)
		qdel(src)
