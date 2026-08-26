extends RigidBody3D

var hp: float = 1

func _ready() -> void:
	var timer: = get_tree().create_timer(4.0)
	await timer.timeout
	queue_free()
	
	
func take_damage(damage: float)-> void:
	hp -= damage
	if hp <= 0:
		queue_free()
