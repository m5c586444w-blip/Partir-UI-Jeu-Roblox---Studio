-- ServerScriptService/Services/DocumentService (Partie)
-- Sections 2.7, 8.3 et 16.2 : documents trouvés (texte de LoreConfig.Documents), journal du groupe
-- (appli Journal de la tablette, dans l'ordre de découverte), tablette des géologues (DOC_07, DOC_08),
-- carnet Halvorsen (DOC_12, pages débloquées par l'histoire).
-- RE_OpenDocument (S → C) : (docId) ; le client affiche DocumentGui.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local ItemConfig = require(Config:WaitForChild("ItemConfig"))
local LoreConfig = require(Config:WaitForChild("LoreConfig"))
local ProgressionConfig = require(Config:WaitForChild("ProgressionConfig"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Signal = require(Shared:WaitForChild("Signal"))
local Util = require(Shared:WaitForChild("Util"))

local DocumentService = {}

DocumentService.Read = Signal.new() -- (docId, player) : première lecture par le groupe

local services = nil
local journal = {} -- liste ordonnée des docId lus par le groupe
local openRemote = nil

local function publish()
	Util.getMatchState():SetAttribute("journal", Util.encode(journal))
end

function DocumentService:HasRead(docId)
	return table.find(journal, docId) ~= nil
end

-- ajoute au journal du groupe ; renvoie true à la première lecture
function DocumentService:AddToJournal(docId, player)
	if self:HasRead(docId) then
		return false
	end
	table.insert(journal, docId)
	publish()
	self.Read:Fire(docId, player)
	return true
end

function DocumentService:Open(player, docId)
	if openRemote and LoreConfig.Documents[docId] then
		openRemote:FireClient(player, docId)
	end
end

-- document ramassé dans le monde
function DocumentService:Collect(player, docId, _part)
	self:AddToJournal(docId, player)
	self:Open(player, docId)
	services.EvidenceService:OnDocument(player, docId)
end

-- 16.4 et 2.7 : pages du carnet (la page 1 est débloquée au départ)
local pages = table.clone(ProgressionConfig.DefaultNotebookPages)

function DocumentService:UnlockNotebookPage(index)
	pages[index] = true
	Util.getMatchState():SetAttribute("notebookPages", Util.encode(pages))
end

function DocumentService:GetNotebookPages()
	return pages
end

local function onItemUsed(player, itemId)
	if itemId == "ITM_TabletGeo" then
		-- 8.3 : la tablette des géologues contient DOC_07 et DOC_08 ; la lire copie la couche « tunnels »
		for _, docId in ItemConfig.Items.ITM_TabletGeo.documents do
			DocumentService:AddToJournal(docId, player)
		end
		Util.getMatchState():SetAttribute("tunnelLayer", true)
		DocumentService:Open(player, "DOC_07")
	elseif itemId == "ITM_Notebook" then
		-- 7.7 : la Descendante lit le carnet familial
		if player:GetAttribute("role") == "Descendant" then
			DocumentService:Open(player, "DOC_12")
		end
	end
end

function DocumentService:Init(allServices)
	services = allServices
end

function DocumentService:Start()
	openRemote = Util.getRemote("RE_OpenDocument")
	publish()
	DocumentService:UnlockNotebookPage(1)
	services.InventoryService.ItemUsed:Connect(onItemUsed)
end

return DocumentService
