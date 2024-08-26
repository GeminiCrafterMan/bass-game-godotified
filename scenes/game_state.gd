extends Node

const characters = [
	"res://scenes/Objects/Players/bass.tscn",
	"res://scenes/Objects/Players/copy_robot.tscn"
]
var character_selected : int

var player_lives : int = 3

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
