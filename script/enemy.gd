class_name Enemy
extends CharacterBody3D

enum State {IDLE, COMBAT, DEATH, ATTACK}

signal player_requested

@export_range(0, 100, 1, "or_greater") var hp: int:
	set(value):
		hp = value
		if  hp <= 0:
			die()

var player: Node3D
var is_dying: bool = false
var current_state: State = State.IDLE
var attack_elapsed: float = 0.0
var is_attack_started: bool = false

@onready var raycast: RayCast3D = $RayCast3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var hit_particles: GPUParticles3D = $HitParticles
@onready var sprite: Sprite3D = $Sprite3D
@onready var attack_collider: CollisionShape3D = $AttackHitbox/CollisionShape3D
@onready var attack_sound: AudioStreamPlayer3D = $AttackSound


func _ready() -> void:
	await get_tree().physics_frame
	player_requested.emit(self)
	
	
func _physics_process(delta: float) -> void:
	match current_state:
		State.IDLE:
			if player:
				look_at_target(player)
				if is_player_in_range() == true:
					current_state = State.COMBAT
		State.COMBAT:
			if player:
				look_at_target(player)
			velocity = global_position.direction_to(nav_agent.get_next_path_position()) * 200 * delta
			if global_position.distance_to(player.global_position) <= 2.0:
				attack_elapsed = 0
				current_state = State.ATTACK
			move_and_slide()
		State.DEATH:
			pass
		State.ATTACK:
			attack_elapsed += delta
			
			if is_attack_started == false:
				attack_collider.disabled = false
				is_attack_started = true
				attack_sound.play()
				
				var tween: Tween = create_tween()
				tween.tween_property(sprite, "scale", Vector3.ONE * 0.51, 0.2).from(Vector3.ONE * 1.5)
				
			if attack_elapsed >= 1.0:
				current_state = State.COMBAT
				is_attack_started = false
				attack_collider.disabled = true
		
func look_at_target(target: Node3D) -> void:
	if target == null:
		return
	raycast.global_position = global_position + Vector3(0, 1.5, 0)
	var look_target: Vector3 = target.global_position + Vector3(0, 1, 0)
	raycast.look_at(look_target, Vector3.UP, true)
	
	global_rotation.y = raycast.global_rotation.y
	
func is_player_in_range() -> bool:
	if raycast.is_colliding():
		if "Player" in raycast.get_collider().name:
			if global_position.distance_to(player.global_position) < 10:
				return true
	return false

func take_damage(amount: float) -> void:
	if current_state == State.DEATH:
		return
	if current_state == State.IDLE:
		current_state = State.COMBAT
	hit_particles.restart()
	hp -= amount
	if hp <=0:
		current_state = State.DEATH
		die()
		
		
func die() -> void:
	animation_player.play("death")


func _on_refresh_path_timeout() -> void:
	if player:
		nav_agent.target_position = player.global_position


func _on_attack_body_entered(body: Node3D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(5)
