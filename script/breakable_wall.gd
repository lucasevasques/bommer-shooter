extends Node3D

const BREAKABLE_WALL_PIECES = preload("uid://l1ipsxguphct")

@onready var breakable_wall: Node3D = $BreakableWall2
@onready var collision_shape: CollisionShape3D = $BreakSensor/CollisionShape3D


func take_damage(amount: float) -> void:
	breakable_wall.hide()
	
	collision_shape.disabled = true
	
	var pieces: Node3D = BREAKABLE_WALL_PIECES.instantiate()
	add_child(pieces)
