extends Node2D

@export var n_terms: int = 5 : set = set_n_terms
@export var center: float = 0.0 : set = set_center
@export var x_range: float = 6.0 : set = set_x_range
@export var scale_px: float = 80.0 : set = set_scale_px

@onready var exact_curve: Line2D = $ExactCurve
@onready var taylor_curve: Line2D = $TaylorCurve
@onready var formaula_display: Label = $FormaulaDisplay

func _ready():
	exact_curve.default_color = Color.CORNFLOWER_BLUE
	taylor_curve.default_color = Color.ORANGE_RED
	plot()

func _input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			scale_px *= 1.1
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			scale_px *= 0.9
		elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			n_terms = clamp(n_terms - 1, 0, 100)
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			n_terms = clamp(n_terms + 1, 0, 100)
		
		scale_px = clamp(scale_px, 10.0, 800.0)

	
func set_n_terms(val: int):
	n_terms = val
	if is_inside_tree(): plot()

func set_center(val: float):
	center = val
	if is_inside_tree(): plot()

func set_x_range(val: float):
	x_range = val
	if is_inside_tree(): plot()

func set_scale_px(val: float):
	scale_px = val
	if is_inside_tree(): plot()

# pass in the derivative array at point a
# derivs[k] = f^(k)(a)
func taylor(x: float, a: float, derivs: Array) -> float:
	var result := 0.0
	var power  := 1.0	# (x - a)^k
	var fact   := 1.0	# k!
	
	for k in range(derivs.size()):
		if k > 0:
			power *= (x - a)
			fact  *= k
		result += derivs[k] * power / fact
	
	return result

# sin(x) derivatives cycle [sin, cos, -sin, -cos]	
func sin_derivs_at(a: float, n: int) -> Array:
	var cycle = [sin(a), cos(a), -sin(a), -cos(a)]
	var derivs = []
	for k in range(n):
		derivs.append(cycle[k % 4])
	return derivs

func plot():
	exact_curve.clear_points()
	taylor_curve.clear_points()
	
	var derivs = sin_derivs_at(center, n_terms)
	var steps = 200
	
	var screen_center = get_viewport_rect().size / 2.0
	
	for i in range(steps + 1):
		var t = float(i) / steps
		var x = lerp(-x_range, x_range, t)
		var px = x * scale_px + screen_center.x
		
		var ey = -sin(x) * scale_px + screen_center.y
		exact_curve.add_point(Vector2(px, ey))
		
		var ty_val = taylor(x, center, derivs)
		ty_val = clamp(ty_val, -10.0, 10.0)
		var ty = -ty_val * scale_px + screen_center.y
		taylor_curve.add_point(Vector2(px, ty))
		
