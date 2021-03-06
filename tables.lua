function CreateTables()
	-- Blockentities to BlockType
	g_BlockEntityToBlockType = {}
	g_BlockEntityToBlockType.cBeaconEntity = E_BLOCK_BEACON
	g_BlockEntityToBlockType.cBedEntity = E_BLOCK_BED
	g_BlockEntityToBlockType.cBrewingstandEntity = E_BLOCK_BREWING_STAND
	g_BlockEntityToBlockType.cCommandBlockEntity = E_BLOCK_COMMAND_BLOCK
	g_BlockEntityToBlockType.cDispenserEntity = E_BLOCK_DISPENSER
	g_BlockEntityToBlockType.cDropSpenserEntity = E_BLOCK_DROPPER
	g_BlockEntityToBlockType.cFlowerPotEntity = E_BLOCK_FLOWER_POT
	g_BlockEntityToBlockType.cJukeboxEntity = E_BLOCK_JUKEBOX
	g_BlockEntityToBlockType.cFurnaceEntity = E_BLOCK_FURNACE
	g_BlockEntityToBlockType.cMobHeadEntity = E_BLOCK_HEAD
	g_BlockEntityToBlockType.cMobSpawnerEntity = E_BLOCK_MOB_SPAWNER
	g_BlockEntityToBlockType.cNoteEntity = E_BLOCK_NOTE_BLOCK


	g_BlockEntityCallBackToBlockType = {}
	g_BlockEntityCallBackToBlockType.DoWithBeaconAt = E_BLOCK_BEACON
	g_BlockEntityCallBackToBlockType.DoWithBedAt = E_BLOCK_BED
	g_BlockEntityCallBackToBlockType.DoWithBlockEntityAt = E_BLOCK_CHEST
	g_BlockEntityCallBackToBlockType.DoWithBrewingstandAt = E_BLOCK_BREWING_STAND
	g_BlockEntityCallBackToBlockType.DoWithChestAt = E_BLOCK_CHEST
	g_BlockEntityCallBackToBlockType.DoWithCommandBlockAt = E_BLOCK_COMMAND_BLOCK
	g_BlockEntityCallBackToBlockType.DoWithDispenserAt = E_BLOCK_DISPENSER
	g_BlockEntityCallBackToBlockType.DoWithDropperAt = E_BLOCK_DROPPER
	g_BlockEntityCallBackToBlockType.DoWithDropSpenserAt = E_BLOCK_DROPPER
	g_BlockEntityCallBackToBlockType.DoWithFlowerPotAt = E_BLOCK_FLOWER_POT
	g_BlockEntityCallBackToBlockType.DoWithFurnaceAt = E_BLOCK_FURNACE
	g_BlockEntityCallBackToBlockType.DoWithMobHeadAt = E_BLOCK_HEAD
	g_BlockEntityCallBackToBlockType.DoWithNoteBlockAt = E_BLOCK_NOTE_BLOCK


	g_ObjectToTypeName = {}

	-- Classes
	g_ObjectToTypeName.ItemCategory = "userdata"
	g_ObjectToTypeName.TakeDamageInfo = "userdata"
	g_ObjectToTypeName.Vector3d = "userdata"
	g_ObjectToTypeName.Vector3f = "userdata"
	g_ObjectToTypeName.Vector3i = "userdata"


	-- Enum type to enum value
	g_EnumValues = {}
	g_EnumValues.EMCSBiome = "biSky"
	g_EnumValues.eMonsterType = "mtBat"
	g_EnumValues.SmokeDirection = "SmokeDirection.EAST"
	g_EnumValues.eGameMode = "gmAdventure"


	-- Classes, functions that requires a player
	g_RequiresPlayer = {}
	g_RequiresPlayer.cClientHandle = true
	g_RequiresPlayer.cInventory = true
	g_RequiresPlayer.cPawn = true
	g_RequiresPlayer.cPlayer = true
	g_RequiresPlayer.cRoot = {}
	g_RequiresPlayer.cRoot.DoWithPlayerByUUID = true
	g_RequiresPlayer.cRoot.FindAndDoWithPlayer = true
	g_RequiresPlayer.cRoot.ForEachPlayer = true
	g_RequiresPlayer.cWorld = {}
	g_RequiresPlayer.cWorld.DoWithPlayer = true
	g_RequiresPlayer.cWorld.DoWithPlayerByUUID = true
	g_RequiresPlayer.cWorld.FindAndDoWithPlayer = true
	g_RequiresPlayer.cWorld.ForEachPlayer = true


	-- This list contains functions (if any) that causes false positives
	-- TODO: Add better test code for the functions below to correct them
	-- [Class name][Function name]
	g_FalsePositives = {}
end



function CreateSharedIgnoreTable()
	-- This table contains classes / functions that are ignored
	g_IgnoreShared = {}

	-- ## Initialize tables ##
	g_IgnoreShared.cBlockInfo = {}
	g_IgnoreShared.cClientHandle = {}
	g_IgnoreShared.cCompositeChat = {}
	g_IgnoreShared.cDispenserEntity = {}
	g_IgnoreShared.cDropSpenserEntity = {}
	g_IgnoreShared.cEntity = {}
	g_IgnoreShared.cMonster = {}
	g_IgnoreShared.cPlayer = {}
	g_IgnoreShared.cPlugin = {}
	g_IgnoreShared.cPluginLua = {}
	g_IgnoreShared.cRoot = {}
	g_IgnoreShared.cSplashPotionEntity = {}
	g_IgnoreShared.cWebAdmin = {}
	g_IgnoreShared.cWorld = {}
	g_IgnoreShared.Globals = {}


	-- ## Ignore a single or more functions ##

	-- Documented, but not exported
	g_IgnoreShared.cCompositeChat.AddShowAchievementPart = true
	g_IgnoreShared.cDispenserEntity.SpawnProjectileFromDispenser = true

	-- Deprecated
	g_IgnoreShared.cBlockInfo.GetPlaceSound = true
	g_IgnoreShared.cWebAdmin.GetURLEncodedString = true
	g_IgnoreShared.cWorld.SpawnBoat = {"number", "number", "number", "cBoat#eMaterial"}
	g_IgnoreShared.cWorld.SpawnPrimedTNT = {"number", "number", "number", "number", "number"}
	g_IgnoreShared.cWorld.WakeUpSimulators = true
	g_IgnoreShared.cWorld.WakeUpSimulatorsInArea = true
	g_IgnoreShared.Globals.LOGWARN = true
	g_IgnoreShared.Globals.md5 = true
	g_IgnoreShared.Globals.StringToMobType = true

	-- Outputs to console, ignore it
	g_IgnoreShared.cRoot.QueueExecuteConsoleCommand = true
	g_IgnoreShared.cWorld.SetLinkedEndWorldName = true
	g_IgnoreShared.cWorld.SetLinkedNetherWorldName = true
	g_IgnoreShared.cWorld.SetLinkedOverworldName = true
	g_IgnoreShared.Globals.LOG = true
	g_IgnoreShared.Globals.LOGERROR = true
	g_IgnoreShared.Globals.LOGINFO = true
	g_IgnoreShared.Globals.LOGWARNING = true

	-- Discussion in process #3651, #3649
	g_IgnoreShared.cEntity.MoveToWorld = true
	g_IgnoreShared.cEntity.ScheduleMoveToWorld = true

	-- Crashes the server
	g_IgnoreShared.cEntity.HandleSpeedFromAttachee = true  -- #3662

	-- Needs an monster as param
	g_IgnoreShared.cMonster.GetLeashedTo = true

	-- Requires score board, it's in rework: #3953
	g_IgnoreShared.cPlayer.GetTeam = true


	-- ## Whole class ignored ##

	-- Deprecated
	g_IgnoreShared.cTracer = "*"

	-- Has only function GetName
	g_IgnoreShared.cPainting = "*"

	-- Outputs to console, ignore it
	g_IgnoreShared.cRankManager = "*"
	g_IgnoreShared.cStringCompression = "*"

	-- Database
	g_IgnoreShared.sqlite3 = "*"

	-- Can write out of bounds and corrupts memory, this could then lead to a crash
	g_IgnoreShared.cBlockArea = "*"

	-- Has only function SetFuseTicks with param number
	g_IgnoreShared.cTNTEntity = "*"

	-- Needs a hook to access the objects
	g_IgnoreShared.cChunkDesc = "*"
	g_IgnoreShared.cCraftingRecipe = "*"

	-- Requires cChunkDesc
	g_IgnoreShared.cSignEntity = "*"

	-- Unclear
	g_IgnoreShared.cItemFrame = "*"

	-- cWorld:CreateProjectile
	g_IgnoreShared.cArrowEntity = "*"
	g_IgnoreShared.cFireworkEntity = "*"
	g_IgnoreShared.cProjectileEntity = "*"
	g_IgnoreShared.cSplashPotionEntity = "*"

	-- Has only function SetFacing with param eBlockFace
	g_IgnoreShared.cHangingEntity = "*"

	-- Has only function GetOutputBlockPos with param number
	g_IgnoreShared.cHopperEntity = "*"

	-- Requires player
	g_IgnoreShared.cFloater = "*"
	g_IgnoreShared.cMap = "*"
	g_IgnoreShared.cMapManager = "*"
	g_IgnoreShared.cObjective = "*"
	g_IgnoreShared.cScoreboard = "*"
	g_IgnoreShared.cTeam = "*"

	-- Contains callbacks
	g_IgnoreShared.lxp = "*"

	-- Is cLuaWindow
	g_IgnoreShared.cWindow = "*"

	-- Better not
	g_IgnoreShared.cPluginManager = "*"

	-- Don't change plugin infos
	g_IgnoreShared.cPlugin.SetName = true
	g_IgnoreShared.cPlugin.SetVersion = true
	g_IgnoreShared.cPluginLua.SetName = true
	g_IgnoreShared.cPluginLua.SetVersion = true

	-- Deprecated
	g_IgnoreShared.cPlugin.GetLocalDirectory = true
	g_IgnoreShared.cPlugin.GetDirectory = true

	-- Is checked in classes that inherit from it
	g_IgnoreShared.cBlockEntity = "*"
	g_IgnoreShared.cBlockEntityWithItems = "*"

	-- Don't want to ddos "internet"
	g_IgnoreShared.cNetwork = "*"
	g_IgnoreShared.cServerHandle = "*"
	g_IgnoreShared.cTCPLink = "*"
	g_IgnoreShared.cUDPEndpoint = "*"
	g_IgnoreShared.cUrlClient = "*"
	g_IgnoreShared.cUrlParser = "*"

	-- Static function cast is unsafe
	g_IgnoreShared.tolua = "*"

	-- Don't want to ddos mojang api server
	g_IgnoreShared.cMojangAPI = "*"

	-- Dangerous, dangerous, very dangerous
	g_IgnoreShared.cFile = "*"
	g_IgnoreShared.cIniFile = "*"

	-- This function doesn't work correctly.
	-- A client can ignore the disconnect packet: #3159
	g_IgnoreShared.cClientHandle.Kick = true

	-- If a invalid packet is send, the client disconnects
	g_IgnoreShared.cPlayer.SendMessageRaw = true

	-- This causes problem for fuzzing / checkapi, as the client name is hardcoded
	g_IgnoreShared.cPlayer.SetName = true

	-- This functions are missing return types in APIDoc
	g_IgnoreShared.cRoot.ForEachWorld = true
	g_IgnoreShared.cRoot.ForEachPlayer = true

	-- Crashes the server: #3994
	g_IgnoreShared.cEntity.Destroy = true
end
