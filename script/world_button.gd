extends Node3D

signal pressed


func take_damage (_amount: float) -> void:
	pressed.emit()
	print("apertou o botao")
