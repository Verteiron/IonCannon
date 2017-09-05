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

Activator 	Property vION_GlowActivator 			Auto
{Bright glow effect}

Form 		Property MGMagicFirePillarSmall 		Auto
{Central beam attractor mesh}

Spell 		Property vION_ICBeamBlastSpell 			Auto
{Blast spell 1}

Spell 		Property vION_ICFlingActorsSpell		Auto
{Blast spell 2}

Explosion 	Property fakeForceBall1024				Auto
{Blast to push actors}

;=== Variables ===--

vION_ICTrackingBeamTarget[] TrackingBeamTargets

Float pX
Float pY
Float pZ


ObjectReference kBeamSparks
ObjectReference kGlow

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
		TrackingBeamTargets[iCount].placeCaster()
		iCount += 1
	EndWhile

	iCount = 0
	Wait(0.1)
	While iCount < 9
		TrackingBeamTargets[iCount].startFiring()
		iCount += 1
	EndWhile
	RegisterForSingleUpdate(1)
	kBeamSparks = PlaceAtMe(MGMagicFirePillarSmall, abInitiallyDisabled = True)
	kBeamSparks.MoveTo(kBeamSparks,0,0,256)
	kBeamSparks.SetAngle(0,0,0)
	kBeamSparks.SetScale(2)
	kBeamSparks.EnableNoWait(True)
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
	kBeamSparks.SetAnimationVariableFloat("fmagicburnamount",(iLockCount as Float) / 9.0)
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
		kGlow = PlaceAtMe(vION_GlowActivator,abInitiallyDisabled = True)
		kGlow.SetScale(2)
		Wait(1)
		kGlow.EnableNoWait(True)
		Wait(1)
		vION_ICFlingActorsSpell.Cast(Self)
		Wait(0.25)
		vION_ICBeamBlastSpell.RemoteCast(Self,PlayerRef)
		kGlow.DisableNoWait(True)
		kBeamSparks.Disable(True)
		kBeamSparks.Delete()
		kGlow.Delete()
		DebugTrace("Deleting myself! :(")
		Delete()
	EndEvent

EndState

Function DebugTrace(String sDebugString, Int iSeverity = 0)
	Debug.Trace("vION/ICBeamTarget: " + sDebugString,iSeverity)
EndFunction