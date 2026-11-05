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

