extends Control

@onready var start: Button = $Start


func _ready():
	hide()


func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		if get_tree().paused:
			close_pause_menu()
		else:
			open_pause_menu()
			start.grab_focus()


func open_pause_menu():
	show()
	get_tree().paused = true


func close_pause_menu():
	hide()
	get_tree().paused = false


func _on_resume_pressed():
	close_pause_menu()
