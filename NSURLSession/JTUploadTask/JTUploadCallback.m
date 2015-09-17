//
//  JTUploadCallback.m
//  JTNetworkingDemo
//
//  Created by Admin on 10/14/13.
//  Copyright (c) 2013 nobuta. All rights reserved.
//

#import "JTUploadCallback.h"
#import "JTUploadTask.h"

@implementation JTUploadCallback

+ (JTUploadCallback *)callbackWithProgressHandler:(void (^)(JTUploadTask *,long long, long long))progressHandler successHandler:(void (^)(JTUploadTask *))successHandler failHandler:(void (^)(JTUploadTask *))failHandler
{
    return [[[JTUploadCallback alloc] initWithProgressHandler:progressHandler successHandler:successHandler failHandler:failHandler] autorelease];
}

- (id)initWithProgressHandler:(void (^)(JTUploadTask *,long long, long long))progressHandler successHandler:(void (^)(JTUploadTask *))successHandler failHandler:(void (^)(JTUploadTask *))failHandler
{
    if(self = [super init])
    {
        self.progressHandler = progressHandler;
        self.successHandler = successHandler;
        self.failHandler = failHandler;
    }
    
    return self;
}

- (void)dealloc
{
    self.target = nil;
    Block_release(self.successHandler);
    Block_release(self.failHandler);
    Block_release(self.progressHandler);
    [super dealloc];
}

@end
