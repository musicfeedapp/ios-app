/*
 
 Copyright (C) 2011 GUI Cocoa, LLC.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 */

#import <execinfo.h>
#import <fcntl.h>
#import <unistd.h>
#import <sys/sysctl.h>
#import <mach/task.h>
#import <mach/task_info.h>
#import <mach/mach_init.h>

#import "EBNotifierFunctions.h"
#import "EBNotice.h"

#import "EBNotifier.h"

// handled signals
int ht_signals_count = 6;
int ht_signals[] = {
	SIGABRT,
	SIGBUS,
	SIGFPE,
	SIGILL,
	SIGSEGV,
	SIGTRAP
};

// internal function prototypes
void ht_handle_signal(int, siginfo_t *, void *);
void ht_handle_exception(NSException *);

#pragma mark crash time methods
void ht_handle_signal(int signal, siginfo_t *info, void *context) {
    
  // stop handler
  EBNotifierStopSignalHandler();
    
  // get file handle
  int fd = EBNotifierOpenNewNoticeFile(eb_signal_info.notice_path, EBNotifierSignalNoticeType);
    
  // write if we have a file
  if (fd > -1) {
		
    // signal
    write(fd, &signal, sizeof(int));

		// backtrace
		int count = 128;
		void *frames[count];
		count = backtrace(frames, count);
		backtrace_symbols_fd(frames, count, fd);
		
		// close
    close(fd);

  }
	
	// re raise
	raise(signal);
}

void ht_handle_exception(NSException *exception) {
  EBNotifierStopSignalHandler();
  EBNotifierStopExceptionHandler();
  [EBNotifier logException:exception];
}

#pragma mark - notice file methods
int EBNotifierOpenNewNoticeFile(const char *path, int type) {
  int fd = open(path, O_WRONLY | O_CREAT, S_IREAD | S_IWRITE);
  if (fd > -1) {
        
    // file version
    write(fd, &EBNotifierNoticeVersion, sizeof(int));

    // file bype
    write(fd, &type, sizeof(int));

    // notice payload
    write(fd, &eb_signal_info.notice_payload_length, sizeof(unsigned long));
    write(fd, eb_signal_info.notice_payload, eb_signal_info.notice_payload_length);

    // user data
    write(fd, &eb_signal_info.user_data_length, sizeof(unsigned long));
    write(fd, eb_signal_info.user_data, eb_signal_info.user_data_length);
  }
  return fd;
}

#pragma mark - modify handler state
void EBNotifierStartExceptionHandler(void) {
  NSSetUncaughtExceptionHandler(&ht_handle_exception);
}

void EBNotifierStartSignalHandler(void) {
  for (int i = 0; i < ht_signals_count; i++) {
    int signal = ht_signals[i];
		struct sigaction action;
		sigemptyset(&action.sa_mask);
		action.sa_flags = SA_SIGINFO;
		action.sa_sigaction = ht_handle_signal;
		if (sigaction(signal, &action, NULL) != 0) {
      EBLog(@"Unable to register signal handler for %s", strsignal(signal));
		}
	}
}

void EBNotifierStopExceptionHandler(void) {
  NSSetUncaughtExceptionHandler(NULL);
}

void EBNotifierStopSignalHandler(void) {
	for (int i = 0; i < ht_signals_count; i++) {
		int signal = ht_signals[i];
		struct sigaction action;
		sigemptyset(&action.sa_mask);
		action.sa_handler = SIG_DFL;
		sigaction(signal, &action, NULL);
	}
}

#pragma mark - Info.plist accessors
NSString *EBNotifierApplicationVersion(void) {
  static NSString *version = nil;
  static dispatch_once_t token;
  dispatch_once(&token, ^{
    NSString *bundleVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString *versionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];

    if (bundleVersion != nil && versionString != nil) {
      version = [[NSString alloc] initWithFormat:@"%@ (%@)", versionString, bundleVersion];
    } else if (bundleVersion != nil) {
      version = [bundleVersion copy];
    } else if (versionString != nil) {
      version = [versionString copy];
    }
  });
  return version;
}

NSString *EBNotifierApplicationName(void) {
  static NSString *name = nil;
  static dispatch_once_t token;
  dispatch_once(&token, ^{
    NSString *displayName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    NSString *bundleName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    NSString *identifier = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
    if (displayName != nil) {
      name = [displayName copy];
    } else if (bundleName != nil) {
      name = [bundleName copy];
    } else if (identifier != nil) {
      name = [identifier copy];
    }
  });
  return name;
}

#pragma mark - platform accessors
NSString *EBNotifierOperatingSystemVersion(void) {
  static NSString *version = nil;
  static dispatch_once_t token;
  dispatch_once(&token, ^{
#if TARGET_IPHONE_SIMULATOR
    version = [[[UIDevice currentDevice] systemVersion] copy];
#else
    version = [[[NSProcessInfo processInfo] operatingSystemVersionString] copy];
#endif
  });
  return version;
}

NSString *EBNotifierMachineName(void) {
#if TARGET_IPHONE_SIMULATOR
  return @"iPhone Simulator";
#else
  static NSString *name = nil;
  static dispatch_once_t token;
  dispatch_once(&token, ^{
    size_t size = 256;
    char *machine = malloc(size);
#if TARGET_OS_IPHONE
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
#else
    sysctlbyname("hw.model", machine, &size, NULL, 0);
#endif
    name = [[NSString alloc] initWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
  });
  return name;
#endif
}
NSString *EBNotifierPlatformName(void) {
#if TARGET_IPHONE_SIMULATOR || !TARGET_OS_IPHONE
  return EBNotifierMachineName();
#else
  static NSString *platform = nil;
  static dispatch_once_t token;
  dispatch_once(&token, ^{
    NSString *machine = EBNotifierMachineName();

      // iphone
    if ([machine isEqualToString:@"iPhone1,1"]) { platform = @"iPhone"; }
    else if ([machine isEqualToString:@"iPhone1,2"]) { platform = @"iPhone 3G"; }
    else if ([machine isEqualToString:@"iPhone2,1"]) { platform = @"iPhone 3GS"; }
    else if ([machine isEqualToString:@"iPhone3,1"]) { platform = @"iPhone 4 (GSM)"; }
    else if ([machine isEqualToString:@"iPhone3,3"]) { platform = @"iPhone 4 (CDMA)"; }
    else if ([machine isEqualToString:@"iPhone4,1"]) { platform = @"iPhone 4S"; }

      // ipad
    else if ([machine isEqualToString:@"iPad1,1"]) { platform = @"iPad"; }
    else if ([machine isEqualToString:@"iPad2,1"]) { platform = @"iPad 2 (WiFi)"; }
    else if ([machine isEqualToString:@"iPad2,2"]) { platform = @"iPad 2 (GSM)"; }
    else if ([machine isEqualToString:@"iPad2,3"]) { platform = @"iPad 2 (CDMA)"; }

      // ipod
    else if ([machine isEqualToString:@"iPod1,1"]) { platform = @"iPod Touch"; }
    else if ([machine isEqualToString:@"iPod2,1"]) { platform = @"iPod Touch (2nd generation)"; }
    else if ([machine isEqualToString:@"iPod3,1"]) { platform = @"iPod Touch (3rd generation)"; }
    else if ([machine isEqualToString:@"iPod4,1"]) { platform = @"iPod Touch (4th generation)"; }

      // unknown
    else { platform = machine; }
  });
  return platform;
#endif
}

#pragma mark - call stack functions
NSArray *EBNotifierParseCallStack(NSArray *callStack) {
  static NSString *pattern = @"^(\\d+)\\s+(\\S.*?)\\s+((0x[0-9a-f]+)\\s+.*)$";
  NSMutableArray *parsed = [NSMutableArray arrayWithCapacity:[callStack count]];
  [callStack enumerateObjectsUsingBlock:^(id line, NSUInteger idx, BOOL *stop) {
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                                options:(NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators)
                                                                                  error:nil];

    NSArray *components = [expression matchesInString:line
                                              options:NSMatchingReportCompletion
                                                range:NSMakeRange(0, [line length])];

    NSMutableArray *frame = [NSMutableArray arrayWithCapacity:[components count]];
    [components enumerateObjectsUsingBlock:^(id result, NSUInteger index, BOOL *s) {
      for (NSUInteger i = 0; i < [result numberOfRanges]; i++) {
        [frame addObject:[line substringWithRange:[result rangeAtIndex:i]]];
      }
    }];
    [parsed addObject:frame];
  }];
  return parsed;
}

NSString *EBNotifierActionFromParsedCallStack(NSArray *callStack, NSString *executable) {
  NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id obj, NSDictionary *bindings) {
    if (![[(NSArray *)obj objectAtIndex:2] isEqualToString:executable]) { return NO; }
    NSRange range = [[(NSArray *)obj objectAtIndex:3] rangeOfString:@"ht_handle_signal"];
    return range.location == NSNotFound;
  }];

  NSArray *matching = [callStack filteredArrayUsingPredicate:predicate];
  if ([matching count]) {
    return [(NSArray *)[matching objectAtIndex:0] objectAtIndex:3];
  } else {
    return nil;
  }
}

#pragma mark - memory usage
NSString *EBNotifierResidentMemoryUsage(void) {
  struct task_basic_info basic;
  mach_msg_type_number_t count = TASK_BASIC_INFO_COUNT;
  if (task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&basic, &count) == KERN_SUCCESS) {
    vm_size_t b = basic.resident_size;
    double mb = (float)b / 1048576.0;
    return [NSString stringWithFormat:@"%0.2f MB", mb];
  } else {
    return @"Unknown";
  }
}

NSString *EBNotifierVirtualMemoryUsage(void) {
  struct task_basic_info basic;
  mach_msg_type_number_t count = TASK_BASIC_INFO_COUNT;
  if (task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&basic, &count) == KERN_SUCCESS) {
    vm_size_t b = basic.virtual_size;
    double mb = (float)b / 1048576.0;
    return [NSString stringWithFormat:@"%0.2f MB", mb];
  } else {
    return @"Unknown";
  }
}

#pragma mark - view controller
NSString *EBNotifierCurrentViewController(void) {
    
  // assert
  NSCAssert([NSThread isMainThread], @"This function must be called on the main thread");
    
	// view controller to inspect
	UIViewController *rootController = nil;
    
	// try getting view controller from notifier delegate
	id<EBNotifierDelegate> delegte = [EBNotifier delegate];
	if ([delegte respondsToSelector:@selector(rootViewControllerForNotice)]) {
		rootController = [delegte rootViewControllerForNotice];
	}
	
	// try getting view controller from window
	UIApplication *app = [UIApplication sharedApplication];
	UIWindow *keyWindow = [app keyWindow];
	if (rootController == nil && [keyWindow respondsToSelector:@selector(rootViewController)]) {
		rootController = [keyWindow rootViewController];
	}
	
	// if we don't have a controller yet, give up
	if (rootController == nil) {
		return nil;
	}
	
	// call method to get class name
	return EBNotifierVisibleViewControllerFromViewController(rootController);
}

NSString *EBNotifierVisibleViewControllerFromViewController(UIViewController *controller) {
    
  // assert
  NSCAssert([NSThread isMainThread], @"This function must be called on the main thread");
	
	if ([controller isKindOfClass:[UITabBarController class]]) {
      // tab bar controller
		UIViewController *visibleController = [(UITabBarController *)controller selectedViewController];
		return EBNotifierVisibleViewControllerFromViewController(visibleController);
	} else if ([controller isKindOfClass:[UINavigationController class]]) {
			// navigation controller
    UIViewController *visibleController = [(UINavigationController *)controller visibleViewController];
		return EBNotifierVisibleViewControllerFromViewController(visibleController);
	} else {
			// other type
    return NSStringFromClass([controller class]);
	}
}

#pragma mark - localization

NSString *EBLocalizedString(NSString* key) {
  return [[NSBundle mainBundle] localizedStringForKey:key value:key table:nil];
}
