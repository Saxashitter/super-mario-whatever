local meta = {}

local function iterate(path)
	for k,v in pairs(love.filesystem.getDirectoryItems(path)) do
		local info = love.filesystem.getInfo(path.."/"..v)
	
		if info.type == "directory" then
			local toReqPath = path:gsub("/", "%.")
			table.insert(meta,
				require(toReqPath.."."..v))
		end
	end
end

iterate("assets/data/characters")
iterate("mods/characters")

table.sort(meta, function(a,b)
	return a.index < b.index
end)

return meta