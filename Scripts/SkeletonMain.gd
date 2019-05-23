extends "res://Scripts/BaseEnemy.gd"

#testtest

#export var SkeletonHealth = 500
export var SkeletonSpeed = 70
var moving = false
var Skeleton_Gravity = 100
var RandomMoveCounter = randi()%200
var LeftMove = 0
var RightMove = 0
onready var CurrSprite = get_node("skeleton")
onready var Animator = CurrSprite.get_node("AnimationPlayer")
var StaggerCounter = 0
var DeathCounter = 0



func _ready():
	set_process(true)
	
func _process(delta):
	#Enemy Detection
	var Direction = SkeletonRandomMovement(delta)
	var motion = Vector2()
	var GravityMotion = Vector2(0, Skeleton_Gravity)
	#moving = false
	if (DeathCounter > 0):
		DeathCounter -= 1
		print(DeathCounter)
		if (DeathCounter == 0):
			print("hello")
			queue_free()
		return
	if (StaggerCounter > 0):
		StaggerCounter -= 1
		return
	if (Direction == "left"):
		motion = Vector2(-1,0)
		CurrSprite.flip_h = true
		Animator.play("walk")
	elif (Direction == "right"):
		motion = Vector2(1,0)
		CurrSprite.flip_h = false
		Animator.play("walk")
	elif (Direction == "none"):
		Animator.play("idle")
		pass

	if (test_move(get_transform(), Vector2(0,0.1))):
		Skeleton_Gravity = 100
	else:
		Skeleton_Gravity += 12
	motion[0] *= SkeletonSpeed
	motion[1] += GravityMotion[1]
	move_and_slide(motion)
	
	
func SkeletonRandomMovement(delta):
	if (LeftMove > 0):
		LeftMove -= 1
		return "left"
	if (RightMove > 0):
		RightMove -= 1
		return "right"

		
	if (RandomMoveCounter > 240):
		var temp = randi()%2 #can be expanded to add things like cool idle animations
		var transform = get_transform()
		if (temp == 0):
			transform[2][0] += -65*SkeletonSpeed*delta
		if (temp == 1):
			transform[2][0] += 65*SkeletonSpeed*delta
		if (temp == 0 and (test_move(transform, Vector2(0,2)))): #left
			LeftMove = 65
			RandomMoveCounter = 0
		elif (temp == 1 and (test_move(transform, Vector2(0,2)))): #right
			RightMove = 65
			RandomMoveCounter = 0
	RandomMoveCounter += 1
	return "none"

func Take_Damage(damage):
	Health -= damage
	StaggerCounter = 42
	Animator.play("stagger")
	
func Die():
	Animator.play("dead")
	DeathCounter = 90
	