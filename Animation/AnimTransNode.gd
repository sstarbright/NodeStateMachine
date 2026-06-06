class_name AnimTransNode
extends TransNode

## How long to transition for.
@export var transition_time := 0.0
## What point in animation time should this Transition start.
## If positive and non-zero, this will enable automatic transitioning based on the current position on animation timeline.
@export var transition_start := -1.0
## INTERNAL - Should the Transition happen automatically after a certain point in the animation?
var _transition_after_time := false

func _ready() -> void:
	super._ready()
	if transition_start > 0.0:
		_transition_after_time = true

func _process(_delta: float) -> void:
	if enabled:
		if auto_transition:
			if _transition_after_time:
				if state_machine.animation_player.current_animation_position >= transition_start || _try_advance():
					_switch_to()
			elif _try_advance():
				_switch_to()
		else:
			if _transition_after_time:
				if state_machine.animation_player.current_animation_position >= transition_start && _try_advance():
					_switch_to()
