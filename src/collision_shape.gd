class_name CollisionShape
extends Node2D

@export var color: Color = Color.WHITE

@export var restitution: float = 0.5

var velocity: Vector2 = Vector2.ZERO
var mass: float = 0

var overlap: bool = false
var overlap_shapes: Array[CollisionShape] = []

var _dragging := false
var _rotating := false
var _drag_offset := Vector2.ZERO
var _rotate_start_angle := 0.0

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var local = to_local(event.position)
			if _is_near_corner(local):
				_rotating = true
				_rotate_start_angle = (get_parent().to_local(event.position) - position).angle() - rotation
				get_viewport().set_input_as_handled()
			elif _is_point_inside(local):
				_dragging = true
				_drag_offset = position - get_parent().to_local(event.position)
				get_viewport().set_input_as_handled()
		else:
			_dragging = false
			_rotating = false
	if event is InputEventMouseMotion:
		if _dragging:
			position = get_parent().to_local(event.position) + _drag_offset
		elif _rotating:
			rotation = (get_parent().to_local(event.position) - position).angle() - _rotate_start_angle

func _is_near_corner(_local: Vector2) -> bool:
	return false

func _is_point_inside(_local: Vector2) -> bool:
	return false
	
func resolve_collision(other: CollisionShape, mtv: Vector2) -> void:
	pass

func get_inv_mass() -> float:
	return 0.0 if mass <= 0.0 else 1.0 / mass

func get_corner_positions() -> Array:
	"""Returns corner positions transformed to global space."""
	return []


func get_axes() -> Array:
	"""Returns collision axes."""
	return []


func _draw_shape() -> void:
	pass


func _draw() -> void:
	draw_circle(Vector2.ZERO, 4.0, color)
	
	for shape in overlap_shapes:
		draw_line(Vector2.ZERO, to_local(shape.global_position), Color.RED, 3.0)
	
	_draw_shape()
