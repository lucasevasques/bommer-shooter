class_name Enemy
extends CharacterBody3D

signal player_requested

@export_range(0, 100, 1, "or_greater") var hp: int:
	set(value):
		hp = value
		if  hp <= 0:
			die()

var player: Node3D
var is_dying: bool = false

@onready var raycast: RayCast3D = $RayCast3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var hit_particles: GPUParticles3D = $HitParticles



func _ready() -> void:
	await get_tree().physics_frame
	player_requested.emit(self)
	
	
func _physics_process(delta: float) -> void:
	if player == null:
		return
	if is_dying == true:
		return
	raycast.global_position = global_position + Vector3(0, 1.5, 0)
	var look_target: Vector3 = player.global_position + Vector3(0, 1, 0)
	raycast.look_at(look_target, Vector3.UP, true)
	
	global_rotation.y = raycast.global_rotation.y
	print(player, " ", raycast)
	if raycast.is_colliding():
		if "Player" in raycast.get_collider().name:
			print("To te vendo")
		

func take_damage(amount: float) -> void:
	if is_dying == true:
		return
	hit_particles.restart()
	hp -= amount
	if hp <=0:
		die()
		
		
func die() -> void:
	if is_dying == false:
		is_dying = true
	animation_player.play("death")
