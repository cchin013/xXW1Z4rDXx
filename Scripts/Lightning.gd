extends Area2D

export var LIFESPAN = 1

var RayNode
var RemainingLife

# Called when the node enters the scene tree for the first time.
func _ready():
	RayNode = get_node("Rotation")
	if (RayNode.get_rotation_degrees() == -90):
		pass
	if (RayNode.get_rotation_degrees() == 90):
		set_rotation_degrees(180)
	RemainingLife = LIFESPAN
	set_process(true)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (RemainingLife <= 0):
		free()
		return
	DealDamage()
	RemainingLife -= 30*delta

func DealDamage():
	var Overlaps = get_overlapping_bodies()
	for Hit in (Overlaps):
		if (Hit.is_in_group("Enemies")):
			if (Hit.Invincible == false and not Hit.Dying):
				Hit.Take_Damage(35)
				Hit.Invincibility_Frames(30)

