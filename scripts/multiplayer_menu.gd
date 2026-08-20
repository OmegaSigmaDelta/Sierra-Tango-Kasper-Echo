extends Control


func _on_host_button_pressed():
	MultiplayerManager.host_game()


func _on_join_button_pressed():
	MultiplayerManager.join_game($Control/VBoxContainer/IPAdress.text)
