# PISTE FROIDE — Bible de production pour Claude Code

Nov 4, 2026 · @Gabriel BEST DE GAND

## 0. Mode d'emploi pour Claude Code

Ce document est la seule source de vérité du projet PISTE FROIDE. Claude Code exécute ce qui est écrit ici. Il n'ajoute aucune règle, aucun lieu, aucun objet et aucun personnage qui n'y figure pas.

### Règles absolues

1. **Ne rien inventer.** Une information absente du document = arrêt et question à Gabriel. En attendant la réponse, laisser un marqueur `-- TODO(BIBLE): <question>` dans le code et passer à la tâche suivante.
2. **Les tableaux font foi.** Chaque valeur chiffrée (dégâts, vitesses, distances, durées) est recopiée telle quelle dans le module `Config` correspondant. Aucune valeur « magique » dans le code.
3. **L'UI est faite d'instances, pas de code.** Toutes les interfaces sont des `ScreenGui` placés dans `StarterGui` et construits une fois dans Studio, avec les noms exacts de la section 15. Les scripts ne créent jamais d'élément d'UI avec `Instance.new` (sauf les clones d'un modèle déjà présent, ex. une ligne de liste). Gabriel doit pouvoir tout déplacer et recolorer à la main.
4. **Aucun asset gratuit du Marketplace Roblox.** Seules les sources de la section 13 sont autorisées. Chaque asset importé est inscrit dans `ReplicatedStorage/Credits` (nom, auteur, URL, licence).
5. **Le serveur décide.** Dégâts, inventaire, IA, preuves et morts sont calculés côté serveur. Le client affiche et envoie des intentions.
6. **Mobile d'abord.** Toute fonctionnalité doit tourner sur un téléphone milieu de gamme (section 17). Une fonctionnalité qui ne passe pas le budget mobile est désactivée sur mobile, jamais supprimée.
7. **Une session = un jalon.** Chaque session Claude Code traite un seul jalon de la section 18 et ne modifie pas les fichiers des autres jalons, sauf demande explicite. Si Gabriel demande d'enchaîner plusieurs phases dans une session, chaque phase se termine quand même par un commit, un push et la mise à jour de SUIVI.md et HANDOFF.md avant de passer à la suivante.

**Questions en attente :** Gabriel veut que Claude Code avance seul. Une question de `SUIVI.md` qui ne touche ni un texte affiché aux joueurs, ni une valeur de gameplay, ni un asset est tranchée par la proposition de Claude Code : il l'applique, la marque `DÉFAUT` dans `SUIVI.md` et continue. Les autres attendent une réponse dans cette bible.

### Rituel de début de session

1. Lire les sections 0, 16 et la section du jalon demandé.
2. Lister l'arborescence existante dans Studio avant d'écrire quoi que ce soit.
3. Annoncer en trois lignes ce qui va être fait, puis le faire.
4. Finir par la liste des critères d'acceptation du jalon, cochés ou non, et les `TODO(BIBLE)` laissés.

### Conventions de nommage

| Élément | Règle | Exemple |
| --- | --- | --- |
| ModuleScript, Script, LocalScript | PascalCase, en anglais | `CreatureBrain`, `EvidenceService` |
| RemoteEvent / RemoteFunction | préfixe `RE_` / `RF_` | `RE_PickupItem`, `RF_GetLoadout` |
| Attribut d'instance | camelCase | `noiseLevel`, `isDowned` |
| Asset 3D | `Catégorie_Nom_Variante` | `Tree_DouglasFir_A`, `Prop_CabinBeck_Ruin` |
| Lieu de la carte | code `Pxx` de la section 3 | `P07_ApeCanyonRim` |
| Son | `SFX_`, `AMB_`, `MUS_`, `VO_` | `SFX_WoodKnock_03` |
| Animation | `ANIM_<Rig>_<Action>` | `ANIM_Creature_RockThrow` |
| Commentaires du code | en français | `-- la créature recule si 3 tirs reçus` |

### Unités

La carte fait 8 000 × 8 000 studs. L'échelle retenue est celle de la section 3 (1 stud = 28 cm, selon la doc Roblox). Les durées sont en secondes, les angles en degrés, les distances en studs.

## 1. Vision, piliers et différenciation

PISTE FROIDE est un jeu d'horreur de survie coopératif pour 1 à 10 joueurs, situé sur le vrai flanc sud-est du mont Saint Helens (État de Washington). Des étudiants y passent une nuit pour retrouver des géologues disparus. Ce document reprend et complète le [Game Design Document validé](https://claude.ai/artifact/UTfdbuxXMutPbwcfsZ2a2m) et le [document Carte et assets](https://claude.ai/artifact/3kbHEGv6jw9Lsbfc1wDSsT). En cas d'écart, **ce document-ci fait foi**.

**Pitch :** cent ans après le siège d'Ape Canyon, ça recommence, et cette fois personne ne croira les survivants.

**Nom du podcast des personnages :** « Cold Trail » (traduction anglaise de PISTE FROIDE), pour que le titre ait un sens dans l'histoire.

### Les cinq piliers (inchangés)

1. **Le réel sert de socle.** Lieux, dates et légendes viennent de faits documentés. La fiction se greffe dessus, jamais l'inverse.
2. **La peur vient de l'intelligence de la créature**, pas des jumpscares. Elle observe, apprend, tend des pièges et sépare le groupe.
3. **La violence a un poids.** Le gore est explicite mais rare : chaque mort est un événement que le groupe voit et subit.
4. **Les ressources manquent.** Peu d'armes, peu de munitions, peu de lumière.
5. **Le groupe est la ressource principale.** À 10, on est fort mais bruyant ; seul, on est discret mais condamné.

### Deux règles de ton ajoutées

- **L'animal avant le monstre.** La créature se comporte comme un grand primate territorial réel (section 9) : elle a faim, elle a peur, elle protège les siens. Ce qui la rend terrifiante, c'est qu'elle est crédible.
- **Toujours une explication possible.** Chaque événement étrange (section 10) a une explication naturelle plausible. Le jeu ne confirme jamais le surnaturel, comme les rangers de 1924 qui ont conclu à une supercherie ([Wikipedia, Ape Canyon](https://en.wikipedia.org/wiki/Ape_Canyon)).

### Ce qui existe déjà, et ce qu'on fait autrement

| Point | BIGFOOT (Steam, CyberLight Game Studio) | Jeux Bigfoot sur Roblox repérés | PISTE FROIDE |
| --- | --- | --- | --- |
| Objectif | Chasser Bigfoot : pièges, pistage, recherche du repaire ([Steam](https://store.steampowered.com/app/509980/BIGFOOT/), [SteamGifts](https://www.steamgifts.com/giveaway/eFp0t/bigfoot)) | Chasse ou survie ; ex. *Bigfoot Survival* (The Gang Stockholm, [Rotrends](https://rotrends.com/game/8898803222)), *The hunt for BigFoot* ([RoWatcher](https://rowatcher.com/games/1901790226/the-hunt-for-bigfoot)) | Enquêter et survivre. Tuer la créature est possible mais puni (loi réelle de 1969, fin amère) |
| Lieu | Réserves sauvages, ex. Ross Lake ([Steam](https://store.steampowered.com/app/509980/?l=koreana)) | Non vérifié | Le vrai site d'Ape Canyon et d'Ape Cave, reconstitué avec coordonnées |
| Joueurs | Coop jusqu'à 4 contre l'IA ; jusqu'à 5 contre un Bigfoot joué par un joueur ([SteamGifts](https://www.steamgifts.com/giveaway/eFp0t/bigfoot), [Steam](https://store.steampowered.com/app/509980?l=schinese)) | Non vérifié | 1 à 10 contre une famille de créatures IA, sans mode PvP |
| Créature | Un Bigfoot (IA ou joueur) | Non vérifié | Une famille avec rôles, mémoire, vengeance et comportement de grand singe documenté |
| Structure | Chasse ouverte | Non vérifié | 4 actes narratifs, 4 voies d'extraction, 5 fins |
| Mort | Non vérifié | Non vérifié | Définitive, spectateur par caméra corporelle |
| Plateforme | PC | Roblox | Roblox PC **et mobile** |

Sur Roblox, la tendance 2026 va vers des jeux d'horreur à mécaniques profondes plutôt qu'à jumpscares ([RoWatcher](https://rowatcher.com/news/10-best-roblox-horror-games-in-2026-from-dandy-s-world-to-hidden-gems)), avec *99 Nights in the Forest* comme succès de survie en forêt ([ExitLag](https://www.exitlag.com/blog/roblox-game-genres-and-popularity/)). PISTE FROIDE se place sur ce créneau, avec un lieu réel et une IA animale comme signature.

**Limite :** les pages des jeux Bigfoot Roblox n'ont pas pu être ouvertes (erreur du site). Leur gameplay n'est donc pas vérifié. Avant le lancement, Gabriel doit jouer 20 minutes à chacun et compléter ce tableau.

## 2. Lore : le réel, les légendes, la fiction

L'histoire repose sur des faits réels datés, puis une fiction qui commence trois semaines avant la partie. Tout texte affiché en jeu est écrit ci-dessous : Claude Code le recopie, il n'en rédige pas d'autre.

### 2.1 Chronologie réelle (sourcée)

| Date | Fait | Source | Usage en jeu |
| --- | --- | --- | --- |
| \~2 000 ans | Une coulée de basalte fluide creuse le tube de lave d'Ape Cave, long d'environ 2 miles | [The Columbian](https://columbian.com/news/2022/aug/07/ape-cave-makes-for-dark-cold-creepy-adventure-in-gifford-pinchot) | Repaire de la famille (P07) |
| \~450 ans | Un lahar bouche l'extrémité basse du tube | [Oregon Hikers](https://www.oregonhikers.org/field_guide/Ape_Cave) | Sortie basse obstruée, à dégager (fin secrète) |
| Juillet 1924 | Des prospecteurs disent avoir été attaqués par des « hommes-singes » d'environ 7 pieds, qui ont bombardé leur cabane de pierres après qu'un des leurs a touché l'un d'eux de trois balles | [Wikipedia](https://en.wikipedia.org/wiki/Ape_Canyon) | Acte 2, le siège |
| 1924 | Les rangers J.H. Huffman et William Welch descendent dans le canyon, ne trouvent rien et montrent que les empreintes de 14 pouces sont faciles à truquer | [Wikipedia](https://en.wikipedia.org/wiki/Ape_Canyon) | Rapport des rangers au musée : l'ambiguïté est officielle |
| 1924 | Le siège dure jusqu'à l'aube ; au matin, Fred Beck voit une créature au bord du canyon | [Atlas Obscura](https://www.atlasobscura.com/places/ape-canyon) | Fin du siège à l'aube |
| 1947 | Le logger Lawrence Johnson découvre l'entrée d'Ape Cave ; des scouts sponsorisés par les « St. Helens Apes » lui donnent son nom | [The Columbian](https://columbian.com/news/2022/aug/07/ape-cave-makes-for-dark-cold-creepy-adventure-in-gifford-pinchot), [Forest Service (archive)](https://webarchive.library.unt.edu/eot2008/20081101215557/http://www.fs.fed.us/gpnf/recreation/ape-cave/index.shtml) | Panneau du musée. Wikipedia cite aussi \~1951 : date à afficher « 1947 » |
| 1967 | Fred Beck publie avec son fils *I Fought the Apemen of Mt. St. Helens*, qui ajoute une lecture spirituelle des créatures | [Cryptomundo](https://cryptomundo.com/?p=68085) | Évoqué seulement, **jamais cité** (texte protégé © Ronald A. Beck) |
| 1er avril 1969 | Ordonnance 69-01 du comté de Skamania : tuer un Sasquatch est un crime, amende jusqu'à 10 000 $ et/ou jusqu'à 5 ans | [Skagit Valley Herald](https://www.goskagit.com/anacortes/news/how-to-find-bigfoot-or-at-least-a-t-shirt-in-skagit-county/article_7018d3ac-751d-11ef-ad64-531ceaf74f60.html), [registre du comté](https://codepublishing.com/WA/SkamaniaCounty/html/SkamaniaCountyOT.html) | Panneaux, fin « Ordonnance 69-01 » |
| 1969 | Le texte parle d'un possible « primate nocturne » | [WSBA](https://nwsidebar.wsba.org/2019/10/31/washington-rules-to-make-you-scream-this-halloween-completely-bizarre-but-totally-real-laws-legislation-and-legal-references/) | Justifie la créature nocturne (section 9) |
| 18 mai 1980, 8 h 32 | Éruption après un séisme de magnitude 5,1 ; 57 morts ; végétation et bâtiments rasés sur 600 km² | [Wikipedia](https://en.wikipedia.org/wiki/Mount_St._Helens) | Zone interdite (P08) |
| 1980 | Au lac Spirit, des milliers d'arbres arrachés forment un radeau de troncs sur \~40 % de la surface | [Wikipedia](<https://en.wikipedia.org/wiki/Spirit_Lake_(Washington)>) | Lac P20 couvert de troncs |
| 1980 | La boue de fonte du glacier Shoestring dévale Lava Canyon par la route 83 | [The Columbian](https://columbian.com/news/2013/jul/10/ape-canyon-trail-mount-hiking) | Lava Canyon décapé (P03) |
| 1984 | Ordonnance amendée : « Sasquatch refuge » ; peine actuelle d'un an et 1 000 $ selon la Chambre de commerce | [registre du comté](https://codepublishing.com/WA/SkamaniaCounty/html/SkamaniaCountyOT.html), [Denver Gazette](https://www.denvergazette.com/?p=112245) | Rappel du ranger |
| 2013 | Le volcan est inscrit au Registre national comme bien culturel traditionnel sous le nom Lawetlat'la | [The Columbian](https://columbian.com/news/2015/sep/06/mount-st-helens-name-appears-safe) | Panneau du musée |
| Mai 2023 | Un glissement coupe la route 504 et l'accès à l'observatoire Johnston Ridge, réouverture prévue en 2027 | [Wikipedia](https://en.wikipedia.org/wiki/Johnston_Ridge_Observatory) | Le flanc nord est inaccessible : seule la route 83 au sud mène au site |
| Hiver | La route 83 est fermée par une barrière à la Sno-Park de Marble Mountain quand il neige | [Visit Mt St Helens](https://www.visitmtsthelens.com/business-directory/ape-canyon-trail-234/) | Le van force la barrière : personne ne viendra vite |

**Règle de respect :** les 57 victimes de 1980 sont réelles. Aucune n'est nommée, montrée ou utilisée dans le gore. Le jeu ne parle que du bilan.

**Versions divergentes de 1924 :** Wikipedia place le tir avant le bombardement ; Atlas Obscura raconte une créature vue au bord du canyon au matin, après le siège. Le jeu suit l'ordre de Wikipedia (tir, puis siège) et garde l'apparition du matin pour la fin de l'acte 2 (CS\_07).

### 2.2 Légendes autochtones : ce qu'on dit, ce qu'on ne fait pas

- Le volcan s'appelle **Lawetlat'la** (« celui qui fume ») chez les Cowlitz et **Loowit** chez les Klickitat ([Wikipedia](https://en.wikipedia.org/wiki/Mount_St._Helens), [The Columbian](https://columbian.com/news/2015/sep/06/mount-st-helens-name-appears-safe)).
- Chez plusieurs peuples salish et du Nord-Ouest, les **« Stick Indians »** sont des esprits de la forêt dangereux ; certains récits parlent de sifflements ou de rires la nuit qui égarent les gens, et de vengeance contre qui leur fait du tort. Dire leurs vrais noms est tabou dans certaines communautés ([Native Languages of the Americas](https://www.native-languages.org/morelegends/stick-indians.htm)).
- Un terme sahaptin est à l'origine de l'anglais local « stick-showers », des êtres dits pousser des bâtons dans les tentes ([Chinook Jargon, D. Robertson](https://chinookjargon.com/2021/03/17/pre-1917-ka-mi-akin-last-hero-of-the-yakamas-part-2-of-2/)).

**Ce que le jeu en fait :** un seul panneau au musée du lobby, résumant ces récits avec leurs sources, et précisant que ce sont des cultures vivantes. **Ce que le jeu ne fait pas :** la créature n'est jamais appelée d'un nom autochtone, aucun personnage autochtone n'est caricaturé, le sommet du volcan n'est jamais jouable. Les sifflements et les bâtons dans la tente existent en jeu, mais comme comportements du Bigfoot (section 9), pas comme « magie indienne ».

### 2.3 Le scénario (fiction)

**Fin octobre, de nos jours.** Quatre géologues de la Pacific Cascades University (fictive) ont disparu près d'Ape Canyon il y a 21 jours. Les recherches sont suspendues pour la météo, la route 83 est fermée. Les membres du podcast étudiant « Cold Trail » y vont quand même, une nuit.

Les joueurs découvrent trois vérités, dans cet ordre :

1. **Les tunnels.** Les géologues ont trouvé un prolongement inconnu d'Ape Cave, que la créature utilise comme repaire.
2. **La famille.** Il n'y a pas une créature mais un groupe, comme les récits de 1924 qui en décrivaient plusieurs.
3. **La faute.** Le chef des géologues a abattu un juvénile au jour J-19. Cette nuit est une vengeance.

Pourquoi la zone soufflée est interdite : l'éruption de 1980 a effondré une partie des tunnels et chassé la famille vers le sud. Depuis, les wapitis revenus paître dans les cendres sont leurs proies. Les rangers ont fermé la zone « pour instabilité du sol » (explication du [document Carte](https://claude.ai/artifact/3kbHEGv6jw9Lsbfc1wDSsT), fiction).

### 2.4 Chronologie fictive

| Jour | Événement | Trace trouvable en jeu |
| --- | --- | --- |
| J-30 | L'équipe Whitcombe installe son camp (P09) | Tentes, permis de recherche |
| J-24 | Sarah Ito cartographie un passage derrière l'éboulement P21 | Carte des tunnels (DOC\_07) |
| J-21 | Premières pierres lancées la nuit sur le camp | Cassette DOC\_03 |
| J-19 | Whitcombe abat un juvénile près de la cascade P13 et tente de cacher le corps ; la famille le récupère dans la nuit | Cassette DOC\_05, bâche ensanglantée et douilles (P13) |
| J-18 | Ben Castillo disparaît en allant chercher de l'eau | Botte et lampe près du ruisseau |
| J-17 | Le camp est attaqué de nuit ; Leah Brandt est tuée | Corps (P09), tablette des géologues |
| J-16 | Whitcombe et Ito fuient vers la tour P11 ; Ito y laisse un message | Message radio DOC\_09 |
| J-15 | Whitcombe descend seul dans les tunnels pour « réparer » sa faute | Son corps dans le repaire (P07b) |
| J-14 | Sarah Ito, blessée, se cache dans la mine P15 | Carnet DOC\_10, sa mort |
| J0, 18 h 30 | Arrivée des joueurs | — |

### 2.5 Personnages jouables (fictifs, apparence imposée)

| Rôle | Nom | Âge | Phrase de présentation (lobby) |
| --- | --- | --- | --- |
| Meneur | Caleb Marsh | 22 | « J'ai créé Cold Trail. Si on rentre bredouilles, c'est ma faute. » |
| Médecin | Priya Natarajan | 23 | « Infirmière en dernière année. Je n'aime pas le sang des autres. » |
| Pisteur | Wyatt Dunn | 21 | « Mon père chasse ici depuis trente ans. Il n'y monte plus. » |
| Caméraman | Theo Lindqvist | 20 | « Une vidéo nette. Une seule. Et on entre dans l'histoire. » |
| Mécanicienne | Rosa Delgado | 22 | « Si ça a un moteur, je le fais repartir. » |
| Descendante | Nora Halvorsen | 19 | « Mon arrière-arrière-grand-père était dans la cabane, en 1924. » |
| Géologue | Malik Okafor | 24 | « Sarah Ito est mon amie. Je la ramène. » |
| Sportif | Jake Kowalski | 21 | « Je porte, je cours, je ne pose pas de questions. » |
| Opératrice radio | Mei Tanaka | 20 | « Il y a toujours quelqu'un qui écoute. Toujours. » |
| Pyrotechnicien | Dylan Croft | 19 | « J'ai apporté des fusées. Beaucoup de fusées. » |

Correction par rapport au GDD : une étudiante de 19 ans ne peut pas être la petite-fille d'un mineur de 1924 ; Nora est son **arrière-arrière-petite-fille**. Le mineur n'est jamais nommé, pour ne pas inventer de descendance à une vraie famille.

**Identifiants de code des rôles :** Meneur `Leader`, Médecin `Medic`, Pisteur `Tracker`, Caméraman `Cameraman`, Mécanicienne `Mechanic`, Descendante `Descendant`, Géologue `Geologist`, Sportif `Athlete`, Opératrice radio `RadioOperator`, Pyrotechnicien `Pyrotechnician`. Partout où la bible écrit `<ROLE>`, c'est l'un de ces identifiants.

### 2.6 Personnages non jouables (fictifs)

| Nom | Rôle | Où |
| --- | --- | --- |
| Ranger Dale Hollis | Accueille au lobby, rappelle l'ordonnance, refuse de les accompagner | Station des rangers du lobby |
| Dr Alan Whitcombe | Chef des géologues, a tué le juvénile | Mort dans le repaire P07b |
| Sarah Ito | Doctorante, a cartographié les tunnels | Morte dans la mine P15 |
| Ben Castillo | Étudiant en master | Disparu ; restes traînés près du lac P20 |
| Leah Brandt | Technicienne | Morte au camp P09 |

### 2.7 Documents trouvables (texte définitif)

Langue source : français. Claude Code peut traduire en anglais via `LocalizationTable`, sans changer le sens. Chaque document a un emplacement fixe ou un tirage parmi les points d'indice C01–C12 (section 3).

| ID | Type | Lieu | Texte affiché / audio |
| --- | --- | --- | --- |
| DOC\_01 | Avis de recherche | Lobby, P01 | « DISPARUS depuis le 7 octobre : Dr A. Whitcombe, S. Ito, B. Castillo, L. Brandt. Recherches suspendues. Toute information : Skamania County Sheriff. » (numéro fictif, jamais un vrai) |
| DOC\_02 | Permis de recherche | P09 | « Pacific Cascades University — relevé géophysique des tubes de lave, secteur sud. Autorisation 30 jours. Interdiction d'entrer dans la zone fermée. » |
| DOC\_03 | Cassette 1 (Ito) | Tiré C01–C04 | « Jour 9. Encore des cailloux sur la bâche cette nuit. Alan dit que c'est le vent. Le vent ne vise pas. » |
| DOC\_04 | Carnet de terrain (Castillo) | Tiré C01–C06 | « Trois coups sur un tronc, au nord. Puis trois coups au sud. Ils se répondent. » |
| DOC\_05 | Cassette 2 (Whitcombe) | Tiré C05–C08 | « Il était petit. Il s'est approché du camp. J'ai tiré. Personne ne doit savoir. On part dans deux jours. » |
| DOC\_06 | Photo d'empreinte | Tiré C03–C08 | Image + légende « 41 cm. Deux tailles différentes sur la même piste. » |
| DOC\_07 | Carte des tunnels | Tablette des géologues (P09) | Plan du réseau P07a–P07c ; débloque la fin secrète |
| DOC\_08 | Vidéo de la tablette | Tablette des géologues | Cutscene CS\_05 (section 6) |
| DOC\_09 | Message radio (Ito) | Tour P11, rejoué si la radio est réparée | « Ici Ito, tour de guet. Alan est descendu. Il dit qu'il va leur rendre. Si quelqu'un entend… ne dormez pas près de l'eau. » |
| DOC\_10 | Dernier carnet (Ito) | P15 | « Ils ne mangent pas les morts tout de suite. Ils les rangent. Comme des réserves. Ou comme des avertissements. » |
| DOC\_11 | Rapport des rangers de 1924 (résumé) | Musée du lobby | Résumé neutre de l'enquête Huffman et Welch, avec lien source |
| DOC\_12 | Carnet de la famille Halvorsen | Inventaire de Nora | 3 pages manuscrites fictives. Page 1 : « Il n'a jamais voulu en parler. Il disait seulement : ne tire pas le premier. » Page 2 (débloquée au siège) : « Ils frappaient les arbres avant les pierres. » Page 3 (fin « La vérité ») : « On leur avait pris quelqu'un, à eux aussi. » |
| DOC\_13 | Note du ranger Hollis | Poste P17 | « Zone fermée. Officiellement le sol. Officieusement, on retrouve des wapitis sans tête. Ne restez pas après la nuit tombée. » |
| DOC\_14 | Enregistrement météo | Station P23 | Fichier audio : 40 s de vent, puis un cri long à distance (SFX\_Call\_Long\_01) |
| DOC\_15 | Panneau « Sasquatch Refuge » | Entrées de forêt | « SKAMANIA COUNTY — SASQUATCH REFUGE — Ord. 69-01 » (panneau fictif, pas de logo officiel) |
| DOC\_16 | Photo de groupe des géologues | P09 | Image fictive, 4 personnes souriantes, date J-30 |

## 3. Carte de la partie : coordonnées et génération

La carte fait 8 000 × 8 000 studs, soit 2,24 km de côté, puisque 1 stud = 28 cm selon la [doc Roblox](https://create.roblox.com/docs/physics/units). Elle compresse d'environ 4,5 fois le vrai secteur sud-est du volcan : le sentier réel d'Ape Canyon monte de 1 300 pieds sur 4,8 miles ([The Columbian](https://columbian.com/news/2013/jul/10/ape-canyon-trail-mount-hiking)), et il en garde l'ordre des lieux et des altitudes.

Les positions reprennent exactement celles du [document Carte validé](https://claude.ai/artifact/3kbHEGv6jw9Lsbfc1wDSsT). Seule la notation change, pour coller au repère de Roblox.

### 3.1 Repère

- Centre de la carte = origine du monde `(0, 0, 0)`. X va vers l'est, Z vers le sud, **le nord est −Z**.
- Zone jouable : X et Z de −4 000 à +4 000. Bande décorative non jouable jusqu'à ±4 600.
- Conversion depuis l'ancien document (origine au coin nord-ouest) : `X = x − 4000`, `Z = y − 4000`.
- Altitude Y : 0 = point le plus bas (sortie du ruisseau principal au sud-ouest). Point jouable le plus haut : Y = 560 (station météo). Compression verticale choisie ≈ 4 fois, comme l'horizontale.
- Vitesses du jeu (section 7) : marche 12 studs/s, course 20 studs/s. Un côté de carte = 11 min de marche, 6 min 40 s de course continue.

&#91;embedded content: carte 8 000 × 8 000 studs · coordonnées monde · 26 lieux, F01, T5\]

Chaque carré de la grille fait 2 000 studs. Les positions exactes sont dans les tableaux ci-dessous ; en cas d'écart, le tableau gagne.

### 3.2 Lieux (Y = altitude du sol)

| Code | Lieu | Statut | X | Z | Y | Rayon (studs) | Fonction |
| --- | --- | --- | --- | --- | --- | --- | --- |
| P01 | Parking du sentier d'Ape Canyon | Réel, déplacé | 2 800 | 3 200 | 120 | 60 | Départ S1, van, extraction E1 |
| P02 | Coulée de lahar | Réel | 1 800 → 2 400 | −1 500 → 3 600 | 110 (sud) → 380 (nord) | couloir 600 de large | Axe rapide mais à découvert |
| P03 | Lava Canyon (fond de gorge) | Réel | 3 200 | 2 200 | bord 110, fond 40 | 120 | Gorge sonore, cascades |
| P04 | Forêt ancienne | Réel (type de forêt) | 507 → 1 800 | −507 → 2 507 | 150 → 330 | zone | Exploration, traque |
| P05 | Ape Canyon | Réel | 2 600 | −1 400 | bord 400, fond 250 | 300 | Acte 2, le siège |
| P05c | Ruine de la cabane de 1924 | Lieu réel, emplacement fictif | 2 550 | −1 300 | 300 (corniche) | 25 | Barricade du siège |
| P05s | « Étroit » du canyon | Réel : la gorge se resserre jusqu'à 8 pieds ([Wikipedia](https://en.wikipedia.org/wiki/Ape_Canyon)) | 2 700 | −1 650 | 330 | 9 de large | Passage étroit, piège |
| P06 | Plateau de cendres | Réel (Plains of Abraham) | 1 200 | −2 600 | 480 | 900 | Vue sur le volcan, à découvert |
| P07a | Ape Cave, entrée principale | Réel | −2 507 | 2 400 | 60 (sol du tube Y = 5) | 20 | Entrée du réseau |
| P07b | Salle du repaire | Fiction | −2 900 | 1 700 | 30 (souterrain) | 45 | Repaire, corps de Whitcombe, femelle |
| P07c | Sortie basse bouchée par le lahar | Réel (bouchon) + fiction (sortie) | −2 300 | 3 600 | 20 | 6 | Extraction E4 (fin secrète) |
| P08 | Zone interdite (forêt soufflée) | Fiction greffée sur 1980 | −3 707 → −507 | −3 707 → −800 | 300 → 430 | zone | Terrain de chasse, raccourci |
| P09 | Camp des géologues | Fiction | −800 | 600 | 230 | 50 | Départ S3, indices, corps |
| P10 | Chantier forestier abandonné | Fiction | −1 400 | 3 307 | 70 | 80 | Départ S2, bulldozer, extraction E3 |
| P11 | Tour de guet centrale | Fiction | 0 | −1 600 | 420 (cabine +60) | 15 | Radio, extraction E2 |
| P12 | Prairie et clairières | Fiction | −2 200 | 200 | 200 | 350 | Respiration, visible de loin |
| P13 | Cascade et bassin | Fiction | −1 800 | 1 200 | haut 210, bassin 150 | 40 | Bruit d'eau, lieu de la mort du juvénile |
| P14 | Volcan (décor) | Réel, hors limites | −500 | −10 000 | sommet 2 600 | — | Repère visuel |
| P15 | Mine abandonnée | Fiction | 3 333 | −667 | 390 | 30 | Corps d'Ito, munitions possibles |
| P16 | Pont sur le ruisseau de Lava Canyon | Un pont existe sur ce sentier ([The Columbian](https://columbian.com/news/2012/jul/10/lots-hike-lava-canyon)), emplacement fictif | 3 467 | 1 600 | tablier 150, eau 100 | 30 de long | Passage obligé, grince |
| P17 | Poste des rangers fermé | Fiction | 800 | 3 067 | 110 | 25 | Radio, carte murale, pièces |
| P18 | Barrière de la zone interdite | Fiction | −400 | −667 | 300 | 10 | Panneaux « Area closed » |
| P19 | Charnier de wapitis | Fiction | −2 933 | −2 667 | 380 | 40 | Preuve de classe B |
| P20 | Lac aux troncs flottants | Clin d'œil au lac Spirit | −1 667 | −1 733 | eau 330 | 600 × 320 (demi-axes X, Z) | Restes de Castillo |
| P21 | Tunnel effondré (puits) | Fiction | −3 200 | 933 | 140 (tube Y = 85) | 15 | Second accès au réseau |
| P22 | Épave de voiture | Fiction | 533 | 3 733 | 100 | 10 | Batterie, cric |
| P23 | Station météo | Fiction | 2 400 | −3 467 | 560 | 12 | Point haut, enregistrement DOC\_14 |
| P24 | Tour est | Fiction | 3 800 | 667 | 300 (cabine +60) | 12 | Vue sur la gorge et la mine |
| P25 | Tour nord | Fiction | −200 | −3 067 | 470 (cabine +60) | 12 | Vue sur le lac et le charnier |
| P26 | Tour ouest | Fiction | −3 600 | −667 | 260 (cabine +60) | 12 | Vue sur la prairie et Ape Cave |
| F01 | Falaise de la Crête (**nouveau**) | Fiction | −507 → 1 800 | −800 | marche de 40 | 40 de haut | Ferme le nord sauf par les lacets de P11 (passage X = −100 à +100) |

### 3.3 Départs, extractions, zones de la créature

| Code | Type | Position (X, Y, Z) | Détail |
| --- | --- | --- | --- |
| S1 | Départ | 2 780, 120, 3 220 | Autour du van ; 10 points espacés de 6 studs |
| S2 | Départ | −1 380, 70, 3 290 | Autour du bulldozer |
| S3 | Départ | −820, 230, 640 | Dans le camp, corps visibles |
| E1 | Extraction van | 2 800, 120, 3 200 | Clés + pneu réparé, puis sortir par la route 83 vers X = 4 000 |
| E2 | Extraction hélicoptère | aire de 60 × 60 en −150, 425, −1 750 | Radio de P11 réparée, tenir 180 s |
| E3 | Extraction bulldozer | barrière en −1 400, 70, 3 950 | Carburant + relais, forcer la barrière |
| E4 | Extraction tunnels | P07c | Carte DOC\_07, dégager le bouchon (60 s d'action) |
| B1 | Zone créature : siège | P05 | Pierres depuis le bord du canyon sur la cabane |
| B2 | Zone créature : repaire | P07a–P07c | Famille, femelle |
| B3 | Zone créature : chasse | P08 | Chasse à découvert, carcasses |
| B4 | Zone créature : traque | P04 | Observation, filature |
| B5 | Zone créature : embuscade | P02 | Attaque pendant les traversées |
| B6 | Zone créature : mise en scène | P09 | Corps déplacés entre deux passages |

### 3.4 Points tirés au hasard

Chaque partie tire 6 points d'indice sur 12, et un emplacement par objet clé. Graine aléatoire = `os.time()` au lancement du serveur, écrite dans la console pour rejouer un bug.

| Code | Lieu | X, Y, Z | Peut contenir |
| --- | --- | --- | --- |
| C01 | Camp, tente nord | −780, 232, 560 | DOC\_03, DOC\_04 |
| C02 | Camp, glacière | −840, 230, 640 | DOC\_03, DOC\_04 |
| C03 | Prairie, souche | −2 150, 200, 260 | DOC\_03, DOC\_04, DOC\_06 |
| C04 | Cascade, rocher | −1 760, 152, 1 240 | DOC\_03, DOC\_04, DOC\_06 |
| C05 | Forêt, arbre creux | 1 100, 240, 900 | DOC\_04, DOC\_05, DOC\_06 |
| C06 | Épave, boîte à gants | 533, 100, 3 733 | DOC\_04, DOC\_05, DOC\_06 |
| C07 | Poste des rangers, bureau | 800, 112, 3 067 | DOC\_05, DOC\_06 |
| C08 | Mine, entrée | 3 300, 390, −640 | DOC\_05, DOC\_06 |
| C09 | Pied de la tour P11 | 20, 420, −1 580 | piles, bandages |
| C10 | Lahar, gros bloc | 2 100, 260, 400 | piles, fusée |
| C11 | Pont, culée | 3 440, 150, 1 620 | bandages, corde |
| C12 | Tour ouest, cabine | −3 580, 320, −650 | piles, attelle |
| K1–K3 | Clés du van (1 tirée) | −760, 230, 610 · −900, 229, 700 · −1 500, 215, 420 | Clés |
| A1–A5 | Boîte de munitions (1 tirée) | P17 (820, 112, 3 050) · P15 (3 360, 390, −700) · P26 cabine · P10 cabane (−1 380, 72, 3 280) · P19 (−2 800, 380, −2 550) | 5 balles de fusil + 6 de rev. + 4 cartouches |
| J1–J2 | Cric (1 tiré) | P22 coffre · P17 garage | Cric |
| R1–R2 | Câble d'antenne (1 tiré) | P23 · P17 | Câble coaxial |
| R3 | Batterie | P22, fixe | Batterie de voiture (lourde) |
| R4–R6 | Jerrican (1 tiré) | P17 · P22 · P15 | Carburant |
| R7 | Relais de démarreur | P17, fixe | Pièce du bulldozer |

### 3.5 Eau, routes et sentiers (polylignes)

Les points sont des (X, Z) ; Y suit le terrain. Les courbes sont des Béziers cubiques (départ, contrôle 1, contrôle 2, arrivée).

| Code | Type | Tracé | Largeur (studs) |
| --- | --- | --- | --- |
| R1 | Ruisseau principal | (533, −3 067) → c(−133, −1 600) → c(−1 067, −267) → **P13** (−1 800, 1 200) → c(−2 200, 2 133) → c(−2 800, 3 067) → (−3 067, 4 000) | 6 à la source, 14 au milieu, 24 sous la cascade, 30 à la sortie |
| R2 | Ruisseau de Lava Canyon | (3 067, −1 600) → c(3 467, 0) → c(3 067, 1 200) → (3 467, 2 400) → c(3 667, 3 067) → c(3 600, 3 600) → (3 733, 4 000) | 8 → 16 → 22 ; rapides dans la gorge |
| R3 | Exutoire du lac | (−1 067, −1 733) → c(−667, −1 067) → c(−533, −533) → rejoint R1 vers (−700, −100) | 5 → 8 |
| RD1 | Route forestière 83 (réelle) | (4 000, 3 467) → P01 → P03 (3 200, 2 200) | 18, asphalte usé |
| RD2 | Piste du chantier (fictive) | (−1 400, 4 000) → P10 → P07a | 14, gravier et boue |
| T1 | Sentier d'Ape Canyon (réel, n° 234) | P01 → (2 400, 1 867) → (2 200, 267) → P05 → P06 | 6 |
| T2 | Sentier de la forêt | P01 → c(933, 2 400) → c(0, 1 200) → P09 → P12 → P07a | 5 |
| T3 | Sentier de la tour | P09 → passage F01 (0, −800) → lacets → P11 → P06 | 5 |
| T4 | Sentier de la gorge | P16 → P15 → P05 | 4 |
| T5 | Piste des wapitis (non balisée) | P12 → (−1 500, −1 000) → (−900, −2 300) → P25 → P06 | aucune, herbe couchée |

Raccourci par la zone interdite : de P12 à P06, T5 fait environ 5 300 studs contre 6 700 par T2 et T3 (lacets de F01 compris). À 12 studs/s, le gain réel est donc d'environ **2 min**, et non 3 min comme écrit dans l'ancien document : correction.

### 3.6 Biomes et végétation

| Biome | Où | Sol (matériau Roblox) | Arbres pour 10 000 studs² | Sous-bois |
| --- | --- | --- | --- | --- |
| Forêt ancienne | P04, abords de T2 | LeafyGrass + Ground, mousse | 9 (sapins de Douglas, pruches) | Fougères denses, troncs couchés |
| Forêt mixte | Tout le reste du sud | Grass + Ground | 6 | Fougères, buissons |
| Prairie | P12 | Grass haute | 0,3 (arbres isolés) | Herbe animée par le vent |
| Lahar | P02 | Pebble + Rock | 0 | Blocs, galets |
| Gorges | P03, P05 | Basalt + Rock | 1 sur les bords | Mousse, éboulis |
| Plateau | P06, P23 | Sand recoloré gris cendre (#7A7670) + Pebble | 0,2 (pins rabougris) | Fleurs rares |
| Zone interdite | P08 | Sand cendre + Ground | 0 vivant ; 4 chicots + 6 troncs couchés orientés nord-sud | Carcasses, aucun sous-bois |

Plafond global : 20 000 modèles de végétation et rochers. Au-delà de 700 studs, les arbres passent en maillage simplifié (`Model.LevelOfDetail = StreamingMesh`).

### 3.7 Génération procédurale (en mode Edit, une seule fois)

Le terrain est généré par un script d'édition, `TerrainBuilder`, avec la graine fixe **1924**, pour que la carte soit identique à chaque régénération.

1. **Relief de base :** somme de collines gaussiennes centrées sur les ancres ci-dessous, plus une pente douce qui monte du sud (Y ≈ 40) vers le nord (Y ≈ 420).
2. **Bruit :** bruit fractal à 5 octaves, période de base 1 600 studs, amplitude 60, chaque octave à fréquence double et amplitude moitié. Bruit en crêtes d'amplitude 40 sur les crêtes.
3. **Rivières :** pour chaque polyligne, creuser un lit de profondeur 0,35 × largeur + 4, raccordé au terrain sur 3 × la largeur. Le fond doit toujours descendre vers l'aval.
4. **Gorges :** Ape Canyon (150 de profondeur, de (2 300, −600) à (3 000, −2 200)) et Lava Canyon (70 de profondeur, le long de R2 entre Z = 1 600 et 2 600), parois en Basalt.
5. **Aplanir** chaque lieu sur son rayon, raccordé sur 1,5 fois le rayon.
6. **Routes et sentiers :** pente maximale 8 % pour les routes, 15 % pour les sentiers (sinon lacets).
7. **Matériaux :** pente > 40° = Rock ou Basalt ; puis les matériaux des biomes ; textures Poly Haven via `MaterialVariant`.
8. **Eau :** eau du terrain pour R1, R2, R3 et le lac P20.
9. **Végétation :** répartition aléatoire avec distance minimale entre arbres (11 studs en forêt ancienne), rotation libre, échelle ±15 %, rangée dans `Workspace/Vegetation/Chunk_X_Z` (blocs de 512 studs).

| Ancre | X, Z | Hauteur visée | Rayon |
| --- | --- | --- | --- |
| Dôme du plateau | 1 200, −2 733 | 520 | 1 470 × 800 (ellipse) |
| Crête de la tour | 200, −1 573 | 430 | 800 × 373 |
| Crête est | 3 200, −800 | 400 | 667 × 933 |
| Colline ouest | −3 067, 1 200 | 220 | 733 × 533 |
| Cuvette du lac | −1 667, −1 733 | 320 (creux) | 700 × 420 |

### 3.8 Limites et décor lointain

- **Nord :** pentes d'éboulis infranchissables qui montent vers le volcan. Le volcan est un maillage lointain (P14), pas du terrain, vu depuis le sud : on n'y voit pas la brèche du cratère, qui s'ouvre au nord ([Wikipedia](https://en.wikipedia.org/wiki/Mount_St._Helens)).
- **Sud :** au-delà de Z = 4 600, un plan d'eau décoratif évoque le réservoir Swift, situé directement au sud du sommet ([Wikipedia](https://en.wikipedia.org/wiki/Mount_St._Helens)).
- **Est et ouest :** collines boisées noyées dans le brouillard.
- À ±3 900, message « Tu t'éloignes trop du groupe » ; mur invisible à ±4 000, caché par des obstacles naturels (troncs, rochers, pentes).

## 4. Lobby : la ville, le récit, le départ

Le lobby est une place Roblox séparée, sans aucun danger : une petite ville forestière au crépuscule, inspirée de Cougar, la localité la plus proche du volcan (118 habitants, au bord du lac Yale, [Wikipedia](https://en.wikipedia.org/wiki/Cougar,_Washington)). Les commerces sont fictifs : aucun vrai nom d'enseigne, aucun logo officiel.

### 4.1 Plan du lobby (place « Lobby », 600 × 600 studs)

| Code | Bâtiment | X, Y, Z | Rôle |
| --- | --- | --- | --- |
| L01 | Point d'apparition | 0, 5, 120 | Arrivée des joueurs, vue sur la rue principale |
| L02 | Station des rangers | −80, 5, 20 | PNJ Dale Hollis, avis de recherche DOC\_01, rappel de l'ordonnance |
| L03 | Musée « Ape Canyon 1924 » | 80, 5, 20 | 8 panneaux du récit réel (4.3), moulages, preuves du joueur |
| L04 | Magasin général | −80, 5, −80 | Choix des skins et de l'équipement cosmétique |
| L05 | Diner | 80, 5, −80 | Tableau des records, tableau de liège des preuves |
| L06 | Parking et van | 0, 5, −180 | Création de groupe, choix des rôles, armes, votes, départ |
| L07 | Ponton sur le lac | 0, 0, 260 | Décor, vue sur le volcan au loin |

### 4.2 Arrivée d'un joueur

1. **Première connexion :** cinématique CS\_00 (section 6), passable après 10 s.
2. Le joueur apparaît en L01. Un indicateur discret propose : « Parle au ranger ».
3. **Dialogue du ranger** (bulles, 3 choix) :
   - Hollis : « Vous êtes les gamins du podcast ? Je vais vous dire ce que j'ai dit aux autres : n'y allez pas. »
   - Choix « Qu'est-ce qui s'est passé en 1924 ? » → « Allez voir le musée d'en face. Et lisez le rapport des rangers, pas seulement l'histoire des mineurs. »
   - Choix « On a le droit de tirer ? » → « Sur un ours, si vous n'avez pas le choix. Sur l'autre chose… Ordonnance 69-01. Ici, c'est un refuge. »
   - Choix « Où sont les géologues ? » → « Si je le savais, je ne serais pas assis ici. La route 83 est fermée. Officiellement, vous ne passez pas. »
4. Le musée se visite librement ; chaque panneau lu donne 5 XP la première fois.

### 4.3 Le récit réel au musée (texte des 8 panneaux)

Chaque panneau affiche son texte, une image d'ambiance (créée, pas une photo réelle copiée) et une ligne « Source » (publication et titre, sans adresse web : voir 19.5). Une voix off lit le texte (VO\_Museum\_01 à 08, enregistrée par Gabriel ou un proche).

| Panneau | Titre | Texte |
| --- | --- | --- |
| M1 | Juillet 1924 | Des prospecteurs travaillent près d'une gorge au sud-est du volcan. Ils disent avoir vu des créatures d'environ deux mètres. L'un d'eux tire. La nuit suivante, leur cabane est bombardée de pierres jusqu'à l'aube. |
| M2 | L'enquête | Deux rangers descendent dans la gorge. Ils ne trouvent rien et montrent que les empreintes peuvent être truquées. La presse, elle, baptise l'endroit Ape Canyon. |
| M3 | Le témoin | Fred Beck racontera l'histoire toute sa vie. En 1967, son livre y ajoute une dimension spirituelle absente des récits de 1924. |
| M4 | Ape Cave | Un tube de lave de près de 4 km, formé il y a 2 000 ans, découvert en 1947 par un bûcheron. Son nom vient d'un groupe local, les St. Helens Apes. |
| M5 | L'ordonnance 69-01 | Le 1er avril 1969, le comté de Skamania fait du meurtre d'un Sasquatch un crime. Ce n'est pas une blague. En 1984, le comté devient un refuge. |
| M6 | 18 mai 1980 | À 8 h 32, le flanc nord s'effondre. 57 personnes meurent. Au nord, la forêt est couchée sur 600 km² et le lac Spirit se couvre de troncs. |
| M7 | Lawetlat'la | Pour les Cowlitz, le volcan est Lawetlat'la, « celui qui fume » ; pour les Klickitat, Loowit. Plusieurs peuples du Nord-Ouest racontent aussi des êtres de la forêt dont on évite de dire le nom. Ces récits appartiennent à des cultures vivantes. |
| M8 | Disparus (fiction) | Il y a 21 jours, quatre géologues ont cessé de répondre. Les recherches sont suspendues. Leur dernier message parlait de pierres lancées sur leur camp. |

Le panneau M8 porte la mention « Fiction » en petit, pour que la frontière réel / inventé reste claire.

### 4.4 Former un groupe et partir

1. Au van (L06), un joueur crée un groupe **public** ou **privé** (code à 4 chiffres). Capacité 1 à 10.
2. File « Rejoindre un groupe » : complète les groupes publics incomplets (MemoryStore, section 16).
3. **Rôles :** chaque joueur choisit un rôle libre parmi les 10. Meneur et Caméraman sont proposés en premier. Sous 10 joueurs, les rôles non pris n'existent pas dans la partie.
4. **Armes :** le tableau du van affiche les armes disponibles selon la taille du groupe (section 8). Un joueur clique pour en prendre une ; en cas de conflit, vote à la majorité en 15 s, sinon tirage.
5. **Votes :** difficulté (Normal, Difficile, Cauchemar si débloquée) et météo (aléatoire ou fixe).
6. Tous « Prêt » → compte à rebours de 10 s → cinématique CS\_01 (les joueurs montent dans le van) → téléportation vers un serveur réservé de la place « Partie ».
7. Données transmises : liste des joueurs, rôles, armes, difficulté, météo, départ tiré (S1, S2 ou S3, une chance sur trois chacun).
8. **Retour :** après la fin, retour au lobby, écran de résultats (fin obtenue, survivants, preuves sorties, XP), puis apparition en L01.

### 4.5 Ce qu'il y a à faire entre deux parties

- Magasin (L04) : équiper les skins débloqués par personnage.
- Diner (L05) : records du serveur (plus grand nombre de survivants, preuves de classe A, fins débloquées).
- Musée (L03) : preuves personnelles sorties de la forêt, pages du carnet Halvorsen débloquées.
- Mode « La nuit suivante » (débloqué par la fin Ordonnance 69-01) : la famille attaque la ville. **Hors périmètre de la version 1**, à concevoir plus tard.

### 4.6 Messages système (lobby et lancement)

Textes définitifs, affichés par `NotificationGui`. `{player}` et `{n}` sont remplacés par le code. Un message nécessaire qui manque ici devient un `TODO(BIBLE)`.

| Clé | Texte |
| --- | --- |
| MSG\_PartyFull | Ce groupe est complet (10 joueurs). |
| MSG\_CodeInvalid | Aucun groupe ne correspond à ce code. |
| MSG\_QuickJoinNone | Aucun groupe public disponible. Crée le tien. |
| MSG\_PartyLeft | Tu as quitté le groupe. |
| MSG\_HostLeft | Le créateur du groupe est parti. {player} prend sa place. |
| MSG\_RoleTaken | Ce rôle est déjà pris par {player}. |
| MSG\_RoleRequired | Choisis un rôle avant d'être prêt. |
| MSG\_WeaponTaken | Cette arme est déjà attribuée à {player}. |
| MSG\_WeaponNotAllowed | L'opératrice radio ne peut pas porter d'arme à feu. |
| MSG\_WeaponVote | Deux joueurs veulent la même arme. Votez : 15 secondes. |
| MSG\_NightmareLocked | Cauchemar se débloque après une première survie. |
| MSG\_WaitingReady | En attente : {n} joueur(s) pas encore prêt(s). |
| MSG\_Countdown | Départ dans {n} s. |
| MSG\_CountdownCancelled | Départ annulé : un joueur n'est plus prêt. |
| MSG\_Teleporting | En route vers la forêt… |
| MSG\_TeleportRetry | Le départ a échoué. Nouvel essai… |
| MSG\_TeleportAbort | Impossible de partir pour l'instant. Réessayez dans un moment. |
| MSG\_WaitingPlayers | En attente des autres membres du groupe… |
| MSG\_PlayerMissing | {player} n'a pas rejoint la forêt. |
| MSG\_VersionMismatch | Une mise à jour est en cours. Retour en ville. |
| MSG\_ReturnToLobby | Retour en ville… |
| MSG\_DataLoadFailed | Ta progression n'a pas pu être chargée. Elle ne sera pas sauvegardée pendant cette session. |

Cas ajouté : configuration de partie introuvable dans la Partie → **MSG\_LaunchConfigMissing** : « La partie n'a pas pu être préparée. Retour en ville. » (remplace l'usage provisoire de MSG\_ReturnToLobby).

## 5. Déroulé d'une partie

Une partie dure 35 à 52 minutes réelles, du crépuscule à l'aube du **28 octobre**, en cinq actes. Avec le lobby, une session complète reste sous 1 h 30. Les objectifs font avancer les actes ; chaque acte a une durée maximale pour qu'un groupe ne stagne pas.

### 5.1 Horloge

L'heure affichée dépend de l'acte, pas d'un chronomètre fixe. Dans un acte, elle avance linéairement de l'heure de début à l'heure de fin sur la durée maximale de l'acte. Au changement d'acte, elle saute à l'heure de début suivante en 10 s (ciel accéléré).

| Acte | Heure en jeu | Durée min → max (réelle) | Passage à l'acte suivant |
| --- | --- | --- | --- |
| 0. Arrivée | 18 h 30 → 19 h 00 | 3 min fixes | Automatique |
| 1. L'enquête | 19 h 00 → 22 h 00 | 10 → 15 min | Tablette des géologues lue ET 3 indices trouvés, ou durée max |
| 2. Le siège | 22 h 00 → 00 h 00 | 8 → 14 min (trajet jusqu'à la cabine compris) | Fin du bombardement (6 min après le début du siège) |
| 3. La chasse | 00 h 00 → 05 h 00 | 10 → 15 min | Conditions d'extraction réunies, ou durée max |
| 4. L'aube | 05 h 00 → 06 h 00 | 3 → 5 min | Extraction, ou 06 h 00 |

À 06 h 00 (au plus tard 55 min réelles après le début), la partie s'arrête. Les joueurs encore dans la forêt sont **disparus**.

### 5.2 Les actes en détail

**Acte 0, l'arrivée.** Cinématique CS\_02 selon le départ tiré. La faune est bruyante (oiseaux, écureuils). Le Meneur reçoit la tablette de terrain. Objectif affiché : « Trouver le camp des géologues ». La créature ne se montre pas ; elle a déjà repéré le van.

**Acte 1, l'enquête.**

1. Atteindre P09 (déjà fait si départ S3) : cinématique CS\_04 à la première entrée.
2. Trouver la tablette des géologues dans la tente de Leah Brandt : elle contient DOC\_07 (carte des tunnels) et DOC\_08 (vidéo, cinématique CS\_05).
3. Trouver 3 des 6 indices tirés.
4. La tablette indique le point de repli prévu par l'équipe : la cabane de 1924 (P05c). Nouvel objectif : « Rejoindre la cabane avant minuit ».

Créature : observation, coups sur les troncs au loin, structures de branches, silence de la faune. Au moins un aperçu lointain garanti par le directeur.

**Acte 2, le siège.** La météo se dégrade (pluie ou neige selon le tirage). Le siège commence 60 s après l'entrée du premier joueur dans la cabane, ou à 23 h 05 si personne n'y est.

1. Barricader 3 ouvertures : porte, fenêtre, trou du toit (planches trouvées dans la cabane ; 8 s par planche, 4 s pour le Sportif).
2. Tenir 6 minutes de bombardement. Les pierres frappent le toit et les murs ; une planche reçoit 4 impacts avant de céder.
3. Une barricade cédée = tentative d'entrée (bras qui passe, saisie possible).
4. Fin : silence total 20 s, puis cinématique CS\_07. La page 2 du carnet Halvorsen se débloque. Le jeu annonce la voie d'extraction de la partie.

Un joueur resté dehors pendant le siège est la cible prioritaire.

**Acte 3, la chasse.** Une voie principale est tirée parmi E1, E2, E3. La voie secrète E4 est toujours ouverte si DOC\_07 a été lue.

| Voie | Ce qu'il faut | Où | Danger |
| --- | --- | --- | --- |
| E1 Van | Clés (K1–K3) + cric (J1–J2) ; changer la roue lacérée (20 s, 10 s pour la Mécanicienne) | P01 | Démarrage bruyant : attaque quasi certaine |
| E2 Hélicoptère | Câble d'antenne (R1–R2) + batterie (R3, lourde : course impossible) ; réparer la radio de P11 (30 s) ; appel ; tenir 180 s sur l'aire | P11 | Aire à découvert sur la crête |
| E3 Bulldozer | Jerrican (R4–R6) + relais (R7) ; réparer (40 s) ; conduire 650 studs jusqu'à la barrière | P10 | Lent (8 studs/s), la créature peut y grimper |
| E4 Tunnels | DOC\_07 + une lampe ; traverser le réseau P07a → P07b → P07c ; dégager le bouchon (60 s) | P07 | Femelle, obscurité totale |

**Acte 4, l'aube.** À 05 h 00, la créature lance le dernier assaut, le plus violent. Les joueurs doivent atteindre le point d'extraction et le déclencher. À l'aube, la créature se retire vers les tunnels (animal nocturne) : aucune attaque après 05 h 50, sauf dans les tunnels.

### 5.3 Fins

| Fin | Condition | Cinématique | Récompense |
| --- | --- | --- | --- |
| Survie | ≥ 1 joueur extrait par E1, E2 ou E3 | CS\_10, CS\_11 ou CS\_12 | XP selon les survivants |
| Preuve | Survie + une preuve de classe A sortie | idem + CS\_15 | XP majorée, entrée au musée |
| La vérité | ≥ 1 joueur extrait par E4 | CS\_13 | Page 3 du carnet, panneau final du musée |
| Ordonnance 69-01 | L'Alpha est tué (quel que soit le reste) | CS\_14 | Fin amère ; débloque la variante « La nuit suivante » (version 2) |
| Silence | Aucun survivant | CS\_16 | Le podcast est publié… incomplet |

Plusieurs fins peuvent se cumuler (ex. La vérité + Preuve). Ordonnance 69-01 remplace Survie.

### 5.4 Difficultés

| Réglage | Normal | Difficile | Cauchemar |
| --- | --- | --- | --- |
| Dégâts de la créature | ×1,0 | ×1,3 | ×1,6 |
| Portées de perception | ×1,0 | ×1,15 | ×1,3 |
| Points de vie de la créature | ×1,0 | ×1,25 | ×1,5 |
| Tir allié | Non | Oui | Oui |
| Temps à terre avant la mort | 45 s | 35 s | 25 s |
| Boîte de munitions de secours | Oui | Oui | Non |
| Indications d'objectif à l'écran | Oui | Oui | Non (tablette seulement) |
| Déblocage | Dès le début | Dès le début | Après une première survie |

**Sans vote :** difficulté Normal, météo aléatoire. **Égalité :** la difficulté la plus basse l'emporte ; pour la météo, aléatoire.

### 5.5 Taille du groupe

| Joueurs | Créatures en surface | Armes à feu | Événements du directeur |
| --- | --- | --- | --- |
| 1 à 3 | Alpha | 1 | ×0,8 |
| 4 à 6 | Alpha + 1 éclaireur | 2 | ×1,0 |
| 7 à 10 | Alpha + 2 éclaireurs | 3 | ×1,2 |

La femelle n'existe que dans les tunnels, quelle que soit la taille du groupe.

## 6. Cinématiques

Le jeu compte 17 cinématiques, toutes faites dans le moteur (caméra scriptable, pas de vidéo). En partie, elles durent 12 s au plus et ne coupent jamais une poursuite.

### 6.1 Règles communes

- **Technique :** `Camera.CameraType = Scriptable`, plans définis par des `Part` invisibles nommés `CS_xx_Shot_n` dans `Workspace/Cinematics` (Gabriel peut les déplacer à la main), transitions par `TweenService`. Bandes noires 2.35:1 (`CinematicGui`, section 15).
- **Qui la voit :** une cinématique de lieu ne joue que pour les joueurs dans son rayon ; les autres entendent un message radio. Les cinématiques de fin jouent pour tous.
- **Sécurité :** pendant une cinématique, le personnage est invulnérable et retiré des cibles de la créature, plus 3 s après.
- **Passer :** en lobby, bouton « Passer » après 10 s. En partie, vote à la majorité des joueurs concernés.
- **Sous-titres :** toujours affichés, texte ci-dessous.

### 6.2 Liste

| ID | Déclencheur | Durée | Plans (caméra → cible, focale) | Son et texte |
| --- | --- | --- | --- | --- |
| CS\_00 | 1re connexion au lobby | 70 s | 1. Nuit, cabane de 1924 en diorama, travelling lent (FOV 50). 2. Pierres qui frappent le toit, plan serré. 3. Deux rangers au bord d'une gorge, lumière de jour. 4. Machine à écrire qui tape « Ordinance 69-01 ». 5. Panache de 1980 au loin (particules), son étouffé. 6. Avis de recherche DOC\_01 punaisé, zoom. 7. Le van au parking du lobby, les phares s'allument. | Voix off : « 1924. Cinq hommes, une cabane, une nuit de pierres. Les rangers n'ont rien trouvé. En 1969, le comté a quand même voté une loi pour le protéger. En 1980, la montagne a explosé. Et il y a trois semaines, quatre géologues ont cessé de répondre. Cette nuit, on y va. » |
| CS\_01 | Compte à rebours fini | 8 s | 1. Intérieur du van, plan sur les joueurs assis. 2. Extérieur, le van passe la barrière fermée de la route 83, fondu au noir. | Moteur, pluie fine. Texte : « Route forestière 83 — fermée » |
| CS\_02a/b/c | Début de partie (S1, S2 ou S3) | 10 s | a : le van s'arrête au parking, plan large sur la forêt. b : bulldozer rouillé, arbres coupés. c : tentes déchirées, lampe qui pend. | Radio du Meneur : « OK. On trouve le camp, on filme, on rentre. » |
| CS\_03 | 1er aperçu de la créature (directeur) | 4 s | Pas de coupe : la caméra du joueur est légèrement attirée vers une silhouette à 90–120 studs, qui se dérobe. | Silence de la faune 3 s avant. Aucun texte |
| CS\_04 | 1re entrée dans P09 | 9 s | 1. Plan subjectif lent sur le camp ravagé. 2. Corps de Leah Brandt partiellement recouvert de pierres, plan large (pas de gros plan). | Mouches, vent. Sous-titre du joueur le plus proche : « … Oh non. » |
| CS\_05 | Vidéo de la tablette (DOC\_08) | 25 s | Images de caméra à l'épaule, grain, horodatage J-17 02:14. 1. Intérieur de tente, lampe. 2. Bruit de pierres sur la toile. 3. Whitcombe : « Éteins ça. Éteins ça ! » 4. Extérieur : deux reflets d'yeux dans le faisceau, loin. 5. Une masse sombre masque l'objectif. 6. Écran : « Point de repli de l'équipe : cabane des mineurs » | Pas de musique. Coupure nette |
| CS\_06 | Début du siège | 6 s | 1. De l'intérieur de la cabane, plan sur la porte. 2. Premier impact sur le toit, poussière qui tombe. | Coup sourd, puis 3 coups sur un tronc au loin |
| CS\_07 | Fin du siège | 10 s | 1. Silence, plan sur les planches fendues. 2. Extérieur, nuit froide : sur le bord du canyon, une silhouette debout regarde la cabane, puis recule hors de vue ; des pierres partout. | Texte de la voie d'extraction tirée (ex. « La radio de la tour. C'est notre seule chance. ») |
| CS\_08 | Début de l'acte 3 | 5 s | Plan large en hauteur sur la forêt, une lampe de joueur au loin, quelque chose bouge entre les arbres. | Cri long à distance (SFX\_Call\_Long\_02) |
| CS\_09 | 05 h 00 | 6 s | Lever du jour bleu sur le volcan, plan fixe. | Oiseaux qui reprennent, puis se taisent d'un coup |
| CS\_10 | Extraction E1 | 12 s | 1. Le van démarre. 2. Rétroviseur : une silhouette sur la route derrière. 3. Fondu au blanc. | Moteur, souffle des joueurs |
| CS\_11 | Extraction E2 | 12 s | 1. L'hélicoptère monte. 2. Vue plongeante : sur la crête, plusieurs silhouettes regardent l'appareil. | Rotor, puis silence |
| CS\_12 | Extraction E3 | 12 s | 1. Le bulldozer enfonce la barrière. 2. Plan arrière : des pierres empilées au milieu de la piste. | Métal, moteur |
| CS\_13 | Extraction E4 | 12 s | 1. Sortie du tube dans la lumière de l'aube. 2. Derrière, dans le noir, la femelle porte les os du juvénile et ne les suit pas. | Page 3 du carnet lue en voix off |
| CS\_14 | Alpha tué | 12 s | 1. Le corps de l'Alpha, plan large, sans gros plan. 2. Titre de journal fictif : « Étudiants inculpés : première application de l'ordonnance 69-01 ». 3. Nuit, la ville du lobby, des pierres tombent sur un toit. | Sirène lointaine |
| CS\_15 | Preuve de classe A sortie | 6 s | La vidéo du Caméraman rejouée sur un écran de montage, compteur de vues qui monte. | Notification de téléphone |
| CS\_16 | Aucun survivant | 10 s | 1. Le van vide au parking, portière ouverte. 2. Écran du podcast : « Épisode 12 — Cold Trail — durée 00:47 », la barre de lecture s'arrête. | Le dernier son enregistré par un joueur, puis rien |

### 6.3 Caméras de mort (sans coupe)

Quand un joueur meurt, sa caméra reste 4 s sur place, légèrement au-dessus du corps, inclinée de 10°, puis passe en spectateur (section 7). Aucun gros plan sur une blessure.

## 7. Joueurs

Chaque joueur incarne un des 10 personnages de la section 2.5, avec une apparence imposée. Il gère six jauges : santé par membre, sang, endurance, peur, bruit et lumière. Toutes les valeurs ci-dessous vont dans `Config/PlayerConfig`.

### 7.1 Personnages et skins

- L'avatar Roblox n'est jamais utilisé en partie. Chaque rôle a son modèle dans `ReplicatedStorage/Characters/<ROLE>/Skin_<n>` ; au spawn, le serveur clone le skin choisi et l'assigne à `Player.Character`.
- Le corps est découpé en 6 maillages (tête, torse, 2 bras, 2 jambes) : chacun reste sous la limite de triangles et peut se détacher pour le gore (section 11).
- 3 skins par personnage : **A** tenue de départ (dès le début), **B** tenue de pluie (5 parties jouées), **C** tenue « Cold Trail » (1 survie). Accessoires déblocables : bonnet, frontale colorée, sac.

### 7.2 Déplacement et caméra

| Action | Vitesse (studs/s) | Bruit (rayon entendu, studs) |
| --- | --- | --- |
| Marche | 12 | 25 |
| Course (endurance) | 20 (Médecin 18) | 60 |
| Accroupi | 6 | 6 |
| Couché | 2,5 | 0 |
| Porter un blessé | 8 (Sportif 12, peut courir) | 40 |
| Boiter (jambe < 30 %) | ×0,6 | +10 |
| Eau aux genoux / cendre / neige | ×0,7 / ×0,9 / ×0,85 | eau : ×2 |
| Saut (réception) | — | 30 |

- Vue à la première personne verrouillée, FOV 70 (76 en course). Balancement de marche, souffle audible. Se pencher (A/E sur PC, bouton sur mobile).
- Pas de réticule permanent : il n'apparaît qu'en visant.

### 7.3 Santé, sang, à terre, mort

| Membre | PV | Effet sous 30 % |
| --- | --- | --- |
| Tête | 30 | Vision floue, bourdonnement |
| Torse | 100 | Endurance max ÷ 2 |
| Bras gauche / droit | 50 / 50 | Visée qui tremble, recharge ×1,5 plus lente |
| Jambe gauche / droite | 60 / 60 | Boiterie, course impossible |

- **Sang (100) :** hémorragie légère −0,5/s (un bandage l'arrête), grave −2/s (seule la Médecin l'arrête ; un bandage la ramène à légère). Une hémorragie laisse une traînée que la créature suit. Sang < 40 : vision qui se désature ; < 20 : à terre ; 0 : mort.
- **À terre** quand tête ou torse tombe à 0, ou sang < 20 : 45 s (35 / 25 selon la difficulté), ramper à 1,5 studs/s, appel à l'aide. Relever : 6 s (3 s pour la Médecin), le joueur revient avec 20 % sur le membre touché.
- La créature peut traîner un joueur à terre (10 studs/s) vers une « réserve » (section 9) ; le groupe a jusqu'à la fin du compte à rebours pour le récupérer.
- **Mort définitive** pour la partie. Le corps reste en ragdoll ; l'inventaire tombe dans un sac ramassable.
- **Spectateur :** vue « caméra corporelle » d'un survivant (flèches ou balayage pour changer). Le spectateur n'a plus de voix de proximité, seulement le canal spectateurs.

### 7.4 Endurance

100 points. Course −12/s, saut −10, porter −6/s. Récupération +15/s en marchant, +25/s à l'arrêt, après 1,5 s sans effort. À 0 : 4 s d'essoufflement, haletèment audible à 35 studs. Le Géologue a 80 points.

### 7.5 Peur (0 à 100)

| Monte | Valeur | Baisse | Valeur |
| --- | --- | --- | --- |
| Aucune lumière à 10 studs | +1/s | Coéquipier à 15 studs | −2/s |
| Aucun coéquipier à 40 studs | +1,5/s | Dans la lumière | −1/s |
| Voir un corps | +15 (une fois par corps) | Près d'un feu ou d'une fusée | −3/s |
| Voir la créature | +20 à +35 (plus si proche) | Ordre du Meneur | −20 d'un coup (recharge 90 s) |
| Cri à moins de 100 studs | +10 | — | — |
| Coup sur tronc entendu | +4 | — | — |

La Descendante gagne de la peur ×1,25.

| Seuil | Effet |
| --- | --- |
| 40 | Battements de cœur audibles (pour soi) |
| 60 | Visée ×1,5 plus instable, respiration audible à 20 studs |
| 80 | Sons parfois mal placés (gauche/droite inversées 2 s), récupération d'endurance ×0,7 |
| 100 | Cri involontaire (bruit 200), au plus une fois par minute |

La peur n'est jamais affichée en chiffre : seulement par les effets et un léger vignettage.

### 7.6 Visibilité pour la créature

Coefficient multiplié à la portée de vue de la créature (section 9) :

| Situation | Coefficient |
| --- | --- |
| Debout à découvert | 1,0 |
| Debout en forêt | 0,6 |
| Accroupi | ×0,6 |
| Couché dans les fougères | ×0,1 (invisible au-delà de 10 studs) |
| Lampe allumée | ×3, visible jusqu'à 600 studs |
| Pluie ou brouillard | ×0,6 |

### 7.7 Capacités des rôles

| Rôle | Capacité | Valeurs | Faiblesse |
| --- | --- | --- | --- |
| Meneur | Voit ses coéquipiers en contour à travers le décor ; donne un ordre qui réduit la peur | contour à 30 studs ; ordre −20 peur à 15 studs, recharge 90 s | Aucune |
| Médecin | Soigne vite, arrête les hémorragies graves | soins ×2, relève en 3 s | Course à 18 |
| Pisteur | Voit les empreintes fraîches en surbrillance ; devine la direction de la créature | empreintes de moins de 120 s ; direction approximative à ±45°, recharge 60 s | Ses tirs comptent double pour la rancune |
| Caméraman | Seul à produire des preuves de classe A | voir section 8 | Batterie de 6 min |
| Mécanicienne | Répare deux fois plus vite | ×2 | Inventaire : 3 emplacements rapides au lieu de 4 |
| Descendante | Lit le carnet familial, voit les indices cachés | indices « cachés » visibles à 8 studs | Peur ×1,25 |
| Géologue | Lit la carte des tunnels, se repère sous terre | tracé visible sur la tablette dans le réseau | Endurance 80 |
| Sportif | Porte un blessé en courant, barricade vite | course à 12 en portant, planche en 4 s | Respiration : bruit de course 75 |
| Opératrice radio | Écoute les fréquences, repère les voix imitées | entend les éclaireurs imiter à 150 studs, voit leur direction | Aucune arme à feu possible |
| Pyrotechnicien | Fabrique une fusée ou un piège à bruit | 1 fusée par 2 piles + 1 ruban ; piège : boîte de conserve + corde | Torse 80 PV |

### 7.8 Communication

- Chat vocal de proximité si le joueur y a accès, sinon chat texte. La voix compte comme du bruit (rayon jusqu'à 80 studs selon le volume).
- Talkie-walkie : canal de groupe, portée 1 500 studs (toute la carte via le talkie du Meneur, section 8) ; il grésille dans les gorges et les tunnels, et son bip s'entend à 20 studs.
- Ping : touche ou bouton, place un repère visible 10 s par le groupe.

## 8. Objets, armes, tablette et preuves

Le joueur a 4 emplacements rapides (3 pour la Mécanicienne) et un sac limité à 12 kg. Un objet lourd (plus de 5 kg) se porte à deux mains : pas de course, pas d'arme. Valeurs dans `Config/ItemConfig` et `Config/WeaponConfig`.

### 8.1 Objets

| ID | Objet | Poids (kg) | Pile | Effet | Bruit | Où |
| --- | --- | --- | --- | --- | --- | --- |
| ITM\_Flashlight | Lampe torche | 0,4 | 1 | Cône 45°, portée 120 studs, 8 min de pile ; clignote sous 15 % | clic 8 | Départ (tous sauf Descendante et Géologue), C09–C12 |
| ITM\_Headlamp | Lampe frontale | 0,2 | 1 | Portée 70, 10 min, mains libres | clic 8 | Descendante |
| ITM\_PowerLight | Lampe puissante | 0,8 | 1 | Portée 220, 6 min ; éblouit la créature 1 s si elle la fixe à moins de 20 studs | clic 8 | Géologue |
| ITM\_Battery | Pile | 0,1 | 6 | Recharge une lampe à 100 % (3 s) | — | Tiré sur les points C |
| ITM\_Bandage | Bandage | 0,1 | 5 | 4 s : arrête une hémorragie légère, +10 PV au membre | 10 | Départ (2 chacun), points C |
| ITM\_Splint | Attelle | 0,3 | 2 | 6 s : supprime la boiterie | 10 | C12, P17 |
| ITM\_Medkit | Trousse complète | 1,5 | 1 (5 usages) | 8 s : +40 PV ; arrête une hémorragie grave (Médecin seulement) | 10 | Médecin |
| ITM\_Flare | Fusée à main | 0,3 | 3 | 60 s de lumière rouge, rayon 60 ; peur −3/s ; la créature reste à plus de 40 studs sauf si elle est enragée | 300 à l'allumage | C10, Pyrotechnicien |
| ITM\_Matches | Allumettes | 0,05 | 1 | Avec 3 branches : feu de camp 180 s, visible à 800 studs, même effet qu'une fusée | 20 | P17, P10 |
| ITM\_Branch | Branche morte | 0,5 | 3 | Combustible ; lançable | casse : 45 | Sol de la forêt |
| ITM\_Stone | Pierre | 0,3 | 3 | Lançable : bruit de leurre à l'impact | 50 à l'impact | Partout au sol |
| ITM\_Rope | Corde | 1,0 | 1 | Descendre dans le puits P21 ; piège du Pyrotechnicien | — | C11, P15 |
| ITM\_Plank | Planche | 2,0 | 1 | Barricade (section 5, acte 2) | clouage : 120 | Cabane P05c (6 planches) |
| ITM\_BearSpray | Bombe anti-ours | 0,4 | 1 (3 usages) | Cône de 6 studs : la créature lâche sa prise et recule 4 s | 40 | P17, P01 (boîte à gants) |
| ITM\_ToolBox | Caisse à outils | 3,0 | 1 | Réparations à vitesse normale ; sans elle, ×2 plus long | ouverte : 30 | Mécanicienne |
| ITM\_Compass | Boussole | 0,1 | 1 | Affiche le nord | — | Géologue |
| ITM\_RadioScanner | Scanner radio | 0,6 | 1 | Capacité de l'Opératrice (section 7.7) | grésillement 15 | Opératrice |
| ITM\_Walkie | Talkie-walkie | 0,3 | 1 | Canal de groupe, portée 1 500 studs ; celui du Meneur couvre la carte et relaie les autres | bip 20 | Tous |
| ITM\_TinCan, ITM\_DuctTape | Boîte de conserve, ruban | 0,1 | 3 | Ingrédients du Pyrotechnicien | — | P09, P10 |
| ITM\_Notebook | Carnet Halvorsen | 0,2 | 1 | DOC\_12, pages débloquées par l'histoire | — | Descendante |
| ITM\_Keys | Clés du van | 0,1 | 1 | Extraction E1 | — | K1–K3 |
| ITM\_Jack | Cric | 4,0 | 1 | Extraction E1 | — | J1–J2 |
| ITM\_CoaxCable | Câble d'antenne | 1,0 | 1 | Extraction E2 | — | R1–R2 |
| ITM\_CarBattery | Batterie de voiture | 8,0 | 1 | Extraction E2 (deux mains) | posée : 30 | R3 |
| ITM\_Jerrycan | Jerrican | 6,0 | 1 | Extraction E3 (deux mains) | clapotis 15 | R4–R6 |
| ITM\_StarterRelay | Relais de démarreur | 0,5 | 1 | Extraction E3 | — | R7 |
| ITM\_PlasterKit | Kit de moulage | 1,2 | 1 (2 usages) | 30 s sur une empreinte fraîche : moulage, preuve B | 10 | Pisteur, P17 |
| ITM\_AudioRecorder | Enregistreur | 0,3 | 1 | Enregistre un cri à moins de 150 studs : preuve B | — | Opératrice, P23 |
| ITM\_SampleBag | Sachet à échantillon | 0,05 | 3 | Ramasser des poils : preuve B | — | P09 |
| ITM\_Camcorder | Caméscope vision nocturne | 0,9 | 1 | Filme ; vision nocturne ; 6 min d'enregistrement | bip 10 | Caméraman |
| ITM\_PhotoCamera | Appareil photo | 0,5 | 1 | 12 photos ; flash = lumière ×3 pendant 0,2 s | déclic 15 | P09, C03–C06 |
| ITM\_TabletField | Tablette de terrain | 0,7 | 1 | Voir 8.3 | — | Meneur |
| ITM\_TabletGeo | Tablette des géologues | 0,7 | 1 | DOC\_07 et DOC\_08 | — | P09, tente de Leah |

### 8.2 Armes

Les armes à feu dépendent de la taille du groupe : 1 à 3 joueurs = fusil ; 4 à 6 = fusil + revolver ; 7 à 10 = fusil + revolver + fusil à pompe. Le fusil revient d'office au Pisteur s'il est présent. L'Opératrice ne peut pas en porter.

| ID | Arme | Munitions | Cadence | Rechargement | Dégâts créature (corps / tête) | Tir allié (torse) | Bruit |
| --- | --- | --- | --- | --- | --- | --- | --- |
| WPN\_Rifle | Fusil à verrou | 5 | 1 tir / 1,4 s | 1,2 s par balle | 180 / 400 | 120 | Toute la carte |
| WPN\_Revolver | Revolver | 6 | 1 tir / 0,6 s | 0,8 s par balle | 70 / 160 | 60 | 2 500 |
| WPN\_Shotgun | Fusil à pompe | 4 | 1 tir / 1,0 s | 0,9 s par cartouche | 8 plombs × 18 jusqu'à 15 studs, puis −70 % à 40 studs | 15 par plomb | Toute la carte |
| WPN\_FlareGun | Pistolet lance-fusées (Pyrotechnicien) | 3 | — | 2 s | 20 + éblouissement 3 s, la créature fuit 8 s | 30 + brûlure | 1 200 |
| MEL\_Axe | Hache (Sportif) | — | 1 coup / 1,1 s | — | 25 ; un coup sur le bras qui saisit = lâcher | 30 | 40 |
| MEL\_Machete | Machette | — | 1 coup / 0,8 s | — | 18 ; deux coups = lâcher | 20 | 30 |

- Une seule boîte de munitions de secours (A1–A5) : 5 balles de fusil, 6 de revolver, 4 cartouches. Absente en Cauchemar.
- Recul, balancement de visée (aggravé par la peur et un bras blessé), rechargement manuel balle par balle, interruptible.
- Le serveur valide chaque tir (origine, direction, munitions, cadence).

### 8.3 Tablette de terrain

Une seule par groupe, au départ dans les mains du Meneur (sans Meneur : le premier joueur du groupe). Si elle tombe (mort), un autre peut la ramasser. Son écran éclaire : visibilité ×1,5 tant qu'elle est ouverte. Batterie : 30 minutes d'écran allumé pour la nuit.

| Appli | Contenu |
| --- | --- |
| Carte | Carte topographique du secteur (image de la section 3). Position GPS à ±30 studs, mise à jour toutes les 10 s ; sous forêt dense, 50 % de chances de « Pas de signal GPS ». 8 repères plaçables. Couche « tunnels » après lecture de DOC\_07 |
| Objectifs | Acte en cours, objectif, heure en jeu (en Cauchemar, seule source des objectifs) |
| Journal | Textes des documents lus (DOC\_xx), dans l'ordre de découverte |
| Preuves | Preuves du groupe, classe, qui les porte |
| Réseau | Toujours « Aucun réseau » ; une barre au sommet de P11 et à P23 : envoi d'un SMS au ranger Hollis, réponse automatique « Restez groupés. Personne ne monte avant l'aube. » |

La tablette des géologues (ITM\_TabletGeo) ne contient que DOC\_07 et DOC\_08. La lire copie la couche « tunnels » sur la tablette de terrain. Dans les tunnels, seul le Géologue voit sa position sur ce tracé.

### 8.4 Preuves

Inspiré des classes de fiabilité du BFRO (voir GDD). Une preuve est un objet d'inventaire ; elle ne compte que si un survivant la sort de la forêt.

| Classe | Preuve | Conditions | XP |
| --- | --- | --- | --- |
| A | Vidéo du Caméraman | Créature visible à 60 % au moins, à 30 studs ou moins, pendant 2 s sans interruption, vision nocturne ou lumière suffisante | 500 |
| B | Moulage d'empreinte | Empreinte de moins de 120 s, 30 s de travail | 150 |
| B | Enregistrement d'un cri | Cri à moins de 150 studs | 150 |
| B | Poils | Sur une structure de branches ou au bord d'Ape Canyon | 150 |
| B | Photo de la créature | Appareil photo, à 40 studs ou moins | 150 |
| C | Document (DOC\_03 à DOC\_10) | Ramassé | 50 |
| C | Photo du charnier P19 | Appareil photo | 50 |

La carte mémoire du caméscope (ITM\_SDCard) est créée automatiquement après une vidéo de classe A ; elle peut être confiée à un autre joueur.

## 9. La créature : biologie et IA

La créature est un grand primate nocturne, territorial et rancunier, qui vit en famille. Elle ne poursuit pas bêtement : elle observe, avertit, teste, puis frappe quand une proie s'isole. Tout son comportement s'appuie sur des comportements réels de grands singes et sur les récits locaux. Valeurs dans `Config/CreatureConfig`.

### 9.1 Ce sur quoi le comportement repose

| Comportement | Base | Source | Statut | En jeu |
| --- | --- | --- | --- | --- |
| Activité nocturne | L'ordonnance de 1969 parle d'un possible « primate nocturne » | [WSBA](https://nwsidebar.wsba.org/2019/10/31/washington-rules-to-make-you-scream-this-halloween-completely-bizarre-but-totally-real-laws-legislation-and-legal-references/) | Texte réel, créature non prouvée | Se retire à l'aube (05 h 50) |
| Martellement de poitrine | Chez le gorille, signal honnête de la taille, rare (1,6 fois par 10 h en moyenne) et qui peut éviter le combat | [National Geographic](https://www.nationalgeographic.com/animals/article/why-do-gorillas-beat-their-chests) | Établi (gorille) | Alpha seulement, dernier avertissement avant une charge |
| Avertissement puis charge | Grognements, végétation arrachée, posture debout ; la plupart des charges s'arrêtent avant le contact | [Rwenzori Expeditions](https://www.rwenzoriexpeditions.com/things-to-observe-on-gorilla-trekking/) | Source touristique, à prendre avec prudence | Échelle d'intimidation, fausse charge |
| Lancer de pierres sur des arbres précis, tas de pierres | Observé chez quatre populations de chimpanzés d'Afrique de l'Ouest, surtout des mâles adultes | [Scientific Reports 2016](https://doi.org/10.1038/srep22219), [The Debrief](https://thedebrief.org/wild-chimpanzees-keep-hurling-rocks-at-the-same-trees-now-scientists-are-trying-to-figure-out-why/) | Établi (chimpanzé) | 3 « arbres à pierres » fixes, marquage du territoire |
| Coups sur les troncs, cris, pierres lancées pour faire partir | Rapports de témoins dans l'État de Washington | [BFRO 31749](https://www.bfro.net/GDB/show_report.asp?id=31749), [BFRO 67407](https://www.bfro.net/GDB/show_report.asp?id=67407) | Témoignages, non prouvés | Échelle d'intimidation |
| Bombardement nocturne d'une cabane | Récit de 1924 | [Wikipedia](https://en.wikipedia.org/wiki/Ape_Canyon) | Récit, contesté par les rangers | Acte 2 |
| Sifflements la nuit, vengeance, bâtons dans les tentes | Récits du Nord-Ouest | [Native Languages](https://www.native-languages.org/morelegends/stick-indians.htm), [Chinook Jargon](https://chinookjargon.com/2021/03/17/pre-1917-ka-mi-akin-last-hero-of-the-yakamas-part-2-of-2/) | Tradition orale | Sifflements des éclaireurs, rancune |

### 9.2 La famille

| ID | Membre | Taille | PV (Normal) | Présence | Rôle |
| --- | --- | --- | --- | --- | --- |
| CRT\_Alpha | Mâle dominant | 2,8 m (10 studs) | 1 000 | Toujours | Chasseur principal, saisit, tue, martelle |
| CRT\_Scout1/2 | Jeunes adultes | 2,2 m (8 studs) | 500 | Selon la taille du groupe (5.5) | Rabattent, lancent des pierres, imitent, sifflent |
| CRT\_Female | Femelle | 2,5 m (9 studs) | 800 | Tunnels uniquement | Garde le repaire, très agressive sous terre |
| — | Juvénile | 1,3 m | — | Mort (os gardés par la femelle en P07b) | Moteur de la vengeance |

Régénération : +2 PV/s hors combat, jusqu'à 70 % du maximum. Tuer l'Alpha demande donc des tirs rapprochés dans le temps.

| Allure | Vitesse (studs/s) | Limite |
| --- | --- | --- |
| Approche furtive | 6 | Bruit 8 |
| Marche | 10 | Bruit 30 (pas lourds) |
| Course debout | 22 | Bruit 80 |
| Sprint à quatre pattes | 30 | 6 s, puis 20 s de récupération |
| Escalade | 5 | Seulement entre deux points tagués `ClimbPoint` |

Un joueur qui court (20) ne la distance pas à découvert. Il survit grâce au groupe, à la lumière, au feu, à l'eau, à la cabane et aux armes.

### 9.3 Architecture

Trois niveaux, tout côté serveur, les modèles des créatures appartenant au serveur (`SetNetworkOwner(nil)`).

| Niveau | Module | Fréquence | Rôle |
| --- | --- | --- | --- |
| Directeur | `TensionDirector` | 1 fois/s | Mesure la tension, autorise ou interdit les attaques, déclenche des événements |
| Famille | `FamilyBrain` | 2 fois/s | Répartit les rôles, coordonne les pièges à plusieurs |
| Individu | `CreatureBrain` | 5 fois/s (perception 10 fois/s à moins de 150 studs, 2 fois/s au-delà) | Choisit un comportement (IA à utilité), l'exécute (machine à états) |

**Simulation à distance :** si aucun joueur n'est à moins de 600 studs d'une créature, elle n'a plus de corps physique et se déplace sur un graphe de points (`CreatureNav` : un nœud tous les 200 studs, plus un par lieu). Son corps réapparaît hors de vue dès qu'un joueur s'approche.

### 9.4 Perception

**Vue.** Portée `Rv = 180` (nuit) ou `300` (aube), × difficulté, × météo (brouillard 0,5, pluie 0,7), × coefficient de visibilité du joueur (7.6). Cône de 120°, vision périphérique jusqu'à 200° avec ×0,4. Deux rayons (tête et torse du joueur) depuis la tête de la créature ; les feuillages ne bloquent pas, troncs et rochers oui.

**Vigilance par joueur (0 à 1).** Quand un joueur est vu : `+1,5 × (1 − d / Rv) × visibilité` par seconde. Sinon, `−0,1` par seconde.

| Vigilance | Réaction |
| --- | --- |
| 0,3 | Tourne la tête, s'immobilise |
| 0,7 | Connaît la position exacte |
| 1,0 | Le joueur devient cible possible |

**Ouïe.** Chaque bruit est un événement `{position, rayon, type}`. Il est entendu si `distance ≤ rayon × ouïe × atténuation` (ouïe : Alpha 1,0, éclaireurs 1,2 ; atténuation : pluie 0,6, à moins de 30 studs d'un ruisseau 0,4, cascade P13 0,2, murs de la cabane 0,7). L'endroit retenu est faux de 10 % de la distance. Un coup de feu met la vigilance du tireur à 1,0.

**Odorat.** Selon le vent (`workspace.GlobalWind`) : joueur au vent de la créature (le vent va du joueur vers elle) senti à 80 studs, vent de travers 30, sous le vent 10. Une hémorragie dépose un point de piste tous les 4 studs, actif 300 s : la créature peut la suivre au pas.

**Lumière.** Un faisceau qui la touche dans sa portée met la vigilance du porteur à 1,0.

### 9.5 Comportements (IA à utilité)

Chaque comportement a un score de 0 à 1. La créature garde le comportement en cours sauf si un autre dépasse son score ×1,25, et chaque comportement a une durée minimale.

| ID | Comportement | Score élevé quand | Durée min | Ce qu'elle fait |
| --- | --- | --- | --- | --- |
| BHV\_Roam | Errance | Rien d'autre (score fixe 0,2) | 20 s | Parcourt son territoire par les zones couvertes |
| BHV\_Feed | Manger | Faim > 0,7 (faim +0,01/min) | 40 s | Va à P19 ou à une carcasse ; moment calme exploitable |
| BHV\_Mark | Marquer | Hors combat, près d'un arbre à pierres | 15 s | Ajoute des pierres au tas, casse une branche à 3 m |
| BHV\_Observe | Observer | Tension basse, cible inconsciente | 30 s | Se poste à 40–90 studs derrière un tronc ; fuit si éclairée ou approchée à 25 studs |
| BHV\_Intimidate | Intimider | Joueurs près du territoire ou du repaire | une marche | Monte d'un cran sur l'échelle 9.6 |
| BHV\_Stalk | Traquer | Cible choisie, pas encore isolée | 45 s | Suit à 50–80 studs sans être vue |
| BHV\_Ambush | Embuscade | Objectif des joueurs connu | 90 s max | Attend à 20–30 studs du chemin probable |
| BHV\_Attack | Attaquer | Cible isolée, directeur d'accord | — | Une attaque de la table 9.10 |
| BHV\_Throw | Lancer | En hauteur, cible à 20–120 studs | 20 s | Pierres sur les joueurs, les lampes, les planches |
| BHV\_Sabotage | Saboter | Groupe soudé depuis 120 s | 30 s | Casse les lanternes du camp, renverse le feu, vole un sac posé |
| BHV\_Drag | Traîner | Joueur à terre ou mort | jusqu'à la réserve | Emporte le corps vers une réserve : rive du lac P20, sous les troncs de P04, repaire P07b |
| BHV\_Retreat | Fuir blessée | 15 % de PV perdus en 10 s, fusée, bombe anti-ours | 30–60 s | Se replie vers la forêt dense ou les tunnels, régénère, revient enragée |
| BHV\_Siege | Siège | Acte 2 | tout le siège | Tourne à 25–40 studs, lance depuis le bord du canyon, teste les barricades |
| BHV\_Guard | Garder | Femelle, joueur à moins de 40 studs du repaire | — | Attaque sans avertissement |
| BHV\_Mimic | Imiter | Éclaireur, une cible s'éloigne du groupe | 10 s | Rejoue un son préenregistré (9.8) |
| BHV\_Avoid | Éviter | Feu ou fusée à moins de 40 studs, aube | — | Reste hors du rayon ; à 05 h 50, rentre au repaire |

### 9.6 Échelle d'intimidation

Chaque cran attend le précédent (moins de 5 min avant). L'échelle redescend d'un cran toutes les 3 min sans contact. Le joueur attentif voit donc toujours venir le danger.

1. Silence de la faune autour d'elle (60 studs).
2. Coups sur un tronc, souvent en réponse à un autre membre de la famille.
3. Cri long à distance ou grognement proche.
4. Branche lancée ou pierre qui tombe à côté du joueur, pas sur lui.
5. Branche cassée tout près, hors de vue.
6. Apparition debout, martellement de poitrine (Alpha).
7. Fausse charge : s'arrête à 4–8 studs, puis repart (60 % des cas si le joueur ne fuit pas et n'éclaire pas).
8. Vraie attaque.

### 9.7 Choix de la cible

Score recalculé toutes les 2 s pour chaque joueur, entre 0 et 1 pour chaque terme :

```latex
S = 3{,}0\,I + 1{,}5\,B + 1{,}0\,N + 1{,}2\,L + 2{,}0\,R + 0{,}8\,P + 0{,}5\,C
```

- I (isolement) = distance au coéquipier le plus proche ÷ 60, plafonné à 1.
- B (blessure) = 1 − santé moyenne ; +0,3 en hémorragie.
- N (bruit) = bruit des 10 dernières secondes ÷ 100.
- L (lumière) = 1 si la lampe est allumée, 0,5 si la tablette est ouverte.
- R (rancune) = dégâts infligés à cette créature ÷ 200 ; +0,3 par fusée ; +0,5 si filmée à moins de 30 studs ; tirs du Pisteur comptés double.
- P (proximité) = 1 − distance ÷ 300.
- C = 1 si le joueur porte une preuve de classe A.

La cible change seulement si un autre joueur dépasse le score actuel de 20 %.

### 9.8 Mémoire et apprentissage pendant la partie

| Ce qu'elle retient | Déclencheur | Ce qui change |
| --- | --- | --- |
| Cachettes | Un joueur s'y est caché (couché, dans un bâtiment) | Les fouille en premier ensuite |
| Chemins | Passages des joueurs, par case de 64 studs | Embuscades sur les chemins les plus pris |
| Armes | 2 tirs reçus | Attaque depuis les hauteurs, lance plus, reste à plus de 60 studs à découvert, arrive par derrière |
| Lumière | Éclairée 3 fois | Se cache au lieu de fuir ; attend que les piles faiblissent ; contourne les faisceaux |
| Fusées | 2e fusée | Fuite réduite de 8 à 4 s |
| Groupe soudé | Groupe dans un rayon de 25 studs pendant 120 s | Passe en usure : sabotage, pierres, attente des isolés |
| Rancune | Voir 9.7 | La cible préférée reste la même d'un acte à l'autre |

**Imitation (éclaireurs).** Ils rejouent des sons préenregistrés du jeu, jamais la vraie voix d'un joueur : sifflement humain (SFX\_Whistle\_01–03), appel « Hey ! », et l'appel à l'aide d'un personnage mort (VO\_\<ROLE>\_Help). L'Opératrice radio les repère (7.7).

**Personnalité de l'Alpha** (tirée à chaque partie) :

| Personnalité | Modificateurs |
| --- | --- |
| Patiente | Traque ×1,5 de durée, attaques ×0,8 de fréquence, vise surtout les isolés |
| Territoriale | Intimidation ×1,4, attaques ×1,3 dans un rayon de 800 studs autour de P05 |
| Joueuse | Imitation et pierres ×1,6, plus de fausses charges, harcèle sans tuer en acte 1 |

### 9.9 Coordination de la famille

- **Pince :** un éclaireur frappe un tronc d'un côté du groupe ; l'Alpha attend de l'autre côté, là où le groupe va fuir.
- **Rabattage :** les éclaireurs lancent des pierres pour pousser un joueur vers l'Alpha.
- **Séparation :** un éclaireur imite un appel à l'aide pour attirer un joueur hors du groupe.
- **Règle de lisibilité :** jamais plus de 2 créatures visibles en même temps par un joueur.
- **Tunnels :** la femelle garde P07b ; l'Alpha y suit les joueurs seulement à partir de l'acte 4.

### 9.10 Attaques

Chaque attaque a un signal sonore avant les dégâts, pour que la mort ne paraisse jamais injuste.

| ID | Attaque | Portée (studs) | Signal (s) | Dégâts | Parade |
| --- | --- | --- | --- | --- | --- |
| ATK\_Strike | Coup | 7 | 0,6 (grognement) | 35 sur un membre, recul | Esquive, hache |
| ATK\_Charge | Charge | départ 15–40 | 0,8 (cri + pas) | 40 + à terre 2 s | Fusée, lampe puissante, bombe anti-ours |
| ATK\_Grab | Saisie | 6 | 0,4 | 10/s tant que tenu ; traîné après 3 s | Coéquipier : hache 1 coup, machette 2, bombe, tir |
| ATK\_Throw | Pierre | 20–120 | sifflement de la pierre | 15–30 | Couvert |
| ATK\_Slam | Frappe au sol (joueur à terre) | 5 | 1,0 | 60 | Relever le joueur avant |
| ATK\_ReachThrough | Bras par une barricade cassée | 5 dans la cabane | 0,5 | Saisie | Reclouer, hache |
| ATK\_Execution | Mise à mort (Alpha, joueur à terre, profil Restricted seulement) | 3 | 1,5 | Mort | Aucune ; noir à l'instant de la mort (section 11) |

### 9.11 Déplacement

- `PathfindingService` avec `AgentRadius = 3`, `AgentHeight = 10`, `AgentCanJump = true`, et des coûts par matériau ([doc Roblox](https://create.roblox.com/docs/reference/engine/classes/PathfindingService)) : Water 5, Sand (cendre) 3, Pebble 2, Rock 2, Grass 1, LeafyGrass 0,8.
- Volumes `PathfindingModifier` : `Cover` 0,6 (forêt dense), `Trail` 1,5 (elle évite les sentiers), `Forbidden` 10 sur P08 sauf en chasse (1).
- Escalade : paires de `ClimbPoint` (bas/haut) sur les falaises d'Ape Canyon, de Lava Canyon et de F01. Les joueurs ne peuvent pas les utiliser.
- Près de la cible (moins de 30 studs), déplacement direct avec évitement par rayons, sans recalcul de chemin.

### 9.12 Directeur de tension

Le directeur mesure une tension T par joueur (0 à 100) et une intensité de groupe (moyenne des T). Il ne déplace pas la créature : il autorise, interdit ou suggère.

```latex
T = 0{,}5 \times \text{peur} + 0{,}3 \times (100 - \text{santé moyenne}) + 20 \times e^{-t/30}
```

t = secondes depuis le dernier événement fort vécu par ce joueur (attaque, créature vue de près, mort d'un coéquipier).

| Règle | Détail |
| --- | --- |
| Montée | Intensité < 25 pendant 120 s : un événement de la section 10 (catalogue « bas ») |
| Pic | Intensité > 75 pendant 90 s : pause imposée de 60 à 90 s, les créatures passent en Observer ou Fuir |
| Acte 1 | Aucune mort, sauf joueur isolé à plus de 200 studs du groupe pendant 60 s ou joueur qui tire sur la créature. Garantis : 1 aperçu lointain (CS\_03) et 2 signes |
| Acte 2 | 1 mort au plus en Normal (2 en Difficile, sans limite en Cauchemar) |
| Acte 3 | Au moins 2 tentatives d'attaque ; au plus 1 mort par tranche de 3 min |
| Acte 4 | Dernier assaut : toutes les créatures, plus de pause imposée |
| Groupe | Événements ×0,8 / ×1,0 / ×1,2 selon la taille (5.5) |

### 9.13 Outil de test

En Studio seulement, `CreatureDebug` (touche F8) affiche au-dessus de chaque créature : comportement, cible, scores, vigilance par joueur, chemin prévu, et la tension du directeur.

## 10. Événements inexpliqués et mise en scène de la peur

Le jeu fait peur par ce qu'on entend et ce qu'on devine, pas par des sursauts. Chaque événement ci-dessous a une explication naturelle possible, que le jeu ne tranche jamais. Le directeur (9.12) les tire dans le catalogue « bas » quand la tension retombe.

### 10.1 Règles de mise en scène

1. **Le son avant l'image.** Une menace s'entend toujours avant de se voir.
2. **Rien n'apparaît sous les yeux.** Un objet ou un décor modifié n'apparaît que hors du champ de vision de tous les joueurs, ou à plus de 80 studs.
3. **La fausse sécurité.** Après une pause imposée, la première menace arrive là où le groupe se croit à l'abri (camp, cabane, van).
4. **Pas de musique de sursaut.** Une seule exception par partie : le premier vrai contact de l'acte 2.
5. **Cadence :** 1 événement au plus toutes les 45 s par joueur ; le même événement jamais deux fois en 10 min.

### 10.2 Catalogue

| ID | Événement | Explication possible | Actes | Son / asset |
| --- | --- | --- | --- | --- |
| EVT\_01 | La faune se tait d'un coup autour du joueur | Un prédateur passe, n'importe lequel | 0–4 | Coupure des AMB\_Birds et AMB\_Insects sur 60 studs |
| EVT\_02 | Trois coups sur un tronc au loin, puis trois de l'autre côté | Branches qui cognent au vent | 1–3 | SFX\_WoodKnock\_01–06 |
| EVT\_03 | Structure de branches entrelacées sur un sentier déjà pris | Chablis, randonneurs | 1–3 | Prop\_StickStructure\_A–C |
| EVT\_04 | Tas de pierres au pied d'un arbre, plus haut qu'au passage précédent | Quelqu'un d'autre est passé | 1–3 | Prop\_StonePile\_A–C (+1 niveau) |
| EVT\_05 | Empreintes fraîches autour du van ou des tentes | Un ours ? Une farce ? (les rangers de 1924 disaient qu'on peut les truquer) | 1–3 | Decal\_Footprint\_Big |
| EVT\_06 | Bâtons enfoncés dans la toile d'une tente | Débris de tempête | 1 | Prop\_TentSticks |
| EVT\_07 | Sifflement humain dans le noir | Un oiseau, peut-être | 1–4 | SFX\_Whistle\_01–03 |
| EVT\_08 | Un « Hey ! » avec la voix d'un coéquipier, qui jure ne rien avoir dit | Écho, fatigue | 2–4 | Imitation (9.8) |
| EVT\_09 | Lampe abandonnée, allumée, sur le sentier, tournée vers la forêt | Celle de Ben Castillo | 1 | Prop\_DroppedFlashlight |
| EVT\_10 | La porte du poste des rangers est ouverte, alors qu'elle était fermée | Le vent | 1–3 | SFX\_DoorCreak\_02 |
| EVT\_11 | Une pierre tombe sur le toit du van | Chute naturelle | 0–1 | SFX\_StoneOnMetal\_01 |
| EVT\_12 | Odeur forte (vignettage vert très léger, réplique « Vous sentez ça ? ») | Une carcasse. Les récits locaux parlent aussi d'une puanteur ([Wenatchee World](https://www.wenatcheeworld.com/news/local/colville-stick-indian-legend-sasquatch-is-getting-his-own-roadside-monument/article_36cee63c-0a7c-540b-8aca-a23eafade59a.html)) | 1–4 | VO\_\<ROLE>\_Smell |
| EVT\_13 | Deux yeux reflètent la lampe à 60 studs, puis disparaissent | Un cerf ou un wapiti | 1–3 | FX\_EyeShine |
| EVT\_14 | Respiration lente sur le canal radio | Interférence | 2–4 | SFX\_RadioBreath\_01 |
| EVT\_15 | Le corps de Leah Brandt a bougé entre deux passages | On s'est trompé d'endroit | 1–3 | Zone B6 |
| EVT\_16 | Arbre cassé net à 3 m de haut, cassure fraîche | Coup de vent | 1–4 | Prop\_SnappedTree\_A |
| EVT\_17 | Des pas qui s'arrêtent une demi-seconde après ceux du joueur | L'écho de ses propres pas | 1–3 | SFX\_Steps\_Heavy\_Delay |
| EVT\_18 | Un cri long au loin, auquel un autre répond à l'opposé | Coyotes, wapitis en rut | 1–4 | SFX\_Call\_Long\_01–04 |
| EVT\_19 | Les objets d'un sac posé sont alignés à côté | Personne ne s'en souvient | 2–4 | Script, aucun asset |
| EVT\_20 | Un caillou tombe dans l'eau à côté du joueur | Berge qui s'effrite | 1–4 | SFX\_Splash\_Small |
| EVT\_21 | La tablette affiche une barre de réseau, puis plus rien | Réseau instable | 1–3 | UI de la tablette |
| EVT\_22 | Une silhouette debout sur les troncs flottants du lac | Un tronc dressé | 1–3 | Pose fixe de la créature, 4 s |

### 10.3 Ce que le joueur ne doit jamais avoir

- Une jauge de « danger » ou une flèche vers la créature.
- Un son de créature sans source réelle (chaque son a une position).
- Une mort sans signal sonore avant (9.10).

## 11. Gore, morts et règles Roblox

Le gore explicite validé impose le label **Restricted**, désormais réservé aux joueurs de **18 ans et plus** dont l'âge est vérifié ; le créateur doit lui aussi avoir 18 ans pour publier une nouvelle expérience Restricted ([DevForum Roblox, mise à jour du 6 novembre 2025](https://devforum.roblox.com/t/updating-age-requirements-for-experiences-with-%E2%80%98restricted%E2%80%99-content-maturity-label/3905863)). Le GDD disait 17+ : c'est dépassé.

**Conséquence à trancher par Gabriel (section 19) :** s'il n'a pas 18 ans vérifiés, il ne peut pas publier la version Restricted. Et un proche de moins de 18 ans ne pourra pas y jouer.

### 11.1 Ce que Roblox autorise

Source : [doc Content Maturity](https://create.roblox.com/docs/production/promotion/content-maturity).

| Label | Violence | Sang |
| --- | --- | --- |
| Moderate | Violence ou mort réalistes mais non graphiques | Sang réaliste léger (éclaboussures vues de loin) |
| Restricted (18+ vérifiés) | Violence graphique, par ex. démembrement, mutilation | Sang abondant : flaques, jets, éclaboussures de près |
| **Jamais autorisé** | Violence extrême, maltraitance ou torture d'animaux, gore extrême réaliste, torture | — |

Le questionnaire de maturité doit être rempli **avant** d'ajouter du contenu Restricted (même source). C'est Gabriel qui le remplit, jamais Claude Code.

### 11.2 Deux profils dans le même code

`Config/GoreConfig.Profile` vaut `"Restricted"` ou `"Moderate"`. Le même jeu peut ainsi être publié en deux expériences distinctes, une par label.

| Élément | Restricted | Moderate |
| --- | --- | --- |
| Membres détachables (bras, jambes) | Oui : un coup de plus de 50 sur un membre à moins de 10 % de PV | Non |
| Mise à mort ATK\_Execution | Oui, avec noir à l'instant de la mort | Non : l'Alpha traîne le joueur hors de vue |
| Flaques de sang | Oui, 600 s, 40 au plus sur la carte | Petites taches au sol, 120 s |
| Plaies sur le personnage | Decals de plaies | Taches sombres sur les vêtements |
| Corps des géologues | Membres manquants, sang séché | Corps couverts (bâche, pierres) |
| Traînées de sang | Oui | Oui, discrètes |

### 11.3 Limites fixes (les deux profils)

- Pas d'organes ni d'entrailles visibles, pas de gros plan sur une blessure, pas de ralenti sur une mort.
- Pas de torture : la créature tue ou emporte, elle ne fait jamais durer.
- Aucun animal tué ou blessé à l'écran : les wapitis de P19 sont des restes anciens, comme dans un documentaire.
- Aucune victime réelle de 1980 montrée ou nommée.
- Aucune image réelle (photo de vrai cadavre, vraie scène de crime) utilisée comme texture.

### 11.4 Option « Gore réduit »

Réglage local par joueur, désactivé par défaut (dans le profil Restricted) : il applique localement l'affichage du profil Moderate. Il ne change pas le label de l'expérience.

### 11.5 Implémentation

- Chaque personnage a 6 maillages ; un membre détaché devient une pièce libre, avec un capuchon (`Gore_Stump_<Membre>`) qui masque la coupe sans détail anatomique.
- Sang : `ParticleEmitter` court (0,3 s) + decal de flaque posé par rayon vers le sol.
- Ragdoll : `BallSocketConstraint` sur les articulations à la mort ; le corps passe ancré après 10 s immobile, pour économiser la physique.

## 12. Ambiance : lumière, météo, vent, son

La nuit doit être vraiment noire entre minuit et 4 h, et le son doit porter la moitié de la peur. Valeurs dans `Config/AmbienceConfig` ; un module client `AmbienceController` interpole entre les réglages selon l'heure et la zone.

### 12.1 Lumière par moment

`Lighting.Technology = Future`. Couleurs en RGB 0–255.

| Moment | ClockTime | Brightness | OutdoorAmbient | Ambient | ExposureCompensation |
| --- | --- | --- | --- | --- | --- |
| Arrivée | 18,5 → 19 | 1,2 | 60, 65, 80 | 40, 45, 55 | 0 |
| Fin d'enquête | 21 | 0,15 | 20, 24, 32 | 12, 14, 18 | 0 |
| Siège | 22 → 0 | 0,05 | 12, 14, 20 | 8, 9, 12 | −0,1 |
| Nuit noire | 0 → 4 | 0 | 8, 9, 14 | 5, 6, 9 | −0,3 |
| Aube | 5 → 6 | 0,6 | 45, 55, 75 | 25, 30, 40 | 0 |

- `ColorCorrectionEffect` : Saturation −0,25, Contrast 0,1, TintColor 220, 230, 255.
- `BloomEffect` intensité 0,3 ; `DepthOfFieldEffect` FarIntensity 0,15 (réglage Élevé seulement).
- Lune par nuit claire : les nuages s'ouvrent 20 s toutes les 3 à 5 min, assez pour voir une silhouette à 80 studs.
- Lampes : `SpotLight` avec ombres, angle 45°, portée de la section 8 ; sous 15 % de pile, clignotement aléatoire.

### 12.2 Brouillard par zone (`Atmosphere`)

| Zone | Density | Haze | Color |
| --- | --- | --- | --- |
| Forêt | 0,35 | 1,5 | 190, 200, 215 |
| Gorges P03, P05 | 0,45 | 2,0 | 180, 190, 205 |
| Zone interdite P08 | 0,20 | 0,5 + particules de cendre | 170, 170, 175 |
| Plateau P06 | 0,25 | 1,0 | 200, 205, 215 |
| Tunnels P07 | Atmosphere désactivée, noir total | — | — |

### 12.3 Météo (tirée à chaque partie, sauf vote « fixe »)

| Météo | Probabilité | Effets |
| --- | --- | --- |
| Nuit claire | 30 % | Lune, froid ; aucune pénalité de vue |
| Brouillard | 30 % | Density ×1,7 ; vue de la créature ×0,5, celle des joueurs aussi |
| Pluie | 25 % | Particules près de la caméra ; bruits ×0,6 pour tous ; sol mouillé |
| Première neige | 15 % | Neige au-dessus de Y = 350 ; empreintes visibles 300 s ; endurance ×0,85 |

Pendant l'acte 2, une nuit claire ou un brouillard passe en pluie (ou en neige au-dessus de Y = 350, ce qui est le cas de la cabane).

### 12.4 Vent

`workspace.GlobalWind` fait bouger l'herbe du terrain, les nuages et les particules qui ont `WindAffectsDrag` ([doc Roblox](https://create.roblox.com/docs/environment/global-wind)). Il ne fait pas bouger les maillages : les arbres sont donc animés par leurs os, côté client, seulement à moins de 120 studs et en réglage Élevé.

| Météo | Vent de base (X, Y, Z) | Rafales |
| --- | --- | --- |
| Nuit claire | 6, 0, −3 | +10, toutes les 8 à 15 s |
| Brouillard | 2, 0, −1 | aucune |
| Pluie | 14, 0, −6 | +20, cycle en sinus comme l'exemple de la doc |
| Neige | 10, 0, −8 | +12 |

Le vent sert aussi à l'odorat de la créature (9.4) : un joueur attentif peut se placer sous le vent.

### 12.5 Sons d'ambiance

| ID | Couche | Où | Règle |
| --- | --- | --- | --- |
| AMB\_Birds | Oiseaux | Forêt, actes 0 et 4 | Se tait autour de la créature (EVT\_01) |
| AMB\_Insects\_Owls | Insectes, chouettes | Forêt, actes 1 à 3 | Idem |
| AMB\_Wind\_Pines | Vent dans les pins | Partout dehors | Volume selon la force du vent |
| AMB\_River | Ruisseau | Émetteurs tous les 60 studs le long de R1, R2, R3 | Masque les bruits (9.4) |
| AMB\_Waterfall | Cascade | P13 | Masquage fort |
| AMB\_CanyonWind | Vent qui siffle | P03, P05 | — |
| AMB\_AshEmpty | Vent à vide, sans faune | P08 | Aucun animal, jamais |
| AMB\_TunnelDrips | Gouttes, souffle | P07 | — |

**Réverbération par zone** (`SoundService.AmbientReverb` mis à jour par zone) : forêt `Forest`, gorges `Mountains`, tunnels `Cave`, cabane et bâtiments `Room`, plateau et zone interdite `Plain`.

**Pas des joueurs :** un jeu de 4 variantes par matériau : Grass, LeafyGrass, Ground, Mud, Pebble, Rock, Basalt, Sand (cendre), Snow, Water, bois (cabane, pont), métal (escaliers des tours).

### 12.6 Musique

| ID | Quand | Style |
| --- | --- | --- |
| MUS\_Lobby | Lobby | Guitare sèche lente, très discrète |
| MUS\_Siege | Acte 2, pendant le bombardement | Bourdon grave continu |
| MUS\_Chase | La créature attaque ou charge le joueur local à moins de 60 studs | Percussions graves et cordes ; coupure nette quand elle perd sa cible |
| MUS\_Dawn | Cinématiques d'extraction | Cordes, une note tenue |
| — | Tout le reste | **Pas de musique** |

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

## 16. Architecture des scripts

L'expérience a deux places : **Lobby** (place de départ) et **Partie**. Le serveur fait autorité sur tout ce qui compte ; le client affiche et envoie des intentions. Toute valeur réglable vit dans `ReplicatedStorage/Config`, commentée en français.

### 16.1 Arborescence

```
ReplicatedStorage/
  Config/       PlayerConfig, ItemConfig, WeaponConfig, CreatureConfig, DirectorConfig,
                ActConfig, MapConfig, AmbienceConfig, GoreConfig, AudioConfig,
                LoreConfig (textes DOC_xx, M1-M8, dialogues), CinematicConfig, ProgressionConfig, LaunchConfig (groupe, lancement, MemoryStore)
  Shared/       Types, Util, Signal, RateLimiter, NoiseTypes, Version
  Remotes/      (RemoteEvents et RemoteFunctions de 16.3)
  Animations/   Player/, Creature/   (objets Animation, section 14)
  Characters/   <ROLE>/Skin_A..C
  Items/        modèles d'objets
  UITemplates/  BillboardGui de ping, noms
ServerStorage/
  Creatures/    CRT_Alpha, CRT_Scout, CRT_Female, Juvenile_Bones
  Props/        StickStructure, StonePile, SnappedTree, ElkRemains...
ServerScriptService/
  Bootstrap     (Script : charge les services dans l'ordre)
  Services/     (16.2)
  AI/           TensionDirector, FamilyBrain, CreatureBrain, Perception, NavGraph,
                Behaviors/ (un module par BHV_), Attacks/ (un module par ATK_),
                CreatureAnimator, MimicService, EventDirector, CreatureDebug
StarterPlayer/StarterPlayerScripts/
  Controllers/  (16.2)
StarterGui/     (section 15)
Workspace/
  Terrain, Vegetation/Chunk_X_Z, Places/Pxx_<Nom>, SpawnPoints/, ClimbPoints/,
  CluePoints/, Cinematics/, Navigation/ (nœuds CreatureNav)
```

Les modules partagés (`Config`, `Shared`) sont identiques dans les deux places. `Shared/Version` porte un numéro ; le Lobby l'envoie avec la configuration de partie ; la Partie la compare à la sienne et, si elles diffèrent, renvoie le groupe au Lobby avec MSG\_VersionMismatch.

### 16.2 Services et contrôleurs

| Place | Côté | Module | Rôle |
| --- | --- | --- | --- |
| Les deux | Serveur | `DataService` | DataStore, verrouillage de session, sauvegarde toutes les 120 s et à la fermeture |
| Lobby | Serveur | `PartyService`, `MatchmakingService` | Groupes, codes, file rapide (MemoryStore) |
| Lobby | Serveur | `RoleService`, `WeaponBoardService`, `VoteService` | Rôles uniques, armes, votes |
| Lobby | Serveur | `LaunchService` | Écrit la configuration de partie dans MemoryStore, réserve le serveur, téléporte |
| Lobby | Serveur | `DialogueService`, `MuseumService`, `SkinService`, `RecordsService` | PNJ, musée, skins, records |
| Partie | Serveur | `PartyLoaderService` | Lit la configuration, attend les joueurs (60 s max) |
| Partie | Serveur | `GameStateService` | Actes, horloge, voie d'extraction, fins, fin à 06 h 00 |
| Partie | Serveur | `SpawnService`, `CharacterService` | Départs S1–S3, skins, 6 membres |
| Partie | Serveur | `HealthService`, `FearService`, `StaminaService` | Membres, sang, à terre, mort, peur, endurance |
| Partie | Serveur | `NoiseService` | Reçoit tous les bruits (section 7, 8) et les diffuse à la perception |
| Partie | Serveur | `InventoryService`, `ItemSpawnService`, `InteractionService` | Inventaire, tirages C/K/A/J/R, `ProximityPrompt` (réparations, barricades, soins) |
| Partie | Serveur | `WeaponService` | Validation des tirs, dégâts, tir allié |
| Partie | Serveur | `EvidenceService`, `DocumentService` | Preuves A/B/C, documents |
| Partie | Serveur | `ExtractionService` | E1–E4 |
| Partie | Serveur | `WeatherService`, `CinematicService` | Météo, vent, déclenchement des cinématiques |
| Partie | Serveur | `ReturnService` | Téléportation vers le Lobby avec les résultats |
| Partie | Client | `InputController` | Clavier, manette, `MobileControlsGui` |
| Partie | Client | `CameraController`, `FootstepController`, `LightController`, `FearFXController`, `TreeWindController` | Vue, pas, lampes, effets de peur, vent dans les arbres |
| Partie | Client | `HUDController`, `InventoryController`, `ObjectiveController`, `InteractController`, `TabletController`, `DocumentController`, `DownedController`, `SpectatorController`, `RadioController` | Interfaces de la section 15.4 |
| Les deux | Client | `AmbienceController`, `CinematicController`, `SettingsController`, `NotificationController` | Lumière, sons, cinématiques, réglages |

### 16.3 Communication client ↔ serveur

Les jauges (santé par membre, sang, endurance, peur, pile, munitions) passent par des **attributs** du joueur, répliqués automatiquement. Les interactions passent par des `ProximityPrompt`, dont l'événement `Triggered` arrive déjà côté serveur. Il reste donc peu de remotes. Toutes celles du client vers le serveur sont limitées à 10 appels par seconde.

| Remote | Sens | Données | Contrôle serveur |
| --- | --- | --- | --- |
| `RE_SetStance` | C → S | debout, accroupi, couché, course | Vitesse réelle comparée à la posture |
| `RE_EquipSlot`, `RE_UseItem`, `RE_DropItem` | C → S | n° d'emplacement | Objet présent, pas en action |
| `RE_PickupItem` | C → S | id de l'objet | Distance ≤ 10 studs |
| `RE_ToggleLight` | C → S | — | Lampe équipée, pile > 0 |
| `RE_FireWeapon` | C → S | origine, direction, horodatage | Origine à moins de 5 studs de la tête, cadence, munitions |
| `RE_Reload` | C → S | — | Réserve > 0 |
| `RE_Ping` | C → S | position | 1 toutes les 2 s |
| `RE_TabletAction` | C → S | appli, action, données | Porte la tablette |
| `RE_CinematicSkipVote`, `RE_Spectate` | C → S | — / joueur suivi | — |
| `RE_Objective`, `RE_PlayCinematic`, `RE_Notify`, `RE_OpenDocument`, `RE_EndGame` | S → C | acte, texte / id / clé de texte / id / résultats | — |
| Lobby : `RE_PartyCreate`, `RE_PartyJoin`, `RE_PartyQuickJoin`, `RE_PartyLeave`, `RE_SelectRole`, `RE_TakeWeapon`, `RE_Vote`, `RE_Ready`, `RE_DialogueChoice`, `RE_EquipSkin`, `RE_MuseumRead` | C → S | selon le nom | Appartenance au groupe, unicité des rôles, déblocages |

### 16.4 Données

**DataStore `PisteFroide_v1`**, clé `player_<UserId>` :

```
{ version = 1, xp = 0, plays = 0, survivals = 0,
  endings = { Survie = false, Preuve = false, Verite = false, Ordonnance = false, Silence = false },
  evidence = { { class = "A", kind = "Video", date = 0 } },      -- 200 au plus
  skins = { Leader = { A = true, B = false, C = false }, ... },
  equipped = { Leader = "A", ... },
  notebookPages = { true, false, false },
  museumRead = { M1 = false, ... },
  nightmareUnlocked = false,
  settings = { ... } }
```

**MemoryStore :** `Parties` (carte triée, durée de vie 900 s) pour les groupes du lobby ; `Launch_<PrivateServerId>` (600 s) pour la configuration lue par la Partie (joueurs, rôles, armes, difficulté, météo, départ, graine).

La clé de lancement utilise l'identifiant du serveur réservé : le Lobby l'obtient en réservant le serveur, la Partie le lit dans `game.PrivateServerId`. Le code d'accès, lui, n'est pas lisible depuis la Partie.

**Identifiants :** expérience « PISTE FROIDE (test) », PlaceId Lobby **77677833738174**, PlaceId Partie **103506696801797** (relevés dans Studio le 22 octobre 2026 ; à reconfirmer dans le Creator Dashboard si l'expérience a été recréée). Ils vont dans `Config/LaunchConfig`.

**Valeurs techniques du lancement et de `DataService`** (verrou de session, nombre d'essais, délais) : les valeurs proposées par Claude Code en phase A1 sont acceptées telles quelles le 4 novembre 2026. Elles restent dans `Config`, commentées.

**XP :** niveau = partie entière de la racine de (XP ÷ 100). Gains : panneau de musée lu 5, partie jouée 50, survie 200, preuves selon 8.4.

### 16.5 Format d'un module de configuration

```lua
-- ReplicatedStorage/Config/MapConfig (extrait)
-- Toutes les positions viennent de la section 3 de la bible. Ne rien ajouter ici sans la bible.
local MapConfig = {}

MapConfig.Places = {
	P01 = { name = "Parking du sentier d'Ape Canyon", pos = Vector3.new(2800, 120, 3200), radius = 60 },
	P05c = { name = "Ruine de la cabane de 1924", pos = Vector3.new(2550, 300, -1300), radius = 25 },
	P11 = { name = "Tour de guet centrale", pos = Vector3.new(0, 420, -1600), radius = 15 },
}

MapConfig.Spawns = {
	S1 = Vector3.new(2780, 120, 3220),
	S2 = Vector3.new(-1380, 70, 3290),
	S3 = Vector3.new(-820, 230, 640),
}

return MapConfig
```

## 17. Réglages graphiques, performances, mobile

Le jeu vise 60 images/s sur un PC moyen et 30 images/s sur un téléphone milieu de gamme, avec 10 joueurs. Une fonctionnalité trop lourde est désactivée par le réglage, jamais supprimée.

### 17.1 Budgets

| Poste | PC | Mobile |
| --- | --- | --- |
| Images par seconde | 60 | 30 |
| `StreamingEnabled` | Oui | Oui |
| Rayon de streaming visé | 1 024 studs | 512 studs |
| Lampes avec ombres actives | 6 | 2 |
| Arbres animés par os | à moins de 120 studs | aucun |
| Débris physiques non ancrés | 60, disparition après 30 s | 20, après 15 s |
| Flaques de sang | 40 | 15 |
| Mémoire client (à mesurer dans la console développeur) | ≤ 1,5 Go | ≤ 800 Mo |

Le rayon de streaming est fixé par le serveur pour tous : la « distance d'affichage » du menu ne règle donc que le décor côté client (petite végétation taguée `Clutter`, effets).

Les lieux qui contiennent des scripts ou des objectifs (P05c, P09, P11, les véhicules) sont réglés pour rester chargés (`ModelStreamingMode` persistant), afin qu'un objectif ne disparaisse jamais.

### 17.2 Menu Réglages (façon Sons of the Forest)

| Onglet | Réglage | Valeurs | Défaut PC / mobile |
| --- | --- | --- | --- |
| Graphismes | Préréglage | Bas, Moyen, Élevé, Ultra | Élevé / Bas |
| Graphismes | Luminosité (gamma) | −0,5 à +0,5 ajouté à `ExposureCompensation`, avec écran de calibrage « le symbole doit être à peine visible » | 0 |
| Graphismes | Distance d'affichage du décor | 25 %, 50 %, 75 %, 100 % | 100 % / 50 % |
| Graphismes | Densité de végétation | 25 %, 50 %, 75 %, 100 % | 100 % / 50 % |
| Graphismes | Vent dans les arbres | Oui / Non | Oui / Non |
| Graphismes | Ombres des lampes | Oui / Non | Oui / Non |
| Graphismes | Profondeur de champ, flou lumineux | Oui / Non | Oui / Non |
| Graphismes | Densité des particules (pluie, neige, cendre) | Faible, Normale | Normale / Faible |
| Graphismes | Champ de vision | 60 à 90 | 70 |
| Contrôles | Sensibilité, inverser l'axe vertical | — | 1,0 / non |
| Contrôles | Taille des boutons tactiles | 80 % à 130 % | — / 100 % |
| Audio | Général, ambiance, voix, musique, effets | 0 à 100 | 80 |
| Accessibilité | Sous-titres, taille | Oui / Non ; 3 tailles | Oui ; moyenne |
| Accessibilité | Réduire les mouvements (balancement de caméra) | Oui / Non | Non |
| Accessibilité | Gore réduit (11.4) | Oui / Non | Non |
| Accessibilité | Langue | Français, anglais | Langue du compte |

Les réglages sont sauvegardés dans `settings` (16.4).

### 17.3 Ce que change chaque préréglage

| Élément | Bas | Moyen | Élevé | Ultra |
| --- | --- | --- | --- | --- |
| Petite végétation (`Clutter`) | 40 % | 70 % | 100 % | 100 % |
| Ombres des lampes | Lampe du joueur seulement | 2 | 6 | 6 |
| Arbres animés | Non | Non | 120 studs | 200 studs |
| Profondeur de champ, bloom | Non | Bloom | Oui | Oui |
| Particules | Faible | Normale | Normale | Normale |
| Flaques de sang | 15 | 25 | 40 | 40 |

### 17.4 Mobile

- `MobileControlsGui` (15.4) remplace les touches ; le joystick de déplacement est celui de Roblox.
- Vibration à chaque blessure et pendant une saisie (si l'appareil le permet).
- Interfaces lisibles sur un écran de 6 pouces : texte à 14 au minimum (15.2).
- Test obligatoire à chaque jalon : émulateur d'appareils de Studio, puis un vrai téléphone avant la publication.

## 18. Plan de production et critères d'acceptation

Le jeu se construit en 15 jalons, un par session Claude Code, chacun testé en jeu avant le suivant. Le jalon 0 est le travail de Gabriel.

### 18.1 Remettre ce document à Claude Code

1. Exporter ce document en Markdown et l'enregistrer dans le dossier du projet sous le nom `BIBLE_PISTE_FROIDE.md`. Les tableaux de coordonnées suffisent : un dessin de carte serait perdu à l'export.
2. À la première session, Claude Code crée `CLAUDE.md` (rappel des règles de la section 0, chemin de la bible) et `SUIVI.md` (jalons, `TODO(BIBLE)`, assets `MANQUANT_`).
3. Message à coller au début de chaque session :

```
Lis CLAUDE.md, SUIVI.md, puis BIBLE_PISTE_FROIDE.md sections 0, 16 et <SECTION DU JALON>.
Fais uniquement le jalon J<N>. N'invente rien : toute information absente de la bible
devient un TODO(BIBLE) dans le code et une question pour moi.
Termine par : critères d'acceptation cochés ou non, erreurs de la console, capture d'écran,
mise à jour de SUIVI.md, résumé en 5 lignes.
```

### 18.1 bis Travail en cloud, puis dans Studio

Gabriel veut que Claude Code avance seul autant que possible. Le travail se fait donc en deux phases : d'abord tout ce qui se fait sans Studio (en cloud), puis seulement ce qui exige Studio.

**Outil :** Rojo. Claude Code écrit le projet sous forme de fichiers (scripts `.luau`, modules `Config`, instances d'UI en `.model.json`), puis `rojo build` assemble les fichiers de place `Lobby.rbxlx` et `Partie.rbxlx`. Gabriel n'a qu'à les ouvrir dans Studio. Fonctionnement exact de Rojo à vérifier au début de la phase A.

**Assets :** Claude Code télécharge seul les assets Poly Haven (CC0, sans compte) et les note dans `ReplicatedStorage/Credits`. Les assets Sketchfab demandent un compte : Claude Code prépare la liste des liens, Gabriel télécharge.

| Phase | Où | Jalons | Ce que Claude Code produit |
| --- | --- | --- | --- |
| A1 | Cloud | J1 | Arborescence Rojo, `Config`, `Shared`, remotes, `DataService`, téléportation Lobby ↔ Partie |
| A2 | Cloud | J5 | Toutes les UI en fichiers d'instances, noms de la section 15, `UI_MAP.md` |
| A3 | Cloud | J6, J7, J8 | Joueur, objets, inventaire, tablette, documents, preuves, armes |
| A4 | Cloud | J9 | Actes, horloge, extractions, fins, cinématiques (scripts), lobby (scripts) |
| A5 | Cloud | J10, J11, J12 | IA complète de la famille, directeur de tension, événements inexpliqués |
| A6 | Cloud | J13, J14 (scripts) | Gore (deux profils), musée, dialogues, skins, records |
| A7 | Cloud | J2 (préparation) | Script `TerrainBuilder` complet, prêt à lancer, et téléchargement des textures Poly Haven |
| A8 | Cloud | — | `rojo build` des deux places, liste de ce qui reste à faire dans Studio |
| B1 | Studio | J2, J3 | Lancer `TerrainBuilder`, vérifier les positions, poser la végétation |
| B2 | Studio | J4 | Lumière, brouillard, météo, sons : réglage à l'œil, captures |
| B3 | Studio | J0, J15 | Import des modèles 3D et animations, tests en jeu, mobile, équilibrage |

En phase A, rien ne peut être testé en jeu. Chaque phase A se termine donc par une relecture du code (zéro erreur de syntaxe, aucune valeur hors `Config`) ; les vrais tests ont lieu en phase B.

### 18.1 ter Synchroniser la session cloud et la session Studio

La phase A et la phase B sont deux sessions Claude Code différentes. Elles partagent un seul dépôt Git, qui est la mémoire commune : rien ne passe d'une session à l'autre en dehors de ce dépôt.

**Fichiers de passation (à la racine du dépôt) :**

| Fichier | Écrit par | Contenu |
| --- | --- | --- |
| `BIBLE_PISTE_FROIDE.md` | Gabriel | Ce document, seule source de vérité |
| `CLAUDE.md` | Session cloud, au début | Règles de la section 0, rappel de ce tableau |
| `SUIVI.md` | Les deux sessions | Phases faites, `TODO(BIBLE)`, assets `MANQUANT_`, questions pour Gabriel |
| `HANDOFF.md` | Session cloud, à la fin | Ce qui est prêt, ce qui reste à faire dans Studio, ordre exact, commandes à lancer |
| `builds/Lobby.rbxlx`, `builds/Partie.rbxlx` | Session cloud | Places assemblées par Rojo |

**Qui fait foi, et quand :**

| Contenu | Avant la 1re ouverture dans Studio | Après |
| --- | --- | --- |
| Scripts et modules `Config` | Fichiers du dépôt | Fichiers du dépôt (synchronisés par `rojo serve` dans Studio) |
| Interfaces (UI) | Fichiers `.model.json` | **Studio.** Les fichiers d'UI sont retirés du projet Rojo ; toute retouche de Gabriel est conservée |
| Terrain, éclairage, modèles 3D placés | — | **Studio** |

**Règles :**

1. La session cloud finit toujours par un commit, `HANDOFF.md` à jour, et le build des deux places.
2. La session Studio commence par lire `CLAUDE.md`, `SUIVI.md` et `HANDOFF.md`, puis ouvre les places de `builds/`.
3. Dès que Gabriel a ouvert une place, plus aucun `rojo build` ne doit l'écraser. Les scripts passent ensuite uniquement par `rojo serve`.
4. Une UI modifiée dans Studio est réexportée dans le dépôt (`ui-export/`) à chaque fin de session, pour sauvegarde, sans être réinjectée par Rojo.
5. Chaque session note dans `SUIVI.md` la date, ce qu'elle a fait et ce qu'elle a laissé ouvert.

### 18.2 Jalons

| Jalon | Contenu | Sections | Critères d'acceptation |
| --- | --- | --- | --- |
| J0 (Gabriel) | Télécharger et vérifier les licences des assets ; réduire dans Blender ; décider les points de la section 19 | 13, 19 | Chaque asset « à valider » passé en validé ou écarté |
| J1 | Squelette des deux places, `Config`, `Shared`, remotes, `DataService`, téléportation Lobby → Partie → Lobby avec la configuration en MemoryStore | 16 | Un groupe de 2 part et revient ; données sauvegardées ; zéro erreur console |
| J2 | Terrain par `TerrainBuilder` : relief, gorges, rivières, lac, routes, sentiers, F01, limites ; un bloc gris étiqueté par lieu | 3 | Toutes les positions à ±5 studs du tableau 3.2 ; P01 → P05 par T1 (≈ 4 700 studs) en 6 à 8 min de marche ; aucune zone bloquante hors F01 et bords |
| J3 | Matériaux, `MaterialVariant`, végétation par blocs, LOD, streaming | 3.6, 13, 17 | ≤ 20 000 modèles ; 60 images/s PC et 30 en émulateur mobile sur P04 |
| J4 | Lumière par acte, brouillard par zone, météo, vent, sons d'ambiance, réverbération | 12 | Captures de chaque moment validées par Gabriel ; nuit noire réelle entre 0 h et 4 h |
| J5 | Toutes les UI en instances, `UI_MAP.md` | 15 | Aucun `Instance.new` d'UI dans le code ; affichage correct sur PC et mobile |
| J6 | Joueur : personnages, postures, caméra, membres, sang, à terre, mort, spectateur, endurance, peur, bruit | 7 | Chaque valeur de la section 7 vérifiable dans `CreatureDebug` ou la console |
| J7 | Objets, inventaire, tablette, documents, preuves, tirages aléatoires | 2.7, 3.4, 8 | 6 indices sur 12 tirés ; graine affichée ; preuves sauvegardées après extraction |
| J8 | Armes et mêlée, validation serveur, tir allié | 8.2 | Tir impossible sans munitions ; cadence respectée ; tir allié seulement en Difficile et Cauchemar |
| J9 | Actes, horloge, voies d'extraction, fins, cinématiques (plans provisoires), déroulé complet du lobby | 4, 5, 6 | Une partie complète jouable sans créature, de CS\_02 à l'écran de résultats |
| J10 | Créature v1 : capsule de 10 studs puis modèle, déplacement, perception, coup et saisie | 9.2–9.4, 9.10, 9.11 | Elle suit un joueur bruyant, perd un joueur couché dans les fougères, grimpe par les `ClimbPoint` |
| J11 | Créature v2 : tous les comportements, échelle d'intimidation, cible, mémoire, famille, imitation, personnalités | 9.5–9.9 | Chaque comportement observé au moins une fois en test ; aucune attaque sans signal |
| J12 | Directeur de tension et événements inexpliqués | 9.12, 10 | Aucun mort en acte 1 hors exceptions ; au moins un temps fort par acte |
| J13 | Gore (deux profils), ragdoll, option gore réduit | 11 | Bascule `Restricted` / `Moderate` sans erreur ; limites fixes respectées |
| J14 | Lobby complet : ville, musée, dialogue, skins, records, résultats | 4, 15.3 | Les 8 panneaux lisibles avec sources ; déblocages corrects |
| J15 | Habillage final, performances, test mobile réel, équilibrage à 1, 5 et 10 joueurs | 17, tout | Durée de partie entre 35 et 52 min sur 3 tests ; budgets 17.1 tenus |

### 18.3 Règles d'arrêt

- Bloqué plus de 30 minutes sur un bug : Claude Code s'arrête et explique.
- Claude Code ne publie pas le jeu, ne remplit pas le questionnaire de maturité, ne crée pas de produit payant.
- Les animations finales et les voix sont faites par Gabriel ; Claude Code prépare les emplacements et les listes.

## 19. Sourcé, interprété, non confirmé, et décisions

### 19.1 Affirmations sourcées

- 1 stud = 28 cm ([Roblox](https://create.roblox.com/docs/physics/units)) ; textures 1 024 px au plus ([creator-docs](https://github.com/Roblox/creator-docs/blob/main/content/en-us/art/modeling/texture-specifications.md)) ; vent global sur herbe, nuages, particules ([Roblox](https://create.roblox.com/docs/environment/global-wind)) ; coûts et paramètres de `PathfindingService` ([Roblox](https://create.roblox.com/docs/reference/engine/classes/PathfindingService)).
- Labels de maturité, démembrement et sang abondant réservés aux 18+ vérifiés, interdits absolus ([Roblox](https://create.roblox.com/docs/production/promotion/content-maturity)) ; Restricted passé à 18+, créateurs 18+ pour publier ([DevForum](https://devforum.roblox.com/t/updating-age-requirements-for-experiences-with-%E2%80%98restricted%E2%80%99-content-maturity-label/3905863)).
- Ape Canyon : 1924, créatures d'environ 7 pieds, trois balles, pierres, enquête des rangers Huffman et Welch, gorge qui se resserre à 8 pieds ([Wikipedia](https://en.wikipedia.org/wiki/Ape_Canyon)) ; siège jusqu'à l'aube ([Atlas Obscura](https://www.atlasobscura.com/places/ape-canyon)) ; livre de 1967 ([Cryptomundo](https://cryptomundo.com/?p=68085)).
- Ape Cave : \~2 000 ans, découverte en 1947 par Lawrence Johnson, nom des St. Helens Apes ([The Columbian](https://columbian.com/news/2022/aug/07/ape-cave-makes-for-dark-cold-creepy-adventure-in-gifford-pinchot)) ; 15 m sous terre en moyenne, 6 °C ([Wikipedia](https://en.wikipedia.org/wiki/Ape_Cave)) ; bouchon de lahar il y a \~450 ans ([Oregon Hikers](https://www.oregonhikers.org/field_guide/Ape_Cave)).
- Ordonnance 69-01 et son amendement de 1984 ([registre du comté](https://codepublishing.com/WA/SkamaniaCounty/html/SkamaniaCountyOT.html)), peines de 1969 ([Skagit Valley Herald](https://www.goskagit.com/anacortes/news/how-to-find-bigfoot-or-at-least-a-t-shirt-in-skagit-county/article_7018d3ac-751d-11ef-ad64-531ceaf74f60.html)), « primate nocturne » ([WSBA](https://nwsidebar.wsba.org/2019/10/31/washington-rules-to-make-you-scream-this-halloween-completely-bizarre-but-totally-real-laws-legislation-and-legal-references/)), peine actuelle ([Denver Gazette](https://www.denvergazette.com/?p=112245)).
- Éruption de 1980 : 8 h 32, magnitude 5,1, 57 morts, 600 km² ([Wikipedia](https://en.wikipedia.org/wiki/Mount_St._Helens)) ; radeau de troncs du lac Spirit ([Wikipedia](<https://en.wikipedia.org/wiki/Spirit_Lake_(Washington)>)) ; boue dans Lava Canyon ([The Columbian](https://columbian.com/news/2013/jul/10/ape-canyon-trail-mount-hiking)).
- Noms Lawetlat'la et Loowit, inscription de 2013 ([The Columbian](https://columbian.com/news/2015/sep/06/mount-st-helens-name-appears-safe)) ; récits des « Stick Indians » ([Native Languages](https://www.native-languages.org/morelegends/stick-indians.htm)) ; « stick-showers » ([Chinook Jargon](https://chinookjargon.com/2021/03/17/pre-1917-ka-mi-akin-last-hero-of-the-yakamas-part-2-of-2/)).
- Comportements de grands singes : martellement de poitrine ([National Geographic](https://www.nationalgeographic.com/animals/article/why-do-gorillas-beat-their-chests)) ; lancer de pierres accumulatif ([Scientific Reports](https://doi.org/10.1038/srep22219)).
- Route 83, sentier 234, pont de Lava Canyon, fermeture hivernale ([Forest Service](https://www.fs.usda.gov/r06/giffordpinchot/recreation/trails/trail-234-ape-canyon), [The Columbian](https://columbian.com/news/2012/jul/10/lots-hike-lava-canyon), [Visit Mt St Helens](https://www.visitmtsthelens.com/business-directory/ape-canyon-trail-234/)) ; fermeture de Johnston Ridge ([Wikipedia](https://en.wikipedia.org/wiki/Johnston_Ridge_Observatory)) ; Cougar ([Wikipedia](https://en.wikipedia.org/wiki/Cougar,_Washington)).
- Jeu BIGFOOT sur Steam : chasse, modes contre l'IA ou contre un joueur, coop ([Steam](https://store.steampowered.com/app/509980/BIGFOOT/), [SteamGifts](https://www.steamgifts.com/giveaway/eFp0t/bigfoot)).

### 19.2 Affirmations interprétatives (choix de design)

- Tout le scénario de fiction, les personnages, les documents, les dialogues et les textes du musée (qui résument des faits sourcés avec mes mots).
- Toutes les positions en studs, la compression horizontale et verticale, F01, P07b et P07c, les altitudes.
- Toutes les valeurs chiffrées de jeu (vitesses, dégâts, PV, portées, durées, probabilités, budgets internes).
- L'adaptation des comportements de gorille et de chimpanzé à une créature fictive : ce sont des inspirations, pas une preuve qu'un tel animal existe.
- Le rapprochement entre les événements étranges et des explications naturelles.

### 19.3 Éléments non confirmés

- Limite de triangles par maillage : 20 000 à 21 000 selon des sources secondaires, à tester dans l'importateur.
- Existence et noms exacts : `Model.LevelOfDetail = StreamingMesh`, `ModelStreamingMode`, `MaterialVariant` sur le terrain, polices Special Elite et Roboto Mono, types de réverbération `Forest`, `Mountains`, `Cave`, `Room`, `Plain`. À vérifier dans Studio au jalon concerné.
- Vitesse de marche par défaut du Humanoid (16) : connue, non rouverte ici ; le jeu impose de toute façon 12.
- Licences de presque tous les modèles Sketchfab, des animations Mixamo et du modèle de whitehair19.
- Les reflets d'yeux (EVT\_13, CS\_05) : à ma connaissance, les grands singes n'ont pas de couche réfléchissante dans l'œil ; c'est donc volontairement ambigu (un cerf ?). Non vérifié ici.
- Les pages des jeux Bigfoot sur Roblox n'ont pas pu être ouvertes.
- Date de découverte d'Ape Cave : 1947 selon le Forest Service, \~1951 dans un autre récit cité par Wikipedia.
- Le passage du ranger « Sur un ours, si vous n'avez pas le choix » n'est pas une règle de chasse vérifiée : c'est une réplique, pas un conseil.

**Sources écartées :** sort-of-history.vercel.app (faux wiki qui invente des personnes et des documents), les pages SEO sur « Roblox Bigfoot », Sasquatch Chronicles et les blogs non sourcés, les wikis Fandom.

### 19.4 Décisions à valider par Gabriel

- [ ] Décidé le 5 novembre (19.5) : Moderate pour l'expérience principale. **Bloquant — Restricted 18+ :** as-tu 18 ans et un âge vérifié sur Roblox ? Sinon : publier en profil Moderate (sang léger, pas de démembrement), ou attendre. Le proche fan de Bigfoot devra avoir 18 ans pour la version Restricted.
- [ ] **Langue du jeu :** anglais par défaut avec traduction française (public plus large, lieu américain), ou français seulement.
- [ ] **Voix :** qui enregistre les 60 répliques (section 13.7), et dans quelle langue.
- [ ] Les corrections de cette bible : marche à 12 studs/s, raccourci de 2 min (et non 3), parties de 35 à 52 min, acte 2 jusqu'à 14 min, Nora arrière-arrière-petite-fille, Restricted 18+.
- [ ] Les nouveautés : falaise F01, salle du repaire P07b, sortie P07c, tablette de terrain, personnalités de l'Alpha, échelle d'intimidation, odorat selon le vent.
- [ ] Les noms des 10 personnages et des 4 géologues.
- [ ] Source des 10 personnages humains (MANQUANT) : je peux chercher des modèles réalistes libres avec squelette.
- [ ] Contacter whitehair19 pour le modèle de la créature, ou passer au gorille de dmlbaker.
- [ ] Chat vocal de proximité (si disponible) ou texte seulement.
- [ ] Mode « La nuit suivante » repoussé à une version 2.

### 19.5 Réponses aux questions C1–C42 (5 novembre 2026)

Ces réponses font foi en cas de conflit avec une autre section.

**Profil publié (C35, décision 19.4) :** l'expérience principale « PISTE FROIDE (test) » est publiée en profil **Moderate**, gratuite et ouverte à tous les âges que ce label autorise. Le profil Restricted reste dans le code pour une seconde expérience, plus tard, seulement si Gabriel a 18 ans vérifiés ; son contenu supplémentaire sera conçu en version 2. La monétisation (cosmétique uniquement) sera conçue après la phase B ; d'ici là, Claude Code ne crée aucun produit payant (18.3).

#### Mécaniques

| Code | Sujet | Réponse |
| --- | --- | --- |
| C6 | Porter un blessé | N'importe quel joueur, sur un coéquipier à terre : maintenir Utiliser 2 s pour le charger sur l'épaule ; Utiliser 1 s pour le poser. Porteur : vitesse 8 (Sportif 12 et peut courir), endurance −6/s, bruit 40, ni arme à feu ni lampe en main (la frontale marche). Le compte à rebours du joueur porté avance deux fois moins vite. Pas de relèvement pendant le portage. Score de cible du porteur +0,5 |
| C7 | Indices cachés de la Descendante | 4 « marques de mineurs », visibles seulement par elle à 8 studs, et seulement si elle est dans le groupe. HC1, gros bloc du lahar (2 140, 262, 380) : affiche l'emplacement de la boîte de munitions sur la tablette. HC2, plancher de la cabane P05c : ouvre une trappe vers un vide sanitaire pour 2 joueurs, invisibles à la vue de la créature (pas à l'ouïe ni à l'odorat). HC3, pierre près du pont P16 (3 420, 100, 1 660) : révèle un gué 60 studs en aval, passage silencieux (bruit ×0,4). HC4, puits P21 : anneau scellé dans la roche, descente sans corde |
| C15 | Machette | Pas d'objet de départ. Une seule, fixe, dans la cabane du chantier P10 (−1 390, 72, 3 285), prenable par tous |
| C38 | Accessoires | Bonnet (3 couleurs) après 3 parties ; frontale ambre après 10 parties ; sac « Cold Trail » après une première preuve de classe B sortie. Cosmétiques, choisis dans `SkinShopGui` |
| C42 | Lacets de T3 sous F01 | 3 segments de 5 studs de large : (−80, −780) → (80, −830) → (−80, −880) → (60, −930), de Y = 300 à Y = 340 (pente ≈ 8 %), puis T3 continue vers P11 |
| J12 | Tentatives d'attaque | Si, 10 min après le début de l'acte 3, il y a eu moins de 2 tentatives d'attaque, le directeur impose BHV\_Attack sur la meilleure cible |

#### Valeurs (fin des « PROVISOIRE »)

| Code | Sujet | Valeur |
| --- | --- | --- |
| C2 | Hémorragies | Un coup de 20 à 34 : hémorragie légère ; 35 ou plus : grave ; moins de 20 : aucune. Saisie tenue plus de 2 s : légère. Les pierres ne causent jamais d'hémorragie grave |
| C12 | Munitions au départ | Armes chargées à pleine capacité (5, 6, 4), aucune réserve. Lance-fusées : 1 fusée chargée + 2 en réserve. Seule réserve possible : la boîte A1–A5 |
| C10 | Lancers | Joueur : portée maximale 60 studs, vitesse 70 studs/s, trajectoire balistique, bruit 50 à l'impact. Créature : pierres à 90 studs/s, portée 20–120, erreur de visée = 3 % de la distance (×0,8 Difficile, ×0,6 Cauchemar), 1 lancer toutes les 3 à 5 s hors siège |
| C13 | Fusil à pompe | Cône de 6° ; 8 plombs × 18 jusqu'à 15 studs ; baisse linéaire jusqu'à 30 % à 40 studs ; 0 au-delà de 60 |
| C20, C34 | Cadence du siège (6 min) | 0:00–2:00 : 1 pierre / 4 s (±1,5 s) par créature ; 2:00–3:00 : 1 / 2,5 s ; 3:00–3:20 : silence total ; 3:20–5:00 : 1 / 2,5 s + essais sur les barricades ; 5:00–6:00 : 1 / 2 s. Les impacts sur toit et murs sont cosmétiques, sauf sur les 3 ouvertures |
| C40 | Largeur des gorges | Ape Canyon : 80 studs en haut, 20 au fond, 9 au point P05s. Lava Canyon : 60 en haut, 15 au fond. Parois à plus de 60° |
| C23 | CS\_05 (25 s) | Joue dans la tablette (`TabletGui`), sans prise de caméra : le joueur reste dans le monde et peut fermer à tout moment. La limite de 12 s et l'invulnérabilité ne s'appliquent pas |

#### Textes

**Objectifs (C19)**, affichés dans `ObjectiveGui` et la tablette :

| Acte | Voie | Objectifs, dans l'ordre |
| --- | --- | --- |
| 0 | — | Trouver le camp des géologues |
| 1 | — | Fouiller le camp · Trouver la tablette des géologues · Trouver des indices ({n}/3) |
| 2 | — | Rejoindre la cabane des mineurs avant minuit · Barricader la cabane ({n}/3) · Tenir |
| 3 | E1 | Trouver les clés du van · Trouver un cric · Changer la roue du van |
| 3 | E2 | Trouver un câble d'antenne · Apporter la batterie de l'épave à la tour · Réparer la radio de la tour |
| 3 | E3 | Trouver du carburant · Trouver le relais de démarreur · Réparer le bulldozer |
| 3 | E4 (si DOC\_07 lue, en plus) | Facultatif : suivre la carte des tunnels |
| 4 | E1 | Partir avec le van |
| 4 | E2 | Tenir sur l'aire jusqu'à l'hélicoptère ({n} s) |
| 4 | E3 | Forcer la barrière de la piste |
| 4 | E4 | Dégager la sortie basse et sortir |

Phrase de CS\_07 selon la voie : E1 « Le van. Si on retrouve les clés, on part. » ; E2 « La radio de la tour. C'est notre seule chance. » ; E3 « Le bulldozer du chantier. Il peut passer la barrière. »

**Messages radio hors du rayon d'une cinématique (C24)**, dits par le personnage du joueur le plus proche du lieu :

| Cinématique | Message |
| --- | --- |
| CS\_04 | {player} : On a trouvé le camp. Il y a… quelqu'un. Venez. |
| CS\_06 | {player} : Ça tombe sur la cabane ! Rejoignez-nous ! |
| CS\_07 | {player} : Ça s'est arrêté. Je crois. |
| Autres | Aucun message |

**Fins (C25)**, dans `ResultsGui` :

| Fin | Titre | Texte |
| --- | --- | --- |
| Survie | Sortis | Vous avez quitté la forêt avant l'aube. Personne ne vous croira. |
| Preuve | La preuve | Une vidéo. Assez pour que le monde en parle, pas assez pour qu'il y croie. |
| La vérité | La vérité | Ils n'ont pas commencé. Ils ont répondu. |
| Ordonnance 69-01 | Ordonnance 69-01 | Vous l'avez tué. Le comté de Skamania appelle ça un crime. |
| Silence | Silence | Le dernier épisode de Cold Trail s'arrête au milieu d'une phrase. |

Statut par joueur : « En vie », « Mort », « Disparu ».

**Sources du musée (C36) :** aucune adresse web dans le jeu. Les règles communautaires de Roblox interdisent d'afficher des URL de sites extérieurs, sauf quelques plateformes autorisées et filtrées par l'API de politique ([citation des règles sur le DevForum](https://devforum.roblox.com/t/link-discord-in-uigui-ingame/4010682) ; page officielle non ouverte ici). La ligne « Source » de chaque panneau donne seulement la publication et le titre :

| Panneau | Ligne « Source » |
| --- | --- |
| M1 | Wikipedia, « Ape Canyon » ; Atlas Obscura, « Ape Canyon » |
| M2 | Wikipedia, « Ape Canyon » |
| M3 | F. Beck et R. A. Beck, I Fought the Apemen of Mt. St. Helens (1967) |
| M4 | The Columbian, 7 août 2022 |
| M5 | Comté de Skamania, ordonnances 69-01 (1969) et 1984-02 (1984) |
| M6 | Wikipedia, « Mount St. Helens » et « Spirit Lake » |
| M7 | The Columbian, 6 septembre 2015 ; Native Languages of the Americas, « Stick Indians » |
| M8 | Fiction |

### 19.6 Réponses aux dernières questions (5 novembre 2026, soir)

Ces réponses retirent tous les marqueurs PROVISOIRE restants. Elles font foi en cas de conflit.

| Code | Sujet | Réponse |
| --- | --- | --- |
| C1 | Distance pour « voir » | Un corps : à 40 studs ou moins, en ligne de vue (+15, une fois par corps). La créature : en ligne de vue jusqu'à 150 studs ; +20 à 150 studs, montant linéairement jusqu'à +35 à 20 studs ou moins ; au plus une fois toutes les 10 s par créature |
| C3 | Coup reçu à terre | Une attaque de la créature sur un joueur à terre le tue. Une pierre ou un tir allié retire 10 s à son compte à rebours, sans le tuer |
| C4 | Membre soigné | Bandage et trousse soignent le membre le plus abîmé en proportion ; l'arrêt d'hémorragie s'applique quel que soit le membre |
| C5 | Sang au relèvement | Un joueur relevé après être tombé faute de sang revient à 45 de sang |
| C8 | Fusées du Pyrotechnicien | 2 fusées à main au départ, en plus du lance-fusées |
| C9 | Poids | Munitions : 0 kg (elles vont directement dans la réserve de l'arme). Carte mémoire 0 kg. Moulage 1,0 kg. Sachet de poils 0,05 kg. Document papier 0,05 kg. Cassette 0,1 kg |
| C11 | Piège à bruit | Posé en 6 s ; se déclenche au passage de la créature ou d'un joueur ; bruit de 150 studs pendant 3 s ; un seul piège posé à la fois par Pyrotechnicien |
| C14 | Lance-fusées | Cadence = rechargement (2 s). Sur un coéquipier : 30 dégâts + brûlure de 5 par seconde pendant 3 s, jamais d'hémorragie grave |
| C16 | Portée de mêlée | Hache 7 studs, machette 6 studs |
| C17 | Quantités | Points C09–C12 : 2 piles, 2 bandages, 1 fusée, 1 corde, 1 attelle selon ce que le point peut contenir (3.4). Lieux fixes : 1 objet, sauf 6 planches (P05c), 3 bandages et 2 piles au poste P17. Branches et pierres : partout au sol |
| C18 | Neige | « Endurance ×0,85 » s'applique à la récupération |
| C26 | Démarrage du van | Bruit de 1 500 studs ; le directeur autorise une attaque immédiate sur le van |
| C29 | Hors combat | 10 s sans dégâts reçus ni attaque lancée |
| C30 | Recul de ATK\_Strike | 40 studs/s vers l'arrière + 15 studs/s vers le haut |
| C31 | « Lance plus » | Fréquence des lancers ×1,5 après 2 tirs reçus |
| C32 | Catalogue « bas » du directeur | EVT\_01, 02, 03, 04, 07, 10, 11, 13, 16, 17, 18, 20, 21. Les autres suivent leurs propres règles (acte, lieu, comportement) |
| C33 | Distances des événements | « Au loin » : tiré entre 150 et 300 studs. « Tout près » : tiré entre 10 et 20 studs |
| C43 | Couleurs du bonnet | Rouge brique #7A2E24, vert mousse #4F6B45, gris anthracite #3A3A3A |

**Textes de verrous proposés par Claude Code :** validés tels quels (« Verrouillé — 3 parties jouées », « Verrouillé — 10 parties jouées », « Verrouillé — 1 preuve de classe B », « Verrouillé — 1 survie »).

**Interprétations notées dans SUIVI.md :** les quatre sont validées (bruit le plus fort des 10 dernières secondes ; Médecin deux fois plus rapide ; un acte dure au moins sa durée minimale ; « conditions d'extraction réunies » = voie principale préparée, extraction à l'acte 4).
