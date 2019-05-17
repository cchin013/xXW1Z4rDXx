extends KinematicBody2D

export var LIGHTNING_SPEED = 500

var RayNode

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	RayNode = get_node("LightningRotation")
	set_process(true)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var LightningMotion = LIGHTNING_SPEED*delta
	if (RayNode.get_rotation_degrees() == -90):
		LightningMotion = LIGHTNING_SPEED*delta
	if (RayNode.get_rotation_degrees() == 90):
		LightningMotion = -LIGHTNING_SPEED*delta
		get_node("LightningSprite").flip_h = true
		get_node("LightningSprite").flip_v = true
	var LightningCollisionCheck = move_and_collide(Vector2(LightningMotion,0))
	#print(LightningCollisionCheck)
	
