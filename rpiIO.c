

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
#include <wiringPi.h>
#include <softPwm.h>

const int SERVO_PIN = 9;
const int PING_PIN = 7;
const int CW = 0;
const int CCW = 1;
const int STOP = 2;

static int fname (lua_State *L){
	// code here
	double a = luaL_checknumber(L,1); // takes the lua_state and which argument to return from the stack, starting with 1.
	return 0; // number of results returned on the stack
}

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

static const struct luaL_Reg rpiIO[] = {
	{"fname", fname},
	{NULL,NULL} // last item must be NULL,NULL to signify end of table.
};

int luaopen_rpiIO (lua_State *L){
	luaL_openlib(L, "rpiIO", rpiIO, 0);
	return 1;
}
