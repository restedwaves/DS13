var/list/holder_mob_icon_cache = list()

//Helper object for picking dionaea (and other creatures) up.
/obj/item/holder
	name = "holder"
	desc = "You shouldn't ever see this."
	icon = 'icons/obj/objects.dmi'
	slot_flags = SLOT_HEAD | SLOT_HOLSTER
	origin_tech = null
	item_icons = list(
		slot_l_hand_str = 'icons/mob/onmob/items/lefthand_holder.dmi',
		slot_r_hand_str = 'icons/mob/onmob/items/righthand_holder.dmi',
		)
	pixel_y = 8

	var/last_holder

/obj/item/holder/New()
	..()
	START_PROCESSING(SSobj, src)

/obj/item/holder/proc/destroy_all()
	for(var/atom/movable/AM in src)
		qdel(AM)
	qdel(src)

/obj/item/holder/Destroy()
	for(var/atom/movable/AM in src)
		AM.forceMove(get_turf(src))
	last_holder = null
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/holder/Process()
	update_state()

/obj/item/holder/dropped()
	..()
	spawn(1)
		update_state()

/obj/item/holder/proc/update_state()
	if(last_holder != loc)
		for(var/mob/M in contents)
			M.UnregisterSignal(loc, list(COMSIG_MOVABLE_MOVED, COMSIG_ATOM_DIR_CHANGE))

	if(istype(loc,/turf) || !(contents.len))
		for(var/mob/M in contents)
			var/atom/movable/mob_container = M
			mob_container.dropInto(loc)
			M.reset_view()
		qdel(src)

/obj/item/holder/onDropInto(var/atom/movable/AM)
	if(ismob(loc))   // Bypass our holding mob and drop directly to its loc
		return loc.loc
	return ..()

/obj/item/holder/GetIdCard()
	for(var/mob/M in contents)
		var/obj/item/I = M.GetIdCard()
		if(I)
			return I
	return null

/obj/item/holder/GetAccess()
	var/obj/item/I = GetIdCard()
	return I ? I.GetAccess() : ..()

/obj/item/holder/attack_self()
	for(var/mob/M in contents)
		M.show_inv(usr)

/obj/item/holder/attack(mob/target, mob/user)
	// Devour on click on self with holder
	if(target == user && istype(user,/mob/living/carbon))
		var/mob/living/carbon/M = user

		for(var/mob/victim in src.contents)
			M.devour(victim)

		update_state()

	..()

/obj/item/holder/proc/sync(var/mob/living/M)
	dir = 2
	overlays.Cut()
	icon = M.icon
	icon_state = M.icon_state
	item_state = M.item_state
	color = M.color
	name = M.name
	desc = M.desc
	overlays |= M.overlays
	var/mob/living/carbon/human/H = loc
	last_holder = H
	if(iscarbon(M))
		w_class = ITEM_SIZE_NO_CONTAINER

	update_held_icon()

//Mob specific holders.
/obj/item/holder/drone
	origin_tech = list(TECH_MAGNET = 3, TECH_ENGINEERING = 5)

/obj/item/holder/mouse
	w_class = ITEM_SIZE_TINY

/obj/item/holder/borer
	origin_tech = list(TECH_BIO = 6)

//need own subtype to work with recipies
/obj/item/holder/corgi
	origin_tech = list(TECH_BIO = 4)

/obj/item/holder/attackby(obj/item/W as obj, mob/user as mob)
	for(var/mob/M in src.contents)
		M.attackby(W,user)

//Mob procs and vars for scooping up
/mob/living/var/holder_type

/mob/living/proc/get_scooped(var/mob/living/carbon/human/grabber, var/self_grab)

	if(!holder_type || buckled || pinned.len)
		return

	if(self_grab)
		if(src.incapacitated()) return
	else
		if(grabber.incapacitated()) return

	var/obj/item/holder/H = new holder_type(get_turf(src))

	if(self_grab)
		if(!grabber.equip_to_slot_if_possible(H, slot_back, del_on_fail=0, disable_warning=1))
			to_chat(src, "<span class='warning'>You can't climb onto [grabber]!</span>")
			return

		to_chat(grabber, "<span class='notice'>\The [src] clambers onto you!</span>")
		to_chat(src, "<span class='notice'>You climb up onto \the [grabber]!</span>")
	else
		if(!grabber.put_in_hands(H))
			to_chat(grabber, "<span class='warning'>Your hands are full!</span>")
			return

		to_chat(grabber, "<span class='notice'>You scoop up \the [src]!</span>")
		to_chat(src, "<span class='notice'>\The [grabber] scoops you up!</span>")

	src.forceMove(H)

	grabber.status_flags |= PASSEMOTES
	H.sync(src)
	return H

/mob/living/MouseDrop(var/mob/living/carbon/human/over_object)
	if(istype(over_object) && Adjacent(over_object) && (usr == src || usr == over_object) && over_object.a_intent == I_GRAB)
		if(scoop_check(over_object))
			get_scooped(over_object, (usr == src))
			return
	return ..()

/mob/living/proc/scoop_check(var/mob/living/scooper)
	return 1

/mob/living/carbon/human/scoop_check(var/mob/living/scooper)
	return (scooper.mob_size > src.mob_size && a_intent == I_HELP)

/obj/item/holder/human
	icon = 'icons/mob/holder_complex.dmi'
	var/list/generate_for_slots = list(slot_l_hand_str, slot_r_hand_str, slot_back_str)
	slot_flags = SLOT_BACK

/obj/item/holder/human/sync(var/mob/living/M)
	// Generate appropriate on-mob icons.
	var/mob/living/carbon/human/owner = M
	if(istype(owner) && owner.species)

		var/skin_colour = rgb(owner.r_skin, owner.g_skin, owner.b_skin)
		var/hair_colour = rgb(owner.r_hair, owner.g_hair, owner.b_hair)
		var/eye_colour =  rgb(owner.r_eyes, owner.g_eyes, owner.b_eyes)
		var/species_name = lowertext(owner.species.get_bodytype(owner))

		for(var/cache_entry in generate_for_slots)
			var/cache_key = "[owner.species]-[cache_entry]-[skin_colour]-[hair_colour]"
			if(!holder_mob_icon_cache[cache_key])

				// Generate individual icons.
				var/icon/mob_icon = icon(icon, "[species_name]_holder_[cache_entry]_base")
				mob_icon.Blend(skin_colour, ICON_ADD)
				var/icon/hair_icon = icon(icon, "[species_name]_holder_[cache_entry]_hair")
				hair_icon.Blend(hair_colour, ICON_ADD)
				var/icon/eyes_icon = icon(icon, "[species_name]_holder_[cache_entry]_eyes")
				eyes_icon.Blend(eye_colour, ICON_ADD)

				// Blend them together.
				mob_icon.Blend(eyes_icon, ICON_OVERLAY)
				mob_icon.Blend(hair_icon, ICON_OVERLAY)

				// Add to the cache.
				holder_mob_icon_cache[cache_key] = mob_icon
			item_icons[cache_entry] = holder_mob_icon_cache[cache_key]

	// Handle the rest of sync().
	..(M)

/atom/proc/get_holding_mob()
	//This function will return the mob which is holding this holder, or null if it's not held
	//It recurses up the hierarchy out of containers until it reaches a mob, or a turf, or hits the limit
	var/x = 0//As a safety, we'll crawl up a maximum of five layers
	var/atom/a = src
	while (x < 5)
		x++
		if (isnull(a))
			return null

		a = a.loc
		if (istype(a, /turf))
			return null//We must be on a table or a floor, or maybe in a wall. Either way we're not held.

		if (istype(a, /mob))
			return a
		//If none of the above are true, we must be inside a box or backpack or something. Keep recursing up.

	return null//If we get here, the holder must be buried many layers deep in nested containers. Shouldn't happen
