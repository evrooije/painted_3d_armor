local playerOverlays = {}
local playerShields = {}
local playerChestplates = {}

-- Whether to overlay the banner on top of the player skin in case the player does not
-- wear a chest plate. If true, the banner will be shown on top of the skin and the
-- player will have to manually remove the painted canvas from the armor inventory. If
-- false, no banner is shown on the player's torso when the chest plate is not worn
local overlayOnSkin = true

local armorTextureSize = { w = 64, h = 32 }
local armorPreviewTextureSize = { w = 32, h = 64 }

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

if painting then
	minetest.register_craftitem("painted_3d_armor:armor_canvas_6x6", {
		description = "Armor Canvas 6x6",
		inventory_image = "default_paper.png",
		stack_max = 99,
	})

	minetest.register_craftitem("painted_3d_armor:armor_canvas_12x12", {
		description = "Armor Canvas 12x12",
		inventory_image = "default_paper.png",
		stack_max = 99,
	})

	minetest.register_craftitem("painted_3d_armor:armor_canvas_24x24", {
		description = "Armor Canvas 24x24",
		inventory_image = "default_paper.png",
		stack_max = 99,
	})

	minetest.register_craft({
		output = "painted_3d_armor:armor_canvas_6x6",
		recipe = {
			{ "default:paper", "default:paper", "" },
			{ "default:paper", "default:paper", "" },
			{ "", "default:paper", "" },
		}
	})

	minetest.register_alias("painted_3d_armor:armor_canvas", "painted_3d_armor:armor_canvas_6x6")

	minetest.register_craft({
		output = "painted_3d_armor:armor_canvas_12x12",
		recipe = {
			{ "default:paper", "default:paper", "default:paper" },
			{ "default:paper", "default:paper", "default:paper" },
			{ "", "default:paper", "" },
		}
	})

	minetest.register_craft({
		output = "painted_3d_armor:armor_canvas_24x24",
		recipe = {
			{ "default:paper", "default:paper", "default:paper" },
			{ "default:paper", "default:paper", "default:paper" },
			{ "", "default:paper", "default:paper" },
		}
	})

	painting:register_canvas("painted_3d_armor:armor_canvas_6x6", 6)
	painting:register_canvas("painted_3d_armor:armor_canvas_12x12", 12)
	painting:register_canvas("painted_3d_armor:armor_canvas_24x24", 24)
	minetest.registered_craftitems["painting:paintedcanvas"].groups.armor_banner = 1
end

if banners then
	minetest.register_craftitem("painted_3d_armor:banner_armor",
		{
			drawtype = "mesh",
			mesh = "banner_support.x",
			inventory_image = "banner_sheet.png",
			description = "Armor banner",
			groups = {armor_banner=1},
			on_use = function(i, p, pt)
				banners.banner_on_use(i, p, pt)
			end,
		}
	)

	minetest.register_craft({
		output = "painted_3d_armor:armor_canvas_12x12",
		recipe = {
			{ "default:paper", "default:paper", "default:paper" },
			{ "default:paper", "banners:wooden_banner", "default:paper" },
			{ "", "default:paper", "" },
		}
	})

end

armor:register_on_equip(
	function(player, index, stack)
		if player then
			if	stack:get_name() == "painting:paintedcanvas" or stack:get_name() == "painted_3d_armor:banner_armor" then
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
				if stack:get_name() == "painting:paintedcanvas" then
					set_painting(player, stack)
				elseif stack:get_name() == "painted_3d_armor:banner_armor" then
					set_banner(player, stack)
				end
			end
		end
	end
)

function set_painting(player, stack)
	local name = player:get_player_name()
	local data = stack:get_metadata()
	data = minetest.deserialize(data)

	local chestplate_overlay = "^"..to_imagestring(data.grid, data.res, 21 * data.res / 6, 23 * data.res / 6, 1)
	local chestplate_preview_overlay = "^"..to_imagestring(data.grid, data.res, 10 * data.res / 6, 22 * data.res / 6, 2)
	local shield_overlay = "^"..to_imagestring(data.grid, data.res, 5 * data.res / 6, 5 * data.res / 6, 1)
	local shield_preview_overlay = "^"..to_imagestring(data.grid, data.res, 23 * data.res / 6, 37 * data.res / 6, 1)

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
		default.player_set_textures(player, {
			armor.textures[name].skin,
			armor.textures[name].armor.."^[resize:"
			..tostring(armorTextureSize.w * data.res / 6).."x"
			..tostring(armorTextureSize.h * data.res / 6)..total_overlay,
			armor.textures[name].wielditem,
		})
		armor.textures[name].preview = armor.textures[name].preview.."^[resize:"
			..tostring(armorPreviewTextureSize.w * data.res / 6).."x"
			..tostring(armorPreviewTextureSize.h * data.res / 6)..total_preview_overlay
	end
end

function set_banner(player, stack)
	local name = player:get_player_name()
	local data = stack:get_metadata()

	local chestplate_overlay = data:gsub("%(", "(c_"):gsub("mask%:", "mask:c_")
	local chestplate_preview_overlay = data:gsub("%(", "(cp_"):gsub("mask%:", "mask:cp_")
	local shield_overlay = data:gsub("%(", "(s_"):gsub("mask%:", "mask:s_")
	local shield_preview_overlay = data:gsub("%(", "(sp_"):gsub("mask%:", "mask:sp_")

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
		total_overlay = total_overlay.."^"..shield_overlay
		total_preview_overlay = total_preview_overlay.."^"..shield_preview_overlay
	end

	if armor.textures[name] then
		default.player_set_textures(player, {
			armor.textures[name].skin,
			armor.textures[name].armor.."^[resize:"
			..tostring(armorTextureSize.w * 8).."x"
			..tostring(armorTextureSize.h * 8).."^"..total_overlay,
			armor.textures[name].wielditem,
		})
		armor.textures[name].preview = armor.textures[name].preview.."^[resize:"
			..tostring(armorPreviewTextureSize.w * 4).."x"
			..tostring(armorPreviewTextureSize.h * 4).."^"..total_preview_overlay
	end
end

armor:register_on_unequip(
	function(player, index, stack)
		if player then
			if	stack:get_name() == "painting:paintedcanvas" or stack:get_name() == "painted_3d_armor:banner_armor"
			then
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
