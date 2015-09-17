//
//  JTDataTask.h
//  JTNetworkingDemo
//
//  Created by Admin on 10/14/13.
//  Copyright (c) 2013 nobuta. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JTDataCallback;

@interface JTDataTask : NSObject

@property (nonatomic,copy) NSString *URL;
@property (nonatomic,readonly) NSURLSessionDataTask *internalTask;
@property (nonatomic,retain) JTDataCallback *callback;
@property (nonatomic,readonly) NSMutableData *data;
@property (nonatomic,retain) NSString *responseString;
@property (nonatomic,retain) NSError  *error;
@property (nonatomic) NSInteger statusCode;

+ (void)setURLSession:(NSURLSession *)URLSession;

+ (JTDataTask *)taskWithMethod:(NSString *)method URL:(NSString *)URL params:(NSDictionary *)params callback:(JTDataCallback *)callback;
+ (JTDataTask *)taskWithMethod:(NSString *)method URL:(NSString *)URL params:(NSDictionary *)params headers:(NSDictionary *)headers callback:(JTDataCallback *)callback;
+ (JTDataTask *)taskWithURL:(NSString *)URL textField:(NSDictionary *)textField fileField:(NSDictionary *)fileField headers:(NSDictionary *)headers callback:(JTDataCallback *)callback;

- (id)initWithMethod:(NSString *)method URL:(NSString *)URL params:(NSDictionary *)params callback:(JTDataCallback *)callback;
- (id)initWithMethod:(NSString *)method URL:(NSString *)URL params:(NSDictionary *)params headers:(NSDictionary *)headers callback:(JTDataCallback *)callback;
- (id)initWithURL:(NSString *)URL textField:(NSDictionary *)textField fileField:(NSDictionary *)fileField headers:(NSDictionary *)headers callback:(JTDataCallback *)callback;
- (void)setMethod:(NSString *)method;
- (void)setPostBody:(NSString *)bodyString;
- (void)setHeader:(NSString *)key value:(NSString *)value;
- (void)setHeaders:(NSDictionary *)headers;
- (void)setFormDataWithTextField:(NSDictionary *)textField withFileField:(NSDictionary *)fileField;
- (void)start;
- (void)cancel;

@end
 