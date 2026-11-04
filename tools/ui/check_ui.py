# Vérifie que les builds contiennent tous les chemins d'UI de la section 15. Usage : python3 tools/ui/check_ui.py
import sys, xml.etree.ElementTree as ET
def paths(fn):
    root=ET.parse(fn).getroot(); out=set()
    def walk(it,p):
        n=it.find("Properties/string[@name='Name']").text
        q=p+"/"+n if p else n
        out.add(q)
        for c in it.findall("Item"): walk(c,q)
    for it in root.findall("Item"): walk(it,"")
    return out
R=["Leader","Medic","Tracker","Cameraman","Mechanic","Descendant","Geologist","Athlete","RadioOperator","Pyrotechnician"]
lobby=["DialogueGui/Dialogue/SpeakerName","DialogueGui/Dialogue/Line"]+[f"DialogueGui/Dialogue/Choices/Choice_{i}" for i in (1,2,3)]
lobby+=[f"MuseumPanelGui/Panel/{x}" for x in "Title Body Source Illustration Close".split()]
lobby+=["PartyGui/PartyFrame/Header/Title","PartyGui/PartyFrame/Header/Code","PartyGui/PartyFrame/CodeInput"]+[f"PartyGui/PartyFrame/MemberList/Template/{x}" for x in "PlayerName RoleName ReadyIcon".split()]+[f"PartyGui/PartyFrame/Buttons/{x}" for x in "CreatePublic CreatePrivate JoinCode QuickJoin Ready Leave".split()]
for r in R: lobby+=[f"RoleSelectGui/Grid/RoleCard_{r}/{x}" for x in "Portrait CharacterName RoleTitle Ability Weakness TakenOverlay/TakenBy".split()]
lobby+=["RoleSelectGui/Confirm"]
for s in "Slot_Rifle Slot_Revolver Slot_Shotgun".split(): lobby+=[f"WeaponBoardGui/Board/{s}/{x}" for x in "Icon Holder Take".split()]
lobby+=[f"WeaponBoardGui/VotePopup/{x}" for x in "Question Option_1 Option_2 Timer".split()]
lobby+=["VoteGui/Difficulty","VoteGui/Weather","VoteGui/Countdown"]
lobby+=["SkinShopGui/CharacterList/Template","SkinShopGui/Preview","SkinShopGui/Equip"]+[f"SkinShopGui/SkinGrid/{s}/{x}" for s in ("Skin_A","Skin_B","Skin_C") for x in ("Lock","Requirement")]
lobby+=[f"RecordsGui/Board/Template/{x}" for x in "Rank Group Value".split()]+[f"RecordsGui/Tabs/{x}" for x in "Survivors EvidenceA Endings".split()]
lobby+=[f"EvidenceBoardGui/Cork/Template/{x}" for x in "Photo Label Class".split()]+[f"EvidenceBoardGui/NotebookPages/Page_{i}/Lock" for i in (1,2,3)]
lobby+=[f"ResultsGui/Card/{x}" for x in "EndingTitle EndingText Survivors/Template/Name Survivors/Template/Status Evidence/Template XPGained Continue".split()]
lobby+=[f"LoadingGui/{x}" for x in "Background Tip Spinner".split()]
partie=[f"HUDGui/BodyStatus/{b}/{s}" for b in "Head Torso ArmL ArmR LegL LegR".split() for s in "Ok Hurt Critical".split()]
partie+=[f"HUDGui/{x}" for x in "BleedIcon Stamina/Fill Battery/Fill Ammo/Count Ammo/Reserve HeldItem Crosshair FearVignette Ping/Template".split()]
partie+=[f"InventoryGui/QuickSlots/Slot_{i}/{x}" for i in range(1,5) for x in "Icon Count Key Selected".split()]+["InventoryGui/Bag/Weight"]+[f"InventoryGui/Bag/List/Template/{x}" for x in "Icon Name Count Drop".split()]
partie+=[f"ObjectiveGui/{x}" for x in "ActName ObjectiveText Clock".split()]
partie+=[f"InteractGui/Prompt/{x}" for x in "KeyHint ActionText Progress/Fill".split()]
T="TabletGui/Device/Screen/"
partie+=[T+"AppBar/"+x for x in "Btn_Map Btn_Objectives Btn_Journal Btn_Evidence Btn_Network".split()]
partie+=[T+"Pages/Page_Map/"+x for x in "MapImage PlayerDot NoSignal Markers/Template TunnelLayer".split()]
partie+=[T+"Pages/Page_Objectives/List/Template",T+"Pages/Page_Journal/List/Template",T+"Pages/Page_Journal/Reader/Title",T+"Pages/Page_Journal/Reader/Body",T+"Pages/Page_Evidence/List/Template"]+[T+"Pages/Page_Network/"+x for x in "Bars Message Send".split()]
partie+=["TabletGui/Device/BatteryText","TabletGui/Device/Close"]
partie+=[f"DocumentGui/Paper/{x}" for x in "Title Body Picture Close".split()]+[f"DocumentGui/Tape/{x}" for x in "Label Play Progress/Fill".split()]
partie+=[f"DownedGui/{x}" for x in "Countdown HelpHint Bleed/Fill".split()]
partie+=[f"SpectatorGui/{x}" for x in "Watching Prev Next Note".split()]
partie+=[f"RadioGui/{x}" for x in "Channel Talking Static".split()]
partie+=[f"MobileControlsGui/{x}" for x in "Sprint Crouch Prone Interact Aim Fire Reload Light Tablet Ping LeanL LeanR".split()]
common=[f"CinematicGui/{x}" for x in "BarTop BarBottom Subtitle Skip/Votes".split()]
common+=[f"SettingsGui/Window/Tabs/{x}" for x in "Audio Controls Graphics Accessibility".split()]+["SettingsGui/Window/Pages","SettingsGui/Window/Apply","SettingsGui/Window/Reset","SettingsGui/Window/Close"]
common+=["NotificationGui/Stack/Template/Text"]
vote=[f"VoteGui/Difficulty/{x}" for x in "Normal Hard Nightmare Nightmare/Lock".split()]+[f"VoteGui/Weather/{x}" for x in "Random Clear Fog Rain Snow".split()]
for fn,exp in (("builds/Lobby.rbxlx",lobby+common+vote),("builds/Partie.rbxlx",partie+common)):
    ps=paths(fn); miss=[e for e in exp if "StarterGui/"+e not in ps]
    print(fn,len(exp),"attendus, manquants:",miss)
