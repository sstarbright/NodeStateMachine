class_name StateNode
extends Node

## Triggered when this State is entered.
signal entered(is_initial : bool)
## Triggered when this State is exited.
signal exited()
## Triggered when the State Machine tries to travel to this State while already current.
signal reinforced()

## Whether this State should be used or not. Avoid setting Process Mode for StateNode, and use this instead.
@export var enabled := true
## The State Machine associated with this State.
@onready var state_machine : StateMachine = get_parent()

## INTERNAL - Dictionary of States (and Transitions to Them) that this State can travel to.
var _state_transitions : Dictionary[String, Array]

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	child_entered_tree.connect(child_added)
	child_exiting_tree.connect(child_removed)
	
	for trans_node in get_children():
		if trans_node is TransNode:
			if !_state_transitions.has(trans_node.target_state.name):
				_state_transitions[trans_node.target_state.name] = []
			_state_transitions[trans_node.target_state.name].append(trans_node)

func child_added(child_node : Node):
	if child_node is TransNode:
		if !_state_transitions.has(child_node.target_state.name):
			_state_transitions[child_node.target_state.name] = []
		_state_transitions[child_node.target_state.name].append(child_node)

func child_removed(child_node : Node):
	if child_node is TransNode:
		if _state_transitions.has(child_node.target_state.name):
			var trans_idx := _state_transitions[child_node.target_state.name].find_custom(find_trans_by_name.bind(child_node))
			if trans_idx >= 0:
				_state_transitions[child_node.target_state.name].remove_at(trans_idx)

## INTERNAL - Used for filtering for specific named Transitions in this State's Transition Dictionary.
func find_trans_by_name(a : TransNode, b : TransNode) -> bool:
	return a.name == b.name

## INTERNAL - Enter this State and Exit the previous.
func _enter(is_initial : bool, trans_node : TransNode) -> bool:
	if trans_node:
		if !state_machine._current_state._exit(trans_node):
			return false
		state_machine._current_state = trans_node.target_state
	process_mode = Node.PROCESS_MODE_INHERIT
	state_machine.state_changed.emit(name)
	entered.emit(is_initial)
	return true

## INTERNAL - Exit this State.
func _exit(_trans_node : TransNode) -> bool:
	process_mode = Node.PROCESS_MODE_DISABLED
	exited.emit()
	return true

## INTERNAL - Switch from this State through a Transition.
func _switch_to(trans_node : TransNode):
	if can_process() && enabled:
		state_machine._switch_to(trans_node)

## Travel to a new State from this one.
func travel_to(target_state: String) -> bool:
	if can_process():
		if _state_transitions.has(target_state):
			for trans_node in _state_transitions[target_state]:
				if trans_node.trigger():
					return true
	return false

## Call a named Transition within this State.
func call_trans(target_trans: String):
	if can_process():
		var found_transition = get_node_or_null(target_trans)
		if found_transition is TransNode:
			found_transition.trigger()

## Enable this State.
func enable():
	enabled = true
	
## Enable this State.
func disable():
	enabled = false
