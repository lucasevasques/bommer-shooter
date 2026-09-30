class_name InteractableComponent
extends Node

@export var interactable_area: Area3D
@export var receiver: Node
@export var callback: String
@export var args: Variant
@export var label: Label3D

func _ready() -> void:
	EventBus.interacted.connect(_on_interected)
	EventBus.interactable_entered.connect(_on_interectable_entered)
	EventBus.intereactable_exited.connect(_on_interectable_exited)
	
	
func _on_interected(_source: Node, target: Node) -> void:
	if interactable_area == target:
		receiver.call(callback, args)


func _on_interectable_entered(source: Node, target: Node) -> void:
	if interactable_area == target:
		label.show()

func _on_interectable_exited(source: Node, target: Node) -> void:
	label.hide()
