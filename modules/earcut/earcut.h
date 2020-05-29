#ifndef GODOT_EARCUT_H
#define GODOT_EARCUT_H

#include "core/reference.h"
#include "include/mapbox/earcut.hpp"
#include <array>

// using N = uint32_t;

class Earcut : public Object {

	GDCLASS(Earcut, Object);

	static Earcut *singleton;

protected:
	static void _bind_methods();

public:

	static Earcut *get_singleton();

	Vector<int> execute(const Vector<Vector2> &p_polygon, const Vector<int> &p_holes);

	Earcut();
};

#endif // GODOT_EARCUT_H
