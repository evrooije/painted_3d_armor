local playerOverlays = {}
local playerShields = {}
local playerChestplates = {}

-- Whether to overlay the banner on top of the player skin in case the player does not
-- wear a chest plate. If true, the banner will be shown on top of the skin and the
-- player will have to manually remove the painted canvas from the armor inventory. If
-- false, no banner is shown on the player's torso when the chest plate is not worn
local overlayOnSkin = true

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	if name then
		playerOverlays[name] = nil
		playerShields[name] = nil
		playerChestplates[name] = nil
	end
end)

table.insert(armor.elements, "banner")

local textures = {
	white = "white.png",
	yellow = "yellow.png",
	orange = "orange.png",
	red = "red.png",
	violet = "violet.png",
	blue = "blue.png",
	green = "green.png",
	magenta = "magenta.png",
	cyan = "cyan.png",
	grey = "grey.png",
	darkgrey = "darkgrey.png",
	black = "black.png",
	darkgreen = "darkgreen.png",
	brown = "brown.png",
	pink = "pink.png"
}

local revcolors = {}

for color, _ in pairs(textures) do
	table.insert(revcolors, color)
end

minetest.register_craftitem("painted_3d_armor:armor_canvas", {
	description = "Armor Canvas",
	inventory_image = "default_paper.png",
	stack_max = 99,
})

minetest.register_craft({
	output = "painted_3d_armor:armor_canvas",
	recipe = {
		{ "default:paper", "default:paper", "default:paper" },
		{ "default:paper", "default:paper", "default:paper" },
		{ "", "default:paper", "" },
	}
})

painting:register_canvas("painted_3d_armor:armor_canvas", 6)
minetest.registered_craftitems["painting:paintedcanvas"].groups.armor_banner = 1

armor:register_on_equip(
	function(player, index, stack)
		if player then
			if stack:get_name() == "painting:paintedcanvas" then
				print("Setting stack in the player overlay")
				playerOverlays[player:get_player_name()] = stack
			else
				local tool = minetest.registered_tools[stack:get_name()]
				if tool and tool.groups.armor_shield then
					playerShields[player:get_player_name()] = true
				elseif tool and tool.groups.armor_torso then
					playerChestplates[player:get_player_name()] = true
				end
			end
		end
	end
)

armor:register_on_update(
	function(player)
		if player then
			local name = player:get_player_name()
			local stack = playerOverlays[name]
			if stack then
				local data = stack:get_metadata()
				data = minetest.deserialize(data)
				local chestplate_overlay = "^"..to_imagestring(data.grid, data.res, 21, 23, 1)
				local chestplate_preview_overlay = "^"..to_imagestring(data.grid, data.res, 10, 22, 2)
				local shield_overlay = "^"..to_imagestring(data.grid, data.res, 5, 5, 1)
				local shield_preview_overlay = "^"..to_imagestring(data.grid, data.res, 23, 37, 1)

				local total_overlay = ""
				local total_preview_overlay = ""

				if playerChestplates[name] then
					total_overlay = chestplate_overlay
					total_preview_overlay = chestplate_preview_overlay
				elseif (not playerChestplates[name]) and overlayOnSkin then
					total_overlay = chestplate_overlay
					total_preview_overlay = chestplate_preview_overlay
				end

				if playerShields[name] then
					total_overlay = total_overlay..shield_overlay
					total_preview_overlay = total_preview_overlay..shield_preview_overlay
				end

				if armor.textures[name] then
					print("Setting overlay on the texture")
					default.player_set_textures(player, {
						armor.textures[name].skin,
						armor.textures[name].armor..total_overlay,
						armor.textures[name].wielditem,
					})
					armor.textures[name].preview = armor.textures[name].preview..total_preview_overlay
				end
			end
		end
	end
)

armor:register_on_unequip(
	function(player, index, stack)
		if player then
			if stack:get_name() == "painting:paintedcanvas" then
				playerOverlays[player:get_player_name()] = nil
			else
				local tool = minetest.registered_tools[stack:get_name()]
				if tool and tool.groups.armor_shield then
					playerShields[player:get_player_name()] = nil
				elseif tool and tool.groups.armor_torso then
					playerChestplates[player:get_player_name()] = nil
				end
			end
		end
	end
)

function to_imagestring(data, res, offsetx, offsety, scale)

	if not data then
		return
	end

	if not scale then
		scale = 1
	elseif scale < 1 then
		scale = 1
	end

	scale = math.floor(scale)

	local t,n = {"[combine:", res * scale, "x", res * scale, ":"}, 6

	for y = 0, (res - 1) * scale, scale  do
		for x = 0, (res - 1) * scale, scale do
			for i = 0, scale - 1 do
				for j = 0, scale - 1 do
					t[n] = x + j + offsetx .. "," .. y + i + offsety .. "=" .. revcolors[ data[x / scale][y / scale] ] .. ".png:"
					n = n + 1
				end
			end
		end
	end

	return table.concat(t)
end
