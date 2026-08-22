extends Node2D

func _on_rage_orb_area_entered(area: Area2D) -> void:
	var entered = area.get_parent()
	if entered.has_method("rage_refill"):
		entered.rage_refill(100)
		queue_free()
