//
//  EXURLConnection.m
//  qdqddadadadad
//
//  Created by Jason Tang on 9/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JTHttpRequest.h"
#import "NSMutableURLRequest+FormData.h"

#define TIMEOUT_DURATION 15


@implementation JTHttpRequest
{
    id<JTHttpRequestDelegate>   _delegate;
    NSString                    *_url;
    NSMutableURLRequest         *_request;
    NSURLConnection             *_con;
    NSMutableData               *_data;
    SEL                         _finishSelector;
    SEL                         _failSelector;
    NSTimer                     *_timer;
    float                       _receivedBytes;
    float                       _totalExpectedBytes;
    void(^_downloadProcessHandler)(JTHttpRequest *request, float progressValue);
    void(^_uploadProcessHandler)(JTHttpRequest *request, float progressValue);
}


@synthesize delegate=_delegate,tag,contextObject,url=_url,data=_data,finishSelector=_finishSelector,failSelector=_failSelector,responseString=_responseString,error=_error,statusCode;

+ (JTHttpRequest *)requestWithURL:(NSString *)url
{
    return [[[JTHttpRequest alloc] initWithURL:url] autorelease];
}

+ (JTHttpRequest *)requestWithURL:(NSString *)url delegate:(id<JTHttpRequestDelegate>)delegate finishSelector:(SEL)finishSel failSelector:(SEL)failSel
{
    return [[[JTHttpRequest alloc] initWithURL:url delegate:delegate finishSelector:finishSel failSelector:failSel] autorelease];
}

+ (JTHttpRequest *)requestWithURL:(NSString *)url delegate:(id<JTHttpRequestDelegate>)delegate
{
    return [[[JTHttpRequest alloc] initWithURL:url delegate:delegate] autorelease];
}

+ (JTHttpRequest *)requestWithURL:(NSString *)url postBody:(NSString *)postBody
{
    JTHttpRequest *request = [[JTHttpRequest alloc] initWithURL:url];
    [request setMethod:@"POST"];
    [request setPostBody:postBody];
    return [request autorelease];
}

+ (JTHttpRequest *)requestWithURL:(NSString *)url
                         postBody:(NSString *)postBody
                         delegate:(id<JTHttpRequestDelegate>)delegate
                   finishSelector:(SEL)finishSel
                     failSelector:(SEL)failSel
{
    JTHttpRequest *request = [[JTHttpRequest alloc] initWithURL:url
                                                       delegate:delegate
                                                 finishSelector:finishSel
                                                   failSelector:failSel];
    [request setMethod:@"POST"];
    [request setPostBody:postBody];
    return [request autorelease];
}


+ (JTHttpRequest *)requestWithURL:(NSString *)url
                         postBody:(NSString *)postBody
                         delegate:(id<JTHttpRequestDelegate>)delegate
{
    JTHttpRequest *request = [[JTHttpRequest alloc] initWithURL:url delegate:delegate];
    [request setMethod:@"POST"];
    [request setPostBody:postBody];
    return [request autorelease];
}



- (id)initWithURL:(NSString *)url
{
    if(self = [super init])
    {
       _request=[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]]; 
        _url = [url retain];
        _totalExpectedBytes = 0;
        _receivedBytes = 0;
    }

    return self;
}

- (id)initWithURL:(NSString *)url delegate:(id<JTHttpRequestDelegate>)delegate finishSelector:(SEL)finishSel failSelector:(SEL)failSel
{
    if(self = [self initWithURL:url])
    {
        self.delegate=delegate;
        self.finishSelector=finishSel;
        self.failSelector=failSel;
    }
    
    return self;
}


- (id)initWithURL:(NSString *)url delegate:(id<JTHttpRequestDelegate>)delegate
{
    if(self = [self initWithURL:url])
    {
        self.delegate=delegate;
    }
    
    return self;
}

- (void)dealloc
{    
    if(_con)
    {
        [_con cancel];
        [_con release]; 
    }
    
    [_request release];
    
    [_url release];
    [_data release];
    [_responseString release];
    [_error release];
    self.contextObject = nil;
    
    if(_downloadProcessHandler)
    {
        Block_release(_downloadProcessHandler);
    }
    
    if(_uploadProcessHandler)
    {
        Block_release(_uploadProcessHandler);
    }
    
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
        [_request setValue:value forHTTPHeaderField:key];
    }
}

- (void)setCachePolicy:(NSURLRequestCachePolicy)policy
{
    if(_request)
    {
        [_request setCachePolicy:policy];
    }
}

- (void)setFormDataWithTextField:(NSDictionary *)textField withFileField:(NSDictionary *)fileField
{
    if(_request)
    {
        [_request setFormDataWithTextField:textField withFileField:fileField];
    }
}

- (void)setDownloadProgressHandler:(void(^)(JTHttpRequest *request, float progressValue))downloadProcessHandler
{
    if(_downloadProcessHandler)
    {
        Block_release(_downloadProcessHandler);
    }
    
    _downloadProcessHandler = Block_copy(downloadProcessHandler);
}

- (void)setUploadProgressHandler:(void(^)(JTHttpRequest *request, float progressValue))uploadProcessHandler
{
    if(_uploadProcessHandler)
    {
        Block_release(_uploadProcessHandler);
    }
    
    _uploadProcessHandler = Block_copy(uploadProcessHandler);
}


- (void)start
{
    if(_data)
    {
        [_data release];
    }
    
    _data=[[NSMutableData alloc] init];
    _con=[[NSURLConnection alloc] initWithRequest:_request delegate:self];
    _timer = [NSTimer scheduledTimerWithTimeInterval:TIMEOUT_DURATION target:self selector:@selector(timeOut) userInfo:nil repeats:YES];
    [self retain];
}

- (void)cancel
{
    if(_timer)
        [_timer invalidate];
    
    [_con cancel];
    [_data release];
    _data = nil;

    [self release];
}

- (void)timeOut
{
    if(_con)
    {
        [_con cancel];
        [_con release];
        _con = nil;
    }
    
    [self connection:_con didFailWithError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorTimedOut userInfo:nil]];
}

#pragma mark NSURLConnectionDelegagte

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.statusCode = ((NSHTTPURLResponse *)response).statusCode;
    _totalExpectedBytes = ((NSHTTPURLResponse *)response).expectedContentLength;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_data appendData:data];
    _receivedBytes += [data length];
    if(_downloadProcessHandler)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            _downloadProcessHandler(self, _totalExpectedBytes>0?_receivedBytes/_totalExpectedBytes:0); 
        });
    }
}


- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
     if(_uploadProcessHandler)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             _uploadProcessHandler(self, totalBytesExpectedToWrite>0?(float)totalBytesWritten/(float)totalBytesExpectedToWrite:0);
         });
     }
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.responseString = [[[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding] autorelease];
    
    if(self.delegate)
    {
        if(self.finishSelector)
        {
            [self.delegate performSelector:self.finishSelector withObject:self];
        }
        else if([self.delegate respondsToSelector:@selector(requestDidSuccess:)])
        {
            [self.delegate requestDidSuccess:self];
        }
    }
    
    [_con release];
    _con = nil;

    if(_timer)
        [_timer invalidate];
    
    [self release];
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.error=error;
    
    if(self.delegate)
    {
        if(self.failSelector)
        {
            [self.delegate performSelector:self.failSelector withObject:self];
        }
        else if([self.delegate respondsToSelector:@selector(requestDidFail:)])
        {
            [self.delegate requestDidFail:self];
        }
    }
    
    [_con release];
    _con = nil;
    
    if(_timer)
        [_timer invalidate];
 
    [self release];
}

@end
