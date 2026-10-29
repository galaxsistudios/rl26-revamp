function adjustColourChannelLevels(arg_1_0, arg_1_1, arg_1_2)
	return math.min(math.max(arg_1_0 - arg_1_1, 0) / (arg_1_2 - arg_1_1), 1)
end

function make(arg_2_0)
	local var_2_0 = 1
	local var_2_1 = 0.1568627450980392
	local var_2_2 = 0.7450980392156863
	local var_2_3 = 1 / native.clamp1(var_2_0, 0.1, 10)
	local var_2_4 = adjustColourChannelLevels(arg_2_0.x, 0, 1)
	local var_2_5 = adjustColourChannelLevels(arg_2_0.y, 0, 1)
	local var_2_6 = adjustColourChannelLevels(arg_2_0.z, 0, 1)
	local var_2_7 = math.pow(var_2_4, var_2_3)
	local var_2_8 = math.pow(var_2_5, var_2_3)
	local var_2_9 = math.pow(var_2_6, var_2_3)
	local var_2_10 = native.lerp1(var_2_7, var_2_1, var_2_2)
	local var_2_11 = native.lerp1(var_2_8, var_2_1, var_2_2)
	local var_2_12 = native.lerp1(var_2_9, var_2_1, var_2_2)

	arg_2_0 = native.vec4(var_2_10, var_2_11, var_2_12, arg_2_0.w)

	return arg_2_0
end

-- nrl-referee-2026-kits: the 2026 NRL referee jerseys as new uniformTop design
-- items (guids 62001-62003), copies of the stock NRL 2025 orange referee top
-- (guid 51, top_vneck06_tucked) with a new colTexture. assetmap imports this
-- file first, so the items are in ItemMaps (and its lookups, which
-- assetmapitems builds itself; it imports nothing) before the native asset map
-- reads them. The stock referee kits are untouched. MOD_EXTRA_REFEREE_KITS
-- lists the kits for choose-play-now-referee's Referee Jersey picker: each is
-- worn as the base stock kit's visual with uniformTop swapped.
do
	local ItemMaps = import("design.characters.assetmapitems").ItemMaps
	local map = ItemMaps.uniformTop
	local lookup = map.item_setup_lookup
	local colMap = ItemMaps.uniformTop_col
	local templateGuid = 51
	local kits = {
		{ guid = 62001, colTexture = "m_top_referee_nrl_2026_orange_col", label = "NRL 2026 Orange", base = "NRL_Orange" },
		{ guid = 62002, colTexture = "m_top_referee_nrl_2026_yellow_col", label = "NRL 2026 Yellow", base = "NRL_Orange" },
		{ guid = 62003, colTexture = "m_top_referee_nrl_2026_blue_col", label = "NRL 2026 Blue", base = "NRL_Orange" }
	}
	local template = lookup[templateGuid]
	local added = {}

	for _, kit in ipairs(kits) do
		if template ~= nil and lookup[kit.guid] == nil then
			local item = {}

			for key, value in pairs(template) do
				item[key] = value
			end

			item.guid = kit.guid
			item.colTexture = kit.colTexture

			table.insert(map.item_setup, item)

			lookup[kit.guid] = item

			if colMap.item_setup_lookup[kit.colTexture] == nil then
				local entry = {
					name = kit.colTexture,
					blend = colMap.blend
				}

				table.insert(colMap.item_setup, entry)

				colMap.item_setup_lookup[kit.colTexture] = entry
			end
		end

		if lookup[kit.guid] ~= nil then
			table.insert(added, kit)
		end
	end

	rawset(_G, "MOD_EXTRA_REFEREE_KITS", added)
end
