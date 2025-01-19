extends CharacterBody2D

class_name Enemy_Template

var Dmg_Vals = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37]
var Atk_Dmg = 4
var Cur_Inv = 0
var Max_HP = 3
var Cur_HP = 3
var blown : bool = false

func basedmg():
	Dmg_Vals[GameState.DMGTYPE.CB_SMOG] = 1
	Dmg_Vals[GameState.DMGTYPE.CB_REAPER_1] = 3
	Dmg_Vals[GameState.DMGTYPE.CB_REAPER_2] = 5
	Dmg_Vals[GameState.DMGTYPE.CB_GALE] = 8
	Dmg_Vals[GameState.DMGTYPE.CB_ORIGAMI] = 2
	Dmg_Vals[GameState.DMGTYPE.CB_GUERILLA] = 2
	Dmg_Vals[GameState.DMGTYPE.CB_PROTO_1] = 2
	Dmg_Vals[GameState.DMGTYPE.CB_PROTO_2] = 3
	Dmg_Vals[GameState.DMGTYPE.CB_PROTO_3] = 5
	
	Dmg_Vals[GameState.DMGTYPE.CR_BUSTER_1] = 1
	Dmg_Vals[GameState.DMGTYPE.CR_BUSTER_2] = 2
	Dmg_Vals[GameState.DMGTYPE.CR_BUSTER_3] = 4
	Dmg_Vals[GameState.DMGTYPE.CR_BLAZE] = 2
	Dmg_Vals[GameState.DMGTYPE.CR_SHARK1] = 4
	Dmg_Vals[GameState.DMGTYPE.CR_SHARK2] = 10
	Dmg_Vals[GameState.DMGTYPE.CR_ARROW] = 1
	Dmg_Vals[GameState.DMGTYPE.CR_ENKER] = 1
	Dmg_Vals[GameState.DMGTYPE.CR_PUNK] = 2
	Dmg_Vals[GameState.DMGTYPE.CR_BALLADE] = 4
	Dmg_Vals[GameState.DMGTYPE.CR_QUINT1] = 4
	Dmg_Vals[GameState.DMGTYPE.CR_QUINT2] = 1
	
	Dmg_Vals[GameState.DMGTYPE.BS_BUSTER] = 1
	Dmg_Vals[GameState.DMGTYPE.BS_BLAZE] = 3
	Dmg_Vals[GameState.DMGTYPE.BS_SHARK] = 8
	Dmg_Vals[GameState.DMGTYPE.BS_TREBLE] = 1
	
	Dmg_Vals[GameState.DMGTYPE.MD_BLAZE] = 3
	Dmg_Vals[GameState.DMGTYPE.MD_VIDEO] = 2
	Dmg_Vals[GameState.DMGTYPE.MD_ORIGAMI] = 3
	Dmg_Vals[GameState.DMGTYPE.MD_GUERILLA] = 2
	
func _ready():
	basedmg()

func _physics_process(_delta):
	if Cur_HP <= 0:
		queue_free()
	if Cur_Inv > 0:
		Cur_Inv -= 1
		if Cur_Inv % 2 == 0:
			$Sprite.visible = false
		else:
			$Sprite.visible = true
	else:
		visible = true

func _on_hitable_body_entered(weapon): # needs to be redefined because damage values
	#Check for I-Frames or multihit
	if Cur_Inv <= 0 or weapon.W_Type == GameState.DMGTYPE.CB_ORIGAMI or weapon.W_Type == GameState.DMGTYPE.CB_REAPER_1 or weapon.W_Type == GameState.DMGTYPE.CB_REAPER_2 or weapon.W_Type == GameState.DMGTYPE.MD_GUERILLA:
		#Does it do 0 damage?
		if Dmg_Vals[weapon.W_Type] == 0:
			#For these, have the projectile dissipate.
			if weapon.W_Type == GameState.DMGTYPE.BS_SHARK or weapon.W_Type == GameState.DMGTYPE.CR_SHARK1 or weapon.W_Type == GameState.DMGTYPE.CR_SHARK2:
				weapon.destroy()
			#For all others, the projectile bounces off. Plink!
			else:
				weapon.reflect()
		#Cool, it does damage!!
		else:
			#Is it Scorch Barrier?
			if weapon.is_in_group("scorch"):
				#For most characters, reduce durability by...
				if GameState.character_selected != 2:
					weapon.durability -= 1
				#Copy robot isn't so lucky...
				else:
					weapon.durability -= 2
			#Look up the damage type and do damage according to it.
			Cur_HP -= Dmg_Vals[weapon.W_Type]
			Cur_Inv = 2
			#If the enemy is killed by Wild Gale, let em get blown away!
			if Cur_HP <= 0 and weapon.W_Type == GameState.DMGTYPE.CB_GALE:
				Cur_HP = 999
				blown = true
			
			#If the projectile kills, or are the below weapons on hit, go to the kill state!
			if Cur_HP <= 0 or weapon.W_Type == GameState.DMGTYPE.CR_SHARK1 or weapon.W_Type == GameState.DMGTYPE.CR_SHARK2 or weapon.W_Type == GameState.DMGTYPE.BS_SHARK:
				weapon.kill()
			else:
				#If neither of these conditions are met, whatever!
				weapon.destroy()

func _on_hurt_body_entered(body):
	body.DmgQueue = Atk_Dmg
