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

Float 		Property ScanDelaySecs = 1.0			Auto
{How long before lock-on - 0 to fire immediately}
Float 		Property ScanBeamRadius = 400.0			Auto
{How far the beams wander during scan phase}

;=== Variables ===--

;=== Events ===--

Event OnLoad()
{Tell Ion Cannon Control there's a new target in town!}
	GotoState("Loaded")
	SetAngle(0,0,GetAngleZ())
	DebugTrace("Placed!")
	If IonCannonControl.Busy
		Debug.Notification("Ion Cannon is busy " + IonCannonControl.Status + "!")
		RegisterForSingleUpdate(1)
		Return
	EndIf
	Int iSafety = 10
	While !Is3dLoaded() && iSafety
		iSafety -= 1
		Wait(0.1)
	EndWhile
	IonCannonControl.SetTarget(Self)
	If ScanDelaySecs
		IonCannonControl.ScanForTarget(ScanBeamRadius)
		Wait(ScanDelaySecs)
		IonCannonControl.LockOnTarget()
	Else
		IonCannonControl.Firebeam()
	EndIf
	RegisterForSingleUpdate(10)
EndEvent

Event OnUpdate()
	Delete()
EndEvent

State Loaded
	Event OnLoad()
		;Do nothing
	EndEvent
EndState

Function DebugTrace(String sDebugString, Int iSeverity = 0)
	Debug.Trace("vION/ICControlTarget: " + sDebugString,iSeverity)
EndFunction