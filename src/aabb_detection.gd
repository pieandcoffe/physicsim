class_name AABBDetection
extends CollisionDetection


func _on_ready_custom() -> void:
	var a = AABBShape.new(Vector2(300, 250))
	a.spawn()
	add_child(a)

	var b = AABBShape.new(Vector2(450, 250))
	b.spawn()
	add_child(b)

	collision_shapes.append(a)
	collision_shapes.append(b)

func _spawn_collision_shape(p_position: Vector2) -> CollisionShape:
	var s = AABBShape.new(p_position)
	s.spawn()
	return s

func _update_label() -> void:
	label.text = "[1 AABB]   2 OBB   3 SAT\n Resolve Collision [%s]" % resolve_collisions_enabled

func _draw() -> void:
	var axis_col = Color.WHITE_SMOKE
	var vp_size = get_viewport_rect().size

	draw_line(Vector2(0, vp_size.y), Vector2(vp_size.x, vp_size.y), axis_col, 15)
	draw_line(Vector2(vp_size.x, 0), Vector2(vp_size.x, vp_size.y), axis_col, 15)

	_draw_overlaps(vp_size)

func _draw_overlaps(vp_size: Vector2) -> void:
	var x_overlap_count := 0
	var y_overlap_count := 0
	const BASE := 15.0
	
	for i in range(collision_shapes.size()):
		for j in range(i + 1, collision_shapes.size()):
			var a = collision_shapes.get(i)
			var b = collision_shapes.get(j)
			# x
			draw_line(Vector2(a.get_min().x, vp_size.y), Vector2(a.get_max().x, vp_size.y), a.color, BASE)
			draw_line(Vector2(b.get_min().x, vp_size.y), Vector2(b.get_max().x, vp_size.y), b.color, BASE)
			# overlap
			var ox_min = max(a.get_min().x, b.get_min().x)
			var ox_max = min(a.get_max().x, b.get_max().x)
			if ox_min < ox_max:
				x_overlap_count += 1
				var thickness = BASE * (x_overlap_count + 1)
				var blend = a.color.lerp(b.color, 0.5)
				draw_line(Vector2(ox_min, vp_size.y), Vector2(ox_max, vp_size.y), blend, thickness)
			# y
			draw_line(Vector2(vp_size.x, a.get_min().y), Vector2(vp_size.x, a.get_max().y), a.color, BASE)
			draw_line(Vector2(vp_size.x, b.get_min().y), Vector2(vp_size.x, b.get_max().y), b.color, BASE)
			# overlap
			var oy_min = max(a.get_min().y, b.get_min().y)
			var oy_max = min(a.get_max().y, b.get_max().y)
			if oy_min < oy_max:
				y_overlap_count += 1
				var thickness = BASE * (y_overlap_count + 1)
				var blend = a.color.lerp(b.color, 0.5)
				draw_line(Vector2(vp_size.x, oy_min), Vector2(vp_size.x, oy_max), blend, thickness)
