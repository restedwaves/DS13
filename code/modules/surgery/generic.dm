//Procedures in this file: Gneric surgery steps
//////////////////////////////////////////////////////////////////
//						COMMON STEPS							//
//////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////
//	generic surgery step datum
//////////////////////////////////////////////////////////////////
/datum/surgery_step/generic/
	can_infect = 1
	shock_level = 10

/datum/surgery_step/generic/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (isslime(target))
		return 0
	if (target_zone == BP_EYES)	//there are specific steps for eye surgery
		return 0
	if (!hasorgans(target))
		return 0
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if (affected == null)
		return 0
	if (affected.is_stump())
		return 0
	return !(BP_IS_ROBOTIC(affected) || BP_IS_CRYSTAL(affected))

//////////////////////////////////////////////////////////////////
//	laser scalpel surgery step
//	acts as both cutting and bleeder clamping surgery steps
//////////////////////////////////////////////////////////////////
/datum/surgery_step/generic/cut_with_laser
	allowed_tools = list(
	/obj/item/tool/scalpel/laser = 95, \
	/obj/item/tool/scalpel/advanced = 85, \
	/obj/item/energy/sword = 5
	)
	priority = 2
	min_duration = 90
	max_duration = 110

/datum/surgery_step/generic/cut_with_laser/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		return affected && affected.how_open() == SURGERY_CLOSED && target_zone != BP_MOUTH

/datum/surgery_step/generic/cut_with_laser/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts the bloodless incision on [target]'s [affected.name] with \the [tool].", \
	"You start the bloodless incision on [target]'s [affected.name] with \the [tool].")
	target.custom_pain("You feel a horrible, searing pain in your [affected.name]!",50, affecting = affected)
	..()

/datum/surgery_step/generic/cut_with_laser/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] has made a bloodless incision on [target]'s [affected.name] with \the [tool].</span>", \
	"<span class='notice'>You have made a bloodless incision on [target]'s [affected.name] with \the [tool].</span>",)
	affected.createwound(CUT, affected.min_broken_damage*DAMAGE_MULT_INCISION, 1, forced_type = /datum/wound/cut/incision)
	affected.clamp_wounds()
	spread_germs_to_organ(affected, user)

/datum/surgery_step/generic/cut_with_laser/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips as the blade sputters, searing a long gash in [target]'s [affected.name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips as the blade sputters, searing a long gash in [target]'s [affected.name] with \the [tool]!</span>")
	affected.take_external_damage(15, 5, (DAM_SHARP|DAM_EDGE), used_weapon = tool)

//////////////////////////////////////////////////////////////////
//	laser scalpel surgery step
//	acts as the cutting, bleeder clamping, and retractor surgery steps
//////////////////////////////////////////////////////////////////
/datum/surgery_step/generic/incision_manager
	allowed_tools = list(
	/obj/item/tool/scalpel/manager = 100
	)
	priority = 2
	min_duration = 80
	max_duration = 120

/datum/surgery_step/generic/incision_manager/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		return affected && affected.how_open() == SURGERY_CLOSED && target_zone != BP_MOUTH

/datum/surgery_step/generic/incision_manager/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts to construct a prepared incision on and within [target]'s [affected.name] with \the [tool].", \
	"You start to construct a prepared incision on and within [target]'s [affected.name] with \the [tool].")
	target.custom_pain("You feel a horrible, searing pain in your [affected.name] as it is pushed apart!",50, affecting = affected)
	..()

/datum/surgery_step/generic/incision_manager/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	user.visible_message("<span class='notice'>[user] has constructed a prepared incision on and within [target]'s [affected.name] with \the [tool].</span>", \
	"<span class='notice'>You have constructed a prepared incision on and within [target]'s [affected.name] with \the [tool].</span>",)

	affected.createwound(CUT, affected.min_broken_damage*DAMAGE_MULT_INCISION, 1, forced_type = /datum/wound/cut/incision) // incision
	affected.clamp_wounds() // clamp
	affected.open_incision() // retract

/datum/surgery_step/generic/incision_manager/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand jolts as the system sparks, ripping a gruesome hole in [target]'s [affected.name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand jolts as the system sparks, ripping a gruesome hole in [target]'s [affected.name] with \the [tool]!</span>")
	affected.take_external_damage(20, 15, (DAM_SHARP|DAM_EDGE), used_weapon = tool)

//////////////////////////////////////////////////////////////////
//	 scalpel surgery step
//////////////////////////////////////////////////////////////////
/datum/surgery_step/generic/cut_open
	allowed_tools = list(
	/obj/item/tool/scalpel = 100,		\
	/obj/item/material/knife = 75,	\
	/obj/item/material/kitchen/utensil/knife = 75,	\
	/obj/item/broken_bottle = 50,
	/obj/item/material/shard = 50, 		\
	)

	min_duration = 90
	max_duration = 110

/datum/surgery_step/generic/cut_open/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		if(!istype(affected))
			return
		if(affected.how_open())
			var/datum/wound/cut/incision = affected.get_incision()
			to_chat(user, "<span class='notice'>The [incision.desc] provides enough access, another incision isn't needed.</span>")
			return SURGERY_FAILURE
		return target_zone != BP_MOUTH

/datum/surgery_step/generic/cut_open/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts the incision on [target]'s [affected.name] with \the [tool].", \
	"You start the incision on [target]'s [affected.name] with \the [tool].")
	target.custom_pain("You feel a horrible pain as if from a sharp knife in your [affected.name]!",40, affecting = affected)
	..()

/datum/surgery_step/generic/cut_open/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] has made an incision on [target]'s [affected.name] with \the [tool].</span>", \
	"<span class='notice'>You have made an incision on [target]'s [affected.name] with \the [tool].</span>",)
	affected.createwound(CUT, affected.min_broken_damage*DAMAGE_MULT_INCISION, 1, forced_type = /datum/wound/cut/incision)
	playsound(target.loc, 'sound/weapons/bladeslice.ogg', 15, 1)

/datum/surgery_step/generic/cut_open/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, slicing open [target]'s [affected.name] in the wrong place with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, slicing open [target]'s [affected.name] in the wrong place with \the [tool]!</span>")
	affected.take_external_damage(10, 0, (DAM_SHARP|DAM_EDGE), used_weapon = tool)

/datum/surgery_step/generic/cut_open/success_chance(mob/living/user, mob/living/carbon/human/target, obj/item/tool)
	. = ..()
	if(user.skill_check(SKILL_ANATOMY, SKILL_ADEPT))
		. += 10

//////////////////////////////////////////////////////////////////
//	 bleeder clamping surgery step
//////////////////////////////////////////////////////////////////
/datum/surgery_step/generic/clamp_bleeders
	allowed_tools = list(
	/obj/item/tool/hemostat = 100,	\
	/obj/item/stack/cable_coil = 75, 	\
	/obj/item/assembly/mousetrap = 20
	)

	min_duration = 40
	max_duration = 60

/datum/surgery_step/generic/clamp_bleeders/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		return affected && affected.how_open() && !affected.clamped()

/datum/surgery_step/generic/clamp_bleeders/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts clamping bleeders in [target]'s [affected.name] with \the [tool].", \
	"You start clamping bleeders in [target]'s [affected.name] with \the [tool].")
	target.custom_pain("The pain in your [affected.name] is maddening!",40, affecting = affected)
	..()

/datum/surgery_step/generic/clamp_bleeders/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] clamps bleeders in [target]'s [affected.name] with \the [tool].</span>",	\
	"<span class='notice'>You clamp bleeders in [target]'s [affected.name] with \the [tool].</span>")
	affected.clamp_wounds()
	spread_germs_to_organ(affected, user)
	playsound(target.loc, 'sound/items/Welder.ogg', 15, 1)

/datum/surgery_step/generic/clamp_bleeders/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, tearing blood vessals and causing massive bleeding in [target]'s [affected.name] with \the [tool]!</span>",	\
	"<span class='warning'>Your hand slips, tearing blood vessels and causing massive bleeding in [target]'s [affected.name] with \the [tool]!</span>",)
	affected.take_external_damage(10, 0, (DAM_SHARP|DAM_EDGE), used_weapon = tool)

//////////////////////////////////////////////////////////////////
//	 retractor surgery step
//////////////////////////////////////////////////////////////////
/datum/surgery_step/generic/retract_skin
	allowed_tools = list(
	/obj/item/tool/retractor = 100, 	\
	/obj/item/tool/crowbar = 75,
	/obj/item/material/knife = 50,	\
	/obj/item/material/kitchen/utensil/fork = 50
	)

	priority = 1
	min_duration = 30
	max_duration = 40

/datum/surgery_step/generic/retract_skin/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		return affected && affected.how_open() == SURGERY_OPEN //&& !(affected.status & ORGAN_BLEEDING)

/datum/surgery_step/generic/retract_skin/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts to pry open the incision on [target]'s [affected.name] with \the [tool].",	\
	"You start to pry open the incision on [target]'s [affected.name] with \the [tool].")
	target.custom_pain("It feels like the skin on your [affected.name] is on fire!",40,affecting = affected)
	..()

/datum/surgery_step/generic/retract_skin/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] keeps the incision open on [target]'s [affected.name] with \the [tool].</span>",	\
	"<span class='notice'>You keep the incision open on [target]'s [affected.name] with \the [tool].</span>")
	affected.open_incision()

/datum/surgery_step/generic/retract_skin/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, tearing the edges of the incision on [target]'s [affected.name] with \the [tool]!</span>",	\
	"<span class='warning'>Your hand slips, tearing the edges of the incision on [target]'s [affected.name] with \the [tool]!</span>")
	affected.take_external_damage(12, 0, (DAM_SHARP|DAM_EDGE), used_weapon = tool)

//////////////////////////////////////////////////////////////////
//	 skin cauterization surgery step
//////////////////////////////////////////////////////////////////
/datum/surgery_step/generic/cauterize
	allowed_tools = list(
	/obj/item/tool/cautery = 100,			\
	/obj/item/clothing/mask/smokable/cigarette = 75,	\
	/obj/item/flame/lighter = 60,			\
	/obj/item/tool/weldingtool = 35
	)

	min_duration = 70
	max_duration = 100

/datum/surgery_step/generic/cauterize/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

	if(target_zone == BP_MOUTH || target_zone == BP_EYES)
		return FALSE
	if(!hasorgans(target))
		return FALSE
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(!affected)
		return FALSE
	if(BP_IS_ROBOTIC(affected))
		return FALSE
	if(!affected.get_incision(1))
		to_chat(user, "<span class='warning'>There are no incisions on [target]'s [affected.name] that can be closed cleanly with \the [tool]!</span>")
		return SURGERY_FAILURE
	if(affected.is_stump()) // Copypasting some stuff here to avoid having to modify ..() for a single surgery
		return affected.status & ORGAN_ARTERY_CUT
	else
		return affected.how_open()


/datum/surgery_step/generic/cauterize/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/datum/wound/cut/W = affected.get_incision()
	user.visible_message("[user] is beginning to cauterize[W ? " \a [W.desc] on" : ""] \the [target]'s [affected.name] with \the [tool]." , \
	"You are beginning to cauterize[W ? " \a [W.desc] on" : ""] \the [target]'s [affected.name] with \the [tool].")
	target.custom_pain("Your [affected.name] is being burned!",40,affecting = affected)
	..()

/datum/surgery_step/generic/cauterize/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/datum/wound/cut/W = affected.get_incision()
	user.visible_message("<span class='notice'>[user] cauterizes[W ? " \a [W.desc] on" : ""] \the [target]'s [affected.name] with \the [tool].</span>", \
	"<span class='notice'>You cauterize[W ? " \a [W.desc] on" : ""] \the [target]'s [affected.name] with \the [tool].</span>")
	if(W)
		W.close()
	if(affected.is_stump())
		affected.status &= ~ORGAN_ARTERY_CUT
	if(affected.clamped())
		affected.remove_clamps()

/datum/surgery_step/generic/cauterize/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, leaving a small burn on [target]'s [affected.name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, leaving a small burn on [target]'s [affected.name] with \the [tool]!</span>")
	affected.take_external_damage(0, 3, used_weapon = tool)

//////////////////////////////////////////////////////////////////
//	 limb amputation surgery step
//////////////////////////////////////////////////////////////////
/datum/surgery_step/generic/amputate
	allowed_tools = list(
	/obj/item/tool/saw/advanced_circular = 120,
	/obj/item/tool/saw/circular = 100,	//The specific circular saw is best, but less delicate tools will do too
	/obj/item/tool/saw = 75,
	/obj/item/tool/pickaxe/laser = 60
	)

	min_duration = 110
	max_duration = 160

/datum/surgery_step/generic/amputate/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (target_zone == BP_EYES)	//there are specific steps for eye surgery
		return 0
	if (!hasorgans(target))
		return 0
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if (affected == null)
		return 0
	if (!(affected.limb_flags & ORGAN_FLAG_CAN_AMPUTATE))
		return 0
	if (affected.how_open())
		to_chat(user,"<span class='warning'>You can't get a clean cut with incisions getting in the way.</span>")
		return 0
	return TRUE

/datum/surgery_step/generic/amputate/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] is beginning to amputate [target]'s [affected.name] with \the [tool]." , \
	"<FONT size=3>You are beginning to cut through [target]'s [affected.amputation_point] with \the [tool].</FONT>")
	target.custom_pain("Your [affected.amputation_point] is being ripped apart!",100,affecting = affected)
	..()

/datum/surgery_step/generic/amputate/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] amputates [target]'s [affected.name] at the [affected.amputation_point] with \the [tool].</span>", \
	"<span class='notice'>You amputate [target]'s [affected.name] with \the [tool].</span>")
	affected.droplimb(1,DROPLIMB_EDGE)

/datum/surgery_step/generic/amputate/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, sawing through the bone in [target]'s [affected.name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, sawwing through the bone in [target]'s [affected.name] with \the [tool]!</span>")
	affected.take_external_damage(5, 0, (DAM_SHARP|DAM_EDGE), used_weapon = tool)
