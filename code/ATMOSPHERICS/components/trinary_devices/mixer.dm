/obj/machinery/atmospherics/trinary/mixer
	icon = 'icons/obj/pipes_and_stuff/atmospherics/atmos/mixer.dmi'
	icon_state = "map"

	can_unwrench = 1

	name = "gas mixer"

	var/target_pressure = ONE_ATMOSPHERE
	var/node1_concentration = 0.5
	var/node2_concentration = 0.5

	//node 3 is the outlet, nodes 1 & 2 are intakes

/obj/machinery/atmospherics/trinary/mixer/CtrlClick(mob/living/user)
	if(!istype(user) || user.incapacitated())
		to_chat(user, span_warning("You can't do that right now!"))
		return
	if(!in_range(src, user) && !issilicon(usr))
		return
	if(!ishuman(usr) && !issilicon(usr))
		return
	toggle()

/obj/machinery/atmospherics/trinary/mixer/AICtrlClick()
	toggle()
	return ..()

/obj/machinery/atmospherics/trinary/mixer/AltClick(mob/living/user)
	if((!Adjacent(user) && !issilicon(user)) || (!ishuman(user) && !issilicon(user)))
		return
	if(user.incapacitated())
		to_chat(user, span_warning("You can't do that right now!"))
		return
	set_max()

/obj/machinery/atmospherics/trinary/mixer/AIAltClick()
	set_max()
	return ..()

/obj/machinery/atmospherics/trinary/mixer/flipped
	icon_state = "mmap"
	flipped = 1

/obj/machinery/atmospherics/trinary/mixer/proc/toggle()
	if(powered())
		on = !on
		update_icon()

/obj/machinery/atmospherics/trinary/mixer/proc/set_max()
	if(powered())
		target_pressure = MAX_OUTPUT_PRESSURE
		update_icon()

/obj/machinery/atmospherics/trinary/mixer/update_icon(safety = 0)
	..()

	if(flipped)
		icon_state = "m"
	else
		icon_state = ""

	if(!powered())
		icon_state += "off"
	else if(node2 && node3 && node1)
		icon_state += on ? "on" : "off"
	else
		icon_state += "off"
		on = 0

/obj/machinery/atmospherics/trinary/mixer/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return

		add_underlay(T, node1, turn(dir, -180))

		if(flipped)
			add_underlay(T, node2, turn(dir, 90))
		else
			add_underlay(T, node2, turn(dir, -90))

		add_underlay(T, node3, dir)

/obj/machinery/atmospherics/trinary/mixer/power_change()
	var/old_stat = stat
	..()
	if(old_stat != stat)
		update_icon()

/obj/machinery/atmospherics/trinary/mixer/New()
	..()
	air3.volume = 300

/obj/machinery/atmospherics/trinary/mixer/process_atmos()
	..()
	if(!on)
		return 0

	var/output_starting_pressure = air3.return_pressure()

	if(output_starting_pressure >= target_pressure)
		//No need to mix if target is already full!
		return 1

	/*
	Pump mode:
	If mixing ratio is set to 100:0 or 0:100, mixer will act like a gas pump, avoiding unnecessary checks for actual mixing process
	pump = 0 - pump mode is OFF
	pump = 1 - pump mode is ON, transfers gas from intake 1 to outlet (node 1 -> node 3)
	pump = 2 - pump mode is ON, transfers gas from intake 2 to outlet (node 2 -> node 3)
	*/

	var/pump = 0

	if(!node1_concentration)
		pump = 2

	if(!node2_concentration)
		pump = 1

	//Calculate necessary moles to transfer using PV=nRT

	var/pressure_delta = target_pressure - output_starting_pressure
	var/transfer_moles1 = 0
	var/transfer_moles2 = 0

	if((air1.temperature > 0) && ((pump == 0) || (pump == 1)))
		transfer_moles1 = (node1_concentration*pressure_delta)*air3.volume/(air1.temperature * R_IDEAL_GAS_EQUATION)

	if((air2.temperature > 0) && ((pump == 0) || (pump == 2)))
		transfer_moles2 = (node2_concentration*pressure_delta)*air3.volume/(air2.temperature * R_IDEAL_GAS_EQUATION)

	if(pump == 0)
		var/air1_moles = air1.total_moles()
		var/air2_moles = air2.total_moles()

		if((air1_moles < transfer_moles1) || (air2_moles < transfer_moles2))
			if(!transfer_moles1 || !transfer_moles2) return
			var/ratio = min(air1_moles/transfer_moles1, air2_moles/transfer_moles2)

			transfer_moles1 *= ratio
			transfer_moles2 *= ratio

	//Actually transfer the gas

	if(transfer_moles1 > 0)
		var/datum/gas_mixture/removed1 = air1.remove(transfer_moles1)
		air3.merge(removed1)

	if(transfer_moles2 > 0)
		var/datum/gas_mixture/removed2 = air2.remove(transfer_moles2)
		air3.merge(removed2)

	if(transfer_moles1)
		parent1.update = 1

	if(transfer_moles2)
		parent2.update = 1

	parent3.update = 1

	return 1

/obj/machinery/atmospherics/trinary/mixer/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/atmospherics/trinary/mixer/attack_hand(mob/user)
	if(..())
		return

	if(!allowed(user))
		to_chat(user, span_alert("Access denied."))
		return

	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/atmospherics/trinary/mixer/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "AtmosMixer", name, 330, 165, master_ui, state)
		ui.open()

/obj/machinery/atmospherics/trinary/mixer/ui_data(mob/user)
	var/list/data = list(
		"on" = on,
		"pressure" = round(target_pressure, 0.01),
		"max_pressure" = MAX_OUTPUT_PRESSURE,
		"node1_concentration" = round(node1_concentration * 100),
		"node2_concentration" = round(node2_concentration * 100)
	)
	return data



/obj/machinery/atmospherics/trinary/mixer/ui_act(action, list/params)
	if(..())
		return

	switch(action)
		if("power")
			toggle()
			investigate_log("was turned [on ? "on" : "off"] by [key_name_log(usr)]", INVESTIGATE_ATMOS)
			return TRUE

		if("set_node")
			if(params["node_name"] == "Node 1")
				node1_concentration = clamp(round(text2num(params["concentration"]), 0.01), 0, 1)
				node2_concentration = round(1 - node1_concentration, 0.01)
				investigate_log("was set to [node1_concentration] % on node 1 by [key_name_log(usr)]", INVESTIGATE_ATMOS)
				return TRUE
			else
				node2_concentration = clamp(round(text2num(params["concentration"]), 0.01), 0, 1)
				node1_concentration = round(1 - node2_concentration, 0.01)
				investigate_log("was set to [node2_concentration] % on node 2 by [key_name_log(usr)]", INVESTIGATE_ATMOS)
				return TRUE

		if("max_pressure")
			target_pressure = MAX_OUTPUT_PRESSURE
			. = TRUE

		if("min_pressure")
			target_pressure = 0
			. = TRUE

		if("custom_pressure")
			target_pressure = clamp(text2num(params["pressure"]), 0, MAX_OUTPUT_PRESSURE)
			. = TRUE
	if(.)
		investigate_log("was set to [target_pressure] kPa by [key_name_log(usr)]", INVESTIGATE_ATMOS)

/obj/machinery/atmospherics/trinary/mixer/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/pen))
		rename_interactive(user, W)
		return
	else
		return ..()
