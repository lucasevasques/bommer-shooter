extends Node3D

const BOX = preload("uid://d11w4hb0oj1fd")

@onready var animation_box: Node3D = $"."
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_open: bool = false

func take_damage(amount: float) -> void:
	animation_player.play("Cube_001Action")
