extends RigidBody2D

@onready var stretch_audio: AudioStreamPlayer2D = $stretch_audio
@onready var arrow: Sprite2D = $arrow
@onready var launch_audio: AudioStreamPlayer2D = $launch_audio
@onready var wood_audio: AudioStreamPlayer2D = $wood_audio

enum ANIMAL_STATE {READY, DRAG, RELEASE}

var animal_state: ANIMAL_STATE = ANIMAL_STATE.READY
var start: Vector2 = Vector2.ZERO
var drag_start: Vector2 = Vector2.ZERO
var dragged_vector: Vector2 = Vector2.ZERO
var previous_dragged_vector: Vector2 = Vector2.ZERO
var arrow_scale_x: float = 0.0
var last_collision_count: int = 0

const MAX_DRAG_LIM: Vector2 = Vector2(0, 60)
const MIN_DRAG_LIM: Vector2 = Vector2(-60, 0)
const IMPULSE_MULT: float = 20.0
const IMPULSE_MAX: float = 1200.0

func _ready() -> void:
	start = position
	arrow.hide()
	arrow_scale_x = arrow.scale.x

func _physics_process(delta: float) -> void:
	update(delta)
	
func get_impulse() -> Vector2:
	return dragged_vector * -1 * IMPULSE_MULT
	

func scale_arrow()-> void:
	var imp_length = get_impulse().length()
	var imp_percentage = imp_length / IMPULSE_MAX
	arrow.rotation = (start - position).angle()
	arrow.scale.x = (arrow_scale_x * imp_percentage) + arrow_scale_x
	

func play_stretch_audio()-> void:
	if (previous_dragged_vector - dragged_vector).length() > 0:
		if stretch_audio.playing == false:
			stretch_audio.play()

func set_release()->void:
	freeze = false
	arrow.hide()
	apply_central_impulse(get_impulse())
	launch_audio.play()
func set_new_state(new_state: ANIMAL_STATE)-> void:
	animal_state = new_state
	if animal_state == ANIMAL_STATE.RELEASE:
		set_release()
	elif animal_state == ANIMAL_STATE.DRAG:
		drag_start = get_global_mouse_position()
		arrow.show()
		
func detect_release()-> bool:
	if animal_state == ANIMAL_STATE.DRAG:
		if Input.is_action_just_released("drag"):
			set_new_state(ANIMAL_STATE.RELEASE)
			return true
	return false

func get_dragged_vector(gmp: Vector2) -> Vector2:
	return gmp - drag_start

func drag_in_limits() -> void:
	previous_dragged_vector = dragged_vector
	dragged_vector.x = clampf(
		dragged_vector.x,
		MIN_DRAG_LIM.x,
		MAX_DRAG_LIM.x
	)
	dragged_vector.y = clampf(
		dragged_vector.y,
		MIN_DRAG_LIM.y,
		MAX_DRAG_LIM.y
	)
	position = start + dragged_vector

func update_drag()-> void:
	if detect_release() == true:
		return
	var get_mouse_position = get_global_mouse_position()
	dragged_vector = get_dragged_vector(get_mouse_position)
	play_stretch_audio()
	drag_in_limits()
	scale_arrow()
func update_flight()-> void:
	if (last_collision_count == 0 and 
		get_contact_count() > 0 and 
		!wood_audio.playing):
		wood_audio.play()
	last_collision_count = get_contact_count()
	
func play_wood_audio() -> void:
	wood_audio.play()
func update(delta: float) -> void:
	match animal_state:
		ANIMAL_STATE.DRAG:
			update_drag()
		ANIMAL_STATE.RELEASE:
			update_flight()

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if animal_state == ANIMAL_STATE.READY and event.is_action_pressed("drag"):
		set_new_state(ANIMAL_STATE.DRAG)

func die() -> void: 
	queue_free()
	SignalManager.ON_PLAYER_DEATH.emit()

func _on_screen_exited() -> void:
	die()

func _on_sleeping_state_changed() -> void:
	if sleeping:
		var cb = get_colliding_bodies()
		if cb.size() > 0:
			cb[0].die()
		call_deferred("die")
