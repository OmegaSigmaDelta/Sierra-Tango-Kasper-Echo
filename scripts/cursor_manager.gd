extends Node

enum CursorState {
	NORMAL,
	PRESSED,
	DRAGGING
}

var normal_cursor = preload("res://assets/sprites/UI/cursor/pointer.png")
var pressed_cursor = preload("res://assets/sprites/UI/cursor/click.png")
var drag_cursor = preload("res://assets/sprites/UI/cursor/grab.png")

var current_state: CursorState = CursorState.NORMAL


func _ready():
	set_cursor(CursorState.NORMAL)


func set_cursor(new_state: CursorState):
	current_state = new_state

	match current_state:
		CursorState.NORMAL:
			Input.set_custom_mouse_cursor(normal_cursor)

		CursorState.PRESSED:
			Input.set_custom_mouse_cursor(pressed_cursor)

		CursorState.DRAGGING:
			Input.set_custom_mouse_cursor(drag_cursor)


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if current_state != CursorState.DRAGGING:
					set_cursor(CursorState.PRESSED)
			else:
				if current_state == CursorState.DRAGGING:
					set_cursor(CursorState.NORMAL)
				else:
					set_cursor(CursorState.NORMAL)
