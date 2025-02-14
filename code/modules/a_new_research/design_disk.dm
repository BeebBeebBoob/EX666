
/obj/item/disk/design_disk
	name = "\improper Component Design Disk"
	desc = "A disk for storing device design data for construction in lathes."
	icon_state = "datadisk6"
	materials = list(MAT_METAL=100, MAT_GLASS=100)
	var/datum/design/blueprint
	// I'm doing this so that disk paths with pre-loaded designs don't get weird names
	// Otherwise, I'd use "initial()"
	var/default_name = "\improper Component Design Disk"
	var/default_desc = "A disk for storing device design data for construction in lathes."

/obj/item/disk/design_disk/New()
	..()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)

/obj/item/disk/design_disk/proc/load_blueprint(datum/design/D)
	name = "[default_name] \[[D]\]"
	desc = D.desc
	// NOTE: This is just a reference to the design on the system it grabbed it from
	// This seems highly fragile
	blueprint = D

/obj/item/disk/design_disk/proc/wipe_blueprint()
	name = default_name
	desc = default_desc
	blueprint = null

/obj/item/disk/design_disk/golem_shell
	name = "golem creation disk"
	desc = "A gift from the Liberator."
	icon_state = "datadisk1"

/obj/item/disk/design_disk/golem_shell/Initialize()
	. = ..()
	var/datum/design/golem_shell/G = new
	blueprint = G

/* Station goals design disks */
/** Base */
/obj/item/disk/design_disk/station_goal_machinery
	name = ""
	desc = ""
	icon_state = "datadisk5"
	var/design_type

/obj/item/disk/design_disk/station_goal_machinery/Initialize()
	. = ..()
	if(isnull(design_type))
		return INITIALIZE_HINT_QDEL

	blueprint = new design_type()

/** Bluespace rift scan server */
/obj/item/disk/design_disk/station_goal_machinery/brs_server
	name = "Bluespace rift scan server design"
	desc = "Экспериментальный проект сервера сканирования блюспейс разлома."
	design_type = /datum/design/brs_server

/** Bluespace rift small scanner */
/obj/item/disk/design_disk/station_goal_machinery/brs_portable_scanner
	name = "Bluespace rift portable scanner design"
	desc = "Экспериментальный проект портативного сканера блюспейс разлома."
	design_type = /datum/design/brs_portable_scanner

/** Bluespace rift big scanner */
/obj/item/disk/design_disk/station_goal_machinery/brs_stationary_scanner
	name = "Bluespace rift stationary scanner design"
	desc = "Экспериментальный проект стационарного сканера блюспейс разлома."
	design_type = /datum/design/brs_stationary_scanner

/** Nanotrasen tail blade implant */
/obj/item/disk/design_disk/tailblade/blade_nt
	name = "Tail laserblade implant design"
	desc = "A laser blade designed to be hidden inside the tail. Latest design of House Eshie'Ssharahss, issued to Nanotrasen in exclusive contract."
	blueprint = new /datum/design/tailblade
