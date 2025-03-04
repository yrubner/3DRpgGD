extends Node3D

@export var player: Player

@onready var timer: Timer = $Timer

var direction: Vector3 = Vector3.ZERO

func _unhandled_input(event: InputEvent) -> void:
	if not timer.is_stopped():
		return

	if event.is_action_pressed("dash"):
		direction = player.get_movement_direction()
		
		if not direction.is_zero_approx():
			print("Dash!")
			timer.start(1.0)
