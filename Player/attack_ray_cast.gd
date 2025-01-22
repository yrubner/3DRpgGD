extends RayCast3D

func deal_damage() -> void:
	if not is_colliding():
		return
	var collider = get_collider()
	print(collider)
	add_exception(collider)
