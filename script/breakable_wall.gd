extends Node3D

const BREAKABLE_WALL_PIECES = preload("uid://l1ipsxguphct")

@onready var breakable_wall: Node3D = $BreakableWall2
@onready var collision_shape: CollisionShape3D = $BreakSensor/CollisionShape3D
var is_destroyed: bool = false
@onready var rigid_body: StaticBody3D = $RigidBody3D
@onready var collision_wall: CollisionShape3D = $RigidBody3D/CollisionWall



func _ready() -> void:
	if is_destroyed == false:
		collision_wall.disabled = false
	
	
	
func take_damage(amount: float) -> void:
	breakable_wall.hide()
	is_destroyed = true
	collision_shape.disabled = true
	collision_wall.disabled = true
	var pieces: Node3D = BREAKABLE_WALL_PIECES.instantiate()
	add_child(pieces)
