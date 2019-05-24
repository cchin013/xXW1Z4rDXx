extends Area2D

export var LIGHTNING_SPEED = 350
export var LIFESPAN = 1

var RayNode
var RemainingLife
var DamageTimer = 0

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	RayNode = get_node("LightningRotation")
	RemainingLife = LIFESPAN
	set_process(true)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (RemainingLife <= 0):
		free()
		return
	if (DamageTimer == 3):
		DealDamage()
		DamageTimer = 0
	else:
		DamageTimer += 1
	var LightningMotion = LIGHTNING_SPEED*delta
	if (RayNode.get_rotation_degrees() == -90):
		LightningMotion = LIGHTNING_SPEED*delta
	if (RayNode.get_rotation_degrees() == 90):
		LightningMotion = -LIGHTNING_SPEED*delta
		get_node("LightningSprite").flip_h = true
		get_node("LightningSprite").flip_v = true
	var LightningCollisionCheck = global_translate(Vector2(LightningMotion,0))
	RemainingLife -= 1*delta

func DealDamage():
	var Overlaps = get_overlapping_bodies()
	for Hit in (Overlaps):
		if (Hit.is_in_group("Enemies")):
			if (Hit.Invincible == false and not Hit.Dying):
				Hit.Take_Damage(35)
				Hit.Invincibility_Frames(42)
		elif (Hit.is_in_group("Terrain")):
			queue_free()

