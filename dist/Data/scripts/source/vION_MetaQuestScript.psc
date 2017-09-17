Scriptname vION_MetaQuestScript extends Quest
{Do initialization and track variables for scripts.}

;=== Imports ===--

Import Utility
Import Game

;=== Properties ===--

Actor Property PlayerRef Auto

Bool Property Ready = False Auto

Float Property ModVersion Auto Hidden
Int Property ModVersionInt Auto Hidden

Int Property ModVersionMajor Auto Hidden
Int Property ModVersionMinor Auto Hidden
Int Property ModVersionPatch Auto Hidden

String Property ModName = "Orbital Ion Cannon" Auto Hidden

vION_IonCannonControlScript Property vION_IonCannonControl Auto

;=== Config variables ===--

;=== Variables ===--

Float _CurrentVersion
Int _iCurrentVersion
String _sCurrentVersion

Bool _Running
Bool _bVersionSystemUpdated = False

Float _ScriptLatency
Float _StartTime
Float _EndTime

Int _iUpkeepsExpected
Int _iUpkeepsCompleted

;=== Events ===--

Event OnInit()
	DebugTrace("Metaquest event: OnInit - IsRunning: " + IsRunning() + " ModVersion: " + ModVersion + " ModVersionMajor: " + ModVersionMajor)
	If IsRunning() && ModVersion == 0 && !ModVersionMajor
		DoUpkeep(True)
	;Else
		;DoUpkeep(True)
	EndIf
EndEvent

Event OnReset()
	;DebugTrace("Metaquest event: OnReset")
EndEvent

Event OnUpdate()

EndEvent

Event OnGameReload()
	DebugTrace("Metaquest event: OnGameReload")
	;If vFFC_CFG_Shutdown.GetValue() != 0
		DoUpkeep(False)
	;EndIf
EndEvent

Event OnUpkeepState(string eventName, string strArg, float numArg, Form sender)
	If eventName == "vFFC_UpkeepBegin"
		_iUpkeepsExpected += 1
	ElseIf eventName == "vFFC_UpkeepEnd"
		_iUpkeepsCompleted += 1
		;DebugTrace("Metaquest Upkeep finished for " + sender + ". (" + _iUpkeepsCompleted + "/" + _iUpkeepsExpected + ")")
	EndIf
EndEvent

Event OnShutdown(string eventName, string strArg, float numArg, Form sender)
	DebugTrace("OnShutdown!")
	Wait(0.1)
	DoShutdown()
EndEvent

;=== Functions ===--

Function DoUpkeep(Bool DelayedStart = True)
	DebugTrace("Metaquest event: DoUpkeep(" + DelayedStart + ")")
	_iUpkeepsExpected = 0
	_iUpkeepsCompleted = 0
	;FIXME: CHANGE THIS WHEN UPDATING!
	ModVersionMajor = 0
	ModVersionMinor = 0
	ModVersionPatch = 2
	If !CheckDependencies()
		AbortStartup()
		Return
	EndIf
	_iCurrentVersion = GetVersionInt(ModVersionMajor,ModVersionMinor,ModVersionPatch)
	_sCurrentVersion = GetVersionString(_iCurrentVersion)
	String sModVersion = GetVersionString(ModVersion as Int)
	Ready = False
	If DelayedStart
		Wait(RandomFloat(3,5))
	EndIf
	
	String sErrorMessage
	DebugTrace("" + ModName)
	DebugTrace("Performing upkeep...")
	DebugTrace("Loaded version is " + sModVersion + ", Current version is " + _sCurrentVersion)
	If ModVersion == 0
		DebugTrace("Newly installed, doing initialization...")
		DoInit()
		If ModVersion == _iCurrentVersion
			DebugTrace("Initialization succeeded.")
		Else
			DebugTrace("WARNING! Initialization had a problem!",1)
		EndIf
	ElseIf ModVersion < _iCurrentVersion
		DebugTrace("Installed version is older. Starting the upgrade...")
		DoUpgrade() ; this should also fire DoUpkeep
		If ModVersion != _iCurrentVersion
			DebugTrace("WARNING! Upgrade failed!",1)
			Debug.MessageBox("WARNING! " + ModName + " upgrade failed for some reason. You should report this to the mod author.")
		EndIf
		DebugTrace("Upgraded to " + GetVersionString(_iCurrentVersion))
	Else
		;FIXME: Do init stuff in other quests
		DebugTrace("Loaded, no updates.")
	EndIf
	CheckForExtras()
	UpdateConfig()
	DebugTrace("Upkeep complete!")
	Ready = True
EndFunction

Function DoInit()
	DebugTrace("DoInit: Starting Ion Cannon Control...")
	Bool bResult = vION_IonCannonControl.Start()
	WaitMenuMode(0.1)
	If !bResult
		DebugTrace("DoInit: Ion Cannon Control script did not start properly, WTF?")
	EndIf
	_Running = True
	ModVersion = _iCurrentVersion
EndFunction

Function DoUpgrade()
	_Running = False
	;version-specific upgrade code
	
	;Generic upgrade code
	If ModVersion < _iCurrentVersion
		DebugTrace("Upgrading to " + GetVersionString(_iCurrentVersion) + "...")
		;FIXME: Do upgrade stuff!
		ModVersion = _iCurrentVersion
		DebugTrace("Upgrade to " + GetVersionString(_iCurrentVersion) + " complete!")
	EndIf
	_Running = True
	DebugTrace("Upgrade complete!")
EndFunction

Function CheckCompatibilityModules(Bool abReset = False)
	DebugTrace("Checking compatibility modules!")
EndFunction

Function AbortStartup(String asAbortReason = "None specified")
	DebugTrace("Aborting startup! Reason: " + asAbortReason,2)
	Ready = False

	_Running = False
	Ready = True
	Stop()
EndFunction

Function DoShutdown(Bool abClearData = False)
	Ready = False
	DebugTrace("Shutting down!")
	_iCurrentVersion = 0
	ModVersion = 0
	
	_Running = False
	Ready = True
EndFunction

Bool Function CheckDependencies()
	Return True
EndFunction

Function UpdateConfig()
	DebugTrace("Updating configuration...")

	DebugTrace("Updated configuration values, some scripts may update in the background!")
EndFunction

Int Function GetVersionInt(Int iMajor, Int iMinor, Int iPatch)
	;Return Math.LeftShift(iMajor,16) + Math.LeftShift(iMinor,8) + iPatch
	;Non-SKSE version:
	Return (iMajor * 65536) + (iMinor * 256) + iPatch
EndFunction

String Function GetVersionString(Int iVersion)
	;Int iMajor = Math.RightShift(iVersion,16)
	;Int iMinor = Math.LogicalAnd(Math.RightShift(iVersion,8),0xff)
	;Int iPatch = Math.LogicalAnd(iVersion,0xff)

	;Non-SKSE version:

	Int iMajor = iVersion / 65536
	Int iMinor = (iVersion % 65536) / 256 
	Int iPatch = (iVersion % 256)

	String sMajorZero
	String sMinorZero
	String sPatchZero
	If !iMajor
		sMajorZero = "0"
	EndIf
	If !iMinor
		sMinorZero = "0"
	EndIf
	;If !iPatch
		;sPatchZero = "0"
	;EndIf
	;DebugTrace("Got version " + iVersion + ", returning " + sMajorZero + iMajor + "." + sMinorZero + iMinor + "." + sPatchZero + iPatch)
	Return sMajorZero + iMajor + "." + sMinorZero + iMinor + "." + sPatchZero + iPatch
EndFunction

Function CheckForExtras()
	; If GetModByName("Dawnguard.esm") != 255
	; 	DebugTrace("Dawnguard is installed!")
	; EndIf
	; If GetModByName("Dragonborn.esm") != 255
	; 	DebugTrace("Dragonborn is installed!")
	; EndIf
EndFunction

Function DebugTrace(String sDebugString, Int iSeverity = 0)
	Debug.Trace("vION/MetaQuest: " + sDebugString,iSeverity)
EndFunction
