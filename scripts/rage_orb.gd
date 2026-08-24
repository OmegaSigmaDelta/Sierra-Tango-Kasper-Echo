extends Node2D

const ABSORB_EFFECT = preload(
	"res://scenes/effects/pickup_absorb_effect.tscn"
)


func _on_rage_orb_area_entered(area: Area2D) -> void:
	var entered = area.get_parent()

	if entered.has_method("rage_refill"):

		# Spawn the absorption effect
		var effect = ABSORB_EFFECT.instantiate()

		effect.global_position = global_position

		get_tree().current_scene.add_child(effect)

		# Play the effect toward Ram
		effect.play(entered)

		# Hide the actual orb
		$AnimatedSprite2D.hide()

		# Disable its collision
		$RageOrb/CollisionShape2D.set_deferred(
			"disabled",
			true
		)

		# Refill rage
		entered.rage_refill(100)

		# Remove the orb
		queue_free()
