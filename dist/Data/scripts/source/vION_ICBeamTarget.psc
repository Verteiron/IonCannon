Scriptname vION_ICBeamTarget extends ObjectReference
{Acts as target of the beam, handles various effects.}

; === [ vION_ICBeamTarget.psc ] ==========================================---
; Handles:
;   Placement of tracking beams
;   Casting of the actual spell
; ========================================================---

;=== Imports ===--

Import Utility
Import Game

;=== Constants ===--


;=== Properties ===--

Actor 		Property PlayerRef						Auto
{The Player, duh.}

Activator 	Property vION_FXEmptyActivator			Auto
{An empty activator that's useful}

Activator 	Property vION_ICTrackingBeamTargetActivator	Auto
{Tracking beam caster activator}

;=== Variables ===--

vION_ICTrackingBeamTarget[] TrackingBeamTargets

Float pX
Float pY
Float pZ

;=== Events ===--

Event OnLoad()
{Place tracking beam casters}
	DebugTrace("Placed!")
	pX = GetPositionX()
	pY = GetPositionY()
	pZ = GetPositionZ()
	GoToState("Placed")
	TrackingBeamTargets	= New vION_ICTrackingBeamTarget[9]
	Int iCount = 0
	While iCount < 9
		TrackingBeamTargets[iCount] = PlaceAtMe(vION_ICTrackingBeamTargetActivator, abInitiallyDisabled = True) as vION_ICTrackingBeamTarget
		TrackingBeamTargets[iCount].indexNumber = iCount
		TrackingBeamTargets[iCount].parentTarget = Self
		Float MultX = Math.Cos((360.0 / 9) * iCount)
		Float MultY = -Math.Sin((360.0 / 9) * iCount)
		DebugTrace("Placing tracking beam " + iCount + " at x:" + (pX + (MultX * 100)) + ",y:" + (pY + (MultY * 100)) + "!")
		TrackingBeamTargets[iCount].SetPosition(pX + (MultX * 100), pY + (MultY * 100), pZ)
		TrackingBeamTargets[iCount].EnableNoWait()
		iCount += 1
	EndWhile

	iCount = 0
	Wait(0.1)
	While iCount < 9
		TrackingBeamTargets[iCount].startFiring()
		iCount += 1
	EndWhile
	RegisterForSingleUpdate(1)
EndEvent

Event OnUpdate()

	Int iLockCount = 0
	Int iCount = 0
	While(iCount < 9)
		If (TrackingBeamTargets[iCount].isLockedOn)
			iLockCount += 1
		EndIf
		iCount += 1
	EndWhile
	If (iLockCount == 9)
		GoToState("LockedOn")
	EndIf
	
	RegisterForSingleUpdate(0.5)

EndEvent

State Placed

	Event OnLoad()
		;Do nothing
	EndEvent

EndState

State LockedOn

	Event OnLoad()
		;Do nothing
	EndEvent

	Event OnUpdate()
		;Do nothing
	EndEvent

	Event OnBeginState()
		Int iCount = 0
		While(iCount < 9)
			TrackingBeamTargets[iCount].doShutdown()
			iCount += 1
		EndWhile
		Wait(3)
		DebugTrace("Deleting myself! :(")
		Delete()
	EndEvent

EndState

Function DebugTrace(String sDebugString, Int iSeverity = 0)
	Debug.Trace("vION/ICBeamTarget: " + sDebugString,iSeverity)
EndFunction