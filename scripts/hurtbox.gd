extends Area2D

@export var ram: CharacterBody2D


# Check if something collides with the hurtbox
func _on_area_entered(area: Area2D):
	print("damaged by  something")
	ram.hit(1)
