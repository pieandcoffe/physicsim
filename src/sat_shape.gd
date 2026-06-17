class_name SATShape
extends OBBShape

const MIN_SIDES: int = 3

@export var sides: int = MIN_SIDES
@export var extents: float = 40

var _target_extents: float

func _init(p_position: Vector2) -> void:
	super._init(p_position)
	self.sides = randi_range(SATShape.MIN_SIDES, 7)
	self._target_extents = randi_range(32, 96)
	self.extents = 0.0
	
func _play_spawn_tween() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "extents", _target_extents, 0.4)
	
func _is_point_inside(local: Vector2) -> bool:
	var corners := _get_local_corners()
	var inside := false
	var n := corners.size()
	for i in range(n):
		var p1: Vector2 = corners[i]
		var p2: Vector2 = corners[(i + 1) % n]
		if (p1.y > local.y) != (p2.y > local.y):
			var x_intersect = p1.x + (local.y - p1.y) / (p2.y - p1.y) * (p2.x - p1.x)
			if local.x < x_intersect:
				inside = not inside
	return inside

func _get_corner_radius() -> float:
	return CORNER_RATIO * extents

func _get_local_corners() -> Array:
	var corners : Array = []
	var angle_step = TAU / sides
	
	for i in range(sides):
		var angle = i * angle_step - PI / 2
		var x = extents * cos(angle)
		var y = extents * sin(angle)
		corners.append(Vector2(x, y))
	
	return corners
	
func get_corner_positions() -> Array:
	return _get_local_corners().map(func(c): return global_transform * c)
	
func get_axes() -> Array:
	var corners : Array = _get_local_corners()
	
	for i in range(corners.size()):
		var current = global_transform * corners[i]
		var next = global_transform * corners[(i + 1) % corners.size()]
		var edge = next - current
		axes.append(edge.orthogonal().normalized())
		
	return axes

func _draw_shape() -> void:
	var corners : Array = _get_local_corners()
	var shape_color = self.color
	var width = 5.0 if overlap else 3.0
	for i in range(corners.size()):
		var current = corners[i]
		var next = corners[(i + 1) % corners.size()]
		draw_line(current, next, shape_color, width)
