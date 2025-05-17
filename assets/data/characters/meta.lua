local meta = {}

for k,v in pairs(love.filesystem.getDirectoryItems("assets/data/characters")) do
	local info = love.filesystem.getInfo("assets/data/characters/"..v)

	if info.type == "directory" then
		table.insert(meta,
			require("assets.data.characters."..v))
	end
end

table.sort(meta, function(a,b)
	return a.index < b.index
end)

return meta