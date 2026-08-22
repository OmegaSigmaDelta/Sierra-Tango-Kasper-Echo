extends "res://addons/MetroidvaniaSystem/Template/Scripts/MetSysModule.gd"


func _initialize() -> void:
	MetSys.room_changed.connect(_on_room_changed, CONNECT_DEFERRED)


func _on_room_changed(target_room: String) -> void:
	if target_room == MetSys.get_current_room_id():
		return

	var prev_room_instance = MetSys.get_current_room_instance()

	# Get the fade from the game scene.
	var fade: ColorRect = game.get_node("CanvasLayer/Fade")

	# Fade OUT.
	var tween: Tween = game.get_tree().create_tween()
	tween.tween_property(fade, "color:a", 1.0, 0.25)
	await tween.finished

	# IMPORTANT:
	# Keep the original MetSys room transition behavior.
	if prev_room_instance:
		prev_room_instance.get_parent().remove_child(prev_room_instance)

	await game.load_room(target_room)

	if prev_room_instance:
		game.player.position -= MetSys.get_current_room_instance().get_room_position_offset(prev_room_instance)
		prev_room_instance.queue_free()

	# Fade IN.
	tween = game.get_tree().create_tween()
	tween.tween_property(fade, "color:a", 0.0, 0.25)
