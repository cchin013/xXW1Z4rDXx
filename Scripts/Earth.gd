extends KinematicBody2D

export var Earth_Speed = 200
export var LIFESPAN = 5
export var Earth_Gravity = 100

var RayNode
var RemainingLife
var EarthDirection = 1

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	RayNode = get_node("EarthRotation")
	RemainingLife = LIFESPAN
	if (RayNode.get_rotation_degrees() == -90):
		get_node("EarthSprite").flip_h = false
		get_node("EarthSprite").flip_v = false
		EarthDirection = 1
	if (RayNode.get_rotation_degrees() == 90):
		get_node("EarthSprite").flip_h = true
		get_node("EarthSprite").flip_v = true
		EarthDirection = -1
	set_process(true)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (RemainingLife <= 0):
		queue_free()
		return
	get_node("EarthSprite").rotation_degrees += (5 * (Earth_Speed/200) * EarthDirection)
	DealDamage()
	move_and_slide(Vector2(EarthDirection*Earth_Speed,Earth_Gravity))
	RemainingLife -= 1*delta
	if (test_move(get_transform(), Vector2(0,0.1))):
		Earth_Gravity = 100
	else:
		Earth_Gravity += 12
	if (test_move(get_transform(), Vector2(0.1,-0.1)) or test_move(get_transform(), Vector2(-0.1,-0.1))):
		Earth_Speed *= 0.8
		EarthDirection *= -1

func DealDamage():
	var Overlaps = get_node("Earth").get_overlapping_bodies()
	for Hit in (Overlaps):
		if (Hit.is_in_group("Enemies")):
			if (Hit.Invincible == false and not Hit.Dying):
				Hit.Take_Damage(30*(Earth_Speed/100))
				Hit.Invincibility_Frames(30)