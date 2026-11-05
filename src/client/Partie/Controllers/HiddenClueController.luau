-- Controllers/HiddenClueController (Partie)
-- 19.5 (C7) : les marques de mineurs (Part taguées HiddenClue, invisibles pour tous) sont rendues
-- visibles localement pour la Descendante, à 8 studs au plus.
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local PlayerConfig = require(Config:WaitForChild("PlayerConfig"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local HiddenClueController = {}

local player = Players.LocalPlayer
local RANGE = PlayerConfig.Abilities.Descendant.HiddenClueRange

function HiddenClueController:Start()
	task.spawn(function()
		while true do
			task.wait(PlayerConfig.Technical.Tick)
			local root = Util.characterRoot(player)
			local isDescendant = player:GetAttribute("role") == "Descendant"
			for _, mark in CollectionService:GetTagged("HiddenClue") do
				local near = isDescendant and root ~= nil and (mark.Position - root.Position).Magnitude <= RANGE
				mark.Transparency = if near then 0 else 1
			end
		end
	end)
end

return HiddenClueController
