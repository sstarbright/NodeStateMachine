class_name SprBtwTransNode
extends SprTransNode

## The name of the Animation to use as a transition.
@export var transition_animation : String
## How much to scale the Animation when it is used.
@export var transition_speed : float = 1.0
## Whether other transitions can interrupt this one.
@export var allow_interrupt := true
@export var interrupt_whitelist : Dictionary[StringName, bool]

signal finished
