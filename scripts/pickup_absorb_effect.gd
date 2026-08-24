extends Node2D

@export var particle_texture: Texture2D
@export var particle_count: int = 12

@export var burst_distance_min: float = 15.0
@export var burst_distance_max: float = 35.0

@export var burst_time: float = 0.15
@export var absorb_speed: float = 350.0

@export var particle_size: float = 1.0


func play(target: Node2D) -> void:
	for i: int in range(particle_count):
		spawn_particle(target)


func spawn_particle(target: Node2D) -> void:
	var particle: Sprite2D = Sprite2D.new()

	particle.texture = particle_texture
	particle.scale = Vector2.ONE * particle_size
	particle.global_position = global_position

	get_tree().current_scene.add_child(particle)

	# Random burst direction
	var angle: float = randf_range(0.0, TAU)
	var direction: Vector2 = Vector2.from_angle(angle)

	var burst_distance: float = randf_range(
		burst_distance_min,
		burst_distance_max
	)

	var burst_position: Vector2 = (
		global_position
		+ direction * burst_distance
	)

	# Scatter outward
	var burst_tween: Tween = create_tween()

	burst_tween.tween_property(
		particle,
		"global_position",
		burst_position,
		burst_time
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# Start homing after burst
	burst_tween.tween_callback(
		start_homing.bind(particle, target)
	)


func start_homing(particle: Sprite2D, target: Node2D) -> void:
	if not is_instance_valid(particle):
		return

	if not is_instance_valid(target):
		particle.queue_free()
		return

	var homing_particle: HomingParticle = HomingParticle.new()

	homing_particle.particle = particle
	homing_particle.target = target
	homing_particle.speed = absorb_speed
	homing_particle.particle_size = particle_size

	get_tree().current_scene.add_child(homing_particle)


class HomingParticle extends Node2D:

	var particle: Sprite2D
	var target: Node2D
	var speed: float
	var particle_size: float


	func _process(delta: float) -> void:
		if not is_instance_valid(particle):
			queue_free()
			return

		if not is_instance_valid(target):
			particle.queue_free()
			queue_free()
			return

		var target_position: Vector2 = target.global_position

		var direction: Vector2 = (
			particle.global_position.direction_to(target_position)
		)

		particle.global_position += direction * speed * delta

		# Shrink as the particle approaches Ram
		var distance: float = (
			particle.global_position.distance_to(target_position)
		)

		var shrink_amount: float = clamp(
			distance / 100.0,
			0.0,
			1.0
		)

		particle.scale = (
			Vector2.ONE
			* particle_size
			* shrink_amount
		)

		# Particle reached Ram
		if distance < 5.0:
			particle.queue_free()
			queue_free()
