/*
 * ТЕХНОЛИГИЧЕСКИЕ ДИСКИ - Особая научная валюта которая используется в изучении уникальных ветках науки.
 * Их можно получить из разных отделов, за выполнение квестов, просто находя их случайно или другими способами.
 *
 *
 */
/obj/item/disk/tech_disk
	name = "\improper Unknown Technology Disk"
	desc = "A technology disk which contains undiscovered technology. Vluable in research."
	icon_state = "datadisk2"

	/// Технология на диске.
	var/datum/tech/tech
	/// Некоторые диски найденные случайно, будут неизвестные и для этого потребуется их обработка.
	var/revealed = TRUE

/obj/item/disk/tech_disk/Initialize(mapload, /datum/tech/assigned_tech)
	. = ..()
	if(!assigned_tech && !tech) // no on new or mapload
		tech = pick(subtypesof(/datum/tech) - /datum/tech/unknown) // gimme gimme
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)
	if(revealed)
		name = "\improper Technology Disk \[[tech.name]]"
		desc = tech.desc

/obj/item/disk/tech_disk/proc/reveal()
	revealed = TRUE
	name = "\improper Technology Disk \[[tech.name]]"
	desc = tech.desc

/// Диск в технологических техах к примеру.
/obj/item/disk/tech_disk/secret
	revealed = FALSE

/*
 * Технологические датумы.
 *
 * Все возможные виды технологии.
 * Includes all the various technoliges and what they make.
 */

/datum/tech	//Datum of individual technologies.
	var/name = "name" //Name of the technology.
	var/desc = "description" //General description of what it does and what it makes.
	var/id = "id" //An easily referenced ID. Must be alphanumeric, lower-case, and no symbols.

//Trunk Technologies (don't require any other techs and you start knowning them).

/datum/tech/materials
	name = "Materials"
	desc = "Development of new and improved materials."
	id = "materials"

/datum/tech/engineering
	name = "Engineering"
	desc = "Development of new and improved engineering parts and methods."
	id = "engineering"

/datum/tech/plasmatech
	name = "Plasma"
	desc = "Research into the mysterious substance colloqually known as 'plasma'."
	id = "plasmatech"

/datum/tech/powerstorage
	name = "Power Manipulation"
	desc = "The various technologies behind the storage and generation of electicity."
	id = "powerstorage"

/datum/tech/bluespace
	name = "Blue-space"
	desc = "Research into the sub-reality known as 'blue-space'."
	id = "bluespace"

/datum/tech/biotech
	name = "Biological"
	desc = "Research into the deeper mysteries of life and organic substances."
	id = "biotech"

/datum/tech/combat
	name = "Combat Systems"
	desc = "The development of offensive and defensive systems."
	id = "combat"

/datum/tech/magnets
	name = "Electromagnetic Spectrum"
	desc = "Research into the electromagnetic spectrum. No clue how they actually work, though."
	id = "magnets"

/datum/tech/programming
	name = "Data Theory"
	desc = "The development of new computer and artificial intelligence and data storage systems."
	id = "programming"

/datum/tech/toxins
	name = "Toxins Research"
	desc = "Research into plasma based explosive devices. Upgrade through testing explosives in the toxins lab."
	id = "toxins"

/datum/tech/explosives
	name = "Explosives"
	desc = "The creation and application of explosive materials."
	id = "explosives"

/datum/tech/generators
	name = "Power Generation"
	desc = "Research into more powerful and more reliable sources."
	id = "generators"

/datum/tech/robotics
	name = "Robotics"
	desc = "The development of advanced automated, autonomous machines."
	id = "robotics"

/datum/tech/unknown

/datum/tech/unknown/syndicate
	name = "Illegal Technologies"
	desc = "The study of technologies that violate standard Nanotrasen regulations."
	id = "syndicate"

/datum/tech/unknown/abductor
	name = "Alien Research"
	desc = "The study of technologies used by the advanced alien race known as Abductors."
	id = "abductor"

/datum/tech/unknown/arcane
	name = "Arcane"
	desc = "Research into the occult and arcane field for use in practical science"
	id = "arcane"
