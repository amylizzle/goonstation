/datum/unit_test/material_id_uniqueness/Run()
	var/list/ids = list()
	for(var/material in concrete_typesof(/datum/material))
		var/datum/material/M = new material
		var/id = M.getID()
		if(ids[id])
			Fail("material id [id] has multiple associated materials: [ids[id]] and [M.type].")
		else
			ids[id] = material
