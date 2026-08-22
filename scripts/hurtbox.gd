extends Area2D

@export var ram: CharacterBody2D


# Check if something collides with the hurtbox
func _on_area_entered(_body):
	ram.hit(1)
