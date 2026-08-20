extends CharacterBody2D

@export var speed := 700.0

var direction := Vector2.RIGHT


func _physics_process(delta):
	position += direction * speed * delta
