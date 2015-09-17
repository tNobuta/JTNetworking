//
//  JTDownloadCallback.h
//  JTNetworkingDemo
//
//  Created by Admin on 10/14/13.
//  Copyright (c) 2013 nobuta. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JTDownloadTask;

@interface JTDownloadCallback : NSObject
 
@property (nonatomic,copy) void(^progressHandler)(JTDownloadTask *task, long long bytesReceived, long long totalBytesReceived, long long bytesExceptedToReceive);

@property (nonatomic,copy) void(^successHandler)(JTDownloadTask *);
@property (nonatomic,copy) void(^failHandler)(JTDownloadTask *);


+ (JTDownloadCallback *)callbackWithProgressHandler:(void(^)(JTDownloadTask *task, long long bytesReceived, long long totalBytesReceived, long long bytesExceptedToReceive))progressHandler successHandler:(void(^)(JTDownloadTask * task))successHandler failHandler:(void(^)(JTDownloadTask * task))failHandler;

- (id)initWithProgressHandler:(void(^)(JTDownloadTask *task,long long bytesReceived, long long totalBytesReceived, long long bytesExceptedToReceive))progressHandler successHandler:(void(^)(JTDownloadTask * task))successHandler failHandler:(void(^)(JTDownloadTask * task))failHandler;

@end

NS_INLINE JTDownloadCallback *DownloadCallback(void(^progressHandler)(JTDownloadTask *task, long long bytesReceived, long long totalBytesReceived, long long bytesExceptedToReceive),void(^successHandler)(JTDownloadTask * task),void(^failHandler)(JTDownloadTask * task))
{
    return [JTDownloadCallback callbackWithProgressHandler:progressHandler successHandler:successHandler failHandler:failHandler];
}