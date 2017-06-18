//VAURCA ORGANS
/obj/item/organ/internal/heart/left
	name = "heart"
	icon_state = "heart-on"
	organ_tag = "left heart"
	parent_organ = "chest"
	dead_icon = "heart-off"
	species = "Vaurca Worker"
/obj/item/organ/internal/heart/right
	name = "heart"
	icon_state = "heart-on"
	organ_tag = "right heart"
	parent_organ = "chest"
	dead_icon = "heart-off"
	species = "Vaurca Worker"

/obj/item/organ/internal/vaurca/neuralsocket
	name = "neural socket"
	organ_tag = "neural socket"
	icon = 'icons/baysphere/mob/alien.dmi'
	icon_state = "neural_socket"
	parent_organ = "head"
	species = "Vaurca Worker"
	robotic = 2

obj/item/organ/internal/vaurca/neuralsocket/process()
	if (is_broken())
		if (all_languages["Hivenet"] in owner.languages)
			owner.remove_language("Hivenet")
			owner << "<span class='warning'> Your mind suddenly grows dark as the unity of the Hive is torn from you.</span>"
	else
		if (!(all_languages["Hivenet"] in owner.languages))
			owner.add_language("Hivenet")
			owner << "<span class='notice'> Your mind expands, and your thoughts join the unity of the Hivenet.</span>"
	..()

/obj/item/organ/internal/vaurca/neuralsocket/replaced(var/mob/living/carbon/human/target)
	if (!(all_languages["Hivenet"] in owner.languages))
		owner.add_language("Hivenet")
		owner << "<span class='notice'> Your mind expands, and your thoughts join the unity of the Hivenet.</span>"
	..()

/obj/item/organ/internal/vaurca/neuralsocket/remove(var/mob/living/carbon/human/target)
	if(all_languages["Hivenet"] in target.languages)
		target.remove_language("Hivenet")
		target << "<span class='warning'>Your mind suddenly grows dark as the unity of the Hive is torn from you.</span>"
	..()

/obj/item/organ/internal/vaurca/filtrationbit
	name = "filtration bit"
	organ_tag = "filtration bit"
	parent_organ = "head"
	icon = 'icons/baysphere/mob/alien.dmi'
	icon_state = "filter"
	species = "Vaurca Worker"
	robotic = 2

/obj/item/organ/internal/vaurca/preserve
	name = "plasma reserve tank"
	organ_tag = "plasma reserve tank"
	parent_organ = "chest"
	icon = 'icons/baysphere/mob/alien.dmi'
	icon_state = "breathing_app"
	species = "Vaurca Worker"
	robotic = 1
	var/datum/gas_mixture/air_contents = null
	var/distribute_pressure = ((2*ONE_ATMOSPHERE)*O2STANDARD)
	var/volume = 50
	var/manipulated_by = null

/obj/item/organ/internal/vaurca/preserve/New()
	..()

	src.air_contents = new /datum/gas_mixture()
	src.air_contents.toxins += ((ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C))
	src.air_contents.volume = volume //liters
	src.air_contents.temperature = T20C
	src.distribute_pressure = ((pick(1.0,1.1,1.2,1.3)*ONE_ATMOSPHERE)*O2STANDARD)

	processing_objects.Add(src)
	var/mob/living/carbon/location = loc

	location.internal = src
	usr << "<span class='notice'>You open \the [src] valve.</span>"
//	if (location.internals)
//		location.internals.icon_state = "internal1"
	location.update_internals_hud_icon(0)

	return

/obj/item/organ/internal/vaurca/preserve/Destroy()
	if(air_contents)
		qdel(air_contents)

	processing_objects.Remove(src)
	..()

/obj/item/organ/internal/vaurca/preserve/examine(mob/user)
	. = ..(user, 0)
	if(.)
		var/celsius_temperature = air_contents.temperature - T0C
		var/descriptive
		switch(celsius_temperature)
			if(300 to INFINITY)
				descriptive = "furiously hot"
			if(100 to 300)
				descriptive = "hot"
			if(80 to 100)
				descriptive = "warm"
			if(40 to 80)
				descriptive = "lukewarm"
			if(20 to 40)
				descriptive = "room temperature"
			else
				descriptive = "cold"
		to_chat(user, "<span class='notice'>\The [src] feels [descriptive].</span>")

/obj/item/organ/internal/vaurca/preserve/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	var/obj/icon = src

	if ((istype(W, /obj/item/device/analyzer)) && get_dist(user, src) <= 1)
		for (var/mob/O in viewers(user, null))
			O << "<span class='warning'>[user] has used [W] on \icon[icon] [src]</span>"

		var/pressure = air_contents.return_pressure()
		manipulated_by = user.real_name			//This person is aware of the contents of the tank.
		var/total_moles = air_contents.total_moles()
//		var/total_moles = air_contents.total_moles

		user << "<span class='notice'>Results of analysis of \icon[icon]</span>"
		if (total_moles>0)
			user << "<span class='notice'>Pressure: [round(pressure,0.1)] kPa</span>"
			var/o2_concentration = air_contents.oxygen/total_moles
			var/n2_concentration = air_contents.nitrogen/total_moles
			var/co2_concentration = air_contents.carbon_dioxide/total_moles
			var/plasma_concentration = air_contents.toxins/total_moles

			var/unknown_concentration =  1-(o2_concentration+n2_concentration+co2_concentration+plasma_concentration)

			to_chat(user, "<span class='notice'>Pressure: [round(pressure,0.1)] kPa</span>")
			to_chat(user, "<span class='notice'>Nitrogen: [round(n2_concentration*100)] %</span>")
			to_chat(user, "<span class='notice'>Oxygen: [round(o2_concentration*100)] %</span>")
			to_chat(user, "<span class='notice'>CO2: [round(co2_concentration*100)] %</span>")
			to_chat(user, "<span class='notice'>Plasma: [round(plasma_concentration*100)] %</span>")
			if(unknown_concentration>0.01)
				to_chat(user, "<span class='danger'>Unknown: [round(unknown_concentration*100)] %</span>")
			to_chat(user, "<span class='notice'>Temperature: [round(air_contents.temperature-T0C)] &deg;C</span>")

//			for(var/g in air_contents.trace_gases)
//				user << "<span class='notice'>[gas_data.name[g]]: [(round(air_contents.gas[g] / total_moles) * 100)]%</span>"
			user << "<span class='notice'>Temperature: [round(air_contents.temperature-T0C)]&deg;C</span>"
		else
			user << "<span class='notice'>Tank is empty!</span>"
		src.add_fingerprint(user)
	else if (istype(W,/obj/item/latexballon))
		var/obj/item/latexballon/LB = W
		LB.blow(src)
		src.add_fingerprint(user)

/obj/item/organ/internal/vaurca/preserve/attack_self(mob/user as mob)
	if (!(src.air_contents))
		return

	ui_interact(user)

/obj/item/organ/internal/vaurca/preserve/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	var/mob/living/carbon/location = null

	var/using_internal
	if(istype(location))
		if(location.internal==src)
			using_internal = 1

	// this is the data which will be sent to the ui
	var/data[0]
	data["tankPressure"] = round(air_contents.return_pressure() ? air_contents.return_pressure() : 0)
	data["releasePressure"] = round(distribute_pressure ? distribute_pressure : 0)
	data["defaultReleasePressure"] = round(TANK_DEFAULT_RELEASE_PRESSURE)
	data["maxReleasePressure"] = round(TANK_MAX_RELEASE_PRESSURE)
	data["valveOpen"] = using_internal ? 1 : 0

	data["maskConnected"] = 0

	if(istype(location))
		var/mask_check = 0

		if(location.internal == src)	// if tank is current internal
			mask_check = 1
		else if(src in location)		// or if tank is in the mobs possession
			if(!location.internal)		// and they do not have any active internals
				mask_check = 1
		else if(istype(src.loc, /obj/item/weapon/rig) && src.loc in location)	// or the rig is in the mobs possession
			if(!location.internal)		// and they do not have any active internals
				mask_check = 1

		if(mask_check)
			if(location.wear_mask && (location.wear_mask.flags & AIRTIGHT))
				data["maskConnected"] = 1
			else if(istype(location, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = location
				if(H.head && (H.head.flags & AIRTIGHT))
					data["maskConnected"] = 1

	// update the ui if it exists, returns null if no ui is passed/found
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "tanks.tmpl", "Tank", 500, 300)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		ui.set_auto_update(1)

/obj/item/organ/internal/vaurca/preserve/Topic(href, href_list)
	..()
	if (usr.stat|| usr.restrained())
		return 0
	if (src.loc != usr)
		return 0

	if (href_list["dist_p"])
		if (href_list["dist_p"] == "reset")
			src.distribute_pressure = TANK_DEFAULT_RELEASE_PRESSURE
		else if (href_list["dist_p"] == "max")
			src.distribute_pressure = TANK_MAX_RELEASE_PRESSURE
		else
			var/cp = text2num(href_list["dist_p"])
			src.distribute_pressure += cp
		src.distribute_pressure = min(max(round(src.distribute_pressure), 0), TANK_MAX_RELEASE_PRESSURE)
	if (href_list["stat"])
		if(istype(loc,/mob/living/carbon))
			var/mob/living/carbon/location = loc
			if(location.internal == src)
				location.internal = null
//				location.internals.icon_state = "internal0"
				to_chat(usr, "<span class='notice'>You close the tank release valve.</span>")
				location.internal = src
				location.update_internals_hud_icon(0)
//				if (location.internals)
//					location.internals.icon_state = "internal0"
			else

				var/can_open_valve
				if(location.wear_mask && (location.wear_mask.flags & AIRTIGHT))
					can_open_valve = 1
				else if(istype(location,/mob/living/carbon/human))
					var/mob/living/carbon/human/H = location
					if(H.head && (H.head.flags & AIRTIGHT))
						can_open_valve = 1

				if(can_open_valve)
					location.internal = src
					usr << "<span class='notice'>You open \the [src] valve.</span>"
					location.internal = src
					location.update_internals_hud_icon(1)

//					if (location.internals)
//						location.internals.icon_state = "internal1"
				else
					usr << "<span class='notice'>You need something to connect to \the [src].</span>"

	src.add_fingerprint(usr)
	return 1


/obj/item/organ/internal/vaurca/preserve/remove_air(amount)
	return air_contents.remove(amount)

/obj/item/organ/internal/vaurca/preserve/return_air()
	return air_contents

/obj/item/organ/internal/vaurca/preserve/assume_air(datum/gas_mixture/giver)
	air_contents.merge(giver)

	check_status()
	return 1

/obj/item/organ/internal/vaurca/preserve/proc/remove_air_volume(volume_to_return)
	if(!air_contents)
		return null

	var/tank_pressure = air_contents.return_pressure()
	if((tank_pressure < distribute_pressure) && prob(5))
		owner << "<span class='warning'>There is a buzzing in your [parent_organ].</span>"

	var/moles_needed = distribute_pressure*volume_to_return/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

	return remove_air(moles_needed)

/obj/item/organ/internal/vaurca/preserve/process()
	//Allow for reactions
	air_contents.react() //cooking up air tanks - add phoron and oxygen, then heat above PHORON_MINIMUM_BURN_TEMPERATURE
	check_status()
	..()


/obj/item/organ/internal/vaurca/preserve/proc/check_status()
	//Handle exploding, leaking, and rupturing of the tank

	if(!air_contents)
		return 0

	var/pressure = air_contents.return_pressure()
	if(pressure > TANK_FRAGMENT_PRESSURE)
		if(!istype(src.loc,/obj/item/device/transfer_valve))
			message_admins("Explosive tank rupture! last key to touch the tank was [src.fingerprintslast].")
			log_game("Explosive tank rupture! last key to touch the tank was [src.fingerprintslast].")

		//Give the gas a chance to build up more pressure through reacting
		air_contents.react()
		air_contents.react()
		air_contents.react()

		pressure = air_contents.return_pressure()
		var/range = (pressure-TANK_FRAGMENT_PRESSURE)/TANK_FRAGMENT_SCALE

		explosion(
			get_turf(loc),
			round(min(MAX_EX_DEVESTATION_RANGE, range*0.25)),
			round(min(MAX_EX_HEAVY_RANGE, range*0.50)),
			round(min(MAX_EX_LIGHT_RANGE, range*1.00)),
			round(min(MAX_EX_FLASH_RANGE, range*1.50))
			)
		qdel(src)

	else if(pressure > (8.0*ONE_ATMOSPHERE))

		if(damage >= 60)
			var/turf/simulated/T = get_turf(src)
			if(!T)
				return
			T.assume_air(air_contents)
			playsound(src.loc, 'sound/effects/spray.ogg', 10, 1, -3)
			qdel(src)

	else if(pressure > (5.0*ONE_ATMOSPHERE))

		if(damage >= 45)
			var/turf/simulated/T = get_turf(src)
			if(!T)
				return
			var/datum/gas_mixture/leaked_gas = air_contents.remove_ratio(0.25)
			T.assume_air(leaked_gas)

/obj/item/organ/internal/eyes/vaurca
	name = "vaurca eyeballs"
	dark_view = 8
	species = "Vaurca Worker"

/obj/item/organ/internal/liver/vaurca
	alcohol_intensity = 8
	species = "Vaurca Worker"

