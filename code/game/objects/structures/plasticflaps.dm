/obj/structure/plasticflaps //HOW DO YOU CALL THOSE THINGS ANYWAY
	name = "\improper plastic flaps"
	desc = "Completely impassable - or are they?"
	icon = 'icons/obj/stationobjs.dmi' //Change this.
	icon_state = "plasticflaps"
	density = 0
	anchored = 1
	layer = ABOVE_HUMAN_LAYER
	explosion_resistance = 5

	obj_flags = OBJ_FLAG_ANCHORABLE

	var/list/mobs_can_pass = list(
		/mob/living/bot,
		/mob/living/carbon/slime,
		/mob/living/simple_animal/mouse,
		/mob/living/silicon/robot/drone
		)

/obj/structure/plasticflaps/CanPass(atom/A, turf/T)
	if(istype(A) && A.checkpass(PASS_FLAG_GLASS))
		return prob(60)

	var/obj/structure/bed/B = A
	if (istype(A, /obj/structure/bed) && B.buckled_mob)//if it's a bed/chair and someone is buckled, it will not pass
		return 0

	if(istype(A, /obj/vehicle))	//no vehicles
		return 0

	var/mob/living/M = A
	if(istype(M))
		if(M.lying)
			return ..()
		for(var/mob_type in mobs_can_pass)
			if(istype(A, mob_type))
				return ..()
		return issmall(M)

	return ..()

/obj/structure/plasticflaps/attackby(obj/item/W, mob/user)
	if(isScrewdriver(W) && !anchored)
		user.visible_message("<span class='notice'>\The [user] begins deconstructing \the [src].</span>", "<span class='notice'>You start deconstructing \the [src].</span>")
		if(user.do_skilled(3 SECONDS, SKILL_CONSTRUCTION, src))
			user.visible_message("<span class='warning'>\The [user] deconstructs \the [src].</span>", "<span class='warning'>You deconstruct \the [src].</span>")
			qdel(src)
	else ..()

/obj/structure/plasticflaps/ex_act(severity)
	if(atom_flags & ATOM_FLAG_INDESTRUCTIBLE)
		return
	switch(severity)
		if (1)
			qdel(src)
		if (2)
			if (prob(50))
				qdel(src)
		if (3)
			if (prob(5))
				qdel(src)

/obj/structure/plasticflaps/mining //A specific type for mining that doesn't allow airflow because of them damn crates
	name = "airtight plastic flaps"
	desc = "Heavy duty, airtight, plastic flaps."

/obj/structure/plasticflaps/mining/Initialize() //set the turf below the flaps to block air
	become_airtight()
	. = ..()

/obj/structure/plasticflaps/mining/wrench_floor_bolts(user)
	..()
	if(!anchored)
		clear_airtight()
	else
		become_airtight()

/obj/structure/plasticflaps/mining/Destroy() //lazy hack to set the turf to allow air to pass if it's a simulated floor
	clear_airtight()
	. = ..()

/obj/structure/plasticflaps/mining/proc/become_airtight()
	var/turf/T = get_turf(loc)
	if(T)
		T.blocks_air = 1

/obj/structure/plasticflaps/mining/proc/clear_airtight()
	var/turf/T = get_turf(loc)
	if(T)
		if(istype(T, /turf/simulated/floor))
			T.blocks_air = 0