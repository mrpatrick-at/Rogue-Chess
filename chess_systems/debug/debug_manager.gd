extends RefCounted
## enums
## consts
## exports
## public vars
## private vars
## onready vars
# obj_ for node refrences
## built-in override methods
## public methods

static func end_timer(time_before:float) -> float: # Returns time elapsed in ms
	var time_after:float = Time.get_ticks_usec()
	var msec_elapsed:float = (time_after - time_before) / 1000
	return msec_elapsed



## private methods
