import("core.foundation.cclass")
import("script-config.design.playerswitching_config")

cPlayerSwitchingConfig = cclass.getInstance("cPlayerSwitchingConfig", native.CPlayerSwitchingConfig)

-- player-switching-fixes: the native switcher scores every candidate with these
-- weights. Stock, being on camera (+6) was worth as much as being 30 m closer
-- (distanceWeight -0.2 per m), so "switch to best" often skipped the player
-- nearest the ball carrier; and being offside cost almost nothing (-0.05).
-- Now distance decides, and an offside player only wins if he's about 30 m
-- closer than the nearest onside one. The recently-controlled penalty
-- (historyTimeWeight -10 for historyExpiryTime 1.4 s) is left as is, so
-- pressing again moves on to the next closest player.
local SwitchingOverrides = {
	onCameraBonus = 0.5,
	offsideWeight = -6
}

for iter_0_0, iter_0_1 in pairs(SwitchingOverrides) do
	playerswitching_config.luaConfig[iter_0_0] = iter_0_1
end

cclass.tableMergeIntoClass(cPlayerSwitchingConfig, playerswitching_config.luaConfig, true)
