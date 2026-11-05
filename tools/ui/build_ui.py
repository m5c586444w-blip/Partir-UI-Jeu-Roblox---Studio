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
        el.add(aspect_of(r), corner())
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


# --- 15.7 : deux dispositions, pixels de référence -----------------------------------------------
# Chaque écran est dessiné en pixels pour sa zone sûre de référence, puis écrit en Scale (15.2) :
# PC 1280 × 720 moins la barre de Roblox (58) = 1280 × 662 ; téléphone 844 × 390 moins l'encoche
# (47 à gauche et à droite), la barre de Roblox (58) et la barre d'accueil (21) = 750 × 311.


class Rect(tuple):
    """Rectangle en Scale (x, y, w, h) qui garde sa taille en pixels de référence (px)."""
    px = None


class Box:
    def __init__(self, w, h):
        self.w, self.h = w, h

    def __call__(self, x, y, w, h):
        r = Rect((round(x / self.w, 4), round(y / self.h, 4), round(w / self.w, 4), round(h / self.h, 4)))
        r.px = (w, h)
        return r


PC = Box(1280, 662)
PH = Box(750, 311)


def screen_box(t):
    return PH if t else PC


def minsize(w, h):
    # 15.7 : taille minimale en pixels (UISizeConstraint)
    return layout_child("UISizeConstraint", MinSize={"Vector2": [w, h]})


ROW_MIN = 36  # 15.7 (4) : hauteur minimale des lignes de réglages et de listes
TOUCH_MIN = 56  # 15.7 (3) : boutons tactiles


def row_min():
    return minsize(0, ROW_MIN)


def veil(*windows):
    # 15.7 : voile noir à 60 % sur le reste de l'écran, montré avec la fenêtre (Util.prepareGui, veilFor)
    el = frame("Veil", (0, 0, 1, 1), bg=BLACK, bg_t=0.4, visible=False,
               note="voile 60 % : visible avec " + ", ".join(windows) + " (attribut veilFor)")
    el.props["ZIndex"] = 1
    el.attributes = {"veilFor": ",".join(windows)}
    return el


def window(name, r, children=(), visible=False, note=None):
    # fenêtre au-dessus d'un panneau : fond opaque (15.7), au-dessus du voile
    el = panel(name, r, visible=visible, children=children, note=note)
    el.props["BackgroundTransparency"] = 0
    el.props["ZIndex"] = 2
    return el


def two_layouts(name, controller, builder, display_order=0, menu=False):
    """15.7 (1) : Layout_Desktop et Layout_Touch, mêmes noms d'éléments ; Util.prepareGui montre la bonne."""
    layouts = []
    for t, lname in ((False, "Layout_Desktop"), (True, "Layout_Touch")):
        lay = frame(lname, (0, 0, 1, 1), visible=not t, children=builder(t),
                    note="15.7 : disposition choisie par Util.prepareGui (UserInputService.TouchEnabled)")
        lay.ref = screen_box(t)
        if menu:
            for child in lay.children:
                if child.read is not None:
                    child.props["Visible"] = False
        layouts.append(lay)
    return screen_gui(name, controller, layouts, display_order=display_order)


def lock_label(text, visible=True):
    # 15.7 (7) : le verrou couvre tout son bouton, fond opaque ; il affiche lui-même sa condition
    el = label("Lock", (0, 0, 1, 1), text=text, align="Center", visible=visible, color=TEXT2)
    el.props.update({"BackgroundColor3": PANEL, "BackgroundTransparency": 0, "ZIndex": 2})
    el.add(corner())
    # 15.6, 15.7 et 19.6 : « Verrouillé », « Verrouillé — 5 parties jouées », et les conditions validées
    # le 5 novembre (« — 3 parties jouées », « — 10 parties jouées », « — 1 preuve de classe B », « — 1 survie »)
    return el


def bar_with_icon(name, icon_name, b, x, y, w, color=TEXT, icon_note=None):
    # 15.7 (6) : chaque jauge a son icône à gauche
    size = 16 if b is PH else 18
    return [
        image(icon_name, b(x, y - size // 2 + 3, size, size), note=icon_note),
        bar(name, b(x + size + 6, y, w, 6 if b is PH else 7), color=color),
    ]


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
    def build(t):
        B = screen_box(t)
        r = B(0, 118, 750, 193) if t else B(240, 400, 800, 250)
        pw, ph = r.px
        b = Box(pw, ph)
        rows = (30, 4) if t else (44, 8)
        choices_h = 3 * rows[0] + 2 * rows[1]
        cb = Box(pw - 16, choices_h)
        choices = frame("Choices", b(8, ph - choices_h - 8, pw - 16, choices_h),
                        children=[list_layout(padding=round(rows[1] / choices_h, 4))])
        for i in range(1, 4):
            choices.add(button(f"Choice_{i}", cb(0, 0, pw - 16, rows[0]), order=i))
        return [veil("Dialogue"), window("Dialogue", r, children=[
            title("SpeakerName", b(10, 6, 420, 22 if t else 34)),
            label("Line", b(10, 30 if t else 44, pw - 20, (ph - choices_h - 46) if t else (ph - choices_h - 64)),
                  valign="Top"),
            choices,
        ])]
    return two_layouts("DialogueGui", "DialogueController", build, menu=True)


def museum_panel_gui():
    def build(t):
        B = screen_box(t)
        r = B(0, 0, 750, 311) if t else B(150, 40, 980, 590)
        pw, ph = r.px
        b = Box(pw, ph)
        if t:
            kids = [
                title("Title", b(8, 4, 600, 24)),
                button("Close", b(650, 4, 92, 28), text="Fermer"),
                image("Illustration", b(8, 36, 230, 226)),
                label("Body", b(246, 36, 496, 226), valign="Top"),
                label("Source", b(8, 268, 734, 38), color=TEXT2),
            ]
        else:
            kids = [
                title("Title", b(24, 20, 780, 50)),
                button("Close", b(836, 20, 120, 44), text="Fermer"),
                image("Illustration", b(24, 86, 420, 400)),
                label("Body", b(468, 86, 488, 400), valign="Top"),
                label("Source", b(24, 504, 932, 62), color=TEXT2),
            ]
        return [veil("Panel"), window("Panel", r, children=kids)]
    return two_layouts("MuseumPanelGui", "MuseumController", build, menu=True)


def party_gui():
    def build(t):
        B = screen_box(t)
        r = B(474, 0, 276, 311) if t else B(794, 66, 448, 460)
        pw, ph = r.px
        b = Box(pw, ph)
        if t:
            header, members, buttons, code = (8, 4, 260, 26), (8, 34, 260, 104), (8, 142, 260, 132), (8, 280, 260, 28)
            btn_h, gap, member_h = 30, 4, 44
        else:
            header, members, buttons, code = (16, 10, 416, 40), (16, 56, 416, 150), (16, 212, 416, 194), (16, 414, 416, 38)
            btn_h, gap, member_h = 44, 6, 48
        mb = Box(members[2], members[3])
        member = template(frame("Template", mb(0, 0, members[2], member_h), children=[
            label("PlayerName", Box(members[2], member_h)(6, 2, members[2] * 0.82, member_h / 2 - 2)),
            label("RoleName", Box(members[2], member_h)(6, member_h / 2, members[2] * 0.82, member_h / 2 - 2),
                  color=TEXT2),
            frame("ReadyIcon", Box(members[2], member_h)(members[2] - 22, member_h / 2 - 7, 14, 14), bg=POSITIVE,
                  bg_t=0, children=[corner(0.5, 0)]),
            row_min(),
        ]))
        # 15.7 : une colonne de boutons assez larges pour « Rejoindre avec un code » à 14
        bb = Box(buttons[2], buttons[3])
        grid = frame("Buttons", b(*buttons), children=[list_layout(padding=round(gap / buttons[3], 4))])
        for i, (name, text) in enumerate([("CreatePublic", "Groupe public"), ("CreatePrivate", "Groupe privé"),
                                          ("JoinCode", "Rejoindre avec un code"), ("QuickJoin", "Partie rapide"),
                                          ("Ready", "Prêt"), ("Leave", "Quitter le groupe")], start=1):
            grid.add(button(name, bb(0, 0, buttons[2], btn_h), order=i, text=text))
        hb = Box(header[2], header[3])
        return [panel("PartyFrame", r, children=[
            frame("Header", b(*header), children=[
                title("Title", hb(0, 0, header[2] * 0.6, header[3]), text="Groupe", defaut=True),
                title("Code", hb(header[2] * 0.6, 0, header[2] * 0.4, header[3]), align="Right"),
            ]),
            scrolling("MemberList", b(*members), children=[list_layout(padding=0.01), member]),
            grid,
            textbox("CodeInput", b(*code), placeholder="Code à 4 chiffres"),
        ])]
    return two_layouts("PartyGui", "PartyController", build)


WEAPONS = [("Slot_Rifle", "Fusil à verrou"), ("Slot_Revolver", "Revolver"), ("Slot_Shotgun", "Fusil à pompe")]


def weapon_board_gui():
    def build(t):
        B = screen_box(t)
        r = B(0, 0, 470, 78) if t else B(26, 66, 740, 250)
        pw, ph = r.px
        b = Box(pw, ph)
        board = panel("Board", r, children=[list_layout(vertical=False, padding=0.012)])
        sw = (pw - 2 * 0.012 * pw) / 3
        sb = Box(sw, ph)
        for i, (slot, weapon_name) in enumerate(WEAPONS, start=1):
            if t:
                kids = [image("Icon", sb(4, 4, 28, ph - 8), note="icône d'arme (Icon_WPN_*, 13.5)"),
                        title("WeaponName", sb(36, 2, sw - 38, 18), text=weapon_name, read=False),  # 8.2
                        label("Holder", sb(36, 21, sw - 38, 20), color=TEXT2),
                        button("Take", sb(36, 44, sw - 40, 28), text="Prendre")]
            else:
                kids = [image("Icon", sb(sw * 0.15, 10, sw * 0.7, 96), note="icône d'arme (Icon_WPN_*, 13.5)"),
                        title("WeaponName", sb(8, 112, sw - 16, 32), text=weapon_name, align="Center", read=False),
                        label("Holder", sb(8, 148, sw - 16, 30), color=TEXT2, align="Center"),
                        button("Take", sb(sw * 0.15, 188, sw * 0.7, 44), text="Prendre")]
            board.add(frame(slot, b(0, 0, sw, ph), order=i, bg=PANEL, bg_t=PANEL_T,
                            children=[corner(), stroke()] + kids))
        # 15.7 : fenêtre surgissante opaque et voile
        pr = B(175, 56, 400, 190) if t else B(390, 170, 500, 300)
        qw, qh = pr.px
        q = Box(qw, qh)
        if t:
            pop = [label("Question", q(10, 8, 380, 60), align="Center"),
                   button("Option_1", q(10, 76, 185, 34)), button("Option_2", q(205, 76, 185, 34)),
                   label("Timer", q(10, 120, 380, 24), align="Center", color=TEXT2)]
        else:
            pop = [label("Question", q(20, 16, 460, 100), align="Center"),
                   button("Option_1", q(20, 130, 220, 54)), button("Option_2", q(260, 130, 220, 54)),
                   label("Timer", q(20, 204, 460, 40), align="Center", color=TEXT2)]
        return [board, veil("VotePopup"), window("VotePopup", pr, children=pop)]
    return two_layouts("WeaponBoardGui", "WeaponBoardController", build, menu=True)


def vote_gui():
    # DÉFAUT : disposition du lobby — armes en haut à gauche, votes dessous, groupe à droite
    # 15.3 : Difficulty > Normal, Hard, Nightmare (> Lock) ; Weather > Random, Clear, Fog, Rain, Snow
    weather_options = [("Random", "Aléatoire"), ("Clear", "Nuit claire"), ("Fog", "Brouillard"),
                       ("Rain", "Pluie"), ("Snow", "Première neige")]  # 4.4 : aléatoire ou fixe ; 12.3

    def build(t):
        B = screen_box(t)
        dr = B(0, 102, 190, 106) if t else B(26, 330, 360, 300)
        wr = B(196, 102, 274, 106) if t else B(406, 330, 360, 300)
        cr = B(0, 80, 470, 20) if t else B(794, 16, 448, 40)
        dw, dh = dr.px
        d = Box(dw, dh)
        title_h, btn_h = (18, 28) if t else (40, 70)
        gap = (dh - title_h - 3 * btn_h) / 4
        difficulty = panel("Difficulty", dr, children=[
            title("Title", d(6, 1, dw - 12, title_h), text="Difficulté", read=False),  # 4.4
            button("Normal", d(6, title_h + gap, dw - 12, btn_h), order=1, text="Normal"),  # 4.4, 5.4
            button("Hard", d(6, title_h + 2 * gap + btn_h, dw - 12, btn_h), order=2, text="Difficile"),
            # 15.7 (7) : le verrou affiche sa condition (5.4 : Cauchemar après une première survie)
            button("Nightmare", d(6, title_h + 3 * gap + 2 * btn_h, dw - 12, btn_h), order=3, text="Cauchemar",
                   children=[lock_label("Verrouillé — 1 survie")]),
        ])
        ww, wh = wr.px
        w = Box(ww, wh)
        grid_h = wh - title_h - 4
        cols = 2 if t else 1
        rows = 3 if t else 5
        cell_w = (ww - 12 - (cols - 1) * 6) / cols
        cell_h = (grid_h - (rows - 1) * 4) / rows
        weather = panel("Weather", wr, children=[
            title("Title", w(6, 1, ww - 12, title_h), text="Météo", read=False),  # 4.4 : et météo
        ])
        # les boutons restent enfants directs de Weather (chemins de 15.3)
        for i, (name, text) in enumerate(weather_options):
            col, row = i % cols, i // cols
            weather.add(button(name, w(6 + col * (cell_w + 6), title_h + 2 + row * (cell_h + 4), cell_w, cell_h),
                               order=i + 1, text=text))
        return [difficulty, weather, title("Countdown", cr, align="Center")]
    return two_layouts("VoteGui", "VoteController", build, menu=True)


# 19.5 (C38) : accessoires ; textes des verrous validés en 19.6
ACCESSORIES = [("Beanie", "Bonnet", "Verrouillé — 3 parties jouées"),
               ("AmberHeadlamp", "Frontale ambre", "Verrouillé — 10 parties jouées"),
               ("ColdTrailBag", "Sac « Cold Trail »", "Verrouillé — 1 preuve de classe B")]


def skin_shop_gui():
    skins = [("Skin_A", "Tenue de départ", ""), ("Skin_B", "Tenue de pluie", "5 parties jouées"),
             ("Skin_C", "Tenue « Cold Trail »", "1 survie")]  # 7.1
    locks = {"Skin_B": "Verrouillé — 5 parties jouées", "Skin_C": "Verrouillé — 1 survie"}  # 15.7 (7)

    def build(t):
        B = screen_box(t)
        if t:
            lr, gr, ar, pr, er = B(0, 0, 180, 311), B(186, 0, 300, 196), B(186, 202, 300, 109), B(492, 0, 258, 262), \
                B(492, 268, 258, 40)
        else:
            lr, gr, ar, pr, er = B(26, 40, 300, 590), B(346, 40, 520, 380), B(346, 432, 520, 198), B(886, 40, 368, 520), \
                B(886, 572, 368, 58)
        lw, lh = lr.px
        row_h = 36 if t else 48
        char_template = template(button("Template", Box(lw, lh)(0, 0, lw, row_h)))
        char_template.add(row_min())
        gw, gh = gr.px
        cell_h = (gh - 12 - 2 * 6) / 3
        grid = frame("SkinGrid", gr, panel=True, children=[
            layout_child("UIListLayout", SortOrder="LayoutOrder", FillDirection="Vertical",
                         Padding={"UDim": [round(6 / gh, 4), 0]}, HorizontalAlignment="Center",
                         VerticalAlignment="Center")])
        cb = Box(gw - 12, cell_h)
        for i, (name, outfit, requirement) in enumerate(skins, start=1):
            grid.add(button(name, Box(gw, gh)(6, 0, gw - 12, cell_h), text=outfit, order=i, children=[
                lock_label(locks[name], visible=True) if name in locks else lock_label("", visible=False),
                # 15.7 (7) : Requirement reste masqué tant que le verrou est là
                label("Requirement", cb(6, cell_h * 0.62, gw - 24, cell_h * 0.36), text=requirement, color=TEXT2,
                      align="Center", visible=False),
            ]))
        aw, ah = ar.px
        acc = frame("Accessories", ar, panel=True, note="19.5 (C38) : accessoires", children=[
            layout_child("UIListLayout", SortOrder="LayoutOrder", FillDirection="Vertical",
                         Padding={"UDim": [round(4 / ah, 4), 0]}, HorizontalAlignment="Center",
                         VerticalAlignment="Center")])
        acc_h = (ah - 12 - 2 * 4) / 3
        for i, (name, text, lock_text) in enumerate(ACCESSORIES, start=1):
            el = button(name, Box(aw, ah)(6, 0, aw - 12, acc_h), text=text, order=i,
                        children=[lock_label(lock_text)])
            el.defaut = None
            acc.add(el)
        return [
            veil("CharacterList", "SkinGrid", "Accessories", "Preview", "Equip"),
            character_list(lr, char_template),
            grid, acc,
            El("Preview", "ViewportFrame", dict(rect(*pr), BackgroundColor3=PANEL, BackgroundTransparency=0,
                                                 BorderSizePixel=0, ZIndex=2),
               [aspect_of(pr), corner()]),
            button("Equip", er, text="Équiper"),
        ]
    gui = two_layouts("SkinShopGui", "SkinShopController", build, menu=True)
    for lay in gui.children:
        for c in lay.children:
            if c.name in ("CharacterList", "SkinGrid", "Accessories", "Equip"):
                c.props["ZIndex"] = 2
                if c.name != "Equip":
                    c.props["BackgroundTransparency"] = 0
    return gui


def character_list(lr, char_template):
    # SkinShopGui/CharacterList/Template (15.3) : la liste défile elle-même
    el = scrolling("CharacterList", lr, children=[list_layout(padding=0.01), char_template])
    el.props.update({"BackgroundColor3": PANEL, "BackgroundTransparency": 0})
    el.add(corner())
    return el


def records_gui():
    def build(t):
        B = screen_box(t)
        tr = B(0, 0, 750, 30) if t else B(190, 40, 900, 50)
        br = B(0, 36, 750, 275) if t else B(190, 100, 900, 530)
        tw, th = tr.px
        tb = Box(tw, th)
        bw, bh = br.px
        row_h = 36 if t else 44
        rb = Box(bw, row_h)
        row = template(frame("Template", Box(bw, bh)(0, 0, bw, row_h), children=[
            label("Rank", rb(4, 4, 50, row_h - 8), align="Center"),
            label("Group", rb(60, 4, bw - 180, row_h - 8)),
            label("Value", rb(bw - 116, 4, 108, row_h - 8), align="Right"),
            row_min(),
        ]))
        tabs = frame("Tabs", tr, children=[list_layout(vertical=False, padding=0.01)])
        for i, (name, text) in enumerate([("Survivors", "Survivants"), ("EvidenceA", "Preuves A"),
                                          ("Endings", "Fins")], start=1):  # 4.5
            tabs.add(button(name, tb(0, 0, (tw - 2 * 0.01 * tw) / 3, th), order=i, text=text))
        board = scrolling("Board", br, children=[list_layout(padding=0.01), row])
        board.props.update({"BackgroundColor3": PANEL, "BackgroundTransparency": 0, "ZIndex": 2})
        tabs.props.update({"BackgroundColor3": PANEL, "BackgroundTransparency": 0, "ZIndex": 2})
        return [veil("Tabs", "Board"), tabs, board]
    return two_layouts("RecordsGui", "RecordsController", build, menu=True)


def evidence_board_gui():
    pages_text = [  # 2.7 : DOC_12, carnet de la famille Halvorsen
        "Il n'a jamais voulu en parler. Il disait seulement : ne tire pas le premier.",
        "Ils frappaient les arbres avant les pierres.",
        "On leur avait pris quelqu'un, à eux aussi.",
    ]

    def build(t):
        B = screen_box(t)
        cr = B(0, 0, 480, 311) if t else B(26, 40, 760, 590)
        nr = B(486, 0, 264, 311) if t else B(806, 40, 448, 590)
        cw, ch = cr.px
        cell = (150, 128) if t else (232, 180)
        cb = Box(*cell)
        item = template(frame("Template", cb(0, 0, *cell), children=[
            image("Photo", cb(6, 4, cell[0] - 12, cell[1] - 70)),
            label("Label", cb(4, cell[1] - 64, cell[0] - 8, 40), align="Center"),
            label("Class", cb(4, cell[1] - 22, cell[0] - 8, 20), color=TEXT2, align="Center"),
        ]))
        grid = layout_child("UIGridLayout", SortOrder="LayoutOrder",
                            CellSize=udim2(round(cell[0] / cw, 4), 0, round(cell[1] / ch, 4), 0),
                            CellPadding=udim2(round(8 / cw, 4), 0, round(8 / ch, 4), 0))
        cork = scrolling("Cork", cr, children=[grid, item])
        cork.props.update({"BackgroundColor3": PANEL, "BackgroundTransparency": 0, "ZIndex": 2})
        nw, nh = nr.px
        page_h = (nh - 16 - 2 * 6) / 3
        pages = frame("NotebookPages", nr, panel=True, children=[
            layout_child("UIListLayout", SortOrder="LayoutOrder", FillDirection="Vertical",
                         Padding={"UDim": [round(6 / nh, 4), 0]}, HorizontalAlignment="Center",
                         VerticalAlignment="Center")])
        pages.props.update({"BackgroundTransparency": 0, "ZIndex": 2})
        for i, text in enumerate(pages_text, start=1):
            page = title(f"Page_{i}", Box(nw, nh)(8, 0, nw - 16, page_h), text=text, order=i, valign="Top")
            page.add(lock_label("Verrouillé", visible=(i != 1)))  # 15.6
            pages.add(page)
        return [veil("Cork", "NotebookPages"), cork, pages]
    return two_layouts("EvidenceBoardGui", "EvidenceBoardController", build, menu=True)


def results_gui():
    def build(t):
        B = screen_box(t)
        r = B(0, 0, 750, 311) if t else B(290, 30, 700, 600)
        pw, ph = r.px
        b = Box(pw, ph)
        if t:
            parts = dict(title=(8, 4, 734, 24), text=(8, 30, 734, 60), surv=(8, 94, 300, 150), evid=(316, 94, 426, 150),
                         xp=(8, 248, 400, 24), cont=(560, 274, 182, 32))
            row_h = 36
        else:
            parts = dict(title=(24, 20, 652, 50), text=(24, 76, 652, 100), surv=(24, 190, 316, 280),
                         evid=(360, 190, 316, 280), xp=(24, 480, 652, 40), cont=(250, 532, 200, 50))
            row_h = 44
        sw = parts["surv"][2]
        survivor = template(frame("Template", Box(sw, parts["surv"][3])(0, 0, sw, row_h), children=[
            label("Name", Box(sw, row_h)(4, 4, sw * 0.6 - 4, row_h - 8)),
            label("Status", Box(sw, row_h)(sw * 0.6, 4, sw * 0.4 - 4, row_h - 8), align="Right", color=TEXT2),
            row_min(),
        ]))
        ew = parts["evid"][2]
        evidence = template(label("Template", Box(ew, parts["evid"][3])(0, 0, ew, row_h)))
        evidence.add(row_min())
        return [veil("Card"), window("Card", r, children=[
            title("EndingTitle", b(*parts["title"]), align="Center"),
            label("EndingText", b(*parts["text"]), align="Center", valign="Top"),
            scrolling("Survivors", b(*parts["surv"]), children=[list_layout(padding=0.01), survivor]),
            scrolling("Evidence", b(*parts["evid"]), children=[list_layout(padding=0.01), evidence]),
            title("XPGained", b(*parts["xp"]), align="Center" if not t else "Left", color=POSITIVE),
            button("Continue", b(*parts["cont"]), text="Continuer"),
        ], visible=True)]
    gui = two_layouts("ResultsGui", "ResultsController", build)
    return gui


def loading_gui():
    return _hide_roots(screen_gui("LoadingGui", "TeleportController", [
        frame("Background", (0, 0, 1, 1), bg=PANEL, bg_t=0),
        label("Tip", (0.05, 0.8, 0.9, 0.1), align="Center", color=TEXT2),
        frame("Spinner", (0.485, 0.45, 0.03, 0.053), bg=TEXT, bg_t=0, read=False,
              children=[corner(0.5, 0), aspect(0.03, 0.053)], note="décor ; à remplacer par une image"),
    ], display_order=100))


def _hide_roots(gui):
    # les enfants directs d'un ScreenGui de menu sont cachés au départ (le contrôleur les montre)
    for child in gui.children:
        if child.read is not None:
            child.props["Visible"] = False
    return gui


def build_role_select():
    def build(t):
        B = screen_box(t)
        if t:
            # 15.7 (5) : cartes réduites (portrait, nom, rôle) sur une ligne qui défile + panneau de détail
            gr = B(0, 0, 750, 164)
            card = (128, 150)
            cb = Box(*card)
            grid = scrolling("Grid", gr, children=[layout_child(
                "UIListLayout", SortOrder="LayoutOrder", FillDirection="Horizontal",
                Padding={"UDim": [round(6 / 750, 4), 0]}, VerticalAlignment="Top")])
            grid.props.update({"AutomaticCanvasSize": "X", "ScrollingDirection": "X"})
            for role_id, name, role_title, ability, weakness in ROLES:
                grid.add(card_button(f"RoleCard_{role_id}", r=Box(750, 164)(0, 0, *card),
                                     order=ROLE_ORDER.index(role_id) + 1, children=[
                    viewport("Portrait", cb(4, 4, card[0] - 8, 64), note="13.5 : affiche le modèle Skin_A du rôle"),
                    title("CharacterName", cb(4, 70, card[0] - 8, 18), text=name),  # 2.5
                    label("RoleTitle", cb(4, 90, card[0] - 8, 40), text=role_title, color=TEXT2, valign="Top"),
                    label("Ability", cb(4, 90, card[0] - 8, 40), text=ability, visible=False,
                          note="téléphone : affiché dans Detail"),  # 7.7
                    label("Weakness", cb(4, 90, card[0] - 8, 40), text=weakness, color=DANGER, visible=False,
                          note="téléphone : affiché dans Detail"),  # 7.7
                    frame("TakenOverlay", cb(0, 0, *card), visible=False, bg=PANEL, bg_t=0, children=[
                        label("TakenBy", cb(4, 60, card[0] - 8, 40), align="Center"),
                    ]),
                ]))
            dr = B(0, 170, 596, 141)
            d = Box(*dr.px)
            detail = panel("Detail", dr, visible=True, note="15.7 (5) : capacité et faiblesse de la carte choisie",
                           children=[
                               label("Ability", d(8, 6, 580, 78), valign="Top"),
                               label("Weakness", d(8, 88, 580, 46), color=DANGER, valign="Top"),
                           ])
            detail.props["BackgroundTransparency"] = 0
            return [veil("Grid", "Detail", "Confirm"), grid, detail,
                    button("Confirm", B(604, 230, 146, 44), text="Confirmer")]
        # PC : grille 5 × 2
        gr = B(26, 30, 1228, 540)
        gw, gh = gr.px
        card = ((gw - 4 * 12) / 5, (gh - 12) / 2)
        cb = Box(*card)
        grid = scrolling("Grid", gr, children=[grid_layout(round(card[0] / gw, 4), round(card[1] / gh, 4),
                                                            round(12 / gw, 4), round(12 / gh, 4))])
        for role_id, name, role_title, ability, weakness in ROLES:
            cw, ch = card
            grid.add(card_button(f"RoleCard_{role_id}", order=ROLE_ORDER.index(role_id) + 1, children=[
                viewport("Portrait", cb(0, 0, cw, 60), note="13.5 : affiche le modèle Skin_A du rôle"),
                title("CharacterName", cb(8, 64, cw - 16, 26), text=name),  # 2.5
                label("RoleTitle", cb(8, 92, cw - 16, 20), text=role_title, color=TEXT2),  # 2.5
                label("Ability", cb(8, 116, cw - 16, 80), text=ability, valign="Top"),  # 7.7
                label("Weakness", cb(8, 200, cw - 16, ch - 204), text=weakness, color=DANGER, valign="Top"),  # 7.7
                frame("TakenOverlay", cb(0, 0, cw, ch), visible=False, bg=PANEL, bg_t=0, children=[
                    label("TakenBy", cb(8, ch / 2 - 20, cw - 16, 40), align="Center"),
                ]),
            ]))
        return [veil("Grid", "Confirm"), grid, button("Confirm", B(540, 584, 200, 50), text="Confirmer")]
    gui = two_layouts("RoleSelectGui", "RoleController", build, menu=True)
    for lay in gui.children:
        for c in lay.children:
            if c.name in ("Grid", "Detail", "Confirm"):
                c.props["ZIndex"] = 2
            if c.name == "Grid":
                c.props.update({"BackgroundColor3": PANEL, "BackgroundTransparency": 0})
    return gui


# --- 15.4 Partie -----------------------------------------------------------------------------

LIMBS = [  # (nom, x, y, w, h) dans une silhouette de 64 × 128
    ("Head", 22, 0, 20, 22), ("Torso", 18, 24, 28, 44), ("ArmL", 4, 24, 12, 44),
    ("ArmR", 48, 24, 12, 44), ("LegL", 18, 70, 13, 58), ("LegR", 33, 70, 13, 58),
]


def body_part(name, r):
    # 15.7 (6) : une image de silhouette par membre (Img_Body_<membre>, 13.5) ; Ok, Hurt, Critical = teintes
    def state(state_name, tint, visible):
        el = image(state_name, (0, 0, 1, 1), visible=visible, note=f"Img_Body_{name} (13.5)")
        el.props["ImageColor3"] = tint
        el.props["ScaleType"] = "Stretch"
        return el
    return frame(name, r, children=[state("Ok", POSITIVE, True), state("Hurt", hex_color("#C9A227"), False),
                                    state("Critical", DANGER, False)])


def hud_gui():
    def build(t):
        B = screen_box(t)
        if t:
            body_r, bleed_r = B(4, 2, 40, 80), B(48, 4, 16, 16)
            gauges = bar_with_icon("Stamina", "StaminaIcon", B, 4, 92, 96) + \
                bar_with_icon("Battery", "BatteryIcon", B, 4, 112, 96, color=TEXT2)
            ammo_r, held_r = B(492, 0, 94, 40), B(240, 238, 270, 22)
        else:
            body_r, bleed_r = B(24, 404, 96, 192), B(126, 404, 22, 22)
            gauges = bar_with_icon("Stamina", "StaminaIcon", B, 24, 618, 220) + \
                bar_with_icon("Battery", "BatteryIcon", B, 24, 642, 220, color=TEXT2)
            ammo_r, held_r = B(1090, 560, 164, 70), B(440, 528, 400, 34)
        bw, bh = body_r.px
        bb = Box(64, 128)
        body = frame("BodyStatus", body_r, children=[aspect(1, 1)])
        body.children = [layout_child("UIAspectRatioConstraint", AspectRatio=0.5)]
        for name, x, y, w, h in LIMBS:
            body.add(body_part(name, bb(x, y, w, h)))
        aw, ah = ammo_r.px
        a = Box(aw, ah)
        ping = frame("Ping", (0, 0, 1, 1), children=[
            template(frame("Template", (0, 0, 0.012, 0.021), bg=POSITIVE, bg_t=0, children=[corner(0.5, 0)])),
        ])
        return [
            image("FearVignette", (0, 0, 1, 1), transparency=1,
                  note="Img_FearVignette (13.5) ; ImageTransparency réglée par le script"),
            body,
            frame("BleedIcon", bleed_r, bg=DANGER, bg_t=0, visible=False, children=[corner(0.5, 0)]),
            *gauges,
            frame("Ammo", ammo_r, children=[
                title("Count", a(0, 0, aw * 0.46, ah), align="Right"),
                label("Reserve", a(aw * 0.5, ah * 0.2, aw * 0.5, ah * 0.6), color=TEXT2),
            ]),
            label("HeldItem", held_r, align="Center"),
            frame("Crosshair", B(375 - 3, 155 - 3, 6, 6) if t else B(640 - 4, 331 - 4, 8, 8), bg=TEXT, bg_t=0,
                  visible=False, children=[corner(0.5, 0)]),
            ping,
        ]
    return two_layouts("HUDGui", "HUDController", build)


def inventory_gui():
    def build(t):
        B = screen_box(t)
        if t:
            sr, slot = B(276, 266, 198, 44), 45
            bag_r = B(150, 84, 400, 148)
        else:
            sr, slot = B(470, 570, 340, 78), 79
            bag_r = B(846, 130, 408, 390)
        sw, sh = sr.px
        gap = (sw - 4 * slot) / 3
        slots = frame("QuickSlots", sr, children=[list_layout(vertical=False, padding=round(gap / sw, 4))])
        s = Box(slot, slot)
        pad = 19 if t else 26
        for i in range(1, 5):
            slots.add(frame(f"Slot_{i}", Box(sw, sh)(0, 0, slot, slot), order=i, bg=PANEL, bg_t=PANEL_T, children=[
                corner(),
                image("Icon", s(slot * 0.15, slot * 0.15, slot * 0.7, slot * 0.7)),
                # 15.7 : pastilles voulues (chiffre en bas à droite, touche en haut à gauche)
                label("Count", s(slot * 0.45, slot - pad, slot * 0.53, pad), align="Right"),
                label("Key", s(2, 0, slot * 0.4, pad), color=TEXT2),
                frame("Selected", s(0, 0, slot, slot), visible=False, children=[stroke(TEXT, 2), corner()]),
            ]))
        bw, bh = bag_r.px
        b = Box(bw, bh)
        top_h = 26 if t else 40
        list_r = (8, top_h + 10, bw - 16, bh - top_h - 18)
        row_h = 36 if t else 44
        rw = list_r[2]
        r = Box(rw, row_h)
        row = template(frame("Template", Box(rw, list_r[3])(0, 0, rw, row_h), children=[
            image("Icon", r(2, 3, row_h - 6, row_h - 6)),
            label("Name", r(row_h + 2, 4, rw * 0.58 - 4, row_h - 8)),
            label("Count", r(rw * 0.58 + row_h, 4, rw * 0.08, row_h - 8), align="Center"),
            button("Drop", r(rw - rw * 0.2 - 2, 4, rw * 0.2, row_h - 8), text="Jeter"),
            row_min(),
        ]))
        bag = window("Bag", bag_r, children=[
            label("Weight", b(8, 6, bw - 120, top_h), color=TEXT2),
            # 15.7 : bouton Fermer (sur téléphone, le seul bouton visible quand le sac est ouvert)
            button("Close", b(bw - 104, 6, 96, top_h), text="Fermer"),
            scrolling("List", b(*list_r), children=[list_layout(padding=0.01), row]),
        ])
        bag.props["ZIndex"] = 1
        return [slots, bag]
    return two_layouts("InventoryGui", "InventoryController", build)


def objective_gui():
    def build(t):
        B = screen_box(t)
        if t:
            return [title("ActName", B(132, 0, 350, 18)), label("ObjectiveText", B(132, 20, 350, 60), valign="Top"),
                    label("Clock", B(650, 0, 100, 20), align="Right")]
        return [title("ActName", B(26, 16, 500, 34)), label("ObjectiveText", B(26, 54, 500, 64), valign="Top"),
                label("Clock", B(1100, 16, 154, 34), align="Right")]
    return two_layouts("ObjectiveGui", "ObjectiveController", build)


def interact_gui():
    def build(t):
        B = screen_box(t)
        r = B(240, 204, 270, 30) if t else B(500, 440, 280, 56)
        pw, ph = r.px
        b = Box(pw, ph)
        if t:
            kids = [label("KeyHint", b(4, 2, 20, 22), align="Center"),
                    label("ActionText", b(28, 1, pw - 34, 23)),
                    bar("Progress", b(4, 25, pw - 8, 3))]
        else:
            kids = [label("KeyHint", b(8, 8, 36, 34), align="Center"),
                    label("ActionText", b(50, 6, pw - 58, 38)),
                    bar("Progress", b(8, 46, pw - 16, 5))]
        return [panel("Prompt", r, children=kids)]
    return two_layouts("InteractGui", "InteractController", build)


def tablet_gui():
    def build(t):
        B = screen_box(t)
        dr = B(40, 2, 670, 307) if t else B(218, 40, 844, 590)
        dw, dh = dr.px
        d = Box(dw, dh)
        sr = (10, 8, dw - 20, dh - 56) if t else (30, 24, dw - 60, dh - 96)
        sw, sh = sr[2], sr[3]
        s = Box(sw, sh)
        bar_h = 32 if t else 50
        pages_r = (0, bar_h + 4, sw, sh - bar_h - 4)
        pw, ph = pages_r[2], pages_r[3]
        p = Box(pw, ph)
        row_h = 36 if t else 44

        def tab(name, text, order):
            return button(name, Box(sw, bar_h)(0, 0, (sw - 4 * 4) / 5, bar_h), text=text, color=TABLET_TEXT,
                          order=order)

        def page(name, children, visible=False):
            return frame(name, (0, 0, 1, 1), visible=visible, children=children)

        def lst(item, lr):
            return scrolling("List", p(*lr), children=[list_layout(padding=0.01), item])

        app_bar = frame("AppBar", s(0, 0, sw, bar_h), children=[
            list_layout(vertical=False, padding=round(4 / sw, 4)),
            # 8.3 : applications de la tablette
            tab("Btn_Map", "Carte", 1), tab("Btn_Objectives", "Objectifs", 2), tab("Btn_Journal", "Journal", 3),
            tab("Btn_Evidence", "Preuves", 4), tab("Btn_Network", "Réseau", 5),
        ])
        dot = 10 if t else 14
        marker = template(frame("Template", p(0, 0, dot, dot), bg=TABLET_TEXT, bg_t=0, children=[corner(0.5, 0)]))
        page_map = page("Page_Map", [
            image("MapImage", (0, 0, 1, 1), note="Img_TabletMap (13.5) : image à créer"),
            image("TunnelLayer", (0, 0, 1, 1), visible=False, note="couche « tunnels » après DOC_07 : image à créer"),
            frame("Markers", (0, 0, 1, 1), children=[marker]),
            frame("PlayerDot", p(pw / 2 - dot / 2, ph / 2 - dot / 2, dot, dot), bg=TABLET_TEXT, bg_t=0,
                  children=[corner(0.5, 0)]),
            label("NoSignal", p(pw * 0.2, ph * 0.42, pw * 0.6, 30 if t else 44), text="Pas de signal GPS",
                  color=TABLET_TEXT, align="Center", visible=False),  # 8.3
        ], visible=True)
        full = (6, 6, pw - 12, ph - 12)

        def item(read_button=False):
            maker = button if read_button else label
            el = template(maker("Template", Box(full[2], full[3])(0, 0, full[2], row_h), color=TABLET_TEXT))
            el.add(row_min())
            return el
        jl = (6, 6, 290 if t else 330, ph - 12)
        reader = (jl[2] + 16, 6, pw - jl[2] - 22, ph - 12)
        rb = Box(reader[2], reader[3])
        journal_item = template(button("Template", Box(jl[2], jl[3])(0, 0, jl[2], row_h), color=TABLET_TEXT))
        journal_item.add(row_min())
        page_journal = page("Page_Journal", [
            scrolling("List", p(*jl), children=[list_layout(padding=0.01), journal_item]),
            frame("Reader", p(*reader), children=[
                title("Title", rb(0, 0, reader[2], 24 if t else 36), color=TABLET_TEXT),
                label("Body", rb(0, 28 if t else 42, reader[2], reader[3] - (28 if t else 42)), color=TABLET_TEXT,
                      valign="Top"),
            ]),
        ])
        page_network = page("Page_Network", [
            frame("Bars", p(pw * 0.4, ph * 0.1, pw * 0.2, 14), bg=PANEL, bg_t=PANEL_T, children=[fill(color=TABLET_TEXT)],
                  note="barres de réseau : Fill.Size.X.Scale = niveau"),
            label("Message", p(pw * 0.1, ph * 0.3, pw * 0.8, ph * 0.3), text="Aucun réseau", color=TABLET_TEXT,
                  align="Center"),  # 8.3
            button("Send", p(pw * 0.35, ph * 0.72, pw * 0.3, 32 if t else 48), color=TABLET_TEXT, text="Envoyer"),
        ])
        screen = frame("Screen", d(*sr), bg=TABLET_BG, bg_t=0, children=[
            app_bar,
            frame("Pages", s(*pages_r), children=[
                page_map,
                page("Page_Objectives", [lst(item(), full)]),
                page_journal,
                page("Page_Evidence", [lst(item(), full)]),
                page_network,
            ]),
        ])
        foot = dh - (40 if t else 62)
        device = frame("Device", dr, bg=PANEL, bg_t=0, visible=False, children=[
            aspect_of(dr), corner(0.03, 0),
            screen,
            label("BatteryText", d(dw - 170, foot + 4, 150, 30 if t else 44), color=TABLET_TEXT, align="Right"),
            button("Close", d(10 if t else 30, foot + 2, 110 if t else 160, 34 if t else 50), text="Fermer"),
        ])
        return [device]
    return two_layouts("TabletGui", "TabletController", build)


def document_gui():
    def build(t):
        B = screen_box(t)
        pr = B(60, 2, 630, 307) if t else B(320, 26, 640, 610)
        pw, ph = pr.px
        p = Box(pw, ph)
        if t:
            paper = [title("Title", p(12, 6, 500, 26)), button("Close", p(520, 6, 98, 28), text="Fermer"),
                     image("Picture", p(12, 40, 606, 104)), label("Body", p(12, 150, 606, 150), valign="Top")]
            tr = B(175, 196, 400, 100)
        else:
            paper = [title("Title", p(30, 22, 440, 44)), button("Close", p(480, 22, 130, 44), text="Fermer"),
                     image("Picture", p(30, 80, 580, 220)), label("Body", p(30, 314, 580, 270), valign="Top")]
            tr = B(390, 430, 500, 150)
        tw, th = tr.px
        q = Box(tw, th)
        tape = window("Tape", tr, children=[
            label("Label", q(12, 8, tw - 24, 28 if t else 44)),
            button("Play", q(12, 44 if t else 70, 80 if t else 110, 32 if t else 50), text="Lire"),
            bar("Progress", q(104 if t else 136, 58 if t else 92, tw - (116 if t else 148), 6)),
        ])
        return [veil("Paper", "Tape"), window("Paper", pr, children=paper), tape]
    return two_layouts("DocumentGui", "DocumentController", build)


def downed_gui():
    def build(t):
        B = screen_box(t)
        if t:
            return [title("Countdown", B(300, 96, 150, 50), align="Center", color=DANGER),
                    label("HelpHint", B(80, 154, 590, 24), align="Center",
                          text="Appelle à l'aide : un coéquipier peut te relever."),
                    bar("Bleed", B(225, 188, 300, 6), color=DANGER)]
        return [title("Countdown", B(540, 250, 200, 80), align="Center", color=DANGER),
                label("HelpHint", B(340, 340, 600, 40), align="Center",
                      text="Appelle à l'aide : un coéquipier peut te relever."),
                bar("Bleed", B(440, 392, 400, 10), color=DANGER)]
    return two_layouts("DownedGui", "DownedController", build, menu=True)


def spectator_gui():
    def build(t):
        B = screen_box(t)
        if t:
            return [title("Watching", B(200, 0, 350, 26), align="Center"),
                    button("Prev", B(0, 130, 110, 34), text="Précédent"),
                    button("Next", B(640, 130, 110, 34), text="Suivant"),
                    label("Note", B(100, 286, 550, 24), align="Center", color=TEXT2,
                          text="Tu es mort. Tu peux encore suivre ton groupe.")]
        return [title("Watching", B(390, 16, 500, 44), align="Center"),
                button("Prev", B(24, 300, 160, 50), text="Précédent"),
                button("Next", B(1096, 300, 160, 50), text="Suivant"),
                label("Note", B(340, 600, 600, 36), align="Center", color=TEXT2,
                      text="Tu es mort. Tu peux encore suivre ton groupe.")]
    return two_layouts("SpectatorGui", "SpectatorController", build, menu=True)


def radio_gui():
    def build(t):
        B = screen_box(t)
        if t:
            return [label("Channel", B(590, 20, 140, 20), align="Right"),
                    frame("Talking", B(736, 24, 12, 12), bg=POSITIVE, bg_t=0, children=[corner(0.5, 0)]),
                    frame("Static", B(590, 44, 158, 4), bg=TEXT2, bg_t=0.4)]
        return [label("Channel", B(1024, 58, 216, 28), align="Right"),
                frame("Talking", B(1242, 64, 14, 14), bg=POSITIVE, bg_t=0, children=[corner(0.5, 0)]),
                frame("Static", B(1024, 92, 232, 5), bg=TEXT2, bg_t=0.4)]
    return two_layouts("RadioGui", "RadioController", build, menu=True)


# 15.7 (3) : boutons tactiles en icônes au trait (Icon_Ctrl_<nom>, 13.5), sans mot ; au plus 6 visibles
# (InputController) ; LayoutOrder = priorité d'affichage (DÉFAUT).
MOBILE_BUTTONS = ["Interact", "Fire", "Aim", "Reload", "Sprint", "Crouch", "Prone", "LeanL", "LeanR", "Light",
                  "Tablet", "Ping"]


def mobile_controls_gui():
    B = PH
    cr = B(556, 92, 194, 128)
    cw, ch = cr.px
    c = Box(cw, ch)
    pad_x = (cw - 3 * TOUCH_MIN) / 2
    container = frame("Layout_Touch", cr, note="15.7 : écran tactile seulement ; 2 rangées de 3 boutons",
                      children=[layout_child("UIListLayout", SortOrder="LayoutOrder", FillDirection="Horizontal",
                                             Wraps=True, HorizontalAlignment="Right", VerticalAlignment="Top",
                                             Padding={"UDim": [round(pad_x / cw - 0.001, 4), 0]})])
    for i, name in enumerate(MOBILE_BUTTONS, start=1):
        props = {"Image": "", "ScaleType": "Fit", "BackgroundColor3": PANEL, "BackgroundTransparency": PANEL_T,
                 "BorderSizePixel": 0, "Visible": False, "LayoutOrder": i, "AutoButtonColor": True}
        props.update(rect(*c(0, 0, TOUCH_MIN, TOUCH_MIN)))
        el = El(name, "ImageButton", props, [corner(0.5, 0), stroke(), minsize(TOUCH_MIN, TOUCH_MIN)],
                note=f"Icon_Ctrl_{name} (13.5)")
        container.add(el)
    container.ref = PH
    return screen_gui("MobileControlsGui", "InputController", [container])


# --- 15.5 Les deux places --------------------------------------------------------------------

def cinematic_gui():
    bar_h = round((1 - SCREEN_ASPECT / 2.35) / 2, 4)  # bandes 2.35:1 (6.1) sur un écran 16:9
    return _hide_roots(screen_gui("CinematicGui", "CinematicController", [
        frame("BarTop", (0, 0, 1, bar_h), bg=BLACK, bg_t=0),
        frame("BarBottom", (0, 1 - bar_h, 1, bar_h), bg=BLACK, bg_t=0),
        label("Subtitle", (0.08, 0.7, 0.84, 0.16), align="Center", valign="Bottom"),
        button("Skip", (0.74, 0.895, 0.12, 0.09), text="Passer", children=[  # 6.1 : bouton « Passer »
            label("Votes", (1.05, 0, 0.55, 1), color=TEXT2),
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


def setting_row(setting_id, text, kind, options, order, t, width):
    # 15.7 (4) : au moins 36 px, une ligne de texte par libellé ; sur téléphone, libellé au-dessus des choix
    h = (62 if t else 46) if kind != "calibration" else (44 if t else 56)
    r = Box(width, h)
    row = frame(setting_id, (0, 0, 1, 0.1), order=order, note="lu par SettingsController")
    row.add(width_aspect(width / h), row_min())
    if kind == "calibration":
        row.add(
            frame("Symbol", r(8, 4, h - 8, h - 8), bg=hex_color("#121311"), bg_t=0, note="symbole de calibrage (17.2)"),
            label("Label", r(h + 8, 4, width - h - 16, h - 8), text=text, color=TEXT2, read=False),
        )
        return row
    if t:
        label_r, ctrl_r, value_r = r(8, 2, width - 16, 26), r(8, 32, width - 76, 28), r(width - 64, 32, 56, 28)
    else:
        label_r, ctrl_r, value_r = r(8, 6, width * 0.46, h - 12), r(width * 0.5, 7, width * 0.37, h - 14), \
            r(width * 0.89, 6, width * 0.1, h - 12)
    row.add(label("Label", label_r, text=text, read=False))
    cw, ch = (ctrl_r[2] * width, ctrl_r[3] * h)
    if kind == "slider":
        row.add(frame("Slider", ctrl_r, children=[
            frame("Track", Box(cw, ch)(0, ch * 0.35, cw, ch * 0.3), bg=TEXT2, bg_t=0.5, children=[fill()]),
        ]), label("Value", value_r, align="Right"))
    else:
        if t:
            ctrl_r = r(8, 32, width - 16, 28)
            cw = width - 16
        opts = frame("Options", ctrl_r, children=[list_layout(vertical=False, padding=0.02)])
        ow = round((1 - 0.02 * (len(options) - 1)) / len(options), 3)
        for i, (opt_id, opt_text) in enumerate(options, start=1):
            if opt_text is None:
                opts.add(button(opt_id, (0, 0, ow, 1), order=i, text=MISSING_OPTION[opt_id], defaut=True))
            else:
                opts.add(button(opt_id, (0, 0, ow, 1), order=i, text=opt_text))
        row.add(opts)
    return row


def settings_gui():
    def build(t):
        B = screen_box(t)
        wr = B(0, 0, 750, 311) if t else B(150, 30, 980, 600)
        ww, wh = wr.px
        w = Box(ww, wh)
        tab_h, foot_h = (30, 32) if t else (44, 50)
        tabs = frame("Tabs", w(6, 4, ww - 12, tab_h), children=[list_layout(vertical=False, padding=0.01)])
        pages_r = (6, tab_h + 8, ww - 12, wh - tab_h - foot_h - 20)
        pages = frame("Pages", w(*pages_r))
        page_w = pages_r[2] - 8
        for i, (page_id, page_text, rows) in enumerate(SETTINGS_PAGES, start=1):
            tabs.add(button(page_id, Box(ww - 12, tab_h)(0, 0, (ww - 12 - 3 * 0.01 * (ww - 12)) / 4, tab_h),
                            text=page_text, order=i))
            pg = scrolling(page_id, (0, 0, 1, 1), children=[list_layout(padding=0.01)])
            if i != 1:
                pg.props["Visible"] = False
            for j, (setting_id, text, kind, options) in enumerate(rows, start=1):
                row = setting_row(setting_id, text, kind, options, j, t, page_w)
                pg.add(row)
            pages.add(pg)
        fw = (ww - 12 - 2 * 8) / 3
        foot_y = wh - foot_h - 6
        return [veil("Window"), window("Window", wr, children=[
            tabs, pages,
            button("Apply", w(6, foot_y, fw, foot_h), text="Appliquer"),
            button("Reset", w(6 + fw + 8, foot_y, fw, foot_h), text="Réinitialiser"),
            button("Close", w(6 + 2 * (fw + 8), foot_y, fw, foot_h), text="Fermer"),
        ], visible=True)]
    gui = two_layouts("SettingsGui", "SettingsController", build, display_order=70)
    return gui


def notification_gui(place):
    # 15.7 : zone réservée par place, sans chevauchement ; 2 messages au plus (PlayerConfig.Interface)
    def build(t):
        B = screen_box(t)
        if place == "Partie":
            sr = B(140, 86, 410, 96) if t else B(540, 16, 460, 104)
        else:
            sr = B(0, 212, 470, 99) if t else B(794, 536, 448, 100)
        sw, sh = sr.px
        row_h = (sh - 4) / 2
        rb = Box(sw, row_h)
        item = template(frame("Template", Box(sw, sh)(0, 0, sw, row_h), bg=PANEL, bg_t=PANEL_T, children=[
            corner(),
            label("Text", rb(8, 2, sw - 16, row_h - 4), align="Center"),
        ]))
        return [frame("Stack", sr, children=[list_layout(padding=round(4 / sh, 4)), item])]
    return two_layouts("NotificationGui", "NotificationController", build, display_order=50)


def aspect_of(r):
    if getattr(r, "px", None):
        return layout_child("UIAspectRatioConstraint", AspectRatio=round(r.px[0] / r.px[1], 3))
    return aspect(r[2], r[3])


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


def creature_debug():
    # 9.13 : outil de test (Studio seulement), désactivé par défaut ; F8 l'affiche
    el = billboard("CreatureDebug", (0, 360, 0, 160), [0, 8, 0], [
        label("Info", (0, 0, 1, 1), align="Left", valign="Top"),
    ], "9.13 : texte écrit par AI/CreatureDebug ; F8 (CreatureDebugController)")
    el.props["Enabled"] = False
    el.props["MaxDistance"] = 300
    return el


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
    if getattr(el, "attributes", None):
        data["attributes"] = el.attributes
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




def width_aspect(ratio):
    # hauteur calculée depuis la largeur : indépendante de la hauteur du canevas défilant
    return layout_child("UIAspectRatioConstraint", AspectRatio=round(ratio, 3), AspectType="ScaleWithParentSize",
                        DominantAxis="Width")


def scroll_aspects(el, abs_w, abs_h):
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
            if el.props.get("ScrollingDirection") == "X":
                # défilement horizontal : la largeur suit la hauteur
                child.children.append(layout_child("UIAspectRatioConstraint", AspectRatio=round(cw / ch, 3),
                                                   AspectType="ScaleWithParentSize", DominantAxis="Height"))
            else:
                child.children.append(width_aspect(cw / ch))
        scroll_aspects(child, cw, ch)


def write_model(el, folder):
    # 15.7 : chaque disposition a sa zone de référence (PC 1280 × 662, téléphone 750 × 311)
    for child in el.children:
        ref = getattr(child, "ref", None)
        if ref is not None:
            sx = child.props.get("Size", udim2(1, 0, 1, 0))["UDim2"][0][0]
            sy = child.props.get("Size", udim2(1, 0, 1, 0))["UDim2"][1][0]
            scroll_aspects(child, ref.w * sx, ref.h * sy)
        else:
            scroll_aspects(child, PC.w, PC.h)
    center_constrained(el)
    os.makedirs(folder, exist_ok=True)
    path = os.path.join(folder, el.name + ".model.json")
    with open(path, "w", encoding="utf-8") as f:
        json.dump(to_json(el), f, ensure_ascii=False, indent=2)
        f.write("\n")


GUIS = {
    "Lobby": [dialogue_gui, museum_panel_gui, party_gui, build_role_select, weapon_board_gui, vote_gui,
              skin_shop_gui, records_gui, evidence_board_gui, results_gui, loading_gui,
              lambda: notification_gui("Lobby")],
    "Partie": [hud_gui, inventory_gui, objective_gui, interact_gui, tablet_gui, document_gui, downed_gui,
               spectator_gui, radio_gui, mobile_controls_gui, lambda: notification_gui("Partie")],
    "Common": [cinematic_gui, settings_gui],
}


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
    templates = [ping_marker(), name_tag(), creature_debug()]
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
