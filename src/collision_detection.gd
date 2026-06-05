class_name CollisionDetection
extends Node2D

@onready var color_rect: ColorRect = $ColorRect
@onready var label: Label = $HUD/Label

var speed: float = 120.0
var rot_speed: float = 1.5

# nav
const nav = preload("res://scn/nav.tscn")

func _ready() -> void:
	var viewport_size = get_viewport_rect().size
	color_rect.position = Vector2.ZERO
	color_rect.size = viewport_size
	get_viewport().size_changed.connect(_on_viewport_resized)
	
	add_child(nav.instantiate())
	_on_ready_custom()

func _on_ready_custom() -> void:
	pass

func _on_viewport_resized() -> void:
	var viewport_size = get_viewport_rect().size
	color_rect.position = Vector2.ZERO
	color_rect.size = viewport_size

func _process(delta: float) -> void:
	_handle_input(delta)
	_update_collision_state()
	_queue_redraws()
	_update_label()
	queue_redraw()

func _handle_input(_delta: float) -> void:
	pass

func _update_collision_state() -> void:
	pass

func _queue_redraws() -> void:
	pass

func _update_label() -> void:
	pass
