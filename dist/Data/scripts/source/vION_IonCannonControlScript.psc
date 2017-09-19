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

ReferenceAlias 		Property alias_SoundFX 				Auto

ReferenceAlias		Property alias_BeamLight			Auto
ReferenceAlias		Property alias_TargetingLight		Auto
ReferenceAlias		Property alias_TargetGreenLight		Auto
ReferenceAlias		Property alias_TargetRedLight		Auto

Explosion 			Property vION_SubBlastExplosion 	Auto
Explosion 			Property vION_RingBlastExplosion1 	Auto
Explosion 			Property vION_AfterglowSparksExplosion 	Auto

Spell 				Property vION_ICTrackerBeam1Spell	Auto
Spell 				Property vION_ICFlingActorsSpell	Auto
Spell 				Property vION_ICBeamBlastSpell		Auto
Spell 				Property vION_ICRemoteTargetSpell			Auto
Spell 				Property vION_ICRemoteTargetActivateSpell	Auto

Sound 				Property vION_BlastSM				Auto

ObjectReference 	Property DummyTarget				Auto 

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

ObjectReference 	Property SoundFX					Auto Hidden

ObjectReference		Property BeamLight 					Auto Hidden
ObjectReference		Property TargetingLight 			Auto Hidden
ObjectReference		Property TargetGreenLight 			Auto Hidden
ObjectReference		Property TargetRedLight				Auto Hidden

Float 				Property tX							Auto Hidden
Float 				Property tY							Auto Hidden
Float 				Property tZ							Auto Hidden
Float 				Property tHeading					Auto Hidden

Float[]				Property MultX 						Auto Hidden
Float[]				Property MultY 						Auto Hidden

Int 				Property LockCount					Auto Hidden

Bool 				Property FireWhenReady 				Auto Hidden

Bool 				Property ReadyToFire = False		Auto Hidden
Bool 				Property Busy = False				Auto Hidden
String 				Property Status = "Ready"			Auto Hidden

;=== Config variables ===--

;=== Variables ===--

;=== Events ===--

Event OnInit()
	DebugTrace("OnInit! IsRunning: " + IsRunning())
	If IsRunning()
		ListRefs()
		AssignRefs()
		ReadyToFire = True
	EndIf
EndEvent

Function SetTarget(ObjectReference kTarget)
{Set the current target property and prep some information about it.}
	If Busy
		DebugTrace("SetTarget called while busy!",1)
		Return 
	EndIf
	If !kTarget.Is3DLoaded() || kTarget.GetDistance(PlayerREF) > 8192
		ReadyToFire = False
		DebugTrace("SetTarget: Invalid target: " + kTarget + ". Target must be loaded and within 8192 units of the player!",1)
		Target = None
		Return
	EndIf
	Target = kTarget
	tX = Target.GetPositionX()
	tY = Target.GetPositionY()
	tZ = Target.GetPositionZ()
	tHeading = Target.GetAngleZ()
	DebugTrace("Target is now " + Target + ". Position x:" + tX +", y:" + tY + ", z:" + tZ + ", Heading:" + tHeading)

	;RegisterForSingleUpdate(0)
	PlaceBeamRings()
	
	RisingSparks.MoveTo(Target,0,0,192)
	RisingSparks.SetAngle(0,0,tHeading)
	RisingSparks.SetScale(3)
	RisingSparks.EnableNoWait(True)
	RisingSparks.SetAnimationVariableFloat("fmagicburnamount",0.1)

	ReadyToFire = True
	Busy = False
	Status = "Ready"

EndFunction

Event OnUpdate()
	If FireWhenReady
		FireWhenReady = False
		FireBeam()
	Else 
		PlaceBeamRings()
	EndIf
EndEvent

Event OnUpdateGameTime()
	DebugTrace("Warning! OnUpdateGameTime fired, which usually means the script locked up for some reason!",1)
	DebugTrace("Busy:" + Busy + ", ReadyToFire:" + ReadyToFire + ", Status:" + Status + ", Target:" + Target,1)
	DebugTrace("Resetting now, let's hope for the best...",1)
	ResetAll()
EndEvent

Function PlaceBeamRings()
{Place Beam rings in advance}
	Int i = 0
	While(i < BeamRings.Length)
		;BeamRings[i].Reset()
		BeamRings[i].DisableNoWait(False)
		;If RandomInt(0,4) > 1
			BeamRings[i].MoveTo(Target,0,0,i * 500 + (RandomFloat(-150,150)))
			BeamRings[i].SetScale(2.0 - (i * 0.125))
			BeamRings[i].SetAngle(RandomInt(-5,5),RandomInt(-5,5),tHeading)
		;EndIf 
		i += 1
	EndWhile
	BeamRings[0].MoveTo(Target,0,0,100) ; make sure lowest ring can be seen
	BeamRings[i].SetAngle(RandomInt(-5,5),RandomInt(-5,5),tHeading)
	DebugTrace("Placed all beam rings!")
EndFunction

Function ScanForTarget(Float fMaxRange)
{Spawn the tracking beams and begin scanning for the target.}

	If Busy
		Return
	EndIf

	If !ReadyToFire
		DebugTrace("ScanForTarget: Not ready to fire! Check that a valid Target is set!",1)
		Return
	EndIf

	ReadyToFire = True
	Busy = True
	Status = "Scanning"

	MultX = New Float[9]
	MultY = New Float[9]

	RegisterForSingleUpdateGameTime((1.0 / 60.0) * 15) ; Emergency bail-out if something locks up

	Int iCount = 0
	While iCount < 9
		TrackerBeamCasters[iCount].InterruptCast()
		TrackerBeamCasters[iCount].DisableNoWait(False)
		;TrackerBeamCasters[iCount].MoveTo(Target)
		;TrackerBeamTargets[iCount].MoveTo(Target)

		Float fAngle = tHeading + ((360.0 / 9) * iCount)
		If fAngle >= 360
			fAngle -= 360
		EndIf
	
		DebugTrace("Angle is " + fAngle)

		MultX[iCount] = Math.Cos(fAngle)
		MultY[iCount] = -Math.Sin(fAngle)
		
		DebugTrace("Placing tracking beam caster " + iCount + " at x:" + (tX + (MultX[iCount] * fMaxRange)) + ",y:" + (tY + (MultY[iCount] * fMaxRange)) + "!")
		(TrackerBeamCasters[iCount] as vION_ICTrackingBeamCaster).IndexNumber = iCount
		TrackerBeamCasters[iCount].MoveTo(Target,(MultX[iCount] * fMaxRange) + RandomFloat(-fMaxRange/2,fMaxRange/2), (MultY[iCount] * fMaxRange) + RandomFloat(-fMaxRange/2,fMaxRange/2), 2000)
		TrackerBeamTargets[iCount].MoveTo(TrackerBeamCasters[iCount],0,0,-1800)
		iCount += 1
	EndWhile

	iCount = 0
	While iCount < 9
		TrackerBeamCasters[iCount].EnableNoWait(True)
		vION_ICTrackerBeam1Spell.RemoteCast(TrackerBeamCasters[iCount],PlayerRef,TrackerBeamTargets[iCount])
		iCount += 1
	EndWhile

	; iCount = 0
	; Wait(0.1)
	; While iCount < 9
	; 	vION_ICTrackerBeam1Spell.RemoteCast(TrackerBeamCasters[iCount],PlayerRef,TrackerBeamTargets[iCount])
	; 	iCount += 1
	; EndWhile

	;TargetingLight.MoveTo(Target,0,0,2400)
	;TargetingLight.SetAngle(0,-90,0)


	Wait(0.25)
	;TargetingLight.TranslateTo(tX,tY,tZ + 317,0,-90,0,200)
	iCount = 0
	While iCount < 9
		TrackerBeamTargets[iCount].MoveTo(Target,MultX[iCount] * 100,MultY[iCount] * 100,100)
		iCount += 1
	EndWhile

	iCount = 0
	While iCount < 9
		(TrackerBeamCasters[iCount] as vION_ICTrackingBeamCaster).StartScanning(fMaxRange)
		iCount += 1
	EndWhile

	RisingSparks.SetAnimationVariableFloat("fmagicburnamount",0.3)
EndFunction

Event TrackerBeamCasterTranslationUpdate(ObjectReference kCaster)

EndEvent

Function LockOnTarget()
{Stop the beams random movement and send them to the lock-on location.}

	If Status != "Scanning"
		DebugTrace("LockOnTarget called without scanning first!",1)
		Return
	EndIf

	ReadyToFire = True
	Busy = True
	Status = "Locking"

	RegisterForSingleUpdateGameTime((1.0 / 60.0) * 15) ; Emergency bail-out if something locks up
	;TargetingLight.TranslateTo(tX,tY,tZ + 317,0,-90,0,1000)
	RisingSparks.SetAnimationVariableFloat("fmagicburnamount",0.7)
	LockCount = 0
	Int iCount = 0
	While iCount < 9
		(TrackerBeamCasters[iCount] as vION_ICTrackingBeamCaster).StartLockOn()
		iCount += 1
	EndWhile	
EndFunction

Event TrackerBeamCasterLockedOn(vION_ICTrackingBeamCaster kCaster)
	; If LockCount > TrackerBeamCasters.Length
	; 	Return
	; EndIf
	LockCount += 1
	DebugTrace("Tracking beam " + kCaster.IndexNumber + " reports locked on! (" + LockCount + "/" + TrackerBeamCasters.Length + ")")
	If LockCount > 6
		RisingSparks.SetAnimationVariableFloat("fmagicburnamount",1.0)
	EndIf
	If LockCount >= TrackerBeamCasters.Length
		DebugTrace("Ready to fire!")
		FireWhenReady = True
		RegisterForSingleUpdate(0)
		;TargetingLight.TranslateTo(tX,tY,tZ,0,-90,0,100)
		Int iCount = 0
		While iCount < 9
			(TrackerBeamCasters[iCount] as vION_ICTrackingBeamCaster).ShutDown()
			TrackerBeamCasters[iCount].TranslateTo(tX, tY, tZ + 2000, 0, 0, (360 / 9) * iCount, 33)
			iCount += 1
		EndWhile
	EndIf
EndEvent

Function FireBeam()

	If Busy && Status != "Locking"
		DebugTrace("FireBeam called without Locking first!",1)
		Return
	EndIf

	If !ReadyToFire
		DebugTrace("Not ready to fire! Check that Target is set!",1)
		Return
	EndIf

	ReadyToFire = False
	Busy = True
	Status = "Firing"

	RegisterForSingleUpdateGameTime((1.0 / 60.0) * 15) ; Emergency bail-out if something locks up

	DebugTrace("Firing beam!")
	ReadyToFire = False
	If !RisingSparks.Is3DLoaded()
		RisingSparks.MoveTo(Target,0,0,192)
		RisingSparks.SetAngle(0,0,tHeading)
		RisingSparks.SetScale(3)
		RisingSparks.EnableNoWait(True)
		RisingSparks.SetAnimationVariableFloat("fmagicburnamount",1.0)
	EndIf

	SoundFX.MoveTo(Target)
	TargetGlow.DisableNoWait()
	TargetGlow.SetScale(1.5)

	BeamCore.DisableNoWait()
	BeamFX.DisableNoWait(False)
	BeamFX.MoveTo(Target)
	BeamFX.SetAngle(-90,0,0)
	BeamFX.SetScale(6)
	BeamLight.MoveTo(Target,0,0,2200)

	vION_BlastSM.Play(SoundFX)
	TargetGlow.MoveTo(Target)
	TargetGlow.EnableNoWait(True)
	BeamLight.TranslateTo(tX,tY,tZ + 25,0,0,0,300)
	
	Int iCount = BeamRings.Length
	While(iCount)
		iCount -= 1
		If BeamRings[iCount]
			BeamRings[iCount].EnableNoWait()
		EndIf
	EndWhile
	Wait(1.0)

	BeamFX.EnableNoWait(True)

	BeamCore.MoveTo(Target,0,0,10000)
	BeamCore.SetAngle(0,0,Target.GetAngleZ())
	BeamCore.SetScale(4)
	BeamCore.EnableNoWait()
	While !BeamCore.Is3dLoaded()
		Wait(0.1)
	EndWhile
	BeamCore.TranslateTo(tX,tY,tZ - 25000,0,0,0,15000)
	
	iCount = BeamRings.Length
	While(iCount)
		iCount -= 1
		If BeamRings[iCount]
			BeamRings[iCount].PlayGamebryoAnimation("SpecialIdle_AreaEffect")
			;BeamRings[iCount].PlaceAtMe(vION_RingBlastExplosion1)
		EndIf
	EndWhile
	;Wait(0.25)
	Target.PlaceAtMe(vION_SubBlastExplosion)
	Wait(0.25)
	vION_ICFlingActorsSpell.Cast(Target)
	Wait(0.25)
	vION_ICBeamBlastSpell.RemoteCast(Target,PlayerRef)
	TargetGlow.SetScale(2)
	BeamLight.TranslateTo(tX,tY,tZ - 2500,0,0,0,300)
	Target.PlaceAtMe(vION_AfterglowSparksExplosion)
	RisingSparks.SetAnimationVariableFloat("fmagicburnamount",0.1)
	Wait(0.25)
	BeamFX.DisableNoWait(True)
	
	RemoteTargetFrame.MoveToMyEditorLocation()
	RemoteCoreWaiting.MoveToMyEditorLocation()
	RemoteCoreActivated.MoveToMyEditorLocation()
	TargetGreenLight.MoveToMyEditorLocation()
	TargetRedLight.MoveToMyEditorLocation()

	Wait(1.75)
	BeamLight.TranslateTo(tX,tY,tZ - 2500,0,0,0,800)
	TargetGlow.DisableNoWait(True)
	Wait(1)
	RisingSparks.SetAnimationVariableFloat("fmagicburnamount",0.0)
	Wait(2)
	BeamLight.StopTranslation()
	BeamLight.MoveToMyEditorLocation()
	BeamCore.StopTranslation()
	BeamCore.MoveToMyEditorLocation()
	BeamFX.MoveToMyEditorLocation()
	RisingSparks.MoveToMyEditorLocation()
	TargetGlow.MoveToMyEditorLocation()

	;Wait a bit longer to avoid cutting off the soundfx
	Wait(3)
	ResetAll()
EndFunction

Function PlaceRemoteTarget(ObjectReference kTarget)
	DebugTrace("Placing remote target!")
	DummyTarget.MoveTo(kTarget)
	RemoteTargetFrame.MoveTo(kTarget)
	RemoteCoreWaiting.MoveTo(kTarget)
	TargetRedLight.MoveTo(kTarget)

	Int i = 0
	While (i < 2)
		If PlayerREF.GetEquippedSpell(i) == vION_ICRemoteTargetSpell
			PlayerREF.EquipSpell(vION_ICRemoteTargetActivateSpell, i)
		EndIf
		i += 1
	EndWhile
EndFunction

Function ActivateRemoteTarget()
	DebugTrace("Activating remote target!")
	If Busy
		TargetGreenLight.MoveToMyEditorLocation()
		Debug.Notification("Ion Cannon is busy " + Status + "!")
		Return
	EndIf
	TargetGreenLight.MoveTo(RemoteTargetFrame)
	RemoteCoreActivated.DisableNoWait()
	RemoteCoreActivated.MoveTo(RemoteTargetFrame)
	TargetGreenLight.MoveTo(RemoteTargetFrame)
	TargetRedLight.MoveToMyEditorLocation()
	RemoteCoreActivated.EnableNoWait(False)
	RemoteCoreWaiting.MoveToMyEditorLocation()

	SetTarget(DummyTarget)
	ScanForTarget(300)
	Wait(0.1)
	LockOnTarget()

	Int i = 0
	While (i < 2)
		If PlayerREF.GetEquippedSpell(i) == vION_ICRemoteTargetActivateSpell
			PlayerREF.EquipSpell(vION_ICRemoteTargetSpell, i)
		EndIf
		i += 1
	EndWhile
	PlayerRef.RemoveSpell(vION_ICRemoteTargetActivateSpell)
	If !PlayerRef.HasSpell(vION_ICRemoteTargetSpell)
		PlayerRef.AddSpell(vION_ICRemoteTargetSpell, False)
	EndIf

EndFunction

Function ResetAll()
	ReadyToFire = False
	Busy = True
	Status = "Resetting"

	DebugTrace("Resetting all objects for next shot...")
	UnregisterForUpdate()
	UnregisterForUpdateGameTime()
	Target = None
	FireWhenReady = False
	LockCount = 0
	BeamCore.MoveToMyEditorLocation()
	BeamFX.MoveToMyEditorLocation()
	RisingSparks.MoveToMyEditorLocation()
	TargetGlow.MoveToMyEditorLocation()
	RemoteTargetFrame.MoveToMyEditorLocation()
	RemoteCoreWaiting.MoveToMyEditorLocation()
	RemoteCoreActivated.MoveToMyEditorLocation()
	TargetGreenLight.MoveToMyEditorLocation()
	TargetRedLight.MoveToMyEditorLocation()
	DummyTarget.MoveToMyEditorLocation()
	SoundFX.MoveToMyEditorLocation()
	BeamLight.MoveToMyEditorLocation()
	;TargetingLight.MoveToMyEditorLocation()

	Int iCount = 0
	While iCount < TrackerBeamTargets.Length
		TrackerBeamTargets[iCount].MoveToMyEditorLocation()
		TrackerBeamCasters[iCount].MoveToMyEditorLocation()
		iCount += 1
	EndWhile

	iCount = 0
	While iCount < BeamRings.Length
		BeamRings[iCount].MoveToMyEditorLocation()
		iCount += 1
	EndWhile
	
	ReadyToFire = False
	Busy = False
	Status = "Ready"
	
	DebugTrace("Resetting complete. Ready to fire!")
EndFunction













Function ListRefs()
	DebugTrace("alias_BeamCore:     " + alias_BeamCore + " - " + alias_BeamCore.GetReference())
	DebugTrace("alias_BeamFX:     " + alias_BeamFX + " - " + alias_BeamFX.GetReference())
	DebugTrace("alias_RisingSparks: " + alias_RisingSparks + " - " + alias_RisingSparks.GetReference())
	DebugTrace("alias_RemoteTargetFrame: " + alias_RemoteTargetFrame + " - " + alias_RemoteTargetFrame.GetReference())
	DebugTrace("alias_RemoteCoreWaiting: " + alias_RemoteCoreWaiting + " - " + alias_RemoteCoreWaiting.GetReference())
	DebugTrace("alias_RemoteCoreActivated: " + alias_RemoteCoreActivated + " - " + alias_RemoteCoreActivated.GetReference())
	DebugTrace("alias_TargetGlow: " + alias_TargetGlow + " - " + alias_TargetGlow.GetReference())
	DebugTrace("alias_SoundFX: " + alias_SoundFX + " - " + alias_SoundFX.GetReference())


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
	BeamFX = alias_BeamFX.GetReference()
	RisingSparks = alias_RisingSparks.GetReference()
	TargetGlow	 = alias_TargetGlow.GetReference()
	RemoteTargetFrame = alias_RemoteTargetFrame.GetReference()
	RemoteCoreWaiting = alias_RemoteCoreWaiting.GetReference()
	RemoteCoreActivated = alias_RemoteCoreActivated.GetReference()
	SoundFX = alias_SoundFX.GetReference()

	BeamLight = alias_BeamLight.GetReference()
	TargetingLight = alias_TargetingLight.GetReference()
	TargetRedLight = alias_TargetRedLight.GetReference()
	TargetGreenLight = alias_TargetGreenLight.GetReference()

	TrackerBeamTargets = New ObjectReference[9]
	TrackerBeamCasters = New ObjectReference[9]
	BeamRings = New ObjectReference[16]

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

Function DebugTrace(String sDebugString, Int iSeverity = 0)
	Debug.Trace("vION/ICControl: " + sDebugString,iSeverity)
EndFunction

