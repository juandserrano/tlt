extends Node

const DEFAULT_TILE_SIZE: float = 0.58

func axial_to_world(q: int, r: int) -> Vector3:
	var x = DEFAULT_TILE_SIZE * (sqrt(3.0) * q + sqrt(3.0)/2.0 * r)
	var z = DEFAULT_TILE_SIZE * (3.0/2.0 * r)
	return Vector3(x, 0, z)
