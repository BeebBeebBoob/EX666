SUBSYSTEM_DEF(research)
	name = "Research"
	flags = SS_NO_FIRE
	cpu_display = SS_CPUDISPLAY_LOW
	ss_id = "research"
	init_order = INIT_ORDER_EARLY_ASSETS

	/// All techs nodes
	var/list/techs
	/// All initialized and some generated quests
	var/list/quests
	/// Designs that are unlocked by completing quest
	var/list/quest_designs

	/// R&D Tech Network
	var/list/networks


/datum/controller/subsystem/research/Initialize()


	return SS_INIT_SUCCESS



///
/*
 * # Tech Network - A datum storing all research information such as points, techs and quests for a certain network.
 *
 * It's individual to every R&D server controller. Destroying server, will destroy datum.
 */
/datum/rnd_techweb_network
	/// Name of network used to identify
	var/network_name



	/// Unlocked techs nodes.
	var/list/researched_techs = list()
	/// Unlocked designs. Techs not the only who can open designs.
	var/list/researched_designs = list()
