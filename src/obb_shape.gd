class_name OBBShape
extends AABBShape

var axes: Array = []

const CORNER_RATIO := 0.2
		
func _init(p_position: Vector2) -> void:
	super._init(p_position)
	self.rotation = randi_range(0, 360)

func _is_point_inside(local: Vector2) -> bool:
	return abs(local.x) <= half_extents.x and abs(local.y) <= half_extents.y

func _is_near_corner(local: Vector2) -> bool:
	for corner in _get_local_corners():
		if local.distance_to(corner) < _get_corner_radius():
			return true
	return false
	
func _get_local_corners() -> Array:
	return [
		Vector2(-half_extents.x, -half_extents.y),
		Vector2(half_extents.x, -half_extents.y),
		Vector2(half_extents.x, half_extents.y),
		Vector2(-half_extents.x, half_extents.y)
	]

# A(-x,-y) ────── B(x,-y)
#     │                │
#     │                │
# D(-x, y) ────── C(x, y)
func get_corner_positions() -> Array:
	return _get_local_corners().map(func(c): return global_transform * c)

func get_min() -> Vector2:
	var pts = get_corner_positions()
	var min_x = pts[0].x
	var min_y = pts[0].y
	for p in pts:
		min_x = min(min_x, p.x)
		min_y = min(min_y, p.y)
	return Vector2(min_x, min_y)

func get_max() -> Vector2:
	var pts = get_corner_positions()
	var max_x = pts[0].x
	var max_y = pts[0].y
	for p in pts:
		max_x = max(max_x, p.x)
		max_y = max(max_y, p.y)
	return Vector2(max_x, max_y)

func get_axes() -> Array:
	var t = get_global_transform()
	axes = [t.x.normalized(), t.y.normalized()]
	return axes
	
func _get_corner_radius() -> float:
	return CORNER_RATIO * min(half_extents.x, half_extents.y)
