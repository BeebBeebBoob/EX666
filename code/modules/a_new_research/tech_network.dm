/*
 * # Techweb - A datum storing all research information such as points, techs and quests for a certain network.
 *
 * It's individual to every R&D server. Destroying server, will destroy datum.
 */
/datum/techweb
	/// Name of network used to identify
	var/network_name = ""
	/// Unlocked techs nodes.
	var/list/researched_techs = list()
	/// Unlocked designs. Techs not the only who can open designs.
	var/list/researched_designs = list()
	/// The science currenc spent on tech.
	var/points = 0

