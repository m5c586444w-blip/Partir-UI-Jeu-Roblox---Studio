## 14. Bibliothèque d'animations

Le jeu a 2 squelettes : un squelette humain partagé par les 10 personnages, et un squelette de créature partagé par les 4 variantes. Claude Code crée tous les objets `Animation` vides, nommés comme ci-dessous, dans `ReplicatedStorage/Animations/<Squelette>/`. Gabriel y colle les identifiants une fois les animations faites. Un identifiant manquant produit un avertissement dans la console, jamais une erreur bloquante.

**Origine :** humains, animations Mixamo adaptées (licence à vérifier) ou créées dans l'Animation Editor ; créature, créées par Gabriel (Blender ou Animation Editor), en partant des animations du modèle de whitehair19 si elles sont incluses.

**Marqueurs** (`KeyframeMarker`) lus par les scripts : `Step` (son de pas), `Impact` (moment des dégâts), `Release` (lâcher d'une pierre), `Grab` (saisie effective), `Done` (fin d'action).

### 14.1 Joueurs (`ANIM_Player_*`)

| Nom | Boucle | Durée (s) | Priorité | Marqueurs |
| --- | --- | --- | --- | --- |
| Idle, Walk, Run | Oui | 2 / 1 / 0,7 | Movement | Step |
| CrouchIdle, CrouchWalk | Oui | 2 / 1,2 | Movement | Step |
| ProneIdle, ProneCrawl | Oui | 3 / 1,6 | Movement | Step |
| Jump, Land | Non | 0,4 / 0,3 | Movement | Step (Land) |
| LimpWalk | Oui | 1,3 | Movement | Step |
| LeanLeft, LeanRight | Non (tenue) | 0,25 | Action | — |
| CarryWalk, CarryRun (porteur) | Oui | 1,1 / 0,8 | Action | Step |
| Carried (porté) | Oui | 2 | Action | — |
| DownedIdle, DownedCrawl | Oui | 3 / 1,8 | Action | — |
| ReviveGive, ReviveReceive | Non | 6 (3 Médecin) | Action | Done |
| Bandage, Splint, Medkit | Non | 4 / 6 / 8 | Action | Done |
| Barricade | Oui | 1 coup / 0,6 | Action | Impact |
| RepairStanding, RepairKneel | Oui | 2 | Action | — |
| Pickup, Throw | Non | 0,6 / 0,7 | Action | Release |
| CarryHeavy (batterie, jerrican) | Oui | 1,2 | Action | Step |
| FlashlightHold, TabletHold, CamcorderHold | Oui (haut du corps) | 2 | Action | — |
| Rifle\_Idle, \_Aim, \_Fire, \_Bolt, \_LoadRound | idle/aim oui | — / 0,3 / 0,2 / 0,9 / 1,2 | Action2 | Impact (Fire) |
| Revolver\_Idle, \_Aim, \_Fire, \_LoadRound | idle/aim oui | — / 0,25 / 0,15 / 0,8 | Action2 | Impact |
| Shotgun\_Idle, \_Aim, \_Fire, \_Pump, \_LoadShell | idle/aim oui | — / 0,3 / 0,2 / 0,5 / 0,9 | Action2 | Impact |
| FlareGun\_Fire, \_Reload | Non | 0,3 / 2 | Action2 | Impact |
| Axe\_Swing, Machete\_Swing | Non | 1,1 / 0,8 | Action2 | Impact |
| BearSpray\_Use, Flare\_Light | Non | 0,6 / 1,0 | Action2 | Release |
| Grabbed\_Struggle, Dragged | Oui | 1,5 / 2 | Action3 | — |
| Scream | Non | 1,2 | Action3 | — |
| FearTremble (additif, mains) | Oui | 0,5 | Action4 | — |
| Van\_Seated (cinématiques) | Oui | 4 | Action | — |

La mort n'a pas d'animation : le corps passe en ragdoll (11.5).

### 14.2 Créature (`ANIM_Creature_*`)

| Nom | Boucle | Durée (s) | Utilisée par | Marqueurs |
| --- | --- | --- | --- | --- |
| IdleStand, IdleCrouch | Oui | 4 / 4 | Tous les états | — |
| PeekTreeLeft, PeekTreeRight | Oui | 3 | BHV\_Observe (tête qui dépasse d'un tronc) | — |
| LookAround, Sniff | Non | 2,5 / 2 | Perception | — |
| Sneak, Walk, RunBiped | Oui | 1,6 / 1,2 / 0,7 | Déplacement | Step |
| SprintQuad | Oui | 0,5 | Sprint à quatre pattes | Step |
| TurnLeft, TurnRight | Non | 0,6 | Déplacement | — |
| ClimbUp, ClimbDown | Oui | 1,4 | ClimbPoint | — |
| WoodKnock | Non | 2,2 (3 coups) | Échelle 9.6, cran 2 | Impact ×3 |
| Call, GrowlClose | Non | 3 / 1,5 | Cran 3 | — |
| BranchBreak | Non | 1,2 | Cran 5, BHV\_Mark | Impact |
| ChestBeat | Non | 2,5 | Cran 6 (Alpha) | Impact ×8 |
| ChargeStart, ChargeStopBluff | Non | 0,8 / 1,0 | ATK\_Charge, fausse charge | Impact |
| PickStone, ThrowOverhand, ThrowUnderhand | Non | 0,8 / 1,1 / 0,9 | BHV\_Throw, siège | Release |
| StrikeLeft, StrikeRight | Non | 0,9 | ATK\_Strike | Impact |
| Grab, HoldStruggle, DragWalk | Grab non ; autres oui | 0,6 / 1,5 / 1,4 | ATK\_Grab, BHV\_Drag | Grab, Step |
| Slam | Non | 1,4 | ATK\_Slam | Impact |
| ReachThrough | Non | 1,6 | ATK\_ReachThrough | Grab |
| Execution | Non | 2,5 | ATK\_Execution (profil Restricted) | Impact (= noir) |
| HitLight, HitHeavy, Blinded | Non | 0,5 / 1,0 / 1,5 | Réactions | — |
| RetreatLimp | Oui | 1,3 | BHV\_Retreat | Step |
| FeedCrouch | Oui | 4 | BHV\_Feed | — |
| StackStones | Non | 3 | BHV\_Mark | Release |
| MimicCall (mains en cornet) | Non | 1,5 | BHV\_Mimic (éclaireurs) | — |
| CarryBones (femelle) | Oui | 2 | CS\_13, repaire | — |
| DeathFall | Non | 2,0 puis ragdoll | Alpha tué | — |

### 14.3 Caméra et objets

- Balancement de marche, de course et de peur : par code (`CameraController`), pas par animation.
- Objets animés : porte de cabane (charnière physique), barrières (charnière), pont qui oscille (ressort), arbres (os, 12.4), hélicoptère et van (trajectoires des cinématiques).

