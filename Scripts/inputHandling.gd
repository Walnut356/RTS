"""
Handles generic inputs not related to an individual body:
Unit selection
Debugging unit spawner
"""

extends Node2D

const unit_temp = preload("res://Scenes/unit_temp.tscn")

export var dragging = false
var refSelection = []
var tempSelection = []
var drag_start = Vector2.ZERO
var selectRectangle = RectangleShape2D.new()

var camSpeed = 10

enum Commands {
	NONE,
	MOVE,
	ATTACK_MOVE,
	HOLD,
	PATROL
}
#modifiers for input
enum CommandMods {
	NONE,
	ATTACK_MOVE,
	PATROL
}

var command_mod = CommandMods.NONE
var command = Commands.NONE

#func _input(event):
#		if Input.is_action_just_pressed("attack_move"):
#			command_mod = CommandMods.ATTACK_MOVE
#		if Input.is_action_just_pressed("hold"):
#			command = Commands.HOLD
#			for unit in selection:
#				unit.state_machine.set_state("states.idle")
#		if Input.is_action_just_released("mouseR"):
#			for unit in selection:
#				unit.moveTarget = event.position
#				unit.state_machine.set_state("states.move")
#		if (Input.is_action_just_pressed("mouseL") and command_mod == CommandMods.ATTACK_MOVE):
#			for unit in selection:
#				unit.moveTarget = event.position
#				unit.state_machine.set_state("states.move")
#				command = Commands.ATTACK_MOVE
#				command_mod = CommandMods.NONE
				
func _unhandled_input(event):
	#left click selection
	if Input.is_action_just_pressed("mouseL") && command_mod == CommandMods.NONE:
		dragging = true
		drag_start = get_global_mouse_position()
		
	if Input.is_action_just_released("mouseL")  && command_mod == CommandMods.NONE:
		dragging = false
		$SelectionDraw.UpdateStatus(drag_start, get_global_mouse_position(), dragging)
		var drag_end = get_global_mouse_position()
		selectRectangle.extents = (drag_end - drag_start) / 2
		var space = get_world_2d().direct_space_state
		var query = Physics2DShapeQueryParameters.new()
		query.set_shape(selectRectangle)
		query.transform = Transform2D(0, (drag_end + drag_start) / 2)
		tempSelection = space.intersect_shape(query)
		if tempSelection.size() > 0:
			for unit in refSelection:
				if unit.get_ref():
					unit.get_ref().Deselect()
			refSelection = []
	
			for unit in tempSelection:
				if unit.collider.is_in_group("selectableUnit"):
					refSelection.append(weakref(unit.collider))
					unit.collider.Select()
				
		tempSelection = []
	
	if Input.is_action_just_pressed("mouseL") && command_mod != CommandMods.NONE:
		var drag_end = get_global_mouse_position()
		selectRectangle.extents = (drag_end - drag_start) / 2
		var space = get_world_2d().direct_space_state
		var query = Physics2DShapeQueryParameters.new()
		query.set_shape(selectRectangle)
		query.transform = Transform2D(0, (drag_end + drag_start) / 2)
		tempSelection = space.intersect_shape(query)
		command_mod = CommandMods.NONE
		
	#drag selection
	if(dragging):
		if event is InputEventMouseMotion: 
			$SelectionDraw.UpdateStatus(drag_start, get_global_mouse_position(), dragging)


func _unhandled_key_input(event):
	
	#Debug unit spawning
	if(event.is_action_pressed("SpawnPlayerUnit")):
		var unit = unit_temp.instance()
		unit.position = get_local_mouse_position()
		unit.unitOwner = "Player"
		unit.isAllied = true
		get_tree().get_root().add_child(unit)
	if(event.is_action_pressed("SpawnEnemyUnit")):
		var unit = unit_temp.instance()
		unit.position = get_local_mouse_position()
		unit.unitOwner = "Enemy"
		unit.isAllied = false
		get_tree().get_root().add_child(unit)
		
	#if(Input.is_action_just_pressed("attack_move") && refSelection.size() != 0):
		#if not dragging:
			#command_mod = CommandMods.ATTACK_MOVE

#func remove_from_selected(selectedUnit):
#	if selection.has(selectedUnit):
#		selection.remove(selection.find(selectedUnit))
#		print("Dead unit removed from selected")
