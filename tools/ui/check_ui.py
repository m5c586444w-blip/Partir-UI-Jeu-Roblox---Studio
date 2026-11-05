#!/usr/bin/env python3
"""Contrôle des interfaces (bible 15, 15.7). Usage, depuis la racine du dépôt :

    python3 tools/ui/check_ui.py              # chemins de la section 15 + mise en page aux deux tailles
    python3 tools/ui/check_ui.py --previews   # idem, et aperçus PNG de chaque écran dans previews/

1. Chemins : les builds (builds/*.rbxlx) contiennent tous les chemins d'UI de la section 15.
   Sous un écran à deux dispositions (15.7, règle 1), `X/a/b` est satisfait par
   `X/Layout_Desktop/a/b` et `X/Layout_Touch/a/b` (ou la seule disposition présente, ex. tactile).
2. Mise en page : chaque écran (src/ui/**.model.json) est calculé à 1280 × 720 (PC) et à
   844 × 390 (téléphone), dans la zone sûre (ScreenInsets = CoreUISafeInsets). Sont signalés :
   - tout texte qui déborde à la taille minimale de 14 (un bouton doit tenir sur une ligne) ;
   - tout chevauchement entre deux éléments visibles en même temps (hors pastilles voulues de 15.7) ;
   - les règles chiffrées de 15.7 : boutons tactiles d'au moins 56 × 56 px et 6 au plus,
     lignes de réglages d'au moins 36 px.
   Les écrans visibles ensemble et leurs états (sac ouvert, arme en main…) sont décrits dans
   CONTEXTS ; les textes remplis par les scripts sont mesurés avec un exemple tiré de la bible
   (SAMPLES).

Le moteur reproduit les règles de Roblox utilisées par l'UI du projet : UDim2 et AnchorPoint,
UIAspectRatioConstraint (FitWithinMaxSize, ScaleWithParentSize), UISizeConstraint, UIListLayout,
UIGridLayout, ScrollingFrame (rognage), TextScaled + UITextSizeConstraint (mesure avec les vraies
polices, tools/ui/fonts). C'est une approximation : la vérification finale reste l'émulateur de Studio (15.7, 8).
"""

import fnmatch
import json
import os
import sys
import xml.etree.ElementTree as ET

from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
UI = os.path.join(ROOT, "src", "ui")
FONTS = os.path.join(ROOT, "tools", "ui", "fonts")
PREVIEWS = os.path.join(ROOT, "previews")

# DÉFAUT : tailles de 15.7 (8) et zone sûre. Haut : barre de Roblox (58 px) ; téléphone en paysage :
# encoche à gauche et à droite (47 px), barre d'accueil en bas (21 px).
SIZES = {
    "PC": {"w": 1280, "h": 720, "insets": (0, 58, 0, 0), "touch": False},
    "Telephone": {"w": 844, "h": 390, "insets": (47, 58, 47, 21), "touch": True},
}
TEXT_MIN = 14  # 15.7 : taille minimale du texte
TOUCH_MIN = 56  # 15.7 (3) : boutons tactiles d'au moins 56 × 56 px
TOUCH_MAX_VISIBLE = 6  # 15.7 (3) : au plus 6 visibles à la fois
ROW_MIN = 36  # 15.7 (4) : lignes de réglages et listes
OVERLAP_MIN = 2  # px : un chevauchement plus fin est ignoré (bords communs, arrondis)

GUI_CLASSES = {"Frame", "TextLabel", "TextButton", "TextBox", "ImageLabel", "ImageButton", "ScrollingFrame",
               "ViewportFrame", "CanvasGroup"}
TEXT_CLASSES = {"TextLabel", "TextButton", "TextBox"}

# --- états des écrans (quels ScreenGui sont visibles ensemble, et dans quel état) -------------
# show / hide : chemins forcés visibles / cachés ; touch_only : visible sur téléphone seulement.
# Un ScreenGui de menu a ses enfants directs cachés au départ (le contrôleur les montre) : ils sont
# montrés ici, sauf ceux de `hide`.
HUD = ["HUDGui", "InventoryGui", "ObjectiveGui", "InteractGui", "RadioGui", "MobileControlsGui", "NotificationGui"]
# 15.7 (3) : boutons tactiles visibles (InputController : les 6 premiers voulus, par priorité)
TOUCH_PROMPT = ["Interact", "Sprint", "Crouch", "Prone", "Light", "Tablet"]
TOUCH_WEAPON = ["Fire", "Aim", "Reload", "Sprint", "Crouch", "Prone"]
CONTEXTS = [
    # Partie
    {"name": "Partie_Jeu", "place": "Partie", "guis": HUD,
     "show": ["InteractGui/Prompt", "RadioGui/Channel", "RadioGui/Static", "NotificationGui/Stack/Template",
              "HUDGui/BleedIcon"]
     + [f"MobileControlsGui/{b}" for b in TOUCH_PROMPT],
     "hide": ["InventoryGui/Bag", "HUDGui/Crosshair", "HUDGui/Ammo"]},
    {"name": "Partie_Arme", "place": "Partie", "guis": HUD,
     "show": ["HUDGui/Crosshair", "HUDGui/Ammo", "RadioGui/Channel", "RadioGui/Static"]
     + [f"MobileControlsGui/{b}" for b in TOUCH_WEAPON],
     "hide": ["InventoryGui/Bag", "InteractGui/Prompt"]},
    {"name": "Partie_Sac", "place": "Partie", "guis": HUD,
     "show": ["InventoryGui/Bag", "RadioGui/Channel", "RadioGui/Static", "InventoryGui/Bag/List/Template"],
     "hide": ["InteractGui/Prompt", "HUDGui/Crosshair", "HUDGui/Ammo"]},
    {"name": "Partie_Tablette_Carte", "place": "Partie", "guis": ["TabletGui"],
     "show": ["TabletGui/Device", "TabletGui/Device/Screen/Pages/Page_Map/Markers/Template"]},
    {"name": "Partie_Tablette_Objectifs", "place": "Partie", "guis": ["TabletGui"],
     "show": ["TabletGui/Device", "TabletGui/Device/Screen/Pages/Page_Objectives",
              "TabletGui/Device/Screen/Pages/Page_Objectives/List/Template"],
     "hide": ["TabletGui/Device/Screen/Pages/Page_Map"]},
    {"name": "Partie_Tablette_Journal", "place": "Partie", "guis": ["TabletGui"],
     "show": ["TabletGui/Device", "TabletGui/Device/Screen/Pages/Page_Journal",
              "TabletGui/Device/Screen/Pages/Page_Journal/List/Template"],
     "hide": ["TabletGui/Device/Screen/Pages/Page_Map"]},
    {"name": "Partie_Tablette_Preuves", "place": "Partie", "guis": ["TabletGui"],
     "show": ["TabletGui/Device", "TabletGui/Device/Screen/Pages/Page_Evidence",
              "TabletGui/Device/Screen/Pages/Page_Evidence/List/Template"],
     "hide": ["TabletGui/Device/Screen/Pages/Page_Map"]},
    {"name": "Partie_Tablette_Reseau", "place": "Partie", "guis": ["TabletGui"],
     "show": ["TabletGui/Device", "TabletGui/Device/Screen/Pages/Page_Network"],
     "hide": ["TabletGui/Device/Screen/Pages/Page_Map"]},
    {"name": "Partie_Document", "place": "Partie", "guis": ["DocumentGui"], "show": ["DocumentGui/Paper"],
     "hide": ["DocumentGui/Tape"]},
    {"name": "Partie_Enregistrement", "place": "Partie", "guis": ["DocumentGui"], "show": ["DocumentGui/Tape"],
     "hide": ["DocumentGui/Paper"]},
    {"name": "Partie_ATerre", "place": "Partie", "guis": ["DownedGui"]},
    {"name": "Partie_Spectateur", "place": "Partie", "guis": ["SpectatorGui"]},
    # Lobby
    {"name": "Lobby_Hall_SansGroupe", "place": "Lobby", "guis": ["PartyGui", "NotificationGui"],
     "show": ["NotificationGui/Stack/Template"],
     "hide": ["PartyGui/PartyFrame/Buttons/Ready", "PartyGui/PartyFrame/Buttons/Leave"]},
    {"name": "Lobby_Hall_Groupe", "place": "Lobby", "guis": ["PartyGui", "VoteGui", "WeaponBoardGui", "NotificationGui"],
     "show": ["PartyGui/PartyFrame/MemberList/Template", "NotificationGui/Stack/Template"],
     "hide": ["WeaponBoardGui/VotePopup", "WeaponBoardGui/Veil", "PartyGui/PartyFrame/CodeInput"]
     + [f"PartyGui/PartyFrame/Buttons/{b}" for b in ("CreatePublic", "CreatePrivate", "JoinCode", "QuickJoin")]},
    {"name": "Lobby_VoteArme", "place": "Lobby", "guis": ["WeaponBoardGui"],
     "show": ["WeaponBoardGui/VotePopup", "WeaponBoardGui/Veil"], "hide": ["WeaponBoardGui/Board"]},
    {"name": "Lobby_Ranger", "place": "Lobby", "guis": ["DialogueGui"]},
    {"name": "Lobby_Musee", "place": "Lobby", "guis": ["MuseumPanelGui"]},
    {"name": "Lobby_Roles", "place": "Lobby", "guis": ["RoleSelectGui"]},
    {"name": "Lobby_Tenues", "place": "Lobby", "guis": ["SkinShopGui"],
     "show": ["SkinShopGui/CharacterList/Template"]},
    {"name": "Lobby_Records", "place": "Lobby", "guis": ["RecordsGui"], "show": ["RecordsGui/Board/Template"]},
    {"name": "Lobby_Preuves", "place": "Lobby", "guis": ["EvidenceBoardGui"],
     "show": ["EvidenceBoardGui/Cork/Template"]},
    {"name": "Lobby_Resultats", "place": "Lobby", "guis": ["ResultsGui"],
     "show": ["ResultsGui/Card/Survivors/Template", "ResultsGui/Card/Evidence/Template"]},
    {"name": "Lobby_Chargement", "place": "Lobby", "guis": ["LoadingGui"]},
    # les deux places
    {"name": "Commun_Cinematique", "place": "Common", "guis": ["CinematicGui"]},
    {"name": "Commun_Reglages_Graphismes", "place": "Common", "guis": ["SettingsGui"]},
    {"name": "Commun_Reglages_Controles", "place": "Common", "guis": ["SettingsGui"],
     "show": ["SettingsGui/Window/Pages/Controls"], "hide": ["SettingsGui/Window/Pages/Graphics"]},
    {"name": "Commun_Reglages_Audio", "place": "Common", "guis": ["SettingsGui"],
     "show": ["SettingsGui/Window/Pages/Audio"], "hide": ["SettingsGui/Window/Pages/Graphics"]},
    {"name": "Commun_Reglages_Accessibilite", "place": "Common", "guis": ["SettingsGui"],
     "show": ["SettingsGui/Window/Pages/Accessibility"], "hide": ["SettingsGui/Window/Pages/Graphics"]},
]
TOUCH_ONLY = {"MobileControlsGui"}
TEMPLATE_CLONES = 3  # lignes clonées pour mesurer une liste
TEMPLATE_CLONES_BY_GUI = {"NotificationGui": 2}  # PlayerConfig.Interface.NotificationMax

# 15.7 : pastilles voulues (jamais signalées)
EXEMPT = [
    ("InventoryGui/*QuickSlots/Slot_*/Count", "InventoryGui/*QuickSlots/Slot_*/Icon"),
    ("InventoryGui/*QuickSlots/Slot_*/Key", "InventoryGui/*QuickSlots/Slot_*/Icon"),
    ("CinematicGui/Skip*", "CinematicGui/BarBottom"),
    ("TabletGui/*/Page_Map/Markers/*", "TabletGui/*/Page_Map/MapImage"),
    ("TabletGui/*/Page_Map/Markers/*", "TabletGui/*/Page_Map/TunnelLayer"),
    ("TabletGui/*/Page_Map/PlayerDot", "TabletGui/*/Page_Map/MapImage"),
    ("TabletGui/*/Page_Map/PlayerDot", "TabletGui/*/Page_Map/TunnelLayer"),
    ("TabletGui/*/Page_Map/NoSignal", "TabletGui/*/Page_Map/MapImage"),
    ("TabletGui/*/Page_Map/NoSignal", "TabletGui/*/Page_Map/TunnelLayer"),
    ("TabletGui/*/Page_Map/TunnelLayer", "TabletGui/*/Page_Map/MapImage"),
    ("TabletGui/*/Page_Map/Markers/*", "TabletGui/*/Page_Map/Markers/*"),
    ("TabletGui/*/Page_Map/Markers/*", "TabletGui/*/Page_Map/PlayerDot"),
]
# calques plein écran voulus (vignettage de la peur, voile des fenêtres, fond de chargement)
OVERLAYS = ["HUDGui/*FearVignette", "*/Veil", "LoadingGui/Background", "HUDGui/*Ping"]

# --- textes d'exemple (bible) pour les libellés remplis par les scripts -------------------------
# exemples propres à une place (même chemin dans les deux places)
SAMPLES_BY_PLACE = {
    "Lobby": {"NotificationGui/*Text": "Ta progression n'a pas pu être chargée. Elle ne sera pas sauvegardée "
                                       "pendant cette session."},  # 4.6 (MSG_DataLoadFailed)
}
SAMPLES = {
    "ObjectiveGui/*ActName": "L'enquête",  # 5.1
    "ObjectiveGui/*ObjectiveText": "Apporter la batterie de l'épave à la tour\nFacultatif : suivre la carte des tunnels",
    "ObjectiveGui/*Clock": "23 h 05",
    "InteractGui/*Prompt/ActionText": "Dégager le bouchon",  # 5.2
    "InteractGui/*Prompt/KeyHint": "F",
    "HUDGui/*HeldItem": "Caméscope vision nocturne",  # 8.1
    "HUDGui/*Ammo/Count": "6",
    "HUDGui/*Ammo/Reserve": "12",
    "RadioGui/*Channel": "Canal 2",
    "NotificationGui/Stack/Template*/Text": "Joueur_123456 : On a trouvé le camp. Il y a… quelqu'un. Venez.",  # 19.5
    "InventoryGui/*Bag/Weight": "12,5 / 15 kg",
    "InventoryGui/*Bag/List/Template*/Name": "Caméscope vision nocturne",
    "InventoryGui/*Bag/List/Template*/Count": "3",
    "InventoryGui/*QuickSlots/Slot_*/Count": "3",
    "InventoryGui/*QuickSlots/Slot_*/Key": "4",
    "TabletGui/*Page_Objectives/List/Template*": "Tenir sur l'aire jusqu'à l'hélicoptère (180 s)",  # 19.5
    "TabletGui/*Page_Journal/List/Template*": "Carnet de la famille Halvorsen",  # 2.7
    "TabletGui/*Page_Evidence/List/Template*": "B · Enregistrement d'un cri · Joueur_123456",  # 8.1
    "TabletGui/*Device/BatteryText": "100 %",
    "TabletGui/*Page_Journal/Reader/Title": "J-17 02:14",
    "TabletGui/*Page_Journal/Reader/Body": "Point de repli de l'équipe : cabane des mineurs",  # 6.2
    "DocumentGui/*Paper/Title": "Carnet de la famille Halvorsen",
    "DocumentGui/*Paper/Body": "DISPARUS depuis le 7 octobre : Dr A. Whitcombe, S. Ito, B. Castillo, L. Brandt. "
                               "Recherches suspendues. Toute information : Skamania County Sheriff.",  # 2.7
    "DocumentGui/*Tape/Label": "Cassette 2 (Whitcombe)",  # 2.7
    "DownedGui/*Countdown": "45",
    "SpectatorGui/*Watching": "Joueur_123456",
    "PartyGui/*Header/Code": "4821",
    "PartyGui/*MemberList/Template*/PlayerName": "Joueur_123456",
    "PartyGui/*MemberList/Template*/RoleName": "Opératrice radio",
    "VoteGui/*Countdown": "Départ dans 10 s",
    "WeaponBoardGui/*Holder": "Joueur_123456",
    "WeaponBoardGui/*VotePopup/Question": "Joueur_123456 veut aussi le fusil à verrou",
    "WeaponBoardGui/*VotePopup/Option_*": "Joueur_123456",
    "WeaponBoardGui/*VotePopup/Timer": "10 s",
    "DialogueGui/*SpeakerName": "Ranger Dale Hollis",  # 4.2
    "DialogueGui/*Line": "Vous êtes les gamins du podcast ? Je vais vous dire ce que j'ai dit aux autres : n'y allez pas.",
    "DialogueGui/*Choice_1": "Qu'est-ce qui s'est passé en 1924 ?",
    "DialogueGui/*Choice_2": "On a le droit de tirer ?",
    "DialogueGui/*Choice_3": "Où sont les géologues ?",
    "MuseumPanelGui/*Title": "L'ordonnance 69-01",  # 4.3
    "MuseumPanelGui/*Source": "The Columbian, 6 septembre 2015 ; Native Languages of the Americas, « Stick Indians »",
    "MuseumPanelGui/*Body": "Pour les Cowlitz, le volcan est Lawetlat'la, « celui qui fume » ; pour les Klickitat, "
                            "Loowit. Plusieurs peuples du Nord-Ouest racontent aussi des êtres de la forêt dont on "
                            "évite de dire le nom. Ces récits appartiennent à des cultures vivantes.",  # 4.3 (M7)
    "SkinShopGui/*CharacterList/Template*": "Nora Halvorsen",
    "RoleSelectGui/*TakenBy": "Joueur_123456",
    "RoleSelectGui/Detail/Ability": "Voit ses coéquipiers en contour à travers le décor ; donne un ordre qui réduit "
                                    "la peur",  # 7.7 (la plus longue)
    "RoleSelectGui/Detail/Weakness": "Inventaire : 3 emplacements rapides au lieu de 4",  # 7.7
    "RecordsGui/*Board/Template*/Rank": "10",
    "RecordsGui/*Board/Template*/Group": "Joueur_123456, Joueur_234567",
    "RecordsGui/*Board/Template*/Value": "10",
    "EvidenceBoardGui/*Cork/Template*/Label": "Enregistrement d'un cri",  # 8.1
    "EvidenceBoardGui/*Cork/Template*/Class": "Classe B",
    "ResultsGui/*EndingTitle": "Ordonnance 69-01",  # 19.5 (C25)
    "ResultsGui/*EndingText": "Ils n'ont pas commencé. Ils ont répondu.\nUne vidéo. Assez pour que le monde en "
                              "parle, pas assez pour qu'il y croie.",  # 19.5 (C25), deux fins cumulées
    "ResultsGui/*Survivors/Template*/Name": "Joueur_123456",
    "ResultsGui/*Survivors/Template*/Status": "Disparu",
    "ResultsGui/*Evidence/Template*": "B · Enregistrement d'un cri · Joueur_123456",
    "ResultsGui/*XPGained": "+ 950 XP",
    "LoadingGui/*Tip": "Seul, tu es discret. Seul, tu es une proie.",  # LoreConfig.LoadingTips
    "CinematicGui/Subtitle": "On leur avait pris quelqu'un, à eux aussi.",  # 6.2 (CS_13)
    "CinematicGui/Skip/Votes": "3/10",
    "SettingsGui/*Value": "100",
}


# --- lecture des fichiers d'instances -----------------------------------------------------------

class Node:
    def __init__(self, data, name, parent=None):
        self.name = name
        self.cls = data["className"]
        self.props = dict(data.get("properties", {}))
        self.parent = parent
        self.path = f"{parent.path}/{name}" if parent else name
        self.children = [Node(c, c["name"], self) for c in data.get("children", [])]
        self.rect = None  # (x, y, w, h) en px, après mise en page
        self.clip = None  # rectangle visible (rognage des ScrollingFrame)
        self.shown = False
        self.text_size = None

    def prop(self, key, default=None):
        value = self.props.get(key, default)
        if isinstance(value, dict) and len(value) == 1:
            return next(iter(value.values()))
        return value

    def child(self, cls):
        return [c for c in self.children if c.cls == cls]

    def clone(self, parent, name):
        data = to_data(self)
        node = Node(data, name, parent)
        return node


def to_data(node):
    return {"className": node.cls, "properties": dict(node.props),
            "children": [dict(to_data(c), name=c.name) for c in node.children]}


def load_guis():
    guis = {}
    for place in ("Lobby", "Partie", "Common"):
        folder = os.path.join(UI, place)
        if not os.path.isdir(folder):
            continue
        for fn in sorted(os.listdir(folder)):
            if fn.endswith(".model.json"):
                with open(os.path.join(folder, fn), encoding="utf-8") as f:
                    name = fn[: -len(".model.json")]
                    guis[(place, name)] = (place, json.load(f))
    return guis


# --- mise en page --------------------------------------------------------------------------------

def udim2(node, key, default=((0, 0), (0, 0))):
    value = node.prop(key)
    if value is None:
        return default
    return (value[0][0], value[0][1]), (value[1][0], value[1][1])


def apply_constraints(node, w, h, pw, ph):
    for c in node.children:
        if c.cls == "UIAspectRatioConstraint":
            ar = c.prop("AspectRatio", 1)
            kind = c.prop("AspectType", "FitWithinMaxSize")
            dominant = c.prop("DominantAxis", "Width")
            if kind == "ScaleWithParentSize":
                if dominant == "Width":
                    h = w / ar
                else:
                    w = h * ar
            elif w / max(h, 1e-6) > ar:
                w = h * ar
            else:
                h = w / ar
    for c in node.children:
        if c.cls == "UISizeConstraint":
            mn = c.prop("MinSize", [0, 0])
            mx = c.prop("MaxSize", [float("inf"), float("inf")])
            w = min(max(w, mn[0]), mx[0])
            h = min(max(h, mn[1]), mx[1])
    return w, h


def own_size(node, pw, ph):
    (sx, ox), (sy, oy) = udim2(node, "Size", ((1, 0), (1, 0)) if node.cls == "ScreenGui" else ((0, 0), (0, 0)))
    w, h = sx * pw + ox, sy * ph + oy
    return apply_constraints(node, w, h, pw, ph)


def is_visible(node, ctx):
    if node.path in ctx["force_hide"]:
        return False
    if node.path in ctx["force_show"]:
        return True
    if node.name == "Layout_Desktop":
        return not ctx["touch"]
    if node.name == "Layout_Touch":
        return ctx["touch"]
    parent = node.parent
    if parent is not None and parent.name in ("Layout_Desktop", "Layout_Touch") and parent.parent is not None \
            and parent.parent.cls == "ScreenGui":
        parent = parent.parent
    elif parent is not None and parent.cls != "ScreenGui":
        parent = None
    if parent is not None and parent.menu and node.name != "Veil":
        return True  # enfant direct d'un menu : montré par son contrôleur
    return node.prop("Visible", True) is not False


def layout(node, x, y, w, h, clip, ctx):
    node.rect = (x, y, w, h)
    node.clip = intersect(clip, node.rect) if node.cls == "ScrollingFrame" else clip
    inner_clip = node.clip
    kids = [c for c in node.children if c.cls in GUI_CLASSES and is_visible(c, ctx)]
    for c in node.children:
        if c.cls in GUI_CLASSES:
            c.shown = c in kids and node.shown
    lst = node.child("UIListLayout")
    grid = node.child("UIGridLayout")
    if lst:
        layout_list(node, lst[0], kids, inner_clip, ctx)
    elif grid:
        layout_grid(node, grid[0], kids, inner_clip, ctx)
    else:
        for c in kids:
            place_child(node, c, inner_clip, ctx)
    # les enfants cachés gardent une position (aperçus, chemins), sans être comptés
    for c in node.children:
        if c.cls in GUI_CLASSES and c not in kids:
            place_child(node, c, inner_clip, ctx, hidden=True)


def place_child(parent, c, clip, ctx, hidden=False):
    px, py, pw, ph = parent.rect
    w, h = own_size(c, pw, ph)
    (sx, ox), (sy, oy) = udim2(c, "Position")
    ax, ay = c.prop("AnchorPoint", [0, 0])
    x = px + sx * pw + ox - ax * w
    y = py + sy * ph + oy - ay * h
    if hidden:
        c.shown = False
    layout(c, x, y, w, h, clip, ctx)


def sort_key(c):
    return (c.prop("LayoutOrder", 0) or 0, c.name)


def layout_list(parent, lst, kids, clip, ctx):
    px, py, pw, ph = parent.rect
    vertical = lst.prop("FillDirection", "Vertical") == "Vertical"
    pad = lst.prop("Padding", [0, 0])
    padding = pad[0] * (ph if vertical else pw) + pad[1]
    sizes = [(c, *own_size(c, pw, ph)) for c in sorted(kids, key=sort_key)]
    total = sum(s[2] if vertical else s[1] for s in sizes) + padding * max(0, len(sizes) - 1)
    pos = 0
    main_align = lst.prop("VerticalAlignment" if vertical else "HorizontalAlignment", "Top" if vertical else "Left")
    if vertical and parent.cls != "ScrollingFrame":
        if main_align == "Center":
            pos = (ph - total) / 2
        elif main_align == "Bottom":
            pos = ph - total
    elif not vertical:
        if main_align == "Center":
            pos = (pw - total) / 2
        elif main_align == "Right":
            pos = pw - total
    cross_align = lst.prop("HorizontalAlignment" if vertical else "VerticalAlignment", "Left" if vertical else "Top")
    if not vertical and lst.prop("Wraps", False):
        # UIListLayout.Wraps : lignes successives, chacune alignée selon HorizontalAlignment
        lines, line, width = [], [], 0
        for item in sizes:
            need = item[1] if not line else width + padding + item[1]
            if line and need > pw + 0.5:
                lines.append((line, width))
                line, width = [item], item[1]
            else:
                line.append(item)
                width = need
        if line:
            lines.append((line, width))
        y = py
        for line, width in lines:
            x = px + {"Center": (pw - width) / 2, "Right": pw - width}.get(main_align, 0)
            for c, w, h in line:
                layout(c, x, y, w, h, clip, ctx)
                x += w + padding
            y += max(h for _, _, h in line) + padding
        return
    for c, w, h in sizes:
        if vertical:
            cx = {"Center": (pw - w) / 2, "Right": pw - w}.get(cross_align, 0)
            layout(c, px + cx, py + pos, w, h, clip, ctx)
            pos += h + padding
        else:
            cy = {"Center": (ph - h) / 2, "Bottom": ph - h}.get(cross_align, 0)
            layout(c, px + pos, py + cy, w, h, clip, ctx)
            pos += w + padding


def layout_grid(parent, grid, kids, clip, ctx):
    px, py, pw, ph = parent.rect
    (csx, cox), (csy, coy) = udim2(grid, "CellSize", ((0, 100), (0, 100)))
    (psx, pox), (psy, poy) = udim2(grid, "CellPadding", ((0, 5), (0, 5)))
    cw, ch = csx * pw + cox, csy * ph + coy
    cw, ch = apply_constraints(grid, cw, ch, pw, ph)
    padx, pady = psx * pw + pox, psy * ph + poy
    per_row = max(1, int((pw + padx + 1e-6) // (cw + padx)))
    for i, c in enumerate(sorted(kids, key=sort_key)):
        row, col = divmod(i, per_row)
        layout(c, px + col * (cw + padx), py + row * (ch + pady), cw, ch, clip, ctx)


def intersect(a, b):
    if a is None:
        return b
    x1, y1 = max(a[0], b[0]), max(a[1], b[1])
    x2, y2 = min(a[0] + a[2], b[0] + b[2]), min(a[1] + a[3], b[1] + b[3])
    return (x1, y1, max(0, x2 - x1), max(0, y2 - y1))


# --- textes --------------------------------------------------------------------------------------

_font_cache = {}


def font(name, size):
    key = (name, size)
    if key not in _font_cache:
        file = "SpecialElite.ttf" if name == "SpecialElite" else "RobotoMono.ttf"
        _font_cache[key] = ImageFont.truetype(os.path.join(FONTS, file), size)
    return _font_cache[key]


def wrap(text, fnt, width):
    """Lignes du texte coupé comme TextWrapped (mots, puis caractères si un mot dépasse)."""
    lines = []
    for para in text.split("\n"):
        line = ""
        for word in para.split(" "):
            candidate = word if not line else line + " " + word
            if fnt.getlength(candidate) <= width:
                line = candidate
                continue
            if line:
                lines.append(line)
            line = word
            while fnt.getlength(line) > width and len(line) > 1:
                cut = len(line)
                while cut > 1 and fnt.getlength(line[:cut]) > width:
                    cut -= 1
                lines.append(line[:cut])
                line = line[cut:]
        lines.append(line)
    return lines


def line_height(fnt):
    ascent, descent = fnt.getmetrics()
    return ascent + descent


def root_of(node):
    while node.parent is not None:
        node = node.parent
    return node


def sample_text(node):
    text = node.prop("Text", "") or ""
    if text:
        return text
    place = getattr(root_of(node), "place", None)
    path = plain(node.path)
    for pattern, sample in SAMPLES_BY_PLACE.get(place, {}).items():
        if fnmatch.fnmatch(path, pattern):
            return sample
    for pattern, sample in SAMPLES.items():
        if fnmatch.fnmatch(path, pattern):
            return sample
    return ""


def text_limits(node):
    mn, mx = TEXT_MIN, 100
    for c in node.children:
        if c.cls == "UITextSizeConstraint":
            mn, mx = c.prop("MinTextSize", mn), c.prop("MaxTextSize", mx)
    return mn, mx


def fit_text(node, text):
    """Taille choisie par TextScaled (la plus grande qui tient), ou None si rien ne tient à la taille minimale."""
    x, y, w, h = node.rect
    mn, mx = text_limits(node)
    single = node.cls in ("TextButton", "TextBox") or node.prop("TextWrapped", False) is not True
    family = node.prop("Font", "RobotoMono")
    for size in range(int(mx), int(mn) - 1, -1):
        fnt = font(family, size)
        if single:
            if all(fnt.getlength(line) <= w for line in text.split("\n")) and \
                    line_height(fnt) * len(text.split("\n")) <= h + 0.5:
                return size
        else:
            lines = wrap(text, fnt, w)
            if len(lines) * line_height(fnt) <= h + 0.5:
                return size
    return None


# --- contrôles -----------------------------------------------------------------------------------

def walk(node):
    yield node
    for c in node.children:
        yield from walk(c)


def plain(path):
    """Chemin sans le segment de disposition (15.7) : X/Layout_Touch/a → X/a."""
    return path.replace("/Layout_Desktop/", "/").replace("/Layout_Touch/", "/")


def matches(path, pattern):
    return fnmatch.fnmatch(plain(path), pattern)


def is_overlay(node):
    return any(matches(node.path, p) for p in OVERLAYS)


def is_visual(node):
    """Élément qui se voit à l'écran (fond, texte, image, vue 3D)."""
    if node.cls in TEXT_CLASSES:
        return True  # un libellé vide recevra un texte du script
    if node.cls in ("ImageLabel", "ImageButton", "ViewportFrame"):
        return True
    return node.prop("BackgroundTransparency", 0) < 1


def exempt(a, b):
    for p, q in EXEMPT:
        if (matches(a.path, p) and matches(b.path, q)) or (matches(a.path, q) and matches(b.path, p)):
            return True
    return False


def related(a, b):
    return a.path.startswith(b.path + "/") or b.path.startswith(a.path + "/")


def area(r):
    return r[2] * r[3]


def find_gui(guis, ctx, name):
    """Écran de la place du contexte, sinon des deux places (Common)."""
    for place in (ctx["place"], "Common"):
        if (place, name) in guis:
            return guis[(place, name)]
    return None


def check_context(ctx, guis, size_name, previews):
    size = SIZES[size_name]
    left, top, right, bottom = size["insets"]
    screen = (left, top, size["w"] - left - right, size["h"] - top - bottom)
    ctx_run = {"touch": size["touch"], "force_show": set(), "force_hide": set()}
    roots = []
    for gui_name in ctx["guis"]:
        if gui_name in TOUCH_ONLY and not size["touch"]:
            continue
        place, data = find_gui(guis, ctx, gui_name)
        root = Node(data, gui_name)
        root.place = place
        tops = []
        for c in data.get("children", []):
            if c["name"] in ("Layout_Desktop", "Layout_Touch"):
                tops += c.get("children", [])
            else:
                tops.append(c)
        root.menu = any(c.get("properties", {}).get("Visible") is False for c in tops) and \
            gui_name not in ("HUDGui", "InventoryGui", "MobileControlsGui", "TabletGui", "DocumentGui", "InteractGui",
                             "NotificationGui")
        for n in walk(root):
            n.menu = getattr(n, "menu", False)
        # chemins forcés : ceux du contexte
        for p in ctx.get("show", []):
            ctx_run["force_show"].add(p)
        for p in ctx.get("hide", []):
            ctx_run["force_hide"].add(p)
        expand_layout_paths(root, ctx_run)
        clone_templates(root, ctx_run)
        root.shown = True
        layout(root, *screen, None, ctx_run)
        roots.append(root)
    reports = []
    visible = []
    for root in roots:
        for n in walk(root):
            if n.cls in GUI_CLASSES and n.shown and ancestors_shown(n):
                visible.append(n)
    # 1. textes
    for n in visible:
        if n.cls in TEXT_CLASSES:
            text = sample_text(n)
            if not text:
                continue
            fitted = fit_text(n, text)
            n.text_size = fitted
            if fitted is None:
                one_line = n.cls in ("TextButton", "TextBox") or n.prop("TextWrapped", False) is not True
                reports.append(f"texte qui déborde à {TEXT_MIN} : {n.path} « {short(text)} » "
                               f"({'une ligne' if one_line else 'plusieurs lignes'}, boîte {int(n.rect[2])} × {int(n.rect[3])} px)")
    # 2. chevauchements
    items = [n for n in visible if is_visual(n) and not is_overlay(n)]
    reported = []  # paires déjà signalées : un chevauchement n'est compté qu'une fois, au plus haut niveau
    for i, a in enumerate(items):
        ra = intersect(a.clip, a.rect) if a.clip else a.rect
        if area(ra) <= 0:
            continue
        for b in items[i + 1:]:
            if related(a, b) or exempt(a, b):
                continue
            rb = intersect(b.clip, b.rect) if b.clip else b.rect
            inter = intersect(ra, rb)
            if inter[2] >= OVERLAP_MIN and inter[3] >= OVERLAP_MIN:
                if any((a is p or a.path.startswith(p.path + "/")) and (b is q or b.path.startswith(q.path + "/"))
                       for p, q in reported):
                    continue
                reported.append((a, b))
                reports.append(f"chevauchement : {a.path} ↔ {b.path} ({int(inter[2])} × {int(inter[3])} px)")
    # 3. règles chiffrées de 15.7
    touch = [n for n in visible if n.path.startswith("MobileControlsGui/") and n.cls in ("TextButton", "ImageButton")
             and (n.parent.cls == "ScreenGui" or n.parent.name in ("Layout_Desktop", "Layout_Touch"))]
    if size["touch"]:
        for n in touch:
            if n.rect[2] < TOUCH_MIN - 0.5 or n.rect[3] < TOUCH_MIN - 0.5:
                reports.append(f"bouton tactile trop petit : {n.path} ({int(n.rect[2])} × {int(n.rect[3])} px)")
        if len(touch) > TOUCH_MAX_VISIBLE:
            reports.append(f"{len(touch)} boutons tactiles visibles (au plus {TOUCH_MAX_VISIBLE})")
    # 15.7 (7) : un verrou couvre tout son bouton avec un fond opaque (le texte dessous ne se lit pas en double)
    for n in visible:
        if n.name == "Lock":
            px, py, pw, ph = n.parent.rect
            x, y, w, h = n.rect
            covers = x <= px + 0.5 and y <= py + 0.5 and x + w >= px + pw - 0.5 and y + h >= py + ph - 0.5
            if n.prop("BackgroundTransparency", 0) > 0 or not covers:
                reports.append(f"verrou transparent ou partiel (texte lu en double) : {n.path}")
    for n in visible:
        lists = n.parent is not None and n.parent.cls == "ScrollingFrame" and n.parent.child("UIListLayout")
        if lists and n.rect[3] < ROW_MIN - 0.5:
            reports.append(f"ligne de liste trop basse : {n.path} ({int(n.rect[3])} px)")
    if previews:
        render(roots, size, screen, ctx["name"], size_name)
    return reports


def ancestors_shown(n):
    p = n.parent
    while p is not None:
        if p.cls in GUI_CLASSES and not p.shown:
            return False
        p = p.parent
    return True


def short(text, n=40):
    text = text.replace("\n", " / ")
    return text if len(text) <= n else text[: n - 1] + "…"


def expand_layout_paths(root, ctx_run):
    """Un chemin forcé « X/a » vaut aussi pour « X/Layout_Desktop/a » et « X/Layout_Touch/a »."""
    extra_show, extra_hide = set(), set()
    for n in walk(root):
        for layout_name in ("Layout_Desktop", "Layout_Touch"):
            marker = f"/{layout_name}/"
            if marker in n.path:
                plain = n.path.replace(marker, "/")
                if plain in ctx_run["force_show"]:
                    extra_show.add(n.path)
                if plain in ctx_run["force_hide"]:
                    extra_hide.add(n.path)
    ctx_run["force_show"] |= extra_show
    ctx_run["force_hide"] |= extra_hide


def clone_templates(root, ctx_run):
    """Un Template montré par le contexte est remplacé par quelques clones visibles (comme Util.cloneTemplate)."""
    for n in list(walk(root)):
        if n.name == "Template" and n.path in ctx_run["force_show"]:
            parent = n.parent
            count = TEMPLATE_CLONES_BY_GUI.get(n.path.split("/")[0], TEMPLATE_CLONES)
            for i in range(1, count + 1):
                clone = n.clone(parent, f"TemplateClone{i}")
                clone.props["Visible"] = True
                clone.props["LayoutOrder"] = i
                for m in walk(clone):
                    m.menu = False
                parent.children.append(clone)
            ctx_run["force_hide"].add(n.path)


# --- aperçus PNG ---------------------------------------------------------------------------------

def color(node, key, default=(1, 1, 1)):
    c = node.prop(key, default)
    return tuple(int(round(v * 255)) for v in c)


def render(roots, size, screen, ctx_name, size_name):
    img = Image.new("RGBA", (size["w"], size["h"]), (52, 58, 52, 255))  # décor de fond neutre (forêt)
    draw = ImageDraw.Draw(img, "RGBA")
    # zone sûre
    draw.rectangle([0, 0, size["w"], screen[1]], fill=(20, 20, 20, 255))
    order = sorted(roots, key=lambda r: r.prop("DisplayOrder", 0) or 0)
    for root in order:
        for n in walk(root):
            if n.cls not in GUI_CLASSES or not n.shown or not ancestors_shown(n):
                continue
            draw_node(img, n)
    os.makedirs(PREVIEWS, exist_ok=True)
    img.convert("RGB").save(os.path.join(PREVIEWS, f"{ctx_name}_{size_name}_{size['w']}x{size['h']}.png"))


def draw_node(img, n):
    x, y, w, h = n.rect
    box = [x, y, x + w, y + h]
    layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    bt = n.prop("BackgroundTransparency", 0)
    radius = 4 if any(c.cls == "UICorner" for c in n.children) else 0
    if bt < 1 and w > 0 and h > 0:
        d.rounded_rectangle(box, radius=radius, fill=color(n, "BackgroundColor3", (0.64, 0.64, 0.64)) + (int(255 * (1 - bt)),))
    for c in n.children:
        if c.cls == "UIStroke" and w > 0 and h > 0:
            d.rounded_rectangle(box, radius=radius, outline=color(c, "Color", (0.6, 0.6, 0.55)) + (255,),
                                width=max(1, int(c.prop("Thickness", 1))))
    if n.cls in ("ImageLabel", "ImageButton", "ViewportFrame") and w > 0 and h > 0:
        d.rectangle(box, outline=(160, 150, 120, 160), width=1)
        d.line([x, y, x + w, y + h], fill=(160, 150, 120, 90))
        d.line([x, y + h, x + w, y], fill=(160, 150, 120, 90))
    if n.cls in TEXT_CLASSES:
        text = sample_text(n)
        if text and w > 0 and h > 0:
            size = n.text_size or TEXT_MIN
            family = n.prop("Font", "RobotoMono")
            fnt = font(family, int(size))
            single = n.cls in ("TextButton", "TextBox") or n.prop("TextWrapped", False) is not True
            lines = text.split("\n") if single else wrap(text, fnt, w)
            lh = line_height(fnt)
            total = lh * len(lines)
            valign = n.prop("TextYAlignment", "Center")
            ty = y + {"Top": 0, "Bottom": h - total}.get(valign, (h - total) / 2)
            halign = n.prop("TextXAlignment", "Center")
            tcolor = color(n, "TextColor3", (0.9, 0.9, 0.85)) + (255,)
            if n.text_size is None:
                tcolor = (255, 80, 80, 255)  # texte qui déborde : en rouge
            for line in lines:
                lw = fnt.getlength(line)
                tx = x + {"Left": 0, "Right": w - lw}.get(halign, (w - lw) / 2)
                d.text((tx, ty), line, font=fnt, fill=tcolor)
                ty += lh
    if n.clip:
        cx, cy, cw, ch = n.clip
        mask = Image.new("L", img.size, 0)
        ImageDraw.Draw(mask).rectangle([cx, cy, cx + cw, cy + ch], fill=255)
        layer.putalpha(Image.composite(layer.getchannel("A"), Image.new("L", img.size, 0), mask))
    img.alpha_composite(layer)


# --- 1. chemins de la section 15 dans les builds ---------------------------------------------------

def build_paths(fn):
    root = ET.parse(fn).getroot()
    out = set()

    def visit(it, p):
        n = it.find("Properties/string[@name='Name']").text
        q = p + "/" + n if p else n
        out.add(q)
        for c in it.findall("Item"):
            visit(c, q)

    for it in root.findall("Item"):
        visit(it, "")
    return out


def expected_paths():
    roles = ["Leader", "Medic", "Tracker", "Cameraman", "Mechanic", "Descendant", "Geologist", "Athlete",
             "RadioOperator", "Pyrotechnician"]
    lobby = ["DialogueGui/Dialogue/SpeakerName", "DialogueGui/Dialogue/Line"]
    lobby += [f"DialogueGui/Dialogue/Choices/Choice_{i}" for i in (1, 2, 3)]
    lobby += [f"MuseumPanelGui/Panel/{x}" for x in "Title Body Source Illustration Close".split()]
    lobby += ["PartyGui/PartyFrame/Header/Title", "PartyGui/PartyFrame/Header/Code", "PartyGui/PartyFrame/CodeInput"]
    lobby += [f"PartyGui/PartyFrame/MemberList/Template/{x}" for x in "PlayerName RoleName ReadyIcon".split()]
    lobby += [f"PartyGui/PartyFrame/Buttons/{x}" for x in "CreatePublic CreatePrivate JoinCode QuickJoin Ready Leave".split()]
    for r in roles:
        lobby += [f"RoleSelectGui/Grid/RoleCard_{r}/{x}"
                  for x in "Portrait CharacterName RoleTitle Ability Weakness TakenOverlay/TakenBy".split()]
    lobby += ["RoleSelectGui/Confirm"]
    for s in "Slot_Rifle Slot_Revolver Slot_Shotgun".split():
        lobby += [f"WeaponBoardGui/Board/{s}/{x}" for x in "Icon Holder Take".split()]
    lobby += [f"WeaponBoardGui/VotePopup/{x}" for x in "Question Option_1 Option_2 Timer".split()]
    lobby += ["VoteGui/Difficulty", "VoteGui/Weather", "VoteGui/Countdown"]
    lobby += ["SkinShopGui/CharacterList/Template", "SkinShopGui/Preview", "SkinShopGui/Equip"]
    lobby += [f"SkinShopGui/SkinGrid/{s}/{x}" for s in ("Skin_A", "Skin_B", "Skin_C") for x in ("Lock", "Requirement")]
    lobby += [f"RecordsGui/Board/Template/{x}" for x in "Rank Group Value".split()]
    lobby += [f"RecordsGui/Tabs/{x}" for x in "Survivors EvidenceA Endings".split()]
    lobby += [f"EvidenceBoardGui/Cork/Template/{x}" for x in "Photo Label Class".split()]
    lobby += [f"EvidenceBoardGui/NotebookPages/Page_{i}/Lock" for i in (1, 2, 3)]
    lobby += [f"ResultsGui/Card/{x}" for x in
              "EndingTitle EndingText Survivors/Template/Name Survivors/Template/Status Evidence/Template XPGained Continue".split()]
    lobby += [f"LoadingGui/{x}" for x in "Background Tip Spinner".split()]
    lobby += [f"VoteGui/Difficulty/{x}" for x in "Normal Hard Nightmare Nightmare/Lock".split()]
    lobby += [f"VoteGui/Weather/{x}" for x in "Random Clear Fog Rain Snow".split()]
    partie = [f"HUDGui/BodyStatus/{b}/{s}" for b in "Head Torso ArmL ArmR LegL LegR".split() for s in "Ok Hurt Critical".split()]
    partie += [f"HUDGui/{x}" for x in
               "BleedIcon Stamina/Fill Battery/Fill Ammo/Count Ammo/Reserve HeldItem Crosshair FearVignette Ping/Template".split()]
    partie += [f"InventoryGui/QuickSlots/Slot_{i}/{x}" for i in range(1, 5) for x in "Icon Count Key Selected".split()]
    partie += ["InventoryGui/Bag/Weight"] + [f"InventoryGui/Bag/List/Template/{x}" for x in "Icon Name Count Drop".split()]
    partie += [f"ObjectiveGui/{x}" for x in "ActName ObjectiveText Clock".split()]
    partie += [f"InteractGui/Prompt/{x}" for x in "KeyHint ActionText Progress/Fill".split()]
    t = "TabletGui/Device/Screen/"
    partie += [t + "AppBar/" + x for x in "Btn_Map Btn_Objectives Btn_Journal Btn_Evidence Btn_Network".split()]
    partie += [t + "Pages/Page_Map/" + x for x in "MapImage PlayerDot NoSignal Markers/Template TunnelLayer".split()]
    partie += [t + "Pages/Page_Objectives/List/Template", t + "Pages/Page_Journal/List/Template",
               t + "Pages/Page_Journal/Reader/Title", t + "Pages/Page_Journal/Reader/Body",
               t + "Pages/Page_Evidence/List/Template"]
    partie += [t + "Pages/Page_Network/" + x for x in "Bars Message Send".split()]
    partie += ["TabletGui/Device/BatteryText", "TabletGui/Device/Close"]
    partie += [f"DocumentGui/Paper/{x}" for x in "Title Body Picture Close".split()]
    partie += [f"DocumentGui/Tape/{x}" for x in "Label Play Progress/Fill".split()]
    partie += [f"DownedGui/{x}" for x in "Countdown HelpHint Bleed/Fill".split()]
    partie += [f"SpectatorGui/{x}" for x in "Watching Prev Next Note".split()]
    partie += [f"RadioGui/{x}" for x in "Channel Talking Static".split()]
    partie += [f"MobileControlsGui/{x}" for x in
               "Sprint Crouch Prone Interact Aim Fire Reload Light Tablet Ping LeanL LeanR".split()]
    common = [f"CinematicGui/{x}" for x in "BarTop BarBottom Subtitle Skip/Votes".split()]
    common += [f"SettingsGui/Window/Tabs/{x}" for x in "Audio Controls Graphics Accessibility".split()]
    common += ["SettingsGui/Window/Pages", "SettingsGui/Window/Apply", "SettingsGui/Window/Reset",
               "SettingsGui/Window/Close", "NotificationGui/Stack/Template/Text"]
    return {"builds/Lobby.rbxlx": lobby + common, "builds/Partie.rbxlx": partie + common}


def check_paths():
    missing_total = 0
    for fn, expected in expected_paths().items():
        full = os.path.join(ROOT, fn)
        if not os.path.exists(full):
            print(f"{fn} : absent (rojo build d'abord)")
            missing_total += 1
            continue
        present = build_paths(full)
        missing = []
        for e in expected:
            gui, _, rest = e.partition("/")
            direct = "StarterGui/" + e
            # toutes les dispositions présentes de l'écran doivent avoir l'élément
            layouts = [lay for lay in ("Layout_Desktop", "Layout_Touch") if f"StarterGui/{gui}/{lay}" in present]
            split = [f"StarterGui/{gui}/{lay}/{rest}" for lay in layouts]
            if direct not in present and not (split and all(p in present for p in split)):
                missing.append(e)
        print(f"{fn} : {len(expected)} chemins attendus, {len(missing)} manquants {missing if missing else ''}")
        missing_total += len(missing)
    return missing_total


def main():
    previews = "--previews" in sys.argv
    missing = check_paths()
    guis = load_guis()
    total = 0
    for ctx in CONTEXTS:
        absent = [g for g in ctx["guis"] if find_gui(guis, ctx, g) is None]
        if absent:
            print(f"{ctx['name']} : écran absent ({', '.join(absent)})")
            total += 1
            continue
        for size_name in SIZES:
            reports = check_context(ctx, guis, size_name, previews)
            for r in sorted(set(reports)):
                print(f"[{ctx['name']} {SIZES[size_name]['w']}×{SIZES[size_name]['h']}] {r}")
            total += len(set(reports))
    print(f"\n{total} signalement(s) de mise en page ; {missing} chemin(s) manquant(s)")
    if previews:
        print(f"aperçus : {os.path.relpath(PREVIEWS, ROOT)}/")
    return 1 if total or missing else 0


if __name__ == "__main__":
    sys.exit(main())
