extends Node2D

@export var particle_texture: Texture2D
@export var particle_count: int = 8

@export var spread_distance_min: float = 8.0
@export var spread_distance_max: float = 20.0

@export var particle_speed_min: float = 30.0
@export var particle_speed_max: float = 60.0

@export var lifetime: float = 0.18

@export var particle_size: float = 1.0


func play() -> void:
	for i: int in range(particle_count):
		spawn_particle()


func spawn_particle() -> void:
	var particle: Sprite2D = Sprite2D.new()

	particle.texture = particle_texture
	particle.scale = Vector2.ONE * particle_size
	particle.global_position = global_position

	get_tree().current_scene.add_child(particle)

	# Random direction
	var angle: float = randf_range(0.0, TAU)
	var direction: Vector2 = Vector2.from_angle(angle)

	var distance: float = randf_range(
		spread_distance_min,
		spread_distance_max
	)

	var target_position: Vector2 = (
		global_position + direction * distance
	)

	var duration: float = lifetime

	# Move outward
	var tween: Tween = create_tween()

	tween.tween_property(
		particle,
		"global_position",
		target_position,
		duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# Fade out at the same time
	tween.parallel().tween_property(
		particle,
		"modulate:a",
		0.0,
		duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	# Remove particle
	tween.tween_callback(particle.queue_free)
