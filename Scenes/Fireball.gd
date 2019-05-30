extends Area2D

export var FIREBALL_SPEED = 350
export var LIFESPAN = 1

var RayNode
var RemainingLife

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	RayNode = get_node("FireballRotation")
	RemainingLife = LIFESPAN
	set_process(true)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (RemainingLife <= 0):
		free()
		return
	DealDamage()
	var FireballMotion = FIREBALL_SPEED*delta
	if (RayNode.get_rotation_degrees() == -90):
		FireballMotion = FIREBALL_SPEED*delta
		set_rotation_degrees(180)
	if (RayNode.get_rotation_degrees() == 90):
		FireballMotion = -FIREBALL_SPEED*delta
	var FireballCollisionCheck = global_translate(Vector2(FireballMotion,0))
	RemainingLife -= 1*delta

func DealDamage():
	var Overlaps = get_overlapping_bodies()
	for Hit in (Overlaps):
		if (Hit.is_in_group("Enemies")):
			if (Hit.Invincible == false):
				Hit.Take_Damage(20)
				Hit.Invincibility_Frames(30)
				queue_free()
		elif (Hit.is_in_group("Terrain")):
			queue_free()

