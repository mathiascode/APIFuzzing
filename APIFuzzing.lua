g_Plugin = nil
g_Ignore = {}

function Initialize(a_Plugin)
	g_Plugin = a_Plugin
	a_Plugin:SetName( "APIFuzzing" )
	a_Plugin:SetVersion( 1 )

	math.randomseed(os.time())

	-- Create and load tables
	CreateTables()
	LoadTableIgnore()
	LoadTableCrashed()
	CreateSharedIgnoreTable()

	-- Was there a crash last time?
	CheckIfCrashed()

	cPluginManager.BindConsoleCommand("fuzzing", CmdFuzzing, " - fuzzing the api")
	cPluginManager.BindConsoleCommand("checkapi", CmdCheckAPI, " - check the api")
	return true
end



function OnDisable()
	LOG( "Disabled APIFuzzing!" )
end


function CmdCheckAPI(a_Split)
	local pathClasses = table.concat({ "Plugins", "APIDump", "Classes" }, cFile:GetPathSeparator())
	local pathAPIDesc = table.concat({ "Plugins", "APIDump", "APIDesc.lua" }, cFile:GetPathSeparator())

	-- Create functions with valid params, with flag IsStatic if any
	-- and checks the return types
	-- Check log files and console output for warnings and errors
	for _, fileClass in ipairs(cFile:GetFolderContents(pathClasses)) do
		CheckAPI(loadfile(pathClasses .. cFile:GetPathSeparator() .. fileClass)())
	end
	CheckAPI(loadfile(pathAPIDesc)().Classes)

	LOG("CheckAPI completed!")
	return true
end



function CmdFuzzing(a_Split)
	local pathClasses = table.concat({ "Plugins", "APIDump", "Classes" }, cFile:GetPathSeparator())
	local pathAPIDesc = table.concat({ "Plugins", "APIDump", "APIDesc.lua" }, cFile:GetPathSeparator())

	-- Fuzzing the functions, pass nil, different types, etc.
	-- Check log files and console output for warnings and errors
	for _, fileClass in ipairs(cFile:GetFolderContents(pathClasses)) do
		RunFuzzing(loadfile(pathClasses .. cFile:GetPathSeparator() .. fileClass)())
	end
	RunFuzzing(loadfile(pathAPIDesc)().Classes)


	LOG("Fuzzing completed!")

	-- If reached here, we haven't got an crash.
	-- Tell the run script, that fuzzing is completed
	io.open("stop.txt", "w")

	-- Stop server
	-- cRoot:Get():QueueExecuteConsoleCommand("stop")
	return true
end



function RunFuzzing(a_API)
	for className, tbFunctions in pairs(a_API) do
		-- Create table for functions
		if g_Ignore[className] == nil then
		 	g_Ignore[className] = {}
		end

		if g_IgnoreShared[className] == nil then
		 	g_IgnoreShared[className] = {}
		end

		if g_Crashed[className] == nil then
		 	g_Crashed[className] = {}
		end

		for functionName, tbFncInfo in pairs(tbFunctions.Functions or {}) do
			if
				g_IgnoreShared[className] ~= "*" and
				g_IgnoreShared[className][functionName] == nil and
				g_Ignore[className] ~= "*" and
				g_Ignore[className][functionName] == nil and
				g_Crashed[className][functionName] == nil and
				functionName ~= "constructor" and
				functionName ~= "operator_div" and
				functionName ~= "operator_eq" and
				functionName ~= "operator_mul" and
				functionName ~= "operator_plus" and
				functionName ~= "operator_sub"
			then
				local params = GetParamTypes(tbFncInfo, functionName)
				if params ~= nil then
					local inputs = CreateInputs(className, functionName, params, true)
					if inputs ~= nil then
						FunctionsWithParams(a_API, className, functionName, nil, inputs, true)
					end
				end
			end
		end
	end
end



function CheckAPI(a_API)
	for className, tbFunctions in pairs(a_API) do
		-- Create table for functions
		if g_Ignore[className] == nil then
		 	g_Ignore[className] = {}
		end

		if g_IgnoreShared[className] == nil then
		 	g_IgnoreShared[className] = {}
		end

		if g_Crashed[className] == nil then
		 	g_Crashed[className] = {}
		end

		for functionName, tbFncInfo in pairs(tbFunctions.Functions or {}) do
			if
				g_IgnoreShared[className] ~= "*" and
				g_IgnoreShared[className][functionName] == nil and
				g_Crashed[className][functionName] == nil and
				functionName ~= "constructor" and
				functionName ~= "operator_div" and
				functionName ~= "operator_eq" and
				functionName ~= "operator_mul" and
				functionName ~= "operator_plus" and
				functionName ~= "operator_sub"
			then
				local paramTypes = GetParamTypes(tbFncInfo)
				local returnTypes = GetReturnTypes(tbFncInfo, className, functionName)
				if paramTypes ~= nil then
					local inputs = CreateInputs(className, functionName, paramTypes, false)
					if inputs ~= nil then
						FunctionsWithParams(a_API, className, functionName, returnTypes, inputs)
					end
				else
					FunctionsWithNoParams(a_API, className, functionName, returnTypes, tbFncInfo.IsStatic)
				end
			end
		end
	end
end



function FunctionsWithNoParams(a_API, a_ClassName, a_FunctionName, a_ReturnTypes, a_IsStatic)
	local isStatic = a_IsStatic or false
	if a_ReturnTypes ~= nil then
		TestFunction(a_API, a_ClassName, a_FunctionName, a_ReturnTypes[1], "", isStatic)
	else
		TestFunction(a_API, a_ClassName, a_FunctionName, nil, "", isStatic)
	end
end



function FunctionsWithParams(a_API, a_ClassName, a_FunctionName, a_ReturnTypes, a_Inputs, a_IsFuzzing)
	for index, input in ipairs(a_Inputs) do
		local isStatic = input.IsStatic or false
		local paramTypes = table.concat(input, ", ")
		if a_ReturnTypes ~= nil then
			TestFunction(a_API, a_ClassName, a_FunctionName, a_ReturnTypes[index], paramTypes, isStatic, a_IsFuzzing)
		else
			TestFunction(a_API, a_ClassName, a_FunctionName, nil, paramTypes, isStatic, a_IsFuzzing)
		end
	end
end



function TestFunction(a_API, a_ClassName, a_FunctionName, a_ReturnTypes, a_ParamTypes, a_IsStatic, a_IsFuzzing)
	local fncTest = ""

	if not(a_IsStatic) then
		if a_ClassName == "cEntity" then
			fncTest = "cRoot:Get():GetDefaultWorld():ForEachEntity(function(a_Entity)"
			fncTest = fncTest .. " GatherReturnValues(a_Entity:" .. a_FunctionName .. "(" .. a_ParamTypes .. ")) return true end)"
		elseif a_ClassName == "cMonster" then
			fncTest = "cRoot:Get():GetDefaultWorld():ForEachEntity(function(a_Entity) if not(a_Entity:IsMob()) then return end"
			fncTest = fncTest .. " local monster = tolua.cast(a_Entity, '" .. a_ClassName .. "' )"
			fncTest = fncTest .. " GatherReturnValues(monster:" .. a_FunctionName .. "(" .. a_ParamTypes .. ")) return true end)"
		elseif a_ClassName == "cWorld" then
			fncTest = "GatherReturnValues(cRoot:Get():GetDefaultWorld():" .. a_FunctionName .. "(" .. a_ParamTypes .. "))"
		elseif a_ClassName == "cRoot" then
			fncTest = "GatherReturnValues(cRoot:Get():" .. a_FunctionName
			fncTest = fncTest .."(" .. a_ParamTypes .. "))"
		elseif a_ClassName == "cWebAdmin" then
			fncTest = "GatherReturnValues(cRoot:Get():GetWebAdmin():" .. a_FunctionName .."(" .. a_ParamTypes .. "))"
		elseif a_ClassName == "cItemGrid" then
			fncTest = "cRoot:Get():GetDefaultWorld():SetBlock(10, 100, 10, E_BLOCK_CHEST, 0)"
			fncTest = fncTest .. " cRoot:Get():GetDefaultWorld():DoWithChestAt(10, 100, 10,"
			fncTest = fncTest .. " function(a_ChestEntity) GatherReturnValues(a_ChestEntity:GetContents():" .. a_FunctionName .. "(" .. a_ParamTypes .. ")) end)"
		elseif a_ClassName == "cServer" then
			fncTest = "GatherReturnValues(cRoot:Get():GetServer():" .. a_FunctionName .."(" .. a_ParamTypes .. "))"
		elseif a_ClassName == "cJukeboxEntity" or a_ClassName == "cMobSpawnerEntity" then
			-- Has no cWorld:DoWith... function. Use DoWithBlockEntityAt and cast it
			fncTest = "cRoot:Get():GetDefaultWorld():SetBlock(10, 100, 10, E_BLOCK_JUKEBOX, 0)"
			fncTest = fncTest .. " cRoot:Get():GetDefaultWorld():DoWithBlockEntityAt(10, 100, 10,"
			fncTest = fncTest .. " function(a_BlockEntity) local blockEntity = tolua.cast(a_BlockEntity, '" .. a_ClassName ..  "')"
			fncTest = fncTest .. " GatherReturnValues(blockEntity:" .. a_FunctionName .. "(" .. a_ParamTypes .. ")) end)"
		end
	end

	if a_ClassName == "Globals" then
		fncTest = "GatherReturnValues(" .. a_FunctionName .."(" .. a_ParamTypes .. "))"
	end

	if fncTest == "" then
		if g_ClassStaticFunctions[a_ClassName] then
			if a_IsStatic then
				if
					a_ClassName == "cStringCompression" or
					a_ClassName == "ItemCategory" or
					a_ClassName == "cCryptoHash"
				then
					fncTest = "GatherReturnValues(" .. a_ClassName .. "." .. a_FunctionName
				else
					fncTest = "GatherReturnValues(" .. a_ClassName .. ":" .. a_FunctionName
				end
				fncTest = fncTest .."(" .. a_ParamTypes .. "))"
			end
		end
		if g_BlockEntityToFunctionCall[a_ClassName] then
			if not a_IsStatic then
				fncTest = "cRoot:Get():GetDefaultWorld():SetBlock(10, 100, 10, " .. g_BlockEntityToBlockType[a_ClassName] .. ", 0)"
				fncTest = fncTest .. " cRoot:Get():GetDefaultWorld():" .. g_BlockEntityToFunctionCall[a_ClassName] .. "("
				fncTest = fncTest .. "10, 100, 10, function(a_BlockEntity) GatherReturnValues(a_BlockEntity:" .. a_FunctionName .. "(" .. a_ParamTypes .. ")) end)"
			end
		end
		if g_ReqInstance[a_ClassName] then
			if not a_IsStatic then
				if a_API[a_ClassName]["Functions"]["constructor"] ~= nil then
					local constParams = GetParamTypes(a_API[a_ClassName]["Functions"]["constructor"])
					if constParams ~= nil and #constParams ~= 0 then
						local constInputs = CreateInputs(a_ClassName, "constructor", constParams)
						fncTest = "local obj = " .. a_ClassName .. "(" .. table.concat(constInputs[1], ", ") .. ")"
					else
						fncTest = "local obj = " .. a_ClassName .. "()"
					end
				else
					fncTest = "local obj = " .. a_ClassName .. "()"
				end
				if a_ClassName == "cItems" then
					if a_FunctionName == "Delete" then
						fncTest = fncTest .. " obj:Add(cItem(1, 1))"
					end
				end
				fncTest = fncTest .. " GatherReturnValues(obj:" .. a_FunctionName .. "(" .. a_ParamTypes .. "))"
			end
		end
	end

	assert(fncTest ~= "", "Not handled: " .. a_ClassName .. "\t" .. a_FunctionName)



	-- Load function, check for syntax problems
	local fnc, errSyntax = loadstring(fncTest)
	if fnc == nil then
		LOG("######################################### SYNTAX ERROR DETECTED #########################################")
		LOG(errSyntax)
		LOG("")
		LOG("                                             ## Code ##")
		LOG("\n" .. fncTest)
		LOG("")
		LOG("This indicates a problem in the generation of the code in this plugin. Plugin will be stopped.")
		LOG("#########################################################################################################")
		assert(false, "Runtime of plugin stopped, because of syntax error.")
	end

	-- Call function
	local status, errRuntime = pcall(fnc)

	if a_IsFuzzing then
		-- Fuzzing in proccess, bail out. Makes no sense to run the code below,
		-- if intentionally invalid params are passed :)
		return
	end

	-- Check if an error occurred. NOTE: A error that occurred inside of a callback, can not be catched
	if not(status) then
		LOG("####################################### ERROR OCCURRED ON RUNTIME #######################################")
		LOG(errRuntime)
		LOG("")
		LOG("                                             ## Code ##")
		LOG("\n" .. fncTest)
		LOG("")
		LOG("Class = \t\t" .. a_ClassName)
		LOG("Function = \t\t" .. a_FunctionName)
		LOG("Params = \t\t" .. a_ParamTypes)
		LOG("This code caused an error on runtime. For example it could be:")
		LOG("- the fault of this plugin, if a wrong param has been passed or a syntax error")
		LOG("- a function that is documented, but not exported or doesn't exists")
		LOG("- a missing IsStatic flag in the APIDoc")
		LOG("#########################################################################################################")
		LOG("")
	end

	if not(status) then
		return
	end

	-- Check the return types
	-- NOTE: There can be false positives. For example for function GetSignLines from cWorld.
	-- If the block is not a sign it will correctly return 1 value instead of the expected 5.
	-- There are currently two ideas. (TODO)
	-- 1) Adding code that will place a sign, before the call will be made
	-- 2) If the output is a false positive. Add the function to the table g_FalsePositives in tables.lua

	if g_FalsePositives[a_ClassName] ~= nil and g_FalsePositives[a_ClassName][a_FunctionName] == true  then
		return
	end

	local title
	local retGot = "nil"
	local retAPIDoc = "nil"
	local catched = false
	if RETURN_VALUES ~= nil and a_ReturnTypes ~= nil then
		if #RETURN_VALUES ~= #a_ReturnTypes then
			title = "########################## AMOUNT OF RETURN TYPES DOESN'T MATCH ########################################"
			catched = true
			retGot = table.concat(RETURN_VALUES, ", ")
			retAPIDoc = table.concat(ObjectToTypeName(a_ClassName, a_FunctionName, a_ReturnTypes), ", ")
		elseif #RETURN_VALUES == #a_ReturnTypes then
			title = "##################################### RETURN TYPES DOESN'T MATCH ########################################"
			retGot = table.concat(RETURN_VALUES, ", ")
			retAPIDoc = table.concat(ObjectToTypeName(a_ClassName, a_FunctionName, a_ReturnTypes), ", ")
			-- Same amount, check if return types are equal
			if retGot ~= retAPIDoc then
				catched = true
			end
		end
	elseif RETURN_VALUES == nil and a_ReturnTypes ~= nil then
		title = "########################## AMOUNT OF RETURN TYPES DOESN'T MATCH ########################################"
		catched = true
		retAPIDoc = table.concat(ObjectToTypeName(a_ClassName, a_FunctionName, a_ReturnTypes), ", ")
	elseif RETURN_VALUES ~= nil and a_ReturnTypes == nil then
		title = "########################## AMOUNT OF RETURN TYPES DOESN'T MATCH ########################################"
		catched = true
		retGot = table.concat(RETURN_VALUES, ", ")
	end

	if catched then
		LOG(title)
		LOG("")
		LOG("")
		LOG("                                             ## Code ##")
		LOG("\n" .. fncTest)
		LOG("")
		LOG("Class = \t\t" .. a_ClassName)
		LOG("Function = \t\t" .. a_FunctionName)
		LOG("Got = \t\t\t" .. retGot)
		LOG("APIDoc = \t\t" .. retAPIDoc)
		LOG("#########################################################################################################")
		LOG("")
	end
end
