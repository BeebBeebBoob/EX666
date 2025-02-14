
/obj/machinery/rnd
	name = "R&D Device"
	icon = 'icons/obj/machines/research.dmi'
	density = TRUE
	use_power = IDLE_POWER_USE

	///Are we currently printing a machine
	var/busy = FALSE
	///Is this machne hacked via wires
	var/hacked = FALSE
	///Is this machine disabled via wires
	var/disabled = FALSE
	///Ref to global science techweb.
	var/obj/machinery/research_server/our_server
	///The item loaded inside the machine, used by experimentors and destructive analyzers only.
	var/obj/item/loaded_item

	///ID used on mapload to link station and other machinery
	var/autolink_id

/obj/machinery/rnd/Initialize(mapload)
	. = ..()
	materials = AddComponent(
		/datum/component/material_container,
		list(MAT_METAL, MAT_GLASS, MAT_SILVER, MAT_GOLD, MAT_DIAMOND, MAT_PLASMA, MAT_URANIUM, MAT_BANANIUM, MAT_TRANQUILLITE, MAT_TITANIUM, MAT_BLUESPACE, MAT_PLASTIC),
		0,
		TRUE,
		/obj/item/stack,
		CALLBACK(src, PROC_REF(is_insertion_ready)),
		CALLBACK(src, PROC_REF(after_material_insert)))
	materials.precise_insertion = TRUE
	retun INITIALIZE_HINT_LATELOAD

/obj/machinery/rnd/LateInitialize()
	/// We do this after all servers and machinery are ready to connect. autolink_id is used for mappers
	for(var/obj/machinery/research_server/SRV as anything in SSresearch.rnd_servers)
		if(SRV.network_name == autolink_id)
			SRV.add_machine(src)

/obj/machinery/rnd/Destroy()
	if(our_server)
		investigate_log("disconnected from server [our_server][COORD(our_server)] (destroyed).", INVESTIGATE_RESEARCH)
		disconnect_server(FALSE)
	return ..()

//we eject the loaded item when deconstructing the machine
/obj/machinery/rnd/on_deconstruction(disassembled)
	if(loaded_item)
		loaded_item.forceMove(drop_location())
	..()

/obj/machinery/rnd/examine(mob/user)
	. = ..()
	. += span_notice("Its maintainence panel can be <b>screwed</b> [panel_open ? "closed" : "open"].")
	if(panel_open)
		. += span_notice("Use a <b>multitool</b> or <b>wirecutters</b> to interact with wires.")
		. += span_notice("The machine can be <b>pried</b> apart.")


///Called when attempting to connect the machine to a server, forgetting the old.
/obj/machinery/rnd/proc/connect_server(obj/machinery/research_server/new_server)
	if(!istype(new_server))
		stack_trace("an attempt to connect to a non-server! If you want to disconnect, use disconnect_server")
		return

	if(our_server)
		investigate_log("disconnected from old server [our_server][COORD(our_server)] when connected to [new_server][COORD(new_server)].", INVESTIGATE_RESEARCH)
		disconnect_server(FALSE)
	our_server = new_server
	if(!isnull(our_server))
		on_connected_server()


/// We call server to disconnect us with logging it
/obj/machinery/rnd/proc/disconnect_server(log = TRUE)
	if(log)
		investigate_log("disconnected from server [our_server][COORD(our_server)].", INVESTIGATE_RESEARCH)
	our_server.remove_machine(src) // sent a hint
	our_server = null


///Called post-connection to a new server.
/obj/machinery/rnd/proc/on_connected_server()
	SHOULD_CALL_PARENT(FALSE)


///Reset the state of this machine
/obj/machinery/rnd/proc/reset_busy()
	busy = FALSE

/obj/machinery/rnd/screwdriver_act(mob/user, obj/item/I)
	if(default_deconstruction_screwdriver(user, "[initial(icon_state)]_t", initial(icon_state), I))
		return TRUE

/obj/machinery/rnd/crowbar_act(mob/living/user, obj/item/I)
	if(default_deconstruction_crowbar(user, I))
		return TRUE

/obj/machinery/rnd/multitool_act(mob/living/user, obj/item/multitool/tool)
	. = TRUE
	if(!QDELETED(tool.buffer) && istype(tool.buffer, /obj/machinery/research_server))
		connect_server(tool.buffer)
		return

//whether the machine can have an item inserted in its current state.
/obj/machinery/rnd/proc/is_insertion_ready(mob/user)
	if(panel_open)
		balloon_alert(user, "panel open!")
		return FALSE
	if(disabled)
		balloon_alert(user, "belts disabled!")
		return FALSE
	if(busy)
		balloon_alert(user, "still busy!")
		return FALSE
	if(stat & BROKEN)
		balloon_alert(user, "machine broken!")
		return FALSE
	if(stat & NOPOWER)
		balloon_alert(user, "no power!")
		return FALSE
	if(loaded_item)
		balloon_alert(user, "item already loaded!")
		return FALSE
	return TRUE

/// Uses a bit of power and does insert animation
/obj/machinery/rnd/proc/after_material_insert(type_inserted, id_inserted, amount_inserted)
	var/stack_name
	if(ispath(type_inserted, /obj/item/stack/ore/bluespace_crystal))
		stack_name = "bluespace polycrystal"
		use_power(MINERAL_MATERIAL_AMOUNT / 10)
	else
		var/obj/item/stack/S = type_inserted
		stack_name = initial(S.name)
		use_power(min(1000, (amount_inserted / 100)))
	flick_overlay_view(image(icon, src,"[initial(name)]_[stack_name]", layer + 0.01), 1 SECONDS)


/obj/machinery/rnd/proc/check_material(datum/design/being_built, var/M)
	return 0 // number of copies of design beign_built you can make with material M
