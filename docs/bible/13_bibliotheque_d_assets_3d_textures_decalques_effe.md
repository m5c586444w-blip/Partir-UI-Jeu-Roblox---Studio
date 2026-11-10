## 13. Bibliothèque d'assets (3D, textures, décalques, effets, sons)

Seuls les assets listés ici entrent dans le jeu. Un asset marqué **MANQUANT** est remplacé par un bloc gris nommé `MANQUANT_<ID>` et noté dans `SUIVI.md`, jamais par un autre modèle. Le catalogue détaillé, avec auteurs et remarques, reste celui du [document Carte et assets](https://claude.ai/artifact/3kbHEGv6jw9Lsbfc1wDSsT) ; ici, chaque asset reçoit son nom définitif dans le jeu.

### 13.1 Sources autorisées

| Source | Licence | Règle |
| --- | --- | --- |
| Poly Haven | CC0, sans crédit obligatoire | Utilisable tel quel après réduction dans Blender |
| Sketchfab | Variable selon la page | Lire la licence sur chaque page. CC-BY : créditer. Refuser « Editorial », « NoDerivatives » et tout modèle extrait d'un jeu commercial |
| Freesound (sons) | Variable par fichier | CC0 de préférence ; CC-BY avec crédit ; refuser NonCommercial |
| Enregistrements de Gabriel | Libres | Voix (VO), pas, bois, pierres |
| Pièces Roblox Studio | — | Autorisées pour les objets simples (planches, caisses), ce ne sont pas des modèles du Marketplace |
| **Interdits** | — | Modèles gratuits du Marketplace Roblox ; modèles « ripés » (comptes game-ripper, toro\_ardido\_modelos\_3d) |

### 13.2 Budgets techniques

- Triangles : 20 000 au plus par maillage (des sources secondaires citent 20 000 à 21 000, à tester dans l'importateur ; [exemple](https://nilo.io/articles/vibe-coding-roblox-assets)). Au-delà, découper.
- Textures : 1 024 × 1 024 au plus ([creator-docs Roblox](https://github.com/Roblox/creator-docs/blob/main/content/en-us/art/modeling/texture-specifications.md)) ; 256 pour un objet de 5 studs, 512 pour 10, 1 024 pour 20 (même source). Un seul matériau par maillage, PBR par `SurfaceAppearance`.
- Cibles internes (choix de performance) :

| Type | Triangles visés | Texture |
| --- | --- | --- |
| Arbre (proche) | 6 000 | 1 024 en atlas |
| Rocher | 3 000 | 512 |
| Objet tenu en main | 2 000 | 512 |
| Petit objet au sol | 800 | 256 |
| Personnage (par membre, 6 membres) | 3 000 | 1 024 pour tout le corps |
| Créature (par morceau, 8 morceaux) | 4 000 | 1 024 |

### 13.3 Modèles 3D

| ID dans le jeu | Source retenue | Licence | Statut | Lieux |
| --- | --- | --- | --- | --- |
| Tree\_DouglasFir\_A–C | Fir Tree 01, Poly Haven | CC0 | Validé | Forêts |
| Tree\_Pine\_A–B | Pine Tree 01, Poly Haven | CC0 | Validé | Crêtes, plateau |
| Tree\_Hemlock\_A | Hemlock Tree, Free3D | À vérifier | À valider ; sinon sapin retouché | Forêt ancienne |
| Tree\_Snag\_A–B | Dead tree, YN14R / ThorPultion (Sketchfab) | À vérifier | À valider | P08 |
| Tree\_Fallen\_A | Realistic dead Fallen Tree, OleksiyFoliage | À vérifier | À valider | P08, P04 |
| Trunk\_Dead\_A–B | Dead Tree Trunk 01 et 02, Poly Haven | CC0 | Validé | P04, P08 |
| Stump\_A–B | Tree Stump 01 et 02, Poly Haven | CC0 | Validé | P10, forêts |
| Fern\_A–D | Fern 02, Poly Haven | CC0 | Validé | Sous-bois |
| Shrub\_A–B, Sapling\_A, Weed\_A | Shrub 03, 04, 02, Weed Plant 02, Poly Haven | CC0 | Validé | Sous-bois, P12 |
| Moss\_A | Moss 01, Poly Haven | CC0 | Validé (à réduire fortement) | Rochers, troncs |
| Rock\_Boulder\_A | Boulder 01, Poly Haven | CC0 | Validé | Partout |
| Rock\_Moss\_Set | Rock Moss Set 01 et 02, Poly Haven | CC0 | Validé | Ruisseaux |
| Rock\_Face\_A | Rock Face 02, Poly Haven | CC0 | Validé | P03, P05, F01 |
| Rock\_Small\_A | Rock 09, Poly Haven | CC0 | Validé | P02, pierres lançables |
| Cliff\_Basalt\_A | Volcanic Basalt Columns Cliffs, perz\_scans | À vérifier | À valider | P03 |
| Cave\_LavaTube\_A | Leiðarendi Lava Tube, ciara474 | À vérifier | À valider | P07 (morceaux répétés) |
| Cave\_LavaTube\_B | Urriðakotshellir Lava Tube, ciara474 | À vérifier | À valider | P21 |
| Tower\_Lookout\_A | Fire lookout tower, k1llreal | Gratuit avec crédit | À valider | P11, P24, P25, P26 |
| Building\_Cabin\_A | Log Cabin, Kless | À vérifier | À valider | P17 ; version abîmée = Prop\_CabinBeck\_Ruin (P05c) |
| Mine\_Entrance\_A | Mine Entrance, almarudjord ou jsabbott | À vérifier | À valider | P15 |
| Mine\_Rail\_A | Rail track straight, lastnickleft | À vérifier | À valider | P15 |
| Mine\_Cart\_A | Rusted Mining Cart, craggle | À vérifier | À valider | P15 |
| Bridge\_Suspension\_A | Suspension Bridge, coffeecat112 | À vérifier | À valider | P16 |
| Bridge\_Wood\_A | Collection bridges, Kaenna | Variable | À trier | Petits ruisseaux |
| WeatherStation\_A | Automatic Weather Station, hdyt | À vérifier | À valider | P23 |
| Gate\_Road\_A | Road Gate Barrier, ngooi1397 | À vérifier | À valider | P18, E3, RD1 |
| Fence\_Wood\_A | Woodfence, pasquill | À vérifier | À valider | P17, P10 |
| Sign\_Wood\_A | Wooden Sign, carlossamuelariza | À vérifier | **Validé par Gabriel** | Tous les panneaux (texte en texture) |
| Vehicle\_Van\_A | VW Van, jesseroberts (ou Retro Van, nmcbc) | À vérifier | À valider ; retirer tout logo de marque | P01, lobby |
| Vehicle\_Bulldozer\_A | Bulldozer, semyon.kan (mobile : Sidramax) | À vérifier | À valider | P10 |
| Vehicle\_Wreck\_A | Old Rusty Car 3, Renafox | Usage indé avec crédit | À valider | P22 |
| Camp\_Tent\_A | Modern Camping Tent, ponchoguy | À vérifier | À valider | P09 |
| Camp\_Stove\_A, Camp\_Cooler\_A | Portable gas stove, manamsudheer ; Cooler, MrPuppet | À vérifier | À valider (pas la glacière de marque Coleman) | P09 |
| Camp\_Backpack\_A | Backpack, MadeByYeshe | À vérifier | À valider | Joueurs, P09 |
| Prop\_LogPile\_A | Log pile, 00amza | À vérifier | À valider | P10 |
| Prop\_Radio\_Old | Radio, 3DSKETCH1550 | Gratuit | À valider | P17, P11 |
| Item\_Walkie | walkie Talkie, davidtsoenyane | À vérifier | À valider | Joueurs |
| Item\_PhotoCamera | Vintage Camera, Ledger9o9 | À vérifier | À valider | Objet |
| Item\_Flashlight | Collection Flashlight, MortemNightshade | Variable | À trier | Objet |
| WPN\_Rifle (modèle) | Hunting Rifle, Ryan\_Nein (mobile) ; Rigby, MartijnVaes (PC) | À vérifier | À valider | Arme |
| Prop\_ElkRemains\_A | Deer Skeleton, Renn36, complété dans Blender | À vérifier | À valider | P19 |
| Prop\_Cast\_Museum | Moulages Virtual Curation Lab / ARCSMU | Téléchargement non confirmé | À vérifier | Musée du lobby |
| CRT\_Alpha (base) | bigfoot, whitehair19 (Sketchfab) | Pas indiqué gratuit : contacter l'auteur | **Choix retenu** | Créature |
| CRT\_Alpha (secours) | Gorille de la collection BIGFOOT, dmlbaker, retravaillé | À vérifier | Secours | Créature |
| CHR\_\<ROLE>\_Skin\_A–C | — | — | **MANQUANT** : 10 humains réalistes avec squelette, découpés en 6 | Joueurs |
| WPN\_Revolver, WPN\_Shotgun, WPN\_FlareGun, MEL\_Axe, MEL\_Machete | — | — | **MANQUANT** | Armes |
| Item\_Tablet, Item\_Camcorder, Item\_Jerrycan, Item\_CarBattery, Item\_Jack, Item\_ToolBox, Item\_BearSpray, Item\_Headlamp, Item\_Flare, Item\_Bandage, Item\_Medkit | — | — | **MANQUANT** | Objets |
| Prop\_StickStructure\_A–C, Prop\_StonePile\_A–C, Prop\_SnappedTree\_A | À assembler dans Studio avec les branches, rochers et troncs ci-dessus | — | À faire | Événements (section 10) |

Créature : 4 variantes à partir d'un même modèle (Alpha 1,0 ; femelle 0,9 avec pelage plus clair ; éclaireurs 0,8 ; os du juvénile séparés), découpées en 8 morceaux (tête, torse, bassin, 2 bras, 2 jambes, mains fusionnées aux bras) pour les blessures.

### 13.4 Textures du terrain (`MaterialVariant`, Poly Haven, CC0)

| Matériau Roblox | Texture | Biome |
| --- | --- | --- |
| Ground | Forest Ground 01 | Forêt mixte |
| LeafyGrass | Forest Floor | Forêt ancienne |
| Mud | Mud Forest, Muddy Tracks | Bords de ruisseau, pistes |
| Rock / Basalt | Rock Pitted Mossy | Falaises |
| Sand (cendre) | Brown Mud 03 recoloré gris | P06, P08 |

### 13.5 Décalques et images à créer

Tout est à créer par Gabriel (ou en Blender), jamais à partir de photos réelles trouvées en ligne.

| ID | Contenu |
| --- | --- |
| Decal\_Footprint\_Big | Empreinte de créature, 41 cm de long (≈ 1,5 stud) |
| Decal\_Footprint\_Human | Empreinte de chaussure de randonnée |
| Decal\_Blood\_Pool\_A–C, Decal\_Blood\_Spatter\_A–C, Decal\_Blood\_Trail | Sang (profil Restricted) ; versions sombres pour Moderate |
| Decal\_Wound\_A–D | Plaies sur vêtements et peau |
| Tex\_Sign\_Refuge, Tex\_Sign\_AreaClosed, Tex\_Sign\_Trail234, Tex\_Sign\_Road83Closed | Textes des panneaux (DOC\_15, P18, T1, RD1) |
| Img\_TabletMap | Carte topographique de la section 3 pour la tablette |
| Img\_DOC06, Img\_DOC16, Img\_News\_CS14 | Photo d'empreinte, photo de groupe fictive, une de journal fictive |
| Img\_Museum\_M1–M8 | Illustrations des panneaux du musée |

**Images d'interface (ajout) :**

| ID | Contenu | Qui le fait |
| --- | --- | --- |
| Img\_FearVignette | Dégradé radial noir, transparent au centre, 1 024 × 1 024 | Claude Code, par script (Python), pas par IA générative |
| Portraits des rôles | Pas d'image : `Portrait` est un `ViewportFrame` qui affiche le modèle `Skin_A` du rôle | Claude Code |
| Icon\_\<ID objet ou arme> | Phase A : icônes simples à traits blancs (SVG exporté en PNG 256 × 256), dessinées par script. Phase B : rendu des vrais modèles 3D sur fond transparent | A : Claude Code ; B : session Studio ou Gabriel |

**Modification du 9 novembre 2026 (décision de Gabriel) :** les images du jeu et des miniatures peuvent être produites par une IA générative d'images (ex. ChatGPT), à ces conditions : (1) Gabriel valide chaque image avant import ; (2) l'image est ajoutée à `ReplicatedStorage/Credits` (outil, date, « généré par IA ») ; (3) aucune image ne reproduit une personne réelle, un logo ou une œuvre existante ; (4) les textes affichés restent ceux de la section 2, écrits dans Studio ou par script, pas par l'IA ; (5) `Img_FearVignette` et les icônes restent faites par script. Claude Code ne génère pas d'images lui-même : il importe celles que Gabriel dépose dans `assets/images-ia/`.

### 13.6 Effets

`FX_Rain`, `FX_Snow`, `FX_Ash` (P08), `FX_Breath` (buée devant la bouche par froid), `FX_Flare`, `FX_Campfire`, `FX_Blood_Burst`, `FX_EyeShine` (deux points rouges, 4 s), `FX_Dust_Roof` (siège), `FX_Waterfall_Mist`, `FX_Leaves` (rafales).

### 13.7 Sons

| Groupe | IDs | Nombre |
| --- | --- | --- |
| Créature | SFX\_WoodKnock\_01–06, SFX\_Call\_Long\_01–04, SFX\_Growl\_Close\_01–04, SFX\_Huff\_01–03, SFX\_ChestBeat\_01–02, SFX\_Whistle\_01–03, SFX\_Steps\_Heavy\_\<Matériau> (×12), SFX\_Steps\_Heavy\_Delay, SFX\_BranchSnap\_01–05, SFX\_StoneWhoosh\_01–02 | 42 |
| Impacts | SFX\_StoneOnWood\_01–03, SFX\_StoneOnMetal\_01, SFX\_StoneGround\_01–03, SFX\_Splash\_Small, SFX\_PlankHit\_01–03, SFX\_PlankBreak\_01 | 12 |
| Joueurs | Pas (12 matériaux × 4), souffle, haletèment, cœur, cri (×10 personnages) | 48 + 13 |
| Voix (10 personnages) | VO\_\<ROLE>\_Help, \_Hey, \_Smell, \_Downed, \_Scream ; VO\_Leader\_Order ; VO\_Museum\_01–08 ; VO\_CS00 | 51 + 9 |
| Objets et armes | Clic de lampe, recharges, tirs proches et lointains par arme, fusée, radio, bips, tablette, déchirure de bandage, outils | 30 |
| Lieux et véhicules | SFX\_DoorCreak\_01–03, SFX\_RadioBreath\_01, van, bulldozer, hélicoptère | 10 |
| Ambiances et musique | Section 12 | 8 + 4 |

Aucun son de créature ne doit être un enregistrement « de Bigfoot » trouvé en ligne : droits inconnus. Base conseillée : voix humaine grave ralentie, cris de wapiti et de coyote sous licence CC0, coups réels sur un tronc.

