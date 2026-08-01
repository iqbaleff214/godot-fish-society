extends GutTest
## Fish-count performance check (TASKS.md 9.3): verify swim AI (task 3.2)
## stays cheap at the ~15-20 simultaneous fish budget documented in
## GDD § 10. Measures real Fish._process() cost across a real scene tree
## and real frame ticks — not a synthetic call-count assertion.
##
## NOTE: GUT (like any headless run) has no rendering server active, so
## this measures script/logic-side cost only (state machine tick + swim
## steering, which is pure CPU/script work with no GPU-dependent cost) —
## not real on-screen FPS on actual hardware. That needs a genuine windowed
## run on a representative low-end device to fully satisfy the DoD's
## literal wording; this is the automatable proxy for it.

const FISH_COUNT := 20
const SAMPLE_FRAMES := 120
const FRAME_BUDGET_MS_60FPS := 16.67


func test_twenty_fish_process_within_60fps_budget() -> void:
	var tank: Tank = add_child_autofree(load("res://scenes/tank/Tank.tscn").instantiate())
	var fish_scene: PackedScene = load("res://scenes/tank/Fish.tscn")
	var all_species := FishSpecies.load_all()
	assert_true(all_species.size() > 0, "expected starter fish species to exist for this test")

	var fish_list: Array[Fish] = []
	for i in range(FISH_COUNT):
		var fish: Fish = fish_scene.instantiate()
		tank.get_contents_node().add_child(fish)
		fish.set_tank(tank)
		fish.setup(all_species[i % all_species.size()])
		fish_list.append(fish)
		# no separate autofree(fish) — each fish is a child of tank (already
		# add_child_autofree'd above), so it's freed via the normal parent-
		# child cascade at test teardown; freeing it again would double-free.

	assert_eq(fish_list.size(), FISH_COUNT)

	# Let the state machine actually engage swim behavior before measuring.
	await wait_process_frames(5)

	var start_usec := Time.get_ticks_usec()
	await wait_process_frames(SAMPLE_FRAMES)
	var elapsed_usec := Time.get_ticks_usec() - start_usec

	var avg_frame_ms := (elapsed_usec / 1000.0) / SAMPLE_FRAMES
	gut.p("20-fish avg frame time: %.4f ms (60fps budget: %.2f ms)" % [avg_frame_ms, FRAME_BUDGET_MS_60FPS])

	# All 20 fish should still be in the water (swim steering, task 3.2,
	# clamps position every frame) after a couple seconds of real ticking.
	var b := tank.get_water_bounds()
	for fish in fish_list:
		assert_true(b.has_point(fish.position), "fish drifted outside water bounds")

	assert_true(avg_frame_ms < FRAME_BUDGET_MS_60FPS, "20 fish should process well within a 60fps frame budget (measured %.4f ms)" % avg_frame_ms)
