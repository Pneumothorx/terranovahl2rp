--[[
	© 2020 TERRANOVA do not share, re-distribute or modify
	without permission of its author (zacharyenriquee@gmail.com).
--]]

local Schema = Schema;
local PLUGIN = PLUGIN;

function Schema:PlayerFootstep(client, position, foot, soundName, volume)
	local factionTable = ix.faction.Get(client:Team());
	local character = client:GetCharacter();

	if(character:IsUndercover()) then
		client:EmitSound(soundName);
		return true;
	end;

	if (factionTable.runSounds and client:IsRunning()) then
		client:EmitSound(factionTable.runSounds[foot]);
		return true;
	end

	client:EmitSound(soundName);
	return true;
end