class_name WaveData
extends Resource
#one wave of enemies, save as .tres so you can tune it in the inspector

#what gets spawned
@export var enemy_scene: PackedScene
#how many of them
@export var count: int = 5

#seconds between each spawn in this wave
@export var spawn_interval: float = 0.8

#the "make each wave harder" knobs, multipliers not flat values so they
#survive retuning base stats
@export_group("Difficulty")
@export var health_multiplier: float = 1.0
@export var speed_multiplier: float = 1.0
