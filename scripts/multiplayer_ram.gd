extends CharacterBody2D

@export var speed := 300.0


func _physics_process(_delta):
	# Only control the player that belongs to this computer
	if not is_multiplayer_authority():
		return

	var direction = Input.get_vector(
		"left",
		"right",
		"up",
		"down"
	)

	velocity = direction * speed

	move_and_slide()
