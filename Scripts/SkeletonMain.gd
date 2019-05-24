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
var DetectAttack = false
var AttackDetection = 30
var AttackTimer = 0
var Attacking = false
var testtransform
 
 
 
func _ready():
	set_process(true)
   
func _process(delta):
	#Enemy Detection
	DistToPlayer = get_global_transform()[2] - (Player.get_global_transform()[2])
	if (abs(DistToPlayer[0]) < MaxDetection):
		#print(rad2deg(acos(DistToPlayer.normalized().dot(Facing))))
		if (rad2deg(acos(DistToPlayer.normalized().dot(Facing))) - 100 > FOV):
			DetectPlayer = true
			if (abs(DistToPlayer[0]) < AttackDetection and not Attacking):
				AttackTimer = 120
				Attacking = true
		else:
			DetectPlayer = false
	else:
		DetectPlayer = false
	#print(DetectAttack)
	var Direction = SkeletonRandomMovement(delta)
	var motion = Vector2()
	var GravityMotion = Vector2(0, Skeleton_Gravity)
	#moving = false
	if (DeathCounter > 0):
		DeathCounter -= 1
		AttackTimer = 0
		Attacking = false
		if (DeathCounter == 0):
			queue_free()
		return
	if (StaggerCounter > 0):
		StaggerCounter -= 1
		AttackTimer = 0
		Attacking = false
		return
	if (AttackTimer >= 0):
		AttackTimer -= 1
		Animator.play("attack")
		if (AttackTimer == 68):
			SkeletonAttack()
		if (AttackTimer <= 0):
			Attacking = false
		return
	if (DetectPlayer and Facing[0] == -1):
			motion = Vector2(-1,0)
			CurrSprite.flip_h = true
			Animator.play("walk")
	elif (DetectPlayer and Facing[0] == 1):
			motion = Vector2(1,0)
			CurrSprite.flip_h = false
			Animator.play("walk")
	else:
		if (Direction == "left"):
			testtransform = transform
			testtransform[2][0] -= SkeletonSpeed*delta*10
			if (test_move(testtransform, Vector2(0,2))): #left
				motion = Vector2(-1,0)
				Animator.play("walk")
			else:
				Animator.play("idle")
			Facing = Vector2(-1,0)
			CurrSprite.flip_h = true
		elif (Direction == "right"):
			testtransform = transform
			testtransform[2][0] += SkeletonSpeed*delta*10
			if (test_move(testtransform, Vector2(0,2))): #left
				motion = Vector2(1,0)
				Animator.play("walk")
			else:
				Animator.play("idle")
			Facing = Vector2(1,0)
			CurrSprite.flip_h = false
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
		if (temp == 0):
			LeftMove = 65
			RandomMoveCounter = 0
		if (temp == 1):
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
 
 
func SkeletonAttack():
	var MeleeHit = load("res://Scenes/SkeletonAttack.tscn")
	var MeleeHitInstance = MeleeHit.instance()
	MeleeHitInstance.set_name("melee")
	var MeleeHitPos = get_position()
	if (Facing[0] == -1):
		MeleeHitPos[0] -= 24
	if (Facing[0] == 1):
		MeleeHitPos[0] += 24
	MeleeHitPos[1] += 2
	MeleeHitInstance.set_position(MeleeHitPos)
	get_node("/root").add_child(MeleeHitInstance)