//
//  JTURLSessionManager.m
//  JTNetworkingDemo
//
//  Created by Admin on 10/14/13.
//  Copyright (c) 2013 nobuta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>
#import <Foundation/NSURLError.h>
#import "JTURLSessionManager.h"
#import "JTDataTask.h"
#import "JTDownloadTask.h"
#import "JTUploadTask.h"
#import "JTDataCallback.h"
#import "JTDownloadCallback.h"
#import "JTUploadCallback.h"

#define TIME_OUT 15
#define BACKGROUND_DOWNLOAD_SESSION_IDENTIFER @"com.nobuta.jtnetworking.background.download.identifier"
#define BACKGROUND_UPLOAD_SESSION_IDENTIFER @"com.nobuta.jtnetworking.background.upload.identifier"

@implementation JTURLSessionManager
{
    NSURLSession    *_dataSession;
    NSURLSession    *_downloadSession;
    NSURLSession    *_uploadSession;
    
    NSMutableDictionary *_dataTasks;
    NSMutableDictionary *_downloadTasks;
    NSMutableDictionary *_uploadTasks;
 
    Reachability    *_reachability;
    
    NSString        *_tempFilePath;
}

- (NSString *)md5:(NSString *)srcString{
    const char *cStr = [srcString UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest );
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [result appendFormat:@"%02x", digest[i]];
    
    return result;
}

- (int64_t)totalBytesReceived
{
    int64_t totalBytesReceived = 0;
    if(_downloadTasks)
    {
        for(JTDownloadTask *task in _downloadTasks.allValues)
        {
            totalBytesReceived += task.internalTask.countOfBytesReceived;
        }
    }
    
    return totalBytesReceived;
}

- (int64_t)totalBytesExpectedToReceive
{
    int64_t totalBytesExpectedToReceive = 0;
    if(_downloadTasks)
    {
        for(JTDownloadTask *task in _downloadTasks.allValues)
        {
            totalBytesExpectedToReceive += task.internalTask.countOfBytesExpectedToReceive;
        }
    }
    
    return totalBytesExpectedToReceive;
}

- (float)speedForDownloading
{
    float speed = 0;
    if(_downloadTasks)
    {
        for(JTDownloadTask *task in _downloadTasks.allValues)
        {
            speed += task.averageDownloadSpeed;
        }
    }
    
    return speed;
}

- (BOOL)isNetworkValid
{
    return  _reachability.currentReachabilityStatus != NotReachable && !_reachability.connectionRequired;
}

- (BOOL)isWiFiValid
{
    return _reachability.currentReachabilityStatus == ReachableViaWiFi;
}

+ (JTURLSessionManager *)sharedManager
{
    static JTURLSessionManager *SharedManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SharedManager = [[JTURLSessionManager alloc] init];
    });
    
    return SharedManager;
}

- (id)init
{
    if(self = [super init])
    {
        _dataTasks = [[NSMutableDictionary alloc] initWithCapacity:100];
        _downloadTasks = [[NSMutableDictionary alloc] initWithCapacity:100];
        _uploadTasks = [[NSMutableDictionary alloc] initWithCapacity:100];
    
        _reachability = [[Reachability reachabilityForInternetConnection] retain];
        [_reachability startNotifier];
        
        _tempFilePath = [[NSString stringWithFormat:@"%@/Library/Caches/TempFiles",NSHomeDirectory()] retain];
        
        BOOL isDirectory = YES;
        if(![[NSFileManager defaultManager] fileExistsAtPath:_tempFilePath isDirectory:&isDirectory])
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:_tempFilePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        _dataSession = [[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil] retain];
        _dataSession.configuration.timeoutIntervalForRequest = TIME_OUT;
        _dataSession.configuration.TLSMinimumSupportedProtocol = kSSLProtocolAll;
        _dataSession.configuration.TLSMaximumSupportedProtocol = kSSLProtocolAll;
        _downloadSession = [[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration backgroundSessionConfiguration:BACKGROUND_DOWNLOAD_SESSION_IDENTIFER] delegate:self delegateQueue:nil] retain];
       
        
        _uploadSession = [[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration backgroundSessionConfiguration:BACKGROUND_UPLOAD_SESSION_IDENTIFER] delegate:self delegateQueue:nil] retain];
        
        [JTDataTask setURLSession:_dataSession];
        [JTDownloadTask setURLSession:_downloadSession];
        [JTUploadTask setURLSession:_uploadSession];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityStatusDidChange:) name:kReachabilityChangedNotification object:_reachability];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_dataSession invalidateAndCancel];
    [_dataSession release];
    [_downloadSession invalidateAndCancel];
    [_downloadSession release];
    [_uploadSession invalidateAndCancel];
    [_uploadSession release];
    
    [_dataTasks release];
    [_downloadTasks release];
    [_uploadTasks release];
    
    [_tempFilePath release];
    
    [super dealloc];
}


- (BOOL)hasResumeDataFor:(NSString *)url
{
    NSString *md5Value = [self md5:url];
    NSString *path = [NSString stringWithFormat:@"%@/%@",_tempFilePath,md5Value];
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

- (NSData *)resumeDataForUrl:(NSString *)url
{
    NSString *md5Value = [self md5:url];
    NSString *path = [NSString stringWithFormat:@"%@/%@",_tempFilePath,md5Value];
    return [NSData dataWithContentsOfFile:path];
}

- (void)saveResumeData:(NSData *)resumeData url:(NSString *)url
{
    if(resumeData.length > 0)
    {
        NSString *md5Value = [self md5:url];
        NSString *path = [NSString stringWithFormat:@"%@/%@",_tempFilePath,md5Value];
        [[NSFileManager defaultManager] createFileAtPath:path contents:resumeData attributes:nil];
    }
}

- (void)deleteResumeDataForUrl:(NSString *)url
{
    NSString *md5Value = [self md5:url];
    NSString *path = [NSString stringWithFormat:@"%@/%@",_tempFilePath,md5Value];
    if([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
       [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
}

- (NSString *)messageForNetworkError:(int) errorCode
{
    NSString *errorMsg = @"";
    switch (errorCode) {
        case NSURLErrorTimedOut:
            errorMsg = NSLocalizedString(@"Network connection timed out, please check your network connection and try again.", nil);
            break;
        case NSURLErrorNotConnectedToInternet:
            errorMsg = NSLocalizedString(@"There are no available network, please check your network connection and try again.", nil);
            break;
        default:
            errorMsg = NSLocalizedString(@"There are an unknown network error, please try again later", nil);
            break;
    }
    
    return errorMsg;
}

- (void)reachabilityStatusDidChange:(NSNotification *)notify
{
    if(self.sessionManagerDelegate && [self.sessionManagerDelegate respondsToSelector:@selector(JTURLSessionManager:didChangeReachabilityStatus:)])
    {
        [self.sessionManagerDelegate JTURLSessionManager:self didChangeReachabilityStatus:_reachability.currentReachabilityStatus];
    }
}

- (JTDataTask *)requestDataTask:(JTDataTask *)dataTask
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    _dataTasks[@(dataTask.internalTask.taskIdentifier)] = dataTask;
    [dataTask start];
    return dataTask;
}

- (JTDataTask *)GET:(NSString *)url params:(NSDictionary *)params callback:(JTDataCallback *)callback
{
    return [self requestDataTask:[JTDataTask taskWithMethod:@"GET" URL:url params:params callback:callback]];
}

- (JTDataTask *)GET:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary *)headers callback:(JTDataCallback *)callback
{
    JTDataTask *task = [JTDataTask taskWithMethod:@"GET" URL:url params:params headers:headers callback:callback];
    return [self requestDataTask:task];
}

- (JTDataTask *)POST:(NSString *)url params:(NSDictionary *)params callback:(JTDataCallback *)callback
{
    return [self requestDataTask:[JTDataTask taskWithMethod:@"POST" URL:url params:params callback:callback]];
}

- (JTDataTask *)POST:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary *)headers callback:(JTDataCallback *)callback
{
    JTDataTask *task = [JTDataTask taskWithMethod:@"POST" URL:url params:params headers:headers callback:callback];
    return [self requestDataTask:task];
}

- (JTDataTask *)POST:(NSString *)url
            textData:(NSDictionary *)textData
            fileData:(NSDictionary *)fileData
            callback:(JTDataCallback *)callback
{
    JTDataTask *task = [JTDataTask taskWithMethod:@"POST" URL:url params:nil callback:callback];
    return [self requestDataTask:task];
}

- (JTDataTask *)PUT:(NSString *)url params:(NSDictionary *)params callback:(JTDataCallback *)callback
{
   return [self requestDataTask:[JTDataTask taskWithMethod:@"PUT" URL:url params:params callback:callback]];
}

- (JTDataTask *)PUT:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary *)headers callback:(JTDataCallback *)callback
{
    JTDataTask *task = [JTDataTask taskWithMethod:@"PUT" URL:url params:params headers:headers callback:callback];
    return [self requestDataTask:task];
}

- (JTDataTask *)HEAD:(NSString *)url params:(NSDictionary *)params callback:(JTDataCallback *)callback
{
     return [self requestDataTask:[JTDataTask taskWithMethod:@"HEAD" URL:url params:params callback:callback]];
}
- (JTDataTask *)HEAD:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary *)headers callback:(JTDataCallback *)callback
{
    JTDataTask *task = [JTDataTask taskWithMethod:@"HEAD" URL:url params:params headers:headers callback:callback];
    return [self requestDataTask:task];
}

- (JTDataTask *)PATCH:(NSString *)url params:(NSDictionary *)params callback:(JTDataCallback *)callback
{
    return [self requestDataTask:[JTDataTask taskWithMethod:@"PATCH" URL:url params:params callback:callback]];
}

- (JTDataTask *)PATCH:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary *)headers callback:(JTDataCallback *)callback
{
    JTDataTask *task = [JTDataTask taskWithMethod:@"PATCH" URL:url params:params headers:headers callback:callback];
    return [self requestDataTask:task];
}

- (JTDataTask *)DELETE:(NSString *)url params:(NSDictionary *)params callback:(JTDataCallback *)callback
{
    return [self requestDataTask:[JTDataTask taskWithMethod:@"DELETE" URL:url params:params callback:callback]];
}
- (JTDataTask *)DELETE:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary *)headers callback:(JTDataCallback *)callback
{
    JTDataTask *task = [JTDataTask taskWithMethod:@"DELETE" URL:url params:params headers:headers callback:callback];
    return [self requestDataTask:task];
}

- (JTDownloadTask *)downloadWithUrl:(NSString *)url savePath:(NSString *)savePath callback:(JTDownloadCallback *)callback
{
    JTDownloadTask *task = nil;
    
    if(![self hasResumeDataFor:url])
    {
        task = [JTDownloadTask taskWithURL:url savePath:savePath callback:callback];
        if (task.isValid) {
            _downloadTasks[@(task.internalTask.taskIdentifier)] = task;
            [task start];
        }else {
            if (callback && callback.failHandler) {
                callback.failHandler(task);
            }
            
            return task;
        }
    }
    else
    {
        @try {
            task = [JTDownloadTask taskWithResumeData:[self resumeDataForUrl:url] savePath:savePath callback:callback];
            
            if (task.isValid && task.internalTask.originalRequest) {
                [task resume];
            }else {
                [self deleteResumeDataForUrl:url];
                task = nil;
            }
        }
        @catch (NSException *exception) {
            [self deleteResumeDataForUrl:url];
            task = nil;
        }
        @finally {
            if (task) {
                _downloadTasks[@(task.internalTask.taskIdentifier)] = task;
            }else {
                return nil;
            }
                
        }
    }
    
    if([_downloadTasks.allKeys count] == 1)
    {
        if(self.sessionManagerDelegate && [self.sessionManagerDelegate respondsToSelector:@selector(JTURLSessionManagerDidBeginDownloadTask:)])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.sessionManagerDelegate JTURLSessionManagerDidBeginDownloadTask:self];
            });
        }
    }
   
    return task;
}

- (JTUploadTask *)uploadWithUrl:(NSString *)url fromFile:(NSString *)filePath callback:(JTUploadCallback *)callback
{
    JTUploadTask *task = [JTUploadTask taskWithURL:url fromFile:filePath callback:callback];
    _uploadTasks[@(task.internalTask.taskIdentifier)] = task;
    [task start];
    
    if([_uploadTasks.allKeys count] == 1)
    {
        if(self.sessionManagerDelegate && [self.sessionManagerDelegate respondsToSelector:@selector(JTURLSessionManagerDidBeginUploadTask:)])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.sessionManagerDelegate JTURLSessionManagerDidBeginUploadTask:self];
            });
        }
    }
    
    return task;
}

- (void)cancelRequest:(id)target
{
    [_dataTasks enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        JTDataTask *task = (JTDataTask *)obj;
        if(task.callback.target == target)
        {
            [task cancel];
        }
    }];
}

- (void)cancelRequest:(id)target url:(NSString *)url
{
    [_dataTasks enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        JTDataTask *task = (JTDataTask *)obj;
        if(task.callback.target == target && [task.URL isEqualToString:url])
        {
            [task cancel];
        }
    }];
}

- (long long)pauseDownloadForURL:(NSString *)url
{
    long long receivedBytes = 0;
    __block long long *__receivedBytes = &receivedBytes;
    
    [_downloadTasks enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        JTDownloadTask *task = (JTDownloadTask *)obj;
        if([task.URL isEqualToString:url])
        {
            *__receivedBytes = task.internalTask.countOfBytesReceived;
            [task pauseWithResumeData:^(NSData *resumeData) {
                
                [self saveResumeData:resumeData url:url];
                
            }];
            *stop = YES;
        }
    }];
    
    return receivedBytes;
}

- (JTDownloadTask *)resumeDownloadForURL:(NSString *)url savePath:(NSString *)savePath callback:(JTDownloadCallback *)callback
{
    return [self downloadWithUrl:url savePath:savePath callback:callback];
}

- (void)cancelDownloadForURL:(NSString *)url
{
  
    BOOL canceled = NO;
    __block BOOL *__canceled = &canceled;
    
    [_downloadTasks enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        JTDownloadTask *task = (JTDownloadTask *)obj;
        if([task.URL isEqualToString:url])
        {
            [task cancel];
            *stop = YES;
            *__canceled = YES;
        }
    }];
    
    if(!canceled && [self hasResumeDataFor:url])
    {
        NSData *resumeData = [self resumeDataForUrl:url];
    
        if(resumeData && (NSNull *)resumeData != [NSNull null] && resumeData.length > 0)
        {
            NSURLSessionDownloadTask *tempTask = [_downloadSession downloadTaskWithResumeData:resumeData];
            [tempTask cancel];
        }
    }
    
    [self deleteResumeDataForUrl:url];
}

- (void)cancelAllDownloadTask
{
    [_downloadTasks enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        JTDownloadTask *task = (JTDownloadTask *)obj;
        NSString *url = task.internalTask.originalRequest.URL.absoluteString;
        [task cancel];
        [self deleteResumeDataForUrl:url];
    }];
    
    [self clearTemporaryCache];
}


- (long long)pauseUploadForURL:(NSString *)url
{
    long long sendedBytes = 0;
    __block long long *__sendedBytes = &sendedBytes;

    [_uploadTasks enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        JTUploadTask *task = (JTUploadTask *)obj;
        if([task.URL isEqualToString:url])
        {
            *__sendedBytes = task.internalTask.countOfBytesSent;
            [task pause];
            *stop = YES;
        }
    }];
    
    return sendedBytes;
}

- (long long)resumeUploadForURL:(NSString *)url
{
    long long resumeBytes = 0;
    __block long long *__resumeBytes = &resumeBytes;
    [_uploadTasks enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        JTUploadTask *task = (JTUploadTask *)obj;
        if([task.URL isEqualToString:url])
        {
            *__resumeBytes = task.internalTask.countOfBytesSent;
            [task resume];
            *stop = YES;
        }
    }];
    
    return resumeBytes;
}

- (long long)cancelUploadForURL:(NSString *)url
{
    long long sendedBytes = -1;
    __block long long *__sendedBytes = &sendedBytes;
    
    [_uploadTasks enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        JTUploadTask *task = (JTUploadTask *)obj;
        if([task.URL isEqualToString:url])
        {
            *__sendedBytes = task.internalTask.countOfBytesSent;
            [task cancel];
            *stop = YES;
        }
    }];
    
    return sendedBytes;
}

- (void)cancelAllUploadTasks
{
    [_uploadTasks enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        JTUploadTask *task = (JTUploadTask *)obj;
        [task cancel];
    }];
}

- (void)clearTemporaryCache
{
    NSArray *resumeDataFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_tempFilePath error:nil];
    for(NSString *fileName in resumeDataFiles)
    {
        NSString *path = [NSString stringWithFormat:@"%@/%@",_tempFilePath,fileName];
        NSData *resumeData = [[NSData alloc] initWithContentsOfFile:path];
        @try {
            NSURLSessionDownloadTask *tempTask = [_downloadSession downloadTaskWithResumeData:resumeData];
            [tempTask cancel];
            [resumeData release];
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }
    }
}

#pragma mark NSURLSessionDelegate

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    if(self.sessionManagerDelegate && [self.sessionManagerDelegate respondsToSelector:@selector(JTURLSessionDidFinishEventsForBackgroundURLSession:)])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.sessionManagerDelegate JTURLSessionDidFinishEventsForBackgroundURLSession:session];
        });
    }
    
    if(self.backgroundEventsCompletionHandlerForAppliaction)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.backgroundEventsCompletionHandlerForAppliaction();
            self.backgroundEventsCompletionHandlerForAppliaction = nil;

        });
    }
    
}

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
    if(self.sessionManagerDelegate && [self.sessionManagerDelegate respondsToSelector:@selector(JTURLSession:didBecomeInvalidWithError:)])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.sessionManagerDelegate JTURLSession:session didBecomeInvalidWithError:error];
        });
    }
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    if(self.sessionManagerDelegate && [self.sessionManagerDelegate respondsToSelector:@selector(JTURLSession:didReceiveChallenge:completionHandler:)])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.sessionManagerDelegate JTURLSession:session didReceiveChallenge:challenge completionHandler:completionHandler];
        });
    }
    else
    {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling,[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]);
    }
}

#pragma mark NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    if(session == _uploadSession)
    {
        JTUploadTask *uploadTask = _uploadTasks[@(task.taskIdentifier)];
        if(uploadTask)
        {
            [uploadTask recordBandwidthUsage];
            
            if(uploadTask.callback.progressHandler)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    uploadTask.callback.progressHandler(uploadTask,totalBytesSent,totalBytesExpectedToSend);
                });
            }
        }
        else
        {
            [uploadTask cancel];
        }
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
    if(session == _dataSession)
    {
        JTDataTask *dataTask = _dataTasks[@(task.taskIdentifier)];
        if(dataTask)
        {
            dataTask.statusCode = ((NSHTTPURLResponse *)dataTask.internalTask.response).statusCode;
            
            if(!error)
            {
                if(dataTask.callback.successHandler)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        dataTask.callback.successHandler(dataTask);
                    });
                }
            }
            else if(error && error.code != NSURLErrorCancelled)
            {
                dataTask.error = error;
                
                if(dataTask.callback.failHandler)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        dataTask.callback.failHandler(dataTask);
                    });
                }
            }
            
            [_dataTasks removeObjectForKey:@(task.taskIdentifier)];
            
            if([_dataTasks.allKeys count] == 0)
            {
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            }
        }
    }
    else if(session == _uploadSession)
    {
        JTUploadTask *uploadTask = _uploadTasks[@(task.taskIdentifier)];
        if(uploadTask)
        {
            uploadTask.statusCode = ((NSHTTPURLResponse *)uploadTask.internalTask.response).statusCode;
            
            if(!error)
            {
                if(uploadTask.callback.successHandler)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        uploadTask.callback.successHandler(uploadTask);
                    });
                }
            }
            else if(error && error.code != NSURLErrorCancelled)
            {
                uploadTask.error = error;
                
                if(uploadTask.callback.failHandler)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        uploadTask.callback.failHandler(uploadTask);
                    });
                }
            }
            
            [_uploadTasks removeObjectForKey:@(task.taskIdentifier)];
            
            if([_uploadTasks.allKeys count] == 0)
            {
                if(self.sessionManagerDelegate && [self.sessionManagerDelegate respondsToSelector:@selector(JTURLSessionManagerDidFinishAllUploadTasks:)])
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.sessionManagerDelegate JTURLSessionManagerDidFinishAllUploadTasks:self];
                    });
                }
            }
        }
    }
    else if(session == _downloadSession)
    {
        JTDownloadTask *downloadTask = _downloadTasks[@(task.taskIdentifier)];
        if(downloadTask)
        {
            downloadTask.statusCode = ((NSHTTPURLResponse *)downloadTask.internalTask.response).statusCode;
            if(!error)
            {
                if(downloadTask.callback.successHandler)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        downloadTask.callback.successHandler(downloadTask);
                    });
                }
            }
            else if(error && error.code != NSURLErrorCancelled)
            {
                if(error.userInfo[@"NSURLSessionDownloadTaskResumeData"])
                {
                    NSData *resumeData = error.userInfo[@"NSURLSessionDownloadTaskResumeData"];
                    NSString *url = error.userInfo[@"NSErrorFailingURLStringKey"];
                    [self saveResumeData:resumeData url:url];
                }
                
                downloadTask.error = error;
                if(downloadTask.callback.failHandler)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        downloadTask.callback.failHandler(downloadTask);
                    });
                }
            }
            
            [_downloadTasks removeObjectForKey:@(task.taskIdentifier)];
            
            if([_downloadTasks.allKeys count] == 0)
            {
                if(self.sessionManagerDelegate && [self.sessionManagerDelegate respondsToSelector:@selector(JTURLSessionManagerDidFinishAllDownloadTasks:)])
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.sessionManagerDelegate JTURLSessionManagerDidFinishAllDownloadTasks:self];
                    });
                }
            }
        }
        else if(error && error.userInfo[@"NSURLErrorBackgroundTaskCancelledReasonKey"] && [error.userInfo[@"NSURLErrorBackgroundTaskCancelledReasonKey"] intValue] == NSURLErrorCancelledReasonUserForceQuitApplication)
        {
            NSData *resumeData = error.userInfo[@"NSURLSessionDownloadTaskResumeData"];
            NSString *url = error.userInfo[@"NSErrorFailingURLStringKey"];
            [self saveResumeData:resumeData url:url];
            
            if(self.sessionManagerDelegate && [self.sessionManagerDelegate respondsToSelector:@selector(JTURLSessionManager:didSaveResumeDataForLastDownloadingTask:)])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.sessionManagerDelegate JTURLSessionManager:self didSaveResumeDataForLastDownloadingTask:url];
                });
            }
        }
    }
}


#pragma mark NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    JTDataTask *task = _dataTasks[@(dataTask.taskIdentifier)];
    
    if(data && task)
    {
        [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
            [task.data appendBytes:bytes length:byteRange.length];
        }];
        
        NSString *responseString = [[NSString alloc] initWithData:task.data encoding:NSUTF8StringEncoding];
        task.responseString = responseString;
        [responseString release];
    }
}

#pragma mark NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    JTDownloadTask *task = _downloadTasks[@(downloadTask.taskIdentifier)];
    if(task)
    {
        BOOL isDirectory = NO;
        if([[NSFileManager defaultManager] fileExistsAtPath:task.savePath isDirectory:&isDirectory])
        {
            [[NSFileManager defaultManager] removeItemAtPath:task.savePath error:nil];
        }
        [[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL fileURLWithPath:task.savePath isDirectory:NO] error:nil];
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    if(session == _downloadSession)
    {
        JTDownloadTask *task = _downloadTasks[@(downloadTask.taskIdentifier)];
        if(task)
        {
            BOOL shouldNotifyForUpdate = [task checkTickWithReceivedBytes:bytesWritten];
            
            if(shouldNotifyForUpdate && task.callback.progressHandler)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    task.callback.progressHandler(task, task.averageDownloadSpeed,totalBytesWritten,totalBytesExpectedToWrite);
                });
            }
        }
        else
        {
            [task cancel];
        }
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    
}
 
@end
