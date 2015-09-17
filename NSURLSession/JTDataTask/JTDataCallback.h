//
//  JTDataCallback.h
//  JTNetworkingDemo
//
//  Created by Admin on 10/14/13.
//  Copyright (c) 2013 nobuta. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JTDataTask;

@interface JTDataCallback : NSObject

@property (nonatomic,retain) id target;
@property (nonatomic,copy) void(^successHandler)(JTDataTask *);
@property (nonatomic,copy) void(^failHandler)(JTDataTask *);


+ (JTDataCallback *)callbackWithTarget:(id)target successHandler:(void(^)(JTDataTask * task))successHandler failHandler:(void(^)(JTDataTask * task))failHandler;

- (id)initWithTarget:(id)target successHandler:(void(^)(JTDataTask *task))successHandler failHandler:(void(^)(JTDataTask *task))failHandler;


@end

NS_INLINE JTDataCallback *DataCallback(id target,void(^successHandler)(JTDataTask * task),void(^failHandler)(JTDataTask * task))
{
    return [JTDataCallback callbackWithTarget:target successHandler:successHandler failHandler:failHandler];
}
 