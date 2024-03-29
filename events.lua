
module(..., package.seeall)

-- Event tables

ActiveCharacterCreated = {}
AdviceCleared = {}
AdviceDismissedEvent = {}
AdviceFinishedTrigger = {}
AdviceIssued = {}
AdviceLevelChanged = {}
AdviceNavigated = {}
AdviceSuperseded = {}
AreaEntered = {}
AreaExited = {}
BattleAideDeCampEvent = {}
BattleBoardingActionCommenced = {}
BattleCommandingShipRouts = {}
BattleCommandingUnitRouts = {}
BattleCompleted = {}
BattleCompletedCameraMove = {}
BattleConflictPhaseCommenced = {}
BattleDeploymentPhaseCommenced = {}
BattleDuelPending = {}
BattleDuelStarted = {}
BattleDuelEnded = {}
BattleFortPlazaCaptureCommenced = {}
BattleShipAttacksEnemyShip = {}
BattleShipCaughtFire = {}
BattleShipMagazineExplosion = {}
BattleShipRouts = {}
BattleShipRunAground = {}
BattleShipSailingIntoWind = {}
BattleShipSurrendered = {}
BattleUnitAttacksBuilding = {}
BattleUnitAttacksEnemyUnit = {}
BattleUnitAttacksWalls = {}
BattleUnitCapturesBuilding = {}
BattleUnitDestroysBuilding = {}
BattleUnitRouts = {}
BattleUnitUsingBuilding = {}
BattleUnitUsingWall = {}
BuildingCardSelected = {}
BuildingCompleted = {}
BuildingConstructionIssuedByPlayer = {}
BuildingInfoPanelOpenedCampaign = {}
CampaignArmiesMerge = {}
CampaignBattleLoggedEvent = {}
CampaignBuildingDamaged = {}
CampaignCoastalAssaultOnCharacter = {}
CampaignCoastalAssaultOnGarrison = {}
CampaignEffectsBundleAwarded = {}
CampaignModelScriptCallback = {}
CampaignTimeTriggerEvent = {}
CharacterAssignedToPost = {}
CharacterAttacksAlly = {}
CharacterBecomesFactionLeader = {}
CharacterBesiegesSettlement = {}
CharacterBlockadedPort = {}
CharacterBrokePortBlockade = {}
CharacterBuildingCompleted = {}
CharacterCaptiveOptionApplied = {}
CharacterCeoAdded = {}
CharacterCeoEquipped = {}
CharacterCeoNodeChanged = {}
CharacterCeoRemoved = {}
CharacterCeoUnequipped = {}
CharacterCharacterTargetAction = {}
CharacterComesOfAge = {}
CharacterCompletedBattle = {}
CharacterCreated = {}
CharacterDefectedEvent = {}
CharacterDeselected = {}
CharacterDied = {}
CharacterDiscovered = {}
CharacterDisembarksNavy = {}
CharacterEmbarksNavy = {}
CharacterEntersAttritionalArea = {}
CharacterEntersGarrison = {}
CharacterEvent = {}
CharacterFactionCompletesResearch = {}
CharacterFamilyRelationDied = {}
CharacterFinishedMovingEvent = {}
CharacterGarrisonTargetAction = {}
CharacterGarrisonTargetEvent = {}
CharacterLeavesFaction = {}
CharacterLeavesGarrison = {}
CharacterMilitaryForceTraditionPointAllocated = {}
CharacterMilitaryForceTraditionPointAvailable = {}
CharacterParticipatedAsSecondaryGeneralInBattle = {}
CharacterPerformsActionAgainstFriendlyTarget = {}
CharacterPerformsSettlementSiegeAction = {}
CharacterPostBattleEnslave = {}
CharacterPostBattleRelease = {}
CharacterPostBattleSlaughter = {}
CharacterPromoted = {}
CharacterRank = {}
CharacterRelationshipChangedEvent = {}
CharacterRelationshipCreatedEvent = {}
CharacterSelected = {}
CharacterSettlementBesieged = {}
CharacterSettlementBlockaded = {}
CharacterSkillPointAllocated = {}
CharacterSkillPointAvailable = {}
CharacterTargetEvent = {}
CharacterTurnEnd = {}
CharacterTurnStart = {}
CharacterUnassignedFromPost = {}
CharacterWaaaghOccurred = {}
CharacterWounded = {}
CharacterWoundHealedEvent = {}
CharacterWoundReceivedEvent = {}
CinematicTrigger = {}
ClanBecomesVassal = {}
CliDebugEvent = {}
ClimatePhaseChange = {}
ComponentLClickUp = {}
ComponentLinkClicked = {}
ComponentLinkMouseOver = {}
ComponentMouseOn = {}
ComponentMoved = {}
DilemmaChoiceMadeEvent = {}
DilemmaEvent = {}
DilemmaIssuedEvent = {}
DillemaOrIncidentStarted = {}
DiplomacyDealNegotiated = {}
DiplomacyNegotiationFinished = {}
DiplomacyNegotiationStarted = {}
EncylopediaEntryRequested = {}
EventMessageOpenedCampaign = {}
FactionAboutToEndTurn = {}
FactionAwakensFromDeath = {}
FactionBecomesLiberationVassal = {}
FactionBecomesWorldLeader = {}
FactionBecomesWorldLeaderCaptureSettlement = {}
FactionBeginTurnPhaseNormal = {}
FactionCapitalChanged = {}
FactionCapturesWorldCapital = {}
FactionCeoAdded = {}
FactionCeoNodeChanged = {}
FactionCeoRemoved = {}
FactionCivilWarOccured = {}
FactionEncountersOtherFaction = {}
FactionEvent = {}
FactionFameLevelUp = {}
FactionGovernmentTypeChanged = {}
FactionHordeStatusChange = {}
FactionJoinsConfederation = {}
FactionLeaderDeclaresWar = {}
FactionLeaderSignsPeaceTreaty = {}
FactionLiberated = {}
FactionNoLongerWorldLeader = {}
FactionOppositionPerformedPoliticalAction = {}
FactionRoundStart = {}
FactionSubjugatesOtherFaction = {}
FactionTurnEnd = {}
FactionTurnStart = {}
FirstTickAfterNewCampaignStarted = {}
FirstTickAfterWorldCreated = {}
ForceAdoptsStance = {}
FrontendScreenTransition = {}
GarrisonAttackedEvent = {}
GarrisonOccupiedEvent = {}
GarrisonResidenceEvent = {}
GovernorAssignedCharacterEvent = {}
GovernorshipTaxRateChanged = {}
HelpPageIndexGenerated = {}
HeroCharacterParticipatedInBattle = {}
HistoricalCharacters = {}
IncidentEvent = {}
IncidentOccuredEvent = {}
IncomingMessage = {}
LoadingGame = {}
LoadingScreenDismissed = {}
MapCharacterDeployed = {}
MilitaryForceBuildingCompleteEvent = {}
MilitaryForceCreated = {}
MilitaryForceDevelopmentPointChange = {}
MissionCancelled = {}
MissionEvent = {}
MissionFailed = {}
MissionGenerationFailed = {}
MissionIssued = {}
MissionNearingExpiry = {}
MissionStatusEvent = {}
MissionSucceeded = {}
MovementPointsExhausted = {}
MultiTurnMove = {}
NewCampaignStarted = {}
NewCharacterEnteredRecruitmentPool = {}
NewSession = {}
NominalDifficultyLevelChangedEvent = {}
OnKeyPressed = {}
PanelAdviceRequestedCampaign = {}
PanelClosedCampaign = {}
PanelOpenedCampaign = {}
PendingBankruptcy = {}
PendingBattle = {}
PlayerCampaignFinished = {}
PooledResourceEffectChangedEvent = {}
PooledResourceEvent = {}
PositiveDiplomaticEvent = {}
RecruitmentItemIssuedByPlayer = {}
RegionAbandonedWithBuildingEvent = {}
RegionEvent = {}
RegionGainedDevlopmentPoint = {}
RegionRebels = {}
RegionSelected = {}
RegionSlotEvent = {}
RegionTurnEnd = {}
RegionTurnStart = {}
RegionWindsOfMagicChanged = {}
ResearchCompleted = {}
ResearchStarted = {}
SavingGame = {}
ScriptedAgentCreated = {}
ScriptedAgentCreationFailed = {}
ScriptedForceCreated = {}
SeaTradeRouteRaided = {}
SettlementDeselected = {}
SettlementSelected = {}
ShortcutPressed = {}
ShortcutTriggered = {}
SlotRoundStart = {}
SlotSelected = {}
SlotTurnStart = {}
TechnologyInfoPanelOpenedCampaign = {}
TestEvent = {}
TooltipAdvice = {}
TradeNodeConnected = {}
TradeRouteEstablished = {}
TriggerPostBattleCeos = {}
UICreated = {}
UIDestroyed = {}
UndercoverCharacterActionCompleteEvent = {}
UndercoverCharacterAddedEvent = {}
UndercoverCharacterDiscoverResolvedEvent = {}
UndercoverCharacterSourceFactionActionCompleteEvent = {}
UndercoverCharacterTargetCharacterActionCompleteEvent = {}
UndercoverCharacterTargetFactionActionCompleteEvent = {}
UndercoverCharacterTargetGarrisonActionCompleteEvent = {}
UndercoverCharacterWillBeRemovedEvent = {}
UnitBeingCharged = {}
UnitBeingFlanked = {}
UnitCreated = {}
UnitEvent = {}
UnitExperienceLevelGained = {}
UnitSelectedCampaign = {}
WorldCreated = {}

-- SV: to be removed
UnitTurnEnd = {}
UnitCompletedBattle = {}
