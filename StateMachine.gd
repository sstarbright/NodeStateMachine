@tool
class_name StateMachine
extends Node

## Triggered when the State of this StateMachine is changed.
signal state_changed(new_state : String)

## INTERNAL - The current State of this StateMachine.
var _current_state : StateNode

## The Node to be used as a reference for Advance Expressions.
@export var advance_node : Node

func _ready() -> void:
	if !Engine.is_editor_hint():
		if !advance_node:
			advance_node = self
		var first_state := false
		for child_node in get_children():
			if verify_state(child_node):
				if !first_state:
					_current_state = child_node
					first_state = true
		if first_state:
			_current_state._enter(true, null)

func _get_configuration_warnings():
	if get_child_count() > 0:
		for child_node in get_children():
			if verify_state(child_node):
				return []
	return ["State Machine must have the proper child StateNodes!"]

## INTERNAL - Verify a Node as a StateNode.
func verify_state(state : Node):
	return (state is StateNode && state is not AnimStateNode)

## INTERNAL - Switch to a new State through a Transition.
func _switch_to(trans_node: TransNode):
	if can_process():
		trans_node._switch_to()

## Force a switch to a new State.
func force_state(target_state: String):
	if can_process():
		var state_node := get_node_or_null(target_state)
		if verify_state(state_node):
			state_node._enter(false, null)

## Travel to a new State.
## Fails if there is no available Transition, unless do_force is true.
func travel_to(target_state: String, do_force := false):
	if can_process():
		if _current_state.name == target_state:
			_current_state.reinforced.emit()
		else:
			if !_current_state.travel_to(target_state) && do_force:
				force_state(target_state)

## Call a named Transition within the current State.
func call_trans(target_trans: String):
	if can_process():
		_current_state.call_trans(target_trans)
