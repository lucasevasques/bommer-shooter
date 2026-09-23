extends CharacterBody3D

enum State {IDLE, ALIVE, DEAD}

const IMPACT_MESH = preload("uid://dno72hdvohili")

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export_range(0, 100, 1) var health: float = 50
@export var max_health: float = 100
@export var bullet_damage: float = 5
@export var ammo: int = 20
@export var cartridges: int = 5
@export var cartridge_size: int = 20
@export var max_ammo: int = 100

var last_mouse_position: Vector2i
var mouse_sens: float = 0.01
var current_state: State = State.IDLE


@onready var fpp_camera: Camera3D = $FPPCamera
@onready var shot_sound: AudioStreamPlayer3D = $ShotSound
@onready var ammo_label: RichTextLabel = %AmmoLabel
@onready var health_label: Label = %HealthLabel
@onready var health_bar: ProgressBar = %HealthBar
@onready var heal_feedback_rect: TextureRect = %HealFeedbackRect
@onready var heal_particles: GPUParticles2D = %HealParticles



func _ready() -> void:
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CAPTURED)
	update_ammo()
	update_health_label()
	current_state = State.ALIVE
	heal_feedback_rect.hide()
	heal_particles.hide()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.screen_relative.x * mouse_sens)
		fpp_camera.rotation.x += -event.screen_relative.y * mouse_sens
		fpp_camera.rotation.x = clampf(fpp_camera.rotation.x, -PI/2, PI/2) 
	if event.is_action_pressed("attack"):
		attack()
		#screen_shake()
	if event.is_action_pressed("reload"):
		reload()
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	match current_state:
		State.IDLE:
			pass
		State.ALIVE:
			# Handle jump.
			if Input.is_action_just_pressed("jump") and is_on_floor():
				velocity.y = JUMP_VELOCITY


			# Get the input direction and handle the movement/deceleration.
			# As good practice, you should replace UI actions with custom gameplay actions.
			var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
			var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
			if direction:
				velocity.x = direction.x * SPEED
				velocity.z = direction.z * SPEED
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
				velocity.z = move_toward(velocity.z, 0, SPEED)
			
		State.DEAD:
			pass
	


	move_and_slide()
	
func attack() -> void:
	if ammo <=0:
		return #TODO: Botar função e som de recarga de arma vazia
	
	ammo -= 1
	
	var space_state := get_world_3d().direct_space_state
	var cam:= get_viewport().get_camera_3d()
	var mouse_position := get_viewport().get_mouse_position()
	var ray_origin: Vector3 = cam.project_ray_origin(mouse_position)
	var ray_direction: Vector3 = ray_origin + cam.project_ray_normal(mouse_position) *100
	
	var query := PhysicsRayQueryParameters3D.create(ray_origin, ray_direction, collision_mask)
	query.collide_with_areas = true
	var result:= space_state.intersect_ray(query)
	#print(result)
	
	if not result.is_empty():
		var impact_mesh := IMPACT_MESH.instantiate()
		add_sibling(impact_mesh)
		impact_mesh.global_position = result["position"]
		
		if result["collider"] is RigidBody3D:
			var obj: RigidBody3D = result["collider"]
			obj.apply_force(-result["normal"] * 1000, result["position"])
			
		var collider: Node3D = result["collider"]
		if collider.has_method("take_damage"):
			collider.take_damage(bullet_damage)
		else:
			if collider.owner.has_method("take_damage"):
				collider.owner.take_damage(bullet_damage)
	shot_sound.play()
	update_ammo()

func screen_shake() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(fpp_camera, "v_offset", 0.0, 0.1).from(0.1)
	
func take_damage(amount: float) -> void:
	#print("HP: ", health)
	health -= amount
	update_health_label()
	if health <= 0:
		die()
		
func update_health_label() -> void:
	health_label.text = "HP: "+str(health)
	health_bar.max_value = max_health
	health_bar.value = health
	
	
func die() -> void:
	#TODO: Criar estado de morte do player
	EventBus.player_died.emit()
	current_state = State.DEAD
	set_process_unhandled_input(false)
	
func update_ammo() -> void:
	print(ammo, " / ", cartridges * cartridge_size)
	ammo_label.text = str(ammo) + " / " + str(cartridges * cartridge_size)
	if cartridges <= 0:
		ammo_label.text += "[shake][color=red][b] Encontre munição[/b][/color][/shake]" 

	elif ammo == 0:
		ammo_label.text += "[shake] Aperte R para recarregar [/shake]"
		
func reload () -> void:
	if cartridges <= 0 or ammo>= cartridge_size:
		return
	
	cartridges -= 1 
	ammo = cartridge_size
	update_ammo()
	


func get_message(message: Message) -> void:
	if "ammo" in message.content:
		cartridges += message.content["ammo"]
		update_ammo()
	if "health" in message.content:
		health+= message.content["health"]
		update_health_label()
		healed_feedback()
		
func healed_feedback() -> void:
	var tween: Tween = create_tween()
	#tween.set_parallel(true)
	
	heal_feedback_rect.show()
	heal_particles.show()
	
	tween.tween_property(heal_feedback_rect, "modulate:a", 1.0, 1.0).from(0.0)
	tween.tween_property(heal_feedback_rect,"modulate:a", 0.0, 1.0)
	tween.tween_callback(heal_feedback_rect.hide)
