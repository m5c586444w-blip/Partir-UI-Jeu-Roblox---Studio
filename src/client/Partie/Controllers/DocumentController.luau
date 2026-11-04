-- Controllers/DocumentController (Partie)
-- Sections 2.7 et 15.4 : DocumentGui. Paper > Title, Body, Picture, Close ; Tape > Label, Play,
-- Progress > Fill. RE_OpenDocument (docId). Textes : LoreConfig.Documents.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local AudioConfig = require(Config:WaitForChild("AudioConfig"))
local LoreConfig = require(Config:WaitForChild("LoreConfig"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local DocumentController = {}

local root = nil

local function find(path)
	return Util.findUI(root, "DocumentGui/" .. path)
end

local function notebookText(doc)
	local pages = Util.decode(Util.getMatchState():GetAttribute("notebookPages"), { true })
	local lines = {}
	for i, text in doc.pages do
		if pages[i] then
			table.insert(lines, text)
		end
	end
	return table.concat(lines, "\n\n")
end

function DocumentController:Open(docId)
	local doc = LoreConfig.Documents[docId]
	if doc == nil or root == nil then
		return
	end
	local paper, tape = find("Paper"), find("Tape")
	local isTape = doc.kind == "Tape"
	if paper then
		paper.Visible = true
		find("Paper/Title").Text = doc.title
		find("Paper/Body").Text = if doc.pages then notebookText(doc) else (doc.body or "")
		find("Paper/Picture").Visible = doc.image ~= nil
	end
	if tape then
		tape.Visible = isTape
		find("Tape/Label").Text = doc.title
	end
	self.current = docId
end

function DocumentController:Start()
	local gui = Util.waitGui("DocumentGui")
	if gui == nil then
		return
	end
	root = gui.Parent
	local close = find("Paper/Close")
	if close then
		close.Activated:Connect(function()
			find("Paper").Visible = false
			find("Tape").Visible = false
		end)
	end
	local play = find("Tape/Play")
	if play then
		play.Activated:Connect(function()
			-- 13.7 : les enregistrements (cassettes, DOC_14) sont à fournir ; AudioConfig.Documents vide en attendant
			local soundId = AudioConfig.Documents and AudioConfig.Documents[self.current]
			if soundId == nil then
				warn("DocumentController : son manquant pour " .. tostring(self.current))
			end
		end)
	end
	local remote = Util.getRemote("RE_OpenDocument")
	if remote then
		remote.OnClientEvent:Connect(function(docId)
			self:Open(docId)
		end)
	end
end

return DocumentController
