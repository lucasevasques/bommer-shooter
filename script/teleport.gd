extends Node3D
@export_file_path("*.tscn") var scene_to_load: String


func _on_area_3d_body_entered(body: Node3D) -> void:
	if scene_to_load != "":
		get_tree().change_scene_to_file(scene_to_load)
