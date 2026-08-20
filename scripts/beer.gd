extends Node2D

func _on_beer_area_entered(_area: Area2D) -> void:
	queue_free()
