//IGNITE------------------

/obj/effect/proc_holder/spell/arcane/ignite
	name = "Ignite"
	desc = ""
	overlay_state = "flame"
	sound = 'sound/items/firelight.ogg'
	range = 4
	releasedrain = 30
	chargedrain = 0
	chargetime = 0
	charge_max = 10 SECONDS

/obj/effect/proc_holder/spell/arcane/ignite/cast(list/targets, mob/user = usr)
	. = ..()
	if(isliving(targets[1]))
		var/mob/living/L = targets[1]
		user.visible_message("<font color='yellow'>[user] points at [L]!</font>")
		if(L.anti_magic_check(TRUE, TRUE))
			return FALSE
		L.adjust_fire_stacks(5)
		L.IgniteMob()
		addtimer(CALLBACK(L, TYPE_PROC_REF(/mob/living, ExtinguishMob)), 5 SECONDS)
		return TRUE

	// Spell interaction with ignitable objects (burn wooden things, light torches up)
	else if(isobj(targets[1]))
		var/obj/O = targets[1]
		if(O.fire_act())
			user.visible_message("<font color='yellow'>[user] points at [O], igniting it in flames!</font>")
			return TRUE
		else
			to_chat(user, span_warning("You point at [O], but it fails to catch fire."))
			return FALSE
	return FALSE

//SMOKESCREEN-----------------

/obj/effect/proc_holder/spell/arcane/smokescreen
	name = "Smoke"
	desc = ""
	overlay_state = "smoke"
	sound = 'sound/items/firesnuff.ogg'
	range = 8
	releasedrain = 30
	chargedrain = 0
	chargetime = 0
	charge_max = 10 SECONDS
	smoke_spread = 1
	smoke_amt = 2

/obj/effect/proc_holder/spell/arcane/smokescreen/cast(list/targets,mob/user = usr)
	. = ..()
	if(isliving(targets[1]))
		return TRUE
	else if(isopenturf(targets[1]))
		return TRUE
	return FALSE

//SWAP PLACES-----------------

/obj/effect/proc_holder/spell/arcane/swap
	name = "Location Swap"
	desc = ""
	overlay_state = "swap"
	sound = 'sound/magic/magic_nulled.ogg'
	range = 8
	releasedrain = 50
	chargedrain = 1
	chargetime = 15
	charge_max = 20 SECONDS
	charging_slowdown = 3
	var/include_space = FALSE //whether it includes space tiles in possible teleport locations
	var/include_dense = FALSE //whether it includes dense tiles in possible teleport locations

/obj/effect/temp_visual/swap
	icon_state = "anom"
	layer = ABOVE_MOB_LAYER
	plane = GAME_PLANE_UPPER

/obj/effect/proc_holder/spell/arcane/swap/cast(list/targets, mob/living/user)
	if(isliving(targets[1]))
		var/mob/living/target = targets[1]
		if(target.anti_magic_check(TRUE, TRUE))
			return FALSE
		new /obj/effect/temp_visual/swap(get_turf(user))
		new /obj/effect/temp_visual/swap(get_turf(target))
		var/atom/targl = get_turf(target)
		if(do_teleport(target, user, forceMove = TRUE, channel = TELEPORT_CHANNEL_MAGIC))
			do_teleport(user, targl, forceMove = TRUE, channel = TELEPORT_CHANNEL_MAGIC)
		if(ismob(target))
			var/mob/M = target
			to_chat(M, span_warning("You find myself somewhere else..."))
	return TRUE

//BLINK-----------------

/obj/effect/proc_holder/spell/arcane/blink
	name = "Blink"
	desc = ""
	overlay_state = "blink"
	sound = 'sound/magic/magic_nulled.ogg'
	range = 8
	releasedrain = 50
	chargedrain = 0
	chargetime = 0
	charge_max = 15 SECONDS
	var/include_space = FALSE //whether it includes space tiles in possible teleport locations
	var/include_dense = FALSE //whether it includes dense tiles in possible teleport locations

/obj/effect/temp_visual/blink
	icon_state = "anom"
	layer = ABOVE_MOB_LAYER
	plane = GAME_PLANE_UPPER

/obj/effect/proc_holder/spell/arcane/blink/cast(list/targets,mob/user = usr)
	. = ..()
	if(isopenturf(targets[1]))
		var/atom/location = get_turf(targets[1])
		new /obj/effect/temp_visual/swap(get_turf(user))
		new /obj/effect/temp_visual/swap(get_turf(location))
		do_teleport(user, location, forceMove = TRUE, channel = TELEPORT_CHANNEL_MAGIC)
		return TRUE
	else
		return FALSE


// BLINDNESS--------------

/obj/effect/proc_holder/spell/arcane/blindness
	name = "Blindness"
	desc = ""
	overlay_state = "blindness"
	releasedrain = 40
	chargedrain = 0
	chargetime = 0
	charge_max = 10 SECONDS
	range = 7
	movement_interrupt = FALSE
	sound = 'sound/magic/churn.ogg'
	antimagic_allowed = TRUE

/obj/effect/proc_holder/spell/arcane/blindness/cast(list/targets, mob/user = usr)
	if(isliving(targets[1]))
		var/mob/living/target = targets[1]
		if(target.anti_magic_check(TRUE, TRUE))
			return FALSE
		target.visible_message(span_warning("[user] points at [target]'s eyes!"),span_warning("My eyes are covered in darkness!"))
		target.blind_eyes(2)
	return TRUE

// INVISIBILITY--------------

/obj/effect/proc_holder/spell/arcane/invisibility
	name = "Invisibility"
	desc = ""
	overlay_state = "invisibility"
	releasedrain = 50
	chargedrain = 0
	chargetime = 0
	charge_max = 30 SECONDS
	range = 3
	movement_interrupt = FALSE
	sound = 'sound/misc/area.ogg' //This sound doesnt play for some reason. Fix me.
	antimagic_allowed = TRUE

/obj/effect/proc_holder/spell/arcane/invisibility/cast(list/targets, mob/living/user)
	if(isliving(targets[1]))
		var/mob/living/target = targets[1]
		if(target.anti_magic_check(TRUE, TRUE))
			return FALSE
		target.visible_message(span_warning("[target] starts to fade into thin air!"), span_notice("You start to become invisible!"))
		animate(target, alpha = 0, time = 1 SECONDS, easing = EASE_IN)
		target.mob_timers[MT_INVISIBILITY] = world.time + 15 SECONDS
		addtimer(CALLBACK(target, TYPE_PROC_REF(/mob/living, update_sneak_invis), TRUE), 15 SECONDS)
		addtimer(CALLBACK(target, TYPE_PROC_REF(/atom/movable, visible_message), span_warning("[target] fades back into view."), span_notice("You become visible again.")), 15 SECONDS)
	return FALSE

//LIGHTNING---------------

/obj/effect/proc_holder/spell/arcane/projectile/lightningbolt
	name = "Bolt of Lightning"
	desc = ""
	overlay_state = "lightning"
	sound = 'sound/magic/lightning.ogg'
	range = 8
	projectile_type = /obj/projectile/magic/lightning
	releasedrain = 30
	chargedrain = 1
	chargetime = 15
	charge_max = 10 SECONDS
	movement_interrupt = FALSE
	charging_slowdown = 3

/obj/projectile/magic/lightning
	name = "bolt of lightning"
	tracer_type = /obj/effect/projectile/tracer/stun
	muzzle_type = null
	impact_type = null
	hitscan = TRUE
	movement_type = UNSTOPPABLE
	light_color = LIGHT_COLOR_WHITE
	damage = 15
	damage_type = BURN
	nodamage = FALSE
	speed = 0.3
	flag = "magic"
	light_color = "#ffffff"
	light_range = 7

/obj/projectile/magic/lightning/on_hit(target)
	. = ..()
	if(ismob(target))
		var/mob/M = target
		if(M.anti_magic_check())
			visible_message(span_warning("[src] fizzles on contact with [target]!"))
			playsound(get_turf(target), 'sound/magic/magic_nulled.ogg', 100)
			qdel(src)
			return BULLET_ACT_BLOCK
		if(isliving(target))
			var/mob/living/L = target
//			for(var/obj/item/I in L.get_equipped_items())	//Maybe add 5 damage for each metal gear in the target? 
//				if(I.smeltresult == /obj/item/ingot/iron)	//More damage if the target is on water tuff too?
//					damage += 5    							//(dont know it that code work tho)
			L.electrocute_act(1, src)
	qdel(src)


//FIREBALL-------------------------

/obj/effect/proc_holder/spell/arcane/projectile/fireball
	name = "Fireball"
	desc = ""
	clothes_req = FALSE
	range = 8
	projectile_type = /obj/projectile/magic/aoe/fireball/rogue
	overlay_state = "fireball"
	sound = list('sound/magic/fireball.ogg')
	active = FALSE
	releasedrain = 30
	chargedrain = 1
	chargetime = 15
	charge_max = 10 SECONDS
	warnie = "spellwarning"
	no_early_release = TRUE
	movement_interrupt = FALSE
	charging_slowdown = 3

/obj/effect/proc_holder/spell/arcane/projectile/fireball/fire_projectile(list/targets, mob/living/user)
	projectile_var_overrides = list("range" = 8)
	return ..()

/obj/projectile/magic/aoe/fireball/rogue
	name = "fireball"
	exp_heavy = 0
	exp_light = 0
	exp_flash = 0
	exp_fire = 1
	damage = 10
	damage_type = BURN
	nodamage = FALSE
	flag = "magic"
	hitsound = 'sound/blank.ogg'


/obj/projectile/magic/aoe/fireball/rogue/on_hit(target)
	. = ..()
	if(ismob(target))
		var/mob/M = target
		if(M.anti_magic_check())
			visible_message(span_warning("[src] fizzles on contact with [target]!"))
			playsound(get_turf(target), 'sound/magic/magic_nulled.ogg', 100)
			qdel(src)
			return BULLET_ACT_BLOCK



/obj/effect/proc_holder/spell/arcane/projectile/fireball/greater
	name = "Greater Fireball"
	desc = ""
	clothes_req = FALSE
	range = 8
	projectile_type = /obj/projectile/magic/aoe/fireball/rogue/great
	overlay_state = "greaterfireball"
	sound = list('sound/magic/fireball.ogg')
	releasedrain = 50
	chargedrain = 1
	chargetime = 15
	charge_max = 10 SECONDS
	warnie = "spellwarning"
	no_early_release = TRUE
	movement_interrupt = TRUE
	chargedloop = /datum/looping_sound/invokegen

/obj/projectile/magic/aoe/fireball/rogue/great
	name = "fireball"
	exp_heavy = 0
	exp_light = 1
	exp_flash = 2
	exp_fire = 2
	flag = "magic"

//FETCH-------------------------

/obj/effect/proc_holder/spell/arcane/projectile/fetch
	name = "Fetch"
	desc = ""
	range = 15
	projectile_type = /obj/projectile/magic/fetch
	overlay_state = "fetch"
	sound = list('sound/magic/magnet.ogg')
	releasedrain = 5
	chargedrain = 0
	chargetime = 0
	charge_max = 5 SECONDS
	warnie = "spellwarning"
	no_early_release = TRUE
	charging_slowdown = 1

/obj/projectile/magic/fetch/on_hit(target)
	. = ..()
	if(ismob(target))
		var/mob/M = target
		if(M.anti_magic_check())
			visible_message(span_warning("[target] repells the fetch!"))
			playsound(get_turf(target), 'sound/magic/magic_nulled.ogg', 100)
			qdel(src)
			return BULLET_ACT_BLOCK

//TELEPATHY---------------------------

/obj/effect/proc_holder/spell/arcane/telepathy
	name = "telepathy"
	desc = ""
	range = 15
	overlay_state = "psy"
	sound = list('sound/magic/magnet.ogg')
	releasedrain = 20
	chargedrain = 0
	chargetime = 0
	charge_max = 15 SECONDS
	warnie = "spellwarning"
	no_early_release = TRUE
	charging_slowdown = 1

/obj/effect/proc_holder/spell/arcane/telepathy/cast(list/targets,mob/user = usr)
	. = ..()
	if(isliving(targets[1]))
		var/mob/living/target = targets[1]
		if(target.anti_magic_check(TRUE, TRUE))
			return FALSE
		var/input = stripped_input(user, "What message are you sending?", null, "")
		if(!input)
			return FALSE
		to_chat(user, span_warning("I transmit to [target]: " + "[input]"))
		to_chat(target, span_warning("You hear a voice in your head saying: ") + span_boldwarning("[input]"))
		return TRUE

//UNLOCK <WIP>--------------------------

/obj/effect/proc_holder/spell/arcane/unlock
	name = "unlock"
	desc = ""
	range = 1
	overlay_state = "lock"
	sound = list('sound/magic/magnet.ogg')
	releasedrain = 20
	chargedrain = 1
	chargetime = 30
	charge_max = 15 SECONDS
	warnie = "spellwarning"
	no_early_release = TRUE
	charging_slowdown = 1

///obj/effect/proc_holder/spell/arcane/unlock/cast(list/targets,mob/user = usr)
//	. = ..()
//	if(istype(targets[1], (/obj/structure/mineral_door/ | /obj/structure/closet)))
//		var/obj/O = targets[1]
//		if(O.door_opened || O.isSwitchingStates)
//			to_chat(user, "<span class='warning'>It is already open.</span>")
//			return TRUE
//		if(!O.keylock)
//			to_chat(user, "<span class='warning'>There's no lock on this.</span>")
//			return TRUE
//		return
//		if(O.lockbroken)
//			to_chat(user, "<span class='warning'>The lock is broken.</span>")
//			return TRUE
//		else
//			var/prob2open = 0
//			var/diceroll = 0
//				if(user && user.mind)
//			prob2open = 20
//			diceroll = rand(0,100)
//			for(var/i in 1 to user.mind.get_skill_level(/datum/skill/magic/arcane))
//				prob2open += 5
//			if (diceroll <= prob2open)
//				if(istype(targets[1], /obj/structure/mineral_door/)
//					lock_toggle(O)
//				if(istype(targets[1], /obj/structure/closet)
//					togglelock(O)
//			else
//				to_chat(user, "<span class='warning'>The spell fails to unlock it...</span>")
//				
//			return TRUE
//	else
//		return TRUE
//I cant code for shit, will rethink this later.

