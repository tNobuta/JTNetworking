//
//  JTUploadTask.m
//  JTNetworkingDemo
//
//  Created by Admin on 10/14/13.
//  Copyright (c) 2013 nobuta. All rights reserved.
//

#import "JTUploadTask.h"

static NSURLSession *UploadTaskURLSession;

@implementation JTUploadTask
{
    NSMutableURLRequest         *_request;
    NSURLSessionUploadTask      *_task;
    NSTimeInterval              _lastRecordTime;
    NSTimeInterval              _totalRecordTime;
    NSTimeInterval              _totalTickTime;
}

@synthesize internalTask = _task;

+ (void)setURLSession:(NSURLSession *)URLSession
{
    UploadTaskURLSession = URLSession;
}

+ (JTUploadTask *)taskWithURL:(NSString *)URL fromFile:(NSString *)filePath callback:(JTUploadCallback *)callback
{
    return [[[JTUploadTask alloc] initWithURL:URL fromFile:filePath callback:callback] autorelease];
}

+ (JTUploadTask *)restoreTaskWithURLSessionUploadTask:(NSURLSessionUploadTask *)task callback:(JTUploadCallback *)callback
{
    return [[[JTUploadTask alloc] restoreWithURLSessionUploadTask:task callback:callback] autorelease];
}

- (id)initWithURL:(NSString *)URL fromFile:(NSString *)filePath callback:(JTUploadCallback *)callback
{
    if(self = [super init])
    {
        self.URL = URL;
        self.callback = callback;
        _request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URL]];
        _task = [[UploadTaskURLSession uploadTaskWithRequest:_request fromFile:[NSURL fileURLWithPath:filePath]] retain];
    }
    
    return self;
}

- (id)restoreWithURLSessionUploadTask:(NSURLSessionUploadTask *)task callback:(JTUploadCallback *)callback
{
    if(self = [super init])
    {
        self.URL = task.originalRequest.URL.absoluteString;
        self.callback = callback;
        _task = [task retain];
    }
    
    return self;
}

- (void)dealloc
{
    [_task release];
    self.URL = nil;
    self.callback = nil;
    self.error = nil;
    [super dealloc];
}

- (void)start
{
    if(_task)
    {
        [_task resume];
    }
}

- (void)pause
{
    if(_task)
    {
        [_task suspend];
    }
}

- (void)resume
{
    if(_task)
    {
        [_task resume];
    }
}

- (void)cancel
{
    if(_task)
    {
        [_task cancel];
    }
}

- (void)recordBandwidthUsage
{
    if(_lastRecordTime == 0)
    {
        _lastRecordTime = [[NSDate date] timeIntervalSince1970];
    }
    else
    {
        NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
        NSTimeInterval tickTime =  currentTime - _lastRecordTime;
        _lastRecordTime = currentTime;
        
        _totalTickTime += tickTime;
        
        BOOL shouldUpdateSpeed = _totalTickTime >= 1;
        if(shouldUpdateSpeed)
        {
            _totalRecordTime += _totalTickTime;
            self.averageUploadSpeed = _task.countOfBytesSent/_totalRecordTime;
            _totalTickTime = 0;
        }
    }
}

@end
