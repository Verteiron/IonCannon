Scriptname vION_ICTrackingBeamTarget extends ObjectReference
{Placement of Ion Cannon tracking beam caster}

; === [ vION_ICTrackingBeamTarget.psc ] ==========================================---
; Handles:
;   Placement and movement of Ion Cannon tracking beam caster
; ========================================================---

;=== Imports ===--

Import Utility
Import Game

;=== Constants ===--


;=== Properties ===--

Actor 		Property PlayerRef					Auto
{The Player, duh.}

Activator 	Property vION_FXEmptyActivator		Auto
{An empty activator that's useful}

Activator 	Property vION_ICTrackingBeamCasterActivator		Auto
{An activator to cast from.}

Objectreference 	Property 	parentTarget 	Auto
{The parent target of this tracking beam target}

Spell		Property vION_ICTrackerBeam1Spell	Auto
{The beam spell/effect.}

Bool 		Property isCasting = False			Auto

Bool 		Property isLockedOn = False			Auto

Int 		Property indexNumber 				Auto

Float 		Property wanderRadius = 800.0		Auto

Float 		Property casterHeight = 2000.0		Auto

;=== Variables ===--

vION_ICTrackingBeamCaster 	kCaster

Float pX
Float pY
Float pZ

Float pCastX
Float pCastY
Float pCastZ

;=== Events ===--

Event OnLoad()
	DebugTrace("Placed!")
	GoToState("Placed")
	
EndEvent

Event OnUpdate()
	If wanderRadius > 30
		wanderRadius /= Randomfloat(1.3,1.6)
		DebugTrace("wanderRadius is now " + wanderRadius)
	Else
		DebugTrace("wanderRadius is <= 30, shutting down...")
		GoToState("StopMoving")
	EndIf
	randomMove()
	RegisterForSingleUpdate(1)
EndEvent

Event OnTranslationAlmostComplete()
	UnregisterForUpdate()
	OnUpdate()
EndEvent

Function startFiring()
{Start updates}
	DebugTrace("startFiring!")

	;Get my position, which should be the final target of the tracking beam
	pX = GetPositionX()
	pY = GetPositionY()
	pZ = GetPositionZ()

	;Move to a random position, some radial distance from the final target
	Float MultX = Math.Cos((360.0 / 9) * indexNumber)
	Float MultY = -Math.Sin((360.0 / 9) * indexNumber)
	pCastX = pX + (MultX * wanderRadius) + RandomFloat(-wanderRadius / 2, wanderRadius / 2)
	pCastY = pY + (MultY * wanderRadius) + RandomFloat(-wanderRadius / 2, wanderRadius / 2)
	SetPosition(pCastX, pCastY, pZ)

	;Place the caster
	kCaster = PlaceAtMe(vION_ICTrackingBeamCasterActivator, abInitiallyDisabled = True) as vION_ICTrackingBeamCaster
	kCaster.parentTarget = Self
	kCaster.MoveTo(Self, 0, 0, casterHeight)
	kCaster.Enable(0)

	;Start casting
	DebugTrace("Casting!")
	isCasting = true
	vION_ICTrackerBeam1Spell.RemoteCast(kCaster,PlayerRef,Self)

	RegisterForSingleUpdate(0.5 + RandomFloat(0,2))
	SetPosition(pX, pY, pZ)
EndFunction

Function randomMove()
	pCastX = pX + RandomFloat(-wanderRadius,wanderRadius)
	pCastY = pY + RandomFloat(-wanderRadius,wanderRadius)
	;DebugTrace("Translating to " + pCastX + "," + pCastY)
	Float fSpeed = wanderRadius / 1.5
	If fSpeed < 100
		fSpeed = 100
	EndIf
	kCaster.SplineTranslateTo(pCastX, pCastY, kCaster.GetPositionZ(), 0, 0, RandomFloat(0,359), fSpeed, fSpeed)
EndFunction

Function doShutDown()
	GoToState("Shutdown")
EndFunction

Event OnUnload()
	;Do nothing	
EndEvent

State Placed

	Event OnLoad()
		;Do nothing
	EndEvent

EndState

State StopMoving

	Event OnBeginState()
		RegisterForsingleUpdate(0.1)
	EndEvent

	Event OnUpdate()
		kCaster.TranslateTo(pX, pY, pZ + casterHeight, 0, 0, 0, 250)
		isLockedOn = True
	EndEvent

	Event OnLoad()
		;Do nothing
	EndEvent

	Event OnTranslationAlmostComplete()
		If (!isLockedOn)
			OnUpdate()
		EndIf
		;Do nothing
	EndEvent

EndState

State Shutdown

	Event OnBeginState()
		RegisterForsingleUpdate(1)
	EndEvent

	Event OnUpdate()
		DebugTrace("Translating to final position...")
		kCaster.TranslateTo(parentTarget.GetPositionX(), parentTarget.GetPositionY(), parentTarget.GetPositionZ() + casterHeight,0,0,0,100)
	EndEvent

	Event OnLoad()
		;Do nothing
	EndEvent

	Event OnTranslationAlmostComplete()
		kCaster.StopTranslation()
		kCaster.InterruptCast()
		DebugTrace("Deleting the caster! :(")
		kCaster.Delete()
		DebugTrace("Deleting myself! :(")
		Delete()
	EndEvent

EndState

Function DebugTrace(String sDebugString, Int iSeverity = 0)
	Debug.Trace("vION/ICTrackingBeamCaster" + indexNumber + ": " + sDebugString,iSeverity)
EndFunction