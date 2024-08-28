extends Node

#enums
enum WEAPONS {BUSTER, BLAZE, VIDEO, SMOG, SHARK, ORIGAMI, GALE, GUERRILLA, REAPER, PROTO, TREBLE, CARRY, ARROW, ENKER, PUNK, BALLADE, QUINT}

# constants
const characters = [
	"res://scenes/Objects/Players/maestro.tscn",
	"res://scenes/Objects/Players/bass.tscn",
	"res://scenes/Objects/Players/copy_robot.tscn"
]

# variables
var character_selected : int
var player # absolute path to player node
var player_lives : int = 3
var current_weapon : int
var old_weapon : int
var current_hp = 28
var max_hp = 28 # upgradeable
var weapon_energy = [
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
var max_weapon_energy = [ # Energy use is always 1, *no matter what*. Increase energy and max_energy values to have larger shot counts.
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
	false, # Kami-Ha
	false, # Aero Glide
	false, # ???
	false, # ???
	false, # Proto Shield
]
