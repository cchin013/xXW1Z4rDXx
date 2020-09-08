extends KinematicBody2D

var WALK_SPEED = 5 * 16 #5 tiles per second
var GRAVITY = 100
var JUMP_SPEED = -300

var Direction = Vector2()
var Velocity = Vector2()

func _ready():
	pass

func _physics_process(delta):
	_get_input()
	pass
	
func _get_input():
	Direction.x = -int(Input.is_action_pressed("ui_right")) + int(Input.is_action_pressed("ui_left"))
	pass
	
func check_grounded():
	