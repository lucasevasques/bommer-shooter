class_name Enemy
extends CharacterBody3D

signal player_requested

var player: Node3D
@onready var raycast: RayCast3D = $RayCast3D



func _ready() -> void:
	await get_tree().physics_frame
	player_requested.emit(self)
	
	
func _physics_process(delta: float) -> void:
	if player == null:
		return
	raycast.global_position = global_position + Vector3(0, 1.5,0)
	var look_target: Vector3 = player.global_position + Vector3(0, 2, 0)
	raycast.look_at(look_target, Vector3.UP, true)
	
	var rotation_target: Vector3 = raycast.global_rotation
	rotation_target *= Vector3(0,1,0)
	rotation_target = rotation_target.normalized()
	
	global_rotation.y = raycast.global_position.y
