extends CanvasLayer

#enums
enum WEAPONS {BUSTER, BLAZE, VIDEO, SMOG, SHARK, ORIGAMI, GALE, GUERRILLA, REAPER, PROTO, TREBLE, CARRY, ARROW, ENKER, PUNK, BALLADE, QUINT}
enum PALETTE {NONE, MD, NES, DOOM, PICO8, GB, VB, C64, CGA, G4, G8, G16}

# constants

# variables
var characters = [ # It's a var now so mods can add more
	"res://scenes/objects/players/maestro.tscn",
	"res://scenes/objects/players/bass.tscn",
	"res://scenes/objects/players/copy_robot.tscn"
]
var maxCharacterID = characters.size() - 1 # Whyyyyy...?
var character_selected : int
var player # absolute path to player node
var player_lives : int = 3
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
