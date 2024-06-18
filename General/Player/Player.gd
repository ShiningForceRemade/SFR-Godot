extends Node2D

@onready var ray = $RayCast2D

var animation_speed = 4
var moving = false

var tile_size = 24
var inputs = {
	"ui_right": Vector2.RIGHT,
	"ui_left": Vector2.LEFT,
	"ui_up": Vector2.UP,
	"ui_down": Vector2.DOWN
}


func _ready() -> void:
	pass 


func _process(_delta: float) -> void:
	if moving:
		return
	
	if Input.is_action_pressed("ui_right"):
		move("ui_right")
	elif Input.is_action_pressed("ui_left"):
		move("ui_left")
	elif Input.is_action_pressed("ui_up"):
		move("ui_up")
	elif Input.is_action_pressed("ui_down"):
		move("ui_down")


func move(dir):
	ray.target_position = inputs[dir] * tile_size
	ray.force_raycast_update()
	if !ray.is_colliding():
		var tween = create_tween()
		tween.tween_property(self, "position",
			position + inputs[dir] *    tile_size, 1.0/animation_speed).set_trans(Tween.TRANS_SINE)
		moving = true
		await tween.finished
		moving = false
