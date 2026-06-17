class_name SATDetection
extends OBBDetection


func _on_ready_custom() -> void:
	var a = SATShape.new(Vector2(300, 250))
	a.init()
	add_child(a)

	var b = SATShape.new(Vector2(450, 250))
	b.init()
	add_child(b)

	collision_shapes.append(a)
	collision_shapes.append(b)

func sat_overlap(a: SATShape, b: SATShape) -> bool:
	var axes = a.get_axes() + b.get_axes()
	var corners_a = a.get_corner_positions()
	var corners_b = b.get_corner_positions()
	
	for axis in axes:
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

func _spawn_collision_shape(p_position: Vector2) -> CollisionShape:
	var s = SATShape.new(p_position)
	s.init()
	return s

func _shapes_collide(a: CollisionShape, b: CollisionShape) -> bool:
	if a is SATShape and b is SATShape:
		return sat_overlap(a, b)
	return false

func _update_label() -> void:
	label.text = "1 AABB   2 OBB   [3 SAT]"
