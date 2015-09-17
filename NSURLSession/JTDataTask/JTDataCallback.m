//
//  JTDataCallback.m
//  JTNetworkingDemo
//
//  Created by Admin on 10/14/13.
//  Copyright (c) 2013 nobuta. All rights reserved.
//

#import "JTDataCallback.h"
#import "JTDataTask.h"

@implementation JTDataCallback

+ (JTDataCallback *)callbackWithTarget:(id)target successHandler:(void (^)(JTDataTask *))successHandler failHandler:(void (^)(JTDataTask *))failHandler
{
    return [[[JTDataCallback alloc] initWithTarget:target successHandler:successHandler failHandler:failHandler] autorelease];
}

- (id)initWithTarget:(id)target successHandler:(void (^)(JTDataTask *))successHandler failHandler:(void (^)(JTDataTask *))failHandler
{
    if(self = [super init])
    {
        self.target = target;
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
    [super dealloc];
}


@end
