extends CharacterBody2D

@export var speed := 500.0

var direction := Vector2.ZERO


func _ready():
	direction = global_position.direction_to(get_global_mouse_position())


func _physics_process(delta):
	position += direction * speed * delta


func _on_area_entered(area: Area2D) -> void:
	if area.name == "HurtBox":
		queue_free()
