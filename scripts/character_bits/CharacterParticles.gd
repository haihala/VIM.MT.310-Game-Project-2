extends Node

func land():
	$LandingParticles.restart()

func start_running():
	$RunningParticles.emitting = true

func stop_running():
	$RunningParticles.emitting = false
