/obj/structure/reagent_anvil
	name = "anvil"
	desc = "An object with the intent to hammer metal against. One of the most important parts for forging an item."
	icon = 'massmeta/icons/obj/forge_structures.dmi'
	icon_state = "anvil_empty"

	anchored = TRUE
	density = TRUE

/obj/structure/reagent_anvil/attackby(obj/item/I, mob/living/user, params)
	var/obj/item/forging/incomplete/searchIncompleteSrc = locate(/obj/item/forging/incomplete) in contents
	if(istype(I, /obj/item/forging/hammer) && searchIncompleteSrc)
		playsound(src, 'massmeta/sounds/forge.ogg', 50, TRUE)
		if(searchIncompleteSrc.heat_world_compare <= world.time)
			to_chat(user, span_warning("You mess up, the metal was too cool!"))
			searchIncompleteSrc.times_hit -= 3
			return
		if(searchIncompleteSrc.world_compare <= world.time)
			searchIncompleteSrc.world_compare = world.time + searchIncompleteSrc.average_wait
			searchIncompleteSrc.times_hit++
			to_chat(user, span_notice("You strike the metal-- good hit."))
			if(searchIncompleteSrc.times_hit >= searchIncompleteSrc.average_hits)
				to_chat(user, span_notice("The metal is sounding ready."))
			return
		searchIncompleteSrc.times_hit -= 3
		to_chat(user, span_warning("You strike the metal-- bad hit."))
		if(searchIncompleteSrc.times_hit <= -(searchIncompleteSrc.average_hits))
			to_chat(user, span_warning("The hits were too inconsistent-- the metal breaks!"))
			icon_state = "anvil_empty"
			qdel(searchIncompleteSrc)
		return
	if(istype(I, /obj/item/forging/tongs))
		var/obj/item/forging/incomplete/searchIncompleteItem = locate(/obj/item/forging/incomplete) in I.contents
		if(searchIncompleteSrc && !searchIncompleteItem)
			searchIncompleteSrc.forceMove(I)
			update_appearance()
			I.icon_state = "tong_full"
			return
		if(!searchIncompleteSrc && searchIncompleteItem)
			searchIncompleteItem.forceMove(src)
			update_appearance()
			I.icon_state = "tong_empty"
		return
	if(I.tool_behaviour == TOOL_WRENCH)
		new /obj/item/stack/sheet/iron/ten(get_turf(src))
		qdel(src)
		return
	return ..()
	
/obj/structure/reagent_anvil/update_appearance()
	. = ..()
	cut_overlays()
	var/obj/item/forging/incomplete/searchIncompleteSrc = locate(/obj/item/forging/incomplete) in contents
	if(!searchIncompleteSrc)
		return

	var/image/overlayed_item = image(icon = searchIncompleteSrc.icon, icon_state = searchIncompleteSrc.icon_state)
	overlayed_item.transform = matrix(, 0, 0, 0, 0.8, 0)
	add_overlay(overlayed_item)

/obj/structure/reagent_anvil/examine(mob/user)
	. = ..()
	. += span_notice("You can place <b>hot metal objects</b> on this by using some <b>tongs</b>.")
