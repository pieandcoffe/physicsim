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
	
func spawn() -> void:
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
	axes = []
	for i in range(corners.size()):
		var current = global_transform * corners[i]
		var next = global_transform * corners[(i + 1) % corners.size()]
		var edge = next - current
		if edge.length_squared() > 0.0001:
			axes.append(edge.orthogonal().normalized())
	return axes
	
func overlap(other: CollisionShape) -> bool:
	if other is not SATShape:
		return false
	
	var shapes_axes = self.get_axes() + other.get_axes()
	var corners_a = self.get_corner_positions()
	var corners_b = other.get_corner_positions()
	
	for axis in shapes_axes:
		var min_a = INF; var max_a = -INF
		var min_b = INF; var max_b = -INF
		
		for c in corners_a:
			var p = c.dot(axis)
			min_a = min(min_a, p); max_a = max(max_a, p)
		for c in corners_b:
			var p = c.dot(axis)
			min_b = min(min_b, p); max_b = max(max_b, p)
		
		if max_a < min_b or max_b < min_a:
			return false
	
	return true

func _draw_shape() -> void:
	var corners : Array = _get_local_corners()
	var shape_color = self.color
	var width = 5.0 if overlap else 3.0
	for i in range(corners.size()):
		var current = corners[i]
		var next = corners[(i + 1) % corners.size()]
		draw_line(current, next, shape_color, width)

func get_mtv(other: CollisionShape) -> Vector2:
	if other is not SATShape:
		return Vector2.ZERO
	if not overlap(other):
		return Vector2.ZERO

	var corners_a := self.get_corner_positions()
	var corners_b := other.get_corner_positions()
	var shapes_axes := self.get_axes() + other.get_axes()

	var min_overlap := INF
	var mtv_axis := Vector2.ZERO

	for axis in shapes_axes:
		var proj_a := project_corners(corners_a, axis)
		var proj_b := project_corners(corners_b, axis)
		var overlap_amount: float = min(proj_a.y, proj_b.y) - max(proj_a.x, proj_b.x)
		if overlap_amount < min_overlap:
			min_overlap = overlap_amount
			mtv_axis = axis

	# ensure axis points from self to other
	if (other.global_position - self.global_position).dot(mtv_axis) < 0:
		mtv_axis = -mtv_axis

	return mtv_axis * min_overlap
