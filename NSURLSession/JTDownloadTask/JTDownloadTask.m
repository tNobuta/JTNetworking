//
//  JTDownloadTask.m
//  JTNetworkingDemo
//
//  Created by Admin on 10/14/13.
//  Copyright (c) 2013 nobuta. All rights reserved.
//

#import "JTDownloadTask.h"
#import "JTDownloadCallback.h"

#define TICK_TIME 1

static NSURLSession *DownloadTaskURLSession;

@implementation JTDownloadTask
{
    NSMutableURLRequest         *_request;
    NSURLSessionDownloadTask    *_task;
    NSTimeInterval              _lastRecordTime;
    NSTimeInterval              _totalRecordTime;
    long long                   _bytesReceivedPerTick;
}
@synthesize internalTask = _task;

+ (void)setURLSession:(NSURLSession *)URLSession
{
    DownloadTaskURLSession = URLSession;
}

+ (JTDownloadTask *)taskWithURL:(NSString *)URL savePath:(NSString *)savePath callback:(JTDownloadCallback *)callback
{
    return [[[JTDownloadTask alloc] initWithURL:URL savePath:savePath callback:callback] autorelease];
}

+ (JTDownloadTask *)taskWithResumeData:(NSData *)resumeData savePath:(NSString *)savePath callback:(JTDownloadCallback *)callback
{
    return [[[JTDownloadTask alloc] initWithResumeData:resumeData savePath:savePath callback:callback] autorelease];
}

- (id)initWithURL:(NSString *)URL savePath:(NSString *)savePath callback:(JTDownloadCallback *)callback
{
    if(self = [super init])
    {
        self.URL = URL;
        self.savePath = savePath;
        self.callback = callback;
        
        if (self.URL && (NSNull *)self.URL != [NSNull null]) {
            NSURL *downloadURL = [NSURL URLWithString:self.URL];
            if (downloadURL) {
                _request = [[NSMutableURLRequest alloc] initWithURL:downloadURL];
                _task = [[DownloadTaskURLSession downloadTaskWithRequest:_request] retain];
                self.isValid = YES;
            }
        }
    }

    return self;
}

- (id)initWithResumeData:(NSData *)resumeData savePath:(NSString *)savePath callback:(JTDownloadCallback *)callback
{
    if(self = [super init])
    {
        self.savePath = savePath;
        self.callback = callback;
        @try {
            _task = [[DownloadTaskURLSession downloadTaskWithResumeData:resumeData] retain];
            self.URL = _task.originalRequest.URL.absoluteString;
            self.isValid = YES;
        }
        @catch (NSException *exception) {

        }
    }
    
    return self;
}

- (void)dealloc
{
    [_request release];
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

- (void)pauseWithResumeData:(void (^)(NSData *resumeData))completionHandler
{
    if(_task)
    {
        [_task cancelByProducingResumeData:^(NSData *resumeData) {
            completionHandler(resumeData);
        }];
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

- (BOOL)checkTickWithReceivedBytes:(long long)receivedBytes
{
    BOOL shouldUpdate = NO;
    _bytesReceivedPerTick += receivedBytes;
    
    if(_lastRecordTime == 0)
    {
        _lastRecordTime = [[NSDate date] timeIntervalSince1970];
    }
    else
    {
        NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
        NSTimeInterval tickTime =  currentTime - _lastRecordTime;
        _lastRecordTime = currentTime;
        
        _totalRecordTime += tickTime;
        
        float timeToUpdateSpeed = self.averageDownloadSpeed > 0?TICK_TIME : (TICK_TIME - 0.2f);
        
        BOOL shouldUpdateSpeed = _totalRecordTime >= timeToUpdateSpeed;
        if(shouldUpdateSpeed)
        {
            self.averageDownloadSpeed = _bytesReceivedPerTick/_totalRecordTime;
            _totalRecordTime = 0;
            _bytesReceivedPerTick = 0;
            shouldUpdate = YES;
        }
    }
    
    return shouldUpdate;
}

@end
