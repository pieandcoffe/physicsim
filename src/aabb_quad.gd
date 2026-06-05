class_name AABBQuad
extends CollisionShape

@export var half_extents: Vector2 = Vector2(40, 40)

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
	

func _draw_shape(color: Color) -> void:
	var local_rect = Rect2(-half_extents, half_extents * 2)
	draw_rect(local_rect, color, false, 2.0)
	
