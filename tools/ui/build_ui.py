#!/usr/bin/env python3
"""Génère les interfaces de la section 15 de la bible en fichiers d'instances Rojo (.model.json),
ainsi que UI_MAP.md.

Usage (depuis la racine du dépôt) : python3 tools/ui/build_ui.py

Les fichiers produits (src/ui/**) sont des réglages de départ : après la première ouverture
d'une place dans Studio, c'est Studio qui fait foi pour l'UI (bible 18.1 ter) et ce script
ne doit plus être relancé sur ces places.

Règles suivies :
- noms exacts de la section 15 ; style de la section 15.2 ;
- tout en Scale, UIAspectRatioConstraint sur les panneaux, UITextSizeConstraint de 14 à 28,
  ScreenInsets = CoreUISafeInsets ;
- un texte n'est écrit que s'il vient de la bible ; sinon il reste vide et figure dans
  la liste des textes manquants (UI_MAP.md, SUIVI.md).
"""

import json
import os
import shutil

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
OUT = os.path.join(ROOT, "src", "ui")


# --- 15.2 : style ---------------------------------------------------------------------------

def hex_color(value):
    value = value.lstrip("#")
    return [round(int(value[i:i + 2], 16) / 255, 4) for i in (0, 2, 4)]


TEXT = hex_color("#E8E4D8")  # texte principal (blanc os)
TEXT2 = hex_color("#9A968C")  # texte secondaire
PANEL = hex_color("#0E0F0D")  # fond des panneaux
PANEL_T = 0.35  # transparence du fond des panneaux
DANGER = hex_color("#A3342B")  # sang séché
POSITIVE = hex_color("#6E8B5E")  # mousse
TABLET_BG = hex_color("#1B2A22")  # écran de la tablette
TABLET_TEXT = hex_color("#9FE0A8")
BLACK = [0, 0, 0]  # bandes noires des cinématiques (6.1)

TITLE_FONT = "SpecialElite"  # police des titres
BODY_FONT = "RobotoMono"  # police du texte et du HUD
TEXT_MIN, TEXT_MAX = 14, 28  # UITextSizeConstraint
SCREEN_ASPECT = 16 / 9  # écran de référence pour les UIAspectRatioConstraint (DÉFAUT)


# --- éléments --------------------------------------------------------------------------------

class El:
    """Une instance. `read` = lue par un script (sinon décorative) ; `missing` = texte absent de la bible."""

    def __init__(self, name, cls, props=None, children=None, read=True, missing=None, note=None):
        self.name = name
        self.cls = cls
        self.props = props or {}
        self.children = list(children or [])
        self.read = read
        self.missing = missing  # proposition de texte, si le texte manque dans la bible
        self.note = note

    def add(self, *children):
        self.children.extend(children)
        return self


def udim2(xs, xo, ys, yo):
    return {"UDim2": [[xs, xo], [ys, yo]]}


def rect(x, y, w, h):
    return {"Position": udim2(x, 0, y, 0), "Size": udim2(w, 0, h, 0)}


def layout_child(cls, **props):
    # objets de disposition et contraintes : absents de UI_MAP.md (ni lus, ni décoratifs)
    el = El(cls, cls, props, read=None)
    return el


def text_constraint():
    return layout_child("UITextSizeConstraint", MinTextSize=TEXT_MIN, MaxTextSize=TEXT_MAX)


def aspect(w, h):
    return layout_child("UIAspectRatioConstraint", AspectRatio=round(w / h * SCREEN_ASPECT, 3))


def corner(scale=0.0, offset=4):
    return layout_child("UICorner", CornerRadius={"UDim": [scale, offset]})


def stroke(color=TEXT2, thickness=1):
    return layout_child("UIStroke", Color=color, Thickness=thickness, ApplyStrokeMode="Border")


def list_layout(vertical=True, padding=0.02, align="Center"):
    props = {
        "SortOrder": "LayoutOrder",
        "FillDirection": "Vertical" if vertical else "Horizontal",
        "Padding": {"UDim": [padding, 0]},
    }
    if vertical:
        props["HorizontalAlignment"] = align
    else:
        props["VerticalAlignment"] = "Center"
    return layout_child("UIListLayout", **props)


def grid_layout(cell_w, cell_h, pad_w=0.01, pad_h=0.02):
    return layout_child(
        "UIGridLayout",
        SortOrder="LayoutOrder",
        CellSize=udim2(cell_w, 0, cell_h, 0),
        CellPadding=udim2(pad_w, 0, pad_h, 0),
    )


def frame(name, r=None, visible=True, bg=None, bg_t=1.0, children=(), read=True, panel=False, order=None, note=None):
    props = {"BackgroundTransparency": bg_t, "BorderSizePixel": 0}
    if bg is not None:
        props["BackgroundColor3"] = bg
    if panel:
        props["BackgroundColor3"] = PANEL
        props["BackgroundTransparency"] = PANEL_T
    if r is not None:
        props.update(rect(*r))
    if not visible:
        props["Visible"] = False
    if order is not None:
        props["LayoutOrder"] = order
    el = El(name, "Frame", props, children, read=read, note=note)
    if panel and r is not None:
        el.add(aspect(r[2], r[3]), corner())
    return el


def panel(name, r, visible=False, children=(), read=True, note=None):
    return frame(name, r, visible=visible, panel=True, children=children, read=read, note=note)


def fill(name="Fill", color=TEXT):
    # jauge : seul Size.X.Scale change (15.1)
    return frame(name, (0, 0, 1, 1), bg=color, bg_t=0)


def bar(name, r, color=TEXT, visible=True, read=True):
    return frame(name, r, visible=visible, bg=PANEL, bg_t=PANEL_T, children=[fill(color=color)], read=read)


def _text_props(text, font, color, align, r, visible, order, size_hint=None):
    props = {
        "Text": text,
        "Font": font,
        "TextColor3": color,
        "TextScaled": True,
        "TextWrapped": True,
        "TextXAlignment": align,
        "BackgroundTransparency": 1,
        "BorderSizePixel": 0,
    }
    if r is not None:
        props.update(rect(*r))
    if not visible:
        props["Visible"] = False
    if order is not None:
        props["LayoutOrder"] = order
    return props


def label(name, r=None, text="", font=BODY_FONT, color=TEXT, align="Left", visible=True, read=True,
          missing=None, order=None, note=None, valign=None, defaut=False):
    props = _text_props(text, font, color, align, r, visible, order)
    if valign:
        props["TextYAlignment"] = valign
    el = El(name, "TextLabel", props, [text_constraint()], read=read, missing=missing, note=note)
    el.defaut = text if defaut else None
    return el


def title(name, r=None, text="", **kw):
    kw.setdefault("font", TITLE_FONT)
    return label(name, r, text, **kw)


def button(name, r=None, text="", font=BODY_FONT, color=TEXT, visible=True, read=True, missing=None,
           order=None, note=None, children=(), defaut=False):
    props = _text_props(text, font, color, "Center", r, visible, order)
    props["BackgroundColor3"] = PANEL
    props["BackgroundTransparency"] = PANEL_T
    props["AutoButtonColor"] = True
    el = El(name, "TextButton", props, [text_constraint(), corner(), stroke()], read=read, missing=missing,
            note=note)
    el.add(*children)
    el.defaut = text if defaut else None
    return el


def card_button(name, r=None, order=None, children=(), visible=True, note=None):
    # bouton sans texte qui porte des enfants (carte de rôle, tenue) : cliquable en entier
    props = {"Text": "", "AutoButtonColor": True, "BackgroundColor3": PANEL, "BackgroundTransparency": PANEL_T,
             "BorderSizePixel": 0}
    if r is not None:
        props.update(rect(*r))
    if order is not None:
        props["LayoutOrder"] = order
    if not visible:
        props["Visible"] = False
    el = El(name, "TextButton", props, [corner(), stroke()], note=note)
    el.add(*children)
    return el


def textbox(name, r, missing=None, placeholder=""):
    props = _text_props("", BODY_FONT, TEXT, "Center", r, True, None)
    props.update({"PlaceholderText": placeholder, "PlaceholderColor3": TEXT2, "ClearTextOnFocus": False,
                  "BackgroundColor3": PANEL, "BackgroundTransparency": PANEL_T})
    return El(name, "TextBox", props, [text_constraint(), corner(), stroke()], missing=missing)


def lock_label(bg, bg_t, visible=True):
    # 15.6 : Lock = « Verrouillé »
    el = label("Lock", (0, 0, 1, 1), text="Verrouillé", align="Center", visible=visible)
    el.props.update({"BackgroundColor3": bg, "BackgroundTransparency": bg_t})
    el.add(corner())
    return el


def viewport(name, r, note=None):
    props = dict(rect(*r), BackgroundTransparency=1, BorderSizePixel=0)
    return El(name, "ViewportFrame", props, note=note)


def image(name, r=None, visible=True, read=True, note=None, transparency=0.0, order=None):
    props = {"Image": "", "ScaleType": "Fit", "BackgroundTransparency": 1, "BorderSizePixel": 0,
             "ImageTransparency": transparency}
    if r is not None:
        props.update(rect(*r))
    if not visible:
        props["Visible"] = False
    if order is not None:
        props["LayoutOrder"] = order
    return El(name, "ImageLabel", props, read=read, note=note)


def scrolling(name, r, children=(), read=True):
    props = {"BackgroundTransparency": 1, "BorderSizePixel": 0, "ScrollBarThickness": 4,
             "ScrollBarImageColor3": TEXT2, "AutomaticCanvasSize": "Y", "CanvasSize": udim2(0, 0, 0, 0),
             "ScrollingDirection": "Y"}
    props.update(rect(*r))
    return El(name, "ScrollingFrame", props, children, read=read)


def template(el):
    # modèle cloné par le script (15.1) : invisible tant qu'il n'est pas cloné
    el.props["Visible"] = False
    el.name = "Template"
    return el


def screen_gui(name, controller, children, display_order=0):
    props = {"ResetOnSpawn": False, "ZIndexBehavior": "Sibling", "ScreenInsets": "CoreUISafeInsets",
             "DisplayOrder": display_order}
    el = El(name, "ScreenGui", props, children)
    el.controller = controller
    return el


# --- 15.3 Lobby ------------------------------------------------------------------------------

# 2.5 et 7.7 : rôles, noms, capacités, faiblesses (textes de la bible)
ROLES = [
    ("Leader", "Caleb Marsh", "Meneur",
     "Voit ses coéquipiers en contour à travers le décor ; donne un ordre qui réduit la peur", "Aucune"),
    ("Medic", "Priya Natarajan", "Médecin", "Soigne vite, arrête les hémorragies graves", "Course à 18"),
    ("Tracker", "Wyatt Dunn", "Pisteur",
     "Voit les empreintes fraîches en surbrillance ; devine la direction de la créature",
     "Ses tirs comptent double pour la rancune"),
    ("Cameraman", "Theo Lindqvist", "Caméraman", "Seul à produire des preuves de classe A", "Batterie de 6 min"),
    ("Mechanic", "Rosa Delgado", "Mécanicienne", "Répare deux fois plus vite",
     "Inventaire : 3 emplacements rapides au lieu de 4"),
    ("Descendant", "Nora Halvorsen", "Descendante", "Lit le carnet familial, voit les indices cachés", "Peur ×1,25"),
    ("Geologist", "Malik Okafor", "Géologue", "Lit la carte des tunnels, se repère sous terre", "Endurance 80"),
    ("Athlete", "Jake Kowalski", "Sportif", "Porte un blessé en courant, barricade vite",
     "Respiration : bruit de course 75"),
    ("RadioOperator", "Mei Tanaka", "Opératrice radio", "Écoute les fréquences, repère les voix imitées",
     "Aucune arme à feu possible"),
    ("Pyrotechnician", "Dylan Croft", "Pyrotechnicien", "Fabrique une fusée ou un piège à bruit", "Torse 80 PV"),
]
# 4.4 : Meneur et Caméraman sont proposés en premier
ROLE_ORDER = ["Leader", "Cameraman", "Medic", "Tracker", "Mechanic", "Descendant", "Geologist", "Athlete",
              "RadioOperator", "Pyrotechnician"]


def dialogue_gui():
    choices = frame("Choices", (0.03, 0.6, 0.94, 0.36), children=[list_layout(padding=0.04)])
    for i in range(1, 4):
        choices.add(button(f"Choice_{i}", (0, 0, 1, 0.29), order=i))
    dialogue = panel("Dialogue", (0.2, 0.64, 0.6, 0.33), children=[
        title("SpeakerName", (0.03, 0.04, 0.6, 0.16)),
        label("Line", (0.03, 0.22, 0.94, 0.36), valign="Top"),
        choices,
    ])
    return screen_gui("DialogueGui", "DialogueController", [dialogue])


def museum_panel_gui():
    p = panel("Panel", (0.12, 0.08, 0.76, 0.84), children=[
        title("Title", (0.03, 0.03, 0.8, 0.09)),
        image("Illustration", (0.03, 0.15, 0.42, 0.62)),
        label("Body", (0.48, 0.15, 0.49, 0.62), valign="Top"),
        label("Source", (0.03, 0.82, 0.94, 0.08), color=TEXT2),
        button("Close", (0.89, 0.03, 0.08, 0.08), text="Fermer"),
    ])
    return screen_gui("MuseumPanelGui", "MuseumController", [p])


def party_gui():
    member = template(frame("Template", (0, 0, 1, 0.1), children=[
        label("PlayerName", (0.03, 0, 0.5, 1)),
        label("RoleName", (0.55, 0, 0.3, 1), color=TEXT2),
        frame("ReadyIcon", (0.9, 0.25, 0.06, 0.5), bg=POSITIVE, bg_t=0, children=[corner(0.5, 0)]),
    ]))
    buttons = frame("Buttons", (0.05, 0.62, 0.9, 0.24), children=[grid_layout(0.49, 0.3, 0.02, 0.05)])
    buttons.add(
        button("CreatePublic", order=1, text="Groupe public"),
        button("CreatePrivate", order=2, text="Groupe privé"),
        button("JoinCode", order=3, text="Rejoindre avec un code"),
        button("QuickJoin", order=4, text="Partie rapide"),
        button("Ready", order=5, text="Prêt"),  # 4.4 : tous « Prêt »
        button("Leave", order=6, text="Quitter le groupe"),
    )
    frame_ = panel("PartyFrame", (0.62, 0.1, 0.35, 0.8), children=[
        frame("Header", (0.05, 0.02, 0.9, 0.1), children=[
            title("Title", (0, 0, 0.65, 1), text="Groupe", defaut=True),
            title("Code", (0.65, 0, 0.35, 1), align="Right"),
        ]),
        scrolling("MemberList", (0.05, 0.14, 0.9, 0.46), children=[list_layout(padding=0.01), member]),
        buttons,
        textbox("CodeInput", (0.05, 0.88, 0.9, 0.09), placeholder="Code à 4 chiffres"),
    ])
    return screen_gui("PartyGui", "PartyController", [frame_])


def _hide_roots(gui):
    # les enfants directs d'un ScreenGui de menu sont cachés au départ (le contrôleur les montre)
    for child in gui.children:
        if child.read is not None:
            child.props["Visible"] = False
    return gui


WEAPONS = [("Slot_Rifle", "Fusil à verrou"), ("Slot_Revolver", "Revolver"), ("Slot_Shotgun", "Fusil à pompe")]


def weapon_board_gui():
    board = panel("Board", (0.2, 0.12, 0.6, 0.62), children=[list_layout(vertical=False, padding=0.02)])
    for i, (slot, weapon_name) in enumerate(WEAPONS, start=1):
        board.add(frame(slot, (0, 0, 0.31, 0.92), order=i, panel=False, bg=PANEL, bg_t=PANEL_T, children=[
            corner(), stroke(),
            image("Icon", (0.1, 0.05, 0.8, 0.45), note="icône d'arme : asset à créer"),
            title("WeaponName", (0.05, 0.52, 0.9, 0.12), text=weapon_name, align="Center", read=False),  # 8.2
            label("Holder", (0.05, 0.66, 0.9, 0.1), color=TEXT2, align="Center"),
            button("Take", (0.15, 0.8, 0.7, 0.14), text="Prendre"),
        ]))
    popup = panel("VotePopup", (0.32, 0.3, 0.36, 0.34), children=[
        label("Question", (0.05, 0.05, 0.9, 0.35), align="Center"),
        button("Option_1", (0.05, 0.45, 0.42, 0.25)),
        button("Option_2", (0.53, 0.45, 0.42, 0.25)),
        label("Timer", (0.05, 0.76, 0.9, 0.18), align="Center", color=TEXT2),
    ])
    return _hide_roots(screen_gui("WeaponBoardGui", "WeaponBoardController", [board, popup]))


def vote_gui():
    # 15.3 : Difficulty > Normal, Hard, Nightmare (> Lock) ; Weather > Random, Clear, Fog, Rain, Snow
    difficulty = panel("Difficulty", (0.05, 0.15, 0.42, 0.55), children=[
        title("Title", (0.05, 0.03, 0.9, 0.14), text="Difficulté", read=False),  # 4.4 : votes : difficulté
        button("Normal", (0.05, 0.22, 0.9, 0.2), order=1, text="Normal"),  # 4.4, 5.4
        button("Hard", (0.05, 0.47, 0.9, 0.2), order=2, text="Difficile"),
        button("Nightmare", (0.05, 0.72, 0.9, 0.2), order=3, text="Cauchemar", children=[
            lock_label(DANGER, 0.5),
        ]),
    ])
    weather_options = [("Random", "Aléatoire"), ("Clear", "Nuit claire"), ("Fog", "Brouillard"),
                       ("Rain", "Pluie"), ("Snow", "Première neige")]  # 4.4 : aléatoire ou fixe ; 12.3
    weather = panel("Weather", (0.53, 0.15, 0.42, 0.55), children=[
        title("Title", (0.05, 0.03, 0.9, 0.14), text="Météo", read=False),  # 4.4 : et météo
    ])
    for i, (name, text) in enumerate(weather_options):
        weather.add(button(name, (0.05, 0.21 + i * 0.155, 0.9, 0.13), order=i + 1, text=text))
    gui = screen_gui("VoteGui", "VoteController", [
        difficulty, weather,
        title("Countdown", (0.3, 0.75, 0.4, 0.1), align="Center"),
    ])
    return _hide_roots(gui)


def skin_shop_gui():
    skins = [("Skin_A", "Tenue de départ", ""), ("Skin_B", "Tenue de pluie", "5 parties jouées"),
             ("Skin_C", "Tenue « Cold Trail »", "1 survie")]  # 7.1
    grid = frame("SkinGrid", (0.27, 0.1, 0.4, 0.8), panel=True, children=[grid_layout(1, 0.31, 0, 0.03)])
    for i, (name, outfit, requirement) in enumerate(skins, start=1):
        grid.add(button(name, text=outfit, order=i, children=[
            lock_label(PANEL, 0.3, visible=(name != "Skin_A")),
            label("Requirement", (0.05, 0.7, 0.9, 0.25), text=requirement, color=TEXT2, align="Center"),
        ]))
    char_template = template(button("Template", (0, 0, 1, 0.09)))
    gui = screen_gui("SkinShopGui", "SkinShopController", [
        frame("CharacterList", (0.03, 0.1, 0.22, 0.8), panel=True, children=[
            list_layout(padding=0.01), char_template]),
        grid,
        El("Preview", "ViewportFrame", dict(rect(0.69, 0.1, 0.28, 0.66), BackgroundColor3=PANEL,
                                             BackgroundTransparency=PANEL_T, BorderSizePixel=0),
           [aspect(0.28, 0.66), corner()]),
        button("Equip", (0.69, 0.8, 0.28, 0.1), text="Équiper"),
    ])
    return _hide_roots(gui)


def records_gui():
    row = template(frame("Template", (0, 0, 1, 0.1), children=[
        label("Rank", (0.02, 0, 0.1, 1), align="Center"),
        label("Group", (0.14, 0, 0.6, 1)),
        label("Value", (0.76, 0, 0.22, 1), align="Right"),
    ]))
    tabs = frame("Tabs", (0.15, 0.08, 0.7, 0.09), children=[
        list_layout(vertical=False, padding=0.01),
        # 4.5 : records du serveur
        button("Survivors", (0, 0, 0.32, 1), order=1, text="Survivants"),
        button("EvidenceA", (0, 0, 0.32, 1), order=2, text="Preuves A"),
        button("Endings", (0, 0, 0.32, 1), order=3, text="Fins"),
    ])
    board = scrolling("Board", (0.15, 0.2, 0.7, 0.72), children=[list_layout(padding=0.01), row])
    board.props.update({"BackgroundColor3": PANEL, "BackgroundTransparency": PANEL_T})
    return _hide_roots(screen_gui("RecordsGui", "RecordsController", [tabs, board]))


def evidence_board_gui():
    item = template(frame("Template", children=[
        image("Photo", (0.05, 0.05, 0.9, 0.6)),
        label("Label", (0.05, 0.67, 0.9, 0.18), align="Center"),
        label("Class", (0.05, 0.86, 0.9, 0.12), color=TEXT2, align="Center"),
    ]))
    pages_text = [  # 2.7 : DOC_12, carnet de la famille Halvorsen
        "Il n'a jamais voulu en parler. Il disait seulement : ne tire pas le premier.",
        "Ils frappaient les arbres avant les pierres.",
        "On leur avait pris quelqu'un, à eux aussi.",
    ]
    pages = frame("NotebookPages", (0.67, 0.08, 0.3, 0.84), panel=True, children=[list_layout(padding=0.02)])
    for i, text in enumerate(pages_text, start=1):
        page = title(f"Page_{i}", (0, 0, 0.95, 0.31), text=text, order=i, valign="Top")
        page.add(lock_label(PANEL, 0.1, visible=(i != 1)))
        pages.add(page)
    cork = frame("Cork", (0.03, 0.08, 0.62, 0.84), panel=True, children=[grid_layout(0.23, 0.3, 0.02, 0.03), item])
    return _hide_roots(screen_gui("EvidenceBoardGui", "EvidenceBoardController", [cork, pages]))


def results_gui():
    survivor = template(frame("Template", (0, 0, 1, 0.2), children=[
        label("Name", (0, 0, 0.6, 1)),
        label("Status", (0.6, 0, 0.4, 1), align="Right", color=TEXT2),
    ]))
    evidence = template(label("Template", (0, 0, 1, 0.2)))
    card = panel("Card", (0.25, 0.06, 0.5, 0.88), children=[
        title("EndingTitle", (0.05, 0.03, 0.9, 0.1), align="Center"),
        label("EndingText", (0.05, 0.14, 0.9, 0.18), align="Center", valign="Top"),
        scrolling("Survivors", (0.05, 0.34, 0.43, 0.42), children=[list_layout(padding=0.01), survivor]),
        scrolling("Evidence", (0.52, 0.34, 0.43, 0.42), children=[list_layout(padding=0.01), evidence]),
        title("XPGained", (0.05, 0.78, 0.9, 0.07), align="Center", color=POSITIVE),
        button("Continue", (0.3, 0.88, 0.4, 0.08), text="Continuer"),
    ])
    return screen_gui("ResultsGui", "ResultsController", [card])


def loading_gui():
    return _hide_roots(screen_gui("LoadingGui", "TeleportController", [
        frame("Background", (0, 0, 1, 1), bg=PANEL, bg_t=0),
        label("Tip", (0.15, 0.82, 0.7, 0.08), align="Center", color=TEXT2),
        frame("Spinner", (0.485, 0.45, 0.03, 0.053), bg=TEXT, bg_t=0, read=False,
              children=[corner(0.5, 0), aspect(0.03, 0.053)], note="décor ; à remplacer par une image"),
    ], display_order=100))


# --- 15.4 Partie -----------------------------------------------------------------------------

def body_part(name, r):
    # chacun > Ok, Hurt, Critical, une seule visible (15.4)
    return frame(name, r, children=[
        frame("Ok", (0, 0, 1, 1), bg=POSITIVE, bg_t=0, children=[corner()]),
        frame("Hurt", (0, 0, 1, 1), bg=DANGER, bg_t=0.5, visible=False, children=[corner()]),
        frame("Critical", (0, 0, 1, 1), bg=DANGER, bg_t=0, visible=False, children=[corner()]),
    ])


def hud_gui():
    body = frame("BodyStatus", (0.02, 0.6, 0.07, 0.3), children=[
        aspect(0.07, 0.3),
        body_part("Head", (0.36, 0, 0.28, 0.17)),
        body_part("Torso", (0.3, 0.19, 0.4, 0.36)),
        body_part("ArmL", (0.06, 0.19, 0.2, 0.36)),
        body_part("ArmR", (0.74, 0.19, 0.2, 0.36)),
        body_part("LegL", (0.3, 0.57, 0.18, 0.43)),
        body_part("LegR", (0.52, 0.57, 0.18, 0.43)),
    ])
    ping = frame("Ping", (0, 0, 1, 1), children=[
        template(frame("Template", (0, 0, 0.012, 0.021), bg=POSITIVE, bg_t=0, children=[corner(0.5, 0)])),
    ])
    return screen_gui("HUDGui", "HUDController", [
        image("FearVignette", (0, 0, 1, 1), transparency=1,
              note="image de vignettage : absente de 13.5 (asset à fournir) ; ImageTransparency réglée par le script"),
        body,
        frame("BleedIcon", (0.1, 0.6, 0.015, 0.027), bg=DANGER, bg_t=0, visible=False,
              children=[corner(0.5, 0), aspect(0.015, 0.027)]),
        bar("Stamina", (0.02, 0.92, 0.16, 0.012)),
        bar("Battery", (0.02, 0.945, 0.16, 0.012), color=TEXT2),
        frame("Ammo", (0.65, 0.87, 0.1, 0.09), children=[
            title("Count", (0, 0, 0.55, 1), align="Right"),
            label("Reserve", (0.6, 0.3, 0.4, 0.6), color=TEXT2),
        ]),
        label("HeldItem", (0.36, 0.81, 0.28, 0.045), align="Center"),
        frame("Crosshair", (0.4975, 0.4955, 0.005, 0.009), bg=TEXT, bg_t=0, visible=False,
              children=[corner(0.5, 0), aspect(0.005, 0.009)]),
        ping,
    ])


def inventory_gui():
    slots = frame("QuickSlots", (0.36, 0.86, 0.28, 0.12), children=[list_layout(vertical=False, padding=0.02)])
    for i in range(1, 5):
        slots.add(frame(f"Slot_{i}", (0, 0, 0.235, 1), order=i, bg=PANEL, bg_t=PANEL_T, children=[
            aspect(0.235 * 0.28, 0.12), corner(),
            image("Icon", (0.1, 0.1, 0.8, 0.8)),
            label("Count", (0.5, 0.65, 0.48, 0.33), align="Right"),
            label("Key", (0.04, 0.02, 0.4, 0.3), color=TEXT2),
            frame("Selected", (0, 0, 1, 1), visible=False, children=[stroke(TEXT, 2), corner()]),
        ]))
    row = template(frame("Template", (0, 0, 1, 0.1), children=[
        image("Icon", (0, 0.05, 0.12, 0.9)),
        label("Name", (0.14, 0, 0.5, 1)),
        label("Count", (0.65, 0, 0.12, 1), align="Center"),
        button("Drop", (0.79, 0.1, 0.2, 0.8), text="Jeter"),
    ]))
    bag = panel("Bag", (0.66, 0.25, 0.31, 0.58), children=[
        label("Weight", (0.05, 0.02, 0.9, 0.08), align="Right", color=TEXT2),
        scrolling("List", (0.04, 0.12, 0.92, 0.85), children=[list_layout(padding=0.01), row]),
    ])
    return screen_gui("InventoryGui", "InventoryController", [slots, bag])


def objective_gui():
    return screen_gui("ObjectiveGui", "ObjectiveController", [
        title("ActName", (0.02, 0.03, 0.4, 0.05)),
        label("ObjectiveText", (0.02, 0.085, 0.4, 0.06), valign="Top"),
        label("Clock", (0.86, 0.03, 0.12, 0.05), align="Right"),
    ])


def interact_gui():
    prompt = panel("Prompt", (0.41, 0.62, 0.18, 0.08), children=[
        label("KeyHint", (0.03, 0.12, 0.2, 0.6), align="Center"),
        label("ActionText", (0.26, 0.12, 0.71, 0.6)),
        bar("Progress", (0.03, 0.8, 0.94, 0.12)),
    ])
    return screen_gui("InteractGui", "InteractController", [prompt])


def tablet_gui():
    def tab(name, text, order):
        return button(name, (0, 0, 0.19, 0.9), text=text, color=TABLET_TEXT, order=order)

    def page(name, children, visible=False):
        return frame(name, (0, 0, 1, 1), visible=visible, children=children)

    def lst(item):
        return scrolling("List", (0.03, 0.03, 0.94, 0.94), children=[list_layout(padding=0.01), item])

    app_bar = frame("AppBar", (0, 0, 1, 0.1), children=[
        list_layout(vertical=False, padding=0.01),
        # 8.3 : applications de la tablette
        tab("Btn_Map", "Carte", 1), tab("Btn_Objectives", "Objectifs", 2), tab("Btn_Journal", "Journal", 3),
        tab("Btn_Evidence", "Preuves", 4), tab("Btn_Network", "Réseau", 5),
    ])
    marker = template(frame("Template", (0, 0, 0.015, 0.027), bg=TABLET_TEXT, bg_t=0, children=[corner(0.5, 0)]))
    page_map = page("Page_Map", [
        image("MapImage", (0, 0, 1, 1), note="Img_TabletMap (13.5) : image à créer"),
        image("TunnelLayer", (0, 0, 1, 1), visible=False, note="couche « tunnels » après DOC_07 : image à créer"),
        frame("Markers", (0, 0, 1, 1), children=[marker]),
        frame("PlayerDot", (0.5, 0.5, 0.015, 0.027), bg=TABLET_TEXT, bg_t=0, children=[corner(0.5, 0)]),
        label("NoSignal", (0.2, 0.45, 0.6, 0.1), text="Pas de signal GPS", color=TABLET_TEXT, align="Center",
              visible=False),  # 8.3
    ], visible=True)
    item = lambda: template(label("Template", (0, 0, 1, 0.1), color=TABLET_TEXT))
    journal_item = template(button("Template", (0, 0, 1, 0.1), color=TABLET_TEXT))
    page_journal = page("Page_Journal", [
        scrolling("List", (0.03, 0.03, 0.35, 0.94), children=[list_layout(padding=0.01), journal_item]),
        frame("Reader", (0.4, 0.03, 0.57, 0.94), children=[
            title("Title", (0, 0, 1, 0.1), color=TABLET_TEXT),
            label("Body", (0, 0.12, 1, 0.88), color=TABLET_TEXT, valign="Top"),
        ]),
    ])
    page_network = page("Page_Network", [
        frame("Bars", (0.4, 0.1, 0.2, 0.1), bg=PANEL, bg_t=PANEL_T, children=[fill(color=TABLET_TEXT)],
              note="barres de réseau : Fill.Size.X.Scale = niveau"),
        label("Message", (0.1, 0.3, 0.8, 0.3), text="Aucun réseau", color=TABLET_TEXT, align="Center"),  # 8.3
        button("Send", (0.35, 0.7, 0.3, 0.12), color=TABLET_TEXT, text="Envoyer"),
    ])
    screen = frame("Screen", (0.04, 0.05, 0.92, 0.84), bg=TABLET_BG, bg_t=0, children=[
        app_bar,
        frame("Pages", (0, 0.1, 1, 0.9), children=[
            page_map,
            page("Page_Objectives", [lst(item())]),
            page_journal,
            page("Page_Evidence", [lst(item())]),
            page_network,
        ]),
    ])
    device = frame("Device", (0.17, 0.07, 0.66, 0.86), bg=PANEL, bg_t=0, visible=False, children=[
        aspect(0.66, 0.86), corner(0.03, 0),
        screen,
        label("BatteryText", (0.75, 0.9, 0.2, 0.06), color=TABLET_TEXT, align="Right"),
        button("Close", (0.04, 0.9, 0.2, 0.07), text="Fermer"),
    ])
    return screen_gui("TabletGui", "TabletController", [device])


def document_gui():
    paper = panel("Paper", (0.25, 0.06, 0.5, 0.88), children=[
        title("Title", (0.05, 0.03, 0.78, 0.08)),
        image("Picture", (0.05, 0.13, 0.9, 0.35)),
        label("Body", (0.05, 0.5, 0.9, 0.46), valign="Top"),
        button("Close", (0.85, 0.03, 0.1, 0.07), text="Fermer"),
    ])
    tape = panel("Tape", (0.3, 0.7, 0.4, 0.2), children=[
        label("Label", (0.05, 0.08, 0.9, 0.35)),
        button("Play", (0.05, 0.5, 0.2, 0.4), text="Lire"),
        bar("Progress", (0.3, 0.65, 0.65, 0.1)),
    ])
    return screen_gui("DocumentGui", "DocumentController", [paper, tape])


def downed_gui():
    return _hide_roots(screen_gui("DownedGui", "DownedController", [
        title("Countdown", (0.4, 0.4, 0.2, 0.1), align="Center", color=DANGER),
        label("HelpHint", (0.3, 0.52, 0.4, 0.06), align="Center", text="Appelle à l'aide : un coéquipier peut te relever."),
        bar("Bleed", (0.35, 0.6, 0.3, 0.015), color=DANGER),
    ]))


def spectator_gui():
    return _hide_roots(screen_gui("SpectatorGui", "SpectatorController", [
        title("Watching", (0.3, 0.03, 0.4, 0.06), align="Center"),
        button("Prev", (0.02, 0.45, 0.08, 0.1), text="Précédent"),
        button("Next", (0.9, 0.45, 0.08, 0.1), text="Suivant"),
        label("Note", (0.25, 0.9, 0.5, 0.05), align="Center", color=TEXT2,
              text="Tu es mort. Tu peux encore suivre ton groupe."),
    ]))


def radio_gui():
    return _hide_roots(screen_gui("RadioGui", "RadioController", [
        label("Channel", (0.8, 0.2, 0.18, 0.04), align="Right"),
        frame("Talking", (0.955, 0.25, 0.015, 0.027), bg=POSITIVE, bg_t=0, children=[corner(0.5, 0)]),
        frame("Static", (0.8, 0.29, 0.18, 0.01), bg=TEXT2, bg_t=0.4),
    ]))


MOBILE_BUTTONS = [  # (nom, x, y) — DÉFAUT : grille à droite, au-dessus du bouton de saut de Roblox
    ("Tablet", 0.89, 0.18), ("Ping", 0.80, 0.18), ("Light", 0.71, 0.18),
    ("Interact", 0.89, 0.32), ("Reload", 0.80, 0.32), ("Aim", 0.71, 0.32),
    ("Fire", 0.89, 0.46), ("Sprint", 0.80, 0.46), ("Crouch", 0.71, 0.46), ("Prone", 0.62, 0.46),
    ("LeanL", 0.02, 0.35), ("LeanR", 0.1, 0.35),
]
MOBILE_LABELS = {  # 15.6
    "Sprint": "Courir", "Crouch": "Accroupi", "Prone": "Couché", "Interact": "Utiliser", "Aim": "Viser",
    "Fire": "Tirer", "Reload": "Recharger", "Light": "Lampe", "Tablet": "Tablette", "Ping": "Signaler",
    "LeanL": "← Pencher", "LeanR": "Pencher →",
}


def mobile_controls_gui():
    children = []
    for name, x, y in MOBILE_BUTTONS:
        b = button(name, (x, y, 0.07, 0.124), visible=False, text=MOBILE_LABELS[name])
        b.add(aspect(0.07, 0.124))
        b.children = [c for c in b.children if c.cls != "UICorner"] + [corner(0.5, 0)]
        children.append(b)
    return screen_gui("MobileControlsGui", "InputController", children)


# --- 15.5 Les deux places --------------------------------------------------------------------

def cinematic_gui():
    bar_h = round((1 - SCREEN_ASPECT / 2.35) / 2, 4)  # bandes 2.35:1 (6.1) sur un écran 16:9
    return _hide_roots(screen_gui("CinematicGui", "CinematicController", [
        frame("BarTop", (0, 0, 1, bar_h), bg=BLACK, bg_t=0),
        frame("BarBottom", (0, 1 - bar_h, 1, bar_h), bg=BLACK, bg_t=0),
        label("Subtitle", (0.1, 0.78, 0.8, 0.07), align="Center"),
        button("Skip", (0.85, 0.91, 0.12, 0.06), text="Passer", children=[  # 6.1 : bouton « Passer »
            label("Votes", (1.05, 0, 0.6, 1), color=TEXT2),
        ]),
    ], display_order=60))


# 17.2 : réglages. (id, texte, type, options) ; type "options" ou "slider"
YES_NO = [("Opt_Yes", "Oui"), ("Opt_No", "Non")]
PERCENTS = [("Opt_25", "25 %"), ("Opt_50", "50 %"), ("Opt_75", "75 %"), ("Opt_100", "100 %")]
SETTINGS_PAGES = [
    ("Graphics", "Graphismes", [
        ("Preset", "Préréglage", "options",
         [("Opt_Low", "Bas"), ("Opt_Medium", "Moyen"), ("Opt_High", "Élevé"), ("Opt_Ultra", "Ultra")]),
        ("Brightness", "Luminosité (gamma)", "slider", None),
        ("Calibration", "le symbole doit être à peine visible", "calibration", None),
        ("ViewDistance", "Distance d'affichage du décor", "options", PERCENTS),
        ("VegetationDensity", "Densité de végétation", "options", PERCENTS),
        ("TreeWind", "Vent dans les arbres", "options", YES_NO),
        ("LampShadows", "Ombres des lampes", "options", YES_NO),
        ("DepthOfField", "Profondeur de champ, flou lumineux", "options", YES_NO),
        ("Particles", "Densité des particules (pluie, neige, cendre)", "options",
         [("Opt_Low", "Faible"), ("Opt_Normal", "Normale")]),
        ("FieldOfView", "Champ de vision", "slider", None),
    ]),
    ("Controls", "Contrôles", [
        ("Sensitivity", "Sensibilité", "slider", None),
        ("InvertY", "Inverser l'axe vertical", "options", YES_NO),
        ("TouchButtonSize", "Taille des boutons tactiles", "slider", None),
    ]),
    ("Audio", "Audio", [
        ("Master", "Général", "slider", None),
        ("Ambience", "Ambiance", "slider", None),
        ("Voice", "Voix", "slider", None),
        ("Music", "Musique", "slider", None),
        ("Effects", "Effets", "slider", None),
    ]),
    ("Accessibility", "Accessibilité", [
        ("Subtitles", "Sous-titres", "options", YES_NO),
        ("SubtitleSize", "Taille", "options",
         [("Opt_Small", None), ("Opt_Medium", "Moyenne"), ("Opt_Large", None)]),
        ("ReduceMotion", "Réduire les mouvements (balancement de caméra)", "options", YES_NO),
        ("ReducedGore", "Gore réduit", "options", YES_NO),
        ("Language", "Langue", "options", [("Opt_French", "Français"), ("Opt_English", "Anglais")]),
    ]),
]
MISSING_OPTION = {"Opt_Small": "Petite", "Opt_Large": "Grande"}


def setting_row(setting_id, text, kind, options, order):
    row = frame(setting_id, (0, 0, 1, 0.085), order=order, note="lu par SettingsController")
    if kind == "calibration":
        row.props.update(rect(0, 0, 1, 0.16))
        row.add(
            frame("Symbol", (0.02, 0.1, 0.08, 0.8), bg=hex_color("#121311"), bg_t=0,
                  children=[aspect(0.08 * 0.94, 0.8 * 0.16 * 0.74)], note="symbole de calibrage (17.2)"),
            label("Label", (0.12, 0.1, 0.86, 0.8), text=text, color=TEXT2, read=False),
        )
        return row
    row.add(label("Label", (0.02, 0, 0.45, 1), text=text, read=False))
    if kind == "slider":
        row.add(frame("Slider", (0.5, 0.3, 0.36, 0.4), children=[
            frame("Track", (0, 0.35, 1, 0.3), bg=TEXT2, bg_t=0.5, children=[fill()]),
        ]), label("Value", (0.88, 0, 0.1, 1), align="Right"))
    else:
        opts = frame("Options", (0.5, 0.1, 0.48, 0.8), children=[list_layout(vertical=False, padding=0.02)])
        width = round((1 - 0.02 * (len(options) - 1)) / len(options), 3)
        for i, (opt_id, opt_text) in enumerate(options, start=1):
            if opt_text is None:
                opts.add(button(opt_id, (0, 0, width, 1), order=i, text=MISSING_OPTION[opt_id], defaut=True))
            else:
                opts.add(button(opt_id, (0, 0, width, 1), order=i, text=opt_text))
        row.add(opts)
    return row


def settings_gui():
    tabs = frame("Tabs", (0.03, 0.02, 0.94, 0.08), children=[list_layout(vertical=False, padding=0.01)])
    pages = frame("Pages", (0.03, 0.12, 0.94, 0.74))
    for i, (page_id, page_text, rows) in enumerate(SETTINGS_PAGES, start=1):
        tabs.add(button(page_id, (0, 0, 0.24, 1), text=page_text, order=i))
        pg = scrolling(page_id, (0, 0, 1, 1), children=[list_layout(padding=0.01)])
        if i != 1:
            pg.props["Visible"] = False
        for j, (setting_id, text, kind, options) in enumerate(rows, start=1):
            pg.add(setting_row(setting_id, text, kind, options, j))
        pages.add(pg)
    window = panel("Window", (0.12, 0.06, 0.76, 0.88), children=[
        tabs, pages,
        button("Apply", (0.03, 0.89, 0.2, 0.08), text="Appliquer"),
        button("Reset", (0.26, 0.89, 0.2, 0.08), text="Réinitialiser"),
        button("Close", (0.77, 0.89, 0.2, 0.08), text="Fermer"),
    ])
    return screen_gui("SettingsGui", "SettingsController", [window], display_order=70)


def notification_gui():
    item = template(frame("Template", (0, 0, 1, 0.22), panel=False, bg=PANEL, bg_t=PANEL_T, children=[
        corner(),
        label("Text", (0.04, 0.1, 0.92, 0.8), align="Center"),
    ]))
    stack = frame("Stack", (0.3, 0.02, 0.4, 0.3), children=[list_layout(padding=0.03), item])
    return screen_gui("NotificationGui", "NotificationController", [stack], display_order=50)


# --- UITemplates (15.5) ----------------------------------------------------------------------

def billboard(name, size, offset, children, note):
    props = {"Size": udim2(*size), "StudsOffset": offset, "AlwaysOnTop": True, "LightInfluence": 0,
             "ResetOnSpawn": False}
    el = El(name, "BillboardGui", props, children, note=note)
    el.controller = None
    return el


def ping_marker():
    return billboard("PingMarker", (0, 24, 0, 24), [0, 1, 0], [
        frame("Dot", (0, 0, 1, 1), bg=POSITIVE, bg_t=0, children=[corner(0.5, 0), stroke(TEXT, 1)]),
    ], "repère de ping (7.8) ; DÉFAUT : nom")


def name_tag():
    return billboard("NameTag", (0, 160, 0, 30), [0, 3, 0], [
        label("PlayerName", (0, 0, 1, 1), align="Center"),
    ], "nom au-dessus de la tête ; DÉFAUT : nom")


# --- écriture --------------------------------------------------------------------------------

def to_json(el, top=True):
    data = {"className": el.cls}
    if not top:
        data = {"name": el.name, "className": el.cls}
    if el.props:
        data["properties"] = el.props
    if el.children:
        data["children"] = [to_json(c, top=False) for c in el.children]
    return data


LAYOUTS = ("UIListLayout", "UIGridLayout")


def center_constrained(el, parent_has_layout=False):
    """Un UIAspectRatioConstraint réduit la boîte sans la recentrer : les éléments contraints
    hors disposition sont donc ancrés en leur centre (AnchorPoint 0,5 ; 0,5) pour rester à la même
    place sur un écran plus large (téléphone)."""
    has_aspect = any(c.cls == "UIAspectRatioConstraint" for c in el.children)
    if has_aspect and not parent_has_layout and "Position" in el.props and "AnchorPoint" not in el.props:
        (xs, _), (ys, _) = el.props["Position"]["UDim2"]
        (ws, _), (hs, _) = el.props["Size"]["UDim2"]
        el.props["Position"] = udim2(round(xs + ws / 2, 4), 0, round(ys + hs / 2, 4), 0)
        el.props["AnchorPoint"] = [0.5, 0.5]
    has_layout = any(c.cls in LAYOUTS for c in el.children)
    for child in el.children:
        center_constrained(child, has_layout)


REF_W, REF_H = 1920, 1080  # écran de référence 16:9


def width_aspect(ratio):
    # hauteur calculée depuis la largeur : indépendante de la hauteur du canevas défilant
    return layout_child("UIAspectRatioConstraint", AspectRatio=round(ratio, 3), AspectType="ScaleWithParentSize",
                        DominantAxis="Width")


def scroll_aspects(el, abs_w=REF_W, abs_h=REF_H):
    """Dans un ScrollingFrame, une taille en Scale sur Y suit la hauteur du canevas : chaque ligne
    reçoit donc une contrainte d'aspect qui fixe sa hauteur à partir de sa largeur (tout reste en Scale)."""
    for child in el.children:
        if child.read is None:
            if el.cls == "ScrollingFrame" and child.cls == "UIGridLayout":
                (cw, _), (ch, _) = child.props["CellSize"]["UDim2"]
                child.children.append(width_aspect(cw * abs_w / (ch * abs_h)))
            continue
        size = child.props.get("Size")
        (sx, _), (sy, _) = size["UDim2"] if size else ([1, 0], [1, 0])
        cw, ch = sx * abs_w, sy * abs_h
        if el.cls == "ScrollingFrame" and size and not any(c.cls == "UIAspectRatioConstraint" for c in child.children):
            child.children.append(width_aspect(cw / ch))
        scroll_aspects(child, cw, ch)


def write_model(el, folder):
    scroll_aspects(el)
    center_constrained(el)
    os.makedirs(folder, exist_ok=True)
    path = os.path.join(folder, el.name + ".model.json")
    with open(path, "w", encoding="utf-8") as f:
        json.dump(to_json(el), f, ensure_ascii=False, indent=2)
        f.write("\n")


GUIS = {
    "Lobby": [dialogue_gui, museum_panel_gui, party_gui, None, weapon_board_gui, vote_gui, skin_shop_gui,
              records_gui, evidence_board_gui, results_gui, loading_gui],
    "Partie": [hud_gui, inventory_gui, objective_gui, interact_gui, tablet_gui, document_gui, downed_gui,
               spectator_gui, radio_gui, mobile_controls_gui],
    "Common": [cinematic_gui, settings_gui, notification_gui],
}


def build_role_select():
    # DÉFAUT : grille défilante (sur téléphone, les 10 cartes ne tiennent pas avec un texte à 14 au minimum)
    grid = scrolling("Grid", (0.04, 0.06, 0.92, 0.78), children=[grid_layout(0.19, 0.48, 0.0125, 0.04)])
    for role_id, name, role_title, ability, weakness in ROLES:
        grid.add(card_button(f"RoleCard_{role_id}", order=ROLE_ORDER.index(role_id) + 1, children=[
            viewport("Portrait", (0, 0, 1, 0.32), note="13.5 : affiche le modèle Skin_A du rôle"),
            title("CharacterName", (0.04, 0.33, 0.92, 0.09), text=name),  # 2.5
            label("RoleTitle", (0.04, 0.43, 0.92, 0.07), text=role_title, color=TEXT2),  # 2.5
            label("Ability", (0.04, 0.51, 0.92, 0.31), text=ability, valign="Top"),  # 7.7
            label("Weakness", (0.04, 0.83, 0.92, 0.15), text=weakness, color=DANGER, valign="Top"),  # 7.7
            frame("TakenOverlay", (0, 0, 1, 1), visible=False, bg=PANEL, bg_t=0.15, children=[
                label("TakenBy", (0.05, 0.4, 0.9, 0.2), align="Center"),
            ]),
        ]))
    return _hide_roots(screen_gui("RoleSelectGui", "RoleController", [
        grid, button("Confirm", (0.4, 0.87, 0.2, 0.08), text="Confirmer"),
    ]))


GUIS["Lobby"][3] = build_role_select


def walk(el, path, rows, missing, controller):
    if el.read is None:  # disposition, contraintes, coins, contours
        return
    status = f"lu par `{controller}`" if (el.read and controller) else ("décoratif" if not el.read else "—")
    text = el.props.get("Text", "")
    rows.append((path, el.cls, status, text, el.note))
    if el.missing:
        missing.append((path, el.missing))
    if getattr(el, "defaut", None):
        missing.append((path, "DÉFAUT appliqué : « " + el.defaut + " »"))
    for child in el.children:
        walk(child, f"{path}/{child.name}", rows, missing, controller)


def main():
    if os.path.isdir(OUT):
        shutil.rmtree(OUT)
    all_rows = []
    all_missing = []
    sections = [("Lobby", "15.3", "StarterGui (Lobby)"), ("Partie", "15.4", "StarterGui (Partie)"),
                ("Common", "15.5", "StarterGui (les deux places)")]
    for place, section, where in sections:
        for builder in GUIS[place]:
            gui = builder()
            write_model(gui, os.path.join(OUT, place))
            rows, missing = [], []
            walk(gui, gui.name, rows, missing, gui.controller)
            all_rows.append((section, where, gui.name, gui.controller, rows))
            all_missing.extend(missing)
    templates = [ping_marker(), name_tag()]
    for el in templates:
        write_model(el, os.path.join(OUT, "UITemplates"))
        rows, missing = [], []
        walk(el, el.name, rows, missing, None)
        all_rows.append(("15.5", "ReplicatedStorage/UITemplates (les deux places)", el.name, None, rows))
        all_missing.extend(missing)
    write_ui_map(all_rows, all_missing)
    print(f"{sum(len(r[4]) for r in all_rows)} éléments, {len(all_missing)} textes manquants")


def write_ui_map(all_rows, all_missing):
    lines = [
        "# UI_MAP — interfaces de PISTE FROIDE",
        "",
        "Livré à la fin du jalon UI (J5, phase A2), bible section 15. Généré par `tools/ui/build_ui.py`.",
        "",
        "Pour chaque élément : son chemin, sa classe, et s'il est **lu par un script** (le contrôleur",
        "de la colonne « Lu par » de la section 15) ou **décoratif**. Les objets de disposition",
        "(`UIListLayout`, `UIGridLayout`, `UIAspectRatioConstraint`, `UITextSizeConstraint`, `UICorner`,",
        "`UIStroke`) ne sont pas listés : les scripts n'y touchent jamais (15.1).",
        "",
        "Contrat (15.1) : les scripts changent seulement `Text`, `Visible`, `Size.X.Scale` des cadres",
        "`Fill`, les transparences, l'`Image` des icônes, et clonent les enfants `Template`.",
        "Tout le reste (position, taille, couleurs, polices, disposition) se règle à la main dans Studio.",
        "",
        "## Libellés hors section 15.6",
        "",
        "15.6 : un libellé court absent du tableau prend la proposition de Claude Code, marquée DÉFAUT.",
        "",
        "| Élément | Libellé |",
        "| --- | --- |",
    ]
    for path, proposal in all_missing:
        lines.append(f"| `{path}` | {proposal} |")
    lines += ["", "## Éléments", ""]
    for section, where, name, controller, rows in all_rows:
        lines += [f"### {name} — {where}, section {section}", ""]
        if controller:
            lines += [f"Lu par `{controller}`.", ""]
        lines += ["| Chemin | Classe | Statut | Texte de départ | Remarque |", "| --- | --- | --- | --- | --- |"]
        for path, cls, status, text, note in rows:
            text_cell = text.replace("|", "\\|") if text else ""
            lines.append(f"| `{path}` | {cls} | {status} | {text_cell} | {note or ''} |")
        lines.append("")
    with open(os.path.join(ROOT, "UI_MAP.md"), "w", encoding="utf-8") as f:
        f.write("\n".join(lines))


if __name__ == "__main__":
    main()
