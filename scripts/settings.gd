extends Control


@onready var master_slider: HSlider = $Panel/VBoxContainer/Master
@onready var music_slider: HSlider = $Panel/VBoxContainer/Music
@onready var sfx_slider: HSlider = $Panel/VBoxContainer/SFX
@onready var back_button: Button = $Panel/VBoxContainer/Back


const MASTER_BUS := 0
const MUSIC_BUS := 1
const SFX_BUS := 2


func _ready() -> void:
	master_slider.value = db_to_slider(
		AudioServer.get_bus_volume_db(MASTER_BUS)
	)

	music_slider.value = db_to_slider(
		AudioServer.get_bus_volume_db(MUSIC_BUS)
	)

	sfx_slider.value = db_to_slider(
		AudioServer.get_bus_volume_db(SFX_BUS)
	)

	master_slider.value_changed.connect(_on_master_changed)
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	back_button.pressed.connect(_on_back_pressed)
	process_mode = Node.PROCESS_MODE_ALWAYS
	back_button.focus_neighbor_top = NodePath("../SFX")


func db_to_slider(db: float) -> float:
	if db <= -80.0:
		return 0.0

	return clampf((db + 80.0) / 80.0 * 100.0, 0.0, 100.0)


func slider_to_db(value: float) -> float:
	if value <= 0.0:
		return -80.0

	return lerpf(-80.0, 0.0, value / 100.0)


func _on_master_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(
		MASTER_BUS,
		slider_to_db(value)
	)


func _on_music_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(
		MUSIC_BUS,
		slider_to_db(value)
	)


func _on_sfx_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(
		SFX_BUS,
		slider_to_db(value)
	)


func _on_back_pressed() -> void:

	hide()
