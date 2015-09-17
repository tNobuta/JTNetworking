//
//  DataCenter.m
//  Surrounding
//
//  Created by tmy on 12-2-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "JTDataLoader.h"

static JTDataLoader *SharedLoader;

@implementation JTDataLoader
{
    NSMutableArray      *_currentRequests;
    Reachability        *_reachability;
}

@dynamic isNetworkValid,isWiFiValid;

+ (JTDataLoader *)sharedLoader
{
    @synchronized(self)
    {
        if(!SharedLoader)
        {
            SharedLoader = [[super allocWithZone:nil] init];
        }
    }
   
    return SharedLoader;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[JTDataLoader sharedLoader] retain];
}

- (unsigned)retainCount
{
    return UINT_MAX;
}

- (id)retain
{
    return self;
}

- (oneway void)release
{
    
}

- (BOOL)isNetworkValid
{
    return  _reachability.currentReachabilityStatus != NotReachable && !_reachability.connectionRequired;
}

- (BOOL)isWiFiValid
{
    return _reachability.currentReachabilityStatus == ReachableViaWiFi;
}

- (id)init
{
    if(self=[super init])
    {
        _currentRequests = [[NSMutableArray alloc] init];
        _reachability = [[Reachability reachabilityForInternetConnection] retain];
        [_reachability startNotifier];

    }
    
    return self;
}

- (void)dealloc
{
    [_currentRequests makeObjectsPerformSelector:@selector(cancel)];
    [_currentRequests removeAllObjects];
    [_reachability stopNotifier];
    [_reachability release];
    [super dealloc];
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


- (JTHttpRequest *)requestWithMethod:(NSString *)httpMethod
                         url:(NSString *)url
                      params:(NSDictionary *)params
                     headers:(NSDictionary *)headers
                    callback:(JTCallback *)callback
{
    if([_currentRequests count] == 0)
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
    
    JTHttpRequest *request = nil;
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
    
    if([[httpMethod uppercaseString] isEqualToString:@"GET"] || [[httpMethod uppercaseString] isEqualToString:@"DELETE"]|| [[httpMethod uppercaseString] isEqualToString:@"HEAD"])
    {
        request = [JTHttpRequest requestWithURL:paramStr?[NSString stringWithFormat:@"%@?%@",url,paramStr]:url delegate:self];
    }
    else if([[httpMethod uppercaseString] isEqualToString:@"POST"] || [[httpMethod uppercaseString] isEqualToString:@"PUT"] || [[httpMethod uppercaseString] isEqualToString:@"PATCH"])
    {
        request = [JTHttpRequest requestWithURL:url postBody:paramStr delegate:self];
    }
    
    [request setMethod:httpMethod];
    
    if(headers)
    {
        for(NSString *key in headers)
        {
            [request setHeader:key value:headers[key]];
        }
    }
    
    [request setDownloadProgressHandler:callback.downloadProcessHandler];
    [request setUploadProgressHandler:callback.uploadProcessHandler];
    request.contextObject = callback;
    [_currentRequests addObject:request];
    [request start];
    
    return request;
}



- (JTHttpRequest *)request:(JTHttpRequest *)request callback:(JTCallback *)callback
{
    if([_currentRequests count] == 0)
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
    
    request.contextObject = callback;
    [_currentRequests addObject:request];
    [request start];
    return request;
}

- (JTHttpRequest *)GET:(NSString *)url params:(NSDictionary *)params callback:(JTCallback *)callback
{
    return [self requestWithMethod:@"GET" url:url params:params headers:nil callback:callback];
}

- (JTHttpRequest *)GET:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary *)headers callback:(JTCallback *)callback
{
   return [self requestWithMethod:@"GET" url:url params:params headers:headers callback:callback];
}

- (JTHttpRequest *)POST:(NSString *)url params:(NSDictionary *)params callback:(JTCallback *)callback
{
   return [self requestWithMethod:@"POST" url:url params:params headers:nil callback:callback];
}

- (JTHttpRequest *)POST:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary *)headers callback:(JTCallback *)callback
{
   return [self requestWithMethod:@"POST" url:url params:params headers:headers  callback:callback];
}

- (JTHttpRequest *)POST:(NSString *)url
               textData:(NSDictionary *)textData
               fileData:(NSDictionary *)fileData
               callback:(JTCallback *)callback
{
    if([_currentRequests count] == 0)
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
    
    JTHttpRequest *request = nil;
    request = [JTHttpRequest requestWithURL:url];
    [request setFormDataWithTextField:textData withFileField:fileData];
    request.contextObject = callback;
    [_currentRequests addObject:request];
    [request start];
    return request;
}

- (JTHttpRequest *)PUT:(NSString *)url params:(NSDictionary *)params callback:(JTCallback *)callback
{
    return [self requestWithMethod:@"PUT" url:url params:params headers:nil callback:callback];
}

- (JTHttpRequest *)PUT:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary *)headers callback:(JTCallback *)callback
{
    return [self requestWithMethod:@"PUT" url:url params:params headers:headers  callback:callback];
}

- (JTHttpRequest *)HEAD:(NSString *)url params:(NSDictionary *)params callback:(JTCallback *)callback
{
    return [self requestWithMethod:@"HEAD" url:url params:params headers:nil callback:callback];
}

- (JTHttpRequest *)HEAD:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary *)headers callback:(JTCallback *)callback
{
    return [self requestWithMethod:@"HEAD" url:url params:params headers:headers  callback:callback];
}

- (JTHttpRequest *)PATCH:(NSString *)url params:(NSDictionary *)params callback:(JTCallback *)callback
{
    return [self requestWithMethod:@"PATCH" url:url params:params headers:nil callback:callback];
}

- (JTHttpRequest *)PATCH:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary *)headers callback:(JTCallback *)callback
{
    return [self requestWithMethod:@"PATCH" url:url params:params headers:headers  callback:callback];
}

- (JTHttpRequest *)DELETE:(NSString *)url params:(NSDictionary *)params callback:(JTCallback *)callback
{
    return [self requestWithMethod:@"DELETE" url:url params:params headers:nil callback:callback];
}

- (JTHttpRequest *)DELETE:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary *)headers callback:(JTCallback *)callback
{
    return [self requestWithMethod:@"DELETE" url:url params:params headers:headers  callback:callback];
}

- (void)cancelRequest:(id)target
{
    NSIndexSet *toRemoveIndexes = [_currentRequests  indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        JTCallback *callback = ((JTHttpRequest *)obj).contextObject;
        return callback.target == target;
    }];
    
    NSArray *toRemoveRequests = [_currentRequests objectsAtIndexes:toRemoveIndexes];
    [toRemoveRequests makeObjectsPerformSelector:@selector(cancel)];
    [_currentRequests removeObjectsInArray:toRemoveRequests];
    
    if([_currentRequests count] == 0)
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}

- (void)cancelRequest:(id)target url:(NSString *)url
{
    NSIndexSet *toRemoveIndexes = [_currentRequests  indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        JTCallback *callback = ((JTHttpRequest *)obj).contextObject;
        return callback.target == target && [((JTHttpRequest *)obj).url isEqualToString:url];
    }];
    
    NSArray *toRemoveRequests = [_currentRequests objectsAtIndexes:toRemoveIndexes];
    [toRemoveRequests makeObjectsPerformSelector:@selector(cancel)];
    [_currentRequests removeObjectsInArray:toRemoveRequests];
    
    if([_currentRequests count] == 0)
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
    
}


- (void)requestDidSuccess:(JTHttpRequest *)request
{
    JTCallback *callback = (JTCallback *)request.contextObject;
    
    if(callback.successBlock)
    {
        callback.successBlock(request);
    }
    else
    {
        if(callback.successSel)
        {
            [callback.target performSelector:callback.successSel withObject:request];
        }
        else if([callback.target respondsToSelector: @selector(requestDidSuccess:)])
        {
            [callback.target performSelector:@selector(requestDidSuccess:) withObject:request];
        }
    }
    
    [_currentRequests removeObject:request];
    
    if([_currentRequests count] == 0)
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}

- (void)requestDidFail:(JTHttpRequest *)request
{
    JTCallback *callback = (JTCallback *)request.contextObject;
    
    if(callback.failBlock)
    {
        callback.failBlock(request);
    }
    else
    {
        if(callback.failSel)
        {
            [callback.target performSelector:callback.failSel withObject:request];
        }
        else if([callback.target respondsToSelector:@selector(requestDidFail:)])
        {
            [callback.target performSelector:@selector(requestDidFail:) withObject:request];
        }

    }
    
    [_currentRequests removeObject:request];
    
    if([_currentRequests count] == 0)
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}

@end
