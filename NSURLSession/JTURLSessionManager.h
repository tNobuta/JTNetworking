//
//  JTURLSessionManager.h
//  JTNetworkingDemo
//
//  Created by Admin on 10/14/13.
//  Copyright (c) 2013 nobuta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@class JTDataCallback;
@class JTDownloadCallback;
@class JTUploadCallback;
@class JTDataTask;
@class JTDownloadTask;
@class JTUploadTask;

@protocol JTURLSessionManagerDelegate;

@interface JTURLSessionManager : NSObject<NSURLSessionDataDelegate,NSURLSessionTaskDelegate,NSURLSessionDownloadDelegate,NSURLSessionDelegate>

@property (nonatomic,assign) id<JTURLSessionManagerDelegate> sessionManagerDelegate;
@property (nonatomic)  BOOL  isNetworkValid;
@property (nonatomic)  BOOL  isWiFiValid;
@property (nonatomic,copy) void(^backgroundEventsCompletionHandlerForAppliaction)(void);
@property (nonatomic)  int64_t totalBytesReceived;
@property (nonatomic)  int64_t totalBytesExpectedToReceive;
@property (nonatomic)  float speedForDownloading;

+ (JTURLSessionManager *)sharedManager;

- (BOOL)hasResumeDataFor:(NSString *)url;

- (NSString *)messageForNetworkError:(int) errorCode;

- (JTDataTask *)requestDataTask:(JTDataTask *)dataTask;

- (JTDataTask *)GET:(NSString *)url params:(NSDictionary *)params callback:(JTDataCallback *)callback;
- (JTDataTask *)GET:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary *)headers callback:(JTDataCallback *)callback;

- (JTDataTask *)POST:(NSString *)url params:(NSDictionary *)params callback:(JTDataCallback *)callback;
- (JTDataTask *)POST:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary *)headers callback:(JTDataCallback *)callback;

- (JTDataTask *)POST:(NSString *)url
               textData:(NSDictionary *)textData
               fileData:(NSDictionary *)fileData
               callback:(JTDataCallback *)callback;

- (JTDataTask *)PUT:(NSString *)url params:(NSDictionary *)params callback:(JTDataCallback *)callback;
- (JTDataTask *)PUT:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary *)headers callback:(JTDataCallback *)callback;

- (JTDataTask *)HEAD:(NSString *)url params:(NSDictionary *)params callback:(JTDataCallback *)callback;
- (JTDataTask *)HEAD:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary *)headers callback:(JTDataCallback *)callback;

- (JTDataTask *)PATCH:(NSString *)url params:(NSDictionary *)params callback:(JTDataCallback *)callback;
- (JTDataTask *)PATCH:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary *)headers callback:(JTDataCallback *)callback;

- (JTDataTask *)DELETE:(NSString *)url params:(NSDictionary *)params callback:(JTDataCallback *)callback;
- (JTDataTask *)DELETE:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary *)headers callback:(JTDataCallback *)callback;

- (JTDownloadTask *)downloadWithUrl:(NSString * )url savePath:(NSString *)savePath callback:(JTDownloadCallback *)callback;

- (JTUploadTask *)uploadWithUrl:(NSString *)url fromFile:(NSString *)filePath callback:(JTUploadCallback *)callback;

- (void)cancelRequest:(id)target;
- (void)cancelRequest:(id)target url:(NSString *)url;

- (long long)pauseDownloadForURL:(NSString *)url;
- (JTDownloadTask *)resumeDownloadForURL:(NSString *)url savePath:(NSString *)savePath callback:(JTDownloadCallback *)callback;
- (void)cancelDownloadForURL:(NSString *)url;
- (void)cancelAllDownloadTask;

- (long long)pauseUploadForURL:(NSString *)url;
- (long long)resumeUploadForURL:(NSString *)url;
- (long long)cancelUploadForURL:(NSString *)url;
- (void)cancelAllUploadTasks;
- (void)clearTemporaryCache;

@end

@protocol JTURLSessionManagerDelegate <NSObject>
@optional

- (void)JTURLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error;

- (void)JTURLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler;

- (void)JTURLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session;

- (void)JTURLSessionManager:(JTURLSessionManager *)manager didChangeReachabilityStatus:(NetworkStatus)status;

- (void)JTURLSessionManager:(JTURLSessionManager *)manager didSaveResumeDataForLastDownloadingTask:(NSString *)url;

- (void)JTURLSessionManagerDidBeginDownloadTask:(JTURLSessionManager *)manager;

- (void)JTURLSessionManagerDidFinishAllDownloadTasks:(JTURLSessionManager *)manager;

- (void)JTURLSessionManagerDidBeginUploadTask:(JTURLSessionManager *)manager;

- (void)JTURLSessionManagerDidFinishAllUploadTasks:(JTURLSessionManager *)manager ;

@end


