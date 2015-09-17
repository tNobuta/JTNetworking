//
//  JTUploadCallback.h
//  JTNetworkingDemo
//
//  Created by Admin on 10/14/13.
//  Copyright (c) 2013 nobuta. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JTUploadTask;

@interface JTUploadCallback : NSObject

@property (nonatomic,retain) id target;

@property (nonatomic,copy) void(^progressHandler)(JTUploadTask *task, long long bytesSended, long long bytesExceptedToSend);
@property (nonatomic,copy) void(^successHandler)(JTUploadTask *);
@property (nonatomic,copy) void(^failHandler)(JTUploadTask *);


+ (JTUploadCallback *)callbackWithProgressHandler:(void(^)(JTUploadTask *task, long long bytesSended, long long bytesExceptedToSend))progressHandler successHandler:(void(^)(JTUploadTask * task))successHandler failHandler:(void(^)(JTUploadTask * task))failHandler;

- (id)initWithProgressHandler:(void(^)(JTUploadTask *task, long long bytesSended, long long bytesExceptedToSend))progressHandler successHandler:(void(^)(JTUploadTask *task))successHandler failHandler:(void(^)(JTUploadTask *task))failHandler;


@end

NS_INLINE JTUploadCallback *UploadCallback(void(^progressHandler)(JTUploadTask *task, long long bytesSended, long long bytesExceptedToSend),void(^successHandler)(JTUploadTask * task),void(^failHandler)(JTUploadTask * task))
{
    return [JTUploadCallback callbackWithProgressHandler:progressHandler successHandler:successHandler failHandler:failHandler];
}
