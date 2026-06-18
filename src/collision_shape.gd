class_name CollisionShape
extends Node2D

@export var color: Color = Color.WHITE

@export var restitution: float = 0.5

var velocity: Vector2 = Vector2.ZERO
var mass: float = 0

var overlapping : bool = false
var overlap_shapes : Array[CollisionShape] = []

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
	
func overlap(_other: CollisionShape) -> bool:
	return false

func get_mtv(_other: CollisionShape) -> Vector2:
	return Vector2()

func resolve_collision(other: CollisionShape) -> void:
	# 1. Separate shapes using MTV
	# MTV points from THIS shape toward OTHER shape.
	var inv_mass_a := get_inv_mass()
	var inv_mass_b := other.get_inv_mass()
	var inv_mass_sum := inv_mass_a + inv_mass_b

	var mtv =  self.get_mtv(other)

	if inv_mass_sum == 0:
		return  # both static

	# Move each shape out of penetration
	position -= mtv * (inv_mass_a / inv_mass_sum)
	other.position += mtv * (inv_mass_b / inv_mass_sum)

	# 2. Compute collision normal
	var normal := mtv.normalized()

	# 3. Relative velocity
	var relative_vel := velocity - other.velocity

	# 4. Relative velocity along the normal
	var vel_along_normal := relative_vel.dot(normal)

	if vel_along_normal > 0:
		return

	# 5. Compute restitution
	var e = min(restitution, other.restitution)

	# 6. Compute impulse scalar
	var j = -(1.0 + e) * vel_along_normal
	j /= inv_mass_sum

	# 7. Apply impulse
	var impulse = normal * j

	velocity += impulse * inv_mass_a
	other.velocity -= impulse * inv_mass_b


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
