extends Node2D

const ANIMAL = preload("res://scenes/animal/animal.tscn")

@onready var animal_spawn_point: Marker2D = $AnimalSpawnPoint


func _ready() -> void:
	spawn_animal()
	SignalManager.ON_PLAYER_DEATH.connect(on_player_death)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func spawn_animal() -> void:
	var animal = ANIMAL.instantiate()
	animal.position = animal_spawn_point.position
	add_child(animal)
	
func on_player_death()-> void:
	spawn_animal()
