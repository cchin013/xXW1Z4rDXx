extends "res://Scripts/BaseEnemy.gd"
 
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
var Attacking = false
var AttackTimer = 0
var testtransform
var DamageTimer = 0





func _ready():
	set_process(true)
   
func _process(delta):
	print(Engine.get_frames_per_second())
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
	var Direction = SkeletonRandomMovement(delta)
	var motion = Vector2()
	var GravityMotion = Vector2(0, Skeleton_Gravity)
	#moving = false
	if (DeathCounter > 0):
		DeathCounter -= 1
		Attacking = false
		if (DeathCounter == 0):
			queue_free()
		return
	if (Facing[0] == 1):
		CurrSprite.flip_h = false
	else:
		CurrSprite.flip_h = true
	if (StaggerCounter > 0):
		StaggerCounter -= 1
		AttackTimer = 0
		Attacking = false
		return
	if (DamageTimer == 3):
		DealDamage()
		DamageTimer = 0
	else:
		DamageTimer += 1
	if (Attacking):
		AttackTimer -= 1
		Animator.play("attack")
		if (AttackTimer == 68):
			SkeletonAttack()
		if (AttackTimer == 0):
			Attacking = false
		return
	if (DetectPlayer and Facing[0] == -1):
			motion = Vector2(-1,0)
			Animator.play("walk")
	elif (DetectPlayer and Facing[0] == 1):
			motion = Vector2(1,0)
			Animator.play("walk")
	else:
		if (Direction == "left"):
			testtransform = transform
			testtransform[2][0] -= SkeletonSpeed*delta*5
			if (test_move(testtransform, Vector2(0,2))): #left
				motion = Vector2(-1,0)
				Animator.play("walk")
			else:
				Animator.play("idle")
			Facing = Vector2(-1,0)
		elif (Direction == "right"):
			testtransform = transform
			testtransform[2][0] += SkeletonSpeed*delta*5
			if (test_move(testtransform, Vector2(0,2))): #left
				motion = Vector2(1,0)
				Animator.play("walk")
			else:
				Animator.play("idle")
			Facing = Vector2(1,0)
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
	var temp = (Player.get_global_transform()[2]) - get_global_transform()[2]
	if (temp[0] > 0):
		Facing[0] = 1
	else:
		Facing[0] = -1
   
func Die():
	Animator.play("dead")
	DeathCounter = 90
 
func DealDamage():
	var Overlaps = get_node("SkeletonDamageBox").get_overlapping_bodies()
	for Hit in (Overlaps):
		if (Hit.is_in_group("Player")):
			if (Hit.Invincible == false and not Hit.Dying):
				Hit.Take_Damage(20)
				Hit.Invincibility_Frames(60)

 
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
