/// This is the primary datum for handling all map generation on the Typhon mining level
var/global/datum/TyphonMiningController/typhonMiningController = new()


/datum/TyphonMiningController
	var/datum/mapPrefab/TyphonTile/tiles[20][20] //300x300, with 15x15 tiles
	var/list/datum/mapPrefab/TyphonTile/possibleTiles

	New()
		..()
		SPAWN(5 SECONDS) //TODO OH MY GOD NO
			//load all potential tiles
			possibleTiles = get_map_prefabs(/datum/mapPrefab/TyphonTile)
			//set the central tile, clear on all sides
			tiles[10][10] = GetValidTile("c","c","c","c")
			tiles[10][10].applyTo(GetTurfAtGridRef(10,10), DMM_OVERWRITE_MOBS | DMM_OVERWRITE_OBJS)
			for(var/X in 9 to 11)
				for(var/Y in 9 to 11)
					if(X==Y==10)
						continue
					GenerateTile(X,Y)
			//add the LRT landmark
			new /obj/landmark/lrt/typhon_mining(locate(157,157,Z_LEVEL_TYPHON))

	proc/GenerateTile(X,Y)
		var/N = null
		var/E = null
		var/S = null
		var/W = null
		if(X > 1)
			var/datum/mapPrefab/TyphonTile/WTile = tiles[X-1][Y]
			if(!isnull(WTile))
				W = WTile.dirstates["E"]
		if(X < 20)
			var/datum/mapPrefab/TyphonTile/ETile = tiles[X+1][Y]
			if(!isnull(ETile))
				E = ETile.dirstates["W"]
		if(Y > 1)
			var/datum/mapPrefab/TyphonTile/STile = tiles[X][Y-1]
			if(!isnull(STile))
				S = STile.dirstates["N"]
		if(Y < 20)
			var/datum/mapPrefab/TyphonTile/NTile = tiles[X][Y+1]
			if(!isnull(NTile))
				N = NTile.dirstates["S"]

		tiles[X][Y] = GetValidTile(N,E,S,W)
		tiles[X][Y].applyTo(GetTurfAtGridRef(X,Y), DMM_OVERWRITE_MOBS | DMM_OVERWRITE_OBJS)
		if(X==10 && Y==10)
			//replace the lrt landmark if it was deleted above
			new /obj/landmark/lrt/typhon_mining(locate(157,157,Z_LEVEL_TYPHON))

	proc/GetValidTile(N,E,S,W)
		var/list/datum/mapPrefab/TyphonTile/foundTiles = list()
		for(var/prefabFile as anything in possibleTiles)
			var/datum/mapPrefab/TyphonTile/tile = possibleTiles[prefabFile]
			if((isnull(N) || N == tile.dirstates["N"]) && (isnull(E) || E == tile.dirstates["E"]) && (isnull(S) || S == tile.dirstates["S"]) && (isnull(W) || W == tile.dirstates["W"]))
				foundTiles[tile] = tile.probability
		if(!length(foundTiles))
			CRASH("Unable to generate tile with bounds N:[N] E:[E] S:[S] W:[W]")
		//do a weighted pick over the valid tiles
		return weighted_pick(foundTiles)

	proc/GetTurfAtGridRef(X,Y)
		if(X > 0 && X <= 20 && Y > 0 && Y <= 20)
			return locate(1+(X-1)*15, 1+(Y-1)*15, Z_LEVEL_TYPHON)
		else
			CRASH("Invalid grid ref [X] [Y] on Typhon map")

TYPEINFO(/datum/mapPrefab/TyphonTile)
	folder = "typhon_tiles"
/datum/mapPrefab/TyphonTile
	prefabSizeX = 15
	prefabSizeY = 15
	///List of chars, indexed by dir [N,E,S,W]. State of each edge. c is clear, w is water
	var/list/dirstates = list("N"="c", "E"="c","S"="c","W"="c")

	post_init()
		var/filename = filename_from_path(prefabPath, strip_extension=TRUE)
		var/list/nameparts = splittext(filename,"_")
		if(length(nameparts) != 3 && length(nameparts[1]) == 4)
			CRASH("TyphonTiles: Invalid filename [filename], it must be formatted as XXXX_name_prob where Xs are dirstates, and prob is 0 to 100")

		src.dirstates["N"] = nameparts[1][1]
		src.dirstates["E"] = nameparts[1][2]
		src.dirstates["S"] = nameparts[1][3]
		src.dirstates["W"] = nameparts[1][4]

		src.name = nameparts[2]

		src.probability = text2num_safe(nameparts[3])
