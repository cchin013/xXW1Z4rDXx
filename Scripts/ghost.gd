extends "res://Scripts/BaseEnemy.gd"

onready var CurrSprite = get_node("ghost/GhostSprite")
onready var Animator = CurrSprite.get_node("AnimationPlayer")
var AttackTimer = 0
var AttackDetection = 200
var DeathCounter = 0
var AttackCooldown = 0

func _ready():
	Health = 1
	MaxDetection = 200
	FOV = 30
	set_process(true)

func _process(delta):
	DistToPlayer = get_global_transform()[2] - (Player.get_global_transform()[2])
	if (abs(DistToPlayer[0]) < MaxDetection):
		#print(rad2deg(acos(DistToPlayer.normalized().dot(Facing))))
		if (DistToPlayer[0] > 0):
			Facing[0] = -1
			#print("face left")
		else:
			Facing[0] = 1
			#print("face right")
		if (rad2deg(acos(DistToPlayer.normalized().dot(Facing))) - 100 > FOV):
			DetectPlayer = true
			if (abs(DistToPlayer[0]) < AttackDetection and AttackCooldown <= 0):
				AttackTimer = 15
				AttackCooldown = 150
		else:
			DetectPlayer = false
	else:
		DetectPlayer = false
	if (DeathCounter > 0):
		AttackTimer = 0
		DeathCounter -= 1
		if (DeathCounter == 0):
			queue_free()
		return
	if (AttackTimer > 0):
		AttackTimer -= 1
		Animator.play("shriek")
		if (AttackTimer == 0):
			SpawnShadowBall()
	if (Facing[0] == 1):
		CurrSprite.flip_h = true
	else:
		CurrSprite.flip_h = false
	if (AttackCooldown <= 90):
		Animator.play("idle")
	AttackCooldown -= 1

func Die():
	DeathCounter = 45
	Animator.play("vanish")

func SpawnShadowBall():
	var ShadowBall = load("res://Scenes/ShadowBall.tscn")
	var ShadowBallInstance = ShadowBall.instance()
	ShadowBallInstance.set_name("ShadowBall")
	if (Facing[0] == 1):
		ShadowBallInstance.get_node("ShadowBallRotation").set_rotation_degrees(90)
	else:
		ShadowBallInstance.get_node("ShadowBallRotation").set_rotation_degrees(-90)
	var ShadowBallPos = get_position()
	if (Facing[0] == 1):
		ShadowBallPos[0] += 16
	if (Facing[0] == -1):
		ShadowBallPos[0] -= 16
	ShadowBallPos[1] -= 2
	ShadowBallInstance.set_position(ShadowBallPos)
	get_node("/root").add_child(ShadowBallInstance)
	
	
	
	
	
	
