extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var heart_1: AnimatedSprite2D = $Camera2D/Hud/BoxContainer/Heart_1
@onready var heart_2: AnimatedSprite2D = $Camera2D/Hud/BoxContainer/Heart_2
@onready var heart_3: AnimatedSprite2D = $Camera2D/Hud/BoxContainer/Heart_3

# Movement Constants
const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# HP Variables
var MAX_HP = 6
var HP = MAX_HP
var armored = true
var godmode_state = false
var is_dead = false
# Armor checkers
var armor_played2 = false
var armor_played3 = false
var armor_played3_2 = false
# HP checkers
var heart_played1 = false
var heart_played2 = false
var heart_played3 = false

# Physics and Animations
func _physics_process(delta: float):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if is_dead == false:
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("left", "right")
	if is_dead == false:
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	# Animation Handling
	if is_dead == false:
	# Walk
		if velocity.x != 0 and animated_sprite_2d.animation != "jump":
			animated_sprite_2d.play("Walk")

		# Jump
		elif velocity.y != 0:
			animated_sprite_2d.play("Jump")

		# Idle
		else:
			animated_sprite_2d.play("Idle")

	# Animation Flipping
	if is_dead == false:
		if direction == 0:
			pass
		elif direction > 0:
			animated_sprite_2d.flip_h = true
		elif direction < 0:
			animated_sprite_2d.flip_h = false

	move_and_slide()
	Health()


# HP
func heal(number):
	HP += number
	print(HP)

func hit(number):
	HP -= number
	print(HP)

func debug_hit():
	if Input.is_action_just_pressed("debug1"):
		hit(1)
		print(HP)

func debug_heal():
	if Input.is_action_just_pressed("debug2"):
		heal(1)
		print(HP)

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

func unarmor():
	if godmode_state == false:
		if armored == true:
			MAX_HP = 6
		else:
			MAX_HP = 3


#Health HUD Animations And death call ( "die()" )
func Health():
	unarmor()
	godmode()
	debug_hit()
	debug_heal()

	# Godmode
	if HP > 1000:
		heart_1.play("Godmode")
		heart_2.play("Godmode")
		heart_3.play("Godmode")

	if godmode_state == false:
		# Full armor
		if HP == 6:
			armor_played2 = false
			armor_played3 = false
			armor_played3_2 = false
			heart_1.play("Full_Armored")
			heart_2.play("Full_Armored")
			heart_3.play("Full_Armored")
			armored = true

		# 5 HP
		elif HP == 5:
			armor_played2 = false
			armor_played3_2 = false
			heart_1.play("Full_Armored")
			heart_2.play("Full_Armored")
			if armor_played3 == false:
				heart_3.play("Full_Armored_Hit")
				armor_played3 = true
			armored = true

		# 4 HP
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
			armored = true

		# Armor breaks at 3 HP
		elif HP == 3 and armored:
			heart_played1 = false
			heart_played2 = false
			heart_played3 = false
			heart_1.play("Full_Armored_Break")
			heart_2.play("Full_Armored_Break")
			heart_3.play("Full_Armored_Break")

			# Prevents the break animation from being triggered again
			armored = false

		# Normal hearts
		elif HP == 3 and not armored:
			heart_played1 = false
			heart_played2 = false
			heart_played3 = false
			if heart_1.animation != "Full_Armored_Break":
				heart_1.play("Full")
				heart_2.play("Full")
				heart_3.play("Full_Animated")

		# 2 HP
		elif HP == 2:
			heart_played1 = false
			heart_played2 = false
			heart_1.play("Full")
			heart_2.play("Full_Animated")
			if heart_played3 == false:
				heart_3.play("Full_Hit")
				heart_played3 = true

		# 1 HP
		elif HP == 1:
			heart_played1 = false
			heart_1.play("Full_Animated")
			if heart_played2 == false:
				heart_2.play("Full_Hit")
				heart_played2 = true
			heart_3.play("Empty")

		# Dead
		elif HP <= 0:
			if heart_played1 == false:
				heart_1.play("Full_Hit")
				heart_played1 = true
			heart_2.play("Empty")
			heart_3.play("Empty")
			animated_sprite_2d.play("Die")
			is_dead = true

	# Prevent HP exceeding MAX_HP
	if HP > MAX_HP:
		HP = MAX_HP


# Armor break animation finished
func _on_heart_1_animation_finished():
	if heart_1.animation == "Full_Armored_Break":
		heart_1.play("Full")
		heart_2.play("Full")
		heart_3.play("Full_Animated")

# Dying
func die():
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")

func _on_animated_sprite_2d_animation_finished():
	if animated_sprite_2d.animation == "Die":
		die()
