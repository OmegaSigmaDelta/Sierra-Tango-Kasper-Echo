extends Node2D

const ABSORB_EFFECT = preload(
	"res://scenes/effects/pickup_absorb_effect.tscn"
)


func _on_beer_area_entered(area: Area2D) -> void:
	var entered: Node = area.get_parent()

	if entered.has_method("beer_refill"):
		# Create the absorb effect
		var effect: Node2D = ABSORB_EFFECT.instantiate()

		effect.global_position = global_position

		get_tree().current_scene.add_child(effect)

		# Make the particles fly toward Ram
		effect.play(entered)

		# Hide the beer
		$Sprite2D.hide()

		# Disable the pickup collision
		$Beer/CollisionShape2D.set_deferred(
			"disabled",
			true
		)

		# Refill beer
		if is_instance_valid(entered):
			entered.beer_refill()

		# Remove the pickup
		queue_free()
