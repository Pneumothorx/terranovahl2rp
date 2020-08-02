--[[
© 2020 TERRANOVA do not share, re-distribute or modify
	without permission of its author.
--]]

ITEM.name = "Human Brain"
ITEM.model = Model("models/gibs/humans/brain_gib.mdl")
ITEM.width = 1
ITEM.height = 1
ITEM.description = "The thinking part of a now non-thinking entity."
ITEM.category = "Contraband Food Meats"

ITEM.functions.Eat = {
	OnRun = function(itemTable)
		local client = itemTable.player
		client:SetHealth(math.Clamp(client:Health() + 3, 0, client:GetMaxHealth()))
	end
}