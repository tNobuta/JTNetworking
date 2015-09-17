//
//  JTUploadTask.h
//  JTNetworkingDemo
//
//  Created by Admin on 10/14/13.
//  Copyright (c) 2013 nobuta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JTUploadCallback.h"

@interface JTUploadTask : NSObject

@property (nonatomic,copy) NSString *URL;
@property (nonatomic,readonly) NSURLSessionUploadTask *internalTask;
@property (nonatomic,retain) JTUploadCallback *callback;
@property (nonatomic,retain) NSError  *error;
@property (nonatomic) NSInteger statusCode;
@property (nonatomic) float averageUploadSpeed;

+ (void)setURLSession:(NSURLSession *)URLSession;

+ (JTUploadTask *)taskWithURL:(NSString *)URL fromFile:(NSString *)filePath callback:(JTUploadCallback *)callback;
+ (JTUploadTask *)restoreTaskWithURLSessionUploadTask:(NSURLSessionUploadTask *)task callback:(JTUploadCallback *)callback;

- (id)initWithURL:(NSString *)URL fromFile:(NSString *)filePath callback:(JTUploadCallback *)callback;
- (id)restoreWithURLSessionUploadTask:(NSURLSessionUploadTask *)task callback:(JTUploadCallback *)callback;

- (void)start;
- (void)pause;
- (void)resume;
- (void)cancel;

- (void)recordBandwidthUsage;

@end
