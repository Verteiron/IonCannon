Scriptname vION_ICBeamRing extends ObjectReference
{Ring special FX}

; === [ vION_ICBeamRing.psc ] ==========================================---
; Handles:
;   Automatic self-deletion
; ========================================================---

;=== Imports ===--

Import Utility
Import Game

;=== Constants ===--


;=== Properties ===--

;=== Variables ===--

;=== Events ===--

Event OnLoad()
	GoToState("Placed")
	DebugTrace("Placed beamring!")
EndEvent

State Placed

	Event OnBeginState()
		RegisterForSingleUpdate(2.75)
	EndEvent

	Event OnUpdate()
		Disable(True)
		;DebugTrace("Deleting myself :(")
		Delete()
	EndEvent

	Event onLoad()
		;Do nothing
	EndEvent
EndState

Function DebugTrace(String sDebugString, Int iSeverity = 0)
	Debug.Trace("vION/ICBeamRing: " + sDebugString,iSeverity)
EndFunction