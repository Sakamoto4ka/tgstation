/*
	Used with the various stat variables (mob, machines)
*/

//mob/var/stat things
#define CONSCIOUS 0
#define SOFT_CRIT 1
#define UNCONSCIOUS 2
#define HARD_CRIT 3
#define DEAD 4

//Maximum healthiness an individual can have
#define MAX_SATIETY 600

// bitflags for machine stat variable
#define BROKEN (1<<0)
#define NOPOWER (1<<1)
#define MAINT (1<<2) // under maintaince
#define EMPED (1<<3) // temporary broken by EMP pulse

//ai power requirement defines
#define POWER_REQ_ALL 1
#define POWER_REQ_CLOCKCULT 2
