// Damage things. TODO: Merge these down to reduce on defines.
// Way to waste perfectly good damage-type names (BRUTE) on this... If you were really worried about case sensitivity, you could have just used lowertext(damagetype) in the proc.
#define BRUTE       "brute"
#define BURN        "fire"
#define TOX         "tox"
#define OXY         "oxy"
#define CLONE       "clone"
#define PAIN        "pain"
#define ELECTROCUTE "electrocute"
#define BLAST	  "blast"

#define CUT       "cut"
#define BRUISE    "bruise"
#define PIERCE    "pierce"
#define LASER     "laser"
#define SHATTER   "shatter"

#define STUN      "stun"
#define WEAKEN    "weaken"
#define PARALYZE  "paralize"
#define IRRADIATE "irradiate"
#define SLUR      "slur"
#define STUTTER   "stutter"
#define EYE_BLUR  "eye_blur"
#define DROWSY    "drowsy"

// Damage flags
#define DAM_SHARP  (1<<0)
#define DAM_EDGE   (1<<1)
#define DAM_LASER  (1<<2)
#define DAM_TIER_1 (1<<3)
#define DAM_TIER_2 (1<<4)
#define DAM_TIER_3 (1<<5)

#define FIRE_DAMAGE_MODIFIER 0.0215 // Higher values result in more external fire damage to the skin. (default 0.0215)
#define  AIR_DAMAGE_MODIFIER 2.025  // More means less damage from hot air scalding lungs, less = more damage. (default 2.025)

// Organ defines.
#define ORGAN_CUT_AWAY   (1<<0)  // The organ is in the process of being surgically removed.
#define ORGAN_BLEEDING   (1<<1)  // The organ is currently bleeding.
#define ORGAN_BROKEN     (1<<2)  // The organ is broken.
#define ORGAN_DEAD       (1<<3)  // The organ is necrotic.
#define ORGAN_MUTATED    (1<<4)  // The organ is unusable due to genetic damage.
#define ORGAN_ARTERY_CUT (1<<6)  // The organ has had its artery cut.
#define ORGAN_TENDON_CUT (1<<7)  // The organ has had its tendon cut.
#define ORGAN_DISFIGURED (1<<8)  // The organ is scarred/disfigured. Alters whether or not the face can be recognised.
#define ORGAN_SABOTAGED  (1<<9)  // The organ will explode if exposed to EMP, if prosthetic.
#define ORGAN_ASSISTED   (1<<10) // The organ is partially prosthetic. No mechanical effect.
#define ORGAN_ROBOTIC    (1<<11) // The organ is robotic. Changes numerous behaviors, search BP_IS_ROBOTIC for checks.
#define ORGAN_BRITTLE    (1<<12) // The organ takes additional blunt damage. If robotic, cannot be repaired through normal means.
#define ORGAN_CRYSTAL    (1<<13) // The organ does not suffer laser damage, but shatters on droplimb.

//A locomotion that has any of these flags will slow down the owner
#define ORGAN_IMPAIRED_LOCOMOTION	(ORGAN_CUT_AWAY|ORGAN_BROKEN|ORGAN_DEAD|ORGAN_TENDON_CUT)

// Organ flag defines.
#define ORGAN_FLAG_CAN_AMPUTATE   (1<<0) // The organ can be amputated.
#define ORGAN_FLAG_CAN_BREAK      (1<<1) // The organ can be broken.
#define ORGAN_FLAG_CAN_GRASP      (1<<2) // The organ contributes to grasping.
#define ORGAN_FLAG_CAN_STAND      (1<<3) // The organ contributes to standing.
#define ORGAN_FLAG_HAS_TENDON     (1<<4) // The organ can have its tendon cut.
#define ORGAN_FLAG_FINGERPRINT    (1<<5) // The organ has a fingerprint.
#define ORGAN_FLAG_GENDERED_ICON  (1<<6) // The icon state for this organ appends _m/_f.
#define ORGAN_FLAG_HEALS_OVERKILL (1<<7) // The organ heals from overkill damage.

// Droplimb types.
#define DROPLIMB_EDGE 0
#define DROPLIMB_BLUNT 1
#define DROPLIMB_BURN 2

// Robotics hatch_state defines.
#define HATCH_CLOSED 0
#define HATCH_UNSCREWED 1
#define HATCH_OPENED 2

// These control the amount of blood lost from burns. The loss is calculated so
// that dealing just enough burn damage to kill the player will cause the given
// proportion of their max blood volume to be lost
// (e.g. 0.6 == 60% lost if 200 burn damage is taken).
#define FLUIDLOSS_WIDE_BURN 0.6 //for burns from heat applied over a wider area, like from fire
#define FLUIDLOSS_CONC_BURN 0.4 //for concentrated burns, like from lasers

// Damage above this value must be repaired with surgery.
#define ROBOLIMB_SELF_REPAIR_CAP 30

//Germs and infections.
#define GERM_LEVEL_AMBIENT  0 // germs are now pretty much disabled
#define GERM_LEVEL_MOVE_CAP 0

#define INFECTION_LEVEL_ONE   2500000
#define INFECTION_LEVEL_TWO   5000000 // infections are now pretty much disabled
#define INFECTION_LEVEL_THREE 10000000

//Blood levels. These are percentages based on the species blood_volume far.
#define BLOOD_VOLUME_SAFE    55
#define BLOOD_VOLUME_OKAY    45
#define BLOOD_VOLUME_BAD     35
#define BLOOD_VOLUME_SURVIVE 25


//These are pretty dumb. Incision stage of an organ is defined by having an open wound which has this proportion of the organ's max damage
#define DAMAGE_MULT_INCISION	0.4
#define DAMAGE_MULT_RETRACTED 	0.6

//Values for the encased var
#define ENCASED_CLOSED	1
#define ENCASED_OPEN	2

//These control the damage thresholds for the various ways of removing limbs
#define DROPLIMB_THRESHOLD_EDGE 5
#define DROPLIMB_THRESHOLD_TEAROFF 2
#define DROPLIMB_THRESHOLD_DESTROY 1
#define DROPLIMB_THRESHOLD_BURN 0.33

#define DROPLIMB_CUMULATIVE_TEAROFF	0.9
#define DROPLIMB_CUMULATIVE_BREAKOFF	1.25
#define DROPLIMB_CUMULATIVE_DESTROY	1.75
#define DROPLIMB_CUMULATIVE_BURN 3

#define ORGAN_RECOVERY_THRESHOLD (5 MINUTES)

#define UPPERBODY	"upper"
#define LOWERBODY 	"lower"