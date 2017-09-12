Scriptname vION_ICTrackingBeamCaster extends ObjectReference
{Lets the parent Target know when we're done translating}

; === [ vION_ICTrackingBeamCaster.psc ] ==========================================---
; Handles:
;   Updating the parent target with our events
; ========================================================---

;=== Imports ===--

Import Utility
Import Game

;=== Constants ===--


;=== Properties ===--

ObjectReference 	Property parentTarget		Auto
{The target that spawned me}

;=== Variables ===--

;=== Events ===--

Event OnTranslationAlmostComplete()
	parentTarget.OnTranslationAlmostComplete()
EndEvent

Event OnCellDetach()
	StopTranslation()
	Delete()
EndEvent