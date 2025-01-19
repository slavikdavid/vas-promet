extends Area2D

func _on_intersection_entered(body):
	print("Car entered intersection. Position: ", global_position)

func _on_intersection_exited(body):
	print("Car exited intersection. Position: ", global_position)
