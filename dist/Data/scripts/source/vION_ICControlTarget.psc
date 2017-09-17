Scriptname vION_ICControlTarget extends ObjectReference
{Uses the IonCannonControl to fire a blast at this location.}

; === [ vION_ICControlTarget.psc ] ==========================================---
; Handles:
;   Calling IonCannonControl to fire a blast at this location.
; ========================================================---

;=== Imports ===--

Import Utility
Import Game

;=== Constants ===--


;=== Properties ===--

Actor 		Property PlayerRef						Auto
{The Player, duh.}

vION_IonCannonControlScript Property IonCannonControl Auto
{Master Ion Cannon control}

;=== Variables ===--

;=== Events ===--

Function DebugTrace(String sDebugString, Int iSeverity = 0)
	Debug.Trace("vION/ICControlTarget: " + sDebugString,iSeverity)
EndFunction