extends CharacterBody3D

const IMPACT_MESH = preload("uid://dno72hdvohili")

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var last_mouse_position: Vector2i
var mouse_sens: float = 0.01
@export_range(0, 100, 1) var health: float = 50
@export var bullet_damage: float = 5

@onready var fpp_camera: Camera3D = $FPPCamera



func _ready() -> void:
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CAPTURED)
	

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.screen_relative.x * mouse_sens)
		fpp_camera.rotation.x += -event.screen_relative.y * mouse_sens
		fpp_camera.rotation.x = clampf(fpp_camera.rotation.x, -PI/2, PI/2) 
	if event.is_action_pressed("attack"):
		attack()
		#screen_shake()
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

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

	move_and_slide()
	
func attack() -> void:
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

func screen_shake() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(fpp_camera, "v_offset", 0.0, 0.1).from(0.1)
	
func take_damage(amount: float) -> void:
	print("HP: ", health)
	health -= amount
	if health <= 0:
		die()
		
func die() -> void:
	get_tree().quit()
