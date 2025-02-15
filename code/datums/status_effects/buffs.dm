//Largely beneficial effects go here, even if they have drawbacks.

/datum/status_effect/his_grace
	id = "his_grace"
	duration = -1
	tick_interval = 4
	alert_type = /atom/movable/screen/alert/status_effect/his_grace
	var/bloodlust = 0

/atom/movable/screen/alert/status_effect/his_grace
	name = "His Grace"
	desc = "His Grace hungers, and you must feed Him."
	icon_state = "his_grace"
	alerttooltipstyle = "hisgrace"

/atom/movable/screen/alert/status_effect/his_grace/MouseEntered(location,control,params)
	desc = initial(desc)
	var/datum/status_effect/his_grace/HG = attached_effect
	desc += "<br><font size=3><b>Current Bloodthirst: [HG.bloodlust]</b></font>\
	<br>Becomes undroppable at <b>[HIS_GRACE_FAMISHED]</b>\
	<br>Will consume you at <b>[HIS_GRACE_CONSUME_OWNER]</b>"
	return ..()

/datum/status_effect/his_grace/on_apply()
	owner.log_message("gained His Grace's stun immunity", LOG_ATTACK)
	owner.add_stun_absorption("hisgrace", INFINITY, 3, null, "His Grace protects you from the stun!")
	return ..()

/datum/status_effect/his_grace/tick()
	bloodlust = 0
	var/graces = 0
	for(var/obj/item/his_grace/HG in owner.held_items)
		if(HG.bloodthirst > bloodlust)
			bloodlust = HG.bloodthirst
		if(HG.awakened)
			graces++
	if(!graces)
		owner.apply_status_effect(/datum/status_effect/his_wrath)
		qdel(src)
		return
	var/grace_heal = bloodlust * 0.05
	owner.adjustBruteLoss(-grace_heal)
	owner.adjustFireLoss(-grace_heal)
	owner.adjustToxLoss(-grace_heal, TRUE, TRUE)
	owner.adjustOxyLoss(-(grace_heal * 2))
	owner.adjustCloneLoss(-grace_heal)

/datum/status_effect/his_grace/on_remove()
	owner.log_message("lost His Grace's stun immunity", LOG_ATTACK)
	if(islist(owner.stun_absorption) && owner.stun_absorption["hisgrace"])
		owner.stun_absorption -= "hisgrace"


/datum/status_effect/wish_granters_gift //Fully revives after ten seconds.
	id = "wish_granters_gift"
	duration = 50
	alert_type = /atom/movable/screen/alert/status_effect/wish_granters_gift

/datum/status_effect/wish_granters_gift/on_apply()
	to_chat(owner, span_notice("Death is not your end! The Wish Granter's energy suffuses you, and you begin to rise..."))
	return ..()


/datum/status_effect/wish_granters_gift/on_remove()
	owner.revive(ADMIN_HEAL_ALL)
	owner.visible_message(span_warning("[owner] appears to wake from the dead, having healed all wounds!"), span_notice("You have regenerated."))


/atom/movable/screen/alert/status_effect/wish_granters_gift
	name = "Wish Granter's Immortality"
	desc = "You are being resurrected!"
	icon_state = "wish_granter"

/datum/status_effect/cult_master
	id = "The Cult Master"
	duration = -1
	alert_type = null
	on_remove_on_mob_delete = TRUE
	var/alive = TRUE

/datum/status_effect/cult_master/proc/deathrattle()
	if(!QDELETED(GLOB.cult_narsie))
		return //if Nar'Sie is alive, don't even worry about it
	var/area/A = get_area(owner)
	for(var/datum/mind/B as anything in get_antag_minds(/datum/antagonist/cult))
		if(isliving(B.current))
			var/mob/living/M = B.current
			SEND_SOUND(M, sound('sound/hallucinations/veryfar_noise.ogg'))
			to_chat(M, span_cultlarge("The Cult's Master, [owner], has fallen in \the [A]!"))

/datum/status_effect/cult_master/tick()
	if(owner.stat != DEAD && !alive)
		alive = TRUE
		return
	if(owner.stat == DEAD && alive)
		alive = FALSE
		deathrattle()

/datum/status_effect/cult_master/on_remove()
	deathrattle()
	. = ..()

/datum/status_effect/blooddrunk
	id = "blooddrunk"
	duration = 10
	tick_interval = 0
	alert_type = /atom/movable/screen/alert/status_effect/blooddrunk

/atom/movable/screen/alert/status_effect/blooddrunk
	name = "Blood-Drunk"
	desc = "You are drunk on blood! Your pulse thunders in your ears! Nothing can harm you!" //not true, and the item description mentions its actual effect
	icon_state = "blooddrunk"

/datum/status_effect/blooddrunk/on_apply()
	. = ..()
	if(.)
		ADD_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, BLOODDRUNK_TRAIT)
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.physiology.brute_mod *= 0.1
			H.physiology.burn_mod *= 0.1
			H.physiology.tox_mod *= 0.1
			H.physiology.oxy_mod *= 0.1
			H.physiology.clone_mod *= 0.1
			H.physiology.stamina_mod *= 0.1
		owner.log_message("gained blood-drunk stun immunity", LOG_ATTACK)
		owner.add_stun_absorption("blooddrunk", INFINITY, 4)
		owner.playsound_local(get_turf(owner), 'sound/effects/singlebeat.ogg', 40, 1, use_reverb = FALSE)

/datum/status_effect/blooddrunk/on_remove()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.physiology.brute_mod *= 10
		H.physiology.burn_mod *= 10
		H.physiology.tox_mod *= 10
		H.physiology.oxy_mod *= 10
		H.physiology.clone_mod *= 10
		H.physiology.stamina_mod *= 10
	owner.log_message("lost blood-drunk stun immunity", LOG_ATTACK)
	REMOVE_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, BLOODDRUNK_TRAIT);
	if(islist(owner.stun_absorption) && owner.stun_absorption["blooddrunk"])
		owner.stun_absorption -= "blooddrunk"

//Used by changelings to rapidly heal
//Heals 10 brute and oxygen damage every second, and 5 fire
//Being on fire will suppress this healing
/datum/status_effect/fleshmend
	id = "fleshmend"
	duration = 10 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/fleshmend

/datum/status_effect/fleshmend/on_apply()
	. = ..()
	if(iscarbon(owner))
		var/mob/living/carbon/carbon_owner = owner
		QDEL_LAZYLIST(carbon_owner.all_scars)

	RegisterSignal(owner, COMSIG_LIVING_IGNITED, PROC_REF(on_ignited))
	RegisterSignal(owner, COMSIG_LIVING_EXTINGUISHED, PROC_REF(on_extinguished))

/datum/status_effect/fleshmend/on_creation(mob/living/new_owner, ...)
	. = ..()
	if(!. || !owner || !linked_alert)
		return
	if(owner.on_fire)
		linked_alert.icon_state = "fleshmend_fire"

/datum/status_effect/fleshmend/on_remove()
	UnregisterSignal(owner, list(COMSIG_LIVING_IGNITED, COMSIG_LIVING_EXTINGUISHED))

/datum/status_effect/fleshmend/tick()
	if(owner.on_fire)
		return

	owner.adjustBruteLoss(-10, FALSE)
	owner.adjustFireLoss(-5, FALSE)
	owner.adjustOxyLoss(-10)

/datum/status_effect/fleshmend/proc/on_ignited(datum/source)
	SIGNAL_HANDLER

	linked_alert?.icon_state = "fleshmend_fire"

/datum/status_effect/fleshmend/proc/on_extinguished(datum/source)
	SIGNAL_HANDLER

	linked_alert?.icon_state = "fleshmend"

/atom/movable/screen/alert/status_effect/fleshmend
	name = "Fleshmend"
	desc = "Our wounds are rapidly healing. <i>This effect is prevented if we are on fire.</i>"
	icon_state = "fleshmend"

/datum/status_effect/exercised
	id = "Exercised"
	duration = 1200
	alert_type = null
	processing_speed = STATUS_EFFECT_NORMAL_PROCESS

//Hippocratic Oath: Applied when the Rod of Asclepius is activated.
/datum/status_effect/hippocratic_oath
	id = "Hippocratic Oath"
	status_type = STATUS_EFFECT_UNIQUE
	duration = -1
	tick_interval = 25
	alert_type = null

	var/datum/component/aura_healing/aura_healing
	var/hand
	var/deathTick = 0

/datum/status_effect/hippocratic_oath/on_apply()
	var/static/list/organ_healing = list(
		ORGAN_SLOT_BRAIN = 1.4,
	)

	aura_healing = owner.AddComponent( \
		/datum/component/aura_healing, \
		range = 7, \
		brute_heal = 1.4, \
		burn_heal = 1.4, \
		toxin_heal = 1.4, \
		suffocation_heal = 1.4, \
		stamina_heal = 1.4, \
		clone_heal = 0.4, \
		simple_heal = 1.4, \
		organ_healing = organ_healing, \
		healing_color = "#375637", \
	)

	//Makes the user passive, it's in their oath not to harm!
	ADD_TRAIT(owner, TRAIT_PACIFISM, HIPPOCRATIC_OATH_TRAIT)
	var/datum/atom_hud/med_hud = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	med_hud.show_to(owner)
	return ..()

/datum/status_effect/hippocratic_oath/on_remove()
	QDEL_NULL(aura_healing)
	REMOVE_TRAIT(owner, TRAIT_PACIFISM, HIPPOCRATIC_OATH_TRAIT)
	var/datum/atom_hud/med_hud = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	med_hud.hide_from(owner)

/datum/status_effect/hippocratic_oath/get_examine_text()
	return span_notice("[owner.p_they(TRUE)] seem[owner.p_s()] to have an aura of healing and helpfulness about [owner.p_them()].")

/datum/status_effect/hippocratic_oath/tick()
	if(owner.stat == DEAD)
		if(deathTick < 4)
			deathTick += 1
		else
			consume_owner()
	else
		if(iscarbon(owner))
			var/mob/living/carbon/itemUser = owner
			var/obj/item/heldItem = itemUser.get_item_for_held_index(hand)
			if(heldItem == null || heldItem.type != /obj/item/rod_of_asclepius) //Checks to make sure the rod is still in their hand
				var/obj/item/rod_of_asclepius/newRod = new(itemUser.loc)
				newRod.activated()
				if(!itemUser.has_hand_for_held_index(hand))
					//If user does not have the corresponding hand anymore, give them one and return the rod to their hand
					if(((hand % 2) == 0))
						var/obj/item/bodypart/L = itemUser.newBodyPart(BODY_ZONE_R_ARM, FALSE, FALSE)
						if(L.try_attach_limb(itemUser))
							L.update_limb(is_creating = TRUE)
							itemUser.update_body_parts()
							itemUser.put_in_hand(newRod, hand, forced = TRUE)
						else
							qdel(L)
							consume_owner() //we can't regrow, abort abort
							return
					else
						var/obj/item/bodypart/L = itemUser.newBodyPart(BODY_ZONE_L_ARM, FALSE, FALSE)
						if(L.try_attach_limb(itemUser))
							L.update_limb(is_creating = TRUE)
							itemUser.update_body_parts()
							itemUser.put_in_hand(newRod, hand, forced = TRUE)
						else
							qdel(L)
							consume_owner() //see above comment
							return
					to_chat(itemUser, span_notice("Your arm suddenly grows back with the Rod of Asclepius still attached!"))
				else
					//Otherwise get rid of whatever else is in their hand and return the rod to said hand
					itemUser.put_in_hand(newRod, hand, forced = TRUE)
					to_chat(itemUser, span_notice("The Rod of Asclepius suddenly grows back out of your arm!"))
			//Because a servant of medicines stops at nothing to help others, lets keep them on their toes and give them an additional boost.
			if(itemUser.health < itemUser.maxHealth)
				new /obj/effect/temp_visual/heal(get_turf(itemUser), "#375637")
			itemUser.adjustBruteLoss(-1.5)
			itemUser.adjustFireLoss(-1.5)
			itemUser.adjustToxLoss(-1.5, forced = TRUE) //Because Slime People are people too
			itemUser.adjustOxyLoss(-1.5, forced = TRUE)
			itemUser.adjustStaminaLoss(-1.5)
			itemUser.adjustOrganLoss(ORGAN_SLOT_BRAIN, -1.5)
			itemUser.adjustCloneLoss(-0.5) //Becasue apparently clone damage is the bastion of all health

/datum/status_effect/hippocratic_oath/proc/consume_owner()
	owner.visible_message(span_notice("[owner]'s soul is absorbed into the rod, relieving the previous snake of its duty."))
	var/list/chems = list(/datum/reagent/medicine/sal_acid, /datum/reagent/medicine/c2/convermol, /datum/reagent/medicine/oxandrolone)
	var/mob/living/simple_animal/hostile/retaliate/snake/healSnake = new(owner.loc, pick(chems))
	healSnake.name = "Asclepius's Snake"
	healSnake.real_name = "Asclepius's Snake"
	healSnake.desc = "A mystical snake previously trapped upon the Rod of Asclepius, now freed of its burden. Unlike the average snake, its bites contain chemicals with minor healing properties."
	new /obj/effect/decal/cleanable/ash(owner.loc)
	new /obj/item/rod_of_asclepius(owner.loc)
	owner.investigate_log("has been consumed by the Rod of Asclepius.", INVESTIGATE_DEATHS)
	qdel(owner)


/datum/status_effect/good_music
	id = "Good Music"
	alert_type = null
	duration = 6 SECONDS
	tick_interval = 1 SECONDS
	status_type = STATUS_EFFECT_REFRESH

/datum/status_effect/good_music/tick()
	if(owner.can_hear())
		owner.adjust_dizzy(-4 SECONDS)
		owner.adjust_jitter(-4 SECONDS)
		owner.adjust_confusion(-1 SECONDS)
		owner.add_mood_event("goodmusic", /datum/mood_event/goodmusic)

/atom/movable/screen/alert/status_effect/regenerative_core
	name = "Regenerative Core Tendrils"
	desc = "You can move faster than your broken body could normally handle!"
	icon_state = "regenerative_core"

/datum/status_effect/regenerative_core
	id = "Regenerative Core"
	duration = 1 MINUTES
	status_type = STATUS_EFFECT_REPLACE
	alert_type = /atom/movable/screen/alert/status_effect/regenerative_core

/datum/status_effect/regenerative_core/on_apply()
	ADD_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, STATUS_EFFECT_TRAIT)
	owner.adjustBruteLoss(-25)
	owner.adjustFireLoss(-25)
	owner.fully_heal(HEAL_CC_STATUS)
	owner.bodytemperature = owner.get_body_temp_normal()
	if(ishuman(owner))
		var/mob/living/carbon/human/humi = owner
		humi.set_coretemperature(humi.get_body_temp_normal())
	return TRUE

/datum/status_effect/regenerative_core/on_remove()
	REMOVE_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, STATUS_EFFECT_TRAIT)

/datum/status_effect/lightningorb
	id = "Lightning Orb"
	duration = 30 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/lightningorb

/datum/status_effect/lightningorb/on_apply()
	. = ..()
	owner.add_movespeed_modifier(/datum/movespeed_modifier/yellow_orb)
	to_chat(owner, span_notice("You feel fast!"))

/datum/status_effect/lightningorb/on_remove()
	. = ..()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/yellow_orb)
	to_chat(owner, span_notice("You slow down."))

/atom/movable/screen/alert/status_effect/lightningorb
	name = "Lightning Orb"
	desc = "The speed surges through you!"
	icon_state = "lightningorb"

/datum/status_effect/mayhem
	id = "Mayhem"
	duration = 2 MINUTES
	/// The chainsaw spawned by the status effect
	var/obj/item/chainsaw/doomslayer/chainsaw

/datum/status_effect/mayhem/on_apply()
	. = ..()
	to_chat(owner, "<span class='reallybig redtext'>RIP AND TEAR</span>")
	SEND_SOUND(owner, sound('sound/hallucinations/veryfar_noise.ogg'))
	owner.cause_hallucination( \
		/datum/hallucination/delusion/preset/demon, \
		"[id] status effect", \
		duration = duration, \
		affects_us = FALSE, \
		affects_others = TRUE, \
		skip_nearby = FALSE, \
		play_wabbajack = FALSE, \
	)

	owner.drop_all_held_items()

	if(iscarbon(owner))
		chainsaw = new(get_turf(owner))
		ADD_TRAIT(chainsaw, TRAIT_NODROP, CHAINSAW_FRENZY_TRAIT)
		owner.put_in_hands(chainsaw, forced = TRUE)
		chainsaw.attack_self(owner)
		owner.reagents.add_reagent(/datum/reagent/medicine/adminordrazine, 25)

	owner.log_message("entered a blood frenzy", LOG_ATTACK)
	to_chat(owner, span_warning("KILL, KILL, KILL! YOU HAVE NO ALLIES ANYMORE, KILL THEM ALL!"))

	var/datum/client_colour/colour = owner.add_client_colour(/datum/client_colour/bloodlust)
	QDEL_IN(colour, 1.1 SECONDS)
	return TRUE

/datum/status_effect/mayhem/on_remove()
	. = ..()
	to_chat(owner, span_notice("Your bloodlust seeps back into the bog of your subconscious and you regain self control."))
	owner.log_message("exited a blood frenzy", LOG_ATTACK)
	QDEL_NULL(chainsaw)

/datum/status_effect/speed_boost
	id = "speed_boost"
	duration = 2 SECONDS
	status_type = STATUS_EFFECT_REPLACE

/datum/status_effect/speed_boost/on_creation(mob/living/new_owner, set_duration)
	if(isnum(set_duration))
		duration = set_duration
	. = ..()

/datum/status_effect/speed_boost/on_apply()
	owner.add_movespeed_modifier(/datum/movespeed_modifier/status_speed_boost, update = TRUE)
	return ..()

/datum/status_effect/speed_boost/on_remove()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/status_speed_boost, update = TRUE)

/datum/movespeed_modifier/status_speed_boost
	multiplicative_slowdown = -1

///this buff provides a max health buff and a heal.
/datum/status_effect/limited_buff/health_buff
	id = "health_buff"
	alert_type = null
	///This var stores the mobs max health when the buff was first applied, and determines the size of future buffs.database.database.
	var/historic_max_health
	///This var determines how large the health buff will be. health_buff_modifier * historic_max_health * stacks
	var/health_buff_modifier = 0.1 //translate to a 10% buff over historic health per stack
	///This modifier multiplies the healing by the effect.
	var/healing_modifier = 2
	///If the mob has a low max health, we instead use this flat value to increase max health and calculate any heal.
	var/fragile_mob_health_buff = 10

/datum/status_effect/limited_buff/health_buff/on_creation(mob/living/new_owner)
	historic_max_health = new_owner.maxHealth
	. = ..()

/datum/status_effect/limited_buff/health_buff/on_apply()
	. = ..()
	var/health_increase = round(max(fragile_mob_health_buff, historic_max_health * health_buff_modifier))
	owner.maxHealth += health_increase
	owner.balloon_alert_to_viewers("health buffed")
	to_chat(owner, span_nicegreen("You feel healthy, like if your body is little stronger than it was a moment ago."))

	if(isanimal(owner))	//dumb animals have their own proc for healing.
		var/mob/living/simple_animal/healthy_animal = owner
		healthy_animal.adjustHealth(-(health_increase * healing_modifier))
	else
		owner.adjustBruteLoss(-(health_increase * healing_modifier))

/datum/status_effect/limited_buff/health_buff/maxed_out()
	. = ..()
	to_chat(owner, span_warning("You don't feel any healthier."))

/datum/status_effect/nest_sustenance
	id = "nest_sustenance"
	duration = -1
	tick_interval = 0.4 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/nest_sustenance

/datum/status_effect/nest_sustenance/tick(seconds_per_tick, times_fired)
	. = ..()

	if(owner.stat == DEAD) //If the victim has died due to complications in the nest
		qdel(src)
		return

	owner.adjustBruteLoss(-2 * seconds_per_tick, updating_health = FALSE)
	owner.adjustFireLoss(-2 * seconds_per_tick, updating_health = FALSE)
	owner.adjustOxyLoss(-4 * seconds_per_tick, updating_health = FALSE)
	owner.adjustStaminaLoss(-4 * seconds_per_tick, updating_stamina = FALSE)
	owner.adjust_bodytemperature(BODYTEMP_NORMAL, 0, BODYTEMP_NORMAL) //Won't save you from the void of space, but it will stop you from freezing or suffocating in low pressure


/atom/movable/screen/alert/status_effect/nest_sustenance
	name = "Nest Vitalization"
	desc = "The resin seems to pulsate around you. It seems to be sustaining your vital functions. You feel ill..."
	icon_state = "nest_life"

/datum/status_effect/miami
	id = "miami"
	tick_interval = 1
	alert_type = /atom/movable/screen/alert/status_effect/miami
	var/atom/cached_thrown_object
	var/atom/movable/plane_master_controller/cached_game_plane_master_controller

	var/elapsed_ticks = 0

/datum/status_effect/miami/on_apply()
	. = ..()
	RegisterSignal(owner,COMSIG_LIVING_INTERACTED_WITH_DOOR,.proc/bust_open)
	RegisterSignal(owner,COMSIG_CARBON_THROW,.proc/throw_relay)
	RegisterSignal(owner,COMSIG_MOB_ITEM_AFTERATTACK,.proc/basically_curbstomp)
	RegisterSignal(owner.reagents, COMSIG_REAGENTS_ADD_REAGENT,.proc/react_to_meds)

	cached_game_plane_master_controller = owner.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]

	cached_game_plane_master_controller.add_filter("miami_blur",2,angular_blur_filter(0,0,0.25))

/datum/status_effect/miami/tick()
	. = ..()
	elapsed_ticks++
	cached_game_plane_master_controller.remove_filter("miami")
	var/list/color_matrix = list(rgb(max(sin(elapsed_ticks)*220,120),0,0) , rgb(0,max(sin(elapsed_ticks + 120)*220,120),0) , rgb(0,0,max(sin(elapsed_ticks - 120)*220,120)))
	cached_game_plane_master_controller.add_filter("miami",1,color_matrix_filter(color_matrix))
	//похуй
	//owner.hallucination = min(owner.hallucination + 1 , 12)

/datum/status_effect/miami/on_remove()
	cached_game_plane_master_controller.remove_filter("miami_blur")
	cached_game_plane_master_controller.remove_filter("miami")
	SEND_SIGNAL(owner,COMSIG_MIAMI_CURED_DISORDER)
	return ..()

/datum/status_effect/miami/proc/bust_open(datum/source,obj/machinery/door/door,destination_state)
	SIGNAL_HANDLER

	owner.do_attack_animation(door, no_effect = TRUE)

	var/direction = get_dir(owner,door)

	var/turf/turf_in_direction = get_step(door,direction)

	for(var/mob/living/carbon/carbie in turf_in_direction)
		carbie.Knockdown(5 SECONDS)


/datum/status_effect/miami/proc/throw_relay(datum/source,atom/target,atom/thrown_thing)
	SIGNAL_HANDLER
	cached_thrown_object = thrown_thing
	if(isliving(thrown_thing))
		RegisterSignal(thrown_thing,COMSIG_MOVABLE_IMPACT,.proc/mob_throw_knockdown)

	if(isitem(thrown_thing))
		RegisterSignal(thrown_thing,COMSIG_MOVABLE_IMPACT,.proc/item_throw_knockdown)

/datum/status_effect/miami/proc/item_throw_knockdown(datum/source,atom/hit_atom, datum/thrownthing/throwingdatum)
	SIGNAL_HANDLER
	UnregisterSignal(cached_thrown_object,COMSIG_MOVABLE_THROW_LANDED)

	if(!iscarbon(hit_atom))
		return

	var/obj/item/this_item = source

	if(this_item.w_class < WEIGHT_CLASS_NORMAL)
		return

	var/mob/living/carbon/carbie_hit = hit_atom

	carbie_hit.Knockdown(3 SECONDS)

/datum/status_effect/miami/proc/mob_throw_knockdown(datum/source,atom/hit_atom, datum/thrownthing/throwingdatum)
	SIGNAL_HANDLER
	UnregisterSignal(cached_thrown_object,COMSIG_MOVABLE_THROW_LANDED)

	if(!iscarbon(hit_atom))
		return

	var/mob/living/this_mob = source

	if(this_mob.mob_size < MOB_SIZE_HUMAN)
		return

	var/mob/living/carbon/carbie_hit = hit_atom

	carbie_hit.Knockdown(4 SECONDS)

/datum/status_effect/miami/proc/basically_curbstomp(mob/living/source, atom/target, obj/item/weapon, proximity_flag, click_parameters)
	SIGNAL_HANDLER
	if(!proximity_flag)
		return

	if(!isliving(target))
		return

	var/mob/living/living_target = target

	if(!living_target.IsKnockdown())
		return
	INVOKE_ASYNC(src,.proc/continue_with_stomping,weapon,target,click_parameters)
	living_target.AdjustKnockdown(1 SECONDS)

/datum/status_effect/miami/proc/continue_with_stomping(obj/item/weapon,atom/target,click_parameters)
	weapon.attack(target,owner,click_parameters)


/datum/status_effect/miami/proc/react_to_meds(datum/source,datum/reagent/reagent , amount, reagtemp, data, no_react)
	SIGNAL_HANDLER

	if(!istype(reagent,/datum/reagent/medicine/haloperidol) && !istype(reagent, /datum/reagent/medicine/psicodine))
		return
	//15u syringe stuns for 3 seconds, 5u pill drops you for 1 second, BS syringe will drop you for 12 seconds
	owner.Paralyze((amount / 5) SECONDS)

	owner.remove_status_effect(type)

	owner.drop_all_held_items()

/atom/movable/screen/alert/status_effect/miami
	name = "THE KILLING NEVER STOPS"
	desc = "Do you like hurting other people?"
	icon_state = "miami"

/datum/status_effect/creep //allows darkspawn to move through lights without lightburn damage //Massmeta edit start
	id = "creep"
	duration = -1
	alert_type = /atom/movable/screen/alert/status_effect/creep
	var/datum/antagonist/darkspawn/darkspawn

/datum/status_effect/creep/get_examine_text()
	return span_warning("[owner.p_they(TRUE)] is surrounded by velvety, gently-waving black shadows!")

/datum/status_effect/creep/on_creation(mob/living/owner, datum/antagonist/darkspawn)
	. = ..()
	if(!.)
		return
	src.darkspawn = darkspawn

/datum/status_effect/creep/tick()
	if(!darkspawn)
		qdel(src)
		return
	if(!darkspawn.has_psi(5))
		to_chat(owner, "<span class='warning'>Without the Psi to maintain it, your protective aura vanishes!</span>")
		qdel(src)
		return
	darkspawn.use_psi(5)

/atom/movable/screen/alert/status_effect/creep
	name = "Creep"
	desc = "You are immune to lightburn. Drains 1 Psi per second."
	icon = 'massmeta/icons/mob/actions/actions_darkspawn.dmi'
	icon_state = "creep"

/datum/status_effect/shadow_dance //allows darkspawn to move through lights without lightburn damage //Massmeta edit start
	id = "shadowdance"
	duration = -1
	alert_type = /atom/movable/screen/alert/status_effect/shadow_dance
	var/datum/antagonist/darkspawn/darkspawn

/datum/status_effect/shadow_dance/on_creation(mob/living/owner, datum/antagonist/darkspawn)
	. = ..()
	if(!.)
		return
	src.darkspawn = darkspawn

/datum/status_effect/shadow_dance/tick()
	if(!darkspawn)
		qdel(src)
		return
	if(!darkspawn.has_psi(5))
		to_chat(owner, "<span class='warning'>You dont have enough psi to mantain the dance!</span>")
		qdel(src)
		return
	darkspawn.use_psi(5)

/atom/movable/screen/alert/status_effect/shadow_dance
	name = "Shadow Dance"
	desc = "You are able to avoid projectiles while in darkness."
	icon = 'icons/mob/actions/actions_minor_antag.dmi'
	icon_state = "ninja_cloak"

#define TIME_DILATION_TRAIT "time_dilation_trait"
/datum/status_effect/time_dilation //used by darkspawn; greatly increases action times etc
	id = "time_dilation"
	duration = 600
	alert_type = /atom/movable/screen/alert/status_effect/time_dilation

/datum/status_effect/time_dilation/get_examine_text()
	return span_warning("[owner.p_they(TRUE)] is moving jerkily and unpredictably!")

/datum/status_effect/time_dilation/on_apply()
	ADD_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, TIME_DILATION_TRAIT)
	owner.add_movespeed_modifier(/datum/movespeed_modifier/status_effect/time_dilation)
	owner.add_actionspeed_modifier(/datum/actionspeed_modifier/time_dilation)
	return TRUE

/datum/status_effect/time_dilation/on_remove()
	REMOVE_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, TIME_DILATION_TRAIT)
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/status_effect/time_dilation)
	owner.remove_actionspeed_modifier(/datum/actionspeed_modifier/time_dilation)

/atom/movable/screen/alert/status_effect/time_dilation
	name = "Time Dilation"
	desc = "Your actions are twice as fast, and the delay between them is halved."
	icon = 'massmeta/icons/mob/actions/actions_darkspawn.dmi'
	icon_state = "time_dilation" 
	
/datum/status_effect/inathneqs_endowment
	id = "inathneqs_endowment"
	duration = 150
	alert_type = /atom/movable/screen/alert/status_effect/inathneqs_endowment

/atom/movable/screen/alert/status_effect/inathneqs_endowment
	name = "Inath-neq's Endowment"
	desc = "Adrenaline courses through you as the Resonant Cogwheel's energy shields you from all harm!"
	icon_state = "inathneqs_endowment"
	alerttooltipstyle = "clockcult"

/datum/status_effect/inathneqs_endowment/on_apply()
	owner.log_message("gained Inath-neq's invulnerability", LOG_ATTACK)
	owner.visible_message("<span class='warning'>[owner] shines with azure light!</span>", "<span class='notice'>You feel Inath-neq's power flow through you! You're invincible!</span>")
	var/oldcolor = owner.color
	owner.color = "#1E8CE1"
	owner.fully_heal()
	owner.add_stun_absorption("inathneq", 150, 2, "'s flickering blue aura momentarily intensifies!", "Inath-neq's power absorbs the stun!", " glowing with a flickering blue light!")
	owner.status_flags |= GODMODE
	animate(owner, color = oldcolor, time = 150, easing = EASE_IN)
	addtimer(CALLBACK(owner, /atom/proc/update_atom_colour), 150)
	playsound(owner, 'sound/magic/ethereal_enter.ogg', 50, TRUE)
	return ..()

/datum/status_effect/inathneqs_endowment/on_remove()
	owner.log_message("lost Inath-neq's invulnerability", LOG_ATTACK)
	owner.visible_message("<span class='warning'>The light around [owner] flickers and dissipates!</span>", "<span class='boldwarning'>You feel Inath-neq's power fade from your body!</span>")
	owner.status_flags &= ~GODMODE
	playsound(owner, 'sound/magic/ethereal_exit.ogg', 50, TRUE)

/datum/status_effect/cyborg_power_regen
	id = "power_regen"
	duration = 100
	alert_type = /atom/movable/screen/alert/status_effect/power_regen
	var/power_to_give = 0 //how much power is gained each tick

/datum/status_effect/cyborg_power_regen/on_creation(mob/living/new_owner, new_power_per_tick)
	. = ..()
	if(. && isnum(new_power_per_tick))
		power_to_give = new_power_per_tick

/atom/movable/screen/alert/status_effect/power_regen
	name = "Power Regeneration"
	desc = "You are quickly regenerating power!"
	icon_state = "power_regen"

/datum/status_effect/cyborg_power_regen/tick()
	var/mob/living/silicon/robot/cyborg = owner
	if(!istype(cyborg) || !cyborg.cell)
		qdel(src)
		return
	playsound(cyborg, 'sound/effects/light_flicker.ogg', 50, TRUE)
	cyborg.cell.give(power_to_give)
//Massmeta edit end

#undef TIME_DILATION_TRAIT
