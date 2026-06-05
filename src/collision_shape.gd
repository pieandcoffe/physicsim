class_name CollisionShape
extends Node2D

@export var shape_color: Color = Color.WHITE

var overlap: bool = false


func get_corner_positions() -> Array:
	"""Returns corner positions transformed to global space."""
	return []


func get_axes() -> Array:
	"""Returns collision axes."""
	return []


func _draw_shape(color: Color) -> void:
	pass


func _draw() -> void:
	var color = Color.RED if overlap else Color.WHITE
	_draw_shape(color)
	
	# Draw center point
	draw_circle(Vector2.ZERO, 3.0, shape_color)
