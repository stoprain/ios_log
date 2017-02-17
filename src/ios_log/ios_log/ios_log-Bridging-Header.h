//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

typedef void (*swift_callback)(const char *);

void start(swift_callback callback);
