extends Node2D

@export var car_scene: PackedScene
var scene_to_instance = preload("res://Car.tscn")
@export var spawn_interval: float = 1.25
var spawn_points: Array[Marker2D] = []
var spawn_cooldowns: Dictionary = {}
var spawn_cooldown_duration: float = 5.0
const MIN_GAP: float = 250.0

func _ready():
	randomize()
	initialize_spawn_points()
	print("Total spawn points: ", spawn_points.size())
	start_spawn_timer()

func initialize_spawn_points():
	for child in get_children():
		if child is Marker2D and child.name.begins_with("Spawn_"):
			print("Found spawn point: ", child.name)
			spawn_points.append(child)
			spawn_cooldowns[child] = 0

func start_spawn_timer():
	var timer = Timer.new()
	timer.wait_time = spawn_interval
	timer.one_shot = false
	timer.connect("timeout", Callable(self, "_spawn_car"))
	add_child(timer)
	timer.start()

func _spawn_car():
	update_cooldowns()
	var available_points = spawn_points.filter(func(p): return spawn_cooldowns[p] <= 0)

	available_points.shuffle()

	for spawn_point in available_points:
		if can_spawn_car_at(spawn_point):
			spawn_cooldowns[spawn_point] = spawn_cooldown_duration
			print("Spawning at: ", spawn_point.name)
			spawn_car_at_point(spawn_point)
			return
	print("No available spawn points due to space constraints.")

func update_cooldowns():
	for point in spawn_points:
		if spawn_cooldowns[point] > 0:
			spawn_cooldowns[point] -= spawn_interval

func can_spawn_car_at(spawn_point):
	var cars_in_proximity = get_tree().get_nodes_in_group("cars")
	for car in cars_in_proximity:
		if car.global_position.distance_to(spawn_point.global_position) < MIN_GAP:
			return false
	return true

func spawn_car_at_point(spawn_point):
	var car = scene_to_instance.instantiate()
	car.global_position = spawn_point.global_position
	set_car_properties(car, spawn_point)
	get_tree().current_scene.add_child(car)

func set_car_properties(car, spawn_point):
	match spawn_point.name:
		"Spawn_Top_Right_Lane_1", "Spawn_Top_Right_Lane_2":
			car.direction = Vector2.DOWN
			car.road_type = "vertical"
		"Spawn_Bottom_Right_Lane_1", "Spawn_Bottom_Right_Lane_2":
			car.direction = Vector2.UP
			car.road_type = "vertical"
		"Spawn_West_Right_Lane_1", "Spawn_West_Right_Lane_2":
			car.direction = Vector2.RIGHT
			car.road_type = "horizontal"
		"Spawn_East_Right_Lane_1", "Spawn_East_Right_Lane_2":
			car.direction = Vector2.LEFT
			car.road_type = "horizontal"

	car.speed = 220
