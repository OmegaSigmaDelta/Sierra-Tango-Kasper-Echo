extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@export var beer_scene = preload("uid://e6exbou7wbfr")

var HP = 3
var chance = randi() % 10 + 1
var is_flashing := false


func flash_white():
	if is_flashing:
		return

	is_flashing = true

	@warning_ignore("shadowed_variable_base_class")
	var material := animated_sprite_2d.material as ShaderMaterial

	if material == null:
		is_flashing = false
		return

	material.set_shader_parameter("flash_amount", 0.25)

	await get_tree().create_timer(0.08).timeout

	material.set_shader_parameter("flash_amount", 0.0)

	is_flashing = false

func die():
	if beer_scene:
		if chance == 10:
			var beer = beer_scene.instantiate()
			get_tree().current_scene.add_child(beer)
			beer.global_position = global_position

	animated_sprite_2d.play("die")


func _on_animated_sprite_2d_animation_finished():
	queue_free()


func _on_hurt_box_body_entered(body: Node2D):
	if body.has_method("hit"):
		body.hit(1)
