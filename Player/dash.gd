extends Node3D

@export var player: Player
@export var speed_multiplier := 3.0

@onready var timer: Timer = $Timer
@onready var dash_particles: GPUParticles3D = $GPUParticles3D


var direction: Vector3 = Vector3.ZERO
var dash_duration := 0.1
var time_remaining := 0.0
var dash_cooldown := 0.5

func _unhandled_input(event: InputEvent) -> void:
	if not timer.is_stopped():
		return
	if not player.is_physics_processing():
		return

	if event.is_action_pressed("dash"):
		direction = player.get_movement_direction()
		
		if not direction.is_zero_approx():
			player.rig.travel("Dash")
			dash_particles.emitting = true			
			timer.start(dash_cooldown)
			time_remaining = dash_duration

func _physics_process(delta: float) -> void:
	if direction.is_zero_approx():
		return
	player.velocity = direction * player.SPEED * speed_multiplier
	time_remaining -= delta
	if time_remaining <= 0:
		direction = Vector3.ZERO
		dash_particles.emitting = false
		
