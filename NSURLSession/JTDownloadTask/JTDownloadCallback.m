//
//  JTDownloadCallback.m
//  JTNetworkingDemo
//
//  Created by Admin on 10/14/13.
//  Copyright (c) 2013 nobuta. All rights reserved.
//

#import "JTDownloadCallback.h"
#import "JTDownloadTask.h"

@implementation JTDownloadCallback

+ (JTDownloadCallback *)callbackWithProgressHandler:(void (^)(JTDownloadTask *, long long, long long, long long))progressHandler successHandler:(void (^)(JTDownloadTask *))successHandler failHandler:(void (^)(JTDownloadTask *))failHandler
{
    return [[[JTDownloadCallback alloc] initWithProgressHandler:progressHandler successHandler:successHandler failHandler:failHandler] autorelease];
}

- (id)initWithProgressHandler:(void (^)(JTDownloadTask *, long long,long long, long long))progressHandler successHandler:(void (^)(JTDownloadTask *))successHandler failHandler:(void (^)(JTDownloadTask *))failHandler
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
    Block_release(self.successHandler);
    Block_release(self.failHandler);
    Block_release(self.progressHandler);
    [super dealloc];
}


@end
