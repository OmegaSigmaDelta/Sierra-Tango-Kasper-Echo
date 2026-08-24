extends Area2D

@export var speed := 500.0
@export var max_distance := 1000.0

const PARTICLE_EFFECT = preload(
	"res://scenes/effects/projectile_particle_effect.tscn"
)

var direction := Vector2.ZERO
var start_position := Vector2.ZERO


func _ready():
	var effect: Node2D = PARTICLE_EFFECT.instantiate()

	effect.global_position = global_position

	get_tree().current_scene.add_child(effect)

	effect.play()


func _physics_process(delta):
	global_position += direction * speed * delta

	if global_position.distance_to(start_position) >= max_distance:
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.has_method("take_damage"):
		area.take_damage(1)
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	# Don't destroy the projectile if it touches the player
	if body.is_in_group("player"):
		return

	# Destroy on any physics body
	queue_free()
