Scriptname vION_ICBeamRemoteTarget extends ObjectReference
{Acts as player-activated target of the beam.}

; === [ vION_ICBeamRemoteTarget.psc ] ==========================================---
; Handles:
;   Placement of remote target SFX
;   Placing the actual beam summoner
; ========================================================---

;=== Imports ===--

Import Utility
Import Game

;=== Constants ===--

;=== Properties ===--

Actor 			Property PlayerREF							Auto

Activator 		Property vION_ICRemoteTargetActivator 		Auto
{Remote target mesh}

Activator 		Property vION_ICTargetSpinnerOnActivator	Auto
{The 'activated' version of the target core}

Activator 		Property vION_ICBeamTargetActivator			Auto
{The beam summoner}

Hazard 			Property vION_ICTargetHazard				Auto
{Target location for this script}

GlobalVariable 	Property vION_ICTargetPlaced 				Auto
{Whether the target is palced}

Light 			Property vION_TargetRedLight				Auto
Light 			Property vION_TargetGreenLight				Auto

Spell 			Property vION_ICRemoteTargetSpell			Auto
Spell 			Property vION_ICRemoteTargetActivateSpell	Auto

;=== Variables ===--

ObjectReference _SpawnPoint

ObjectReference _frameMesh

ObjectReference _coreMesh

ObjectReference _redLight
ObjectReference _greenLight

;=== Events ===--


Event OnLoad()
	GoToState("Loaded")
	If (vION_ICTargetPlaced.GetValue())
		;DebugTrace("Already placed, aborting :(")
		;GoToState("Shutdown")
		;Return
	EndIf
	vION_ICTargetPlaced.Mod(1)
	Int i = 0
	While !_SpawnPoint && i < 10
		_SpawnPoint = FindClosestReferenceOfTypeFromRef(vION_ICTargetHazard,Self,500)
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
	_frameMesh = _SpawnPoint.PlaceAtMe(vION_ICRemoteTargetActivator)
	MoveTo(_SpawnPoint)
	_redLight = PlaceAtMe(vION_TargetRedLight)
	DebugTrace("Moved to " + _SpawnPoint)

	i = 0
	While (i < 2)
		If PlayerREF.GetEquippedSpell(i) == vION_ICRemoteTargetSpell
			PlayerREF.EquipSpell(vION_ICRemoteTargetActivateSpell, i)
		EndIf
		i += 1
	EndWhile
	PlayerRef.RemoveSpell(vION_ICRemoteTargetSpell)
EndEvent

Function GoSplodey()
	_coreMesh = PlaceAtMe(vION_ICTargetSpinnerOnActivator,abInitiallyDisabled = True)
	_coreMesh.EnableNoWait(False)
	_greenLight = _coreMesh.PlaceAtMe(vION_TargetGreenLight)
	_redLight.Delete()
	PlaceAtMe(vION_ICBeamTargetActivator)
	RegisterForSingleUpdate(5)
	MoveToMyEditorLocation()
EndFunction

Event OnCellDetach()
	GoToState("Shutdown")
EndEvent

Event OnUpdate()
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
	GoToState("Shutdown")
EndEvent

State Loaded
	Event OnLoad()
		;Do nothing
	EndEvent
EndState

State Shutdown
	Event OnLoad()
		;Do nothing
	EndEvent

	Event OnBeginState()
		vION_ICTargetPlaced.Mod(-1)
		If _redLight
			_redLight.Delete()
			_redLight = None
		EndIf
		If _greenLight
			_greenLight.Delete()
			_greenLight = None
		EndIf
		If _coreMesh
			_coreMesh.Delete()
			_coreMesh = None
		EndIf
		If _frameMesh
			_frameMesh.Delete()
			_frameMesh = None
		EndIf
		If _SpawnPoint
			_SpawnPoint.Delete()
			_SpawnPoint = None
		EndIf
		RegisterForSingleUpdate(0.1)
	EndEvent

	Event OnUpdate()
		MoveToMyEditorLocation()
		GoToState("")
	EndEvent

EndState

Function DebugTrace(String sDebugString, Int iSeverity = 0)
	Debug.Trace("vION/vION_ICBeamRemoteTarget(" + Self + "): " + sDebugString,iSeverity)
EndFunction