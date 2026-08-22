extends Node2D

func _on_beer_area_entered(area: Area2D) -> void:
	var entered = area.get_parent()
	if entered.has_method("beer_refill"):
		entered.beer_refill()
		queue_free()
