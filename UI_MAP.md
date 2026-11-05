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
| `PartyGui/Layout_Desktop/PartyFrame/Header/Title` | DÉFAUT appliqué : « Groupe » |
| `PartyGui/Layout_Touch/PartyFrame/Header/Title` | DÉFAUT appliqué : « Groupe » |
| `SettingsGui/Layout_Desktop/Window/Pages/Accessibility/SubtitleSize/Options/Opt_Small` | DÉFAUT appliqué : « Petite » |
| `SettingsGui/Layout_Desktop/Window/Pages/Accessibility/SubtitleSize/Options/Opt_Large` | DÉFAUT appliqué : « Grande » |
| `SettingsGui/Layout_Touch/Window/Pages/Accessibility/SubtitleSize/Options/Opt_Small` | DÉFAUT appliqué : « Petite » |
| `SettingsGui/Layout_Touch/Window/Pages/Accessibility/SubtitleSize/Options/Opt_Large` | DÉFAUT appliqué : « Grande » |

## Éléments

### DialogueGui — StarterGui (Lobby), section 15.3

Lu par `DialogueController`.

| Chemin | Classe | Statut | Texte de départ | Remarque |
| --- | --- | --- | --- | --- |
| `DialogueGui` | ScreenGui | lu par `DialogueController` |  |  |
| `DialogueGui/Layout_Desktop` | Frame | lu par `DialogueController` |  | 15.7 : disposition choisie par Util.prepareGui (UserInputService.TouchEnabled) |
| `DialogueGui/Layout_Desktop/Veil` | Frame | lu par `DialogueController` |  | voile 60 % : visible avec Dialogue (attribut veilFor) |
| `DialogueGui/Layout_Desktop/Dialogue` | Frame | lu par `DialogueController` |  |  |
| `DialogueGui/Layout_Desktop/Dialogue/SpeakerName` | TextLabel | lu par `DialogueController` |  |  |
| `DialogueGui/Layout_Desktop/Dialogue/Line` | TextLabel | lu par `DialogueController` |  |  |
| `DialogueGui/Layout_Desktop/Dialogue/Choices` | Frame | lu par `DialogueController` |  |  |
| `DialogueGui/Layout_Desktop/Dialogue/Choices/Choice_1` | TextButton | lu par `DialogueController` |  |  |
| `DialogueGui/Layout_Desktop/Dialogue/Choices/Choice_2` | TextButton | lu par `DialogueController` |  |  |
| `DialogueGui/Layout_Desktop/Dialogue/Choices/Choice_3` | TextButton | lu par `DialogueController` |  |  |
| `DialogueGui/Layout_Touch` | Frame | lu par `DialogueController` |  | 15.7 : disposition choisie par Util.prepareGui (UserInputService.TouchEnabled) |
| `DialogueGui/Layout_Touch/Veil` | Frame | lu par `DialogueController` |  | voile 60 % : visible avec Dialogue (attribut veilFor) |
| `DialogueGui/Layout_Touch/Dialogue` | Frame | lu par `DialogueController` |  |  |
| `DialogueGui/Layout_Touch/Dialogue/SpeakerName` | TextLabel | lu par `DialogueController` |  |  |
| `DialogueGui/Layout_Touch/Dialogue/Line` | TextLabel | lu par `DialogueController` |  |  |
| `DialogueGui/Layout_Touch/Dialogue/Choices` | Frame | lu par `DialogueController` |  |  |
| `DialogueGui/Layout_Touch/Dialogue/Choices/Choice_1` | TextButton | lu par `DialogueController` |  |  |
| `DialogueGui/Layout_Touch/Dialogue/Choices/Choice_2` | TextButton | lu par `DialogueController` |  |  |
| `DialogueGui/Layout_Touch/Dialogue/Choices/Choice_3` | TextButton | lu par `DialogueController` |  |  |

### MuseumPanelGui — StarterGui (Lobby), section 15.3

Lu par `MuseumController`.

| Chemin | Classe | Statut | Texte de départ | Remarque |
| --- | --- | --- | --- | --- |
| `MuseumPanelGui` | ScreenGui | lu par `MuseumController` |  |  |
| `MuseumPanelGui/Layout_Desktop` | Frame | lu par `MuseumController` |  | 15.7 : disposition choisie par Util.prepareGui (UserInputService.TouchEnabled) |
| `MuseumPanelGui/Layout_Desktop/Veil` | Frame | lu par `MuseumController` |  | voile 60 % : visible avec Panel (attribut veilFor) |
| `MuseumPanelGui/Layout_Desktop/Panel` | Frame | lu par `MuseumController` |  |  |
| `MuseumPanelGui/Layout_Desktop/Panel/Title` | TextLabel | lu par `MuseumController` |  |  |
| `MuseumPanelGui/Layout_Desktop/Panel/Close` | TextButton | lu par `MuseumController` | Fermer |  |
| `MuseumPanelGui/Layout_Desktop/Panel/Illustration` | ImageLabel | lu par `MuseumController` |  |  |
| `MuseumPanelGui/Layout_Desktop/Panel/Body` | TextLabel | lu par `MuseumController` |  |  |
| `MuseumPanelGui/Layout_Desktop/Panel/Source` | TextLabel | lu par `MuseumController` |  |  |
| `MuseumPanelGui/Layout_Touch` | Frame | lu par `MuseumController` |  | 15.7 : disposition choisie par Util.prepareGui (UserInputService.TouchEnabled) |
| `MuseumPanelGui/Layout_Touch/Veil` | Frame | lu par `MuseumController` |  | voile 60 % : visible avec Panel (attribut veilFor) |
| `MuseumPanelGui/Layout_Touch/Panel` | Frame | lu par `MuseumController` |  |  |
| `MuseumPanelGui/Layout_Touch/Panel/Title` | TextLabel | lu par `MuseumController` |  |  |
| `MuseumPanelGui/Layout_Touch/Panel/Close` | TextButton | lu par `MuseumController` | Fermer |  |
| `MuseumPanelGui/Layout_Touch/Panel/Illustration` | ImageLabel | lu par `MuseumController` |  |  |
| `MuseumPanelGui/Layout_Touch/Panel/Body` | TextLabel | lu par `MuseumController` |  |  |
| `MuseumPanelGui/Layout_Touch/Panel/Source` | TextLabel | lu par `MuseumController` |  |  |

### PartyGui — StarterGui (Lobby), section 15.3

Lu par `PartyController`.

| Chemin | Classe | Statut | Texte de départ | Remarque |
| --- | --- | --- | --- | --- |
| `PartyGui` | ScreenGui | lu par `PartyController` |  |  |
| `PartyGui/Layout_Desktop` | Frame | lu par `PartyController` |  | 15.7 : disposition choisie par Util.prepareGui (UserInputService.TouchEnabled) |
| `PartyGui/Layout_Desktop/PartyFrame` | Frame | lu par `PartyController` |  |  |
| `PartyGui/Layout_Desktop/PartyFrame/Header` | Frame | lu par `PartyController` |  |  |
| `PartyGui/Layout_Desktop/PartyFrame/Header/Title` | TextLabel | lu par `PartyController` | Groupe |  |
| `PartyGui/Layout_Desktop/PartyFrame/Header/Code` | TextLabel | lu par `PartyController` |  |  |
| `PartyGui/Layout_Desktop/PartyFrame/MemberList` | ScrollingFrame | lu par `PartyController` |  |  |
| `PartyGui/Layout_Desktop/PartyFrame/MemberList/Template` | Frame | lu par `PartyController` |  |  |
| `PartyGui/Layout_Desktop/PartyFrame/MemberList/Template/PlayerName` | TextLabel | lu par `PartyController` |  |  |
| `PartyGui/Layout_Desktop/PartyFrame/MemberList/Template/RoleName` | TextLabel | lu par `PartyController` |  |  |
| `PartyGui/Layout_Desktop/PartyFrame/MemberList/Template/ReadyIcon` | Frame | lu par `PartyController` |  |  |
| `PartyGui/Layout_Desktop/PartyFrame/Buttons` | Frame | lu par `PartyController` |  |  |
| `PartyGui/Layout_Desktop/PartyFrame/Buttons/CreatePublic` | TextButton | lu par `PartyController` | Groupe public |  |
| `PartyGui/Layout_Desktop/PartyFrame/Buttons/CreatePrivate` | TextButton | lu par `PartyController` | Groupe privé |  |
| `PartyGui/Layout_Desktop/PartyFrame/Buttons/JoinCode` | TextButton | lu par `PartyController` | Rejoindre avec un code |  |
| `PartyGui/Layout_Desktop/PartyFrame/Buttons/QuickJoin` | TextButton | lu par `PartyController` | Partie rapide |  |
| `PartyGui/Layout_Desktop/PartyFrame/Buttons/Ready` | TextButton | lu par `PartyController` | Prêt |  |
| `PartyGui/Layout_Desktop/PartyFrame/Buttons/Leave` | TextButton | lu par `PartyController` | Quitter le groupe |  |
| `PartyGui/Layout_Desktop/PartyFrame/CodeInput` | TextBox | lu par `PartyController` |  |  |
| `PartyGui/Layout_Touch` | Frame | lu par `PartyController` |  | 15.7 : disposition choisie par Util.prepareGui (UserInputService.TouchEnabled) |
| `PartyGui/Layout_Touch/PartyFrame` | Frame | lu par `PartyController` |  |  |
| `PartyGui/Layout_Touch/PartyFrame/Header` | Frame | lu par `PartyController` |  |  |
| `PartyGui/Layout_Touch/PartyFrame/Header/Title` | TextLabel | lu par `PartyController` | Groupe |  |
| `PartyGui/Layout_Touch/PartyFrame/Header/Code` | TextLabel | lu par `PartyController` |  |  |
| `PartyGui/Layout_Touch/PartyFrame/MemberList` | ScrollingFrame | lu par `PartyController` |  |  |
| `PartyGui/Layout_Touch/PartyFrame/MemberList/Template` | Frame | lu par `PartyController` |  |  |
| `PartyGui/Layout_Touch/PartyFrame/MemberList/Template/PlayerName` | TextLabel | lu par `PartyController` |  |  |
| `PartyGui/Layout_Touch/PartyFrame/MemberList/Template/RoleName` | TextLabel | lu par `PartyController` |  |  |
| `PartyGui/Layout_Touch/PartyFrame/MemberList/Template/ReadyIcon` | Frame | lu par `PartyController` |  |  |
| `PartyGui/Layout_Touch/PartyFrame/Buttons` | Frame | lu par `PartyController` |  |  |
| `PartyGui/Layout_Touch/PartyFrame/Buttons/CreatePublic` | TextButton | lu par `PartyController` | Groupe public |  |
| `PartyGui/Layout_Touch/PartyFrame/Buttons/CreatePrivate` | TextButton | lu par `PartyController` | Groupe privé |  |
| `PartyGui/Layout_Touch/PartyFrame/Buttons/JoinCode` | TextButton | lu par `PartyController` | Rejoindre avec un code |  |
| `PartyGui/Layout_Touch/PartyFrame/Buttons/QuickJoin` | TextButton | lu par `PartyController` | Partie rapide |  |
| `PartyGui/Layout_Touch/PartyFrame/Buttons/Ready` | TextButton | lu par `PartyController` | Prêt |  |
| `PartyGui/Layout_Touch/PartyFrame/Buttons/Leave` | TextButton | lu par `PartyController` | Quitter le groupe |  |
| `PartyGui/Layout_Touch/PartyFrame/CodeInput` | TextBox | lu par `PartyController` |  |  |

### RoleSelectGui — StarterGui (Lobby), section 15.3

Lu par `RoleController`.

| Chemin | Classe | Statut | Texte de départ | Remarque |
| --- | --- | --- | --- | --- |
| `RoleSelectGui` | ScreenGui | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Desktop` | Frame | lu par `RoleController` |  | 15.7 : disposition choisie par Util.prepareGui (UserInputService.TouchEnabled) |
| `RoleSelectGui/Layout_Desktop/Veil` | Frame | lu par `RoleController` |  | voile 60 % : visible avec Grid, Confirm (attribut veilFor) |
| `RoleSelectGui/Layout_Desktop/Grid` | ScrollingFrame | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Leader` | TextButton | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Leader/Portrait` | ViewportFrame | lu par `RoleController` |  | 13.5 : affiche le modèle Skin_A du rôle |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Leader/CharacterName` | TextLabel | lu par `RoleController` | Caleb Marsh |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Leader/RoleTitle` | TextLabel | lu par `RoleController` | Meneur |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Leader/Ability` | TextLabel | lu par `RoleController` | Voit ses coéquipiers en contour à travers le décor ; donne un ordre qui réduit la peur |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Leader/Weakness` | TextLabel | lu par `RoleController` | Aucune |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Leader/TakenOverlay` | Frame | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Leader/TakenOverlay/TakenBy` | TextLabel | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Medic` | TextButton | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Medic/Portrait` | ViewportFrame | lu par `RoleController` |  | 13.5 : affiche le modèle Skin_A du rôle |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Medic/CharacterName` | TextLabel | lu par `RoleController` | Priya Natarajan |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Medic/RoleTitle` | TextLabel | lu par `RoleController` | Médecin |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Medic/Ability` | TextLabel | lu par `RoleController` | Soigne vite, arrête les hémorragies graves |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Medic/Weakness` | TextLabel | lu par `RoleController` | Course à 18 |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Medic/TakenOverlay` | Frame | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Medic/TakenOverlay/TakenBy` | TextLabel | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Tracker` | TextButton | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Tracker/Portrait` | ViewportFrame | lu par `RoleController` |  | 13.5 : affiche le modèle Skin_A du rôle |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Tracker/CharacterName` | TextLabel | lu par `RoleController` | Wyatt Dunn |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Tracker/RoleTitle` | TextLabel | lu par `RoleController` | Pisteur |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Tracker/Ability` | TextLabel | lu par `RoleController` | Voit les empreintes fraîches en surbrillance ; devine la direction de la créature |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Tracker/Weakness` | TextLabel | lu par `RoleController` | Ses tirs comptent double pour la rancune |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Tracker/TakenOverlay` | Frame | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Tracker/TakenOverlay/TakenBy` | TextLabel | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Cameraman` | TextButton | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Cameraman/Portrait` | ViewportFrame | lu par `RoleController` |  | 13.5 : affiche le modèle Skin_A du rôle |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Cameraman/CharacterName` | TextLabel | lu par `RoleController` | Theo Lindqvist |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Cameraman/RoleTitle` | TextLabel | lu par `RoleController` | Caméraman |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Cameraman/Ability` | TextLabel | lu par `RoleController` | Seul à produire des preuves de classe A |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Cameraman/Weakness` | TextLabel | lu par `RoleController` | Batterie de 6 min |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Cameraman/TakenOverlay` | Frame | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Cameraman/TakenOverlay/TakenBy` | TextLabel | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Mechanic` | TextButton | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Mechanic/Portrait` | ViewportFrame | lu par `RoleController` |  | 13.5 : affiche le modèle Skin_A du rôle |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Mechanic/CharacterName` | TextLabel | lu par `RoleController` | Rosa Delgado |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Mechanic/RoleTitle` | TextLabel | lu par `RoleController` | Mécanicienne |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Mechanic/Ability` | TextLabel | lu par `RoleController` | Répare deux fois plus vite |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Mechanic/Weakness` | TextLabel | lu par `RoleController` | Inventaire : 3 emplacements rapides au lieu de 4 |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Mechanic/TakenOverlay` | Frame | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Mechanic/TakenOverlay/TakenBy` | TextLabel | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Descendant` | TextButton | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Descendant/Portrait` | ViewportFrame | lu par `RoleController` |  | 13.5 : affiche le modèle Skin_A du rôle |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Descendant/CharacterName` | TextLabel | lu par `RoleController` | Nora Halvorsen |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Descendant/RoleTitle` | TextLabel | lu par `RoleController` | Descendante |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Descendant/Ability` | TextLabel | lu par `RoleController` | Lit le carnet familial, voit les indices cachés |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Descendant/Weakness` | TextLabel | lu par `RoleController` | Peur ×1,25 |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Descendant/TakenOverlay` | Frame | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Descendant/TakenOverlay/TakenBy` | TextLabel | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Geologist` | TextButton | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Geologist/Portrait` | ViewportFrame | lu par `RoleController` |  | 13.5 : affiche le modèle Skin_A du rôle |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Geologist/CharacterName` | TextLabel | lu par `RoleController` | Malik Okafor |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Geologist/RoleTitle` | TextLabel | lu par `RoleController` | Géologue |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Geologist/Ability` | TextLabel | lu par `RoleController` | Lit la carte des tunnels, se repère sous terre |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Geologist/Weakness` | TextLabel | lu par `RoleController` | Endurance 80 |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Geologist/TakenOverlay` | Frame | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Geologist/TakenOverlay/TakenBy` | TextLabel | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Athlete` | TextButton | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Athlete/Portrait` | ViewportFrame | lu par `RoleController` |  | 13.5 : affiche le modèle Skin_A du rôle |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Athlete/CharacterName` | TextLabel | lu par `RoleController` | Jake Kowalski |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Athlete/RoleTitle` | TextLabel | lu par `RoleController` | Sportif |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Athlete/Ability` | TextLabel | lu par `RoleController` | Porte un blessé en courant, barricade vite |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Athlete/Weakness` | TextLabel | lu par `RoleController` | Respiration : bruit de course 75 |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Athlete/TakenOverlay` | Frame | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Athlete/TakenOverlay/TakenBy` | TextLabel | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_RadioOperator` | TextButton | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_RadioOperator/Portrait` | ViewportFrame | lu par `RoleController` |  | 13.5 : affiche le modèle Skin_A du rôle |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_RadioOperator/CharacterName` | TextLabel | lu par `RoleController` | Mei Tanaka |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_RadioOperator/RoleTitle` | TextLabel | lu par `RoleController` | Opératrice radio |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_RadioOperator/Ability` | TextLabel | lu par `RoleController` | Écoute les fréquences, repère les voix imitées |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_RadioOperator/Weakness` | TextLabel | lu par `RoleController` | Aucune arme à feu possible |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_RadioOperator/TakenOverlay` | Frame | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_RadioOperator/TakenOverlay/TakenBy` | TextLabel | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Pyrotechnician` | TextButton | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Pyrotechnician/Portrait` | ViewportFrame | lu par `RoleController` |  | 13.5 : affiche le modèle Skin_A du rôle |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Pyrotechnician/CharacterName` | TextLabel | lu par `RoleController` | Dylan Croft |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Pyrotechnician/RoleTitle` | TextLabel | lu par `RoleController` | Pyrotechnicien |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Pyrotechnician/Ability` | TextLabel | lu par `RoleController` | Fabrique une fusée ou un piège à bruit |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Pyrotechnician/Weakness` | TextLabel | lu par `RoleController` | Torse 80 PV |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Pyrotechnician/TakenOverlay` | Frame | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Desktop/Grid/RoleCard_Pyrotechnician/TakenOverlay/TakenBy` | TextLabel | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Desktop/Confirm` | TextButton | lu par `RoleController` | Confirmer |  |
| `RoleSelectGui/Layout_Touch` | Frame | lu par `RoleController` |  | 15.7 : disposition choisie par Util.prepareGui (UserInputService.TouchEnabled) |
| `RoleSelectGui/Layout_Touch/Veil` | Frame | lu par `RoleController` |  | voile 60 % : visible avec Grid, Detail, Confirm (attribut veilFor) |
| `RoleSelectGui/Layout_Touch/Grid` | ScrollingFrame | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Leader` | TextButton | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Leader/Portrait` | ViewportFrame | lu par `RoleController` |  | 13.5 : affiche le modèle Skin_A du rôle |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Leader/CharacterName` | TextLabel | lu par `RoleController` | Caleb Marsh |  |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Leader/RoleTitle` | TextLabel | lu par `RoleController` | Meneur |  |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Leader/Ability` | TextLabel | lu par `RoleController` | Voit ses coéquipiers en contour à travers le décor ; donne un ordre qui réduit la peur | téléphone : affiché dans Detail |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Leader/Weakness` | TextLabel | lu par `RoleController` | Aucune | téléphone : affiché dans Detail |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Leader/TakenOverlay` | Frame | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Leader/TakenOverlay/TakenBy` | TextLabel | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Medic` | TextButton | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Medic/Portrait` | ViewportFrame | lu par `RoleController` |  | 13.5 : affiche le modèle Skin_A du rôle |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Medic/CharacterName` | TextLabel | lu par `RoleController` | Priya Natarajan |  |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Medic/RoleTitle` | TextLabel | lu par `RoleController` | Médecin |  |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Medic/Ability` | TextLabel | lu par `RoleController` | Soigne vite, arrête les hémorragies graves | téléphone : affiché dans Detail |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Medic/Weakness` | TextLabel | lu par `RoleController` | Course à 18 | téléphone : affiché dans Detail |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Medic/TakenOverlay` | Frame | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Medic/TakenOverlay/TakenBy` | TextLabel | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Tracker` | TextButton | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Tracker/Portrait` | ViewportFrame | lu par `RoleController` |  | 13.5 : affiche le modèle Skin_A du rôle |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Tracker/CharacterName` | TextLabel | lu par `RoleController` | Wyatt Dunn |  |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Tracker/RoleTitle` | TextLabel | lu par `RoleController` | Pisteur |  |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Tracker/Ability` | TextLabel | lu par `RoleController` | Voit les empreintes fraîches en surbrillance ; devine la direction de la créature | téléphone : affiché dans Detail |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Tracker/Weakness` | TextLabel | lu par `RoleController` | Ses tirs comptent double pour la rancune | téléphone : affiché dans Detail |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Tracker/TakenOverlay` | Frame | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Tracker/TakenOverlay/TakenBy` | TextLabel | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Cameraman` | TextButton | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Cameraman/Portrait` | ViewportFrame | lu par `RoleController` |  | 13.5 : affiche le modèle Skin_A du rôle |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Cameraman/CharacterName` | TextLabel | lu par `RoleController` | Theo Lindqvist |  |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Cameraman/RoleTitle` | TextLabel | lu par `RoleController` | Caméraman |  |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Cameraman/Ability` | TextLabel | lu par `RoleController` | Seul à produire des preuves de classe A | téléphone : affiché dans Detail |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Cameraman/Weakness` | TextLabel | lu par `RoleController` | Batterie de 6 min | téléphone : affiché dans Detail |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Cameraman/TakenOverlay` | Frame | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Cameraman/TakenOverlay/TakenBy` | TextLabel | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Mechanic` | TextButton | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Mechanic/Portrait` | ViewportFrame | lu par `RoleController` |  | 13.5 : affiche le modèle Skin_A du rôle |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Mechanic/CharacterName` | TextLabel | lu par `RoleController` | Rosa Delgado |  |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Mechanic/RoleTitle` | TextLabel | lu par `RoleController` | Mécanicienne |  |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Mechanic/Ability` | TextLabel | lu par `RoleController` | Répare deux fois plus vite | téléphone : affiché dans Detail |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Mechanic/Weakness` | TextLabel | lu par `RoleController` | Inventaire : 3 emplacements rapides au lieu de 4 | téléphone : affiché dans Detail |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Mechanic/TakenOverlay` | Frame | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Mechanic/TakenOverlay/TakenBy` | TextLabel | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Descendant` | TextButton | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Descendant/Portrait` | ViewportFrame | lu par `RoleController` |  | 13.5 : affiche le modèle Skin_A du rôle |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Descendant/CharacterName` | TextLabel | lu par `RoleController` | Nora Halvorsen |  |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Descendant/RoleTitle` | TextLabel | lu par `RoleController` | Descendante |  |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Descendant/Ability` | TextLabel | lu par `RoleController` | Lit le carnet familial, voit les indices cachés | téléphone : affiché dans Detail |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Descendant/Weakness` | TextLabel | lu par `RoleController` | Peur ×1,25 | téléphone : affiché dans Detail |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Descendant/TakenOverlay` | Frame | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Descendant/TakenOverlay/TakenBy` | TextLabel | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Geologist` | TextButton | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Geologist/Portrait` | ViewportFrame | lu par `RoleController` |  | 13.5 : affiche le modèle Skin_A du rôle |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Geologist/CharacterName` | TextLabel | lu par `RoleController` | Malik Okafor |  |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Geologist/RoleTitle` | TextLabel | lu par `RoleController` | Géologue |  |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Geologist/Ability` | TextLabel | lu par `RoleController` | Lit la carte des tunnels, se repère sous terre | téléphone : affiché dans Detail |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Geologist/Weakness` | TextLabel | lu par `RoleController` | Endurance 80 | téléphone : affiché dans Detail |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Geologist/TakenOverlay` | Frame | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Geologist/TakenOverlay/TakenBy` | TextLabel | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Athlete` | TextButton | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Athlete/Portrait` | ViewportFrame | lu par `RoleController` |  | 13.5 : affiche le modèle Skin_A du rôle |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Athlete/CharacterName` | TextLabel | lu par `RoleController` | Jake Kowalski |  |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Athlete/RoleTitle` | TextLabel | lu par `RoleController` | Sportif |  |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Athlete/Ability` | TextLabel | lu par `RoleController` | Porte un blessé en courant, barricade vite | téléphone : affiché dans Detail |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Athlete/Weakness` | TextLabel | lu par `RoleController` | Respiration : bruit de course 75 | téléphone : affiché dans Detail |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Athlete/TakenOverlay` | Frame | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Athlete/TakenOverlay/TakenBy` | TextLabel | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_RadioOperator` | TextButton | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_RadioOperator/Portrait` | ViewportFrame | lu par `RoleController` |  | 13.5 : affiche le modèle Skin_A du rôle |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_RadioOperator/CharacterName` | TextLabel | lu par `RoleController` | Mei Tanaka |  |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_RadioOperator/RoleTitle` | TextLabel | lu par `RoleController` | Opératrice radio |  |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_RadioOperator/Ability` | TextLabel | lu par `RoleController` | Écoute les fréquences, repère les voix imitées | téléphone : affiché dans Detail |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_RadioOperator/Weakness` | TextLabel | lu par `RoleController` | Aucune arme à feu possible | téléphone : affiché dans Detail |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_RadioOperator/TakenOverlay` | Frame | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_RadioOperator/TakenOverlay/TakenBy` | TextLabel | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Pyrotechnician` | TextButton | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Pyrotechnician/Portrait` | ViewportFrame | lu par `RoleController` |  | 13.5 : affiche le modèle Skin_A du rôle |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Pyrotechnician/CharacterName` | TextLabel | lu par `RoleController` | Dylan Croft |  |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Pyrotechnician/RoleTitle` | TextLabel | lu par `RoleController` | Pyrotechnicien |  |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Pyrotechnician/Ability` | TextLabel | lu par `RoleController` | Fabrique une fusée ou un piège à bruit | téléphone : affiché dans Detail |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Pyrotechnician/Weakness` | TextLabel | lu par `RoleController` | Torse 80 PV | téléphone : affiché dans Detail |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Pyrotechnician/TakenOverlay` | Frame | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Touch/Grid/RoleCard_Pyrotechnician/TakenOverlay/TakenBy` | TextLabel | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Touch/Detail` | Frame | lu par `RoleController` |  | 15.7 (5) : capacité et faiblesse de la carte choisie |
| `RoleSelectGui/Layout_Touch/Detail/Ability` | TextLabel | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Touch/Detail/Weakness` | TextLabel | lu par `RoleController` |  |  |
| `RoleSelectGui/Layout_Touch/Confirm` | TextButton | lu par `RoleController` | Confirmer |  |

### WeaponBoardGui — StarterGui (Lobby), section 15.3

Lu par `WeaponBoardController`.

| Chemin | Classe | Statut | Texte de départ | Remarque |
| --- | --- | --- | --- | --- |
| `WeaponBoardGui` | ScreenGui | lu par `WeaponBoardController` |  |  |
| `WeaponBoardGui/Layout_Desktop` | Frame | lu par `WeaponBoardController` |  | 15.7 : disposition choisie par Util.prepareGui (UserInputService.TouchEnabled) |
| `WeaponBoardGui/Layout_Desktop/Board` | Frame | lu par `WeaponBoardController` |  |  |
| `WeaponBoardGui/Layout_Desktop/Board/Slot_Rifle` | Frame | lu par `WeaponBoardController` |  |  |
| `WeaponBoardGui/Layout_Desktop/Board/Slot_Rifle/Icon` | ImageLabel | lu par `WeaponBoardController` |  | icône d'arme (Icon_WPN_*, 13.5) |
| `WeaponBoardGui/Layout_Desktop/Board/Slot_Rifle/WeaponName` | TextLabel | décoratif | Fusil à verrou |  |
| `WeaponBoardGui/Layout_Desktop/Board/Slot_Rifle/Holder` | TextLabel | lu par `WeaponBoardController` |  |  |
| `WeaponBoardGui/Layout_Desktop/Board/Slot_Rifle/Take` | TextButton | lu par `WeaponBoardController` | Prendre |  |
| `WeaponBoardGui/Layout_Desktop/Board/Slot_Revolver` | Frame | lu par `WeaponBoardController` |  |  |
| `WeaponBoardGui/Layout_Desktop/Board/Slot_Revolver/Icon` | ImageLabel | lu par `WeaponBoardController` |  | icône d'arme (Icon_WPN_*, 13.5) |
| `WeaponBoardGui/Layout_Desktop/Board/Slot_Revolver/WeaponName` | TextLabel | décoratif | Revolver |  |
| `WeaponBoardGui/Layout_Desktop/Board/Slot_Revolver/Holder` | TextLabel | lu par `WeaponBoardController` |  |  |
| `WeaponBoardGui/Layout_Desktop/Board/Slot_Revolver/Take` | TextButton | lu par `WeaponBoardController` | Prendre |  |
| `WeaponBoardGui/Layout_Desktop/Board/Slot_Shotgun` | Frame | lu par `WeaponBoardController` |  |  |
| `WeaponBoardGui/Layout_Desktop/Board/Slot_Shotgun/Icon` | ImageLabel | lu par `WeaponBoardController` |  | icône d'arme (Icon_WPN_*, 13.5) |
| `WeaponBoardGui/Layout_Desktop/Board/Slot_Shotgun/WeaponName` | TextLabel | décoratif | Fusil à pompe |  |
| `WeaponBoardGui/Layout_Desktop/Board/Slot_Shotgun/Holder` | TextLabel | lu par `WeaponBoardController` |  |  |
| `WeaponBoardGui/Layout_Desktop/Board/Slot_Shotgun/Take` | TextButton | lu par `WeaponBoardController` | Prendre |  |
| `WeaponBoardGui/Layout_Desktop/Veil` | Frame | lu par `WeaponBoardController` |  | voile 60 % : visible avec VotePopup (attribut veilFor) |
| `WeaponBoardGui/Layout_Desktop/VotePopup` | Frame | lu par `WeaponBoardController` |  |  |
| `WeaponBoardGui/Layout_Desktop/VotePopup/Question` | TextLabel | lu par `WeaponBoardController` |  |  |
| `WeaponBoardGui/Layout_Desktop/VotePopup/Option_1` | TextButton | lu par `WeaponBoardController` |  |  |
| `WeaponBoardGui/Layout_Desktop/VotePopup/Option_2` | TextButton | lu par `WeaponBoardController` |  |  |
| `WeaponBoardGui/Layout_Desktop/VotePopup/Timer` | TextLabel | lu par `WeaponBoardController` |  |  |
| `WeaponBoardGui/Layout_Touch` | Frame | lu par `WeaponBoardController` |  | 15.7 : disposition choisie par Util.prepareGui (UserInputService.TouchEnabled) |
| `WeaponBoardGui/Layout_Touch/Board` | Frame | lu par `WeaponBoardController` |  |  |
| `WeaponBoardGui/Layout_Touch/Board/Slot_Rifle` | Frame | lu par `WeaponBoardController` |  |  |
| `WeaponBoardGui/Layout_Touch/Board/Slot_Rifle/Icon` | ImageLabel | lu par `WeaponBoardController` |  | icône d'arme (Icon_WPN_*, 13.5) |
| `WeaponBoardGui/Layout_Touch/Board/Slot_Rifle/WeaponName` | TextLabel | décoratif | Fusil à verrou |  |
| `WeaponBoardGui/Layout_Touch/Board/Slot_Rifle/Holder` | TextLabel | lu par `WeaponBoardController` |  |  |
| `WeaponBoardGui/Layout_Touch/Board/Slot_Rifle/Take` | TextButton | lu par `WeaponBoardController` | Prendre |  |
| `WeaponBoardGui/Layout_Touch/Board/Slot_Revolver` | Frame | lu par `WeaponBoardController` |  |  |
| `WeaponBoardGui/Layout_Touch/Board/Slot_Revolver/Icon` | ImageLabel | lu par `WeaponBoardController` |  | icône d'arme (Icon_WPN_*, 13.5) |
| `WeaponBoardGui/Layout_Touch/Board/Slot_Revolver/WeaponName` | TextLabel | décoratif | Revolver |  |
| `WeaponBoardGui/Layout_Touch/Board/Slot_Revolver/Holder` | TextLabel | lu par `WeaponBoardController` |  |  |
| `WeaponBoardGui/Layout_Touch/Board/Slot_Revolver/Take` | TextButton | lu par `WeaponBoardController` | Prendre |  |
| `WeaponBoardGui/Layout_Touch/Board/Slot_Shotgun` | Frame | lu par `WeaponBoardController` |  |  |
| `WeaponBoardGui/Layout_Touch/Board/Slot_Shotgun/Icon` | ImageLabel | lu par `WeaponBoardController` |  | icône d'arme (Icon_WPN_*, 13.5) |
| `WeaponBoardGui/Layout_Touch/Board/Slot_Shotgun/WeaponName` | TextLabel | décoratif | Fusil à pompe |  |
| `WeaponBoardGui/Layout_Touch/Board/Slot_Shotgun/Holder` | TextLabel | lu par `WeaponBoardController` |  |  |
| `WeaponBoardGui/Layout_Touch/Board/Slot_Shotgun/Take` | TextButton | lu par `WeaponBoardController` | Prendre |  |
| `WeaponBoardGui/Layout_Touch/Veil` | Frame | lu par `WeaponBoardController` |  | voile 60 % : visible avec VotePopup (attribut veilFor) |
| `WeaponBoardGui/Layout_Touch/VotePopup` | Frame | lu par `WeaponBoardController` |  |  |
| `WeaponBoardGui/Layout_Touch/VotePopup/Question` | TextLabel | lu par `WeaponBoardController` |  |  |
| `WeaponBoardGui/Layout_Touch/VotePopup/Option_1` | TextButton | lu par `WeaponBoardController` |  |  |
| `WeaponBoardGui/Layout_Touch/VotePopup/Option_2` | TextButton | lu par `WeaponBoardController` |  |  |
| `WeaponBoardGui/Layout_Touch/VotePopup/Timer` | TextLabel | lu par `WeaponBoardController` |  |  |

### VoteGui — StarterGui (Lobby), section 15.3

Lu par `VoteController`.

| Chemin | Classe | Statut | Texte de départ | Remarque |
| --- | --- | --- | --- | --- |
| `VoteGui` | ScreenGui | lu par `VoteController` |  |  |
| `VoteGui/Layout_Desktop` | Frame | lu par `VoteController` |  | 15.7 : disposition choisie par Util.prepareGui (UserInputService.TouchEnabled) |
| `VoteGui/Layout_Desktop/Difficulty` | Frame | lu par `VoteController` |  |  |
| `VoteGui/Layout_Desktop/Difficulty/Title` | TextLabel | décoratif | Difficulté |  |
| `VoteGui/Layout_Desktop/Difficulty/Normal` | TextButton | lu par `VoteController` | Normal |  |
| `VoteGui/Layout_Desktop/Difficulty/Hard` | TextButton | lu par `VoteController` | Difficile |  |
| `VoteGui/Layout_Desktop/Difficulty/Nightmare` | TextButton | lu par `VoteController` | Cauchemar |  |
| `VoteGui/Layout_Desktop/Difficulty/Nightmare/Lock` | TextLabel | lu par `VoteController` | Verrouillé — 1 survie |  |
| `VoteGui/Layout_Desktop/Weather` | Frame | lu par `VoteController` |  |  |
| `VoteGui/Layout_Desktop/Weather/Title` | TextLabel | décoratif | Météo |  |
| `VoteGui/Layout_Desktop/Weather/Random` | TextButton | lu par `VoteController` | Aléatoire |  |
| `VoteGui/Layout_Desktop/Weather/Clear` | TextButton | lu par `VoteController` | Nuit claire |  |
| `VoteGui/Layout_Desktop/Weather/Fog` | TextButton | lu par `VoteController` | Brouillard |  |
| `VoteGui/Layout_Desktop/Weather/Rain` | TextButton | lu par `VoteController` | Pluie |  |
| `VoteGui/Layout_Desktop/Weather/Snow` | TextButton | lu par `VoteController` | Première neige |  |
| `VoteGui/Layout_Desktop/Countdown` | TextLabel | lu par `VoteController` |  |  |
| `VoteGui/Layout_Touch` | Frame | lu par `VoteController` |  | 15.7 : disposition choisie par Util.prepareGui (UserInputService.TouchEnabled) |
| `VoteGui/Layout_Touch/Difficulty` | Frame | lu par `VoteController` |  |  |
| `VoteGui/Layout_Touch/Difficulty/Title` | TextLabel | décoratif | Difficulté |  |
| `VoteGui/Layout_Touch/Difficulty/Normal` | TextButton | lu par `VoteController` | Normal |  |
| `VoteGui/Layout_Touch/Difficulty/Hard` | TextButton | lu par `VoteController` | Difficile |  |
| `VoteGui/Layout_Touch/Difficulty/Nightmare` | TextButton | lu par `VoteController` | Cauchemar |  |
| `VoteGui/Layout_Touch/Difficulty/Nightmare/Lock` | TextLabel | lu par `VoteController` | Verrouillé — 1 survie |  |
| `VoteGui/Layout_Touch/Weather` | Frame | lu par `VoteController` |  |  |
| `VoteGui/Layout_Touch/Weather/Title` | TextLabel | décoratif | Météo |  |
| `VoteGui/Layout_Touch/Weather/Random` | TextButton | lu par `VoteController` | Aléatoire |  |
| `VoteGui/Layout_Touch/Weather/Clear` | TextButton | lu par `VoteController` | Nuit claire |  |
| `VoteGui/Layout_Touch/Weather/Fog` | TextButton | lu par `VoteController` | Brouillard |  |
| `VoteGui/Layout_Touch/Weather/Rain` | TextButton | lu par `VoteController` | Pluie |  |
| `VoteGui/Layout_Touch/Weather/Snow` | TextButton | lu par `VoteController` | Première neige |  |
| `VoteGui/Layout_Touch/Countdown` | TextLabel | lu par `VoteController` |  |  |

### SkinShopGui — StarterGui (Lobby), section 15.3

Lu par `SkinShopController`.

| Chemin | Classe | Statut | Texte de départ | Remarque |
| --- | --- | --- | --- | --- |
| `SkinShopGui` | ScreenGui | lu par `SkinShopController` |  |  |
| `SkinShopGui/Layout_Desktop` | Frame | lu par `SkinShopController` |  | 15.7 : disposition choisie par Util.prepareGui (UserInputService.TouchEnabled) |
| `SkinShopGui/Layout_Desktop/Veil` | Frame | lu par `SkinShopController` |  | voile 60 % : visible avec CharacterList, SkinGrid, Accessories, Preview, Equip (attribut veilFor) |
| `SkinShopGui/Layout_Desktop/CharacterList` | ScrollingFrame | lu par `SkinShopController` |  |  |
| `SkinShopGui/Layout_Desktop/CharacterList/Template` | TextButton | lu par `SkinShopController` |  |  |
| `SkinShopGui/Layout_Desktop/SkinGrid` | Frame | lu par `SkinShopController` |  |  |
| `SkinShopGui/Layout_Desktop/SkinGrid/Skin_A` | TextButton | lu par `SkinShopController` | Tenue de départ |  |
| `SkinShopGui/Layout_Desktop/SkinGrid/Skin_A/Lock` | TextLabel | lu par `SkinShopController` |  |  |
| `SkinShopGui/Layout_Desktop/SkinGrid/Skin_A/Requirement` | TextLabel | lu par `SkinShopController` |  |  |
| `SkinShopGui/Layout_Desktop/SkinGrid/Skin_B` | TextButton | lu par `SkinShopController` | Tenue de pluie |  |
| `SkinShopGui/Layout_Desktop/SkinGrid/Skin_B/Lock` | TextLabel | lu par `SkinShopController` | Verrouillé — 5 parties jouées |  |
| `SkinShopGui/Layout_Desktop/SkinGrid/Skin_B/Requirement` | TextLabel | lu par `SkinShopController` | 5 parties jouées |  |
| `SkinShopGui/Layout_Desktop/SkinGrid/Skin_C` | TextButton | lu par `SkinShopController` | Tenue « Cold Trail » |  |
| `SkinShopGui/Layout_Desktop/SkinGrid/Skin_C/Lock` | TextLabel | lu par `SkinShopController` | Verrouillé — 1 survie |  |
| `SkinShopGui/Layout_Desktop/SkinGrid/Skin_C/Requirement` | TextLabel | lu par `SkinShopController` | 1 survie |  |
| `SkinShopGui/Layout_Desktop/Accessories` | Frame | lu par `SkinShopController` |  | 19.5 (C38) : accessoires |
| `SkinShopGui/Layout_Desktop/Accessories/Beanie` | TextButton | lu par `SkinShopController` | Bonnet |  |
| `SkinShopGui/Layout_Desktop/Accessories/Beanie/Lock` | TextLabel | lu par `SkinShopController` | Verrouillé — 3 parties jouées |  |
| `SkinShopGui/Layout_Desktop/Accessories/AmberHeadlamp` | TextButton | lu par `SkinShopController` | Frontale ambre |  |
| `SkinShopGui/Layout_Desktop/Accessories/AmberHeadlamp/Lock` | TextLabel | lu par `SkinShopController` | Verrouillé — 10 parties jouées |  |
| `SkinShopGui/Layout_Desktop/Accessories/ColdTrailBag` | TextButton | lu par `SkinShopController` | Sac « Cold Trail » |  |
| `SkinShopGui/Layout_Desktop/Accessories/ColdTrailBag/Lock` | TextLabel | lu par `SkinShopController` | Verrouillé — 1 preuve de classe B |  |
| `SkinShopGui/Layout_Desktop/Preview` | ViewportFrame | lu par `SkinShopController` |  |  |
| `SkinShopGui/Layout_Desktop/Equip` | TextButton | lu par `SkinShopController` | Équiper |  |
| `SkinShopGui/Layout_Touch` | Frame | lu par `SkinShopController` |  | 15.7 : disposition choisie par Util.prepareGui (UserInputService.TouchEnabled) |
| `SkinShopGui/Layout_Touch/Veil` | Frame | lu par `SkinShopController` |  | voile 60 % : visible avec CharacterList, SkinGrid, Accessories, Preview, Equip (attribut veilFor) |
| `SkinShopGui/Layout_Touch/CharacterList` | ScrollingFrame | lu par `SkinShopController` |  |  |
| `SkinShopGui/Layout_Touch/CharacterList/Template` | TextButton | lu par `SkinShopController` |  |  |
| `SkinShopGui/Layout_Touch/SkinGrid` | Frame | lu par `SkinShopController` |  |  |
| `SkinShopGui/Layout_Touch/SkinGrid/Skin_A` | TextButton | lu par `SkinShopController` | Tenue de départ |  |
| `SkinShopGui/Layout_Touch/SkinGrid/Skin_A/Lock` | TextLabel | lu par `SkinShopController` |  |  |
| `SkinShopGui/Layout_Touch/SkinGrid/Skin_A/Requirement` | TextLabel | lu par `SkinShopController` |  |  |
| `SkinShopGui/Layout_Touch/SkinGrid/Skin_B` | TextButton | lu par `SkinShopController` | Tenue de pluie |  |
| `SkinShopGui/Layout_Touch/SkinGrid/Skin_B/Lock` | TextLabel | lu par `SkinShopController` | Verrouillé — 5 parties jouées |  |
| `SkinShopGui/Layout_Touch/SkinGrid/Skin_B/Requirement` | TextLabel | lu par `SkinShopController` | 5 parties jouées |  |
| `SkinShopGui/Layout_Touch/SkinGrid/Skin_C` | TextButton | lu par `SkinShopController` | Tenue « Cold Trail » |  |
| `SkinShopGui/Layout_Touch/SkinGrid/Skin_C/Lock` | TextLabel | lu par `SkinShopController` | Verrouillé — 1 survie |  |
| `SkinShopGui/Layout_Touch/SkinGrid/Skin_C/Requirement` | TextLabel | lu par `SkinShopController` | 1 survie |  |
| `SkinShopGui/Layout_Touch/Accessories` | Frame | lu par `SkinShopController` |  | 19.5 (C38) : accessoires |
| `SkinShopGui/Layout_Touch/Accessories/Beanie` | TextButton | lu par `SkinShopController` | Bonnet |  |
| `SkinShopGui/Layout_Touch/Accessories/Beanie/Lock` | TextLabel | lu par `SkinShopController` | Verrouillé — 3 parties jouées |  |
| `SkinShopGui/Layout_Touch/Accessories/AmberHeadlamp` | TextButton | lu par `SkinShopController` | Frontale ambre |  |
| `SkinShopGui/Layout_Touch/Accessories/AmberHeadlamp/Lock` | TextLabel | lu par `SkinShopController` | Verrouillé — 10 parties jouées |  |
| `SkinShopGui/Layout_Touch/Accessories/ColdTrailBag` | TextButton | lu par `SkinShopController` | Sac « Cold Trail » |  |
| `SkinShopGui/Layout_Touch/Accessories/ColdTrailBag/Lock` | TextLabel | lu par `SkinShopController` | Verrouillé — 1 preuve de classe B |  |
| `SkinShopGui/Layout_Touch/Preview` | ViewportFrame | lu par `SkinShopController` |  |  |
| `SkinShopGui/Layout_Touch/Equip` | TextButton | lu par `SkinShopController` | Équiper |  |

### RecordsGui — StarterGui (Lobby), section 15.3

Lu par `RecordsController`.

| Chemin | Classe | Statut | Texte de départ | Remarque |
| --- | --- | --- | --- | --- |
| `RecordsGui` | ScreenGui | lu par `RecordsController` |  |  |
| `RecordsGui/Layout_Desktop` | Frame | lu par `RecordsController` |  | 15.7 : disposition choisie par Util.prepareGui (UserInputService.TouchEnabled) |
| `RecordsGui/Layout_Desktop/Veil` | Frame | lu par `RecordsController` |  | voile 60 % : visible avec Tabs, Board (attribut veilFor) |
| `RecordsGui/Layout_Desktop/Tabs` | Frame | lu par `RecordsController` |  |  |
| `RecordsGui/Layout_Desktop/Tabs/Survivors` | TextButton | lu par `RecordsController` | Survivants |  |
| `RecordsGui/Layout_Desktop/Tabs/EvidenceA` | TextButton | lu par `RecordsController` | Preuves A |  |
| `RecordsGui/Layout_Desktop/Tabs/Endings` | TextButton | lu par `RecordsController` | Fins |  |
| `RecordsGui/Layout_Desktop/Board` | ScrollingFrame | lu par `RecordsController` |  |  |
| `RecordsGui/Layout_Desktop/Board/Template` | Frame | lu par `RecordsController` |  |  |
| `RecordsGui/Layout_Desktop/Board/Template/Rank` | TextLabel | lu par `RecordsController` |  |  |
| `RecordsGui/Layout_Desktop/Board/Template/Group` | TextLabel | lu par `RecordsController` |  |  |
| `RecordsGui/Layout_Desktop/Board/Template/Value` | TextLabel | lu par `RecordsController` |  |  |
| `RecordsGui/Layout_Touch` | Frame | lu par `RecordsController` |  | 15.7 : disposition choisie par Util.prepareGui (UserInputService.TouchEnabled) |
| `RecordsGui/Layout_Touch/Veil` | Frame | lu par `RecordsController` |  | voile 60 % : visible avec Tabs, Board (attribut veilFor) |
| `RecordsGui/Layout_Touch/Tabs` | Frame | lu par `RecordsController` |  |  |
| `RecordsGui/Layout_Touch/Tabs/Survivors` | TextButton | lu par `RecordsController` | Survivants |  |
| `RecordsGui/Layout_Touch/Tabs/EvidenceA` | TextButton | lu par `RecordsController` | Preuves A |  |
| `RecordsGui/Layout_Touch/Tabs/Endings` | TextButton | lu par `RecordsController` | Fins |  |
| `RecordsGui/Layout_Touch/Board` | ScrollingFrame | lu par `RecordsController` |  |  |
| `RecordsGui/Layout_Touch/Board/Template` | Frame | lu par `RecordsController` |  |  |
| `RecordsGui/Layout_Touch/Board/Template/Rank` | TextLabel | lu par `RecordsController` |  |  |
| `RecordsGui/Layout_Touch/Board/Template/Group` | TextLabel | lu par `RecordsController` |  |  |
| `RecordsGui/Layout_Touch/Board/Template/Value` | TextLabel | lu par `RecordsController` |  |  |

### EvidenceBoardGui — StarterGui (Lobby), section 15.3

Lu par `EvidenceBoardController`.

| Chemin | Classe | Statut | Texte de départ | Remarque |
| --- | --- | --- | --- | --- |
| `EvidenceBoardGui` | ScreenGui | lu par `EvidenceBoardController` |  |  |
| `EvidenceBoardGui/Layout_Desktop` | Frame | lu par `EvidenceBoardController` |  | 15.7 : disposition choisie par Util.prepareGui (UserInputService.TouchEnabled) |
| `EvidenceBoardGui/Layout_Desktop/Veil` | Frame | lu par `EvidenceBoardController` |  | voile 60 % : visible avec Cork, NotebookPages (attribut veilFor) |
| `EvidenceBoardGui/Layout_Desktop/Cork` | ScrollingFrame | lu par `EvidenceBoardController` |  |  |
| `EvidenceBoardGui/Layout_Desktop/Cork/Template` | Frame | lu par `EvidenceBoardController` |  |  |
| `EvidenceBoardGui/Layout_Desktop/Cork/Template/Photo` | ImageLabel | lu par `EvidenceBoardController` |  |  |
| `EvidenceBoardGui/Layout_Desktop/Cork/Template/Label` | TextLabel | lu par `EvidenceBoardController` |  |  |
| `EvidenceBoardGui/Layout_Desktop/Cork/Template/Class` | TextLabel | lu par `EvidenceBoardController` |  |  |
| `EvidenceBoardGui/Layout_Desktop/NotebookPages` | Frame | lu par `EvidenceBoardController` |  |  |
| `EvidenceBoardGui/Layout_Desktop/NotebookPages/Page_1` | TextLabel | lu par `EvidenceBoardController` | Il n'a jamais voulu en parler. Il disait seulement : ne tire pas le premier. |  |
| `EvidenceBoardGui/Layout_Desktop/NotebookPages/Page_1/Lock` | TextLabel | lu par `EvidenceBoardController` | Verrouillé |  |
| `EvidenceBoardGui/Layout_Desktop/NotebookPages/Page_2` | TextLabel | lu par `EvidenceBoardController` | Ils frappaient les arbres avant les pierres. |  |
| `EvidenceBoardGui/Layout_Desktop/NotebookPages/Page_2/Lock` | TextLabel | lu par `EvidenceBoardController` | Verrouillé |  |
| `EvidenceBoardGui/Layout_Desktop/NotebookPages/Page_3` | TextLabel | lu par `EvidenceBoardController` | On leur avait pris quelqu'un, à eux aussi. |  |
| `EvidenceBoardGui/Layout_Desktop/NotebookPages/Page_3/Lock` | TextLabel | lu par `EvidenceBoardController` | Verrouillé |  |
| `EvidenceBoardGui/Layout_Touch` | Frame | lu par `EvidenceBoardController` |  | 15.7 : disposition choisie par Util.prepareGui (UserInputService.TouchEnabled) |
| `EvidenceBoardGui/Layout_Touch/Veil` | Frame | lu par `EvidenceBoardController` |  | voile 60 % : visible avec Cork, NotebookPages (attribut veilFor) |
| `EvidenceBoardGui/Layout_Touch/Cork` | ScrollingFrame | lu par `EvidenceBoardController` |  |  |
| `EvidenceBoardGui/Layout_Touch/Cork/Template` | Frame | lu par `EvidenceBoardController` |  |  |
| `EvidenceBoardGui/Layout_Touch/Cork/Template/Photo` | ImageLabel | lu par `EvidenceBoardController` |  |  |
| `EvidenceBoardGui/Layout_Touch/Cork/Template/Label` | TextLabel | lu par `EvidenceBoardController` |  |  |
| `EvidenceBoardGui/Layout_Touch/Cork/Template/Class` | TextLabel | lu par `EvidenceBoardController` |  |  |
| `EvidenceBoardGui/Layout_Touch/NotebookPages` | Frame | lu par `EvidenceBoardController` |  |  |
| `EvidenceBoardGui/Layout_Touch/NotebookPages/Page_1` | TextLabel | lu par `EvidenceBoardController` | Il n'a jamais voulu en parler. Il disait seulement : ne tire pas le premier. |  |
| `EvidenceBoardGui/Layout_Touch/NotebookPages/Page_1/Lock` | TextLabel | lu par `EvidenceBoardController` | Verrouillé |  |
| `EvidenceBoardGui/Layout_Touch/NotebookPages/Page_2` | TextLabel | lu par `EvidenceBoardController` | Ils frappaient les arbres avant les pierres. |  |
| `EvidenceBoardGui/Layout_Touch/NotebookPages/Page_2/Lock` | TextLabel | lu par `EvidenceBoardController` | Verrouillé |  |
| `EvidenceBoardGui/Layout_Touch/NotebookPages/Page_3` | TextLabel | lu par `EvidenceBoardController` | On leur avait pris quelqu'un, à eux aussi. |  |
| `EvidenceBoardGui/Layout_Touch/NotebookPages/Page_3/Lock` | TextLabel | lu par `EvidenceBoardController` | Verrouillé |  |

### ResultsGui — StarterGui (Lobby), section 15.3

Lu par `ResultsController`.

| Chemin | Classe | Statut | Texte de départ | Remarque |
| --- | --- | --- | --- | --- |
| `ResultsGui` | ScreenGui | lu par `ResultsController` |  |  |
| `ResultsGui/Layout_Desktop` | Frame | lu par `ResultsController` |  | 15.7 : disposition choisie par Util.prepareGui (UserInputService.TouchEnabled) |
| `ResultsGui/Layout_Desktop/Veil` | Frame | lu par `ResultsController` |  | voile 60 % : visible avec Card (attribut veilFor) |
| `ResultsGui/Layout_Desktop/Card` | Frame | lu par `ResultsController` |  |  |
| `ResultsGui/Layout_Desktop/Card/EndingTitle` | TextLabel | lu par `ResultsController` |  |  |
| `ResultsGui/Layout_Desktop/Card/EndingText` | TextLabel | lu par `ResultsController` |  |  |
| `ResultsGui/Layout_Desktop/Card/Survivors` | ScrollingFrame | lu par `ResultsController` |  |  |
| `ResultsGui/Layout_Desktop/Card/Survivors/Template` | Frame | lu par `ResultsController` |  |  |
| `ResultsGui/Layout_Desktop/Card/Survivors/Template/Name` | TextLabel | lu par `ResultsController` |  |  |
| `ResultsGui/Layout_Desktop/Card/Survivors/Template/Status` | TextLabel | lu par `ResultsController` |  |  |
| `ResultsGui/Layout_Desktop/Card/Evidence` | ScrollingFrame | lu par `ResultsController` |  |  |
| `ResultsGui/Layout_Desktop/Card/Evidence/Template` | TextLabel | lu par `ResultsController` |  |  |
| `ResultsGui/Layout_Desktop/Card/XPGained` | TextLabel | lu par `ResultsController` |  |  |
| `ResultsGui/Layout_Desktop/Card/Continue` | TextButton | lu par `ResultsController` | Continuer |  |
| `ResultsGui/Layout_Touch` | Frame | lu par `ResultsController` |  | 15.7 : disposition choisie par Util.prepareGui (UserInputService.TouchEnabled) |
| `ResultsGui/Layout_Touch/Veil` | Frame | lu par `ResultsController` |  | voile 60 % : visible avec Card (attribut veilFor) |
| `ResultsGui/Layout_Touch/Card` | Frame | lu par `ResultsController` |  |  |
| `ResultsGui/Layout_Touch/Card/EndingTitle` | TextLabel | lu par `ResultsController` |  |  |
| `ResultsGui/Layout_Touch/Card/EndingText` | TextLabel | lu par `ResultsController` |  |  |
| `ResultsGui/Layout_Touch/Card/Survivors` | ScrollingFrame | lu par `ResultsController` |  |  |
| `ResultsGui/Layout_Touch/Card/Survivors/Template` | Frame | lu par `ResultsController` |  |  |
| `ResultsGui/Layout_Touch/Card/Survivors/Template/Name` | TextLabel | lu par `ResultsController` |  |  |
| `ResultsGui/Layout_Touch/Card/Survivors/Template/Status` | TextLabel | lu par `ResultsController` |  |  |
| `ResultsGui/Layout_Touch/Card/Evidence` | ScrollingFrame | lu par `ResultsController` |  |  |
| `ResultsGui/Layout_Touch/Card/Evidence/Template` | TextLabel | lu par `ResultsController` |  |  |
| `ResultsGui/Layout_Touch/Card/XPGained` | TextLabel | lu par `ResultsController` |  |  |
| `ResultsGui/Layout_Touch/Card/Continue` | TextButton | lu par `ResultsController` | Continuer |  |

### LoadingGui — StarterGui (Lobby), section 15.3

Lu par `TeleportController`.

| Chemin | Classe | Statut | Texte de départ | Remarque |
| --- | --- | --- | --- | --- |
| `LoadingGui` | ScreenGui | lu par `TeleportController` |  |  |
| `LoadingGui/Background` | Frame | lu par `TeleportController` |  |  |
| `LoadingGui/Tip` | TextLabel | lu par `TeleportController` |  |  |
| `LoadingGui/Spinner` | Frame | décoratif |  | décor ; à remplacer par une image |

### NotificationGui — StarterGui (Lobby), section 15.3

Lu par `NotificationController`.

| Chemin | Classe | Statut | Texte de départ | Remarque |
| --- | --- | --- | --- | --- |
| `NotificationGui` | ScreenGui | lu par `NotificationController` |  |  |
| `NotificationGui/Layout_Desktop` | Frame | lu par `NotificationController` |  | 15.7 : disposition choisie par Util.prepareGui (UserInputService.TouchEnabled) |
| `NotificationGui/Layout_Desktop/Stack` | Frame | lu par `NotificationController` |  |  |
| `NotificationGui/Layout_Desktop/Stack/Template` | Frame | lu par `NotificationController` |  |  |
| `NotificationGui/Layout_Desktop/Stack/Template/Text` | TextLabel | lu par `NotificationController` |  |  |
| `NotificationGui/Layout_Touch` | Frame | lu par `NotificationController` |  | 15.7 : disposition choisie par Util.prepareGui (UserInputService.TouchEnabled) |
| `NotificationGui/Layout_Touch/Stack` | Frame | lu par `NotificationController` |  |  |
| `NotificationGui/Layout_Touch/Stack/Template` | Frame | lu par `NotificationController` |  |  |
| `NotificationGui/Layout_Touch/Stack/Template/Text` | TextLabel | lu par `NotificationController` |  |  |

### HUDGui — StarterGui (Partie), section 15.4

Lu par `HUDController`.

| Chemin | Classe | Statut | Texte de départ | Remarque |
| --- | --- | --- | --- | --- |
| `HUDGui` | ScreenGui | lu par `HUDController` |  |  |
| `HUDGui/Layout_Desktop` | Frame | lu par `HUDController` |  | 15.7 : disposition choisie par Util.prepareGui (UserInputService.TouchEnabled) |
| `HUDGui/Layout_Desktop/FearVignette` | ImageLabel | lu par `HUDController` |  | Img_FearVignette (13.5) ; ImageTransparency réglée par le script |
| `HUDGui/Layout_Desktop/BodyStatus` | Frame | lu par `HUDController` |  |  |
| `HUDGui/Layout_Desktop/BodyStatus/Head` | Frame | lu par `HUDController` |  |  |
| `HUDGui/Layout_Desktop/BodyStatus/Head/Ok` | ImageLabel | lu par `HUDController` |  | Img_Body_Head (13.5) |
| `HUDGui/Layout_Desktop/BodyStatus/Head/Hurt` | ImageLabel | lu par `HUDController` |  | Img_Body_Head (13.5) |
| `HUDGui/Layout_Desktop/BodyStatus/Head/Critical` | ImageLabel | lu par `HUDController` |  | Img_Body_Head (13.5) |
| `HUDGui/Layout_Desktop/BodyStatus/Torso` | Frame | lu par `HUDController` |  |  |
| `HUDGui/Layout_Desktop/BodyStatus/Torso/Ok` | ImageLabel | lu par `HUDController` |  | Img_Body_Torso (13.5) |
| `HUDGui/Layout_Desktop/BodyStatus/Torso/Hurt` | ImageLabel | lu par `HUDController` |  | Img_Body_Torso (13.5) |
| `HUDGui/Layout_Desktop/BodyStatus/Torso/Critical` | ImageLabel | lu par `HUDController` |  | Img_Body_Torso (13.5) |
| `HUDGui/Layout_Desktop/BodyStatus/ArmL` | Frame | lu par `HUDController` |  |  |
| `HUDGui/Layout_Desktop/BodyStatus/ArmL/Ok` | ImageLabel | lu par `HUDController` |  | Img_Body_ArmL (13.5) |
| `HUDGui/Layout_Desktop/BodyStatus/ArmL/Hurt` | ImageLabel | lu par `HUDController` |  | Img_Body_ArmL (13.5) |
| `HUDGui/Layout_Desktop/BodyStatus/ArmL/Critical` | ImageLabel | lu par `HUDController` |  | Img_Body_ArmL (13.5) |
| `HUDGui/Layout_Desktop/BodyStatus/ArmR` | Frame | lu par `HUDController` |  |  |
| `HUDGui/Layout_Desktop/BodyStatus/ArmR/Ok` | ImageLabel | lu par `HUDController` |  | Img_Body_ArmR (13.5) |
| `HUDGui/Layout_Desktop/BodyStatus/ArmR/Hurt` | ImageLabel | lu par `HUDController` |  | Img_Body_ArmR (13.5) |
| `HUDGui/Layout_Desktop/BodyStatus/ArmR/Critical` | ImageLabel | lu par `HUDController` |  | Img_Body_ArmR (13.5) |
| `HUDGui/Layout_Desktop/BodyStatus/LegL` | Frame | lu par `HUDController` |  |  |
| `HUDGui/Layout_Desktop/BodyStatus/LegL/Ok` | ImageLabel | lu par `HUDController` |  | Img_Body_LegL (13.5) |
| `HUDGui/Layout_Desktop/BodyStatus/LegL/Hurt` | ImageLabel | lu par `HUDController` |  | Img_Body_LegL (13.5) |
| `HUDGui/Layout_Desktop/BodyStatus/LegL/Critical` | ImageLabel | lu par `HUDController` |  | Img_Body_LegL (13.5) |
| `HUDGui/Layout_Desktop/BodyStatus/LegR` | Frame | lu par `HUDController` |  |  |
| `HUDGui/Layout_Desktop/BodyStatus/LegR/Ok` | ImageLabel | lu par `HUDController` |  | Img_Body_LegR (13.5) |
| `HUDGui/Layout_Desktop/BodyStatus/LegR/Hurt` | ImageLabel | lu par `HUDController` |  | Img_Body_LegR (13.5) |
| `HUDGui/Layout_Desktop/BodyStatus/LegR/Critical` | ImageLabel | lu par `HUDController` |  | Img_Body_LegR (13.5) |
| `HUDGui/Layout_Desktop/BleedIcon` | Frame | lu par `HUDController` |  |  |
| `HUDGui/Layout_Desktop/StaminaIcon` | ImageLabel | lu par `HUDController` |  |  |
| `HUDGui/Layout_Desktop/Stamina` | Frame | lu par `HUDController` |  |  |
| `HUDGui/Layout_Desktop/Stamina/Fill` | Frame | lu par `HUDController` |  |  |
| `HUDGui/Layout_Desktop/BatteryIcon` | ImageLabel | lu par `HUDController` |  |  |
| `HUDGui/Layout_Desktop/Battery` | Frame | lu par `HUDController` |  |  |
| `HUDGui/Layout_Desktop/Battery/Fill` | Frame | lu par `HUDController` |  |  |
| `HUDGui/Layout_Desktop/Ammo` | Frame | lu par `HUDController` |  |  |
| `HUDGui/Layout_Desktop/Ammo/Count` | TextLabel | lu par `HUDController` |  |  |
| `HUDGui/Layout_Desktop/Ammo/Reserve` | TextLabel | lu par `HUDController` |  |  |
| `HUDGui/Layout_Desktop/HeldItem` | TextLabel | lu par `HUDController` |  |  |
| `HUDGui/Layout_Desktop/Crosshair` | Frame | lu par `HUDController` |  |  |
| `HUDGui/Layout_Desktop/Ping` | Frame | lu par `HUDController` |  |  |
| `HUDGui/Layout_Desktop/Ping/Template` | Frame | lu par `HUDController` |  |  |
| `HUDGui/Layout_Touch` | Frame | lu par `HUDController` |  | 15.7 : disposition choisie par Util.prepareGui (UserInputService.TouchEnabled) |
| `HUDGui/Layout_Touch/FearVignette` | ImageLabel | lu par `HUDController` |  | Img_FearVignette (13.5) ; ImageTransparency réglée par le script |
| `HUDGui/Layout_Touch/BodyStatus` | Frame | lu par `HUDController` |  |  |
| `HUDGui/Layout_Touch/BodyStatus/Head` | Frame | lu par `HUDController` |  |  |
| `HUDGui/Layout_Touch/BodyStatus/Head/Ok` | ImageLabel | lu par `HUDController` |  | Img_Body_Head (13.5) |
| `HUDGui/Layout_Touch/BodyStatus/Head/Hurt` | ImageLabel | lu par `HUDController` |  | Img_Body_Head (13.5) |
| `HUDGui/Layout_Touch/BodyStatus/Head/Critical` | ImageLabel | lu par `HUDController` |  | Img_Body_Head (13.5) |
| `HUDGui/Layout_Touch/BodyStatus/Torso` | Frame | lu par `HUDController` |  |  |
| `HUDGui/Layout_Touch/BodyStatus/Torso/Ok` | ImageLabel | lu par `HUDController` |  | Img_Body_Torso (13.5) |
| `HUDGui/Layout_Touch/BodyStatus/Torso/Hurt` | ImageLabel | lu par `HUDController` |  | Img_Body_Torso (13.5) |
| `HUDGui/Layout_Touch/BodyStatus/Torso/Critical` | ImageLabel | lu par `HUDController` |  | Img_Body_Torso (13.5) |
| `HUDGui/Layout_Touch/BodyStatus/ArmL` | Frame | lu par `HUDController` |  |  |
| `HUDGui/Layout_Touch/BodyStatus/ArmL/Ok` | ImageLabel | lu par `HUDController` |  | Img_Body_ArmL (13.5) |
| `HUDGui/Layout_Touch/BodyStatus/ArmL/Hurt` | ImageLabel | lu par `HUDController` |  | Img_Body_ArmL (13.5) |
| `HUDGui/Layout_Touch/BodyStatus/ArmL/Critical` | ImageLabel | lu par `HUDController` |  | Img_Body_ArmL (13.5) |
| `HUDGui/Layout_Touch/BodyStatus/ArmR` | Frame | lu par `HUDController` |  |  |
| `HUDGui/Layout_Touch/BodyStatus/ArmR/Ok` | ImageLabel | lu par `HUDController` |  | Img_Body_ArmR (13.5) |
| `HUDGui/Layout_Touch/BodyStatus/ArmR/Hurt` | ImageLabel | lu par `HUDController` |  | Img_Body_ArmR (13.5) |
| `HUDGui/Layout_Touch/BodyStatus/ArmR/Critical` | ImageLabel | lu par `HUDController` |  | Img_Body_ArmR (13.5) |
| `HUDGui/Layout_Touch/BodyStatus/LegL` | Frame | lu par `HUDController` |  |  |
| `HUDGui/Layout_Touch/BodyStatus/LegL/Ok` | ImageLabel | lu par `HUDController` |  | Img_Body_LegL (13.5) |
| `HUDGui/Layout_Touch/BodyStatus/LegL/Hurt` | ImageLabel | lu par `HUDController` |  | Img_Body_LegL (13.5) |
| `HUDGui/Layout_Touch/BodyStatus/LegL/Critical` | ImageLabel | lu par `HUDController` |  | Img_Body_LegL (13.5) |
| `HUDGui/Layout_Touch/BodyStatus/LegR` | Frame | lu par `HUDController` |  |  |
| `HUDGui/Layout_Touch/BodyStatus/LegR/Ok` | ImageLabel | lu par `HUDController` |  | Img_Body_LegR (13.5) |
| `HUDGui/Layout_Touch/BodyStatus/LegR/Hurt` | ImageLabel | lu par `HUDController` |  | Img_Body_LegR (13.5) |
| `HUDGui/Layout_Touch/BodyStatus/LegR/Critical` | ImageLabel | lu par `HUDController` |  | Img_Body_LegR (13.5) |
| `HUDGui/Layout_Touch/BleedIcon` | Frame | lu par `HUDController` |  |  |
| `HUDGui/Layout_Touch/StaminaIcon` | ImageLabel | lu par `HUDController` |  |  |
| `HUDGui/Layout_Touch/Stamina` | Frame | lu par `HUDController` |  |  |
| `HUDGui/Layout_Touch/Stamina/Fill` | Frame | lu par `HUDController` |  |  |
| `HUDGui/Layout_Touch/BatteryIcon` | ImageLabel | lu par `HUDController` |  |  |
| `HUDGui/Layout_Touch/Battery` | Frame | lu par `HUDController` |  |  |
| `HUDGui/Layout_Touch/Battery/Fill` | Frame | lu par `HUDController` |  |  |
| `HUDGui/Layout_Touch/Ammo` | Frame | lu par `HUDController` |  |  |
| `HUDGui/Layout_Touch/Ammo/Count` | TextLabel | lu par `HUDController` |  |  |
| `HUDGui/Layout_Touch/Ammo/Reserve` | TextLabel | lu par `HUDController` |  |  |
| `HUDGui/Layout_Touch/HeldItem` | TextLabel | lu par `HUDController` |  |  |
| `HUDGui/Layout_Touch/Crosshair` | Frame | lu par `HUDController` |  |  |
| `HUDGui/Layout_Touch/Ping` | Frame | lu par `HUDController` |  |  |
| `HUDGui/Layout_Touch/Ping/Template` | Frame | lu par `HUDController` |  |  |

### InventoryGui — StarterGui (Partie), section 15.4

Lu par `InventoryController`.

| Chemin | Classe | Statut | Texte de départ | Remarque |
| --- | --- | --- | --- | --- |
| `InventoryGui` | ScreenGui | lu par `InventoryController` |  |  |
| `InventoryGui/Layout_Desktop` | Frame | lu par `InventoryController` |  | 15.7 : disposition choisie par Util.prepareGui (UserInputService.TouchEnabled) |
| `InventoryGui/Layout_Desktop/QuickSlots` | Frame | lu par `InventoryController` |  |  |
| `InventoryGui/Layout_Desktop/QuickSlots/Slot_1` | Frame | lu par `InventoryController` |  |  |
| `InventoryGui/Layout_Desktop/QuickSlots/Slot_1/Icon` | ImageLabel | lu par `InventoryController` |  |  |
| `InventoryGui/Layout_Desktop/QuickSlots/Slot_1/Count` | TextLabel | lu par `InventoryController` |  |  |
| `InventoryGui/Layout_Desktop/QuickSlots/Slot_1/Key` | TextLabel | lu par `InventoryController` |  |  |
| `InventoryGui/Layout_Desktop/QuickSlots/Slot_1/Selected` | Frame | lu par `InventoryController` |  |  |
| `InventoryGui/Layout_Desktop/QuickSlots/Slot_2` | Frame | lu par `InventoryController` |  |  |
| `InventoryGui/Layout_Desktop/QuickSlots/Slot_2/Icon` | ImageLabel | lu par `InventoryController` |  |  |
| `InventoryGui/Layout_Desktop/QuickSlots/Slot_2/Count` | TextLabel | lu par `InventoryController` |  |  |
| `InventoryGui/Layout_Desktop/QuickSlots/Slot_2/Key` | TextLabel | lu par `InventoryController` |  |  |
| `InventoryGui/Layout_Desktop/QuickSlots/Slot_2/Selected` | Frame | lu par `InventoryController` |  |  |
| `InventoryGui/Layout_Desktop/QuickSlots/Slot_3` | Frame | lu par `InventoryController` |  |  |
| `InventoryGui/Layout_Desktop/QuickSlots/Slot_3/Icon` | ImageLabel | lu par `InventoryController` |  |  |
| `InventoryGui/Layout_Desktop/QuickSlots/Slot_3/Count` | TextLabel | lu par `InventoryController` |  |  |
| `InventoryGui/Layout_Desktop/QuickSlots/Slot_3/Key` | TextLabel | lu par `InventoryController` |  |  |
| `InventoryGui/Layout_Desktop/QuickSlots/Slot_3/Selected` | Frame | lu par `InventoryController` |  |  |
| `InventoryGui/Layout_Desktop/QuickSlots/Slot_4` | Frame | lu par `InventoryController` |  |  |
| `InventoryGui/Layout_Desktop/QuickSlots/Slot_4/Icon` | ImageLabel | lu par `InventoryController` |  |  |
| `InventoryGui/Layout_Desktop/QuickSlots/Slot_4/Count` | TextLabel | lu par `InventoryController` |  |  |
| `InventoryGui/Layout_Desktop/QuickSlots/Slot_4/Key` | TextLabel | lu par `InventoryController` |  |  |
| `InventoryGui/Layout_Desktop/QuickSlots/Slot_4/Selected` | Frame | lu par `InventoryController` |  |  |
| `InventoryGui/Layout_Desktop/Bag` | Frame | lu par `InventoryController` |  |  |
| `InventoryGui/Layout_Desktop/Bag/Weight` | TextLabel | lu par `InventoryController` |  |  |
| `InventoryGui/Layout_Desktop/Bag/Close` | TextButton | lu par `InventoryController` | Fermer |  |
| `InventoryGui/Layout_Desktop/Bag/List` | ScrollingFrame | lu par `InventoryController` |  |  |
| `InventoryGui/Layout_Desktop/Bag/List/Template` | Frame | lu par `InventoryController` |  |  |
| `InventoryGui/Layout_Desktop/Bag/List/Template/Icon` | ImageLabel | lu par `InventoryController` |  |  |
| `InventoryGui/Layout_Desktop/Bag/List/Template/Name` | TextLabel | lu par `InventoryController` |  |  |
| `InventoryGui/Layout_Desktop/Bag/List/Template/Count` | TextLabel | lu par `InventoryController` |  |  |
| `InventoryGui/Layout_Desktop/Bag/List/Template/Drop` | TextButton | lu par `InventoryController` | Jeter |  |
| `InventoryGui/Layout_Touch` | Frame | lu par `InventoryController` |  | 15.7 : disposition choisie par Util.prepareGui (UserInputService.TouchEnabled) |
| `InventoryGui/Layout_Touch/QuickSlots` | Frame | lu par `InventoryController` |  |  |
| `InventoryGui/Layout_Touch/QuickSlots/Slot_1` | Frame | lu par `InventoryController` |  |  |
| `InventoryGui/Layout_Touch/QuickSlots/Slot_1/Icon` | ImageLabel | lu par `InventoryController` |  |  |
| `InventoryGui/Layout_Touch/QuickSlots/Slot_1/Count` | TextLabel | lu par `InventoryController` |  |  |
| `InventoryGui/Layout_Touch/QuickSlots/Slot_1/Key` | TextLabel | lu par `InventoryController` |  |  |
| `InventoryGui/Layout_Touch/QuickSlots/Slot_1/Selected` | Frame | lu par `InventoryController` |  |  |
| `InventoryGui/Layout_Touch/QuickSlots/Slot_2` | Frame | lu par `InventoryController` |  |  |
| `InventoryGui/Layout_Touch/QuickSlots/Slot_2/Icon` | ImageLabel | lu par `InventoryController` |  |  |
| `InventoryGui/Layout_Touch/QuickSlots/Slot_2/Count` | TextLabel | lu par `InventoryController` |  |  |
| `InventoryGui/Layout_Touch/QuickSlots/Slot_2/Key` | TextLabel | lu par `InventoryController` |  |  |
| `InventoryGui/Layout_Touch/QuickSlots/Slot_2/Selected` | Frame | lu par `InventoryController` |  |  |
| `InventoryGui/Layout_Touch/QuickSlots/Slot_3` | Frame | lu par `InventoryController` |  |  |
| `InventoryGui/Layout_Touch/QuickSlots/Slot_3/Icon` | ImageLabel | lu par `InventoryController` |  |  |
| `InventoryGui/Layout_Touch/QuickSlots/Slot_3/Count` | TextLabel | lu par `InventoryController` |  |  |
| `InventoryGui/Layout_Touch/QuickSlots/Slot_3/Key` | TextLabel | lu par `InventoryController` |  |  |
| `InventoryGui/Layout_Touch/QuickSlots/Slot_3/Selected` | Frame | lu par `InventoryController` |  |  |
| `InventoryGui/Layout_Touch/QuickSlots/Slot_4` | Frame | lu par `InventoryController` |  |  |
| `InventoryGui/Layout_Touch/QuickSlots/Slot_4/Icon` | ImageLabel | lu par `InventoryController` |  |  |
| `InventoryGui/Layout_Touch/QuickSlots/Slot_4/Count` | TextLabel | lu par `InventoryController` |  |  |
| `InventoryGui/Layout_Touch/QuickSlots/Slot_4/Key` | TextLabel | lu par `InventoryController` |  |  |
| `InventoryGui/Layout_Touch/QuickSlots/Slot_4/Selected` | Frame | lu par `InventoryController` |  |  |
| `InventoryGui/Layout_Touch/Bag` | Frame | lu par `InventoryController` |  |  |
| `InventoryGui/Layout_Touch/Bag/Weight` | TextLabel | lu par `InventoryController` |  |  |
| `InventoryGui/Layout_Touch/Bag/Close` | TextButton | lu par `InventoryController` | Fermer |  |
| `InventoryGui/Layout_Touch/Bag/List` | ScrollingFrame | lu par `InventoryController` |  |  |
| `InventoryGui/Layout_Touch/Bag/List/Template` | Frame | lu par `InventoryController` |  |  |
| `InventoryGui/Layout_Touch/Bag/List/Template/Icon` | ImageLabel | lu par `InventoryController` |  |  |
| `InventoryGui/Layout_Touch/Bag/List/Template/Name` | TextLabel | lu par `InventoryController` |  |  |
| `InventoryGui/Layout_Touch/Bag/List/Template/Count` | TextLabel | lu par `InventoryController` |  |  |
| `InventoryGui/Layout_Touch/Bag/List/Template/Drop` | TextButton | lu par `InventoryController` | Jeter |  |

### ObjectiveGui — StarterGui (Partie), section 15.4

Lu par `ObjectiveController`.

| Chemin | Classe | Statut | Texte de départ | Remarque |
| --- | --- | --- | --- | --- |
| `ObjectiveGui` | ScreenGui | lu par `ObjectiveController` |  |  |
| `ObjectiveGui/Layout_Desktop` | Frame | lu par `ObjectiveController` |  | 15.7 : disposition choisie par Util.prepareGui (UserInputService.TouchEnabled) |
| `ObjectiveGui/Layout_Desktop/ActName` | TextLabel | lu par `ObjectiveController` |  |  |
| `ObjectiveGui/Layout_Desktop/ObjectiveText` | TextLabel | lu par `ObjectiveController` |  |  |
| `ObjectiveGui/Layout_Desktop/Clock` | TextLabel | lu par `ObjectiveController` |  |  |
| `ObjectiveGui/Layout_Touch` | Frame | lu par `ObjectiveController` |  | 15.7 : disposition choisie par Util.prepareGui (UserInputService.TouchEnabled) |
| `ObjectiveGui/Layout_Touch/ActName` | TextLabel | lu par `ObjectiveController` |  |  |
| `ObjectiveGui/Layout_Touch/ObjectiveText` | TextLabel | lu par `ObjectiveController` |  |  |
| `ObjectiveGui/Layout_Touch/Clock` | TextLabel | lu par `ObjectiveController` |  |  |

### InteractGui — StarterGui (Partie), section 15.4

Lu par `InteractController`.

| Chemin | Classe | Statut | Texte de départ | Remarque |
| --- | --- | --- | --- | --- |
| `InteractGui` | ScreenGui | lu par `InteractController` |  |  |
| `InteractGui/Layout_Desktop` | Frame | lu par `InteractController` |  | 15.7 : disposition choisie par Util.prepareGui (UserInputService.TouchEnabled) |
| `InteractGui/Layout_Desktop/Prompt` | Frame | lu par `InteractController` |  |  |
| `InteractGui/Layout_Desktop/Prompt/KeyHint` | TextLabel | lu par `InteractController` |  |  |
| `InteractGui/Layout_Desktop/Prompt/ActionText` | TextLabel | lu par `InteractController` |  |  |
| `InteractGui/Layout_Desktop/Prompt/Progress` | Frame | lu par `InteractController` |  |  |
| `InteractGui/Layout_Desktop/Prompt/Progress/Fill` | Frame | lu par `InteractController` |  |  |
| `InteractGui/Layout_Touch` | Frame | lu par `InteractController` |  | 15.7 : disposition choisie par Util.prepareGui (UserInputService.TouchEnabled) |
| `InteractGui/Layout_Touch/Prompt` | Frame | lu par `InteractController` |  |  |
| `InteractGui/Layout_Touch/Prompt/KeyHint` | TextLabel | lu par `InteractController` |  |  |
| `InteractGui/Layout_Touch/Prompt/ActionText` | TextLabel | lu par `InteractController` |  |  |
| `InteractGui/Layout_Touch/Prompt/Progress` | Frame | lu par `InteractController` |  |  |
| `InteractGui/Layout_Touch/Prompt/Progress/Fill` | Frame | lu par `InteractController` |  |  |

### TabletGui — StarterGui (Partie), section 15.4

Lu par `TabletController`.

| Chemin | Classe | Statut | Texte de départ | Remarque |
| --- | --- | --- | --- | --- |
| `TabletGui` | ScreenGui | lu par `TabletController` |  |  |
| `TabletGui/Layout_Desktop` | Frame | lu par `TabletController` |  | 15.7 : disposition choisie par Util.prepareGui (UserInputService.TouchEnabled) |
| `TabletGui/Layout_Desktop/Device` | Frame | lu par `TabletController` |  |  |
| `TabletGui/Layout_Desktop/Device/Screen` | Frame | lu par `TabletController` |  |  |
| `TabletGui/Layout_Desktop/Device/Screen/AppBar` | Frame | lu par `TabletController` |  |  |
| `TabletGui/Layout_Desktop/Device/Screen/AppBar/Btn_Map` | TextButton | lu par `TabletController` | Carte |  |
| `TabletGui/Layout_Desktop/Device/Screen/AppBar/Btn_Objectives` | TextButton | lu par `TabletController` | Objectifs |  |
| `TabletGui/Layout_Desktop/Device/Screen/AppBar/Btn_Journal` | TextButton | lu par `TabletController` | Journal |  |
| `TabletGui/Layout_Desktop/Device/Screen/AppBar/Btn_Evidence` | TextButton | lu par `TabletController` | Preuves |  |
| `TabletGui/Layout_Desktop/Device/Screen/AppBar/Btn_Network` | TextButton | lu par `TabletController` | Réseau |  |
| `TabletGui/Layout_Desktop/Device/Screen/Pages` | Frame | lu par `TabletController` |  |  |
| `TabletGui/Layout_Desktop/Device/Screen/Pages/Page_Map` | Frame | lu par `TabletController` |  |  |
| `TabletGui/Layout_Desktop/Device/Screen/Pages/Page_Map/MapImage` | ImageLabel | lu par `TabletController` |  | Img_TabletMap (13.5) : image à créer |
| `TabletGui/Layout_Desktop/Device/Screen/Pages/Page_Map/TunnelLayer` | ImageLabel | lu par `TabletController` |  | couche « tunnels » après DOC_07 : image à créer |
| `TabletGui/Layout_Desktop/Device/Screen/Pages/Page_Map/Markers` | Frame | lu par `TabletController` |  |  |
| `TabletGui/Layout_Desktop/Device/Screen/Pages/Page_Map/Markers/Template` | Frame | lu par `TabletController` |  |  |
| `TabletGui/Layout_Desktop/Device/Screen/Pages/Page_Map/PlayerDot` | Frame | lu par `TabletController` |  |  |
| `TabletGui/Layout_Desktop/Device/Screen/Pages/Page_Map/NoSignal` | TextLabel | lu par `TabletController` | Pas de signal GPS |  |
| `TabletGui/Layout_Desktop/Device/Screen/Pages/Page_Objectives` | Frame | lu par `TabletController` |  |  |
| `TabletGui/Layout_Desktop/Device/Screen/Pages/Page_Objectives/List` | ScrollingFrame | lu par `TabletController` |  |  |
| `TabletGui/Layout_Desktop/Device/Screen/Pages/Page_Objectives/List/Template` | TextLabel | lu par `TabletController` |  |  |
| `TabletGui/Layout_Desktop/Device/Screen/Pages/Page_Journal` | Frame | lu par `TabletController` |  |  |
| `TabletGui/Layout_Desktop/Device/Screen/Pages/Page_Journal/List` | ScrollingFrame | lu par `TabletController` |  |  |
| `TabletGui/Layout_Desktop/Device/Screen/Pages/Page_Journal/List/Template` | TextButton | lu par `TabletController` |  |  |
| `TabletGui/Layout_Desktop/Device/Screen/Pages/Page_Journal/Reader` | Frame | lu par `TabletController` |  |  |
| `TabletGui/Layout_Desktop/Device/Screen/Pages/Page_Journal/Reader/Title` | TextLabel | lu par `TabletController` |  |  |
| `TabletGui/Layout_Desktop/Device/Screen/Pages/Page_Journal/Reader/Body` | TextLabel | lu par `TabletController` |  |  |
| `TabletGui/Layout_Desktop/Device/Screen/Pages/Page_Evidence` | Frame | lu par `TabletController` |  |  |
| `TabletGui/Layout_Desktop/Device/Screen/Pages/Page_Evidence/List` | ScrollingFrame | lu par `TabletController` |  |  |
| `TabletGui/Layout_Desktop/Device/Screen/Pages/Page_Evidence/List/Template` | TextLabel | lu par `TabletController` |  |  |
| `TabletGui/Layout_Desktop/Device/Screen/Pages/Page_Network` | Frame | lu par `TabletController` |  |  |
| `TabletGui/Layout_Desktop/Device/Screen/Pages/Page_Network/Bars` | Frame | lu par `TabletController` |  | barres de réseau : Fill.Size.X.Scale = niveau |
| `TabletGui/Layout_Desktop/Device/Screen/Pages/Page_Network/Bars/Fill` | Frame | lu par `TabletController` |  |  |
| `TabletGui/Layout_Desktop/Device/Screen/Pages/Page_Network/Message` | TextLabel | lu par `TabletController` | Aucun réseau |  |
| `TabletGui/Layout_Desktop/Device/Screen/Pages/Page_Network/Send` | TextButton | lu par `TabletController` | Envoyer |  |
| `TabletGui/Layout_Desktop/Device/BatteryText` | TextLabel | lu par `TabletController` |  |  |
| `TabletGui/Layout_Desktop/Device/Close` | TextButton | lu par `TabletController` | Fermer |  |
| `TabletGui/Layout_Touch` | Frame | lu par `TabletController` |  | 15.7 : disposition choisie par Util.prepareGui (UserInputService.TouchEnabled) |
| `TabletGui/Layout_Touch/Device` | Frame | lu par `TabletController` |  |  |
| `TabletGui/Layout_Touch/Device/Screen` | Frame | lu par `TabletController` |  |  |
| `TabletGui/Layout_Touch/Device/Screen/AppBar` | Frame | lu par `TabletController` |  |  |
| `TabletGui/Layout_Touch/Device/Screen/AppBar/Btn_Map` | TextButton | lu par `TabletController` | Carte |  |
| `TabletGui/Layout_Touch/Device/Screen/AppBar/Btn_Objectives` | TextButton | lu par `TabletController` | Objectifs |  |
| `TabletGui/Layout_Touch/Device/Screen/AppBar/Btn_Journal` | TextButton | lu par `TabletController` | Journal |  |
| `TabletGui/Layout_Touch/Device/Screen/AppBar/Btn_Evidence` | TextButton | lu par `TabletController` | Preuves |  |
| `TabletGui/Layout_Touch/Device/Screen/AppBar/Btn_Network` | TextButton | lu par `TabletController` | Réseau |  |
| `TabletGui/Layout_Touch/Device/Screen/Pages` | Frame | lu par `TabletController` |  |  |
| `TabletGui/Layout_Touch/Device/Screen/Pages/Page_Map` | Frame | lu par `TabletController` |  |  |
| `TabletGui/Layout_Touch/Device/Screen/Pages/Page_Map/MapImage` | ImageLabel | lu par `TabletController` |  | Img_TabletMap (13.5) : image à créer |
| `TabletGui/Layout_Touch/Device/Screen/Pages/Page_Map/TunnelLayer` | ImageLabel | lu par `TabletController` |  | couche « tunnels » après DOC_07 : image à créer |
| `TabletGui/Layout_Touch/Device/Screen/Pages/Page_Map/Markers` | Frame | lu par `TabletController` |  |  |
| `TabletGui/Layout_Touch/Device/Screen/Pages/Page_Map/Markers/Template` | Frame | lu par `TabletController` |  |  |
| `TabletGui/Layout_Touch/Device/Screen/Pages/Page_Map/PlayerDot` | Frame | lu par `TabletController` |  |  |
| `TabletGui/Layout_Touch/Device/Screen/Pages/Page_Map/NoSignal` | TextLabel | lu par `TabletController` | Pas de signal GPS |  |
| `TabletGui/Layout_Touch/Device/Screen/Pages/Page_Objectives` | Frame | lu par `TabletController` |  |  |
| `TabletGui/Layout_Touch/Device/Screen/Pages/Page_Objectives/List` | ScrollingFrame | lu par `TabletController` |  |  |
| `TabletGui/Layout_Touch/Device/Screen/Pages/Page_Objectives/List/Template` | TextLabel | lu par `TabletController` |  |  |
| `TabletGui/Layout_Touch/Device/Screen/Pages/Page_Journal` | Frame | lu par `TabletController` |  |  |
| `TabletGui/Layout_Touch/Device/Screen/Pages/Page_Journal/List` | ScrollingFrame | lu par `TabletController` |  |  |
| `TabletGui/Layout_Touch/Device/Screen/Pages/Page_Journal/List/Template` | TextButton | lu par `TabletController` |  |  |
| `TabletGui/Layout_Touch/Device/Screen/Pages/Page_Journal/Reader` | Frame | lu par `TabletController` |  |  |
| `TabletGui/Layout_Touch/Device/Screen/Pages/Page_Journal/Reader/Title` | TextLabel | lu par `TabletController` |  |  |
| `TabletGui/Layout_Touch/Device/Screen/Pages/Page_Journal/Reader/Body` | TextLabel | lu par `TabletController` |  |  |
| `TabletGui/Layout_Touch/Device/Screen/Pages/Page_Evidence` | Frame | lu par `TabletController` |  |  |
| `TabletGui/Layout_Touch/Device/Screen/Pages/Page_Evidence/List` | ScrollingFrame | lu par `TabletController` |  |  |
| `TabletGui/Layout_Touch/Device/Screen/Pages/Page_Evidence/List/Template` | TextLabel | lu par `TabletController` |  |  |
| `TabletGui/Layout_Touch/Device/Screen/Pages/Page_Network` | Frame | lu par `TabletController` |  |  |
| `TabletGui/Layout_Touch/Device/Screen/Pages/Page_Network/Bars` | Frame | lu par `TabletController` |  | barres de réseau : Fill.Size.X.Scale = niveau |
| `TabletGui/Layout_Touch/Device/Screen/Pages/Page_Network/Bars/Fill` | Frame | lu par `TabletController` |  |  |
| `TabletGui/Layout_Touch/Device/Screen/Pages/Page_Network/Message` | TextLabel | lu par `TabletController` | Aucun réseau |  |
| `TabletGui/Layout_Touch/Device/Screen/Pages/Page_Network/Send` | TextButton | lu par `TabletController` | Envoyer |  |
| `TabletGui/Layout_Touch/Device/BatteryText` | TextLabel | lu par `TabletController` |  |  |
| `TabletGui/Layout_Touch/Device/Close` | TextButton | lu par `TabletController` | Fermer |  |

### DocumentGui — StarterGui (Partie), section 15.4

Lu par `DocumentController`.

| Chemin | Classe | Statut | Texte de départ | Remarque |
| --- | --- | --- | --- | --- |
| `DocumentGui` | ScreenGui | lu par `DocumentController` |  |  |
| `DocumentGui/Layout_Desktop` | Frame | lu par `DocumentController` |  | 15.7 : disposition choisie par Util.prepareGui (UserInputService.TouchEnabled) |
| `DocumentGui/Layout_Desktop/Veil` | Frame | lu par `DocumentController` |  | voile 60 % : visible avec Paper, Tape (attribut veilFor) |
| `DocumentGui/Layout_Desktop/Paper` | Frame | lu par `DocumentController` |  |  |
| `DocumentGui/Layout_Desktop/Paper/Title` | TextLabel | lu par `DocumentController` |  |  |
| `DocumentGui/Layout_Desktop/Paper/Close` | TextButton | lu par `DocumentController` | Fermer |  |
| `DocumentGui/Layout_Desktop/Paper/Picture` | ImageLabel | lu par `DocumentController` |  |  |
| `DocumentGui/Layout_Desktop/Paper/Body` | TextLabel | lu par `DocumentController` |  |  |
| `DocumentGui/Layout_Desktop/Tape` | Frame | lu par `DocumentController` |  |  |
| `DocumentGui/Layout_Desktop/Tape/Label` | TextLabel | lu par `DocumentController` |  |  |
| `DocumentGui/Layout_Desktop/Tape/Play` | TextButton | lu par `DocumentController` | Lire |  |
| `DocumentGui/Layout_Desktop/Tape/Progress` | Frame | lu par `DocumentController` |  |  |
| `DocumentGui/Layout_Desktop/Tape/Progress/Fill` | Frame | lu par `DocumentController` |  |  |
| `DocumentGui/Layout_Touch` | Frame | lu par `DocumentController` |  | 15.7 : disposition choisie par Util.prepareGui (UserInputService.TouchEnabled) |
| `DocumentGui/Layout_Touch/Veil` | Frame | lu par `DocumentController` |  | voile 60 % : visible avec Paper, Tape (attribut veilFor) |
| `DocumentGui/Layout_Touch/Paper` | Frame | lu par `DocumentController` |  |  |
| `DocumentGui/Layout_Touch/Paper/Title` | TextLabel | lu par `DocumentController` |  |  |
| `DocumentGui/Layout_Touch/Paper/Close` | TextButton | lu par `DocumentController` | Fermer |  |
| `DocumentGui/Layout_Touch/Paper/Picture` | ImageLabel | lu par `DocumentController` |  |  |
| `DocumentGui/Layout_Touch/Paper/Body` | TextLabel | lu par `DocumentController` |  |  |
| `DocumentGui/Layout_Touch/Tape` | Frame | lu par `DocumentController` |  |  |
| `DocumentGui/Layout_Touch/Tape/Label` | TextLabel | lu par `DocumentController` |  |  |
| `DocumentGui/Layout_Touch/Tape/Play` | TextButton | lu par `DocumentController` | Lire |  |
| `DocumentGui/Layout_Touch/Tape/Progress` | Frame | lu par `DocumentController` |  |  |
| `DocumentGui/Layout_Touch/Tape/Progress/Fill` | Frame | lu par `DocumentController` |  |  |

### DownedGui — StarterGui (Partie), section 15.4

Lu par `DownedController`.

| Chemin | Classe | Statut | Texte de départ | Remarque |
| --- | --- | --- | --- | --- |
| `DownedGui` | ScreenGui | lu par `DownedController` |  |  |
| `DownedGui/Layout_Desktop` | Frame | lu par `DownedController` |  | 15.7 : disposition choisie par Util.prepareGui (UserInputService.TouchEnabled) |
| `DownedGui/Layout_Desktop/Countdown` | TextLabel | lu par `DownedController` |  |  |
| `DownedGui/Layout_Desktop/HelpHint` | TextLabel | lu par `DownedController` | Appelle à l'aide : un coéquipier peut te relever. |  |
| `DownedGui/Layout_Desktop/Bleed` | Frame | lu par `DownedController` |  |  |
| `DownedGui/Layout_Desktop/Bleed/Fill` | Frame | lu par `DownedController` |  |  |
| `DownedGui/Layout_Touch` | Frame | lu par `DownedController` |  | 15.7 : disposition choisie par Util.prepareGui (UserInputService.TouchEnabled) |
| `DownedGui/Layout_Touch/Countdown` | TextLabel | lu par `DownedController` |  |  |
| `DownedGui/Layout_Touch/HelpHint` | TextLabel | lu par `DownedController` | Appelle à l'aide : un coéquipier peut te relever. |  |
| `DownedGui/Layout_Touch/Bleed` | Frame | lu par `DownedController` |  |  |
| `DownedGui/Layout_Touch/Bleed/Fill` | Frame | lu par `DownedController` |  |  |

### SpectatorGui — StarterGui (Partie), section 15.4

Lu par `SpectatorController`.

| Chemin | Classe | Statut | Texte de départ | Remarque |
| --- | --- | --- | --- | --- |
| `SpectatorGui` | ScreenGui | lu par `SpectatorController` |  |  |
| `SpectatorGui/Layout_Desktop` | Frame | lu par `SpectatorController` |  | 15.7 : disposition choisie par Util.prepareGui (UserInputService.TouchEnabled) |
| `SpectatorGui/Layout_Desktop/Watching` | TextLabel | lu par `SpectatorController` |  |  |
| `SpectatorGui/Layout_Desktop/Prev` | TextButton | lu par `SpectatorController` | Précédent |  |
| `SpectatorGui/Layout_Desktop/Next` | TextButton | lu par `SpectatorController` | Suivant |  |
| `SpectatorGui/Layout_Desktop/Note` | TextLabel | lu par `SpectatorController` | Tu es mort. Tu peux encore suivre ton groupe. |  |
| `SpectatorGui/Layout_Touch` | Frame | lu par `SpectatorController` |  | 15.7 : disposition choisie par Util.prepareGui (UserInputService.TouchEnabled) |
| `SpectatorGui/Layout_Touch/Watching` | TextLabel | lu par `SpectatorController` |  |  |
| `SpectatorGui/Layout_Touch/Prev` | TextButton | lu par `SpectatorController` | Précédent |  |
| `SpectatorGui/Layout_Touch/Next` | TextButton | lu par `SpectatorController` | Suivant |  |
| `SpectatorGui/Layout_Touch/Note` | TextLabel | lu par `SpectatorController` | Tu es mort. Tu peux encore suivre ton groupe. |  |

### RadioGui — StarterGui (Partie), section 15.4

Lu par `RadioController`.

| Chemin | Classe | Statut | Texte de départ | Remarque |
| --- | --- | --- | --- | --- |
| `RadioGui` | ScreenGui | lu par `RadioController` |  |  |
| `RadioGui/Layout_Desktop` | Frame | lu par `RadioController` |  | 15.7 : disposition choisie par Util.prepareGui (UserInputService.TouchEnabled) |
| `RadioGui/Layout_Desktop/Channel` | TextLabel | lu par `RadioController` |  |  |
| `RadioGui/Layout_Desktop/Talking` | Frame | lu par `RadioController` |  |  |
| `RadioGui/Layout_Desktop/Static` | Frame | lu par `RadioController` |  |  |
| `RadioGui/Layout_Touch` | Frame | lu par `RadioController` |  | 15.7 : disposition choisie par Util.prepareGui (UserInputService.TouchEnabled) |
| `RadioGui/Layout_Touch/Channel` | TextLabel | lu par `RadioController` |  |  |
| `RadioGui/Layout_Touch/Talking` | Frame | lu par `RadioController` |  |  |
| `RadioGui/Layout_Touch/Static` | Frame | lu par `RadioController` |  |  |

### MobileControlsGui — StarterGui (Partie), section 15.4

Lu par `InputController`.

| Chemin | Classe | Statut | Texte de départ | Remarque |
| --- | --- | --- | --- | --- |
| `MobileControlsGui` | ScreenGui | lu par `InputController` |  |  |
| `MobileControlsGui/Layout_Touch` | Frame | lu par `InputController` |  | 15.7 : écran tactile seulement ; 2 rangées de 3 boutons |
| `MobileControlsGui/Layout_Touch/Interact` | ImageButton | lu par `InputController` |  | Icon_Ctrl_Interact (13.5) |
| `MobileControlsGui/Layout_Touch/Fire` | ImageButton | lu par `InputController` |  | Icon_Ctrl_Fire (13.5) |
| `MobileControlsGui/Layout_Touch/Aim` | ImageButton | lu par `InputController` |  | Icon_Ctrl_Aim (13.5) |
| `MobileControlsGui/Layout_Touch/Reload` | ImageButton | lu par `InputController` |  | Icon_Ctrl_Reload (13.5) |
| `MobileControlsGui/Layout_Touch/Sprint` | ImageButton | lu par `InputController` |  | Icon_Ctrl_Sprint (13.5) |
| `MobileControlsGui/Layout_Touch/Crouch` | ImageButton | lu par `InputController` |  | Icon_Ctrl_Crouch (13.5) |
| `MobileControlsGui/Layout_Touch/Prone` | ImageButton | lu par `InputController` |  | Icon_Ctrl_Prone (13.5) |
| `MobileControlsGui/Layout_Touch/LeanL` | ImageButton | lu par `InputController` |  | Icon_Ctrl_LeanL (13.5) |
| `MobileControlsGui/Layout_Touch/LeanR` | ImageButton | lu par `InputController` |  | Icon_Ctrl_LeanR (13.5) |
| `MobileControlsGui/Layout_Touch/Light` | ImageButton | lu par `InputController` |  | Icon_Ctrl_Light (13.5) |
| `MobileControlsGui/Layout_Touch/Tablet` | ImageButton | lu par `InputController` |  | Icon_Ctrl_Tablet (13.5) |
| `MobileControlsGui/Layout_Touch/Ping` | ImageButton | lu par `InputController` |  | Icon_Ctrl_Ping (13.5) |

### NotificationGui — StarterGui (Partie), section 15.4

Lu par `NotificationController`.

| Chemin | Classe | Statut | Texte de départ | Remarque |
| --- | --- | --- | --- | --- |
| `NotificationGui` | ScreenGui | lu par `NotificationController` |  |  |
| `NotificationGui/Layout_Desktop` | Frame | lu par `NotificationController` |  | 15.7 : disposition choisie par Util.prepareGui (UserInputService.TouchEnabled) |
| `NotificationGui/Layout_Desktop/Stack` | Frame | lu par `NotificationController` |  |  |
| `NotificationGui/Layout_Desktop/Stack/Template` | Frame | lu par `NotificationController` |  |  |
| `NotificationGui/Layout_Desktop/Stack/Template/Text` | TextLabel | lu par `NotificationController` |  |  |
| `NotificationGui/Layout_Touch` | Frame | lu par `NotificationController` |  | 15.7 : disposition choisie par Util.prepareGui (UserInputService.TouchEnabled) |
| `NotificationGui/Layout_Touch/Stack` | Frame | lu par `NotificationController` |  |  |
| `NotificationGui/Layout_Touch/Stack/Template` | Frame | lu par `NotificationController` |  |  |
| `NotificationGui/Layout_Touch/Stack/Template/Text` | TextLabel | lu par `NotificationController` |  |  |

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
| `SettingsGui/Layout_Desktop` | Frame | lu par `SettingsController` |  | 15.7 : disposition choisie par Util.prepareGui (UserInputService.TouchEnabled) |
| `SettingsGui/Layout_Desktop/Veil` | Frame | lu par `SettingsController` |  | voile 60 % : visible avec Window (attribut veilFor) |
| `SettingsGui/Layout_Desktop/Window` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Desktop/Window/Tabs` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Desktop/Window/Tabs/Graphics` | TextButton | lu par `SettingsController` | Graphismes |  |
| `SettingsGui/Layout_Desktop/Window/Tabs/Controls` | TextButton | lu par `SettingsController` | Contrôles |  |
| `SettingsGui/Layout_Desktop/Window/Tabs/Audio` | TextButton | lu par `SettingsController` | Audio |  |
| `SettingsGui/Layout_Desktop/Window/Tabs/Accessibility` | TextButton | lu par `SettingsController` | Accessibilité |  |
| `SettingsGui/Layout_Desktop/Window/Pages` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Graphics` | ScrollingFrame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Graphics/Preset` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Layout_Desktop/Window/Pages/Graphics/Preset/Label` | TextLabel | décoratif | Préréglage |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Graphics/Preset/Options` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Graphics/Preset/Options/Opt_Low` | TextButton | lu par `SettingsController` | Bas |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Graphics/Preset/Options/Opt_Medium` | TextButton | lu par `SettingsController` | Moyen |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Graphics/Preset/Options/Opt_High` | TextButton | lu par `SettingsController` | Élevé |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Graphics/Preset/Options/Opt_Ultra` | TextButton | lu par `SettingsController` | Ultra |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Graphics/Brightness` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Layout_Desktop/Window/Pages/Graphics/Brightness/Label` | TextLabel | décoratif | Luminosité (gamma) |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Graphics/Brightness/Slider` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Graphics/Brightness/Slider/Track` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Graphics/Brightness/Slider/Track/Fill` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Graphics/Brightness/Value` | TextLabel | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Graphics/Calibration` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Layout_Desktop/Window/Pages/Graphics/Calibration/Symbol` | Frame | lu par `SettingsController` |  | symbole de calibrage (17.2) |
| `SettingsGui/Layout_Desktop/Window/Pages/Graphics/Calibration/Label` | TextLabel | décoratif | le symbole doit être à peine visible |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Graphics/ViewDistance` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Layout_Desktop/Window/Pages/Graphics/ViewDistance/Label` | TextLabel | décoratif | Distance d'affichage du décor |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Graphics/ViewDistance/Options` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Graphics/ViewDistance/Options/Opt_25` | TextButton | lu par `SettingsController` | 25 % |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Graphics/ViewDistance/Options/Opt_50` | TextButton | lu par `SettingsController` | 50 % |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Graphics/ViewDistance/Options/Opt_75` | TextButton | lu par `SettingsController` | 75 % |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Graphics/ViewDistance/Options/Opt_100` | TextButton | lu par `SettingsController` | 100 % |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Graphics/VegetationDensity` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Layout_Desktop/Window/Pages/Graphics/VegetationDensity/Label` | TextLabel | décoratif | Densité de végétation |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Graphics/VegetationDensity/Options` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Graphics/VegetationDensity/Options/Opt_25` | TextButton | lu par `SettingsController` | 25 % |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Graphics/VegetationDensity/Options/Opt_50` | TextButton | lu par `SettingsController` | 50 % |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Graphics/VegetationDensity/Options/Opt_75` | TextButton | lu par `SettingsController` | 75 % |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Graphics/VegetationDensity/Options/Opt_100` | TextButton | lu par `SettingsController` | 100 % |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Graphics/TreeWind` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Layout_Desktop/Window/Pages/Graphics/TreeWind/Label` | TextLabel | décoratif | Vent dans les arbres |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Graphics/TreeWind/Options` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Graphics/TreeWind/Options/Opt_Yes` | TextButton | lu par `SettingsController` | Oui |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Graphics/TreeWind/Options/Opt_No` | TextButton | lu par `SettingsController` | Non |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Graphics/LampShadows` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Layout_Desktop/Window/Pages/Graphics/LampShadows/Label` | TextLabel | décoratif | Ombres des lampes |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Graphics/LampShadows/Options` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Graphics/LampShadows/Options/Opt_Yes` | TextButton | lu par `SettingsController` | Oui |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Graphics/LampShadows/Options/Opt_No` | TextButton | lu par `SettingsController` | Non |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Graphics/DepthOfField` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Layout_Desktop/Window/Pages/Graphics/DepthOfField/Label` | TextLabel | décoratif | Profondeur de champ, flou lumineux |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Graphics/DepthOfField/Options` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Graphics/DepthOfField/Options/Opt_Yes` | TextButton | lu par `SettingsController` | Oui |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Graphics/DepthOfField/Options/Opt_No` | TextButton | lu par `SettingsController` | Non |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Graphics/Particles` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Layout_Desktop/Window/Pages/Graphics/Particles/Label` | TextLabel | décoratif | Densité des particules (pluie, neige, cendre) |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Graphics/Particles/Options` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Graphics/Particles/Options/Opt_Low` | TextButton | lu par `SettingsController` | Faible |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Graphics/Particles/Options/Opt_Normal` | TextButton | lu par `SettingsController` | Normale |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Graphics/FieldOfView` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Layout_Desktop/Window/Pages/Graphics/FieldOfView/Label` | TextLabel | décoratif | Champ de vision |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Graphics/FieldOfView/Slider` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Graphics/FieldOfView/Slider/Track` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Graphics/FieldOfView/Slider/Track/Fill` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Graphics/FieldOfView/Value` | TextLabel | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Controls` | ScrollingFrame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Controls/Sensitivity` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Layout_Desktop/Window/Pages/Controls/Sensitivity/Label` | TextLabel | décoratif | Sensibilité |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Controls/Sensitivity/Slider` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Controls/Sensitivity/Slider/Track` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Controls/Sensitivity/Slider/Track/Fill` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Controls/Sensitivity/Value` | TextLabel | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Controls/InvertY` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Layout_Desktop/Window/Pages/Controls/InvertY/Label` | TextLabel | décoratif | Inverser l'axe vertical |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Controls/InvertY/Options` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Controls/InvertY/Options/Opt_Yes` | TextButton | lu par `SettingsController` | Oui |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Controls/InvertY/Options/Opt_No` | TextButton | lu par `SettingsController` | Non |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Controls/TouchButtonSize` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Layout_Desktop/Window/Pages/Controls/TouchButtonSize/Label` | TextLabel | décoratif | Taille des boutons tactiles |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Controls/TouchButtonSize/Slider` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Controls/TouchButtonSize/Slider/Track` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Controls/TouchButtonSize/Slider/Track/Fill` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Controls/TouchButtonSize/Value` | TextLabel | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Audio` | ScrollingFrame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Audio/Master` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Layout_Desktop/Window/Pages/Audio/Master/Label` | TextLabel | décoratif | Général |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Audio/Master/Slider` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Audio/Master/Slider/Track` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Audio/Master/Slider/Track/Fill` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Audio/Master/Value` | TextLabel | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Audio/Ambience` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Layout_Desktop/Window/Pages/Audio/Ambience/Label` | TextLabel | décoratif | Ambiance |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Audio/Ambience/Slider` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Audio/Ambience/Slider/Track` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Audio/Ambience/Slider/Track/Fill` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Audio/Ambience/Value` | TextLabel | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Audio/Voice` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Layout_Desktop/Window/Pages/Audio/Voice/Label` | TextLabel | décoratif | Voix |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Audio/Voice/Slider` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Audio/Voice/Slider/Track` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Audio/Voice/Slider/Track/Fill` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Audio/Voice/Value` | TextLabel | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Audio/Music` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Layout_Desktop/Window/Pages/Audio/Music/Label` | TextLabel | décoratif | Musique |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Audio/Music/Slider` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Audio/Music/Slider/Track` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Audio/Music/Slider/Track/Fill` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Audio/Music/Value` | TextLabel | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Audio/Effects` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Layout_Desktop/Window/Pages/Audio/Effects/Label` | TextLabel | décoratif | Effets |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Audio/Effects/Slider` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Audio/Effects/Slider/Track` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Audio/Effects/Slider/Track/Fill` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Audio/Effects/Value` | TextLabel | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Accessibility` | ScrollingFrame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Accessibility/Subtitles` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Layout_Desktop/Window/Pages/Accessibility/Subtitles/Label` | TextLabel | décoratif | Sous-titres |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Accessibility/Subtitles/Options` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Accessibility/Subtitles/Options/Opt_Yes` | TextButton | lu par `SettingsController` | Oui |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Accessibility/Subtitles/Options/Opt_No` | TextButton | lu par `SettingsController` | Non |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Accessibility/SubtitleSize` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Layout_Desktop/Window/Pages/Accessibility/SubtitleSize/Label` | TextLabel | décoratif | Taille |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Accessibility/SubtitleSize/Options` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Accessibility/SubtitleSize/Options/Opt_Small` | TextButton | lu par `SettingsController` | Petite |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Accessibility/SubtitleSize/Options/Opt_Medium` | TextButton | lu par `SettingsController` | Moyenne |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Accessibility/SubtitleSize/Options/Opt_Large` | TextButton | lu par `SettingsController` | Grande |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Accessibility/ReduceMotion` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Layout_Desktop/Window/Pages/Accessibility/ReduceMotion/Label` | TextLabel | décoratif | Réduire les mouvements (balancement de caméra) |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Accessibility/ReduceMotion/Options` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Accessibility/ReduceMotion/Options/Opt_Yes` | TextButton | lu par `SettingsController` | Oui |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Accessibility/ReduceMotion/Options/Opt_No` | TextButton | lu par `SettingsController` | Non |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Accessibility/ReducedGore` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Layout_Desktop/Window/Pages/Accessibility/ReducedGore/Label` | TextLabel | décoratif | Gore réduit |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Accessibility/ReducedGore/Options` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Accessibility/ReducedGore/Options/Opt_Yes` | TextButton | lu par `SettingsController` | Oui |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Accessibility/ReducedGore/Options/Opt_No` | TextButton | lu par `SettingsController` | Non |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Accessibility/Language` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Layout_Desktop/Window/Pages/Accessibility/Language/Label` | TextLabel | décoratif | Langue |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Accessibility/Language/Options` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Accessibility/Language/Options/Opt_French` | TextButton | lu par `SettingsController` | Français |  |
| `SettingsGui/Layout_Desktop/Window/Pages/Accessibility/Language/Options/Opt_English` | TextButton | lu par `SettingsController` | Anglais |  |
| `SettingsGui/Layout_Desktop/Window/Apply` | TextButton | lu par `SettingsController` | Appliquer |  |
| `SettingsGui/Layout_Desktop/Window/Reset` | TextButton | lu par `SettingsController` | Réinitialiser |  |
| `SettingsGui/Layout_Desktop/Window/Close` | TextButton | lu par `SettingsController` | Fermer |  |
| `SettingsGui/Layout_Touch` | Frame | lu par `SettingsController` |  | 15.7 : disposition choisie par Util.prepareGui (UserInputService.TouchEnabled) |
| `SettingsGui/Layout_Touch/Veil` | Frame | lu par `SettingsController` |  | voile 60 % : visible avec Window (attribut veilFor) |
| `SettingsGui/Layout_Touch/Window` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Touch/Window/Tabs` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Touch/Window/Tabs/Graphics` | TextButton | lu par `SettingsController` | Graphismes |  |
| `SettingsGui/Layout_Touch/Window/Tabs/Controls` | TextButton | lu par `SettingsController` | Contrôles |  |
| `SettingsGui/Layout_Touch/Window/Tabs/Audio` | TextButton | lu par `SettingsController` | Audio |  |
| `SettingsGui/Layout_Touch/Window/Tabs/Accessibility` | TextButton | lu par `SettingsController` | Accessibilité |  |
| `SettingsGui/Layout_Touch/Window/Pages` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Touch/Window/Pages/Graphics` | ScrollingFrame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Touch/Window/Pages/Graphics/Preset` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Layout_Touch/Window/Pages/Graphics/Preset/Label` | TextLabel | décoratif | Préréglage |  |
| `SettingsGui/Layout_Touch/Window/Pages/Graphics/Preset/Options` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Touch/Window/Pages/Graphics/Preset/Options/Opt_Low` | TextButton | lu par `SettingsController` | Bas |  |
| `SettingsGui/Layout_Touch/Window/Pages/Graphics/Preset/Options/Opt_Medium` | TextButton | lu par `SettingsController` | Moyen |  |
| `SettingsGui/Layout_Touch/Window/Pages/Graphics/Preset/Options/Opt_High` | TextButton | lu par `SettingsController` | Élevé |  |
| `SettingsGui/Layout_Touch/Window/Pages/Graphics/Preset/Options/Opt_Ultra` | TextButton | lu par `SettingsController` | Ultra |  |
| `SettingsGui/Layout_Touch/Window/Pages/Graphics/Brightness` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Layout_Touch/Window/Pages/Graphics/Brightness/Label` | TextLabel | décoratif | Luminosité (gamma) |  |
| `SettingsGui/Layout_Touch/Window/Pages/Graphics/Brightness/Slider` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Touch/Window/Pages/Graphics/Brightness/Slider/Track` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Touch/Window/Pages/Graphics/Brightness/Slider/Track/Fill` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Touch/Window/Pages/Graphics/Brightness/Value` | TextLabel | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Touch/Window/Pages/Graphics/Calibration` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Layout_Touch/Window/Pages/Graphics/Calibration/Symbol` | Frame | lu par `SettingsController` |  | symbole de calibrage (17.2) |
| `SettingsGui/Layout_Touch/Window/Pages/Graphics/Calibration/Label` | TextLabel | décoratif | le symbole doit être à peine visible |  |
| `SettingsGui/Layout_Touch/Window/Pages/Graphics/ViewDistance` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Layout_Touch/Window/Pages/Graphics/ViewDistance/Label` | TextLabel | décoratif | Distance d'affichage du décor |  |
| `SettingsGui/Layout_Touch/Window/Pages/Graphics/ViewDistance/Options` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Touch/Window/Pages/Graphics/ViewDistance/Options/Opt_25` | TextButton | lu par `SettingsController` | 25 % |  |
| `SettingsGui/Layout_Touch/Window/Pages/Graphics/ViewDistance/Options/Opt_50` | TextButton | lu par `SettingsController` | 50 % |  |
| `SettingsGui/Layout_Touch/Window/Pages/Graphics/ViewDistance/Options/Opt_75` | TextButton | lu par `SettingsController` | 75 % |  |
| `SettingsGui/Layout_Touch/Window/Pages/Graphics/ViewDistance/Options/Opt_100` | TextButton | lu par `SettingsController` | 100 % |  |
| `SettingsGui/Layout_Touch/Window/Pages/Graphics/VegetationDensity` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Layout_Touch/Window/Pages/Graphics/VegetationDensity/Label` | TextLabel | décoratif | Densité de végétation |  |
| `SettingsGui/Layout_Touch/Window/Pages/Graphics/VegetationDensity/Options` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Touch/Window/Pages/Graphics/VegetationDensity/Options/Opt_25` | TextButton | lu par `SettingsController` | 25 % |  |
| `SettingsGui/Layout_Touch/Window/Pages/Graphics/VegetationDensity/Options/Opt_50` | TextButton | lu par `SettingsController` | 50 % |  |
| `SettingsGui/Layout_Touch/Window/Pages/Graphics/VegetationDensity/Options/Opt_75` | TextButton | lu par `SettingsController` | 75 % |  |
| `SettingsGui/Layout_Touch/Window/Pages/Graphics/VegetationDensity/Options/Opt_100` | TextButton | lu par `SettingsController` | 100 % |  |
| `SettingsGui/Layout_Touch/Window/Pages/Graphics/TreeWind` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Layout_Touch/Window/Pages/Graphics/TreeWind/Label` | TextLabel | décoratif | Vent dans les arbres |  |
| `SettingsGui/Layout_Touch/Window/Pages/Graphics/TreeWind/Options` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Touch/Window/Pages/Graphics/TreeWind/Options/Opt_Yes` | TextButton | lu par `SettingsController` | Oui |  |
| `SettingsGui/Layout_Touch/Window/Pages/Graphics/TreeWind/Options/Opt_No` | TextButton | lu par `SettingsController` | Non |  |
| `SettingsGui/Layout_Touch/Window/Pages/Graphics/LampShadows` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Layout_Touch/Window/Pages/Graphics/LampShadows/Label` | TextLabel | décoratif | Ombres des lampes |  |
| `SettingsGui/Layout_Touch/Window/Pages/Graphics/LampShadows/Options` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Touch/Window/Pages/Graphics/LampShadows/Options/Opt_Yes` | TextButton | lu par `SettingsController` | Oui |  |
| `SettingsGui/Layout_Touch/Window/Pages/Graphics/LampShadows/Options/Opt_No` | TextButton | lu par `SettingsController` | Non |  |
| `SettingsGui/Layout_Touch/Window/Pages/Graphics/DepthOfField` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Layout_Touch/Window/Pages/Graphics/DepthOfField/Label` | TextLabel | décoratif | Profondeur de champ, flou lumineux |  |
| `SettingsGui/Layout_Touch/Window/Pages/Graphics/DepthOfField/Options` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Touch/Window/Pages/Graphics/DepthOfField/Options/Opt_Yes` | TextButton | lu par `SettingsController` | Oui |  |
| `SettingsGui/Layout_Touch/Window/Pages/Graphics/DepthOfField/Options/Opt_No` | TextButton | lu par `SettingsController` | Non |  |
| `SettingsGui/Layout_Touch/Window/Pages/Graphics/Particles` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Layout_Touch/Window/Pages/Graphics/Particles/Label` | TextLabel | décoratif | Densité des particules (pluie, neige, cendre) |  |
| `SettingsGui/Layout_Touch/Window/Pages/Graphics/Particles/Options` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Touch/Window/Pages/Graphics/Particles/Options/Opt_Low` | TextButton | lu par `SettingsController` | Faible |  |
| `SettingsGui/Layout_Touch/Window/Pages/Graphics/Particles/Options/Opt_Normal` | TextButton | lu par `SettingsController` | Normale |  |
| `SettingsGui/Layout_Touch/Window/Pages/Graphics/FieldOfView` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Layout_Touch/Window/Pages/Graphics/FieldOfView/Label` | TextLabel | décoratif | Champ de vision |  |
| `SettingsGui/Layout_Touch/Window/Pages/Graphics/FieldOfView/Slider` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Touch/Window/Pages/Graphics/FieldOfView/Slider/Track` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Touch/Window/Pages/Graphics/FieldOfView/Slider/Track/Fill` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Touch/Window/Pages/Graphics/FieldOfView/Value` | TextLabel | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Touch/Window/Pages/Controls` | ScrollingFrame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Touch/Window/Pages/Controls/Sensitivity` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Layout_Touch/Window/Pages/Controls/Sensitivity/Label` | TextLabel | décoratif | Sensibilité |  |
| `SettingsGui/Layout_Touch/Window/Pages/Controls/Sensitivity/Slider` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Touch/Window/Pages/Controls/Sensitivity/Slider/Track` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Touch/Window/Pages/Controls/Sensitivity/Slider/Track/Fill` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Touch/Window/Pages/Controls/Sensitivity/Value` | TextLabel | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Touch/Window/Pages/Controls/InvertY` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Layout_Touch/Window/Pages/Controls/InvertY/Label` | TextLabel | décoratif | Inverser l'axe vertical |  |
| `SettingsGui/Layout_Touch/Window/Pages/Controls/InvertY/Options` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Touch/Window/Pages/Controls/InvertY/Options/Opt_Yes` | TextButton | lu par `SettingsController` | Oui |  |
| `SettingsGui/Layout_Touch/Window/Pages/Controls/InvertY/Options/Opt_No` | TextButton | lu par `SettingsController` | Non |  |
| `SettingsGui/Layout_Touch/Window/Pages/Controls/TouchButtonSize` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Layout_Touch/Window/Pages/Controls/TouchButtonSize/Label` | TextLabel | décoratif | Taille des boutons tactiles |  |
| `SettingsGui/Layout_Touch/Window/Pages/Controls/TouchButtonSize/Slider` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Touch/Window/Pages/Controls/TouchButtonSize/Slider/Track` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Touch/Window/Pages/Controls/TouchButtonSize/Slider/Track/Fill` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Touch/Window/Pages/Controls/TouchButtonSize/Value` | TextLabel | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Touch/Window/Pages/Audio` | ScrollingFrame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Touch/Window/Pages/Audio/Master` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Layout_Touch/Window/Pages/Audio/Master/Label` | TextLabel | décoratif | Général |  |
| `SettingsGui/Layout_Touch/Window/Pages/Audio/Master/Slider` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Touch/Window/Pages/Audio/Master/Slider/Track` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Touch/Window/Pages/Audio/Master/Slider/Track/Fill` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Touch/Window/Pages/Audio/Master/Value` | TextLabel | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Touch/Window/Pages/Audio/Ambience` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Layout_Touch/Window/Pages/Audio/Ambience/Label` | TextLabel | décoratif | Ambiance |  |
| `SettingsGui/Layout_Touch/Window/Pages/Audio/Ambience/Slider` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Touch/Window/Pages/Audio/Ambience/Slider/Track` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Touch/Window/Pages/Audio/Ambience/Slider/Track/Fill` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Touch/Window/Pages/Audio/Ambience/Value` | TextLabel | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Touch/Window/Pages/Audio/Voice` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Layout_Touch/Window/Pages/Audio/Voice/Label` | TextLabel | décoratif | Voix |  |
| `SettingsGui/Layout_Touch/Window/Pages/Audio/Voice/Slider` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Touch/Window/Pages/Audio/Voice/Slider/Track` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Touch/Window/Pages/Audio/Voice/Slider/Track/Fill` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Touch/Window/Pages/Audio/Voice/Value` | TextLabel | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Touch/Window/Pages/Audio/Music` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Layout_Touch/Window/Pages/Audio/Music/Label` | TextLabel | décoratif | Musique |  |
| `SettingsGui/Layout_Touch/Window/Pages/Audio/Music/Slider` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Touch/Window/Pages/Audio/Music/Slider/Track` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Touch/Window/Pages/Audio/Music/Slider/Track/Fill` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Touch/Window/Pages/Audio/Music/Value` | TextLabel | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Touch/Window/Pages/Audio/Effects` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Layout_Touch/Window/Pages/Audio/Effects/Label` | TextLabel | décoratif | Effets |  |
| `SettingsGui/Layout_Touch/Window/Pages/Audio/Effects/Slider` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Touch/Window/Pages/Audio/Effects/Slider/Track` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Touch/Window/Pages/Audio/Effects/Slider/Track/Fill` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Touch/Window/Pages/Audio/Effects/Value` | TextLabel | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Touch/Window/Pages/Accessibility` | ScrollingFrame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Touch/Window/Pages/Accessibility/Subtitles` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Layout_Touch/Window/Pages/Accessibility/Subtitles/Label` | TextLabel | décoratif | Sous-titres |  |
| `SettingsGui/Layout_Touch/Window/Pages/Accessibility/Subtitles/Options` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Touch/Window/Pages/Accessibility/Subtitles/Options/Opt_Yes` | TextButton | lu par `SettingsController` | Oui |  |
| `SettingsGui/Layout_Touch/Window/Pages/Accessibility/Subtitles/Options/Opt_No` | TextButton | lu par `SettingsController` | Non |  |
| `SettingsGui/Layout_Touch/Window/Pages/Accessibility/SubtitleSize` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Layout_Touch/Window/Pages/Accessibility/SubtitleSize/Label` | TextLabel | décoratif | Taille |  |
| `SettingsGui/Layout_Touch/Window/Pages/Accessibility/SubtitleSize/Options` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Touch/Window/Pages/Accessibility/SubtitleSize/Options/Opt_Small` | TextButton | lu par `SettingsController` | Petite |  |
| `SettingsGui/Layout_Touch/Window/Pages/Accessibility/SubtitleSize/Options/Opt_Medium` | TextButton | lu par `SettingsController` | Moyenne |  |
| `SettingsGui/Layout_Touch/Window/Pages/Accessibility/SubtitleSize/Options/Opt_Large` | TextButton | lu par `SettingsController` | Grande |  |
| `SettingsGui/Layout_Touch/Window/Pages/Accessibility/ReduceMotion` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Layout_Touch/Window/Pages/Accessibility/ReduceMotion/Label` | TextLabel | décoratif | Réduire les mouvements (balancement de caméra) |  |
| `SettingsGui/Layout_Touch/Window/Pages/Accessibility/ReduceMotion/Options` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Touch/Window/Pages/Accessibility/ReduceMotion/Options/Opt_Yes` | TextButton | lu par `SettingsController` | Oui |  |
| `SettingsGui/Layout_Touch/Window/Pages/Accessibility/ReduceMotion/Options/Opt_No` | TextButton | lu par `SettingsController` | Non |  |
| `SettingsGui/Layout_Touch/Window/Pages/Accessibility/ReducedGore` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Layout_Touch/Window/Pages/Accessibility/ReducedGore/Label` | TextLabel | décoratif | Gore réduit |  |
| `SettingsGui/Layout_Touch/Window/Pages/Accessibility/ReducedGore/Options` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Touch/Window/Pages/Accessibility/ReducedGore/Options/Opt_Yes` | TextButton | lu par `SettingsController` | Oui |  |
| `SettingsGui/Layout_Touch/Window/Pages/Accessibility/ReducedGore/Options/Opt_No` | TextButton | lu par `SettingsController` | Non |  |
| `SettingsGui/Layout_Touch/Window/Pages/Accessibility/Language` | Frame | lu par `SettingsController` |  | lu par SettingsController |
| `SettingsGui/Layout_Touch/Window/Pages/Accessibility/Language/Label` | TextLabel | décoratif | Langue |  |
| `SettingsGui/Layout_Touch/Window/Pages/Accessibility/Language/Options` | Frame | lu par `SettingsController` |  |  |
| `SettingsGui/Layout_Touch/Window/Pages/Accessibility/Language/Options/Opt_French` | TextButton | lu par `SettingsController` | Français |  |
| `SettingsGui/Layout_Touch/Window/Pages/Accessibility/Language/Options/Opt_English` | TextButton | lu par `SettingsController` | Anglais |  |
| `SettingsGui/Layout_Touch/Window/Apply` | TextButton | lu par `SettingsController` | Appliquer |  |
| `SettingsGui/Layout_Touch/Window/Reset` | TextButton | lu par `SettingsController` | Réinitialiser |  |
| `SettingsGui/Layout_Touch/Window/Close` | TextButton | lu par `SettingsController` | Fermer |  |

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

### CreatureDebug — ReplicatedStorage/UITemplates (les deux places), section 15.5

| Chemin | Classe | Statut | Texte de départ | Remarque |
| --- | --- | --- | --- | --- |
| `CreatureDebug` | BillboardGui | — |  | 9.13 : texte écrit par AI/CreatureDebug ; F8 (CreatureDebugController) |
| `CreatureDebug/Info` | TextLabel | — |  |  |
