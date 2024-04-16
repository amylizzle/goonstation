TYPEINFO(/datum/component/reflective)
	initialization_args = list(
		ARG_INFO("alpha", DATA_INPUT_NUM, "Strength of reflection. 100 is a perfect mirror. \[0-100\]", 100),
		ARG_INFO("direction", DATA_INPUT_DIR, "Direction of reflection. North reflects things above the object. Cardinal dirs only.", NORTH),
		//todo alpha mask probably
	)

/datum/component/reflective
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/icon = 'icons/effects/reflections.dmi'
	var/icon_state = "south5"

	Initialize(alpha=100)
		if(!istype(parent,/atom))
			return COMPONENT_INCOMPATIBLE
		. = ..()
		var/atom/parentatom = parent
		var/image/reflection = image(icon=src.icon, icon_state=src.icon_state)
		reflection.plane = PLANE_DISTORTION
		reflection.blend_mode = BLEND_OVERLAY
		reflection.appearance_flags = RESET_ALPHA | RESET_COLOR
		reflection.alpha = alpha
		parentatom.UpdateOverlays(reflection, "reflection_\ref[src]")

	UnregisterFromParent()
		. = ..()
		var/atom/parentatom = parent
		if(istype(parentatom))
			parentatom.UpdateOverlays(null, "reflection_\ref[src]")
