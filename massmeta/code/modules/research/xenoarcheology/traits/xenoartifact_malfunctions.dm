//Malfunctions
//============
// Bear, produces a bear until it reaches its upper limit
//============
/datum/xenoartifact_trait/malfunction/bear
	label_name = "P.B.R." 
	label_desc = "Parallel Bearspace Retrieval: A strange malfunction causes the Artifact to open a gateway to deep bearspace."
	weight = 15
	flags = URANIUM_TRAIT
	var/bears //bear per bears

/datum/xenoartifact_trait/malfunction/bear/activate(obj/item/xenoartifact/X)
	if(bears < XENOA_MAX_BEARS)
		bears++
		var/mob/living/simple_animal/hostile/bear/new_bear = new(get_turf(X.loc))
		new_bear.name = pick("Freddy", "Bearington", "Smokey", "Beorn", "Pooh", "Paddington", "Winnie", "Baloo", "Rupert", "Yogi", "Fozzie", "Boo") //Why not?
		log_game("[X] spawned a (/mob/living/simple_animal/hostile/bear) at [world.time]. [X] located at [X.x] [X.y] [X.z]")
	else
		X.visible_message("<span class='danger'>The [X.name] shatters as bearspace collapses! Too many bears!</span>")
		var/obj/effect/decal/cleanable/ash/A = new(get_turf(X))
		A.color = X.material
		qdel(X)
	X.cooldown += 20 SECONDS

//============
// Badtarget, changes target to user
//============
/datum/xenoartifact_trait/malfunction/badtarget
	label_name = "Maltargeting"
	label_desc = "Maltargeting: A strange malfunction that causes the Artifact to always target the original user."
	flags = BLUESPACE_TRAIT | URANIUM_TRAIT | PLASMA_TRAIT

/datum/xenoartifact_trait/malfunction/badtarget/activate(obj/item/xenoartifact/X, atom/target, atom/user)
	var/mob/living/M
	if(isliving(user))
		M = user
	else if(isliving(user?.loc))
		M = user.loc
	else
		return
	X.true_target = X.process_target(M)
	X.cooldown += 5 SECONDS

//============
// Strip, moves a single clothing on target to floor
//============
/datum/xenoartifact_trait/malfunction/strip
	label_name = "B.A.D."
	label_desc = "Bluespace Axis Desync: A strange malfunction inside the Artifact causes it to shift the target's realspace position with its bluespace mass in an offset manner. This results in the target dropping all they're wearing. This is probably the plot to a very educational movie."
	flags = BLUESPACE_TRAIT | URANIUM_TRAIT

/datum/xenoartifact_trait/malfunction/strip/activate(obj/item/xenoartifact/X, atom/target)
	if(isliving(target))
		var/mob/living/carbon/victim = target
		var/list/clothing_list = list()
		//Im okay with this targetting clothing in other non-worn slots
		for(var/obj/item/clothing/I in victim.contents)
			clothing_list += I
		//Stops this from stripping funky stuff
		var/obj/item/clothing/C = pick(clothing_list)
		if(!HAS_TRAIT(C, TRAIT_NODROP))
			victim.dropItemToGround(C)
			X.cooldown += 10 SECONDS

//============
// Trauma, gives target trauma, amazing
//============
/datum/xenoartifact_trait/malfunction/trauma
	label_name = "C.D.E."
	label_desc = "Cerebral Dysfunction Emergence: A strange malfunction that causes the Artifact to force brain traumas to develop in a given target."
	flags = BLUESPACE_TRAIT | URANIUM_TRAIT
	weight = 25
	var/datum/brain_trauma/trauma

/datum/xenoartifact_trait/malfunction/trauma/on_init(obj/item/xenoartifact/X)
	trauma = pick(list(
			/datum/brain_trauma/mild/hallucinations, /datum/brain_trauma/mild/stuttering, /datum/brain_trauma/mild/dumbness,
			/datum/brain_trauma/mild/speech_impediment, /datum/brain_trauma/mild/concussion, /datum/brain_trauma/mild/muscle_weakness,
			/datum/brain_trauma/mild/expressive_aphasia, /datum/brain_trauma/severe/narcolepsy, /datum/brain_trauma/severe/discoordination,
			/datum/brain_trauma/severe/pacifism, /datum/brain_trauma/special/beepsky))

/datum/xenoartifact_trait/malfunction/trauma/activate(obj/item/xenoartifact/X, atom/target, atom/user)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.Unconscious(0.3 SECONDS)
		H.gain_trauma(trauma, TRAUMA_RESILIENCE_BASIC)
		X.cooldownmod += 10 SECONDS

//============
// Heated, causes artifact explode in flames
//============
/datum/xenoartifact_trait/malfunction/heated
	label_name = "Combustible" 
	label_desc = "Combustible: A strange malfunction that causes the Artifact to violently combust."
	weight = 15
	flags = URANIUM_TRAIT

/datum/xenoartifact_trait/malfunction/heated/activate(obj/item/xenoartifact/X, atom/target, atom/user)
	var/turf/T = get_turf(X)
	playsound(T, 'sound/effects/bamf.ogg', 50, TRUE) 
	for(var/turf/open/turf in RANGE_TURFS(max(1, 4*((X.charge*1.5)/100)), T))
		if(!locate(/obj/effect/safe_fire) in turf)
			new /obj/effect/safe_fire(turf)

//Lights on fire, does nothing else damage / atmos wise
/obj/effect/safe_fire
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	icon = 'icons/effects/fire.dmi'
	icon_state = "1"
	layer = GASFIRE_LAYER
	blend_mode = BLEND_ADD
	light_system = MOVABLE_LIGHT
	light_range = LIGHT_RANGE_FIRE
	light_power = 1
	light_color = LIGHT_COLOR_FIRE

/obj/effect/safe_fire/Initialize(mapload)
	. = ..()
	for(var/atom/AT in loc)
		if(!QDELETED(AT) && AT != src) // It's possible that the item is deleted in temperature_expose
			AT.fire_act(400, 50) //should be average enough to not do too much damage
	addtimer(CALLBACK(src, .proc/after_burn), 0.3 SECONDS)

/obj/effect/safe_fire/proc/after_burn()
	qdel(src)

//============
// Radioactive, makes the artifact more radioactive with use
//============
/datum/xenoartifact_trait/malfunction/radioactive
	label_name = "Radioactive"
	label_desc = "Radioactive: The Artifact Emmits harmful particles when a reaction takes place."
	flags = BLUESPACE_TRAIT | URANIUM_TRAIT | PLASMA_TRAIT

/datum/xenoartifact_trait/malfunction/radioactive/on_init(obj/item/xenoartifact/X)
	radiation_pulse(
		X,
		max_range = 1,
		threshold = RAD_VERY_LIGHT_INSULATION,
		chance = (URANIUM_IRRADIATION_CHANCE / 3),
		minimum_exposure_time = URANIUM_RADIATION_MINIMUM_EXPOSURE_TIME,
		)

/datum/xenoartifact_trait/malfunction/radioactive/on_item(obj/item/xenoartifact/X, atom/user, atom/item)
	if(istype(item, /obj/item/geiger_counter))
		to_chat(user, "<span class='notice'>The [X.name] has residual radioactive decay features.</span>")
		return TRUE
	..()

/datum/xenoartifact_trait/malfunction/radioactive/on_touch(obj/item/xenoartifact/X, mob/user)
	to_chat(user, "<span class='notice'>You feel pins and needles after touching the [X.name].</span>")
	return TRUE

/datum/xenoartifact_trait/malfunction/radioactive/activate(obj/item/xenoartifact/X)
	radiation_pulse(
		X,
		max_range = 1,
		threshold = RAD_VERY_LIGHT_INSULATION,
		chance = (URANIUM_IRRADIATION_CHANCE / 3),
		minimum_exposure_time = URANIUM_RADIATION_MINIMUM_EXPOSURE_TIME,
		)


//============
// twin, makes an evil twin of the target
//============
/datum/xenoartifact_trait/malfunction/twin
	label_name = "Anti-Cloning"
	label_desc = "Anti-Cloning: The Artifact produces an arguably maleviolent clone of target."
	flags = BLUESPACE_TRAIT | URANIUM_TRAIT | PLASMA_TRAIT

/datum/xenoartifact_trait/malfunction/twin/activate(obj/item/xenoartifact/X, mob/living/target, atom/user, setup)
	var/mob/living/simple_animal/hostile/twin/T = new(get_turf(X))
	//Setup appearence for evil twin
	T.name = target.name
	T.appearance = target.appearance
	if(istype(target) && length(target.vis_contents))
		T.add_overlay(target.vis_contents)
	T.alpha = 255
	T.pixel_y = initial(T.pixel_y)
	T.pixel_x = initial(T.pixel_x)
	T.color = COLOR_BLUE

/mob/living/simple_animal/hostile/twin
	name = "evil twin"
	desc = "It looks just like... someone!"
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	speak_chance = 0
	turns_per_move = 5
	response_help_continuous = "pokes"
	response_help_simple = "poke"
	response_help_continuous = "shoves"
	response_help_simple = "shove"
	response_help_continuous = "hits"
	response_help_simple = "hit"
	speed = 0
	maxHealth = 10
	health = 10
	melee_damage_lower = 1
	melee_damage_upper = 10
	attack_verb_continuous ="punches"
	attack_verb_simple ="punch"
	attack_sound = 'sound/weapons/punch1.ogg'
	combat_mode = TRUE
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 15
	faction = list("evil_clone")
	status_flags = CANPUSH
	del_on_death = TRUE

//============
// explode, a very small explosion takes place, destroying the artifact in the process
//============
/datum/xenoartifact_trait/malfunction/explode
	label_name = "Delaminating"
	label_desc = "Delaminating: The Artifact violently collapses, exploding."

/datum/xenoartifact_trait/malfunction/explode/activate(obj/item/xenoartifact/X, atom/target, atom/user, setup)
	. = ..()
	X.visible_message("<span class='warning'>The [X] begins to heat up, it's delaminating!</span>")
	apply_wibbly_filters(X, 3)
	addtimer(CALLBACK(src, .proc/explode, X), 10 SECONDS)

/datum/xenoartifact_trait/malfunction/explode/proc/explode(obj/item/xenoartifact/X)
	SSexplosions.explode(X, 0, 1, 2, 1)
	qdel(X)
