SUBSYSTEM_DEF(research)
	name = "Research"
	flags = SS_NO_FIRE
	cpu_display = SS_CPUDISPLAY_LOW
	ss_id = "research"
	init_order = INIT_ORDER_RESEARCH

	/// R&D servers each containing own tech network
	var/list/rnd_servers = list()

	/// All techs nodes
	var/list/techs
	/// All initialized and some generated quests
	var/list/datum/research_quest/quests
	/// Designs that are unlocked by completing quest
	var/list/quest_designs


/datum/controller/subsystem/research/Initialize()
	return SS_INIT_SUCCESS

