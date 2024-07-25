extends Node

var character_selected : bool
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
	false, # ???
	false, # ???
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
