Scriptname vION_PlayerLoadGameAliasScript extends ReferenceAlias
{Attach to Player alias. Enables the quest to receive the OnGameReload event.}

; === [ vION_PlayerLoadGameAliasScript.psc ] ==============================---
; Enables the owning vION_MetaQuestScript to receive the OnGameReload event.
; ========================================================---

;=== Events ===--

Event OnPlayerLoadGame()
{Send OnGameReload event to the owning quest.}
	(GetOwningQuest() as vION_MetaQuestScript).OnGameReload()
EndEvent
