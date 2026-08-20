extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var HP = 3

var is_flashing := false

func flash_white():
	if is_flashing:
		return

	is_flashing = true

	var material_ := animated_sprite_2d.material as ShaderMaterial
	if material == null:
		return

	material_.set_shader_parameter("flash_amount", 0.25)

	await get_tree().create_timer(0.08).timeout

	material_.set_shader_parameter("flash_amount", 0.0)

	is_flashing = false

func take_damage():
	HP -= 1
	flash_white()

	if HP <= 0:
		die()

func die():
	animated_sprite_2d.play("die")

func _on_hurt_box_body_entered(_body: Node2D) -> void:
	take_damage()


func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()
