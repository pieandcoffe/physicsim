class_name AABBShape
extends CollisionShape

@export var half_extents: Vector2 = Vector2(40, 40):
	set(v):
		half_extents = v
		queue_redraw()

var _target_half_extents: Vector2

func _init(p_position: Vector2) -> void:
	self.position = p_position
	self.color = Color.from_hsv(randf(), 0.6, 0.9)
	
	self._target_half_extents = Vector2(randi_range(32, 64), randi_range(32, 64))
	self.half_extents = Vector2.ZERO
	
	self.mass = self._target_half_extents.x


func spawn() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "half_extents", _target_half_extents, 0.4)
	

func _is_point_inside(local: Vector2) -> bool:
	return abs(local.x) <= half_extents.x and abs(local.y) <= half_extents.y


func _set(property, value):
	if property == "half_extents":
		half_extents = value
		queue_redraw()

func get_min() -> Vector2:
	return global_position - half_extents
	

func get_max() -> Vector2:
	return global_position + half_extents
	

func get_rect() -> Rect2:
	return Rect2(get_min(), half_extents * 2)

func overlap(other: CollisionShape) -> bool:
	if other is not CollisionShape:
		return false

	if self.get_max().x < other.get_min().x: return false
	if other.get_max().x < self.get_min().x: return false
	if self.get_max().y < other.get_min().y: return false
	if other.get_max().y < self.get_min().y: return false
	
	return true

func get_mtv(other: CollisionShape) -> Vector2:
	if not overlap(other):
		return Vector2.ZERO

	var a_min = get_min()
	var a_max = get_max()
	var b_min = other.get_min()
	var b_max = other.get_max()

	# 1. Compute overlap distances on each axis
	var overlap_x = min(a_max.x - b_min.x, b_max.x - a_min.x)
	var overlap_y = min(a_max.y - b_min.y, b_max.y - a_min.y)

	# 2. Choose the axis with the smallest overlap - minimum translation vector
	if abs(overlap_x) < abs(overlap_y):
		# Push left or right
		if a_max.x > b_max.x:
			overlap_x = -overlap_x
		return Vector2(overlap_x, 0)
	else:
		# Push up or down
		if a_max.y > b_max.y:
			overlap_y = -overlap_y
		return Vector2(0, overlap_y)

func _draw_shape() -> void:
	var local_rect = Rect2(-half_extents, half_extents * 2)
	var shape_color = self.color		
	var width = 5.0 if self.overlapping else 3.0
	draw_rect(local_rect, shape_color, false, width)
