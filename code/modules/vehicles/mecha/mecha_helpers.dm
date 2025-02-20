///Adds a cell, for use in Map-spawned mechs, Nuke Ops mechs, and admin-spawned mechs. Mechs built by hand will replace this.
/obj/vehicle/sealed/mecha/proc/add_cell(obj/item/stock_parts/cell/new_cell)
	QDEL_NULL(cell)
	if(new_cell)
		new_cell.forceMove(src)
		cell = new_cell
		return
	cell = new /obj/item/stock_parts/cell/high(src)

///Adds a scanning module, for use in Map-spawned mechs, Nuke Ops mechs, and admin-spawned mechs. Mechs built by hand will replace this.
/obj/vehicle/sealed/mecha/proc/add_scanmod(obj/item/stock_parts/scanning_module/new_scanmod)
	QDEL_NULL(scanmod)
	if(new_scanmod)
		new_scanmod.forceMove(src)
		scanmod = new_scanmod
		return
	scanmod = new /obj/item/stock_parts/scanning_module(src)

///Adds a capacitor, for use in Map-spawned mechs, Nuke Ops mechs, and admin-spawned mechs. Mechs built by hand will replace this.
/obj/vehicle/sealed/mecha/proc/add_capacitor(obj/item/stock_parts/capacitor/new_capacitor)
	QDEL_NULL(capacitor)
	if(new_capacitor)
		new_capacitor.forceMove(src)
		capacitor = new_capacitor
	else
		capacitor = new /obj/item/stock_parts/capacitor(src)

///////////////////////
///// Power stuff /////
///////////////////////
/obj/vehicle/sealed/mecha/proc/has_charge(amount)
	return (get_charge() >= amount)

/obj/vehicle/sealed/mecha/proc/get_charge()
	for(var/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/R in flat_equipment)
		var/relay_charge = R.get_charge()
		if(relay_charge)
			return relay_charge
	if(cell)
		return max(0, cell.charge)

/obj/vehicle/sealed/mecha/proc/use_power(amount)
	return (get_charge() && cell.use(amount))

/obj/vehicle/sealed/mecha/proc/give_power(amount)
	if(!isnull(get_charge()))
		cell.give(amount)
		return TRUE
	return FALSE

//////////////////////
///// Ammo stuff /////
//////////////////////

///Max the ammo stored in all ballistic weapons for this mech
/obj/vehicle/sealed/mecha/proc/max_ammo()
	for(var/obj/item/I as anything in flat_equipment)
		if(istype(I, /obj/item/mecha_parts/mecha_equipment/weapon/ballistic))
			var/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/gun = I
			gun.projectiles_cache = gun.projectiles_cache_max
