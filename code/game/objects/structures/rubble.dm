/obj/structure/rubble //Abstract parent type
	name = "rubble"
	icon = 'icons/obj/structures/rubble.dmi'
	anchored = FALSE
	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	density = TRUE
	can_buckle = TRUE
	layer = TABLE_LAYER
	buckle_lying = 90
	max_integrity = 300
	integrity_failure = 0.33
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/structure/rubble/Initialize(mapload)
	. = ..()
	if(!mapload)
		var/turf/my_turf = get_turf(src)
		if(!isopenspaceturf(my_turf))
			CrushTurf(my_turf)
		my_turf.zFall(src) //Needs to call this because apparently initialized movables dont get /turf/Entered()

/obj/structure/rubble/ex_act(severity, target)
	if(severity == EXPLODE_DEVASTATE)
		return ..()
	return FALSE

/obj/structure/rubble/attack_paw(mob/user, list/modifiers)
	return attack_hand(user, modifiers)

/obj/structure/rubble/user_buckle_mob(mob/living/M, mob/user, check_loc = TRUE)
	return

/obj/structure/rubble/user_unbuckle_mob(mob/living/buckled_mob, mob/living/user)
	if(buckled_mob != user)
		buckled_mob.visible_message(SPAN_NOTICE("[user.name] pulls [buckled_mob.name] free from the rubble!"),\
			SPAN_NOTICE("[user.name] pulls you free from the rubble."),\
			SPAN_HEAR("You hear something being dragged..."))
	else
		buckled_mob.visible_message(SPAN_WARNING("[buckled_mob.name] struggles to break free from the rubble!"),\
			SPAN_NOTICE("You struggle to break free from the rubble... (Stay still for 30 seconds.)"),\
			SPAN_HEAR("You hear struggling..."))
		if(!do_after(buckled_mob, 30 SECONDS, target = src))
			if(buckled_mob?.buckled)
				to_chat(buckled_mob, SPAN_WARNING("You fail to get out!"))
			return
		if(!buckled_mob.buckled)
			return
		buckled_mob.visible_message(SPAN_WARNING("[buckled_mob.name] breaks free from the rubble!"),\
			SPAN_NOTICE("You break free from the rubble!"))
	unbuckle_mob(buckled_mob)

/obj/structure/rubble/welder_act(mob/living/user, obj/item/I)
	..()
	if(!I.tool_start_check(user, amount=0))
		return TRUE
	to_chat(user, SPAN_NOTICE("You start welding the [src] down..."))
	if(I.use_tool(src, user, 8 SECONDS, volume=50))
		to_chat(user, SPAN_NOTICE("You weld the [src] down."))
		qdel(src)
	return TRUE

/obj/structure/rubble/onZImpact(turf/T, levels)
	playsound(src, 'sound/effects/bang.ogg', 50, TRUE)
	CrushTurf(T, 20 * levels)

/obj/structure/rubble/proc/CrushTurf(turf/Turf, power = 10)
	for(var/mob/living/living_mob in Turf)
		living_mob.visible_message(SPAN_WARNING("[living_mob.name] is crushed under the rubble!"),\
			SPAN_USERDANGER("Rubble crushes you, pinning you under its weight!"),\
			SPAN_HEAR("You hear crashing..."))
		living_mob.adjustBruteLoss(power)
		living_mob.Paralyze(2 SECONDS)
		buckle_mob(living_mob, TRUE)

/obj/structure/rubble/large
	desc = "A large pile of rubble, rendering the terrain unpassable. You probably could weld this down."
	icon_state = "rubble_big"

/obj/structure/rubble/large/metal
	icon_state = "rubble_big_metal"

/obj/structure/rubble/medium
	desc = "A pile of rubble, you could probably climb over it. You probably could weld this down."
	icon_state = "rubble_medium"
	pass_flags_self = PASSTABLE | LETPASSTHROW

/obj/structure/rubble/medium/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/climbable)

/obj/structure/rubble/medium/metal
	icon_state = "rubble_medium_metal"
