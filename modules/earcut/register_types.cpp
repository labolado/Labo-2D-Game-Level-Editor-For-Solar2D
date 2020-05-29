#include "core/engine.h"
#include "register_types.h"
#include "earcut.h"

static Earcut *earcut = NULL;

void register_earcut_types() {
	ClassDB::register_class<Earcut>();
	earcut = memnew(Earcut);
	Engine::get_singleton()->add_singleton(Engine::Singleton("Earcut", Earcut::get_singleton()));
}

void unregister_earcut_types() {
	// nothing to do here
	memdelete(earcut);
}
