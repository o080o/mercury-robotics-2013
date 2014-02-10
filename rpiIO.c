

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
#include <wiringPi.h>
//<<<<<<< HEAD
#include <softPwm.h>

const int SERVO_PIN = 9;
const int PING_PIN = 7;
const int CW = 0;
const int CCW = 1;
const int STOP = 2;


//=======
//>>>>>>> 93a7702f328b8f7f96f044bd611560355e68b3c9

//<<<<<<< HEAD
// Reads the distance measurement from a single PING sensor.
// Returns a double representing the distance in cm to the nearest object.
// Returns -1.0 if an error occurs.
double readPing(int pin) {
	double distance = 0;
	int startTime = 0;
	int endTime = 0;
	int elapsed = 0;
	int timeout = 0;
	pinMode(pin, OUTPUT);
	digitalWrite(pin, 1);
	delayMicroseconds(5);
	digitalWrite(pin, 0);
	pinMode(pin, INPUT);
	pullUpDnControl(pin, PUD_DOWN);
	timeout = micros();
	while(digitalRead(pin) == 0) {
		// Wait for return signal to start, timeout 100 ms
		if(micros() - timeout > 100000) {
			return -1.0; // Timeout; return error
		}
	}
	startTime = micros();
	while(digitalRead(pin) == 1) {
		// Wait for return signal to end, timeout 100ms
		if(micros() - timeout > 100000) {
			return -1.0; // Timeout; return error
		}
	}
	endTime = micros();
	elapsed = endTime - startTime; // Time elapsed in us
	elapsed = elapsed / 2;
	distance = (34029.0 * elapsed) / 1000000; // Convert to centimeters
	return distance;
}

// Sets the software PWM for the servo. Options are full speed CW, full speed CCW,
// or stop.
void setServo(int pin, int direction) {
	switch(direction) {
		case 0: softPwmWrite(pin, 10);
				break;
		case 1: softPwmWrite(pin, 20);
				break;
		case 2: softPwmWrite(pin, 0);
				break;
		default: softPwmWrite(pin, 0); // Direction invalid; stop servo
	}
}

// Initializes the software PWM for the servo.
void initServo(int pin) {
	softPwmCreate(pin, 0, 200);
}
//=======


//>>>>>>> 93a7702f328b8f7f96f044bd611560355e68b3c9
/*
	Begin Lua wrapper section. Every callable C function must be wrapped
	in order to be called from Lua code.
*/

//template function
static int fname (lua_State *L){
	double a = luaL_checknumber(L,1); // takes the lua_state and which argument to return from the stack, starting with 1.

	// code here
	a=a*123764;
	//a=funcrtrion(a);

	// push return values onto the stack and return
	lua_pushnumber(L, a);
	return 1; // number of results returned on the stack
}

// Lua wrapper for readPing
static int LreadPing (lua_State *L){
	double pin = lua_checknumber(L,1); // pop args off stack
	double retval = readPing(pin);     // execute function
	if (retval==-1){                   // test for error conditions
		lua_error("PING sensor timeout!");
	}
	lua_pushnumber(L, retval);         // push return values back to stack
	return 1;                          // indicate # of return values
}

// Lua wrapper for readPing
static int LsetServo (lua_State *L){
	double pin = lua_checknumber(L,1);
	double dir = lua_checknumber(L,2);
	setServo(pin,dir);
	return 0;
}

// Lua wrapper for readPing
static int LinitServo (lua_State *L){
	double pin = lua_checknumber(L,1); 
	initServo(pin);
	return 0;
}

// Table structure containing all the wrapper functinos. Any new functions need
// to be added in this table.
static const struct luaL_Reg rpiIO[] = {
	{"fname", fname},
	{"readPing", LreadPing},
	{"setServo", LsetServo},
	{"initServo", LinitServo},
	{NULL,NULL} // last item must be NULL,NULL to signify end of table.
};

// this functino is called to register the rpiIO table of functions. 
int luaopen_rpiIO (lua_State *L){
	// setup code here.
	wiringPiSetup();

	luaL_openlib(L, "rpiIO", rpiIO, 0);
	return 1;
}
