class_name AABBScene
extends CollisionDetection

@onready var quad_a: AABBQuad = $QuadA
@onready var quad_b: AABBQuad = $QuadB

# draw settings
const AXIS_LENGTH: float = 600.0
const AXIS_OFFSET_X: float = 32.0
const AXIS_OFFSET_Y: float = 32.0
const PROJ_THICKNESS: float = 6.0
const TICK_SIZE: float = 5.0

func aabb_overlap(a: AABBQuad, b: AABBQuad) -> bool:
	if a.get_max().x < b.get_min().x: return false
	if b.get_max().x < a.get_min().x: return false
	if a.get_max().y < b.get_min().y: return false
	if b.get_max().y < a.get_min().y: return false
	return true

func _handle_input(delta: float) -> void:
	# Quad A
	if Input.is_key_pressed(KEY_LEFT): quad_a.position.x -= speed * delta
	if Input.is_key_pressed(KEY_RIGHT): quad_a.position.x += speed * delta
	if Input.is_key_pressed(KEY_UP): quad_a.position.y -= speed * delta
	if Input.is_key_pressed(KEY_DOWN): quad_a.position.y += speed * delta
	
	# Quad B
	if Input.is_key_pressed(KEY_A): quad_b.position.x -= speed * delta
	if Input.is_key_pressed(KEY_D): quad_b.position.x += speed * delta
	if Input.is_key_pressed(KEY_W): quad_b.position.y -= speed * delta
	if Input.is_key_pressed(KEY_S): quad_b.position.y += speed * delta

func _spawn_collision_shape(position: Vector2) -> CollisionShape:
	var new_quad = AABBQuad.new()
	new_quad.position = position
	new_quad.half_extents = Vector2(32, 32)
	new_quad.shape_color = Color8(110, 190, 240)
	return new_quad

func _shapes_collide(a: CollisionShape, b: CollisionShape) -> bool:
	if a is AABBQuad and b is AABBQuad:
		return aabb_overlap(a, b)
	return false

func _update_label() -> void:
	label.text = "[F1 AABB]   F2 OBB   F3 SAT\n   BoxA : move ARROWS\n   BoxB : move WASD\n   Left click: spawn AABB\nColliding: %s" % quad_a.overlap

func _draw() -> void:
	var col_a = quad_a.shape_color
	var col_b = quad_b.shape_color
	var axis_col = Color.WHITE_SMOKE
	var overlap_col = Color.RED
	
	var x_axis_y = get_viewport_rect().size.y - AXIS_OFFSET_X
	draw_line(Vector2(0, x_axis_y), Vector2(get_viewport_rect().size.x, x_axis_y), axis_col, 1.5)
	draw_string(ThemeDB.fallback_font, Vector2(8, x_axis_y - 6), "X", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, axis_col)
	
	# X projections
	var ax_min = quad_a.get_min().x
	var ax_max = quad_a.get_max().x
	var bx_min = quad_b.get_min().x
	var bx_max = quad_b.get_max().x
	
	draw_line(Vector2(ax_min, x_axis_y - PROJ_THICKNESS), Vector2(ax_max, x_axis_y - PROJ_THICKNESS), col_a, PROJ_THICKNESS)
	_draw_ticks(Vector2(ax_min, x_axis_y - PROJ_THICKNESS), Vector2(ax_max, x_axis_y - PROJ_THICKNESS), col_a, TICK_SIZE)

	draw_line(Vector2(bx_min, x_axis_y + PROJ_THICKNESS), Vector2(bx_max, x_axis_y + PROJ_THICKNESS), col_b, PROJ_THICKNESS)
	_draw_ticks(Vector2(bx_min, x_axis_y + PROJ_THICKNESS), Vector2(bx_max, x_axis_y + PROJ_THICKNESS), col_b, TICK_SIZE)
	
	# X overlap highlight
	var ox_min = max(ax_min, bx_min)
	var ox_max = min(ax_max, bx_max)
	if ox_min < ox_max:
		draw_line(Vector2(ox_min, x_axis_y), Vector2(ox_max, x_axis_y), overlap_col, PROJ_THICKNESS * 0.75)

	# Y AXIS
	var vp = get_viewport_rect().size
	var y_axis_x = vp.x - AXIS_OFFSET_Y
	draw_line(Vector2(y_axis_x, 0), Vector2(y_axis_x, get_viewport_rect().size.y), axis_col, 1.5)
	draw_string(ThemeDB.fallback_font, Vector2(y_axis_x + 4, 16), "Y", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, axis_col)

	# Y projections
	var ay_min = quad_a.get_min().y
	var ay_max = quad_a.get_max().y
	var by_min = quad_b.get_min().y
	var by_max = quad_b.get_max().y

	draw_line(Vector2(y_axis_x - PROJ_THICKNESS, ay_min), Vector2(y_axis_x - PROJ_THICKNESS, ay_max), col_a, PROJ_THICKNESS)
	_draw_ticks_y(ay_min, ay_max, y_axis_x, col_a)

	draw_line(Vector2(y_axis_x + PROJ_THICKNESS, by_min), Vector2(y_axis_x + PROJ_THICKNESS, by_max), col_b, PROJ_THICKNESS)
	_draw_ticks_y(by_min, by_max, y_axis_x, col_b)

	# Y overlap highlight
	var oy_min = max(ay_min, by_min)
	var oy_max = min(ay_max, by_max)
	if oy_min < oy_max:
		draw_line(Vector2(y_axis_x, oy_min), Vector2(y_axis_x, oy_max), overlap_col, PROJ_THICKNESS * 0.75)


func _draw_ticks(start_pos: Vector2, end_pos: Vector2, color: Color, tick_size: float):
	draw_line(start_pos + Vector2(0, -tick_size), start_pos + Vector2(0, tick_size), color, 1.5)
	draw_line(end_pos + Vector2(0, -tick_size), end_pos + Vector2(0, tick_size), color, 1.5)

 

func _draw_ticks_y(from_y: float, to_y: float, x: float, color: Color):
	draw_line(Vector2(x - TICK_SIZE, from_y), Vector2(x + TICK_SIZE, from_y), color, 1.5)
	draw_line(Vector2(x - TICK_SIZE, to_y),   Vector2(x + TICK_SIZE, to_y),   color, 1.5)
