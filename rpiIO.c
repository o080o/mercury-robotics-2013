

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>


static int fname (lua_State *L){
	// code here
	double a = luaL_checknumber(L,1); // takes the lua_state and which argument to return from the stack, starting with 1.
	return 0; // number of results returned on the stack
}

static const struct luaL_Reg rpiIO[] = {
	{"fname", fname},
	{NULL,NULL} // last item must be NULL,NULL to signify end of table.
};

int luaopen_rpiIO (lua_State *L){
	luaL_openlib(L, "rpiIO", rpiIO, 0);
	return 1;
}
