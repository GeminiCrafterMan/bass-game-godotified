extends CanvasLayer

#enums
enum WEAPONS {BUSTER, BLAZE, VIDEO, SMOG, SHARK, ORIGAMI, GALE, GUERRILLA, REAPER, PROTO, TREBLE, CARRY, ARROW, ENKER, PUNK, BALLADE, QUINT}
enum PALETTE {NONE, MD, NES, DOOM, PICO8, GB, VB, C64, CGA, G4, G8, G16}

# constants

# variables
## List of characters. Mods can add to this to add their own characters.
var characters : Array[String] = [
	"res://scenes/objects/players/maestro.tscn",
	"res://scenes/objects/players/bass.tscn",
	"res://scenes/objects/players/copy_robot.tscn",
	"res://scenes/objects/players/maestro.tscn" # Megaman
]
## List of life icon PNGs.
var lifeIcons = [
	"res://sprites/players/maestro/life.png",
	"res://sprites/players/bass/life.png",
	"res://sprites/players/copy_robot/life.png",
	"res://sprites/players/megaman/life.png"
]
## List of stage select portrait PNGs.
var stageSelectPlayerPortraits = [
	"res://sprites/players/maestro/stageselect.png",
	"res://sprites/players/bass/stageselect.png",
	"res://sprites/players/copy_robot/stageselect.png",
	"res://sprites/players/megaman/stageselect.png"
]
## List of stage select color translations. G: ...I couldn't make this pick Maestro's by default.
var stageSelectColorTranslations = [
	"res://sprites/players/maestro/stageseltrans.png",
	"res://sprites/players/bass/stageseltrans.png",
	"res://sprites/players/copy_robot/stageseltrans.png",
	"res://sprites/players/megaman/stageseltrans.png"
]


var maxCharacterID = characters.size() - 1 # Whyyyyy...?
var character_selected : int
var player # absolute path to player node
var player_lives : int = 3

var onscreen_bullets : int
var onscreen_sp_bullets : int

var playerposx
var playerposy
var playerstate

var camposx
var camposy

var tellies : int


var current_weapon : int
var old_weapon : int
var current_hp = 28
var bolts = 0
var ETanks = 0
var WTanks = 0
var STanks = 0
var max_hp = 28 # G: upgradeable # M: not upgradable anymore # G: yeah but mod characters :))
var healamt = 0
var ammoamt = 0

var droptimer : int
var itemtimer : int


var PROGRESSDICT = {
	"NumberOfScrews" : 0,
	"NumberOfLives": 0,
	"BlazeDead": false,
	"VideoDead": false,
	"OrigamiDead": false,
	"GaleDead": false,
	"GuerillaDead": false,
	"ReaperDead": false,
	"SharkDead": false,
	"SmogDead": false,
	"EnkerDead": false,
	"PunkDead": false,
	"BalladeDead": false,
	"QuintDead": false,
	"TrebleDead": false,
	"ProtoManDead": false,
	"HaveProtoKey1": false,
	"HaveProtoKey2": false,
	"HaveProtoKey3": false,
	"HaveProtoKey4": false
}

var weapon_energy : Array = [
	0,	# Buster
	28,	# Scorch Barrier
	28,	# Freeze Frame
	28,	# Poison Cloud
	28,	# Fin Shredder
	28,	# Origami Star
	28,	# Wild Gale
	28,	# Rolling Bomb
	28,	# Boomerang Scythe
	28,	# Proto Buster
	28,	# Treble Boost
# CR-exclusive
	28,	# Carry
	28,	# Super Arrow
	28,	# Mirror Buster
	28,	# Screw Crusher
	28,	# Ballade Cracker
	28	# Sakugarne
]
var max_weapon_energy : Array = [
# G: Energy use is always 1, *no matter what*. Increase energy and max_energy values to have larger shot counts.
# M: what the hell are you talking about???
# G: i literally have no idea, i think i was trying to think of how we'd spend ammo in a more automatic way but like
# G: that's stupid
	0,	# Buster
	28,	# Scorch Barrier
	28,	# Freeze Frame
	28,	# Poison Cloud
	28,	# Fin Shredder
	28,	# Origami Star
	28,	# Wild Gale
	28,	# Rolling Bomb
	28,	# Boomerang Scythe
	28,	# Proto Buster
	28,	# Treble Boost
# CR-exclusive
	28,	# Carry
	28,	# Super Arrow
	28,	# Mirror Buster
	28,	# Screw Crusher
	28,	# Ballade Cracker
	28	# Sakugarne
]
var weapons_unlocked = [
	#Buster, under no circumstances should this be disabled
	true, # Buster
	#Special weapons shared between Bass and Copy Robot
	false, # Blaze
	false, # Video
	false, # Smog
	false, # Shark
	false, # Origami
	false, # Gale
	false, # Guerrilla
	false, # Reaper
	false, # Proto Buster
	#Bass Only
	false, # Treble Boost
	#Copy Robot Only
	false, # Carry
	false, # Super Arrow
	false, # Mirror Buster
	false, # Screw Crusher
	false, # Ballade Cracker
	false, # Sakugarne
]
var modules_enabled = [
	true, # nothing lol
	false, # Blast Jump
	false, # Track 2
	false, # Mist Dash
	false, # Aqua Drive
	false, # Paper Cut
	false, # Aero Glide
	false, # Machine Buster
	false, # Spirit Dash
	false, # Proto Shield
]


func refill_health() -> void:
	current_hp = max_hp # Reset HP
	
func refill_ammo() -> void:
	for n in weapon_energy.size():
	# I hate this. So much.
		weapon_energy[n] = max_weapon_energy[n] # Reset WE

func _ready() -> void:
	# This could fail if, for example, mod.pck cannot be found.
	var success = ProjectSettings.load_resource_pack("res://mod.pck")

	if success:
		print("mod.pck loaded!")
		var file = FileAccess.open("res://mod.json", FileAccess.READ)
		var json = JSON.new()
		var data = json.parse(file.get_as_text(), true)
		# Save data
		# ...
		# Retrieve data
		if data == OK:
			var data_received = json.data
			if typeof(data_received) == TYPE_ARRAY:
				print(data_received) # Prints array
				characters.append(json.data[0])
				lifeIcons.append(json.data[1])
				stageSelectPlayerPortraits.append(json.data[2])
				stageSelectColorTranslations.append(json.data[3])
				maxCharacterID = characters.size() - 1
			else:
				print("Unexpected data")
		else:
			print("JSON Parse Error: ", json.get_error_message(), " in ", file, " at line ", json.get_error_line())
	else:
		print("mod.pck not found!")
