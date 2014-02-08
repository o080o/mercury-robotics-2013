

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
#include <wiringPi.h>
#include <time.h>


static int fname (lua_State *L){
	// code here
	double a = luaL_checknumber(L,1); // takes the lua_state and which argument to return from the stack, starting with 1.
	return 0; // number of results returned on the stack
}

// Reads the distance measurement from a single PING sensor.
// Returns a double representing the distance in cm to the nearest object.
static int readPing(int pin) {
	double distance = 0;
	int startTime = 0;
	int endTime = 0;
	int elapsed = 0;
	pinMode(pin, OUTPUT);
	digitalWrite(pin, 1);
	delay(5); // 5 ms
	digitalWrite(pin, 0);
	pinMode(pin, INPUT);
	while(digitalRead(pin) == 0) {
		// Do nothing; wait for ping signal to start
	}
	startTime = clock();
	while(digitalRead(pin) == 1) {
		// Do nothing; wait for ping signal to end
	}
	endTime = clock();
	elapsed = endTime - startTime; // Time elapsed in clock cycles
	elapsed = elapsed / (CLOCKS_PER_SEC / 1000000) // Convert to microseconds
	distance = (34029.0 * elapsed) / 1000000 // Convert to centimeters
	return distance
}

// Sends one pulse to the servo. Options are full speed either direction or stop.
static void servoPulse(int pin, int direction) {
	pinMode(pin, OUTPUT); // If we set all pin modes elsewhere, this can be removed
	digitalWrite(pin, 1);
	switch(direction) {
		case 0: delayMicroseconds(1000);
				break;
		case 1: delayMicroseconds(2000);
				break;
		case 2: delayMicroseconds(1500);
				break;
		default: delayMicroseconds(1500); // Direction pin invalid, stop servo
	}
	digitalWrite(pin, 0);
}

static const struct luaL_Reg rpiIO[] = {
	{"fname", fname},
	{NULL,NULL} // last item must be NULL,NULL to signify end of table.
};

int luaopen_rpiIO (lua_State *L){
	luaL_openlib(L, "rpiIO", rpiIO, 0);
	return 1;
}
