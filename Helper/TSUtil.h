#include <spawn.h>
#include <libroot.h>
#include <sys/sysctl.h>
#include <mach-o/dyld.h>
#include <Foundation/Foundation.h>

@import Foundation;

extern void killall(NSString* processName, BOOL softly);
extern int spawnRoot(NSString* path, NSArray* args, NSString** stdOut, NSString** stdErr);

#define POSIX_SPAWN_PERSONA_FLAGS_OVERRIDE 1
extern int posix_spawnattr_set_persona_gid_np(const posix_spawnattr_t* __restrict, uid_t);
extern int posix_spawnattr_set_persona_uid_np(const posix_spawnattr_t* __restrict, uid_t);
extern int posix_spawnattr_set_persona_np(const posix_spawnattr_t* __restrict, uid_t, uint32_t);
