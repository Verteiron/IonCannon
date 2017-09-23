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
EndEvent


Function DebugTrace(String sDebugString, Int iSeverity = 0)
	Debug.Trace("vION/vION_ICRemoteTargetCastME: " + sDebugString,iSeverity)
EndFunction