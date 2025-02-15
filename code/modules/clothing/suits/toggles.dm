//Hoods for winter coats and chaplain hoodie etc

/obj/item/clothing/suit/hooded
	actions_types = list(/datum/action/item_action/toggle_hood)
	var/obj/item/clothing/head/hooded/hood
	var/hoodtype = /obj/item/clothing/head/hooded/winterhood //so the chaplain hoodie or other hoodies can override this
	///Alternative mode for hiding the hood, instead of storing the hood in the suit it qdels it, useful for when you deal with hooded suit with storage.
	var/alternative_mode = FALSE
	///Whether the hood is flipped up
	var/hood_up = FALSE
	/// What should be added to the end of the icon state when the hood is up? Set to "" for the suit sprite to not change at all
	var/hood_up_affix = "_t"
	/// Are we zipped? Mostly relevant for wintercoats, leaving this here to simplify logic and so someone else can extend it if they ever wish to.
	var/zipped = FALSE

/obj/item/clothing/suit/hooded/Initialize(mapload)
	. = ..()
	if(!alternative_mode)
		MakeHood()


/obj/item/clothing/suit/hooded/Destroy()
	. = ..()
	QDEL_NULL(hood)

/obj/item/clothing/suit/hooded/proc/MakeHood()
	if(!hood)
		var/obj/item/clothing/head/hooded/W = new hoodtype(src)
		W.suit = src
		hood = W

/obj/item/clothing/suit/hooded/ui_action_click()
	ToggleHood()

/obj/item/clothing/suit/hooded/item_action_slot_check(slot, mob/user)
	if(slot & ITEM_SLOT_OCLOTHING|ITEM_SLOT_NECK)
		return TRUE

/obj/item/clothing/suit/hooded/equipped(mob/user, slot)
	if(!(slot & ITEM_SLOT_OCLOTHING|ITEM_SLOT_NECK))
		RemoveHood()
	return ..()

/obj/item/clothing/suit/hooded/on_outfit_equip(mob/living/carbon/human/outfit_wearer, visuals_only, item_slot)
	if(visuals_only)
		MakeHood()
	ToggleHood()

/obj/item/clothing/suit/hooded/proc/RemoveHood()
	icon_state = "[initial(icon_state)]"
	worn_icon_state = icon_state
	zipped = FALSE
	hood_up = FALSE

	if(hood)
		if(ishuman(hood.loc))
			var/mob/living/carbon/human/H = hood.loc
			H.transferItemToLoc(hood, src, TRUE)
			H.update_worn_oversuit()
		else
			hood.forceMove(src)

		if(alternative_mode)
			QDEL_NULL(hood)

	update_item_action_buttons()

/obj/item/clothing/suit/hooded/dropped()
	..()
	RemoveHood()

/obj/item/clothing/suit/hooded/proc/ToggleHood()
	if(!hood_up)
		if(!ishuman(loc))
			return
		var/mob/living/carbon/human/H = loc
		if(H.is_holding(src))
			to_chat(H, span_warning("You must be wearing [src] to put up the hood!"))
			return
		if(H.head)
			to_chat(H, span_warning("You're already wearing something on your head!"))
			return
		else
			if(alternative_mode)
				MakeHood()
			if(!H.equip_to_slot_if_possible(hood,ITEM_SLOT_HEAD,0,0,1))
				if(alternative_mode)
					RemoveHood()
				return
			hood_up = TRUE
			icon_state = "[initial(icon_state)][hood_up_affix]"
			worn_icon_state = icon_state
			zipped = TRUE // Just to maintain the same behavior, and so we avoid any bugs that otherwise relied on this behavior of zipping the jacket when bringing up the hood
			H.update_worn_oversuit()
			H.update_mob_action_buttons()
	else
		RemoveHood()

/obj/item/clothing/head/hooded
	var/obj/item/clothing/suit/hooded/suit


/obj/item/clothing/head/hooded/Destroy()
	suit = null
	return ..()

/obj/item/clothing/head/hooded/dropped()
	..()
	if(suit)
		suit.RemoveHood()

/obj/item/clothing/head/hooded/equipped(mob/user, slot)
	..()
	if(!(slot & ITEM_SLOT_HEAD))
		if(suit)
			suit.RemoveHood()
		else
			qdel(src)

// Toggle exosuits for different aesthetic styles (hoodies, suit jacket buttons, etc)
// Pretty much just a holder for `/datum/component/toggle_icon`.

/obj/item/clothing/suit/toggle
	/// The noun that is displayed to the user on toggle. EX: "Toggles the suit's [buttons]".
	var/toggle_noun = "buttons"

/obj/item/clothing/suit/toggle/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/toggle_icon, toggle_noun)

//Hardsuit toggle code
/obj/item/clothing/suit/space/hardsuit/Initialize(mapload)
	MakeHelmet()
	. = ..()

/obj/item/clothing/suit/space/hardsuit/Destroy()
	if(!QDELETED(helmet))
		helmet.suit = null
		qdel(helmet)
		helmet = null
	if (isatom(jetpack))
		QDEL_NULL(jetpack)
	return ..()

/obj/item/clothing/head/helmet/space/hardsuit/Destroy()
	if(suit)
		suit.helmet = null
	return ..()

/obj/item/clothing/suit/space/hardsuit/proc/MakeHelmet()
	if(!helmettype)
		return
	if(!helmet)
		var/obj/item/clothing/head/helmet/space/hardsuit/W = new helmettype(src)
		W.suit = src
		helmet = W

/obj/item/clothing/suit/space/hardsuit/ui_action_click()
	..()
	ToggleHelmet()

/obj/item/clothing/suit/space/hardsuit/equipped(mob/user, slot)
	if(!helmettype)
		return
	if(slot != ITEM_SLOT_OCLOTHING)
		RemoveHelmet()
	..()

/obj/item/clothing/suit/space/hardsuit/proc/RemoveHelmet()
	if(!helmet)
		return
	helmet_on = FALSE
	if(ishuman(helmet.loc))
		var/mob/living/carbon/H = helmet.loc
		if(helmet.on)
			helmet.attack_self(H)
		H.transferItemToLoc(helmet, src, TRUE)
		H.update_worn_oversuit()
		to_chat(H, span_notice("The helmet on the hardsuit disengages."))
		playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, TRUE)
	else
		helmet.forceMove(src)

/obj/item/clothing/suit/space/hardsuit/dropped()
	..()
	RemoveHelmet()

/obj/item/clothing/suit/space/hardsuit/proc/ToggleHelmet()
	var/mob/living/carbon/human/H = src.loc
	if(!helmettype)
		return
	if(!helmet)
		to_chat(H, span_warning("The helmet's lightbulb seems to be damaged! You'll need a replacement bulb."))
		return
	if(!helmet_on)
		if(ishuman(src.loc))
			if(H.wear_suit != src)
				to_chat(H, span_warning("You must be wearing [src] to engage the helmet!"))
				return
			if(H.head)
				to_chat(H, span_warning("You're already wearing something on your head!"))
				return
			else if(H.equip_to_slot_if_possible(helmet,ITEM_SLOT_HEAD,0,0,1))
				to_chat(H, span_notice("You engage the helmet on the hardsuit."))
				helmet_on = TRUE
				H.update_worn_oversuit()
				playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, TRUE)
	else
		RemoveHelmet()
