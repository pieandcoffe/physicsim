class_name OBBDetection
extends AABBDetection

func _on_ready_custom() -> void:
	var a = OBBShape.new(Vector2(300, 250))
	a.spawn()
	add_child(a)

	var b = OBBShape.new(Vector2(450, 250))
	b.spawn()
	add_child(b)

	collision_shapes.append(a)
	collision_shapes.append(b)

func _spawn_collision_shape(p_position: Vector2) -> CollisionShape:
	var s = OBBShape.new(p_position)
	s.spawn()
	return s

func _update_label() -> void:
	label.text = "1 AABB   [2 OBB]   3 SAT\n Resolve Collision [%s]" % resolve_collisions_enabled

func _draw() -> void:
	pass
