extends CharacterBody3D
class_name Enemy
@export var max_health: int = 20

@onready var rig: Node3D = $Rig
@onready var health_component: HealthComponent = $HealthComponent
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var player_detector: ShapeCast3D = $PlayerDetector


func _ready() -> void:
	rig.set_active_mesh(
		rig.villager_meshes.pick_random()
	)
	health_component.update_max_health(max_health)

func _physics_process(delta: float) -> void:
	if rig.is_idle():
		check_for_attacks()
	
func check_for_attacks() -> void:
	for collider_id in player_detector.get_collision_count():
		var collider = player_detector.get_collider(collider_id)
		if collider is Player:
			rig.travel("Overhead")

func _on_health_component_defeat() -> void:
	rig.travel("Defeat")
	collision_shape_3d.disabled = true
	set_physics_process(false)


func _on_rig_heavy_attack() -> void:
	print("Heavy attack signal")
