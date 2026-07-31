extends GutTest
## Unit tests for DecorationPlacement overlap detection (TASKS.md 2.3).


func test_rects_overlap_true_for_overlapping() -> void:
	var a := Rect2(0, 0, 10, 10)
	var b := Rect2(5, 5, 10, 10)
	assert_true(DecorationPlacement.rects_overlap(a, b))


func test_rects_overlap_false_for_non_overlapping() -> void:
	var a := Rect2(0, 0, 10, 10)
	var b := Rect2(20, 20, 10, 10)
	assert_false(DecorationPlacement.rects_overlap(a, b))


func test_rects_overlap_false_for_edge_touching() -> void:
	var a := Rect2(0, 0, 10, 10)
	var b := Rect2(10, 0, 10, 10)
	assert_false(DecorationPlacement.rects_overlap(a, b))


func test_is_valid_placement_rejects_when_any_sibling_overlaps() -> void:
	var candidate := Rect2(0, 0, 10, 10)
	var others: Array[Rect2] = [Rect2(50, 50, 5, 5), Rect2(5, 5, 10, 10)]
	assert_false(DecorationPlacement.is_valid_placement(candidate, others))


func test_is_valid_placement_accepts_when_no_sibling_overlaps() -> void:
	var candidate := Rect2(0, 0, 10, 10)
	var others: Array[Rect2] = [Rect2(50, 50, 5, 5), Rect2(-20, -20, 5, 5)]
	assert_true(DecorationPlacement.is_valid_placement(candidate, others))


func test_is_valid_placement_true_with_no_others() -> void:
	var candidate := Rect2(0, 0, 10, 10)
	var others: Array[Rect2] = []
	assert_true(DecorationPlacement.is_valid_placement(candidate, others))
