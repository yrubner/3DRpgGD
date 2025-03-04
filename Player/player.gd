extends CharacterBody3D
class_name Player

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Stores the x/y direction the player is trying to look in
var _look := Vector2.ZERO
# Stores the direction the player is facing when attacking
var _attack_direction := Vector3.ZERO

@export var mouse_sensitivity : float = 0.00075
@export var min_boundary : float = -60
@export var max_boundary : float = 10
@export var animation_decay : float = 20.0
@export var attack_move_speed : float = 3.0

@onready var horizontal_pivot: Node3D = $HorizontalPivot
@onready var vertical_pivot: Node3D = $HorizontalPivot/VerticalPivot
@onready var rig_pivot: Node3D = $RigPivot
@onready var rig: Node3D = $RigPivot/Rig
@onready var attack_ray_cast: RayCast3D = %AttackRayCast
@onready var health_component: HealthComponent = $HealthComponent
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var area_attack: ShapeCast3D = $RigPivot/AreaAttack


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	health_component.update_max_health(30.0)

func _physics_process(delta: float) -> void:
	frame_camera_rotation()

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	var direction := get_movement_direction()
	rig.update_animation_tree(direction)
	
	# Handle Action States
	handle_idle_physics_frame(direction, delta)
	handle_slashing_physics_frame(delta)
	handle_overhead_physics_frame()
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			_look = -event.relative * mouse_sensitivity
	if rig.is_idle():
		if event.is_action_pressed("click"):
			slash_attack()
		if event.is_action_pressed("right_click"):
			rig.travel("Overhead")

func get_movement_direction() -> Vector3:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var input_vector := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()	
	var direction := horizontal_pivot.global_transform.basis * input_vector
	return direction
	

func frame_camera_rotation() -> void:
	horizontal_pivot.rotate_y(_look.x)
	vertical_pivot.rotate_x(_look.y)
	
	vertical_pivot.rotation.x = clampf(
		vertical_pivot.rotation.x, 
		deg_to_rad(min_boundary), 
		deg_to_rad(max_boundary)
		)
	
	_look = Vector2.ZERO
	
func look_toward_direction(direction: Vector3, delta: float) -> void:
	var target_transform = rig_pivot.global_transform.looking_at(
		rig_pivot.global_position + direction, Vector3.UP, true
		)
	rig_pivot.global_transform = rig_pivot.global_transform.interpolate_with(
		target_transform,
		1 - exp(-animation_decay * delta)
	)

func slash_attack() -> void:
	rig.travel("Slash")
	_attack_direction = get_movement_direction()
	# If player is not giving a direction through Input, set the attack direction to the current positions forward vector
	if _attack_direction.is_zero_approx():
		_attack_direction = rig.global_basis * Vector3(0, 0, 1)	 # can't use Vector3.FORWARD here, since character-model is facing in +z direction, default FORWARD is -z
	attack_ray_cast.clear_exceptions()

func handle_idle_physics_frame(direction: Vector3, delta: float) -> void:
	if not rig.is_idle():
		return
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		look_toward_direction(direction, delta)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

func handle_slashing_physics_frame(delta: float) -> void:
	if not rig.is_slashing():
		return
	velocity.x = _attack_direction.x * attack_move_speed
	velocity.z = _attack_direction.z * attack_move_speed
	look_toward_direction(_attack_direction, delta)
	attack_ray_cast.deal_damage()
	
func handle_overhead_physics_frame() -> void:
	if not rig.is_overhead():
		return
	velocity.x = 0.0
	velocity.z = 0.0

func _on_health_component_defeat() -> void:
	rig.travel("Defeat")
	collision_shape_3d.disabled = true
	set_physics_process(false)

func _on_rig_heavy_attack() -> void:
	area_attack.deal_damage(50.0)
