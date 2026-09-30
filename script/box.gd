extends Node3D




@onready var animation_player: AnimationPlayer = $AnimationBox2/AnimationPlayer


var is_open: bool = false

func take_damage(amount: float) -> void:
	animation_player.play("Cube_001Action")
	
