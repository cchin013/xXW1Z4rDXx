extends Area2D

export var LIFESPAN = 1

var RayNode
var RemainingLife

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	RayNode = get_node("LightningRotation")
	if (RayNode.get_rotation_degrees() == -90):
		pass
	if (RayNode.get_rotation_degrees() == 90):
		set_rotation_degrees(180)
		#get_node("LightningSprite1").flip_h = true
		#get_node("LightningSprite1").flip_v = true
		#get_node("LightningSprite2").flip_h = true
		#get_node("LightningSprite2").flip_v = true
		#get_node("LightningSprite3").flip_h = true
		#get_node("LightningSprite3").flip_v = true
		#get_node("LightningSprite4").flip_h = true
		#get_node("LightningSprite4").flip_v = true
		#get_node("LightningSprite5").flip_h = true
		#get_node("LightningSprite5").flip_v = true
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

