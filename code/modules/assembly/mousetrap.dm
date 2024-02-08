/obj/item/assembly/mousetrap
	name = "mousetrap"
	desc = "A handy little spring-loaded trap for catching pesty rodents."
	icon_state = "mousetrap"
	materials = list(MAT_METAL=100)
	origin_tech = "combat=1;materials=2;engineering=1"
	var/armed = FALSE

	bomb_name = "contact mine"


/obj/item/assembly/mousetrap/examine(mob/user)
	. = ..()
	if(armed)
		. += span_warning("It looks like it's armed.")
	. += span_info("<b>Alt-Click</b> to hide it.")


/obj/item/assembly/mousetrap/activate()
	if(!..())
		return

	armed = !armed
	if(!armed && ishuman(usr))
		var/mob/living/carbon/human/user = usr
		if((user.getBrainLoss() >= 60 || (CLUMSY in user.mutations)) && prob(50))
			to_chat(user, "Your hand slips, setting off the trigger.")
			pulse(FALSE, user)

	update_icon()

	if(usr)
		playsound(usr.loc, 'sound/weapons/handcuffs.ogg', 30, TRUE, -3)


/obj/item/assembly/mousetrap/update_icon_state()
	icon_state = "mousetrap[armed ? "armed": ""]"
	if(holder)
		holder.update_icon()


/obj/item/assembly/mousetrap/proc/triggered(mob/target, type = "feet")
	if(!armed)
		return

	var/obj/item/organ/external/affecting = null

	if(ishuman(target))
		var/mob/living/carbon/human/h_target = target
		if(h_target.dna && (PIERCEIMMUNE in h_target.dna.species.species_traits))
			playsound(src, 'sound/effects/snap.ogg', 50, TRUE)
			armed = FALSE
			update_icon()
			pulse(FALSE, h_target)
			return FALSE

		switch(type)
			if("feet")
				if(!h_target.shoes)
					affecting = h_target.get_organ(pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
					h_target.Weaken(6 SECONDS)

			if(BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND)
				if(!h_target.gloves)
					affecting = h_target.get_organ(type)
					h_target.Stun(6 SECONDS)

		if(affecting)
			affecting.receive_damage(1, 0)

	else if(ismouse(target) && target.stat != DEAD)
		var/mob/living/simple_animal/mouse/mouse = target
		visible_message(span_danger("SPLAT!"))
		mouse.death()
		mouse.splat(src)

	playsound(loc, 'sound/effects/snap.ogg', 50, TRUE)
	layer = MOB_LAYER - 0.2
	armed = FALSE
	update_icon()
	pulse(FALSE, target)


/obj/item/assembly/mousetrap/attack_self(mob/living/user)
	if(!armed)
		to_chat(user, span_notice("You arm [src]."))
	else
		if((user.getBrainLoss() >= 60 || (CLUMSY in user.mutations)) && prob(50))
			triggered(user, user.hand ? BODY_ZONE_PRECISE_L_HAND : BODY_ZONE_PRECISE_R_HAND)
			user.visible_message(
				span_warning("[user] accidentally sets off [src], breaking [user.p_their()] fingers."),
				span_warning("You accidentally trigger [src]!"),
			)
			return
		to_chat(user, span_notice("You disarm [src]."))
	armed = !armed
	update_icon()
	playsound(user.loc, 'sound/weapons/handcuffs.ogg', 30, TRUE, -3)


/obj/item/assembly/mousetrap/attack_hand(mob/living/user)
	if(armed && (user.getBrainLoss() >= 60 || (CLUMSY in user.mutations)) && prob(50))
		triggered(user, user.hand ? BODY_ZONE_PRECISE_L_HAND : BODY_ZONE_PRECISE_R_HAND)
		user.visible_message(
			span_warning("[user] accidentally sets off [src], breaking [user.p_their()] fingers."),
			span_warning("You accidentally trigger [src]!"),
		)
		return
	..()


/obj/item/assembly/mousetrap/Crossed(atom/movable/AM, oldloc)
	if(armed)
		if(ishuman(AM))
			var/mob/living/carbon/h_target = AM
			if(h_target.m_intent == MOVE_INTENT_RUN)
				triggered(h_target)
				h_target.visible_message(
					span_warning("[h_target] accidentally steps on [src]."),
					span_warning("You accidentally step on [src]!"),
				)
		else if(ismouse(AM))
			triggered(AM)
		else if(AM.density) // For mousetrap grenades, set off by anything heavy
			triggered(AM)
	..()


/obj/item/assembly/mousetrap/on_found(mob/finder)
	if(armed)
		finder.visible_message(
			span_warning("[finder] accidentally sets off [src], breaking [finder.p_their()] fingers."),
			span_warning("You accidentally trigger [src]!"),
		)
		triggered(finder, finder.hand ? BODY_ZONE_PRECISE_L_HAND : BODY_ZONE_PRECISE_R_HAND)
		return TRUE	//end the search!
	return FALSE


/obj/item/assembly/mousetrap/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(!armed)
		return ..()
	visible_message(span_warning("[src] is triggered by [AM]."))
	triggered()


/obj/item/assembly/mousetrap/armed
	icon_state = "mousetraparmed"
	armed = TRUE


/obj/item/assembly/mousetrap/AltClick(mob/user)
	if(user.incapacitated() || !Adjacent(user))
		return

	layer = TURF_LAYER+0.2
	to_chat(user, "<span class='notice'>You hide [src].</span>")
