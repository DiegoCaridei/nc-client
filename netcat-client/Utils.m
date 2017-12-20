//
//  Utils.m
//  netcat-client
//
//  Created by vgm on 12/20/17.
//  Copyright © 2017 vgmoose. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSTask.h"

@interface NSObject (KVOHelper)

- (nullable NSString *)tryLaunchTask:(NSTask *) task;

@end

@implementation NSObject (KVOHelper)


- (nullable NSString *)tryLaunchTask:(NSTask *) task {
	NSString *result = @"";
	@try {
		[task launch];
	}
	@catch (NSException *exception) {
		result = exception.reason;
	}
	return result;
}

@end
