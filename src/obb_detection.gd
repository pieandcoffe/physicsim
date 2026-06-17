class_name OBBDetection
extends AABBDetection

func _on_ready_custom() -> void:
	var a = OBBShape.new(Vector2(300, 250))
	a.init()
	add_child(a)

	var b = OBBShape.new(Vector2(450, 250))
	b.init()
	add_child(b)

	collision_shapes.append(a)
	collision_shapes.append(b)

func project_corners(corners: Array, axis: Vector2) -> Vector2:
	var min_p := INF
	var max_p := -INF
	
	for c in corners:
		var p : float = c.dot(axis)
		min_p = min(min_p, p)
		max_p = max(max_p, p)
		
	return Vector2(min_p, max_p)
	
func obb_overlap(a: OBBShape, b: OBBShape) -> bool:
	var corners_a := a.get_corner_positions()
	var corners_b := b.get_corner_positions()
	var axes_a := a.get_axes()
	var axes_b := b.get_axes()
	
	for axis in [axes_a[0], axes_b[0], axes_a[1], axes_b[1]]:
		var proj_a := project_corners(corners_a, axis)
		var proj_b := project_corners(corners_b, axis)
		if proj_a.y < proj_b.x or proj_b.y < proj_a.x:
			return false
			
	return true

func _spawn_collision_shape(p_position: Vector2) -> CollisionShape:
	var s = OBBShape.new(p_position)
	s.init()
	print(s.to_string())
	return s

func _shapes_collide(a: CollisionShape, b: CollisionShape) -> bool:
	if a is OBBShape and b is OBBShape:
		return obb_overlap(a, b)
	return false

func _update_label() -> void:
	label.text = "1 AABB   [2 OBB]   3 SAT"

func _draw() -> void:
	pass
