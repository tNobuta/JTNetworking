//
//  JTDataTask.m
//  JTNetworkingDemo
//
//  Created by Admin on 10/14/13.
//  Copyright (c) 2013 nobuta. All rights reserved.
//

#import "JTDataTask.h"
#import "NSMutableURLRequest+FormData.h"

static NSURLSession *DataTaskURLSession;

@implementation JTDataTask
{
    NSMutableURLRequest         *_request;
    NSURLSessionDataTask        *_task;
    NSMutableData               *_data;
}
@synthesize internalTask = _task,data = _data;

+ (void)setURLSession:(NSURLSession *)URLSession
{
    DataTaskURLSession = URLSession;
}

+ (JTDataTask *)taskWithMethod:(NSString *)method URL:(NSString *)URL params:(NSDictionary *)params callback:(JTDataCallback *)callback
{
    return [[[JTDataTask alloc] initWithMethod:method URL:URL params:params callback:callback] autorelease];
}

+ (JTDataTask *)taskWithMethod:(NSString *)method URL:(NSString *)URL params:(NSDictionary *)params headers:(NSDictionary *)headers callback:(JTDataCallback *)callback
{
    return [[[JTDataTask alloc] initWithMethod:method URL:URL params:params headers:headers callback:callback] autorelease];
}

+ (JTDataTask *)taskWithURL:(NSString *)URL textField:(NSDictionary *)textField fileField:(NSDictionary *)fileField headers:(NSDictionary *)headers callback:(JTDataCallback *)callback
{
    return [[[JTDataTask alloc] initWithURL:URL textField:textField fileField:fileField headers:headers callback:callback] autorelease];
}

- (id)initWithMethod:(NSString *)method URL:(NSString *)URL params:(NSDictionary *)params headers:(NSDictionary *)headers callback:(JTDataCallback *)callback
{
    NSString *paramStr = nil;
    
    if(params && [params.allKeys count]>0)
    {
        NSMutableArray *paramKeyValues = [NSMutableArray array];
        for(NSString *key in params.allKeys)
        {
            [paramKeyValues addObject:[NSString stringWithFormat:@"%@=%@",key,params[key]]];
        }
        
        paramStr = [paramKeyValues componentsJoinedByString:@"&"];
    }
    
    if([[method uppercaseString] isEqualToString:@"GET"] || [[method uppercaseString] isEqualToString:@"DELETE"]|| [[method uppercaseString] isEqualToString:@"HEAD"])
    {
        self.URL = paramStr?[NSString stringWithFormat:@"%@?%@",URL,paramStr]:URL;
        _request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:self.URL]];
    }
    else if([[method uppercaseString] isEqualToString:@"POST"] || [[method uppercaseString] isEqualToString:@"PUT"] || [[method uppercaseString] isEqualToString:@"PATCH"])
    {
        self.URL = URL;
        _request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:self.URL]];
        [self setPostBody:paramStr];
    }
    
    [self setMethod:method];
    
    if(headers && (NSNull *)headers != [NSNull null])
    {
        [self setHeaders:headers];
    }
    
    self.callback = callback;
    
    _data = [[NSMutableData alloc] init];
    _task = [[DataTaskURLSession dataTaskWithRequest:_request] retain];
    
    return self;
}

- (id)initWithMethod:(NSString *)method URL:(NSString *)URL params:(NSDictionary *)params callback:(JTDataCallback *)callback
{
    return [self initWithMethod:method URL:URL params:params headers:nil callback:callback];
}

- (id)initWithURL:(NSString *)URL textField:(NSDictionary *)textField fileField:(NSDictionary *)fileField headers:(NSDictionary *)headers callback:(JTDataCallback *)callback
{
    self.URL = URL;
    _request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:self.URL]];
    
    [self setMethod:@"POST"];
    
    if(headers && (NSNull *)headers != [NSNull null])
    {
        [self setHeaders:headers];
    }
    
    [self setFormDataWithTextField:textField withFileField:fileField];
    
    self.callback = callback;
    
    _data = [[NSMutableData alloc] init];
    _task = [[DataTaskURLSession dataTaskWithRequest:_request] retain];
    
    return self;
}

- (void)dealloc
{
    [_request release];
    [_task release];
    [_data release];
    self.URL = nil;
    self.callback = nil;
    self.responseString = nil;
    self.error = nil;
    
    [super dealloc];
}

- (void)setMethod:(NSString *)method
{
    if(_request)
    {
        [_request setHTTPMethod:method];
    }
}

- (void)setPostBody:(NSString *)bodyString
{
    if(_request)
    {
        NSData *postData=[bodyString dataUsingEncoding:NSUTF8StringEncoding];
        [_request setHTTPBody:postData];
    }
}

- (void)setHeader:(NSString *)key value:(NSString *)value
{
    if(_request)
    {
        [_request addValue:value forHTTPHeaderField:key];
    }
}

- (void)setHeaders:(NSDictionary *)headers
{
    for(NSString *header in headers.allKeys)
    {
        NSString *value = headers[header];
        [_request addValue:value forHTTPHeaderField:header];
    }
}

- (void)setFormDataWithTextField:(NSDictionary *)textField withFileField:(NSDictionary *)fileField
{
    if(_request)
    {
        [_request setFormDataWithTextField:textField withFileField:fileField];
    }
}

- (void)start
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

@end
