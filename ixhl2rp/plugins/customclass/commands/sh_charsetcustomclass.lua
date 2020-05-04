local PLUGIN = PLUGIN

ix.command.Add("CharSetCustomClass", {
	adminOnly = true,
	arguments = {
		ix.type.character,
		ix.type.string
	},
    OnRun = function(self, client, target, text)
        target:SetData("customclass", text);

        client:Notify(string.format("You have set the custom class of %s to %s.", target:GetName(), text))
	end
})