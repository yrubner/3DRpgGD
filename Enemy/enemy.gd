extends CharacterBody3D

@export var max_health: int = 20

@onready var rig: Node3D = $Rig
@onready var health_component: HealthComponent = $HealthComponent


func _ready() -> void:
	rig.set_active_mesh(
		rig.villager_meshes.pick_random()
	)
	health_component.update_max_health(max_health)
