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

vION_IonCannonControlScript Property IonCannonControl Auto
{Master Ion Cannon control}

;=== Variables ===--

;=== Events ===--

Event OnTranslationAlmostComplete()
	IonCannonControl.TrackerBeamCasterTranslationUpdate(Self)
EndEvent

Function StartScanning()
	
EndFunction