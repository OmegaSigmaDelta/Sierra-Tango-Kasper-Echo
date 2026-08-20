extends Area2D

@onready var damage_label: Label = $DamageLabel/DamageLabel

var damage_done := 0


func take_damage(number):
	damage_done += number
	damage_label.text = str(damage_done)
