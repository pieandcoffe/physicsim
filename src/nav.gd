extends CanvasLayer

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F1: _go("res://scn/aabb.tscn")
			KEY_F2: _go("res://scn/obb.tscn")
			KEY_F3: _go("res://scn/sat.tscn")

func _go(path: String) -> void:
	get_tree().change_scene_to_file(path)
