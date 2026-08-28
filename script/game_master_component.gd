class_name GameMasterComponent
extends Node

@export var player: Node3D


func _on_player_requested(source: Node) -> void:
	if player != null:
		source.player = player
