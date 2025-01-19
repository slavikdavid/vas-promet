extends CharacterBody2D

@export var speed: float = 200.0
@export var direction: Vector2 = Vector2.ZERO
@export var road_type: String = "vertical"

const STOP_LINE_DOWN = 520.0
const STOP_LINE_UP = 2020.0
const STOP_LINE_RIGHT = 520.0
const STOP_LINE_LEFT = 2020.0

const MIN_GAP: float = 200.0

enum LightState { GREEN, YELLOW, RED, RED_YELLOW }
enum CarState { MOVING, STOPPED }

var current_speed: float = 0.0
var current_state: CarState = CarState.MOVING
var light_state: int = LightState.GREEN
var is_in_intersection: bool = false
var has_exited_intersection: bool = false

func _ready():
	direction = direction.normalized()
	add_to_group("cars")
	current_state = CarState.MOVING
	current_speed = speed

	var traffic_light = null
	if road_type == "vertical":
		traffic_light = get_node_or_null("/root/Main/TrafficLight")
		if traffic_light:
			traffic_light.connect("vertical_light_changed", Callable(self, "_on_light_changed"))
			light_state = traffic_light.vertical_state
	elif road_type == "horizontal":
		traffic_light = get_node_or_null("/root/Main/TrafficLight2")
		if traffic_light:
			traffic_light.connect("horizontal_light_changed", Callable(self, "_on_light_changed"))
			light_state = traffic_light.horizontal_state

	var intersection = get_node_or_null("/root/Main/IntersectionArea")
	if intersection:
		intersection.connect("body_entered", Callable(self, "_on_intersection_entered"))
		intersection.connect("body_exited", Callable(self, "_on_intersection_exited"))
		print("Connected to IntersectionArea signals")
	else:
		print("IntersectionArea not found!")

func _process(delta):
	if has_exited_intersection:
		print("Car has exited intersection, ignoring stop lines. Position: ", global_position)
		current_state = CarState.MOVING
		current_speed = speed
		global_position += direction * current_speed * delta
		return

	if is_in_intersection:
		print("Car is in intersection, continuing to move. Position: ", global_position)
		current_state = CarState.MOVING
		current_speed = speed
		global_position += direction * current_speed * delta
		return

	if light_state in [LightState.RED, LightState.YELLOW, LightState.RED_YELLOW]:
		if is_first_car_to_stop_line():
			if not is_at_stop_line():
				print("First car moving toward stop line. Position: ", global_position)
				current_state = CarState.MOVING
				current_speed = speed
				global_position += direction * current_speed * delta
			else:
				print("First car stopped at stop line. Position: ", global_position)
				current_state = CarState.STOPPED
				current_speed = 0
		else:
			if has_car_ahead(MIN_GAP):
				print("Car stopped due to car ahead. Position: ", global_position)
				current_state = CarState.STOPPED
				current_speed = 0
			elif not is_at_stop_line():
				print("Car moving forward until reaching min gap or stop line. Position: ", global_position)
				current_state = CarState.MOVING
				current_speed = speed
				global_position += direction * current_speed * delta
			else:
				print("Car stopped at stop line due to no car ahead. Position: ", global_position)
				current_state = CarState.STOPPED
				current_speed = 0
		return  # Ensure no further movement occurs after processing stop conditions

	# Green light case
	if light_state == LightState.GREEN:
		print("Car is moving. Position: ", global_position)
		current_state = CarState.MOVING
		current_speed = speed
		global_position += direction * current_speed * delta

func is_first_car_to_stop_line() -> bool:
	var nearest_car: Node2D = null
	var nearest_dist: float = INF

	for car in get_tree().get_nodes_in_group("cars"):
		if car == self:
			continue
		if car.road_type != road_type or car.direction != direction:
			continue

		var delta_vec = car.global_position - global_position
		var projection = delta_vec.dot(direction)
		if projection > 0:
			var dist = delta_vec.length()
			if dist < nearest_dist:
				nearest_car = car
				nearest_dist = dist

	if nearest_car == null:
		return true

	return is_closer_to_stop_line(global_position, nearest_car.global_position)

func is_closer_to_stop_line(car_pos: Vector2, other_car_pos: Vector2) -> bool:
	match direction:
		Vector2.DOWN:
			return car_pos.y >= other_car_pos.y
		Vector2.UP:
			return car_pos.y <= other_car_pos.y
		Vector2.RIGHT:
			return car_pos.x >= other_car_pos.x
		Vector2.LEFT:
			return car_pos.x <= other_car_pos.x
		_:
			return false

func is_at_stop_line() -> bool:
	match direction:
		Vector2.DOWN:
			return global_position.y >= STOP_LINE_DOWN
		Vector2.UP:
			return global_position.y <= STOP_LINE_UP
		Vector2.RIGHT:
			return global_position.x >= STOP_LINE_RIGHT
		Vector2.LEFT:
			return global_position.x <= STOP_LINE_LEFT
		_:
			return false

func has_car_ahead(min_gap: float) -> bool:
	var nearest_dist = INF
	for car in get_tree().get_nodes_in_group("cars"):
		if car == self:
			continue
		if car.road_type != road_type or car.direction != direction:
			continue

		var delta_vec = car.global_position - global_position
		var projection = delta_vec.dot(direction)
		if projection > 0:
			var dist = delta_vec.length()
			if dist < nearest_dist:
				nearest_dist = dist

	return nearest_dist < min_gap

func _on_light_changed(new_state):
	print("Light state updated to: ", new_state)
	light_state = new_state

	if is_in_intersection:
		print("Car is in intersection, ignoring light change. Position: ", global_position)
		
func _on_intersection_entered(body: Node) -> void:
	if body == self:
		is_in_intersection = true
		print("Entered intersection")

func _on_intersection_exited(body: Node) -> void:
	if body == self:
		is_in_intersection = false
		has_exited_intersection = true
		print("Exited intersection")
