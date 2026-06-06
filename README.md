# NodeStateMachine
Node-based State Machine for Godot

## Basic State Machine
### StateMachine
- Manages States automatically
- Has Advance Expressions
  - Feel free to set any node you like as the Advance Node
  - Advance Node's data can be queried in Advance Expressions, just like Godot's native Animation State Machines
  - Defaults to the StateMachine, if you want to do a version closer to Godot's native solution
- Has a Signal for when State changes
### StateNode
- Manages an individual State
- Has Signals for when the State is entered, exited, or reinforced
### TransNode
- Manages Transitioning to new States
- Make it the child of the starting State, and set the Target State
- Has an Advance Expression
  - Robust, can be used to either:
    - Automatically transition (Auto Transition) when the conditions are met
    - Allow or disallow transition when triggered by other means

## Animation Player State Machine
### AnimStateMachine
- Has all of StateMachine's features
- Must set a target AnimationPlayer
- Children must be AnimStateNode
### AnimStateNode
- Has all of StateNode's features
- Must set a target Animation Name (AnimationLibrary path must be included)
- Can set Animation playback speed
### AnimTransNode
- Has all of TransNode's features
- Can set a Transition Time, for how long to blend between source and target Animations
- Can set a Transition Start, to declare if and when the transition should happen automatically, at a certain point in the Animation Timeline
    - If Auto Transition is disabled, the Advance Expression can be used to prevent a Transition Start, if conditions are not met

## Animated Sprite State Machine
### SprStateMachine
- Has all of StateMachine's features
- Must set a target Animator (Either AnimationSprite2D or 3D)
- Children must be SprStateNode
### SprStateNode
- Has all of StateNode's features
- Must set a target Animation Name
- Can set Animation playback speed
### SprTransNode
- Has all of TransNode's features
- Can set a Transition Start (for both Sprite Frame Index and Sprite Frame Progress), to declare if and when the transition should happen automatically, at a certain point in the Animation Timeline
    - If Auto Transition is disabled, the Advance Expression can be used to prevent a Transition Start, if conditions are not met

## TO-DO
- [x] Support for 2D/3D animated sprites
- [ ] Allow for changing the Advance Expressions at runtime
- [ ] In-editor animation and transition previews
