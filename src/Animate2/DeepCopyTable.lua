local function linkTables(oldTable, links)
	links[oldTable] = {}
	for k, v in pairs(oldTable) do
		if type(v) == "table" and not links[v] then
			linkTables(v, links)
		end
	end
	return links
end

local function copyValues(newTable, oldTable, exploredTables, links)
	for k, v in pairs(oldTable) do
		if type(v) == "table" and not exploredTables[v] then
			exploredTables[v] = true
			copyValues(links[v], v, exploredTables, links)
			v = links[v]
		end
		newTable[k] = v
	end
	return newTable
end

local function deepCopyTable(newTable, oldTable)
	
	-- also supports deepCopyTable(oldTable)
	newTable, oldTable = oldTable and newTable or {}, oldTable or newTable
	
	local links = linkTables(oldTable, {})
	
	copyValues(newTable, oldTable, {}, links)
	
	return newTable
end

return deepCopyTable