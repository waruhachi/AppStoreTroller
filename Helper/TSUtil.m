#include "TSUtil.h"

int fd_is_valid(int fd) {
	return fcntl(fd, F_GETFD) != -1 || errno != EBADF;
}

NSString* getNSStringFromFile(int fd) {
	char c;
	ssize_t num_read;
	NSMutableString* ms = [NSMutableString new];

	if(!fd_is_valid(fd)) return @"";

    while((num_read = read(fd, &c, sizeof(c)))) {
        [ms appendString:[NSString stringWithFormat:@"%c", c]];
		if(c == '\n') break;
	}

	return ms.copy;
}

void printMultilineNSString(NSString* stringToPrint) {
	NSCharacterSet* separator = [NSCharacterSet newlineCharacterSet];
	NSArray* lines = [stringToPrint componentsSeparatedByCharactersInSet:separator];

	for(NSString* line in lines) {
		NSLog(@"%@", line);
	}
}

int spawnRoot(NSString* path, NSArray* args, NSString** stdOut, NSString** stdErr) {
    NSMutableArray* argsM = args.mutableCopy ?: [NSMutableArray new];
	[argsM insertObject:path atIndex:0];

	NSUInteger argCount = [argsM count];
	char** argsC = (char**)malloc((argCount + 1)*  sizeof(char*));

	for (NSUInteger i = 0; i < argCount; i++) {
		argsC[i] = strdup([[argsM objectAtIndex:i] UTF8String]);
	}

	argsC[argCount] = NULL;

	posix_spawnattr_t attr;
	posix_spawnattr_init(&attr);

	posix_spawnattr_set_persona_np(&attr, 99, POSIX_SPAWN_PERSONA_FLAGS_OVERRIDE);
	posix_spawnattr_set_persona_uid_np(&attr, 0);
	posix_spawnattr_set_persona_gid_np(&attr, 0);

	posix_spawn_file_actions_t action;
	posix_spawn_file_actions_init(&action);

	int outErr[2];
	if(stdErr) {
		pipe(outErr);
		posix_spawn_file_actions_adddup2(&action, outErr[1], STDERR_FILENO);
		posix_spawn_file_actions_addclose(&action, outErr[0]);
	}

	int out[2];
	if(stdOut) {
		pipe(out);
		posix_spawn_file_actions_adddup2(&action, out[1], STDOUT_FILENO);
		posix_spawn_file_actions_addclose(&action, out[0]);
	}

	pid_t task_pid;
	int status = -200;
	int spawnError = posix_spawn(&task_pid, [path UTF8String], &action, &attr, (char* const*)argsC, NULL);
	posix_spawnattr_destroy(&attr);

	for (NSUInteger i = 0; i < argCount; i++) {
		free(argsC[i]);
	}
	free(argsC);

	if(spawnError != 0) {
		NSLog(@"posix_spawn error %d\n", spawnError);
		return spawnError;
	}

	__block volatile BOOL _isRunning = YES;

	NSMutableString* outString = [NSMutableString new];
	NSMutableString* errString = [NSMutableString new];

	dispatch_queue_t logQueue;
	dispatch_semaphore_t sema = 0;

	if(stdOut || stdErr) {
		logQueue = dispatch_queue_create("com.opa334.TrollStore.LogCollector", NULL);
		sema = dispatch_semaphore_create(0);

		int outPipe = out[0];
		int outErrPipe = outErr[0];

		__block BOOL outEnabled = (BOOL)stdOut;
		__block BOOL errEnabled = (BOOL)stdErr;

		dispatch_async(logQueue, ^{
			while(_isRunning) {
				@autoreleasepool {
					if(outEnabled) {
						[outString appendString:getNSStringFromFile(outPipe)];
					}

					if(errEnabled) {
						[errString appendString:getNSStringFromFile(outErrPipe)];
					}
				}
			}

			dispatch_semaphore_signal(sema);
		});
	}

	do {
	    if (waitpid(task_pid, &status, 0) != -1) {
			NSLog(@"Child status %d", WEXITSTATUS(status));
		} else {
			perror("waitpid");
			_isRunning = NO;

			return -222;
		}
	}   while (!WIFEXITED(status) && !WIFSIGNALED(status));

	_isRunning = NO;
	if(stdOut || stdErr) {
		if(stdOut) {
			close(out[1]);
		}

		if(stdErr) {
			close(outErr[1]);
		}

		// wait for logging queue to finish
		dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);

		if(stdOut) {
			*stdOut = outString.copy;
		}

		if(stdErr) {
			*stdErr = errString.copy;
		}
	}

	return WEXITSTATUS(status);
}

void enumerateProcessesUsingBlock(void (^enumerator)(pid_t pid, NSString* executablePath, BOOL* stop)) {
    static int maxArgumentSize = 0;

    if (maxArgumentSize == 0) {
        size_t size = sizeof(maxArgumentSize);

        if (sysctl((int[]){ CTL_KERN, KERN_ARGMAX }, 2, &maxArgumentSize, &size, NULL, 0) == -1) {
            perror("sysctl argument size");
            maxArgumentSize = 4096; // Default
        }
    }

    int count;
    size_t length;
    struct kinfo_proc* info;
    int mib[3] = { CTL_KERN, KERN_PROC, KERN_PROC_ALL};

    if (sysctl(mib, 3, NULL, &length, NULL, 0) < 0) {
        return;
    }

    if (!(info = malloc(length))) {
        return;
    }

    if (sysctl(mib, 3, info, &length, NULL, 0) < 0) {
        free(info);
        return;
    }

    count = length / sizeof(struct kinfo_proc);
    for (int i = 0; i < count; i++) {
        @autoreleasepool {
            pid_t pid = info[i].kp_proc.p_pid;
            if (pid == 0) {
                continue;
            }

            size_t size = maxArgumentSize;
            char* buffer = (char* )malloc(length);

            if (sysctl((int[]){ CTL_KERN, KERN_PROCARGS2, pid }, 3, buffer, &size, NULL, 0) == 0) {
                NSString* executablePath = [NSString stringWithCString:(buffer+sizeof(int)) encoding:NSUTF8StringEncoding];

                BOOL stop = NO;
                enumerator(pid, executablePath, &stop);

                if(stop) {
                    free(buffer);
                    break;
                }
            }

            free(buffer);
        }
    }

    free(info);
}

void killall(NSString* processName, BOOL softly) {
    enumerateProcessesUsingBlock(^(pid_t pid, NSString* executablePath, BOOL* stop) {
        if([executablePath.lastPathComponent isEqualToString:processName]) {
            if(softly) {
                kill(pid, SIGTERM);
            } else {
                kill(pid, SIGKILL);
            }
        }
    });
}
