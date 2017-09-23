Scriptname vION_PushActorBlastScript extends ActiveMagicEffect  
{Pushes actors away based on radius.}

; === [ vION_PushActorBlastScript.psc ] =====================================---
; Pushes actors away based on radius.
; ========================================================---

Import Game
Import Utility

;=== Properties ===--

Actor 			Property PlayerREF						Auto

Float 			Property AreaOfEffect 					Auto
Int 			Property PushForce 						Auto

FormList 		Property vION_ICTargetList				Auto

ObjectReference Property PushSource						Auto

;=== Variables ===--

Actor 			kTarget
Actor 			kCaster

;=== Events ===--

Event OnEffectStart(Actor akTarget, Actor akCaster)
	kTarget = akTarget
	kCaster = akCaster
	PushSource = FindClosestReferenceOfAnyTypeInListFromRef(vION_ICTargetList,akTarget,AreaOfEffect * 21.333333)
	;Debug.Trace(self + ": kTarget is " + kTarget + ", kCaster is " + kCaster + ", PushSource is " + PushSource + ".")
	If kTarget == PlayerREF
		Return
	EndIf
	If !AreaOfEffect 
		AreaOfEffect = 15.0
	EndIf

	Float fRadius = AreaOfEffect ; / 2
	fRadius = fRadius * 21.33333 ; Convert Feet to Units

	Float fDistance = kTarget.GetDistance(PushSource)

	If fDistance < fRadius
		Float fPushMag = ((fRadius - fDistance) / fRadius) * PushForce
		;Debug.Trace(self + ": Blast Radius is " + fRadius + ". Distance to target" + kTarget + " is " + fDistance + ". Applying PushMag " + fPushMag + ".")
		PushSource.PushActorAway(kTarget, fPushMag)
	Else
		;Debug.Trace(self + ": Blast Radius is " + fRadius + ". Distance to target" + kTarget + " is " + fDistance + ". No force applied.")
	EndIf
EndEvent

