extends SpringArm3D

@export var target : Node3D
@export var decay : float = 20.0

func _physics_process(delta: float) -> void:
	global_transform = global_transform.interpolate_with(
		target.global_transform, 
		1.0 - exp(-decay * delta)
		)
