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
	if area.has_method("take_damage"):
		area.take_damage(1)
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	# Ignore player
	if body.is_in_group("player"):
		return
	# Destroy if touches something rigid
	if body.is_in_group("rigid"):
		queue_free()
