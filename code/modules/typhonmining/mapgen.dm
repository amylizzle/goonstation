/// This is the primary datum for handling all map generation on the Typhon mining level
var/global/datum/TyphonMiningController/typhonMiningController = new()


/datum/TyphonMiningController
	var/datum/mapPrefab/TyphonTile/tiles[20][20] //300x300, with 15x15 tiles
	var/list/datum/mapPrefab/TyphonTile/possibleTiles
	var/list/mob/trackedMobs = list()

	New()
		..()
		SPAWN(5 SECONDS) //TODO OH MY GOD NO
			//load all potential tiles
			possibleTiles = get_map_prefabs(/datum/mapPrefab/TyphonTile)
			//set the central tile, clear on all sides
			tiles[10][10] = GetValidTile("c","c","c","c", TRUE)
			tiles[10][10].applyTo(GetTurfAtGridRef(10,10), DMM_OVERWRITE_MOBS | DMM_OVERWRITE_OBJS)
			for(var/X in 9 to 11)
				for(var/Y in 9 to 11)
					if(X==Y==10)
						continue
					GenerateTile(X,Y)
			//add the LRT landmark
			new /obj/landmark/lrt/typhon_mining(locate(157,157,Z_LEVEL_TYPHON))

	proc/GenerateTile(X,Y,force=FALSE)
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

		//if it's already valid && !force, return
		if(!force && !isnull(tiles[X][Y]))
			if((isnull(N) || N == tiles[X][Y].dirstates["N"]) && (isnull(E) || E == tiles[X][Y].dirstates["E"]) && (isnull(S) || S == tiles[X][Y].dirstates["S"]) && (isnull(W) || W == tiles[X][Y].dirstates["W"]))
				return

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

	proc/NotifyMobMove(var/mob/M)
		//sanity checking first
		if(M.loc?.z != Z_LEVEL_TYPHON)
			//remove from the tracked mobs list
			M.RemoveComponentsOfType(/datum/component/typhon_tracker)
			trackedMobs -= M
			return
		if(isnull(M.client))
			return //no point generating terain for people who can't see it

		trackedMobs |= M
		//all we need to do here is decide if we need to generate a new tile
		//we need a new tile iff:
		//there's a tile just coming in to range that nobody else can currently see that is not valid
		var/mobTileX = round(M.loc.x/15)+1
		var/mobTileY = round(M.loc.y/15)+1
		//are you closer to one edge or another
		var/mobTileBiasX = sign((M.loc.x % 15) - 8)
		var/mobTileBiasY = sign((M.loc.y % 15) - 8)

		//we assume all tiles in the 3x3 centered on the player are already generated
		if(mobTileBiasX != 0)
			for(var/Y in -1 to 1)
				GenerateTile(mobTileX + mobTileBiasX*2, mobTileY + Y, FALSE) //because we don't force, we don't need to check if they can be seen
				//mark the tiles you've moved away from as ready for regen if nobody can see them
				var/seen = FALSE
				for(var/mob/tracked in trackedMobs)
					//euclidean distance will do for checking
					if(GET_DIST(tracked, GetTurfAtGridRef(mobTileX - mobTileBiasX*2, mobTileY + Y)) < 2)
						seen = TRUE
						break
				if(!seen)
					tiles[mobTileX - mobTileBiasX*2][mobTileY + Y] = null

		if(mobTileBiasY != 0)
			for(var/X in -1 to 1)
				GenerateTile(mobTileX + X, mobTileY + mobTileBiasY*2, FALSE)
				//mark the tiles you've moved away from as ready for regen if nobody can see them
				var/seen = FALSE
				for(var/mob/tracked in trackedMobs)
					//euclidean distance will do for checking
					if(GET_DIST(tracked, GetTurfAtGridRef(mobTileX + X, mobTileY - mobTileBiasY*2)) < 2)
						seen = TRUE
						break
				if(!seen)
					tiles[mobTileX + X][mobTileY - mobTileBiasY*2] = null



TYPEINFO(/datum/mapPrefab/TyphonTile)
	folder = "typhon_tiles"
/datum/mapPrefab/TyphonTile
	prefabSizeX = 15
	prefabSizeY = 15
	///flag for marking tile in use
	var/inUse = 0
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

/area/typhon
	ambient_light = "#de84f0"
	icon_state = "purple"

	Entered(atom/movable/AM, atom/oldloc)
		if(istype(AM, /mob))
			AM.AddComponent(/datum/component/typhon_tracker)
		return ..()

	Exited(atom/movable/AM, atom/newloc)
		if(istype(AM, /mob))
			AM.RemoveComponentsOfType(/datum/component/typhon_tracker)
		return ..()


TYPEINFO(/datum/component/typhon_tracker)
	initialization_args = list()

/datum/component/typhon_tracker/Initialize()
	. = ..()
	if (!ismob(src.parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(src.parent, COMSIG_MOVABLE_MOVED, PROC_REF(MoveNotify))

/datum/component/typhon_tracker/proc/MoveNotify(thing, previous_loc, direction)
	typhonMiningController.NotifyMobMove(src.parent)

/datum/component/typhon_tracker/UnregisterFromParent()
	. = ..()
	typhonMiningController.trackedMobs -= src.parent
	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)
