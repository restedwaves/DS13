/mob/observer/eye/signal
	name = "Signal"
	icon = 'icons/mob/eye.dmi'
	icon_state = "default-eye"

	movement_handlers = list(
		/datum/movement_handler/mob/incorporeal/eye
	)

/mob/observer/eye/signal/is_necromorph()
	return TRUE


//This will have a mob passed in that we were created from
/mob/observer/eye/signal/New(var/mob/body)
	..()
	visualnet = GLOB.necrovision	//Set the visualnet of course



	var/turf/T = get_turf(body)
	if(ismob(body))
		key = body.key
		possess(src) //Possess thyself
		if(body.mind && body.mind.name)
			name = body.mind.name
		else
			if(body.real_name)
				name = body.real_name
			else
				if(gender == MALE)
					name = capitalize(pick(GLOB.first_names_male)) + " " + capitalize(pick(GLOB.last_names))
				else
					name = capitalize(pick(GLOB.first_names_female)) + " " + capitalize(pick(GLOB.last_names))

		mind = body.mind	//we don't transfer the mind but we keep a reference to it.

	forceMove(T)





//Joining and leaving
//-------------------------------
/mob/observer/ghost/verb/join_marker_verb()
	set name = "Join Necromorph Horde"
	set category = "Necromorph"
	set desc = "Joins the necromorph team, and allows you to control horrible creatures."

	var/response = alert(src, "Would you like to join the necromorph side?", "Make us whole again", "Yes", "No")
	if (!response || response == "No")
		return

	join_marker()	//This cannot fail, do safety checks first

	qdel(src)



/mob/proc/join_marker()
	var/mob/observer/eye/signal/S = new(src)
	return S


/mob/observer/eye/signal/verb/leave_marker_verb()
	set name = "Leave Necromorph Horde"
	set category = "Necromorph"
	set desc = "Leaves the necromorph team, making you a normal ghost"

	//Lets not look like an eye after we become a ghost
	icon = 'icons/mob/mob.dmi'
	icon_state = "ghost"

	var/mob/observer/ghost/ghost = ghostize(0)
	qdel(src)
	return ghost



//Posession and evacuating
/mob/observer/eye/signal/verb/necro_possess(var/mob/living/L)
	set name = "Posess"
	set category = "Necromorph"
	set desc = "Take control of a necromorph vessel"

	if (!L.is_necromorph())
		to_chat(src, SPAN_DANGER("You can only posess necromorph units."))
		return

	if (L.client)
		to_chat(src, SPAN_DANGER("Error: [L.key] is already controlling [L]"))
		return

	//Seems clear
	L.key = key
	qdel(src)

/mob/proc/necro_evacuate()
	set name = "Evacuate"
	set category = "Necromorph"
	set desc = "Depart your body and return to the marker. You can go back and forth with ease"

	necro_ghost()


//Evacuates a mob from their body but makes them a marker signal instead of a normal ghost
/mob/proc/necro_ghost()
	var/signaltype = /mob/observer/eye/signal
	if (is_marker_master(src))	//If they are the marker's player, lets be sure to put them into the correct signal type
		signaltype = /mob/observer/eye/signal/master

	.=new signaltype(src)

	//If we're in some kind of observer body, delete it
	if (!isliving(src))
		qdel(src)


//Signals cant become signals, silly
/mob/observer/eye/signal/necro_ghost()
	return src


/mob/observer/eye/signal/Login()
	.=..()
	//Todo, check preferences for autoqueue here

	SSnecromorph.join_necroqueue(src)


/mob/observer/eye/signal/Logout()
	SSnecromorph.remove_from_necroqueue(src)
	.=..()

/mob/observer/eye/signal/Destroy()
	SSnecromorph.remove_from_necroqueue(src)
	.=..()