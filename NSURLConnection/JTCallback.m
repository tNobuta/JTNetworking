//
//  SenderInfo.m
//  HaiTao
//
//  Created by tmy on 12-12-24.
//
//

#import "JTCallback.h"

@implementation JTCallback

+ (JTCallback *)callbackWithTarget:(id)target successSelector:(SEL)finishSelector failSelector:(SEL)failSelector
{
    return [[[JTCallback alloc] initWithTarget:target successSelector:finishSelector failSelector:failSelector] autorelease];
}

+ (JTCallback *)callbackWithTarget:(id)target successBlock:(void (^)(JTHttpRequest *))successBlock failBlock:(void (^)(JTHttpRequest *))failBlock
{
    return [[[JTCallback alloc] initWithTarget:target successBlock:successBlock failBlock:failBlock] autorelease];
}

- (id)initWithTarget:(id)target successSelector:(SEL)finishSelector failSelector:(SEL)failSelector
{
    if(self = [super init])
    {
        self.target = target;
        self.successSel = finishSelector;
        self.failSel = failSelector;
    }
    
    return self;
}


- (id)initWithTarget:(id)target successBlock:(void (^)(JTHttpRequest *))successBlock failBlock:(void (^)(JTHttpRequest *))failBlock
{
    if(self = [super init])
    {
        self.target = target;
        self.successBlock = successBlock;
        self.failBlock = failBlock;
    }
    
    return self;
}


- (void)dealloc
{
    self.target = nil;
    Block_release(self.successBlock);
    Block_release(self.failBlock);
    Block_release(self.downloadProcessHandler);
    Block_release(self.uploadProcessHandler);
    [super dealloc];
}

@end
