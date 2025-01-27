local _PATH = (...):gsub("%.", "/")

local function getLuas(path)
	local luas = {}

	local files = love.filesystem.getDirectoryItems(path)
	for k,v in pairs(files) do
		if v ~= "init.lua" then
			local file = v:gsub(".lua", "")
			luas[file] = require(_PATH.."."..file:gsub("/", "."))
		end
	end

	return luas
end

return getLuas(_PATH)