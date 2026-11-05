## 15. Bibliothèque d'interfaces (UI)

Toutes les interfaces sont de vraies instances dans `StarterGui`, construites une fois par Claude Code en mode Edit, avec les noms exacts ci-dessous. Gabriel peut ensuite tout déplacer, redimensionner et recolorer dans Studio sans toucher un script.

### 15.1 Contrat entre scripts et UI

| Les scripts peuvent changer | Les scripts ne changent jamais |
| --- | --- |
| `Text` | `Position`, `Size` (sauf les cadres `Fill`) |
| `Visible` | Couleurs, polices, tailles de texte |
| `Size.X.Scale` d'un cadre nommé `Fill` (jauges) | `ZIndex`, `AnchorPoint`, coins, bordures |
| Transparences, en fondu entre la valeur réglée à la main et 1 | Disposition (`UIListLayout`, `UIGridLayout`) |
| `Image` d'une icône d'objet (contenu, pas style) | — |
| Cloner un enfant nommé `Template` (puis `LayoutOrder` du clone) | Créer un élément avec `Instance.new` |

Un élément introuvable produit un seul avertissement clair (« UI manquante : HUDGui/BodyStatus/Head ») et le jeu continue.

### 15.2 Style (réglages de départ, modifiables à la main)

| Élément | Valeur |
| --- | --- |
| Police des titres | Special Elite (machine à écrire) |
| Police du texte et du HUD | Roboto Mono |
| Texte principal | #E8E4D8 (blanc os) |
| Texte secondaire | #9A968C |
| Fond des panneaux | #0E0F0D, transparence 0,35 |
| Danger | #A3342B (sang séché) |
| Positif | #6E8B5E (mousse) |
| Écran de la tablette | fond #1B2A22, texte #9FE0A8 |
| Mise en page | Tout en Scale ; `UIAspectRatioConstraint` sur les panneaux ; `UITextSizeConstraint` de 14 à 28 ; `ScreenInsets = CoreUISafeInsets` |
| HUD | S'efface après 4 s sans changement ; réapparaît à la moindre variation |

Polices : vérifier dans Studio qu'elles existent sous ces noms ; sinon, choisir la plus proche et le noter.

### 15.3 Lobby

| ScreenGui | Hiérarchie (enfants principaux) | Lu par |
| --- | --- | --- |
| `DialogueGui` | `Dialogue` > `SpeakerName`, `Line`, `Choices` > `Choice_1`, `Choice_2`, `Choice_3` | `DialogueController` |
| `MuseumPanelGui` | `Panel` > `Title`, `Body`, `Source`, `Illustration`, `Close` | `MuseumController` |
| `PartyGui` | `PartyFrame` > `Header` (`Title`, `Code`), `MemberList` > `Template` (`PlayerName`, `RoleName`, `ReadyIcon`), `Buttons` (`CreatePublic`, `CreatePrivate`, `JoinCode`, `QuickJoin`, `Ready`, `Leave`), `CodeInput` | `PartyController` |
| `RoleSelectGui` | `Grid` > `RoleCard_<ROLE>` (×10) > `Portrait`, `CharacterName`, `RoleTitle`, `Ability`, `Weakness`, `TakenOverlay` (> `TakenBy`) ; `Confirm` | `RoleController` |
| `WeaponBoardGui` | `Board` > `Slot_Rifle`, `Slot_Revolver`, `Slot_Shotgun` > `Icon`, `Holder`, `Take` ; `VotePopup` > `Question`, `Option_1`, `Option_2`, `Timer` | `WeaponBoardController` |
| `VoteGui` | `Difficulty` > `Normal`, `Hard`, `Nightmare` (> `Lock`) ; `Weather` > `Random`, `Clear`, `Fog`, `Rain`, `Snow` ; `Countdown` | `VoteController` |
| `SkinShopGui` | `CharacterList` > `Template` ; `SkinGrid` > `Skin_A`, `Skin_B`, `Skin_C` (> `Lock`, `Requirement`) ; `Preview` (ViewportFrame) ; `Equip` | `SkinShopController` |
| `RecordsGui` | `Board` > `Template` (`Rank`, `Group`, `Value`) ; `Tabs` > `Survivors`, `EvidenceA`, `Endings` | `RecordsController` |
| `EvidenceBoardGui` | `Cork` > `Template` (`Photo`, `Label`, `Class`) ; `NotebookPages` > `Page_1`, `Page_2`, `Page_3` (> `Lock`) | `EvidenceBoardController` |
| `ResultsGui` | `Card` > `EndingTitle`, `EndingText`, `Survivors` > `Template` (`Name`, `Status`), `Evidence` > `Template`, `XPGained`, `Continue` | `ResultsController` |
| `LoadingGui` | `Background`, `Tip`, `Spinner` | `TeleportController` |

### 15.4 Partie

| ScreenGui | Hiérarchie (enfants principaux) | Lu par |
| --- | --- | --- |
| `HUDGui` | `BodyStatus` > `Head`, `Torso`, `ArmL`, `ArmR`, `LegL`, `LegR` (chacun > `Ok`, `Hurt`, `Critical`, une seule visible) ; `BleedIcon` ; `Stamina` > `Fill` ; `Battery` > `Fill` ; `Ammo` > `Count`, `Reserve` ; `HeldItem` ; `Crosshair` ; `FearVignette` ; `Ping` > `Template` | `HUDController` |
| `InventoryGui` | `QuickSlots` > `Slot_1` à `Slot_4` (> `Icon`, `Count`, `Key`, `Selected`) ; `Bag` > `Weight`, `List` > `Template` (`Icon`, `Name`, `Count`, `Drop`) | `InventoryController` |
| `ObjectiveGui` | `ActName`, `ObjectiveText`, `Clock` | `ObjectiveController` |
| `InteractGui` | `Prompt` > `KeyHint`, `ActionText`, `Progress` > `Fill` | `InteractController` (prompts `ProximityPrompt` en style Custom) |
| `TabletGui` | `Device` > `Screen` > `AppBar` (`Btn_Map`, `Btn_Objectives`, `Btn_Journal`, `Btn_Evidence`, `Btn_Network`), `Pages` > `Page_Map` (`MapImage`, `PlayerDot`, `NoSignal`, `Markers` > `Template`, `TunnelLayer`), `Page_Objectives` (`List` > `Template`), `Page_Journal` (`List` > `Template`, `Reader` > `Title`, `Body`), `Page_Evidence` (`List` > `Template`), `Page_Network` (`Bars`, `Message`, `Send`) ; `BatteryText` ; `Close` | `TabletController` |
| `DocumentGui` | `Paper` > `Title`, `Body`, `Picture`, `Close` ; `Tape` > `Label`, `Play`, `Progress` > `Fill` | `DocumentController` |
| `DownedGui` | `Countdown`, `HelpHint`, `Bleed` > `Fill` | `DownedController` |
| `SpectatorGui` | `Watching`, `Prev`, `Next`, `Note` | `SpectatorController` |
| `RadioGui` | `Channel`, `Talking`, `Static` | `RadioController` |
| `MobileControlsGui` | `Sprint`, `Crouch`, `Prone`, `Interact`, `Aim`, `Fire`, `Reload`, `Light`, `Tablet`, `Ping`, `LeanL`, `LeanR` (visible seulement sur écran tactile) | `InputController` |

### 15.5 Les deux places

| ScreenGui | Hiérarchie | Lu par |
| --- | --- | --- |
| `CinematicGui` | `BarTop`, `BarBottom`, `Subtitle`, `Skip` > `Votes` | `CinematicController` |
| `SettingsGui` | `Window` > `Tabs` (`Audio`, `Controls`, `Graphics`, `Accessibility`) ; `Pages` (voir 17.2 pour les réglages) ; `Apply`, `Reset`, `Close` | `SettingsController` |
| `NotificationGui` | `Stack` > `Template` (`Text`) | `NotificationController` |

Les repères de ping et les noms au-dessus des têtes sont des `BillboardGui` modèles rangés dans `ReplicatedStorage/UITemplates`, faits à la main de la même façon.

À la fin du jalon UI, Claude Code livre `UI_MAP.md` : chaque élément, son chemin, et s'il est lu par un script ou purement décoratif.

### 15.6 Libellés des boutons et aides

| Élément | Texte |
| --- | --- |
| `Close` (partout) | Fermer |
| `Confirm` | Confirmer |
| `Take` | Prendre |
| `Equip` | Équiper |
| `Continue` | Continuer |
| `Apply`, `Reset` | Appliquer, Réinitialiser |
| `Skip` | Passer |
| `Send` (tablette) | Envoyer |
| `Play` (cassette) | Lire |
| `Drop` (sac) | Jeter |
| `Prev`, `Next` (spectateur) | Précédent, Suivant |
| `CreatePublic`, `CreatePrivate` | Groupe public, Groupe privé |
| `JoinCode`, `QuickJoin` | Rejoindre avec un code, Partie rapide |
| `Ready`, `Leave` | Prêt, Quitter le groupe |
| `CodeInput` (texte d'attente) | Code à 4 chiffres |
| `TakenBy` | Pris par {player} |
| `Lock` | Verrouillé |
| `Requirement` (skins B, C) | 5 parties jouées ; 1 survie |
| Difficulté | Normal, Difficile, Cauchemar |
| Météo | Aléatoire, Nuit claire, Brouillard, Pluie, Première neige |
| Onglets des records | Survivants, Preuves A, Fins |
| Onglets des réglages | Audio, Contrôles, Graphismes, Accessibilité |
| Applis de la tablette | Carte, Objectifs, Journal, Preuves, Réseau |
| `NoSignal` | Pas de signal GPS |
| `Page_Network` > `Message` (sans réseau) | Aucun réseau |
| `HelpHint` (à terre) | Appelle à l'aide : un coéquipier peut te relever. |
| `Watching` (spectateur) | Tu regardes {player} |
| `Note` (spectateur) | Tu es mort. Tu peux encore suivre ton groupe. |
| `MobileControlsGui` | Courir, Accroupi, Couché, Utiliser, Viser, Tirer, Recharger, Lampe, Tablette, Signaler, ← Pencher, Pencher → |
| `LoadingGui` > `Tip` (tiré au hasard) | « Une lampe allumée se voit de très loin. » ; « Le bruit de l'eau couvre tes pas. » ; « Seul, tu es discret. Seul, tu es une proie. » |

Un libellé court (bouton, onglet, aide d'un mot ou deux) encore absent de ce tableau prend la proposition de Claude Code dans `UI_MAP.md`, marquée `DÉFAUT`. Les textes plus longs restent un `TODO(BIBLE)`.

### 15.7 Règles d'affichage sur téléphone (ajout du 5 novembre)

Une relecture des interfaces générées a montré des textes qui débordent et des éléments placés sous les pouces sur un écran de 844 × 390. Règles :

1. **Deux dispositions faites à la main.** Un écran dont la disposition doit changer sur téléphone a deux enfants, `Layout_Desktop` et `Layout_Touch`, avec les mêmes noms d'éléments dedans. Le script choisit lequel est visible selon l'appareil (`UserInputService.TouchEnabled`). C'est la seule exception au contrat 15.1, car elle ne touche que `Visible`.
2. **Coin bas gauche et bas droit libres sur téléphone :** le joystick et le bouton de saut de Roblox y sont. Santé, endurance et pile passent en haut à gauche dans `Layout_Touch`.
3. **Boutons tactiles :** une icône au trait (style 13.5), pas de mot ; au moins 56 × 56 pixels (taille minimale par `UISizeConstraint`) ; au plus 6 visibles à la fois. Viser, Tirer et Recharger n'apparaissent qu'avec une arme en main ; Utiliser seulement quand une invite est proche.
4. **Lignes de réglages et listes :** hauteur minimale de 36 pixels (`UISizeConstraint`), une ligne de texte par libellé, défilement par `AutomaticCanvasSize`.
5. **Choix du rôle sur téléphone :** cartes réduites (portrait, nom, rôle) sur une ligne qui défile, et un panneau de détail pour la carte sélectionnée (capacité, faiblesse).
6. **Jauges distinguables :** chaque barre (endurance, pile) a son icône à gauche. `BodyStatus` utilise 6 images de silhouette (une par membre, états Ok, Hurt, Critical), dans le style au trait de 13.5.
7. **Verrous :** un `Lock` couvre entièrement son bouton avec un fond opaque ; le texte dessous ne doit jamais se lire en double. Pour les skins, le verrou affiche lui-même la condition (« Verrouillé — 5 parties jouées ») et Requirement reste masqué tant que le verrou est là.
8. **Vérification :** émulateur d'appareils de Studio au format téléphone 844 × 390 et PC 1280 × 720, capture de chaque écran, avant la publication.

Compléments après mesure des chevauchements :

- **Fenêtres surgissantes** (`VotePopup` et toute fenêtre au-dessus d'un panneau) : fond opaque et un voile noir à 60 % sur le reste de l'écran, pour que rien ne se lise au travers.
- **Sac ouvert :** il ne doit chevaucher ni l'indicateur radio (`RadioGui`) ni les boutons tactiles. Sur téléphone, ouvrir le sac masque les boutons tactiles, sauf Fermer.
- **Boutons Fermer et boutons à deux mots** (« Rejoindre avec un code », « Quitter le groupe ») : assez larges pour leur texte à la taille minimale de 14, sans retour à la ligne.
- **Contrôle automatique :** `tools/ui/check_ui.py` doit signaler tout texte qui déborde et tout chevauchement entre deux éléments visibles en même temps (hors pastilles voulues : chiffres et touches sur les icônes d'inventaire, bouton Passer dans la bande noire, repères sur la carte de la tablette).

