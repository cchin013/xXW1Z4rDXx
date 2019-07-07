extends Area2D

export var SHADOWBALL_SPEED = 100
export var LIFESPAN = 1.75

var RayNode
var RemainingLife

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	RayNode = get_node("ShadowBallRotation")
	RemainingLife = LIFESPAN
	set_process(true)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (RemainingLife <= 0):
		free()
		return
	DealDamage()
	var ShadowBallMotion = SHADOWBALL_SPEED*delta
	if (RayNode.get_rotation_degrees() == 90):
		ShadowBallMotion = SHADOWBALL_SPEED*delta
		#set_rotation_degrees(180)
	if (RayNode.get_rotation_degrees() == -90):
		ShadowBallMotion = -SHADOWBALL_SPEED*delta
	global_translate(Vector2(ShadowBallMotion,0))
	RemainingLife -= 1*delta
	SHADOWBALL_SPEED += 3

func DealDamage():
	var Overlaps = get_overlapping_bodies()
	for Hit in (Overlaps):
		if (Hit.is_in_group("Player")):
			if (Hit.Invincible == false and not Hit.Dying):
				Hit.Take_Damage(30)
				Hit.Invincibility_Frames(60)
				queue_free()

	
