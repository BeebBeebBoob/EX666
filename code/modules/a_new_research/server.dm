/obj/machinery/research_server
	name = "Research server"
	desc = "It saves, contains and provides all research data to connected consoles and machines"
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "server"

	/// The link ID of this console, used for map purposes
	var/network_name = null
	/// The network password for this device
	var/network_password
	/// Our techweb
	var/datum/techweb/techweb
	/// List of connected machines which are needed RnD designs updated
	var/list/obj/machinery/rnd/machines = list()


/obj/machinery/research_server/Initialize(mapload)
	. = ..()
	SSresearch.rnd_servers += src
	techweb = new()
	network_password = GenerateKey()

	// Make sure that name isnt already in use
	if(network_name)
		network_name = trim(network_name)

		if(name_check(network_name))
			var/myuid = UID()
			stack_trace("[src] at [x],[y],[z] tried to init with a network name of [network_name] when its already in use. Name has been randomised to [myuid]")
			network_name = myuid
	if(!network_name)
		network_name = UID()

/obj/machinery/research_server/Destroy()
	. = ..()
	for(var/obj/machinery/rnd/machine as anything in machines)
		machine.disconnect_server()
	SSresearch.rnd_servers -= src

/// Name sanity check. Makes sure the target network name isnt already in use. Returns TRUE or FALSE depending on that criteria.
/obj/machinery/research_server/proc/name_check(pending_name)
	var/list/all_names = list()

	for(var/obj/machinery/research_server/server in SSresearch.rnd_servers)
		if(server == src)
			continue
		all_names += server.network_name

	return (pending_name in all_names)

/// Add machines to give new designs on signal
/obj/machinery/research_server/proc/add_machine(obj/machinery/rnd/machine)
	if(!istype(machine))
		return
	machines |= machine
	machine.on_connected_server()

/// This is internal way to remove machine and his link to the server. use disconnect_server() on a machine
/obj/machinery/research_server/proc/remove_machine(obj/machinery/rnd/machine)
	if(!istype(machine))
		return
	machines -= machine

/obj/machinery/research_server/screwdriver_act(mob/user, obj/item/I)
	if(default_deconstruction_screwdriver(user, "server_o", "server", I))
		update_icon()
		return TRUE

/obj/machinery/research_server/crowbar_act(mob/user, obj/item/I)
	if(default_deconstruction_crowbar(user, I))
		return TRUE

/obj/machinery/research_server/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(!I.multitool_check_buffer(user))
		return
	var/obj/item/multitool/M = I
	M.set_multitool_buffer(user, src)


/obj/machinery/research_server/main
	network_name = "station_rnd"

/obj/machinery/research_server/golems
	network_name = "golems_rnd"

/obj/machinery/research_server/taipan
	network_name = "taipan_rnd"

/obj/machinery/research_server/old_station
	network_name = "oldstation_rnd"
