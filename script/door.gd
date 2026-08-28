extends Node3D


@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_open: bool = false

func open() -> void:
	if is_open == true:
		return
	animation_player.play("open")
	is_open = true 
