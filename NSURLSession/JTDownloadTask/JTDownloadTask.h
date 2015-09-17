//
//  JTDownloadTask.h
//  JTNetworkingDemo
//
//  Created by Admin on 10/14/13.
//  Copyright (c) 2013 nobuta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JTDownloadCallback.h"

@interface JTDownloadTask : NSObject

@property (nonatomic) BOOL isValid;
@property (nonatomic,copy) NSString *URL;
@property (nonatomic,copy) NSString *savePath;
@property (nonatomic,readonly) NSURLSessionDownloadTask *internalTask;
@property (nonatomic,retain) JTDownloadCallback *callback;
@property (nonatomic,retain) NSError  *error;
@property (nonatomic) NSInteger statusCode;
@property (nonatomic) long long averageDownloadSpeed;

+ (void)setURLSession:(NSURLSession *)URLSession;

+ (JTDownloadTask *)taskWithURL:(NSString *)URL savePath:(NSString *)savePath callback:(JTDownloadCallback *)callback;
+ (JTDownloadTask *)taskWithResumeData:(NSData *)resumeData savePath:(NSString *)savePath callback:(JTDownloadCallback *)callback;

- (id)initWithURL:(NSString *)URL savePath:(NSString *)savePath callback:(JTDownloadCallback *)callback;
- (id)initWithResumeData:(NSData *)resumeData savePath:(NSString *)savePath callback:(JTDownloadCallback *)callback;

- (void)start;
- (void)pauseWithResumeData:(void (^)(NSData *resumeData))completionHandler;
- (void)pause;
- (void)resume;
- (void)cancel;

- (BOOL)checkTickWithReceivedBytes:(long long)receivedBytes;

@end
