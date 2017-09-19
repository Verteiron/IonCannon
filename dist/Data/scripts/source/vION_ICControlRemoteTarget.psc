Scriptname vION_ICControlRemoteTarget extends ObjectReference
{Place the target core here.}

; === [ vION_ICControlRemoteTarget.psc ] ==========================================---
; Handles:
;   Placement of remote target meshes
;   Notifying IonCannonControl of what to do
; ========================================================---

;=== Imports ===--

Import Utility
Import Game

;=== Constants ===--

;=== Properties ===--

vION_IonCannonControlScript Property IonCannonControl 		Auto
{Master Ion Cannon control}

Actor 			Property PlayerREF							Auto

Hazard 			Property vION_ICTargetHazard				Auto
{Target location for this script}

;=== Variables ===--

ObjectReference _SpawnPoint

;=== Events ===--

Event OnLoad()
{Move to Hazard location and tell the IonCannonControl about me.}
	GotoState("Loaded")
	;SetAngle(0,0,GetAngleZ())
	DebugTrace("Placed!")
	
	; Int iSafety = 10
	; While !Is3dLoaded() && iSafety
	; 	iSafety -= 1
	; 	Wait(0.1)
	; EndWhile

	Int i = 0
	While !_SpawnPoint && i < 10
		_SpawnPoint = FindClosestReferenceOfTypeFromRef(vION_ICTargetHazard,Self,4096)
		i += 1
		Wait(0.1)
	EndWhile
	If !_SpawnPoint
		;DebugTrace("Couldn't find _SpawnPoint, aborting :(")
		;vION_ICTargetPlaced.Mod(-1)
		;Delete()
		;Return
		_SpawnPoint = Self
	EndIf
	MoveTo(_SpawnPoint)
	IonCannonControl.PlaceRemoteTarget(Self)
	RegisterForSingleUpdate(3)
EndEvent

Event OnUpdate()
	_SpawnPoint.Disable()
	_SpawnPoint.Delete()
	Delete()
EndEvent

State Loaded
	Event OnLoad()
		;Do nothing
	EndEvent
EndState
Function DebugTrace(String sDebugString, Int iSeverity = 0)
	Debug.Trace("vION/ICControlRemoteTarget: " + sDebugString,iSeverity)
EndFunction