extends CharacterBody2D

const PROJECTILE = preload("res://scenes/items/projectile.tscn")

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@onready var heart_1: AnimatedSprite2D = get_node("/root/Game/CanvasLayer/Hud/Hearts/Heart_Slot1/Heart_1")
@onready var heart_2: AnimatedSprite2D = get_node("/root/Game/CanvasLayer/Hud/Hearts/Heart_Slot2/Heart_2")
@onready var heart_3: AnimatedSprite2D = get_node("/root/Game/CanvasLayer/Hud/Hearts/Heart_Slot3/Heart_3")

@onready var heal_1: AnimatedSprite2D = get_node("/root/Game/CanvasLayer/Hud/Heals/Heal_Slot1/Heal1")
@onready var heal_2: AnimatedSprite2D = get_node("/root/Game/CanvasLayer/Hud/Heals/Heal_Slot2/Heal2")

@onready var progress_bar: ProgressBar = get_node("/root/Game/CanvasLayer/Hud/ProgressBar")

@onready var gamepad_crosshair: Node2D = $GamepadCrosshair

# Constants
const SPEED = 200.0
const JUMP_VELOCITY := -300.0
const MIN_JUMP_VELOCITY := -200.0
const JUMP_HOLD_TIME := 0.25
const JUMP_BUFFER_TIME: float = 0.12

# Health variables
var MAX_HP = 6
var HP = MAX_HP
var MAX_HEALS = 2
var heals = MAX_HEALS
var in_armor = true
var armored = true
var armor_broke = false
var godmode_state = false
var is_dead = false
var is_healing = false

# I-frames
const IFRAME_DURATION = 1.0
var is_invulnerable = false

# Armor animation checkers
var armor_played2 = false
var armor_played3 = false
var armor_played3_2 = false

# Health animation checkers
var heart_played1 = false
var heart_played2 = false
var heart_played3 = false

# Rage bar tweening
var rage_tween: Tween

# Coyote frames
var jump_timer: float = 0.0
var is_holding_jump: bool = false
var jump_buffer_timer: float = 0.0

# Rage declaration
var rage: int = 100:
	set(value):
		rage = clampi(value, 0, 100)

		if is_node_ready() and progress_bar:
			if rage_tween:
				rage_tween.kill()

			rage_tween = create_tween()
			rage_tween.tween_property(
				progress_bar,
				"value",
				float(rage),
				0.25
			).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

# Crosshair stuff
const CROSSHAIR_DISTANCE: float = 50.0
const RIGHT_STICK_DEADZONE: float = 0.2
var aim_direction: Vector2 = Vector2.RIGHT
var using_gamepad_aim: bool = false
var last_mouse_position: Vector2

func _ready() -> void:
	progress_bar.min_value = 0
	progress_bar.max_value = 100
	progress_bar.value = rage
	last_mouse_position = get_viewport().get_mouse_position()
	gamepad_crosshair.hide()


func _physics_process(delta: float):
	if not is_on_floor():
		velocity += get_gravity() * delta

# Jump handling
	if is_dead == false:
		if Input.is_action_just_pressed("jump"):
			jump_buffer_timer = JUMP_BUFFER_TIME

		if jump_buffer_timer > 0.0:
			jump_buffer_timer -= delta

		if jump_buffer_timer > 0.0 and is_on_floor():
			jump_buffer_timer = 0.0
			velocity.y = MIN_JUMP_VELOCITY
			jump_timer = 0.0
			is_holding_jump = true

		if Input.is_action_pressed("jump") and is_holding_jump:
			jump_timer += delta

			var jump_progress: float = clampf(
				jump_timer / JUMP_HOLD_TIME,
				0.0,
				1.0
			)

			velocity.y = lerp(
				MIN_JUMP_VELOCITY,
				JUMP_VELOCITY,
				jump_progress
			)

			if jump_progress >= 1.0:
				is_holding_jump = false

		if Input.is_action_just_released("jump"):
			is_holding_jump = false


# Moving
	var direction := Input.get_axis("left", "right")

	if is_dead == false and is_healing == false:
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

# Animation handling
	if is_dead == false and is_healing == false:
		if velocity.x != 0 and animated_sprite_2d.animation != "jump":
			if in_armor == true:
				animated_sprite_2d.play("Walk_Armored")
			elif in_armor == false:
				animated_sprite_2d.play("Walk")
		elif velocity.y != 0:
			if in_armor == true:
				animated_sprite_2d.play("Jump_Armored")
			elif in_armor == false:
				animated_sprite_2d.play("Jump")
		else:
			if in_armor == true:
				animated_sprite_2d.play("Idle_Armored")
			elif in_armor == false:
				animated_sprite_2d.play("Idle")

# Sprite flipping
	if is_dead == false:
		if direction == 0:
			pass
		elif direction > 0:
			animated_sprite_2d.flip_h = true
		elif direction < 0:
			animated_sprite_2d.flip_h = false

# Gamepad aiming
	var aim_input: Vector2 = Input.get_vector(
		"aim_left",
		"aim_right",
		"aim_up",
		"aim_down"
	)

	if aim_input.length() > RIGHT_STICK_DEADZONE:
		aim_direction = aim_input.normalized()

	gamepad_crosshair.position = aim_direction * CROSSHAIR_DISTANCE

	move_and_slide()
	Health()
	fullscreen()
	shoot()
	update_aim()

func update_aim() -> void:
	var aim_input: Vector2 = Input.get_vector(
		"aim_left",
		"aim_right",
		"aim_up",
		"aim_down"
	)

	var mouse_position: Vector2 = get_viewport().get_mouse_position()

	if aim_input.length() > RIGHT_STICK_DEADZONE:
		using_gamepad_aim = true
		aim_direction = aim_input.normalized()

		gamepad_crosshair.show()
		gamepad_crosshair.position = aim_direction * CROSSHAIR_DISTANCE

		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	elif mouse_position != last_mouse_position:
		using_gamepad_aim = false

		gamepad_crosshair.hide()

		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	last_mouse_position = mouse_position

# Get healed by [number]
func heal(number):
	if HP < MAX_HP:
		HP += number
		print(HP)
# Get damaged by [number]
func hit(number):
	if is_invulnerable:
		return

	if is_dead:
		return

	HP -= number
	print(HP)
	is_invulnerable = true

	for i in range(5):
		animated_sprite_2d.material.set_shader_parameter("flash_amount", 1.0)
		await get_tree().create_timer(0.10).timeout

		animated_sprite_2d.material.set_shader_parameter("flash_amount", 0.0)
		await get_tree().create_timer(0.10).timeout

	animated_sprite_2d.material.set_shader_parameter("flash_amount", 0.0)
	is_invulnerable = false
# Heal using beer
func beer_use():
	if Input.is_action_just_pressed("heal") and is_healing == false:
		if heals == 2:
			velocity.x = 0
			velocity.y = 0
			is_healing = true
			heals = 1
			animated_sprite_2d.play("Heal")
			heal_1.play("full")
			heal_2.play("use")

		elif heals == 1:
			velocity.x = 0
			velocity.y = 0
			is_healing = true
			heals = 0
			animated_sprite_2d.play("Heal")
			heal_1.play("use")
			heal_2.play("empty")
# Recover beer uses
func beer_refill():
	if heals == 1:
		heals = 2
		heal_1.play("full")
		heal_2.play("refill")

	elif heals == 0:
		heals = 1
		heal_1.play("refill")
		heal_2.play("empty")
# Damage yourself by 1 (debug 1)
func debug_hit():
	if Input.is_action_just_pressed("debug1"):
		hit(1)
		print(HP)
# Heal 1 hp (debug 2)
func debug_heal():
	if Input.is_action_just_pressed("debug2"):
		heal(1)
		print(HP)
# Swap between armored and unarmored animations (debug 3)
func debug_armor():
	if Input.is_action_just_pressed("debug3"):
		if in_armor == true:
			in_armor = false
		elif in_armor == false:
			in_armor = true
# Set HP to 100000000 (debug ~)
func godmode():
	if Input.is_action_just_pressed("debug~"):
		if godmode_state == false:
			godmode_state = true
			MAX_HP = 100000000
			HP = 100000000
			print("godmode activated")

		elif godmode_state == true:
			godmode_state = false
			MAX_HP = 6
			HP = 6
			print("godmode deactivated")
# bugged, does nothing
func unarmor():
	if godmode_state == false:
		if armored == true:
			MAX_HP = 6
		else:
			MAX_HP = 3
# Swap between Fullscreen and Windowed (F11)
func fullscreen():
	if Input.is_action_just_pressed("fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
# Shoot a projectile that deals 1 damage (Lmb/RT) 
func shoot():
	if Input.is_action_just_pressed("shoot"):
		if rage >= 25:
			rage -= 25

			var projectile = PROJECTILE.instantiate()
			var shoot_direction: Vector2

			if using_gamepad_aim:
				shoot_direction = aim_direction
			else:
				var mouse_position: Vector2 = get_global_mouse_position()
				shoot_direction = global_position.direction_to(mouse_position)

			projectile.global_position = global_position
			projectile.direction = shoot_direction

			get_parent().add_child(projectile)
# Set rage to 100
func debug_rage():
	if Input.is_action_just_pressed("debug4"):
		rage = 100
# Handle Health and UI updates
func Health():
	beer_use()
	unarmor()
	godmode()
	debug_hit()
	debug_heal()
	debug_armor()
	debug_rage()

	if HP > 1000:
		heart_1.play("Godmode")
		heart_2.play("Godmode")
		heart_3.play("Godmode")

	if godmode_state == false:
		if HP == 6:
			armor_played2 = false
			armor_played3 = false
			armor_played3_2 = false

			heart_1.play("Full_Armored")
			heart_2.play("Full_Armored")
			heart_3.play("Full_Armored")

		elif HP == 5:
			armor_played2 = false
			armor_played3_2 = false

			heart_1.play("Full_Armored")
			heart_2.play("Full_Armored")

			if armor_played3 == false:
				heart_3.play("Full_Armored_Hit")
				armor_played3 = true

		elif HP == 4:
			if armor_played3_2 == false:
				armor_played3_2 = true
				armor_played3 = false

			heart_1.play("Full_Armored")

			if armor_played2 == false:
				heart_2.play("Full_Armored_Hit")
				armor_played2 = true

			if armor_played3 == false:
				heart_3.play("Full_Armored_Hit")
				armor_played3 = true
				armor_broke = false

		elif HP == 3 and armor_broke == false:
			heart_played1 = false
			heart_played2 = false
			heart_played3 = false

			heart_1.play("Full_Armored_Break")
			heart_2.play("Full_Armored_Break")
			heart_3.play("Full_Armored_Break")

			armor_broke = true

		elif HP == 3 and armor_broke == true:
			heart_played1 = false
			heart_played2 = false
			heart_played3 = false

			if heart_1.animation != "Full_Armored_Break":
				heart_1.play("Full")
				heart_2.play("Full")
				heart_3.play("Full_Animated")

		elif HP == 2:
			heart_played1 = false
			heart_played2 = false

			heart_1.play("Full")
			heart_2.play("Full_Animated")

			if heart_played3 == false:
				heart_3.play("Full_Hit")
				heart_played3 = true

		elif HP == 1:
			heart_played1 = false

			heart_1.play("Full_Animated")

			if heart_played2 == false:
				heart_2.play("Full_Hit")
				heart_played2 = true

			heart_3.play("Empty")

		elif HP <= 0:
			if heart_played1 == false:
				heart_1.play("Full_Hit")
				heart_played1 = true

			heart_2.play("Empty")
			heart_3.play("Empty")

			die()

	if HP > MAX_HP:
		HP = MAX_HP


func _on_heart_1_animation_finished():
	if heart_1.animation == "Full_Armored_Break":
		heart_1.play("Full")
		heart_2.play("Full")
		heart_3.play("Full_Animated")


func die():
	is_dead = true
	velocity.x = 0
	velocity.y = 0
	animated_sprite_2d.play("Die")


func _on_animated_sprite_2d_animation_finished():
	if animated_sprite_2d.animation == "Die":
		get_tree().change_scene_to_file("res://scenes/menus/game_over.tscn")

	if animated_sprite_2d.animation == "Heal":
		is_healing = false
		heal(2)


func _on_item_check_area_entered(_area: Area2D):
	beer_refill()
