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
{My target}

vION_IonCannonControlScript Property IonCannonControl Auto
{Master Ion Cannon control}

Int Property IndexNumber Auto Hidden

Float Property MaxRange Auto Hidden
Float Property TargetDistance Auto Hidden
Float Property Speed Auto Hidden

Float Property TargetX Auto Hidden
Float Property TargetY Auto Hidden

Bool Property LockingOn Auto Hidden
Bool Property LockedOn Auto Hidden

;=== Variables ===--

Float _fMaxRangle

;=== Events ===--


Event OnLoad()
	GotoState("")
EndEvent

Event OnTranslationAlmostComplete()
	IonCannonControl.TrackerBeamCasterTranslationUpdate(Self)
	
	If !LockingOn 
		If TargetDistance > 35
			StartSweep()
		EndIf
	ElseIf TargetDistance > 10
		StartLockOn()
	ElseIf !LockedOn
		LockedOn = True
		IonCannonControl.TrackerBeamCasterLockedOn(Self)
	EndIf

EndEvent

Event OnUpdate()
	StartSweep()
EndEvent

Function StartScanning(Float fMaxRange)
	DebugTrace("Starting scan!")
	LockingOn = False
	LockedOn = False
	MaxRange = fMaxRange
	If !parentTarget 
		parentTarget = GetLinkedRef()
	EndIf

	RegisterForSingleUpdate(0.1)
EndFunction

Function StartSweep()
	UpdateTargetDistance()
	SplineTranslateTo(TargetX + RandomFloat(-TargetDistance,TargetDistance), TargetY + RandomFloat(-TargetDistance,TargetDistance), IonCannonControl.tZ + 2000, 0, 0, (360 / 9 * indexNumber) - 90, RandomFloat(-1,1) * Speed / 2, Speed)
EndFunction

Function StartLockOn()
	DebugTrace("Locking on!")
	LockingOn = True
	UpdateTargetDistance()
	SplineTranslateTo(TargetX, TargetY, IonCannonControl.tZ + 2000, 0, 0, (360 / 9 * indexNumber) - 90, RandomFloat(-1,1) * Speed / 2, Speed)
EndFunction

Function UpdateTargetDistance()
	Float pCastX = GetPositionX()
	Float pCastY = GetPositionY()
	TargetX = parentTarget.GetPositionX()
	TargetY = parentTarget.GetPositionY()

	TargetDistance = Math.SqRt(((pCastX - TargetX) * (pCastX - TargetX)) + ((pCastY - TargetY) * (pCastY - TargetY)))
	;DebugTrace("Target distance is " + TargetDistance)

	Speed = TargetDistance ; / 1.5
	If Speed < 125
		Speed = 125
	EndIf
EndFunction

Function ShutDown()
	GotoState("Shutdown")
EndFunction

State Shutdown
	Event OnTranslationComplete()
		InterruptCast()
		;Disable(True)
		MoveToMyEditorLocation()
	EndEvent
	Event OnUpdate()
		;Do nothing
	EndEvent
EndState

Function DebugTrace(String sDebugString, Int iSeverity = 0)
	Debug.Trace("vION/ICTrackingBeamCaster" + indexNumber + ": " + sDebugString,iSeverity)
EndFunction