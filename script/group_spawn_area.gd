extends Node3D

@export var width: float
@export var depth: float
@export var duration: float
@export var interval: float

@export var to_spawn: PackedScene

var is_running: bool = false
var running_delta: float = 0


func _ready() -> void:
	pass
	
	
func _physics_process(delta: float) -> void:
	if is_running == true:
		running_delta += delta
		if running_delta >= interval:
			running_delta = 0
			var new_object := to_spawn.instantiate()
			var random_x: float = randf_range(0, width)
			var random_z: float = randf_range(0, depth)
			new_object.position = Vector3(random_x, 0 , random_z)
			add_child(new_object)
	
func start() -> void:
	if is_running == true:
		return
	running_delta = 0
	is_running = true
	await get_tree().create_timer(duration).timeout
	is_running = false
