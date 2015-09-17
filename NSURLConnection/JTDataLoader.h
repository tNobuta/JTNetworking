//
//  DataCenter.h
//  Surrounding
//
//  Created by tmy on 12-2-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JTHttpRequest.h"
#import "JTCallback.h"
#import "Reachability.h"

@interface JTDataLoader : NSObject<JTHttpRequestDelegate>
 
@property (nonatomic)  BOOL  isNetworkValid;
@property (nonatomic)  BOOL  isWiFiValid;

+ (JTDataLoader *)sharedLoader;

- (NSString *)messageForNetworkError:(int) errorCode;

- (JTHttpRequest *)requestWithMethod:(NSString *)httpMethod
                      url:(NSString *)url
                   params:(NSDictionary *)params
                  headers:(NSDictionary *)headers
                 callback:(JTCallback *)callback;

- (JTHttpRequest *)request:(JTHttpRequest *)request callback:(JTCallback *)callback;

- (JTHttpRequest *)GET:(NSString *)url params:(NSDictionary *)params callback:(JTCallback *)callback;
- (JTHttpRequest *)GET:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary *)headers callback:(JTCallback *)callback;

- (JTHttpRequest *)POST:(NSString *)url params:(NSDictionary *)params callback:(JTCallback *)callback;
- (JTHttpRequest *)POST:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary *)headers callback:(JTCallback *)callback;

- (JTHttpRequest *)POST:(NSString *)url
               textData:(NSDictionary *)textData
               fileData:(NSDictionary *)fileData
               callback:(JTCallback *)callback;

- (JTHttpRequest *)PUT:(NSString *)url params:(NSDictionary *)params callback:(JTCallback *)callback;
- (JTHttpRequest *)PUT:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary *)headers callback:(JTCallback *)callback;

- (JTHttpRequest *)HEAD:(NSString *)url params:(NSDictionary *)params callback:(JTCallback *)callback;
- (JTHttpRequest *)HEAD:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary *)headers callback:(JTCallback *)callback;

- (JTHttpRequest *)PATCH:(NSString *)url params:(NSDictionary *)params callback:(JTCallback *)callback;
- (JTHttpRequest *)PATCH:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary *)headers callback:(JTCallback *)callback;

- (JTHttpRequest *)DELETE:(NSString *)url params:(NSDictionary *)params callback:(JTCallback *)callback;
- (JTHttpRequest *)DELETE:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary *)headers callback:(JTCallback *)callback;

- (void)cancelRequest:(id)target;
- (void)cancelRequest:(id)target url:(NSString *)url;
 
 
@end

