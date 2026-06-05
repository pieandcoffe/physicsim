class_name SATPolygon
extends CollisionShape

@export var sides: int = 3
@export var extents: float = 40

var corners: Array


func _ready() -> void:
	_generate_corners()


func _generate_corners() -> void:
	corners.clear()
	var angle_step = TAU / sides
	
	for i in range(sides):
		var angle = i * angle_step - PI / 2  # Start from top (-90 degrees)
		var x = extents * cos(angle)
		var y = extents * sin(angle)
		corners.append(Vector2(x, y))
		
func get_corner_positions() -> Array:
	return corners.map(func(c): return global_transform * c)
	
func get_axes() -> Array:
	var axes = []
	
	for i in range(corners.size()):
		var current = global_transform * corners[i]
		var next = global_transform * corners[(i + 1) % corners.size()]
		var edge = next - current
		axes.append(edge.orthogonal().normalized())
		
	return axes

func _draw_shape(color: Color) -> void:
	for i in range(corners.size()):
		var current = corners[i]
		var next = corners[(i + 1) % corners.size()]
		draw_line(current, next, color)
