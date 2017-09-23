Scriptname vION_DeleteOnUnload extends ObjectReference
{Last-ditch safety to prevent save bloat}

; === [ vION_DeleteOnUnload.psc ] ==========================================---
; Handles:
;   Making absolutely certain the parent object is removed
; ========================================================---

;=== Imports ===--

Import Utility
Import Game

;=== Constants ===--

;=== Properties ===--

Float 	Property SecsToUnload Auto
{Unload after this many seconds.}

;=== Variables ===--

;=== Events ===--

Event OnLoad()
	If (SecsToUnload)
		RegisterForSingleUpdate(SecsToUnload)
	EndIf
EndEvent

Event OnUpdate()
	DebugTrace("Deleting: timer expired!")
	Disable()
	Delete()
EndEvent

Event OnCellDetach()
	UnregisterForUpdate()
	DebugTrace("Deleting: cell detached!")
	Delete()
EndEvent

Function DebugTrace(String sDebugString, Int iSeverity = 0)
	Debug.Trace("vION/" + Self + ": " + sDebugString,iSeverity)
EndFunction