extends Node3D
@onready var particles: GPUParticles3D = $GPUParticles3D
@onready var light: OmniLight3D = $Light


func _ready() -> void:
	particles.emitting = true
	var tween: Tween = create_tween()
	tween.tween_property(light, "light_energy", 0.0, 0.1).from_current()
	await  particles.finished
	queue_free()
