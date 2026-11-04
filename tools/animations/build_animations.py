#!/usr/bin/env python3
"""Section 14 : crée les objets Animation vides, nommés ANIM_<Squelette>_<Action>, en fichiers Rojo
(src/shared/Animations/<Squelette>/). Gabriel colle ensuite les identifiants (AnimationId) dans Studio.
Usage : python3 tools/animations/build_animations.py
"""
import json
import os

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
OUT = os.path.join(ROOT, "src", "shared", "Animations")

# 14.1 : joueurs (ANIM_Player_*)
PLAYER = [
    "Idle", "Walk", "Run", "CrouchIdle", "CrouchWalk", "ProneIdle", "ProneCrawl", "Jump", "Land", "LimpWalk",
    "LeanLeft", "LeanRight", "CarryWalk", "CarryRun", "Carried", "DownedIdle", "DownedCrawl", "ReviveGive",
    "ReviveReceive", "Bandage", "Splint", "Medkit", "Barricade", "RepairStanding", "RepairKneel", "Pickup", "Throw",
    "CarryHeavy", "FlashlightHold", "TabletHold", "CamcorderHold", "Rifle_Idle", "Rifle_Aim", "Rifle_Fire",
    "Rifle_Bolt", "Rifle_LoadRound", "Revolver_Idle", "Revolver_Aim", "Revolver_Fire", "Revolver_LoadRound",
    "Shotgun_Idle", "Shotgun_Aim", "Shotgun_Fire", "Shotgun_Pump", "Shotgun_LoadShell", "FlareGun_Fire",
    "FlareGun_Reload", "Axe_Swing", "Machete_Swing", "BearSpray_Use", "Flare_Light", "Grabbed_Struggle", "Dragged",
    "Scream", "FearTremble", "Van_Seated",
]
# 14.2 : créature (ANIM_Creature_*)
CREATURE = [
    "IdleStand", "IdleCrouch", "PeekTreeLeft", "PeekTreeRight", "LookAround", "Sniff", "Sneak", "Walk", "RunBiped",
    "SprintQuad", "TurnLeft", "TurnRight", "ClimbUp", "ClimbDown", "WoodKnock", "Call", "GrowlClose", "BranchBreak",
    "ChestBeat", "ChargeStart", "ChargeStopBluff", "PickStone", "ThrowOverhand", "ThrowUnderhand", "StrikeLeft",
    "StrikeRight", "Grab", "HoldStruggle", "DragWalk", "Slam", "ReachThrough", "Execution", "HitLight", "HitHeavy",
    "Blinded", "RetreatLimp", "FeedCrouch", "StackStones", "MimicCall", "CarryBones", "DeathFall",
]


def main():
    for rig, names in (("Player", PLAYER), ("Creature", CREATURE)):
        folder = os.path.join(OUT, rig)
        os.makedirs(folder, exist_ok=True)
        for name in names:
            path = os.path.join(folder, f"ANIM_{rig}_{name}.model.json")
            with open(path, "w", encoding="utf-8") as f:
                json.dump({"className": "Animation", "properties": {"AnimationId": ""}}, f, indent=2)
                f.write("\n")
    print(f"{len(PLAYER)} animations joueur, {len(CREATURE)} animations créature")


if __name__ == "__main__":
    main()
