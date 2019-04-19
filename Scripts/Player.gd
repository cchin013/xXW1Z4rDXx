extends KinematicBody2D

# Declare member variables here. Examples:

export var motion_speed = 140

var rayNode

# Called when the node enters the scene tree for the first time.
func _ready():
	set_physics_process(true)
	rayNode = get_node("Raycast")
	
func _physics_process(delta):
	var motion = Vector2()
	
	if(Input.is_action_pressed("ui_up")):
		motion += Vector2(0, -1)
		rayNode.rotation = 180
		
	if(Input.is_action_pressed("ui_down")):
		motion += Vector2(0, 1)
		rayNode.rotation = 0
		
	if(Input.is_action_pressed("ui_left")):
		motion += Vector2(-1, 0)
		rayNode.rotation = -90

	if(Input.is_action_pressed("ui_right")):
		motion += Vector2(1, 0)
		rayNode.rotation = 90
		
	motion =  motion.normalized() * motion_speed * delta
	move_and_collide(motion)
