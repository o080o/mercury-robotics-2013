

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
#include <wiringPi.h>

static int fname (lua_State *L){
	double a = luaL_checknumber(L,1); // takes the lua_state and which argument to return from the stack, starting with 1.

	// code here
	a=a*123764;
	a=funcrtrion(a);

	// push return values onto the stack and return
	lua_pushnumber(L, a);
	return 1; // number of results returned on the stack
}




static const struct luaL_Reg rpiIO[] = {
	{"fname", fname},
	{NULL,NULL} // last item must be NULL,NULL to signify end of table.
};

int luaopen_rpiIO (lua_State *L){
	// setup code here.
	wiringPiSetup();

	luaL_openlib(L, "rpiIO", rpiIO, 0);
	return 1;
}
