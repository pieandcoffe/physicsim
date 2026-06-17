class_name AABBShape
extends CollisionShape

@export var half_extents: Vector2 = Vector2(40, 40):
	set(v):
		half_extents = v
		queue_redraw()

var _target_half_extents: Vector2

func init() -> void:
	self._play_spawn_tween()

func _init(p_position: Vector2) -> void:
	self.position = p_position
	self.color = Color.from_hsv(randf(), 0.6, 0.9)
	
	self._target_half_extents = Vector2(randi_range(32, 64), randi_range(32, 64))
	self.half_extents = Vector2.ZERO
	
	self.mass = self._target_half_extents.x


func _play_spawn_tween() -> void:
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
	
func get_mtv(other: AABBShape) -> Vector2:
	return Vector2()

func _draw_shape() -> void:
	var local_rect = Rect2(-half_extents, half_extents * 2)
	var shape_color = self.color		
	var width = 5.0 if overlap else 3.0
	draw_rect(local_rect, shape_color, false, width)
