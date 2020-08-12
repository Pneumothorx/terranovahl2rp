--[[
	© 2020 TERRANOVA do not share, re-distribute or modify
	without permission of its author (zacharyenriquee@gmail.com).
--]]

local PLUGIN = PLUGIN

ix.command.Add("PlaySound", {
    description = "Plays a sound to players in talking range.",
    adminOnly = true,
    arguments = {
		ix.type.text
	},
    OnRun = function(self, client, sound)
        local range = math.pow(ix.config.Get("chatRange", 280), 2)
        local playerList = {}

        range = range * range

        for _, target in pairs(player.GetAll()) do
            if((client:GetPos() - target:GetPos()):LengthSqr() <= range) then
                netstream.Start(target, "ixPlaySound", sound)
                table.insert(playerList, target:Name())
            end
        end

        if(#playerList > 0) then
            client:Notify("Playing sound '" .. sound .. "' to all players in talking range. Played for: " .. ix.util.TableToString(playerList))
        else
            client:Notify("The sound was not played for anyone.")
        end
	end
})