Scriptname vION_ICRemoteTargetCastME extends ActiveMagicEffect
{Acts as player-activated target of the beam.}

; === [ vION_ICRemoteTargetCastME.psc ] ==========================================---
; Handles:
;   Placing the remote target activator at the target point
; ========================================================---

;=== Imports ===--

Import Utility
Import Game

;=== Constants ===--

;=== Properties ===--

Actor 			Property PlayerREF							Auto

vION_IonCannonControlScript Property IonCannonControl 		Auto
{Master Ion Cannon control}

Activator 		Property vION_ICTargetSpinnerActivator		Auto
{The current target core that we're activating}

Hazard 			Property vION_ICTargetHazard				Auto
{Target location for this script}

GlobalVariable 	Property vION_ICTargetPlaced 				Auto
{Whether the target is palced}

Spell 			Property vION_ICRemoteTargetSpell			Auto
Spell 			Property vION_ICRemoteTargetActivateSpell	Auto

;=== Variables ===--

ObjectReference _TargetPoint

;=== Events ===--

Event OnEffectStart(Actor akTarget, Actor akCaster)
	DebugTrace("Activating remote target!")
	IonCannonControl.ActivateRemoteTarget()
	; _TargetPoint = FindClosestReferenceOfTypeFromRef(vION_ICTargetSpinnerActivator,akCaster,8192)
	; If _TargetPoint
	; 	DebugTrace("Activating " + _TargetPoint)
	; 	(_TargetPoint as vION_ICBeamRemoteTarget).GoSplodey()
	; Else
	; 	DebugTrace("Targetpoint not found! That's bad...")
	; 	If (vION_ICTargetPlaced.GetValue())
	; 		vION_ICTargetPlaced.SetValue(0)
	; 		Int i = 0
	; 		While (i < 2)
	; 			If PlayerREF.GetEquippedSpell(i) == vION_ICRemoteTargetActivateSpell
	; 				PlayerREF.EquipSpell(vION_ICRemoteTargetSpell, i)
	; 			EndIf
	; 			i += 1
	; 		EndWhile
	; 		PlayerRef.RemoveSpell(vION_ICRemoteTargetActivateSpell)
	; 		If !PlayerRef.HasSpell(vION_ICRemoteTargetSpell)
	; 			PlayerRef.AddSpell(vION_ICRemoteTargetSpell, False)
	; 		EndIf
	; 	EndIf
	; EndIf
EndEvent


Function DebugTrace(String sDebugString, Int iSeverity = 0)
	Debug.Trace("vION/vION_ICRemoteTargetCastME: " + sDebugString,iSeverity)
EndFunction