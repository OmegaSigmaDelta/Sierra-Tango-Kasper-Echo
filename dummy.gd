extends Area2D

@onready var damage_label: Label = $DamageLabel/DamageLabel

var damagedone = 0

func take_damage(number):
	damagedone += number
	damage_label.text = damagedone
