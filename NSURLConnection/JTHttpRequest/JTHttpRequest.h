//
//  EXURLConnection.h
//  qdqddadadadad
//
//  Created by Jason Tang on 9/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JTHttpRequestDelegate;

@interface JTHttpRequest : NSObject<NSURLConnectionDataDelegate,NSURLConnectionDelegate>

@property (nonatomic,assign) id<JTHttpRequestDelegate> delegate;
@property (nonatomic,readonly) NSString *url;
@property (nonatomic) NSInteger tag;
@property (nonatomic,retain) id contextObject;
@property (nonatomic,readonly) NSData *data;
@property (nonatomic,retain) NSString *responseString;
@property (nonatomic,retain) NSError  *error;
@property (nonatomic) NSInteger statusCode;
@property (nonatomic) SEL finishSelector;
@property (nonatomic) SEL failSelector;
 
//GET
+ (JTHttpRequest *)requestWithURL:(NSString *)url;
+ (JTHttpRequest *)requestWithURL:(NSString *)url delegate:(id<JTHttpRequestDelegate>)delegate finishSelector:(SEL)finishSel failSelector:(SEL)failSel;
+ (JTHttpRequest *)requestWithURL:(NSString *)url delegate:(id<JTHttpRequestDelegate>)delegate;

//POST
+ (JTHttpRequest *)requestWithURL:(NSString *)url postBody:(NSString *)postBody;
+ (JTHttpRequest *)requestWithURL:(NSString *)url postBody:(NSString *)postBody delegate:(id<JTHttpRequestDelegate>)delegate finishSelector:(SEL)finishSel failSelector:(SEL)failSel;
+ (JTHttpRequest *)requestWithURL:(NSString *)url postBody:(NSString *)postBody delegate:(id<JTHttpRequestDelegate>)delegate;


- (id)initWithURL:(NSString *)url;
- (id)initWithURL:(NSString *)url delegate:(id<JTHttpRequestDelegate>)delegate finishSelector:(SEL)finishSel failSelector:(SEL)failSel;
- (id)initWithURL:(NSString *)url delegate:(id<JTHttpRequestDelegate>)delegate;
- (void)setMethod:(NSString *)method;
- (void)setPostBody:(NSString *)bodyString;
- (void)setHeader:(NSString *)key value:(NSString *)value;
- (void)setCachePolicy:(NSURLRequestCachePolicy)policy;
- (void)setFormDataWithTextField:(NSDictionary *)textField withFileField:(NSDictionary *)fileField;
- (void)setDownloadProgressHandler:(void(^)(JTHttpRequest *request, float progressValue))downloadProcessHandler;
- (void)setUploadProgressHandler:(void(^)(JTHttpRequest *request, float progressValue))uploadProcessHandler;
- (void)start;
- (void)cancel;

@end

@protocol JTHttpRequestDelegate <NSObject>
@optional
- (void)requestDidSuccess:(JTHttpRequest *)request;
- (void)requestDidFail:(JTHttpRequest *)request;

@end
