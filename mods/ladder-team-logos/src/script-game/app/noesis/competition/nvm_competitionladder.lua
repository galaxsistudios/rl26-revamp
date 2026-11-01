import("app.noesis.ns")
import("app.noesis.ns_viewmodel")
import("app.noesis.ns_observablecollection")
import("app.noesis.competition.nvm_competitionladderrow")

local var_0_0 = ns_viewmodel.ViewModel
local var_0_1 = ns_observablecollection.ObservableCollection

ns.Class("NVMCompetitionLadder", var_0_0, function(arg_1_0)
	var_0_0.init(arg_1_0)

	arg_1_0.Header = "Ladder"
	arg_1_0.LadderRows = var_0_1()
	arg_1_0.SelectedIndex = 0
end).Bindings = {
	Namespace = "Workspace.ViewModels.Competition",
	Properties = {
		SelectedIndex = ns.Int8,
		LadderRows = ns.typeOf(var_0_1),
		Header = ns.String
	}
}

function NVMCompetitionLadder.clearCollection(arg_2_0, arg_2_1)
	if arg_2_1 then
		for iter_2_0, iter_2_1 in arg_2_1:iter() do
			iter_2_1:dispose()
		end

		arg_2_1:clear()
	end
end

function NVMCompetitionLadder.dispose(arg_3_0)
	-- ladder-team-logos: free logos still loading
	for iter_3_0, iter_3_1 in arg_3_0.LadderRows:iter() do
		if iter_3_1.teamLogoTexture then
			iter_3_1.teamLogoTexture:unload()

			iter_3_1.teamLogoTexture = nil
		end
	end

	var_0_0.dispose(arg_3_0)
end

-- ladder-team-logos: set by CompetitionHubLadder.enter, needed to build club textures
function NVMCompetitionLadder.setLogoContext(arg_3_0, arg_3_1, arg_3_2)
	arg_3_0.logoEngine = arg_3_1
	arg_3_0.logoFrontend = arg_3_2
end

-- ladder-team-logos: rows are positional, so a re-sorted ladder hands a row a new club
function NVMCompetitionLadder.updateRowLogo(arg_3_0, arg_3_1, arg_3_2)
	if not arg_3_0.logoEngine or not arg_3_2 or arg_3_1.logoClubId == arg_3_2.id then
		return
	end

	if arg_3_1.teamLogoTexture then
		arg_3_1.teamLogoTexture:unload()

		arg_3_1.teamLogoTexture = nil
	end

	local var_3_0, var_3_1 = pcall(arg_3_1.createTeamLogoTexture, arg_3_1, arg_3_0.logoEngine, arg_3_0.logoFrontend, arg_3_2)

	if var_3_0 then
		arg_3_1.logoClubId = arg_3_2.id
	end
end

-- ladder-team-logos: CompetitionHub ticks every tab's update(); the rows swap in their logo once loaded
function NVMCompetitionLadder.update(arg_3_0)
	for iter_3_0, iter_3_1 in arg_3_0.LadderRows:iter() do
		iter_3_1:update()
	end
end

function NVMCompetitionLadder.populateLadder(arg_4_0, arg_4_1, arg_4_2, arg_4_3, arg_4_4, arg_4_5)
	if arg_4_5 then
		arg_4_0.Header = string.format("%s, %s", arg_4_5, native.Localise("Ladder"))
	end

	for iter_4_0 = 1, arg_4_3.clubCount do
		local var_4_0 = arg_4_3:getClubIdAt(iter_4_0)
		local var_4_1 = arg_4_3:getClubEntry(var_4_0)
		local var_4_2 = arg_4_1:getClub(var_4_0)
		local var_4_3 = arg_4_0.LadderRows:getComponent(iter_4_0)

		if var_4_3 then
			var_4_3:updateData(iter_4_0, var_4_2, var_4_1, arg_4_2, arg_4_4)
		else
			var_4_3 = nvm_competitionladderrow.NVMLadderRow(iter_4_0, var_4_2, var_4_1, arg_4_2, arg_4_4)

			arg_4_0.LadderRows:addItem(var_4_3)
		end

		arg_4_0:updateRowLogo(var_4_3, var_4_2)
	end

	arg_4_0.updated = true
end
