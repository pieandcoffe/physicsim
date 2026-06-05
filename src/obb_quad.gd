class_name OBBQuad
extends CollisionShape

@export var half_extents: Vector2 = Vector2(40, 40)

var axes: Array = []
var corners: Array

func _ready() -> void:
	_update_corners()
	
func _set(property, value):
	if property == "half_extents":
		half_extents = value
		_update_corners()
		queue_redraw()
	
func _update_corners() -> void:
	corners = [
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
	return corners.map(func(c): return global_transform * c)

func get_axes() -> Array:
	var t = get_global_transform()
	axes = [t.x.normalized(), t.y.normalized()]
	return axes

func _draw_shape(color: Color) -> void:
	var local_rect = Rect2(-half_extents, half_extents * 2)
	draw_rect(local_rect, color, false, 2.0)
