extends Sprite2D

func _process(_delta):
	var dir: Vector2 = get_parent().direction
	
	rotation = 0.0
	flip_h = false
	flip_v = false

	if dir == Vector2.UP:
		flip_h = false
		flip_v = false
		rotation = 0.0 
	elif dir == Vector2.DOWN:
		flip_h = false
		flip_v = true
		rotation = 0.0
	elif dir == Vector2.LEFT:
		flip_h = true
		flip_v = false
		rotation = deg_to_rad(-90)
	elif dir == Vector2.RIGHT:
		flip_h = false
		flip_v = false
		rotation = deg_to_rad(90)
	elif dir == (Vector2.UP + Vector2.LEFT).normalized():
		flip_h = true
		flip_v = false
		rotation = 0.0 
	elif dir == (Vector2.UP + Vector2.RIGHT).normalized():
		flip_h = false
		flip_v = false
		rotation = deg_to_rad(90)
	elif dir == (Vector2.DOWN + Vector2.LEFT).normalized():
		flip_h = true
		flip_v = true
		rotation = 0.0
	elif dir == (Vector2.DOWN + Vector2.RIGHT).normalized():
		flip_h = false
		flip_v = true
		rotation = deg_to_rad(90)
