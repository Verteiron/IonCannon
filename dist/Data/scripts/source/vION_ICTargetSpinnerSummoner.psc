Scriptname vION_ICTargetSpinnerSummoner extends ObjectReference
{Place the target core here.}

; === [ vION_ICTargetSpinnerSummoner.psc ] ==========================================---
; Handles:
;   Placing the actual beam summoner
; ========================================================---

;=== Imports ===--

Import Utility
Import Game

;=== Constants ===--

;=== Properties ===--

Actor 			Property PlayerREF							Auto

ObjectReference	Property vION_TargetSpinner			 		Auto
{Remote target mesh}

;=== Variables ===--

;=== Events ===--

Event OnLoad()
	DebugTrace("A thing happened!")
	vION_TargetSpinner.MoveTo(Self)
	Delete()
EndEvent

Function DebugTrace(String sDebugString, Int iSeverity = 0)
	Debug.Trace("vION/vION_ICTargetSpinnerSummoner(" + Self + "): " + sDebugString,iSeverity)
EndFunction