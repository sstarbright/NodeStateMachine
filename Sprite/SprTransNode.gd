class_name SprTransNode
extends TransNode

## The frame to the target State's animation on.
@export var target_start_frame := 0
## The amount of progress to start the target State's first frame on.
@export var target_start_progress := 0.0

## What frame in the animation should this Transition start.
## If positive and non-zero, this will enable automatic transitioning based on current animation frame.
@export var transition_start_frame := -1
## What point in specified frame should this Transition start.
@export var transition_start_progress := 0.0

## INTERNAL - Should the Transition happen automatically after a certain point in the animation?
var _transition_after_time := false

func _ready() -> void:
	super._ready()
	if transition_start_frame > 0:
		_transition_after_time = true

func _process(_delta: float) -> void:
	if enabled:
		if auto_transition:
			if _transition_after_time:
				if state_machine.animator_node.frame >= transition_start_frame && state_machine.animator_node.frame_progress >= transition_start_progress || _try_advance():
					_switch_to()
			elif _try_advance():
				_switch_to()
		else:
			if _transition_after_time:
				if state_machine.animator_node.frame >= transition_start_frame && state_machine.animator_node.frame_progress >= transition_start_progress && _try_advance():
					_switch_to()
