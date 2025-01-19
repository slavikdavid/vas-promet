extends Sprite2D

func _process(_delta):
	# Get the parent's movement direction.
	var dir: Vector2 = get_parent().direction
	
	# Reset to default values.
	rotation = 0.0
	flip_h = false
	flip_v = false

	if dir == Vector2.UP:
		# Default: sprite facing up.
		flip_h = false
		flip_v = false
		rotation = 0.0  # no rotation
	elif dir == Vector2.DOWN:
		# Moving down: flip vertically.
		flip_h = false
		flip_v = true
		rotation = 0.0  # no rotation, only flip
	elif dir == Vector2.LEFT:
		# Moving left: flip horizontally.
		flip_h = true
		flip_v = false
		rotation = deg_to_rad(-90)
	elif dir == Vector2.RIGHT:
		# Moving right: rotate sprite 90°.
		# Depending on your art, you might need to adjust the rotation.
		# Here we assume that default (0°) is up, so 90° rotation makes it face right.
		flip_h = false
		flip_v = false
		rotation = deg_to_rad(90)
	elif dir == (Vector2.UP + Vector2.LEFT).normalized():
		# Diagonal up-left.
		flip_h = true
		flip_v = false
		rotation = 0.0  # adjust if needed
	elif dir == (Vector2.UP + Vector2.RIGHT).normalized():
		# Diagonal up-right.
		flip_h = false
		flip_v = false
		rotation = deg_to_rad(90)  # adjust if needed
	elif dir == (Vector2.DOWN + Vector2.LEFT).normalized():
		# Diagonal down-left.
		flip_h = true
		flip_v = true
		rotation = 0.0  # adjust if needed
	elif dir == (Vector2.DOWN + Vector2.RIGHT).normalized():
		# Diagonal down-right.
		flip_h = false
		flip_v = true
		rotation = deg_to_rad(90)  # adjust if needed
