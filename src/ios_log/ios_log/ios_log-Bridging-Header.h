//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//


typedef void (*swift_callback_message)(int address, const char *);
typedef void (*swift_callback_connect)(int address, const char *);
typedef void (*swift_callback_disconnect)(const char *);

void start(swift_callback_message c1, swift_callback_connect c2, swift_callback_disconnect c3);
