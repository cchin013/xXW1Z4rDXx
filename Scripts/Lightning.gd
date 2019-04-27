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
	if (RayNode.is_colliding()):
		print("reeee")
	var LightningMotion = LIGHTNING_SPEED*delta
	if (RayNode.get_rotation_degrees() == 0):
		LightningMotion = LIGHTNING_SPEED*delta
	if (RayNode.get_rotation_degrees() == 180):
		LightningMotion = -LIGHTNING_SPEED*delta
	var LightningCollisionCheck = move_and_collide(Vector2(LightningMotion,0))
	#print(LightningCollisionCheck)
	
