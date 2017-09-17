Scriptname vION_IonCannonControlScript extends Quest
{Control basic Ion Cannon functions.}

;=== Imports ===--

Import Utility
Import Game

;=== Properties ===--

Actor 				Property PlayerRef 					Auto

ReferenceAlias 		Property alias_BeamCore 			Auto
ReferenceAlias 		Property alias_BeamFX	 			Auto
ReferenceAlias 		Property alias_RisingSparks 		Auto
ReferenceAlias 		Property alias_TargetGlow	 		Auto

ReferenceAlias[] 	Property alias_TrackerBeamTargets 	Auto
ReferenceAlias[] 	Property alias_TrackerBeamCasters 	Auto
ReferenceAlias[] 	Property alias_BeamRings 			Auto			

ReferenceAlias 		Property alias_RemoteTargetFrame 	Auto
ReferenceAlias 		Property alias_RemoteCoreWaiting 	Auto
ReferenceAlias 		Property alias_RemoteCoreActivated 	Auto

Spell 				Property vION_ICTrackerBeam1Spell	Auto

ObjectReference 	Property BeamCore 					Auto Hidden
ObjectReference 	Property BeamFX 					Auto Hidden
ObjectReference 	Property RisingSparks				Auto Hidden
ObjectReference 	Property TargetGlow					Auto Hidden
ObjectReference 	Property RemoteTargetFrame			Auto Hidden
ObjectReference 	Property RemoteCoreWaiting			Auto Hidden
ObjectReference 	Property RemoteCoreActivated 		Auto Hidden
ObjectReference[] 	Property TrackerBeamTargets 		Auto Hidden
ObjectReference[] 	Property TrackerBeamCasters 		Auto Hidden
ObjectReference[] 	Property BeamRings 					Auto Hidden

ObjectReference 	Property Target						Auto Hidden

Float 				Property tX							Auto Hidden
Float 				Property tY							Auto Hidden
Float 				Property tZ							Auto Hidden
Float 				Property tHeading					Auto Hidden


;=== Config variables ===--

;=== Variables ===--

;=== Events ===--

Event OnInit()
	DebugTrace("OnInit! IsRunning: " + IsRunning())
	If IsRunning()
		ListRefs()
		AssignRefs()
	EndIf
EndEvent


Function ListRefs()
	DebugTrace("alias_BeamCore:     " + alias_BeamCore + " - " + alias_BeamCore.GetReference())
	DebugTrace("alias_RisingSparks: " + alias_RisingSparks + " - " + alias_RisingSparks.GetReference())
	DebugTrace("alias_RemoteTargetFrame: " + alias_RemoteTargetFrame + " - " + alias_RemoteTargetFrame.GetReference())
	DebugTrace("alias_RemoteCoreWaiting: " + alias_RemoteCoreWaiting + " - " + alias_RemoteCoreWaiting.GetReference())
	DebugTrace("alias_RemoteCoreActivated: " + alias_RemoteCoreActivated + " - " + alias_RemoteCoreActivated.GetReference())
	DebugTrace("alias_TargetGlow: " + alias_TargetGlow + " - " + alias_TargetGlow.GetReference())

	Int i = 0	
	While i < alias_TrackerBeamTargets.Length
		DebugTrace("alias_TrackerBeamTargets[" + i + "]: " + alias_TrackerBeamTargets[i] + " - " + alias_TrackerBeamTargets[i].GetReference())
		i += 1
	EndWhile
	i = 0
	While i < alias_TrackerBeamCasters.Length
		DebugTrace("alias_TrackerBeamCasters[" + i + "]: " + alias_TrackerBeamCasters[i] + " - " + alias_TrackerBeamCasters[i].GetReference())
		i += 1
	EndWhile
	i = 0
	While i < alias_BeamRings.Length
		DebugTrace("alias_BeamRings[" + i + "]: " + alias_BeamRings[i] + " - " + alias_BeamRings[i].GetReference())
		i += 1
	EndWhile

EndFunction

Function AssignRefs()
	BeamCore = alias_BeamCore.GetReference()
	RisingSparks = alias_RisingSparks.GetReference()
	TargetGlow	 = alias_TargetGlow	.GetReference()
	RemoteTargetFrame = alias_RemoteTargetFrame.GetReference()
	RemoteCoreWaiting = alias_RemoteCoreWaiting.GetReference()
	RemoteCoreActivated = alias_RemoteCoreActivated.GetReference()

	Int i = 0	
	While i < alias_TrackerBeamTargets.Length
		TrackerBeamTargets[i] = alias_TrackerBeamTargets[i].GetReference()
		i += 1
	EndWhile
	i = 0	
	While i < alias_TrackerBeamCasters.Length
		TrackerBeamCasters[i] = alias_TrackerBeamCasters[i].GetReference()
		i += 1
	EndWhile
	i = 0	
	While i < alias_BeamRings.Length
		BeamRings[i] = alias_BeamRings[i].GetReference()
		i += 1
	EndWhile
EndFunction

Function SetTarget(ObjectReference kTarget)
{Set the current target property and prep some information about it.}
	Target = kTarget
	tX = Target.GetPositionX()
	tY = Target.GetPositionY()
	tZ = Target.GetPositionZ()
	tHeading = Target.GetAngleZ()
	DebugTrace("Target is now " + Target + ". Position x:" + tX +", y:" + tY + ", z:" + tZ + ", Heading:" + tHeading)
EndFunction

Function ScanForTarget(Float fMaxRange)
{Spawn the tracking beams and begin scanning for the target.}
	Int iCount = 0
	While iCount < 9
		TrackerBeamCasters[iCount].DisableNoWait()
		TrackerBeamCasters[iCount].MoveTo(Target)

		Float MultX = Math.Cos((360.0 / 9) * iCount)
		Float MultY = -Math.Sin((360.0 / 9) * iCount)
		
		DebugTrace("Placing tracking beam caster " + iCount + " at x:" + (tX + (MultX * fMaxRange)) + ",y:" + (tY + (MultY * fMaxRange)) + "!")
		TrackerBeamCasters[iCount].MoveTo(Target,(MultX * fMaxRange) + RandomFloat(-fMaxRange/2,fMaxRange/2), (MultY * fMaxRange) + RandomFloat(-fMaxRange/2,fMaxRange/2), 2000)
		TrackerBeamTargets[iCount].MoveTo(TrackerBeamCasters[iCount],0,0,-2000)
		iCount += 1
	EndWhile

	iCount = 0
	While iCount < 9
		TrackerBeamCasters[iCount].EnableNoWait(True)
		iCount += 1
	EndWhile

	iCount = 0
	Wait(0.1)
	While iCount < 9
		TrackerBeamCasters[iCount].EnableNoWait(True)
		vION_ICTrackerBeam1Spell.RemoteCast(TrackerBeamCasters[iCount],PlayerRef,TrackerBeamTargets[iCount])
		iCount += 1
	EndWhile

	iCount = 0
	Wait(0.1)
	While iCount < 9
		TrackerBeamCasters[iCount].EnableNoWait(True)
		iCount += 1
	EndWhile
EndFunction

Event TrackerBeamCasterTranslationUpdate(ObjectReference kCaster)

EndEvent

Function LockOnTarget()
{Stop the beams random movement and send them to the lock-on location.}
	
EndFunction

Function DebugTrace(String sDebugString, Int iSeverity = 0)
	Debug.Trace("vION/ICControl: " + sDebugString,iSeverity)
EndFunction
