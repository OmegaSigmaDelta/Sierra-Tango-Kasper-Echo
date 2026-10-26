extends Area2D

@onready var damage_label: Label = $DamageLabel/DamageLabel

var damage_done := 0


func take_damage(number):
	damage_done += number
	damage_label.text = str(damage_done)


# FIX: в dummy.tscn к этому методу подключён сигнал body_entered,
# а метода не было -> ошибка подключения при загрузке сцены.
func _on_body_entered(_body: Node2D) -> void:
	pass
