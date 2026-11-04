# UI_MAP — interfaces de PISTE FROIDE

Livré à la fin du jalon UI (J5, phase A2), bible section 15. Généré par `tools/ui/build_ui.py`.

Pour chaque élément : son chemin, sa classe, et s'il est **lu par un script** (le contrôleur
de la colonne « Lu par » de la section 15) ou **décoratif**. Les objets de disposition
(`UIListLayout`, `UIGridLayout`, `UIAspectRatioConstraint`, `UITextSizeConstraint`, `UICorner`,
`UIStroke`) ne sont pas listés : les scripts n'y touchent jamais (15.1).

Contrat (15.1) : les scripts changent seulement `Text`, `Visible`, `Size.X.Scale` des cadres
`Fill`, les transparences, l'`Image` des icônes, et clonent les enfants `Template`.
Tout le reste (position, taille, couleurs, polices, disposition) se règle à la main dans Studio.

## Libellés hors section 15.6

15.6 : un libellé court absent du tableau prend la proposition de Claude Code, marquée DÉFAUT.

| Élément | Libellé |
| --- | --- |
| `PartyGui/PartyFrame/Header/Title` | DÉFAUT appliqué : « Groupe » |
| `SettingsGui/Window/Pages/Accessibility/SubtitleSize/Options/Opt_Small` | DÉFAUT appliqué : « Petite » |
| `SettingsGui/Window/Pages/Accessibility/SubtitleSize/Options/Opt_Large` | DÉFAUT appliqué : « Grande » |

## Éléments

### DialogueGui — StarterGui (Lobby), section 15.3

Lu par `DialogueController`.

| Chemin | Classe | Statut | Texte de départ | Remarque |
| --- | --- | --- | --- | --- |
| `DialogueGui` | ScreenGui | lu par `DialogueController` |  |  |
| `DialogueGui/Dialogue` | Frame | lu par `DialogueController` |  |  |
| `DialogueGui/Dialogue/SpeakerName` | TextLabel | lu par `DialogueController` |  |  |
| `DialogueGui/Dialogue/Line` | TextLabel | lu par `DialogueController` |  |  |
| `DialogueGui/Dialogue/Choices` | Frame | lu par `DialogueController` |  |  |
| `DialogueGui/Dialogue/Choices/Choice_1` | TextButton | lu par `DialogueController` |  |  |
| `DialogueGui/Dialogue/Choices/Choice_2` | TextButton | lu par `DialogueController` |  |  |
| `DialogueGui/Dialogue/Choices/Choice_3` | TextButton | lu par `DialogueController` |  |  |

### MuseumPanelGui — StarterGui (Lobby), section 15.3

Lu par `MuseumController`.

| Chemin | Classe | Statut | Texte de départ | Remarque |
| --- | --- | --- | --- | --- |
| `MuseumPanelGui` | ScreenGui | lu par `MuseumController` |  |  |
| `MuseumPanelGui/Panel` | Frame | lu par `MuseumController` |  |  |
| `MuseumPanelGui/Panel/Title` | TextLabel | lu par `MuseumController` |  |  |
| `MuseumPanelGui/Panel/Illustration` | ImageLabel | lu par `MuseumController` |  |  |
| `MuseumPanelGui/Panel/Body` | TextLabel | lu par `MuseumController` |  |  |
| `MuseumPanelGui/Panel/Source` | TextLabel | lu par `MuseumController` |  |  |
| `MuseumPanelGui/Panel/Close` | TextButton | lu par `MuseumController` | Fermer |  |

### PartyGui — StarterGui (Lobby), section 15.3

Lu par `PartyController`.

| Chemin | Classe | Statut | Texte de départ | Remarque |
| --- | --- | --- | --- | --- |
| `PartyGui` | ScreenGui | lu par `PartyController` |  |  |
| `PartyGui/PartyFrame` | Frame | lu par `PartyController` |  |  |
| `PartyGui/PartyFrame/Header` | Frame | lu par `PartyController` |  |  |
| `PartyGui/PartyFrame/Header/Title` | TextLabel | lu par `PartyController` | Groupe |  |
| `PartyGui/PartyFrame/Header/Code` | TextLabel | lu par `PartyController` |  |  |
| `PartyGui/PartyFrame/MemberList` | ScrollingFrame | lu par `PartyController` |  |  |
| `PartyGui/PartyFrame/MemberList/Template` | Frame | lu par `PartyController` |  |  |
| `PartyGui/PartyFrame/MemberList/Template/PlayerName` | TextLabel | lu par `PartyController` |  |  |
| `PartyGui/PartyFrame/MemberList/Template/RoleName` | TextLabel | lu par `PartyController` |  |  |
| `PartyGui/PartyFrame/MemberList/Template/ReadyIcon` | Frame | lu par `PartyController` |  |  |
| `PartyGui/PartyFrame/Buttons` | Frame | lu par `PartyController` |  |  |
| `PartyGui/PartyFrame/Buttons/CreatePublic` | TextButton | lu par `PartyController` | Groupe public |  |
| `PartyGui/PartyFrame/Buttons/CreatePrivate` | TextButton | lu par `PartyController` | Groupe privé |  |
| `PartyGui/PartyFrame/Buttons/JoinCode` | TextButton | lu par `PartyController` | Rejoindre avec un code |  |
| `PartyGui/PartyFrame/Buttons/QuickJoin` | TextButton | lu par `PartyController` | Partie rapide |  |
| `PartyGui/PartyFrame/Buttons/Ready` | TextButton | lu par `PartyController` | Prêt |  |
| `PartyGui/PartyFrame/Buttons/Leave` | TextButton | lu par `PartyController` | Quitter le groupe |  |
| `PartyGui/PartyFrame/CodeInput` | TextBox | lu par `PartyController` |  |  |

### RoleSelectGui — StarterGui (Lobby), section 15.3

Lu par `RoleController`.

| Chemin | Classe | Statut | Texte de départ | Remarque |
| --- | --- | --- | --- | --- |
| `RoleSelectGui` | ScreenGui | lu par `RoleController` |  |  |
| `RoleSelectGui/Grid` | ScrollingFrame | lu par `RoleController` |  |  |
| `RoleSelectGui/Grid/RoleCard_Leader` | TextButton | lu par `RoleController` |  |  |
| `RoleSelectGui/Grid/RoleCard_Leader/Portrait` | ViewportFrame | lu par `RoleController` |  | 13.5 : affiche le modèle Skin_A du rôle |
| `RoleSelectGui/Grid/RoleCard_Leader/CharacterName` | TextLabel | lu par `RoleController` | Caleb Marsh |  |
| `RoleSelectGui/Grid/RoleCard_Leader/RoleTitle` | TextLabel | lu par `RoleController` | Meneur |  |
| `RoleSelectGui/Grid/RoleCard_Leader/Ability` | TextLabel | lu par `RoleController` | Voit ses coéquipiers en contour à travers le décor ; donne un ordre qui réduit la peur |  |
| `RoleSelectGui/Grid/RoleCard_Leader/Weakness` | TextLabel | lu par `RoleController` | Aucune |  |
| `RoleSelectGui/Grid/RoleCard_Leader/TakenOverlay` | Frame | lu par `RoleController` |  |  |
| `RoleSelectGui/Grid/RoleCard_Leader/TakenOverlay/TakenBy` | TextLabel | lu par `RoleController` |  |  |
| `RoleSelectGui/Grid/RoleCard_Medic` | TextButton | lu par `RoleController` |  |  |
| `RoleSelectGui/Grid/RoleCard_Medic/Portrait` | ViewportFrame | lu par `RoleController` |  | 13.5 : affiche le modèle Skin_A du rôle |
| `RoleSelectGui/Grid/RoleCard_Medic/CharacterName` | TextLabel | lu par `RoleController` | Priya Natarajan |  |
| `RoleSelectGui/Grid/RoleCard_Medic/RoleTitle` | TextLabel | lu par `RoleController` | Médecin |  |
| `RoleSelectGui/Grid/RoleCard_Medic/Ability` | TextLabel | lu par `RoleController` | Soigne vite, arrête les hémorragies graves |  |
| `RoleSelectGui/Grid/RoleCard_Medic/Weakness` | TextLabel | lu par `RoleController` | Course à 18 |  |
| `RoleSelectGui/Grid/RoleCard_Medic/TakenOverlay` | Frame | lu par `RoleController` |  |  |
| `RoleSelectGui/Grid/RoleCard_Medic/TakenOverlay/TakenBy` | TextLabel | lu par `RoleController` |  |  |
| `RoleSelectGui/Grid/RoleCard_Tracker` | TextButton | lu par `RoleController` |  |  |
| `RoleSelectGui/Grid/RoleCard_Tracker/Portrait` | ViewportFrame | lu par `RoleController` |  | 13.5 : affiche le modèle Skin_A du rôle |
| `RoleSelectGui/Grid/RoleCard_Tracker/CharacterName` | TextLabel | lu par `RoleController` | Wyatt Dunn |  |
| `RoleSelectGui/Grid/RoleCard_Tracker/RoleTitle` | TextLabel | lu par `RoleController` | Pisteur |  |
| `RoleSelectGui/Grid/RoleCard_Tracker/Ability` | TextLabel | lu par `RoleController` | Voit les empreintes fraîches en surbrillance ; devine la direction de la créature |  |
| `RoleSelectGui/Grid/RoleCard_Tracker/Weakness` | TextLabel | lu par `RoleController` | Ses tirs comptent double pour la rancune |  |
| `RoleSelectGui/Grid/RoleCard_Tracker/TakenOverlay` | Frame | lu par `RoleController` |  |  |
| `RoleSelectGui/Grid/RoleCard_Tracker/TakenOverlay/TakenBy` | TextLabel | lu par `RoleController` |  |  |
| `RoleSelectGui/Grid/RoleCard_Cameraman` | TextButton | lu par `RoleController` |  |  |
| `RoleSelectGui/Grid/RoleCard_Cameraman/Portrait` | ViewportFrame | lu par `RoleController` |  | 13.5 : affiche le modèle Skin_A du rôle |
| `RoleSelectGui/Grid/RoleCard_Cameraman/CharacterName` | TextLabel | lu par `RoleController` | Theo Lindqvist |  |
| `RoleSelectGui/Grid/RoleCard_Cameraman/RoleTitle` | TextLabel | lu par `RoleController` | Caméraman |  |
| `RoleSelectGui/Grid/RoleCard_Cameraman/Ability` | TextLabel | lu par `RoleController` | Seul à produire des preuves de classe A |  |
| `RoleSelectGui/Grid/RoleCard_Cameraman/Weakness` | TextLabel | lu par `RoleController` | Batterie de 6 min |  |
| `RoleSelectGui/Grid/RoleCard_Cameraman/TakenOverlay` | Frame | lu par `RoleController` |  |  |
| `RoleSelectGui/Grid/RoleCard_Cameraman/TakenOverlay/TakenBy` | TextLabel | lu par `RoleController` |  |  |
| `RoleSelectGui/Grid/RoleCard_Mechanic` | TextButton | lu par `RoleController` |  |  |
| `RoleSelectGui/Grid/RoleCard_Mechanic/Portrait` | ViewportFrame | lu par `RoleController` |  | 13.5 : affiche le modèle Skin_A du rôle |
| `RoleSelectGui/Grid/RoleCard_Mechanic/CharacterName` | TextLabel | lu par `RoleController` | Rosa Delgado |  |
| `RoleSelectGui/Grid/RoleCard_Mechanic/RoleTitle` | TextLabel | lu par `RoleController` | Mécanicienne |  |
| `RoleSelectGui/Grid/RoleCard_Mechanic/Ability` | TextLabel | lu par `RoleController` | Répare deux fois plus vite |  |
| `RoleSelectGui/Grid/RoleCard_Mechanic/Weakness` | TextLabel | lu par `RoleController` | Inventaire : 3 emplacements rapides au lieu de 4 |  |
| `RoleSelectGui/Grid/RoleCard_Mechanic/TakenOverlay` | Frame | lu par `RoleController` |  |  |
| `RoleSelectGui/Grid/RoleCard_Mechanic/TakenOverlay/TakenBy` | TextLabel | lu par `RoleController` |  |  |
| `RoleSelectGui/Grid/RoleCard_Descendant` | TextButton | lu par `RoleController` |  |  |
| `RoleSelectGui/Grid/RoleCard_Descendant/Portrait` | ViewportFrame | lu par `RoleController` |  | 13.5 : affiche le modèle Skin_A du rôle |
| `RoleSelectGui/Grid/RoleCard_Descendant/CharacterName` | TextLabel | lu par `RoleController` | Nora Halvorsen |  |
| `RoleSelectGui/Grid/RoleCard_Descendant/RoleTitle` | TextLabel | lu par `RoleController` | Descendante |  |
| `RoleSelectGui/Grid/RoleCard_Descendant/Ability` | TextLabel | lu par `RoleController` | Lit le carnet familial, voit les indices cachés |  |
| `RoleSelectGui/Grid/RoleCard_Descendant/Weakness` | TextLabel | lu par `RoleController` | Peur ×1,25 |  |
| `RoleSelectGui/Grid/RoleCard_Descendant/TakenOverlay` | Frame | lu par `RoleController` |  |  |
| `RoleSelectGui/Grid/RoleCard_Descendant/TakenOverlay/TakenBy` | TextLabel | lu par `RoleController` |  |  |
| `RoleSelectGui/Grid/RoleCard_Geologist` | TextButton | lu par `RoleController` |  |  |
| `RoleSelectGui/Grid/RoleCard_Geologist/Portrait` | ViewportFrame | lu par `RoleController` |  | 13.5 : affiche le modèle Skin_A du rôle |
| `RoleSelectGui/Grid/RoleCard_Geologist/CharacterName` | TextLabel | lu par `RoleController` | Malik Okafor |  |
| `RoleSelectGui/Grid/RoleCard_Geologist/RoleTitle` | TextLabel | lu par `RoleController` | Géologue |  |
| `RoleSelectGui/Grid/RoleCard_Geologist/Ability` | TextLabel | lu par `RoleController` | Lit la carte des tunnels, se repère sous terre |  |
| `RoleSelectGui/Grid/RoleCard_Geologist/Weakness` | TextLabel | lu par `RoleController` | Endurance 80 |  |
| `RoleSelectGui/Grid/RoleCard_Geologist/TakenOverlay` | Frame | lu par `RoleController` |  |  |
| `RoleSelectGui/Grid/RoleCard_Geologist/TakenOverlay/TakenBy` | TextLabel | lu par `RoleController` |  |  |
| `RoleSelectGui/Grid/RoleCard_Athlete` | TextButton | lu par `RoleController` |  |  |
| `RoleSelectGui/Grid/RoleCard_Athlete/Portrait` | ViewportFrame | lu par `RoleController` |  | 13.5 : affiche le modèle Skin_A du rôle |
| `RoleSelectGui/Grid/RoleCard_Athlete/CharacterName` | TextLabel | lu par `RoleController` | Jake Kowalski |  |
| `RoleSelectGui/Grid/RoleCard_Athlete/RoleTitle` | TextLabel | lu par `RoleController` | Sportif |  |
| `RoleSelectGui/Grid/RoleCard_Athlete/Ability` | TextLabel | lu par `RoleController` | Porte un blessé en courant, barricade vite |  |
| `RoleSelectGui/Grid/RoleCard_Athlete/Weakness` | TextLabel | lu par `RoleController` | Respiration : bruit de course 75 |  |
| `RoleSelectGui/Grid/RoleCard_Athlete/TakenOverlay` | Frame | lu par `RoleController` |  |  |
| `RoleSelectGui/Grid/RoleCard_Athlete/TakenOverlay/TakenBy` | TextLabel | lu par `RoleController` |  |  |
| `RoleSelectGui/Grid/RoleCard_RadioOperator` | TextButton | lu par `RoleController` |  |  |
| `RoleSelectGui/Grid/RoleCard_RadioOperator/Portrait` | ViewportFrame | lu par `RoleController` |  | 13.5 : affiche le modèle Skin_A du rôle |
| `RoleSelectGui/Grid/RoleCard_RadioOperator/CharacterName` | TextLabel | lu par `RoleController` | Mei Tanaka |  |
| `RoleSelectGui/Grid/RoleCard_RadioOperator/RoleTitle` | TextLabel | lu par `RoleController` | Opératrice radio |  |
| `RoleSelectGui/Grid/RoleCard_RadioOperator/Ability` | TextLabel | lu par `RoleController` | Écoute les fréquences, repère les voix imitées |  |
| `RoleSelectGui/Grid/RoleCard_RadioOperator/Weakness` | TextLabel | lu par `RoleController` | Aucune arme à feu possible |  |
| `RoleSelectGui/Grid/RoleCard_RadioOperator/TakenOverlay` | Frame | lu par `RoleController` |  |  |
| `RoleSelectGui/Grid/RoleCard_RadioOperator/TakenOverlay/TakenBy` | TextLabel | lu par `RoleController` |  |  |
| `RoleSelectGui/Grid/RoleCard_Pyrotechnician` | TextButton | lu par `RoleController` |  |  |
| `RoleSelectGui/Grid/RoleCard_Pyrotechnician/Portrait` | ViewportFrame | lu par `RoleController` |  | 13.5 : affiche le modèle Skin_A du rôle |
| `RoleSelectGui/Grid/RoleCard_Pyrotechnician/CharacterName` | TextLabel | lu par `RoleController` | Dylan Croft |  |
| `RoleSelectGui/Grid/RoleCard_Pyrotechnician/RoleTitle` | TextLabel | lu par `RoleController` | Pyrotechnicien |  |
| `RoleSelectGui/Grid/RoleCard_Pyrotechnician/Ability` | TextLabel | lu par `RoleController` | Fabrique une fusée ou un piège à bruit |  |
| `RoleSelectGui/Grid/RoleCard_Pyrotechnician/Weakness` | TextLabel | lu par `RoleController` | Torse 80 PV |  |
| `RoleSelectGui/Grid/RoleCard_Pyrotechnician/TakenOverlay` | Frame | lu par `RoleController` |  |  |
| `RoleSelectGui/Grid/RoleCard_Pyrotechnician/TakenOverlay/TakenBy` | TextLabel | lu par `RoleController` |  |  |
| `RoleSelectGui/Confirm` | TextButton | lu par `RoleController` | Confirmer |  |

### WeaponBoardGui — StarterGui (Lobby), section 15.3

Lu par `WeaponBoardController`.

| Chemin | Classe | Statut | Texte de départ | Remarque |
| --- | --- | --- | --- | --- |
| `WeaponBoardGui` | ScreenGui | lu par `WeaponBoardController` |  |  |
| `WeaponBoardGui/Board` | Frame | lu par `WeaponBoardController` |  |  |
| `WeaponBoardGui/Board/Slot_Rifle` | Frame | lu par `WeaponBoardController` |  |  |
| `WeaponBoardGui/Board/Slot_Rifle/Icon` | ImageLabel | lu par `WeaponBoardController` |  | icône d'arme : asset à créer |
| `WeaponBoardGui/Board/Slot_Rifle/WeaponName` | TextLabel | décoratif | Fusil à verrou |  |
| `WeaponBoardGui/Board/Slot_Rifle/Holder` | TextLabel | lu par `WeaponBoardController` |  |  |
| `WeaponBoardGui/Board/Slot_Rifle/Take` | TextButton | lu par `WeaponBoardController` | Prendre |  |
| `WeaponBoardGui/Board/Slot_Revolver` | Frame | lu par `WeaponBoardController` |  |  |
| `WeaponBoardGui/Board/Slot_Revolver/Icon` | ImageLabel | lu par `WeaponBoardController` |  | icône d'arme : asset à créer |
| `WeaponBoardGui/Board/Slot_Revolver/WeaponName` | TextLabel | décoratif | Revolver |  |
| `WeaponBoardGui/Board/Slot_Revolver/Holder` | TextLabel | lu par `WeaponBoardController` |  |  |
| `WeaponBoardGui/Board/Slot_Revolver/Take` | TextButton | lu par `WeaponBoardController` | Prendre |  |
| `WeaponBoardGui/Board/Slot_Shotgun` | Frame | lu par `WeaponBoardController` |  |  |
| `WeaponBoardGui/Board/Slot_Shotgun/Icon` | ImageLabel | lu par `WeaponBoardController` |  | icône d'arme : asset à créer |
| `WeaponBoardGui/Board/Slot_Shotgun/WeaponName` | TextLabel | décoratif | Fusil à pompe |  |
| `WeaponBoardGui/Board/Slot_Shotgun/Holder` | TextLabel | lu par `WeaponBoardController` |  |  |
| `WeaponBoardGui/Board/Slot_Shotgun/Take` | TextButton | lu par `WeaponBoardController` | Prendre |  |
| `WeaponBoardGui/VotePopup` | Frame | lu par `WeaponBoardController` |  |  |
| `WeaponBoardGui/VotePopup/Question` | TextLabel | lu par `WeaponBoardController` |  |  |
| `WeaponBoardGui/VotePopup/Option_1` | TextButton | lu par `WeaponBoardController` |  |  |
| `WeaponBoardGui/VotePopup/Option_2` | TextButton | lu par `WeaponBoardController` |  |  |
| `WeaponBoardGui/VotePopup/Timer` | TextLabel | lu par `WeaponBoardController` |  |  |

### VoteGui — StarterGui (Lobby), section 15.3

Lu par `VoteController`.

| Chemin | Classe | Statut | Texte de départ | Remarque |
| --- | --- | --- | --- | --- |
| `VoteGui` | ScreenGui | lu par `VoteController` |  |  |
| `VoteGui/Difficulty` | Frame | lu par `VoteController` |  |  |
| `VoteGui/Difficulty/Title` | TextLabel | décoratif | Difficulté |  |
| `VoteGui/Difficulty/Normal` | TextButton | lu par `VoteController` | Normal |  |
| `VoteGui/Difficulty/Hard` | TextButton | lu par `VoteController` | Difficile |  |
| `VoteGui/Difficulty/Nightmare` | TextButton | lu par `VoteController` | Cauchemar |  |
| `VoteGui/Difficulty/Nightmare/Lock` | TextLabel | lu par `VoteController` | Verrouillé |  |
| `VoteGui/Weather` | Frame | lu par `VoteController` |  |  |
| `VoteGui/Weather/Title` | TextLabel | décoratif | Météo |  |
| `VoteGui/Weather/Random` | TextButton | lu par `VoteController` | Aléatoire |  |
| `VoteGui/Weather/Clear` | TextButton | lu par `VoteController` | Nuit claire |  |
| `VoteGui/Weather/Fog` | TextButton | lu par `VoteController` | Brouillard |  |
| `VoteGui/Weather/Rain` | TextButton | lu par `VoteController` | Pluie |  |
| `VoteGui/Weather/Snow` | TextButton | lu par `VoteController` | Première neige |  |
| `VoteGui/Countdown` | TextLabel | lu par `VoteController` |  |  |

### SkinShopGui — StarterGui (Lobby), section 15.3

Lu par `SkinShopController`.

| Chemin | Classe | Statut | Texte de départ | Remarque |
| --- | --- | --- | --- | --- |
| `SkinShopGui` | ScreenGui | lu par `SkinShopController` |  |  |
| `SkinShopGui/CharacterList` | Frame | lu par `SkinShopController` |  |  |
| `SkinShopGui/CharacterList/Template` | TextButton | lu par `SkinShopController` |  |  |
| `SkinShopGui/SkinGrid` | Frame | lu par `SkinShopController` |  |  |
| `SkinShopGui/SkinGrid/Skin_A` | TextButton | lu par `SkinShopController` | Tenue de départ |  |
| `SkinShopGui/SkinGrid/Skin_A/Lock` | TextLabel | lu par `SkinShopController` | Verrouillé |  |
| `SkinShopGui/SkinGrid/Skin_A/Requirement` | TextLabel | lu par `SkinShopController` |  |  |
| `SkinShopGui/SkinGrid/Skin_B` | TextButton | lu par `SkinShopController` | Tenue de pluie |  |
| `SkinShopGui/SkinGrid/Skin_B/Lock` | TextLabel | lu par `SkinShopController` | Verrouillé |  |
| `SkinShopGui/SkinGrid/Skin_B/Requirement` | TextLabel | lu par `SkinShopController` | 5 parties jouées |  |
| `SkinShopGui/SkinGrid/Skin_C` | TextButton | lu par `SkinShopController` | Tenue « Cold Trail » |  |
| `SkinShopGui/SkinGrid/Skin_C/Lock` | TextLabel | lu par `SkinShopController` | Verrouillé |  |
| `SkinShopGui/SkinGrid/Skin_C/Requirement` | TextLabel | lu par `SkinShopController` | 1 survie |  |
| `SkinShopGui/Preview` | ViewportFrame | lu par `SkinShopController` |  |  |
| `SkinShopGui/Equip` | TextButton | lu par `SkinShopController` | Équiper |  |

### RecordsGui — StarterGui (Lobby), section 15.3

Lu par `RecordsController`.

| Chemin | Classe | Statut | Texte de départ | Remarque |
| --- | --- | --- | --- | --- |
| `RecordsGui` | ScreenGui | lu par `RecordsController` |  |  |
| `RecordsGui/Tabs` | Frame | lu par `RecordsController` |  |  |
| `RecordsGui/Tabs/Survivors` | TextButton | lu par `RecordsController` | Survivants |  |
| `RecordsGui/Tabs/EvidenceA` | TextButton | lu par `RecordsController` | Preuves A |  |
| `RecordsGui/Tabs/Endings` | TextButton | lu par `RecordsController` | Fins |  |
| `RecordsGui/Board` | ScrollingFrame | lu par `RecordsController` |  |  |
| `RecordsGui/Board/Template` | Frame | lu par `RecordsController` |  |  |
| `RecordsGui/Board/Template/Rank` | TextLabel | lu par `RecordsController` |  |  |
| `RecordsGui/Board/Template/Group` | TextLabel | lu par `RecordsController` |  |  |
| `RecordsGui/Board/Template/Value` | TextLabel | lu par `RecordsController` |  |  |

### EvidenceBoardGui — StarterGui (Lobby), section 15.3

Lu par `EvidenceBoardController`.

| Chemin | Classe | Statut | Texte de départ | Remarque |
| --- | --- | --- | --- | --- |
| `EvidenceBoardGui` | ScreenGui | lu par `EvidenceBoardController` |  |  |
| `EvidenceBoardGui/Cork` | Frame | lu par `EvidenceBoardController` |  |  |
| `EvidenceBoardGui/Cork/Template` | Frame | lu par `EvidenceBoardController` |  |  |
| `EvidenceBoardGui/Cork/Template/Photo` | ImageLabel | lu par `EvidenceBoardController` |  |  |
| `EvidenceBoardGui/Cork/Template/Label` | TextLabel | lu par `EvidenceBoardController` |  |  |
| `EvidenceBoardGui/Cork/Template/Class` | TextLabel | lu par `EvidenceBoardController` |  |  |
| `EvidenceBoardGui/NotebookPages` | Frame | lu par `EvidenceBoardController` |  |  |
| `EvidenceBoardGui/NotebookPages/Page_1` | TextLabel | lu par `EvidenceBoardController` | Il n'a jamais voulu en parler. Il disait seulement : ne tire pas le premier. |  |
| `EvidenceBoardGui/NotebookPages/Page_1/Lock` | TextLabel | lu par `EvidenceBoardController` | Verrouillé |  |
| `EvidenceBoardGui/NotebookPages/Page_2` | TextLabel | lu par `EvidenceBoardController` | Ils frappaient les arbres avant les pierres. |  |
| `EvidenceBoardGui/NotebookPages/Page_2/Lock` | TextLabel | lu par `EvidenceBoardController` | Verrouillé |  |
| `EvidenceBoardGui/NotebookPages/Page_3` | TextLabel | lu par `EvidenceBoardController` | On leur avait pris quelqu'un, à eux aussi. |  |
| `EvidenceBoardGui/NotebookPages/Page_3/Lock` | TextLabel | lu par `EvidenceBoardController` | Verrouillé |  |

### ResultsGui — StarterGui (Lobby), section 15.3

Lu par `ResultsController`.

| Chemin | Classe | Statut | Texte de départ | Remarque |
| --- | --- | --- | --- | --- |
| `ResultsGui` | ScreenGui | lu par `ResultsController` |  |  |
| `ResultsGui/Card` | Frame | lu par `ResultsController` |  |  |
| `ResultsGui/Card/EndingTitle` | TextLabel | lu par `ResultsController` |  |  |
| `ResultsGui/Card/EndingText` | TextLabel | lu par `ResultsController` |  |  |
| `ResultsGui/Card/Survivors` | ScrollingFrame | lu par `ResultsController` |  |  |
| `ResultsGui/Card/Survivors/Template` | Frame | lu par `ResultsController` |  |  |
| `ResultsGui/Card/Survivors/Template/Name` | TextLabel | lu par `ResultsController` |  |  |
| `ResultsGui/Card/Survivors/Template/Status` | TextLabel | lu par `ResultsController` |  |  |
| `ResultsGui/Card/Evidence` | ScrollingFrame | lu par `ResultsController` |  |  |
| `ResultsGui/Card/Evidence/Template` | TextLabel | lu par `ResultsController` |  |  |
| `ResultsGui/Card/XPGained` | TextLabel | lu par `ResultsController` |  |  |
| `ResultsGui/Card/Continue` | TextButton | lu par `ResultsController` | Continuer |  |

### LoadingGui — StarterGui (Lobby), section 15.3

Lu par `TeleportController`.

| Chemin | Classe | Statut | Texte de départ | Remarque |
| --- | --- | --- | --- | --- |
| `LoadingGui` | ScreenGui | lu par `TeleportController` |  |  |
| `LoadingGui/Background` | Frame | lu par `TeleportController` |  |  |
| `LoadingGui/Tip` | TextLabel | lu par `TeleportController` |  |  |
| `LoadingGui/Spinner` | Frame | décoratif |  | décor ; à remplacer par une image |

### HUDGui — StarterGui (Partie), section 15.4

Lu par `HUDController`.

| Chemin | Classe | Statut | Texte de départ | Remarque |
| --- | --- | --- | --- | --- |
| `HUDGui` | ScreenGui | lu par `HUDController` |  |  |
| `HUDGui/FearVignette` | ImageLabel | lu par `HUDController` |  | image de vignettage : absente de 13.5 (asset à fournir) ; ImageTransparency réglée par le script |
| `HUDGui/BodyStatus` | Frame | lu par `HUDController` |  |  |
| `HUDGui/BodyStatus/Head` | Frame | lu par `HUDController` |  |  |
| `HUDGui/BodyStatus/Head/Ok` | Frame | lu par `HUDController` |  |  |
| `HUDGui/BodyStatus/Head/Hurt` | Frame | lu par `HUDController` |  |  |
| `HUDGui/BodyStatus/Head/Critical` | Frame | lu par `HUDController` |  |  |
| `HUDGui/BodyStatus/Torso` | Frame | lu par `HUDController` |  |  |
| `HUDGui/BodyStatus/Torso/Ok` | Frame | lu par `HUDController` |  |  |
| `HUDGui/BodyStatus/Torso/Hurt` | Frame | lu par `HUDController` |  |  |
| `HUDGui/BodyStatus/Torso/Critical` | Frame | lu par `HUDController` |  |  |
| `HUDGui/BodyStatus/ArmL` | Frame | lu par `HUDController` |  |  |
| `HUDGui/BodyStatus/ArmL/Ok` | Frame | lu par `HUDController` |  |  |
| `HUDGui/BodyStatus/ArmL/Hurt` | Frame | lu par `HUDController` |  |  |
| `HUDGui/BodyStatus/ArmL/Critical` | Frame | lu par `HUDController` |  |  |
| `HUDGui/BodyStatus/ArmR` | Frame | lu par `HUDController` |  |  |
| `HUDGui/BodyStatus/ArmR/Ok` | Frame | lu par `HUDController` |  |  |
| `HUDGui/BodyStatus/ArmR/Hurt` | Frame | lu par `HUDController` |  |  |
| `HUDGui/BodyStatus/ArmR/Critical` | Frame | lu par `HUDController` |  |  |
| `HUDGui/BodyStatus/LegL` | Frame | lu par `HUDController` |  |  |
| `HUDGui/BodyStatus/LegL/Ok` | Frame | lu par `HUDController` |  |  |
| `HUDGui/BodyStatus/LegL/Hurt` | Frame | lu par `HUDController` |  |  |
| `HUDGui/BodyStatus/LegL/Critical` | Frame | lu par `HUDController` |  |  |
| `HUDGui/BodyStatus/LegR` | Frame | lu par `HUDController` |  |  |
| `HUDGui/BodyStatus/LegR/Ok` | Frame | lu par `HUDController` |  |  |
| `HUDGui/BodyStatus/LegR/Hurt` | Frame | lu par `HUDController` |  |  |
| `HUDGui/BodyStatus/LegR/Critical` | Frame | lu par `HUDController` |  |  |
| `HUDGui/BleedIcon` | Frame | lu par `HUDController` |  |  |
| `HUDGui/Stamina` | Frame | lu par `HUDController` |  |  |
| `HUDGui/Stamina/Fill` | Frame | lu par `HUDController` |  |  |
| `HUDGui/Battery` | Frame | lu par `HUDController` |  |  |
| `HUDGui/Battery/Fill` | Frame | lu par `HUDController` |  |  |
| `HUDGui/Ammo` | Frame | lu par `HUDController` |  |  |
| `HUDGui/Ammo/Count` | TextLabel | lu par `HUDController` |  |  |
| `HUDGui/Ammo/Reserve` | TextLabel | lu par `HUDController` |  |  |
| `HUDGui/HeldItem` | TextLabel | lu par `HUDController` |  |  |
| `HUDGui/Crosshair` | Frame | lu par `HUDController` |  |  |
| `HUDGui/Ping` | Frame | lu par `HUDController` |  |  |
| `HUDGui/Ping/Template` | Frame | lu par `HUDController` |  |  |

### InventoryGui — StarterGui (Partie), section 15.4

Lu par `InventoryController`.

| Chemin | Classe | Statut | Texte de départ | Remarque |
| --- | --- | --- | --- | --- |
| `InventoryGui` | ScreenGui | lu par `InventoryController` |  |  |
| `InventoryGui/QuickSlots` | Frame | lu par `InventoryController` |  |  |
| `InventoryGui/QuickSlots/Slot_1` | Frame | lu par `InventoryController` |  |  |
| `InventoryGui/QuickSlots/Slot_1/Icon` | ImageLabel | lu par `InventoryController` |  |  |
| `InventoryGui/QuickSlots/Slot_1/Count` | TextLabel | lu par `InventoryController` |  |  |
| `InventoryGui/QuickSlots/Slot_1/Key` | TextLabel | lu par `InventoryController` |  |  |
| `InventoryGui/QuickSlots/Slot_1/Selected` | Frame | lu par `InventoryController` |  |  |
| `InventoryGui/QuickSlots/Slot_2` | Frame | lu par `InventoryController` |  |  |
| `InventoryGui/QuickSlots/Slot_2/Icon` | ImageLabel | lu par `InventoryController` |  |  |
| `InventoryGui/QuickSlots/Slot_2/Count` | TextLabel | lu par `InventoryController` |  |  |
| `InventoryGui/QuickSlots/Slot_2/Key` | TextLabel | lu par `InventoryController` |  |  |
| `InventoryGui/QuickSlots/Slot_2/Selected` | Frame | lu par `InventoryController` |  |  |
| `InventoryGui/QuickSlots/Slot_3` | Frame | lu par `InventoryController` |  |  |
| `InventoryGui/QuickSlots/Slot_3/Icon` | ImageLabel | lu par `InventoryController` |  |  |
| `InventoryGui/QuickSlots/Slot_3/Count` | TextLabel | lu par `InventoryController` |  |  |
| `InventoryGui/QuickSlots/Slot_3/Key` | TextLabel | lu par `InventoryController` |  |  |
| `InventoryGui/QuickSlots/Slot_3/Selected` | Frame | lu par `InventoryController` |  |  |
| `InventoryGui/QuickSlots/Slot_4` | Frame | lu par `InventoryController` |  |  |
| `InventoryGui/QuickSlots/Slot_4/Icon` | ImageLabel | lu par `InventoryController` |  |  |
| `InventoryGui/QuickSlots/Slot_4/Count` | TextLabel | lu par `InventoryController` |  |  |
| `InventoryGui/QuickSlots/Slot_4/Key` | TextLabel | lu par `InventoryController` |  |  |
| `InventoryGui/QuickSlots/Slot_4/Selected` | Frame | lu par `InventoryController` |  |  |
| `InventoryGui/Bag` | Frame | lu par `InventoryController` |  |  |
| `InventoryGui/Bag/Weight` | TextLabel | lu par `InventoryController` |  |  |
| `InventoryGui/Bag/List` | ScrollingFrame | lu par `InventoryController` |  |  |
| `InventoryGui/Bag/List/Template` | Frame | lu par `InventoryController` |  |  |
| `InventoryGui/Bag/List/Template/Icon` | ImageLabel | lu par `InventoryController` |  |  |
| `InventoryGui/Bag/List/Template/Name` | TextLabel | lu par `InventoryController` |  |  |
| `InventoryGui/Bag/List/Template/Count` | TextLabel | lu par `InventoryController` |  |  |
| `InventoryGui/Bag/List/Template/Drop` | TextButton | lu par `InventoryController` | Jeter |  |

### ObjectiveGui — StarterGui (Partie), section 15.4

Lu par `ObjectiveController`.

| Chemin | Classe | Statut | Texte de départ | Remarque |
| --- | --- | --- | --- | --- |
| `ObjectiveGui` | ScreenGui | lu par `ObjectiveController` |  |  |
| `ObjectiveGui/ActName` | TextLabel | lu par `ObjectiveController` |  |  |
| `ObjectiveGui/ObjectiveText` | TextLabel | lu par `ObjectiveController` |  |  |
| `ObjectiveGui/Clock` | TextLabel | lu par `ObjectiveController` |  |  |

### InteractGui — StarterGui (Partie), section 15.4

Lu par `InteractController`.

| Chemin | Classe | Statut | Texte de départ | Remarque |
| --- | --- | --- | --- | --- |
| `InteractGui` | ScreenGui | lu par `InteractController` |  |  |
| `InteractGui/Prompt` | Frame | lu par `InteractController` |  |  |
| `InteractGui/Prompt/KeyHint` | TextLabel | lu par `InteractController` |  |  |
| `InteractGui/Prompt/ActionText` | TextLabel | lu par `InteractController` |  |  |
| `InteractGui/Prompt/Progress` | Frame | lu par `InteractController` |  |  |
| `InteractGui/Prompt/Progress/Fill` | Frame | lu par `InteractController` |  |  |

### TabletGui — StarterGui (Partie), section 15.4

Lu par `TabletController`.

| Chemin | Classe | Statut | Texte de départ | Remarque |
| --- | --- | --- | --- | --- |
| `TabletGui` | ScreenGui | lu par `TabletController` |  |  |
| `TabletGui/Device` | Frame | lu par `TabletController` |  |  |
| `TabletGui/Device/Screen` | Frame | lu par `TabletController` |  |  |
| `TabletGui/Device/Screen/AppBar` | Frame | lu par `TabletController` |  |  |
| `TabletGui/Device/Screen/AppBar/Btn_Map` | TextButton | lu par `TabletController` | Carte |  |
| `TabletGui/Device/Screen/AppBar/Btn_Objectives` | TextButton | lu par `TabletController` | Objectifs |  |
| `TabletGui/Device/Screen/AppBar/Btn_Journal` | TextButton | lu par `TabletController` | Journal |  |
| `TabletGui/Device/Screen/AppBar/Btn_Evidence` | TextButton | lu par `TabletController` | Preuves |  |
| `TabletGui/Device/Screen/AppBar/Btn_Network` | TextButton | lu par `TabletController` | Réseau |  |
| `TabletGui/Device/Screen/Pages` | Frame | lu par `TabletController` |  |  |
| `TabletGui/Device/Screen/Pages/Page_Map` | Frame | lu par `TabletController` |  |  |
| `TabletGui/Device/Screen/Pages/Page_Map/MapImage` | ImageLabel | lu par `TabletController` |  | Img_TabletMap (13.5) : image à créer |
| `TabletGui/Device/Screen/Pages/Page_Map/TunnelLayer` | ImageLabel | lu par `TabletController` |  | couche « tunnels » après DOC_07 : image à créer |
| `TabletGui/Device/Screen/Pages/Page_Map/Markers` | Frame | lu par `TabletController` |  |  |
| `TabletGui/Device/Screen/Pages/Page_Map/Markers/Template` | Frame | lu par `TabletController` |  |  |
| `TabletGui/Device/Screen/Pages/Page_Map/PlayerDot` | Frame | lu par `TabletController` |  |  |
| `TabletGui/Device/Screen/Pages/Page_Map/NoSignal` | TextLabel | lu par `TabletController` | Pas de signal GPS |  |
| `TabletGui/Device/Screen/Pages/Page_Objectives` | Frame | lu par `TabletController` |  |  |
| `TabletGui/Device/Screen/Pages/Page_Objectives/List` | ScrollingFrame | lu par `TabletController` |  |  |
| `TabletGui/Device/Screen/Pages/Page_Objectives/List/Template` | TextLabel | lu par `TabletController` |  |  |
| `TabletGui/Device/Screen/Pages/Page_Journal` | Frame | lu par `TabletController` |  |  |
| `TabletGui/Device/Screen/Pages/Page_Journal/List` | ScrollingFrame | lu par `TabletController` |  |  |
| `TabletGui/Device/Screen/Pages/Page_Journal/List/Template` | TextButton | lu par `TabletController` |  |  |
| `TabletGui/Device/Screen/Pages/Page_Journal/Reader` | Frame | lu par `TabletController` |  |  |
| `TabletGui/Device/Screen/Pages/Page_Journal/Reader/Title` | TextLabel | lu par `TabletController` |  |  |
| `TabletGui/Device/Screen/Pages/Page_Journal/Reader/Body` | TextLabel | lu par `TabletController` |  |  |
| `TabletGui/Device/Screen/Pages/Page_Evidence` | Frame | lu par `TabletController` |  |  |
| `TabletGui/Device/Screen/Pages/Page_Evidence/List` | ScrollingFrame | lu par `TabletController` |  |  |
| `TabletGui/Device/Screen/Pages/Page_Evidence/List/Template` | TextLabel | lu par `TabletController` |  |  |
| `TabletGui/Device/Screen/Pages/Page_Network` | Frame | lu par `TabletController` |  |  |
| `TabletGui/Device/Screen/Pages/Page_Network/Bars` | Frame | lu par `TabletController` |  | barres de réseau : Fill.Size.X.Scale = niveau |
| `TabletGui/Device/Screen/Pages/Page_Network/Bars/Fill` | Frame | lu par `TabletController` |  |  |
| `TabletGui/Device/Screen/Pages/Page_Network/Message` | TextLabel | lu par `TabletController` | Aucun réseau |  |
| `TabletGui/Device/Screen/Pages/Page_Network/Send` | TextButton | lu par `TabletController` | Envoyer |  |
| `TabletGui/Device/BatteryText` | TextLabel | lu par `TabletController` |  |  |
| `TabletGui/Device/Close` | TextButton | lu par `TabletController` | Fermer |  |

### DocumentGui — StarterGui (Partie), section 15.4

Lu par `DocumentController`.

| Chemin | Classe | Statut | Texte de départ | Remarque |
| --- | --- | --- | --- | --- |
| `DocumentGui` | ScreenGui | lu par `DocumentController` |  |  |
| `DocumentGui/Paper` | Frame | lu par `DocumentController` |  |  |
| `DocumentGui/Paper/Title` | TextLabel | lu par `DocumentController` |  |  |
| `DocumentGui/Paper/Picture` | ImageLabel | lu par `DocumentController` |  |  |
| `DocumentGui/Paper/Body` | TextLabel | lu par `DocumentController` |  |  |
| `DocumentGui/Paper/Close` | TextButton | lu par `DocumentController` | Fermer |  |
| `DocumentGui/Tape` | Frame | lu par `DocumentController` |  |  |
| `DocumentGui/Tape/Label` | TextLabel | lu par `DocumentController` |  |  |
| `DocumentGui/Tape/Play` | TextButton | lu par `DocumentController` | Lire |  |
| `DocumentGui/Tape/Progress` | Frame | lu par `DocumentController` |  |  |
| `DocumentGui/Tape/Progress/Fill` | Frame | lu par `DocumentController` |  |  |

### DownedGui — StarterGui (Partie), section 15.4

Lu par `DownedController`.

| Chemin | Classe | Statut | Texte de départ | Remarque |
| --- | --- | --- | --- | --- |
| `DownedGui` | ScreenGui | lu par `DownedController` |  |  |
| `DownedGui/Countdown` | TextLabel | lu par `DownedController` |  |  |
| `DownedGui/HelpHint` | TextLabel | lu par `DownedController` | Appelle à l'aide : un coéquipier peut te relever. |  |
| `DownedGui/Bleed` | Frame | lu par `DownedController` |  |  |
| `DownedGui/Bleed/Fill` | Frame | lu par `DownedController` |  |  |

### SpectatorGui — StarterGui (Partie), section 15.4

Lu par `SpectatorController`.

| Chemin | Classe | Statut | Texte de départ | Remarque |
| --- | --- | --- | --- | --- |
| `SpectatorGui` | ScreenGui | lu par `SpectatorController` |  |  |
| `SpectatorGui/Watching` | TextLabel | lu par `SpectatorController` |  |  |
| `SpectatorGui/Prev` | TextButton | lu par `SpectatorController` | Précédent |  |
| `SpectatorGui/Next` | TextButton | lu par `SpectatorController` | Suivant |  |
| `SpectatorGui/Note` | TextLabel | lu par `SpectatorController` | Tu es mort. Tu peux encore suivre ton groupe. |  |

### RadioGui — StarterGui (Partie), section 15.4

Lu par `RadioController`.

| Chemin | Classe | Statut | Texte de départ | Remarque |
| --- | --- | --- | --- | --- |
| `RadioGui` | ScreenGui | lu par `RadioController` |  |  |
| `RadioGui/Channel` | TextLabel | lu par `RadioController` |  |  |
| `RadioGui/Talking` | Frame | lu par `RadioController` |  |  |
| `RadioGui/Static` | Frame | lu par `RadioController` |  |  |

### MobileControlsGui — StarterGui (Partie), section 15.4

Lu par `InputController`.

| Chemin | Classe | Statut | Texte de départ | Remarque |
| --- | --- | --- | --- | --- |
| `MobileControlsGui` | ScreenGui | lu par `InputController` |  |  |
| `MobileControlsGui/Tablet` | TextButton | lu par `InputController` | Tablette |  |
| `MobileControlsGui/Ping` | TextButton | lu par `InputController` | Signaler |  |
| `MobileControlsGui/Light` | TextButton | lu par `InputController` | Lampe |  |
| `MobileControlsGui/Interact` | TextButton | lu par `InputController` | Utiliser |  |
| `MobileControlsGui/Reload` | TextButton | lu par `InputController` | Recharger |  |
| `MobileControlsGui/Aim` | TextButton | lu par `InputController` | Viser |  |
| `MobileControlsGui/Fire` | TextButton | lu par `InputController` | Tirer |  |
| `MobileControlsGui/Sprint` | TextButton | lu par `InputController` | Courir |  |
| `MobileControlsGui/Crouch` | TextButton | lu par `InputController` | Accroupi |  |
| `MobileControlsGui/Prone` | TextButton | lu par `InputController` | Couché |  |
| `MobileControlsGui/LeanL` | TextButton | lu par `InputController` | ← Pencher |  |
| `MobileControlsGui/LeanR` | TextButton | lu par `InputController` | Pencher → |  |

### CinematicGui — StarterGui (les deux places), section 15.5

Lu par `CinematicController`.

| Chemin | Classe | Statut | Texte de départ | Remarque |
| --- | --- | --- | --- | --- |
| `CinematicGui` | ScreenGui | lu par `CinematicController` |  |  |
| `CinematicGui/BarTop` | Frame | lu par `CinematicController` |  |  |
| `CinematicGui/BarBottom` | Frame | lu par `CinematicController` |  |  |
| `CinematicGui/Subtitle` | TextLabel | lu par `CinematicController` |  |  |
| `CinematicGui/Skip` | TextButton | lu par `CinematicController` | Passer |  |
| `CinematicGui/Skip/Votes` | TextLabel | lu par `CinematicController` |  |  |

### SettingsGui — StarterGui (les deux places), section 15.5

Lu par `SettingsController`.

| Chemin | Classe | Statut | Texte de départ | Remarque |
| --- | --- | --- | --- | --- |
| `SettingsGui` | ScreenGui | lu par `SettingsController` |  |  |
| `SettingsGui/Window` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Window/Tabs` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Window/Tabs/Graphics` | TextButton | lu par `SettingsController` | Graphismes |  |
| `SettingsGui/Window/Tabs/Controls` | TextButton | lu par `SettingsController` | Contrôles |  |
| `SettingsGui/Window/Tabs/Audio` | TextButton | lu par `SettingsController` | Audio |  |
| `SettingsGui/Window/Tabs/Accessibility` | TextButton | lu par `SettingsController` | Accessibilité |  |
| `SettingsGui/Window/Pages` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Window/Pages/Graphics` | ScrollingFrame | lu par `SettingsController` |  |  |
| `SettingsGui/Window/Pages/Graphics/Preset` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Window/Pages/Graphics/Preset/Label` | TextLabel | décoratif | Préréglage |  |
| `SettingsGui/Window/Pages/Graphics/Preset/Options` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Window/Pages/Graphics/Preset/Options/Opt_Low` | TextButton | lu par `SettingsController` | Bas |  |
| `SettingsGui/Window/Pages/Graphics/Preset/Options/Opt_Medium` | TextButton | lu par `SettingsController` | Moyen |  |
| `SettingsGui/Window/Pages/Graphics/Preset/Options/Opt_High` | TextButton | lu par `SettingsController` | Élevé |  |
| `SettingsGui/Window/Pages/Graphics/Preset/Options/Opt_Ultra` | TextButton | lu par `SettingsController` | Ultra |  |
| `SettingsGui/Window/Pages/Graphics/Brightness` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Window/Pages/Graphics/Brightness/Label` | TextLabel | décoratif | Luminosité (gamma) |  |
| `SettingsGui/Window/Pages/Graphics/Brightness/Slider` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Window/Pages/Graphics/Brightness/Slider/Track` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Window/Pages/Graphics/Brightness/Slider/Track/Fill` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Window/Pages/Graphics/Brightness/Value` | TextLabel | lu par `SettingsController` |  |  |
| `SettingsGui/Window/Pages/Graphics/Calibration` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Window/Pages/Graphics/Calibration/Symbol` | Frame | lu par `SettingsController` |  | symbole de calibrage (17.2) |
| `SettingsGui/Window/Pages/Graphics/Calibration/Label` | TextLabel | décoratif | le symbole doit être à peine visible |  |
| `SettingsGui/Window/Pages/Graphics/ViewDistance` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Window/Pages/Graphics/ViewDistance/Label` | TextLabel | décoratif | Distance d'affichage du décor |  |
| `SettingsGui/Window/Pages/Graphics/ViewDistance/Options` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Window/Pages/Graphics/ViewDistance/Options/Opt_25` | TextButton | lu par `SettingsController` | 25 % |  |
| `SettingsGui/Window/Pages/Graphics/ViewDistance/Options/Opt_50` | TextButton | lu par `SettingsController` | 50 % |  |
| `SettingsGui/Window/Pages/Graphics/ViewDistance/Options/Opt_75` | TextButton | lu par `SettingsController` | 75 % |  |
| `SettingsGui/Window/Pages/Graphics/ViewDistance/Options/Opt_100` | TextButton | lu par `SettingsController` | 100 % |  |
| `SettingsGui/Window/Pages/Graphics/VegetationDensity` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Window/Pages/Graphics/VegetationDensity/Label` | TextLabel | décoratif | Densité de végétation |  |
| `SettingsGui/Window/Pages/Graphics/VegetationDensity/Options` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Window/Pages/Graphics/VegetationDensity/Options/Opt_25` | TextButton | lu par `SettingsController` | 25 % |  |
| `SettingsGui/Window/Pages/Graphics/VegetationDensity/Options/Opt_50` | TextButton | lu par `SettingsController` | 50 % |  |
| `SettingsGui/Window/Pages/Graphics/VegetationDensity/Options/Opt_75` | TextButton | lu par `SettingsController` | 75 % |  |
| `SettingsGui/Window/Pages/Graphics/VegetationDensity/Options/Opt_100` | TextButton | lu par `SettingsController` | 100 % |  |
| `SettingsGui/Window/Pages/Graphics/TreeWind` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Window/Pages/Graphics/TreeWind/Label` | TextLabel | décoratif | Vent dans les arbres |  |
| `SettingsGui/Window/Pages/Graphics/TreeWind/Options` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Window/Pages/Graphics/TreeWind/Options/Opt_Yes` | TextButton | lu par `SettingsController` | Oui |  |
| `SettingsGui/Window/Pages/Graphics/TreeWind/Options/Opt_No` | TextButton | lu par `SettingsController` | Non |  |
| `SettingsGui/Window/Pages/Graphics/LampShadows` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Window/Pages/Graphics/LampShadows/Label` | TextLabel | décoratif | Ombres des lampes |  |
| `SettingsGui/Window/Pages/Graphics/LampShadows/Options` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Window/Pages/Graphics/LampShadows/Options/Opt_Yes` | TextButton | lu par `SettingsController` | Oui |  |
| `SettingsGui/Window/Pages/Graphics/LampShadows/Options/Opt_No` | TextButton | lu par `SettingsController` | Non |  |
| `SettingsGui/Window/Pages/Graphics/DepthOfField` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Window/Pages/Graphics/DepthOfField/Label` | TextLabel | décoratif | Profondeur de champ, flou lumineux |  |
| `SettingsGui/Window/Pages/Graphics/DepthOfField/Options` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Window/Pages/Graphics/DepthOfField/Options/Opt_Yes` | TextButton | lu par `SettingsController` | Oui |  |
| `SettingsGui/Window/Pages/Graphics/DepthOfField/Options/Opt_No` | TextButton | lu par `SettingsController` | Non |  |
| `SettingsGui/Window/Pages/Graphics/Particles` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Window/Pages/Graphics/Particles/Label` | TextLabel | décoratif | Densité des particules (pluie, neige, cendre) |  |
| `SettingsGui/Window/Pages/Graphics/Particles/Options` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Window/Pages/Graphics/Particles/Options/Opt_Low` | TextButton | lu par `SettingsController` | Faible |  |
| `SettingsGui/Window/Pages/Graphics/Particles/Options/Opt_Normal` | TextButton | lu par `SettingsController` | Normale |  |
| `SettingsGui/Window/Pages/Graphics/FieldOfView` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Window/Pages/Graphics/FieldOfView/Label` | TextLabel | décoratif | Champ de vision |  |
| `SettingsGui/Window/Pages/Graphics/FieldOfView/Slider` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Window/Pages/Graphics/FieldOfView/Slider/Track` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Window/Pages/Graphics/FieldOfView/Slider/Track/Fill` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Window/Pages/Graphics/FieldOfView/Value` | TextLabel | lu par `SettingsController` |  |  |
| `SettingsGui/Window/Pages/Controls` | ScrollingFrame | lu par `SettingsController` |  |  |
| `SettingsGui/Window/Pages/Controls/Sensitivity` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Window/Pages/Controls/Sensitivity/Label` | TextLabel | décoratif | Sensibilité |  |
| `SettingsGui/Window/Pages/Controls/Sensitivity/Slider` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Window/Pages/Controls/Sensitivity/Slider/Track` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Window/Pages/Controls/Sensitivity/Slider/Track/Fill` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Window/Pages/Controls/Sensitivity/Value` | TextLabel | lu par `SettingsController` |  |  |
| `SettingsGui/Window/Pages/Controls/InvertY` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Window/Pages/Controls/InvertY/Label` | TextLabel | décoratif | Inverser l'axe vertical |  |
| `SettingsGui/Window/Pages/Controls/InvertY/Options` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Window/Pages/Controls/InvertY/Options/Opt_Yes` | TextButton | lu par `SettingsController` | Oui |  |
| `SettingsGui/Window/Pages/Controls/InvertY/Options/Opt_No` | TextButton | lu par `SettingsController` | Non |  |
| `SettingsGui/Window/Pages/Controls/TouchButtonSize` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Window/Pages/Controls/TouchButtonSize/Label` | TextLabel | décoratif | Taille des boutons tactiles |  |
| `SettingsGui/Window/Pages/Controls/TouchButtonSize/Slider` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Window/Pages/Controls/TouchButtonSize/Slider/Track` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Window/Pages/Controls/TouchButtonSize/Slider/Track/Fill` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Window/Pages/Controls/TouchButtonSize/Value` | TextLabel | lu par `SettingsController` |  |  |
| `SettingsGui/Window/Pages/Audio` | ScrollingFrame | lu par `SettingsController` |  |  |
| `SettingsGui/Window/Pages/Audio/Master` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Window/Pages/Audio/Master/Label` | TextLabel | décoratif | Général |  |
| `SettingsGui/Window/Pages/Audio/Master/Slider` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Window/Pages/Audio/Master/Slider/Track` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Window/Pages/Audio/Master/Slider/Track/Fill` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Window/Pages/Audio/Master/Value` | TextLabel | lu par `SettingsController` |  |  |
| `SettingsGui/Window/Pages/Audio/Ambience` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Window/Pages/Audio/Ambience/Label` | TextLabel | décoratif | Ambiance |  |
| `SettingsGui/Window/Pages/Audio/Ambience/Slider` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Window/Pages/Audio/Ambience/Slider/Track` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Window/Pages/Audio/Ambience/Slider/Track/Fill` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Window/Pages/Audio/Ambience/Value` | TextLabel | lu par `SettingsController` |  |  |
| `SettingsGui/Window/Pages/Audio/Voice` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Window/Pages/Audio/Voice/Label` | TextLabel | décoratif | Voix |  |
| `SettingsGui/Window/Pages/Audio/Voice/Slider` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Window/Pages/Audio/Voice/Slider/Track` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Window/Pages/Audio/Voice/Slider/Track/Fill` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Window/Pages/Audio/Voice/Value` | TextLabel | lu par `SettingsController` |  |  |
| `SettingsGui/Window/Pages/Audio/Music` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Window/Pages/Audio/Music/Label` | TextLabel | décoratif | Musique |  |
| `SettingsGui/Window/Pages/Audio/Music/Slider` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Window/Pages/Audio/Music/Slider/Track` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Window/Pages/Audio/Music/Slider/Track/Fill` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Window/Pages/Audio/Music/Value` | TextLabel | lu par `SettingsController` |  |  |
| `SettingsGui/Window/Pages/Audio/Effects` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Window/Pages/Audio/Effects/Label` | TextLabel | décoratif | Effets |  |
| `SettingsGui/Window/Pages/Audio/Effects/Slider` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Window/Pages/Audio/Effects/Slider/Track` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Window/Pages/Audio/Effects/Slider/Track/Fill` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Window/Pages/Audio/Effects/Value` | TextLabel | lu par `SettingsController` |  |  |
| `SettingsGui/Window/Pages/Accessibility` | ScrollingFrame | lu par `SettingsController` |  |  |
| `SettingsGui/Window/Pages/Accessibility/Subtitles` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Window/Pages/Accessibility/Subtitles/Label` | TextLabel | décoratif | Sous-titres |  |
| `SettingsGui/Window/Pages/Accessibility/Subtitles/Options` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Window/Pages/Accessibility/Subtitles/Options/Opt_Yes` | TextButton | lu par `SettingsController` | Oui |  |
| `SettingsGui/Window/Pages/Accessibility/Subtitles/Options/Opt_No` | TextButton | lu par `SettingsController` | Non |  |
| `SettingsGui/Window/Pages/Accessibility/SubtitleSize` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Window/Pages/Accessibility/SubtitleSize/Label` | TextLabel | décoratif | Taille |  |
| `SettingsGui/Window/Pages/Accessibility/SubtitleSize/Options` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Window/Pages/Accessibility/SubtitleSize/Options/Opt_Small` | TextButton | lu par `SettingsController` | Petite |  |
| `SettingsGui/Window/Pages/Accessibility/SubtitleSize/Options/Opt_Medium` | TextButton | lu par `SettingsController` | Moyenne |  |
| `SettingsGui/Window/Pages/Accessibility/SubtitleSize/Options/Opt_Large` | TextButton | lu par `SettingsController` | Grande |  |
| `SettingsGui/Window/Pages/Accessibility/ReduceMotion` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Window/Pages/Accessibility/ReduceMotion/Label` | TextLabel | décoratif | Réduire les mouvements (balancement de caméra) |  |
| `SettingsGui/Window/Pages/Accessibility/ReduceMotion/Options` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Window/Pages/Accessibility/ReduceMotion/Options/Opt_Yes` | TextButton | lu par `SettingsController` | Oui |  |
| `SettingsGui/Window/Pages/Accessibility/ReduceMotion/Options/Opt_No` | TextButton | lu par `SettingsController` | Non |  |
| `SettingsGui/Window/Pages/Accessibility/ReducedGore` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Window/Pages/Accessibility/ReducedGore/Label` | TextLabel | décoratif | Gore réduit |  |
| `SettingsGui/Window/Pages/Accessibility/ReducedGore/Options` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Window/Pages/Accessibility/ReducedGore/Options/Opt_Yes` | TextButton | lu par `SettingsController` | Oui |  |
| `SettingsGui/Window/Pages/Accessibility/ReducedGore/Options/Opt_No` | TextButton | lu par `SettingsController` | Non |  |
| `SettingsGui/Window/Pages/Accessibility/Language` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Window/Pages/Accessibility/Language/Label` | TextLabel | décoratif | Langue |  |
| `SettingsGui/Window/Pages/Accessibility/Language/Options` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Window/Pages/Accessibility/Language/Options/Opt_French` | TextButton | lu par `SettingsController` | Français |  |
| `SettingsGui/Window/Pages/Accessibility/Language/Options/Opt_English` | TextButton | lu par `SettingsController` | Anglais |  |
| `SettingsGui/Window/Apply` | TextButton | lu par `SettingsController` | Appliquer |  |
| `SettingsGui/Window/Reset` | TextButton | lu par `SettingsController` | Réinitialiser |  |
| `SettingsGui/Window/Close` | TextButton | lu par `SettingsController` | Fermer |  |

### NotificationGui — StarterGui (les deux places), section 15.5

Lu par `NotificationController`.

| Chemin | Classe | Statut | Texte de départ | Remarque |
| --- | --- | --- | --- | --- |
| `NotificationGui` | ScreenGui | lu par `NotificationController` |  |  |
| `NotificationGui/Stack` | Frame | lu par `NotificationController` |  |  |
| `NotificationGui/Stack/Template` | Frame | lu par `NotificationController` |  |  |
| `NotificationGui/Stack/Template/Text` | TextLabel | lu par `NotificationController` |  |  |

### PingMarker — ReplicatedStorage/UITemplates (les deux places), section 15.5

| Chemin | Classe | Statut | Texte de départ | Remarque |
| --- | --- | --- | --- | --- |
| `PingMarker` | BillboardGui | — |  | repère de ping (7.8) ; DÉFAUT : nom |
| `PingMarker/Dot` | Frame | — |  |  |

### NameTag — ReplicatedStorage/UITemplates (les deux places), section 15.5

| Chemin | Classe | Statut | Texte de départ | Remarque |
| --- | --- | --- | --- | --- |
| `NameTag` | BillboardGui | — |  | nom au-dessus de la tête ; DÉFAUT : nom |
| `NameTag/PlayerName` | TextLabel | — |  |  |
