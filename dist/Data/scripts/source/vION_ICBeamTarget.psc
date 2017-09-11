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

Activator 	Property vION_ICBeamRingActivator		Auto
{SFX}

Activator 	Property vION_ICBeamCoreActivator		Auto
{SFX}

Activator 	Property vION_ICBeamFXActivator 		Auto
{SFX}

Activator 	Property vION_ICBeamLeaderActivator		Auto
{SFX}

Explosion 	Property vION_RingBlastExplosion		Auto
{SFX}

Activator 	Property vION_GlowActivator 			Auto
{Bright glow effect}

Activator	Property vION_ICRisingSparks1Activator 	Auto
{Central beam sparks mesh}

Spell 		Property vION_ICBeamBlastSpell 			Auto
{Blast spell 1}

Spell 		Property vION_ICFlingActorsSpell		Auto
{Blast spell 2}

Sound 		Property vION_BlastSM					Auto
{Ion cannon blast sound}

Explosion 	Property vION_SubBlastExplosion			Auto
{Oval-shaped shockwave}

Explosion 	Property fakeForceBall1024				Auto
{Blast to push actors}

Explosion 	Property vION_AfterglowSparksExplosion	Auto
{Lingering sparkles}

;=== Variables ===--

vION_ICTrackingBeamTarget[] TrackingBeamTargets

Float pX
Float pY
Float pZ


ObjectReference kSoundObj
ObjectReference kSparksObj

ObjectReference kBeamSparks
ObjectReference kGlow

ObjectReference[] kBlastRings

ObjectReference kSparkZap

;=== Events ===--

Event OnLoad()
{Place tracking beam casters}
	DebugTrace("Placed!")
	pX = GetPositionX()
	pY = GetPositionY()
	pZ = GetPositionZ()
	GoToState("Placed")
	SetAngle(0,0,GetAngleZ())
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
	kBeamSparks = PlaceAtMe(vION_ICRisingSparks1Activator, abInitiallyDisabled = True)

	kBeamSparks.MoveTo(kBeamSparks,0,0,128)
	kBeamSparks.SetAngle(0,0,0)
	kBeamSparks.SetScale(3)
	kBeamSparks.EnableNoWait(True)

	kSoundObj = PlaceAtMe(vION_FXEmptyActivator)
	
	kSparksObj = PlaceAtMe(vION_FXEmptyActivator)
	kSparksObj.MoveTo(Self,0,0,-8)
	kSparksObj.SetAngle(0,0,RandomInt(0,359))
	;kSparksObj.SetScale(4)
	
	kBeamSparks.SetAnimationVariableFloat("fmagicburnamount",0.1)
	
	kBlastRings = New ObjectReference[64]
	Int i = 0
	While(i < kBlastRings.Length)
		kBlastRings[i] = PlaceAtMe(vION_ICBeamRingActivator,abInitiallyDisabled = True)
		kBlastRings[i].MoveTo(Self,0,0,i * 500 + (RandomFloat(-200,200)))
		If RandomInt(0,4) <= 1
			kBlastRings[i].Delete()
			kBlastRings[i] = None
		Else
			kBlastRings[i].SetScale(RandomFloat(0.85,1.0))
			kBlastRings[i].SetAngle(RandomInt(-5,5),RandomInt(-5,5),RandomInt(0,359))
		EndIf 
		i += 1
	EndWhile
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
		
		kSparkZap = PlaceAtMe(vION_ICBeamFXActivator,abInitiallyDisabled = True)
		kSparkZap.SetAngle(-90,0,0)
		kSparkZap.SetScale(6)

		vION_BlastSM.Play(kSoundObj)
		Wait(1)
		kGlow.EnableNoWait(True)


		kSparkZap.EnableNoWait(True)
		ObjectReference kBeamCore = PlaceAtMe(vION_ICBeamCoreActivator,abInitiallyDisabled = True)
		kBeamCore.MoveTo(Self,0,0,10000)
		kBeamCore.EnableNoWait()
		While !kBeamCore.Is3dLoaded()
			Wait(0.1)
		EndWhile
		kBeamCore.TranslateTo(pX,pY,pZ - 25000,0,0,359,15000)
		iCount = kBlastRings.Length
		While(iCount)
			iCount -= 1
			If kBlastRings[iCount]
				kBlastRings[iCount].EnableNoWait(False)
			EndIf
		EndWhile
		PlaceAtMe(vION_SubBlastExplosion)		
		Wait(0.5)
		vION_ICFlingActorsSpell.Cast(Self)
		Wait(0.25)
		vION_ICBeamBlastSpell.RemoteCast(Self,PlayerRef)
		kGlow.SetScale(2)
		kSparksObj.PlaceAtMe(vION_AfterglowSparksExplosion)
		kBeamSparks.SetAnimationVariableFloat("fmagicburnamount",0.1)
		Wait(0.25)
		kSparkZap.DisableNoWait(True)
		Wait(1.75)
		kGlow.DisableNoWait(True)
		Wait(1)
		kBeamSparks.SetAnimationVariableFloat("fmagicburnamount",0.0)
		Wait(2)
		kBeamCore.StopTranslation()
		kBeamCore.Delete()
		kSparkZap.Delete()
		kBeamSparks.Disable(True)
		kBeamSparks.Delete()

		;Wait a bit longer to avoid cutting off the soundfx
		Wait(3)
		kSoundObj.Delete()
		kSparksObj.Delete()
		kGlow.Delete()
		DebugTrace("Deleting myself! :(")
		Delete()
	EndEvent

EndState

Function DebugTrace(String sDebugString, Int iSeverity = 0)
	Debug.Trace("vION/ICBeamTarget: " + sDebugString,iSeverity)
EndFunction