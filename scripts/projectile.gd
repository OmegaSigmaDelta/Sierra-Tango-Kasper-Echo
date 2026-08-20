extends Area2D

@export var speed := 500.0
@export var max_distance := 1000.0

var direction := Vector2.ZERO
var start_position := Vector2.ZERO


func _ready():
	start_position = global_position
	direction = global_position.direction_to(get_global_mouse_position())


func _physics_process(delta):
	global_position += direction * speed * delta

	if global_position.distance_to(start_position) >= max_distance:
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.name == "HurtBox":
		var enemy = area.get_parent()

		if enemy.has_method("take_damage"):
			enemy.take_damage(1)
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		if body.is_in_group("player"):
			return

		queue_free()
