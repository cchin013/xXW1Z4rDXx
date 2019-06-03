extends "res://Scripts/BaseEnemy.gd"

var LeftMove = 0
var SlimeGravity = 50
var RightMove = 0
var RandomMoveCounter = 0
export var SlimeSpeed = 50
onready var CurrSprite = get_node("green")
onready var Animator = CurrSprite.get_node("green_player")
var DeathCounter = 0
var StaggerCounter = 0
var DamageTimer = 0


func _ready():
	set_process(true)

func _process(delta):
	DistToPlayer = get_global_transform()[2] - (Player.get_global_transform()[2])
	if (abs(DistToPlayer[0]) < MaxDetection):
		#print(rad2deg(acos(DistToPlayer.normalized().dot(Facing))))
		if (rad2deg(acos(DistToPlayer.normalized().dot(Facing))) - 100 > FOV):
			DetectPlayer = true
			SlimeSpeed = 80
		else:
			DetectPlayer = false
			SlimeSpeed = 50
	else:
		DetectPlayer = false
		SlimeSpeed = 50
	var motion = Vector2(0,0)
	var GravityMotion = Vector2(0, SlimeGravity)
	var Direction = SlimeRandomMovement()
	if (DeathCounter > 0):
		DeathCounter -= 1
		move_and_slide(GravityMotion)
		if (DeathCounter == 0):
			queue_free()
		return
	if (StaggerCounter > 0):
		StaggerCounter -= 1
		move_and_slide(GravityMotion)
		return
	if (DamageTimer == 3):
		DamageTimer = 0
		DealDamage()
	var testtransform
	if (DetectPlayer and Facing[0] == -1):
			motion = Vector2(-1,0)
			Animator.play("Left")
	elif (DetectPlayer and Facing[0] == 1):
			motion = Vector2(1,0)
			Animator.play("Right")
	else:
		if (Direction == "left"):
			testtransform = transform
			testtransform[2][0] -= SlimeSpeed*delta*5
			if (test_move(testtransform, Vector2(0,2))): #left
				motion = Vector2(-1,0)
				Animator.play("Left")
			else:
				Animator.play("Bounce")
			Facing = Vector2(-1,0)
		elif (Direction == "right"):
			testtransform = transform
			testtransform[2][0] += SlimeSpeed*delta*5
			if (test_move(testtransform, Vector2(0,2))): #left
				motion = Vector2(1,0)
				Animator.play("Right")
			else:
				Animator.play("Bounce")
			Facing = Vector2(1,0)
		elif (Direction == "none"):
			Animator.play("Bounce")
			
	if (test_move(get_transform(), Vector2(0,0.1))):
		SlimeGravity = 50
	else:
		SlimeGravity += 6
	motion[0] *= SlimeSpeed
	motion[1] += GravityMotion[1]
	move_and_slide(motion)
	DamageTimer += 1

func DealDamage():
	var Overlaps = get_node("SlimeDamageBox").get_overlapping_bodies()
	for Hit in (Overlaps):
		if (Hit.is_in_group("Player")):
			if (Hit.Invincible == false and not Hit.Dying):
				Hit.Take_Damage(30)
				Hit.Invincibility_Frames(60)
				
func Take_Damage(damage):
	Health -= damage
	StaggerCounter = 42
	Animator.play("Bounce")
	var temp = (Player.get_global_transform()[2]) - get_global_transform()[2]
	if (temp[0] > 0):
		Facing[0] = 1
	else:
		Facing[0] = -1

func SlimeRandomMovement():
	if (LeftMove > 0):
		LeftMove -= 1
		return "left"
	if (RightMove > 0):
		RightMove -= 1
		return "right"
		
	if (RandomMoveCounter > 300):
		var temp = randi()%2 #can be expanded to add things like cool idle animations
		if (temp == 0):
			LeftMove = 85
			RandomMoveCounter = 0
		if (temp == 1):
			RightMove = 85
			RandomMoveCounter = 0
	RandomMoveCounter += 1
	return "none"

func Die():
	Animator.play("Bounce")
	DeathCounter = 60