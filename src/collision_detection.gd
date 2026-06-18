class_name CollisionDetection
extends Node2D

@onready var color_rect: ColorRect = $ColorRect
@onready var label: Label = $HUD/Label

var speed: float = 120.0
var rot_speed: float = 1.5
var collision_shapes: Array[CollisionShape] = []

var resolve_collisions_enabled : bool = true

# nav
const nav = preload("res://scn/nav.tscn")

func _ready() -> void:
	var viewport_size = get_viewport_rect().size
	color_rect.position = Vector2.ZERO
	color_rect.size = viewport_size
	get_viewport().size_changed.connect(_on_viewport_resized)

	_on_ready_custom()
	_collect_collision_shapes()
	add_child(nav.instantiate())
	set_process_input(true)

func _on_ready_custom() -> void:
	pass

func _on_viewport_resized() -> void:
	color_rect.position = Vector2.ZERO
	color_rect.size = get_viewport_rect().size

func _process(delta: float) -> void:
	_handle_input(delta)
	_update_collision_state()
	_queue_redraws()
	_update_label()
	queue_redraw()
	
func _handle_input(_delta: float) -> void:
	if Input.is_key_pressed(KEY_SPACE):
		resolve_collisions_enabled = not resolve_collisions_enabled

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		var any_dragging = collision_shapes.any(func(s): return s._dragging)
		if any_dragging:
			return
		var shape = _spawn_collision_shape(to_local(event.position))
		if shape:
			add_child(shape)
			collision_shapes.append(shape)

func _collect_collision_shapes(node: Node = null) -> void:
	if node == null:
		node = self
		collision_shapes.clear()
	for child in node.get_children():
		if child is CollisionShape:
			collision_shapes.append(child)
		_collect_collision_shapes(child)

func _spawn_collision_shape(_position: Vector2) -> CollisionShape:
	return null

func _update_collision_state() -> void:
	for shape in collision_shapes:
		shape.overlapping = false
		shape.overlap_shapes.clear()

	for i in range(collision_shapes.size()):
		for j in range(i + 1, collision_shapes.size()):
			var a = collision_shapes[i]
			var b = collision_shapes[j]
			if a.overlap(b):
				a.overlapping = true
				b.overlapping = true
				a.overlap_shapes.append(b)
				b.overlap_shapes.append(a)
				
				if resolve_collisions_enabled:
					a.resolve_collision(b)

func _queue_redraws() -> void:
	for shape in collision_shapes:
		shape.queue_redraw()

func _update_label() -> void:
	pass
