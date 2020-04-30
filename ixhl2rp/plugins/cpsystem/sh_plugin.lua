--[[
	© 2020 TERRANOVA do not share, re-distribute or modify
	without permission of its author (zacharyenriquee@gmail.com).
--]]

cpSystem = {}
cpSystem.config = {}

PLUGIN.name = "Civil Protection System";
PLUGIN.description = "tbd";
PLUGIN.author = "Adolphus";
PLUGIN.maxLength = 512;
PLUGIN.newPath = PLUGIN.folder .. "/plugin";

-- Including core files in a different location
ix.util.Include("plugin/sh_plugin.lua");
ix.lang.LoadFromDir(PLUGIN.newPath.."/languages")
ix.util.IncludeDir(PLUGIN.newPath.."/libs", true)
ix.attributes.LoadFromDir(PLUGIN.newPath.."/attributes")
ix.faction.LoadFromDir(PLUGIN.newPath.."/factions")
ix.class.LoadFromDir(PLUGIN.newPath.."/classes")
ix.item.LoadFromDir(PLUGIN.newPath.."/items")
ix.util.IncludeDir(PLUGIN.newPath.."/derma", true)
ix.plugin.LoadEntities(PLUGIN.newPath.."/entities")

--Including directories that HELIX does not natively recognise.
PLUGIN:IncludeDirectory("config");
PLUGIN:IncludeDirectory("plugin");
PLUGIN:IncludeDirectory("plugin/commands")
PLUGIN:IncludeDirectory("plugin/meta")

