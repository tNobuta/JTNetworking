//
//  SenderInfo.h
//  HaiTao
//
//  Created by tmy on 12-12-24.
//
//
#import <Foundation/Foundation.h>
#import "JTHttpRequest.h"

@interface JTCallback : NSObject

@property (nonatomic,retain) id target;
@property (nonatomic) SEL   successSel;
@property (nonatomic) SEL   failSel;

@property (nonatomic,copy) void(^downloadProcessHandler)(JTHttpRequest *request, float progressValue);
@property (nonatomic,copy) void(^uploadProcessHandler)(JTHttpRequest *request, float progressValue);
@property (nonatomic,copy) void(^successBlock)(JTHttpRequest *);
@property (nonatomic,copy) void(^failBlock)(JTHttpRequest *);

+ (JTCallback *)callbackWithTarget:(id)target successSelector:(SEL)finishSelector failSelector:(SEL)failSelector;

+ (JTCallback *)callbackWithTarget:(id)target successBlock:(void(^)(JTHttpRequest * request))successBlock failBlock:(void(^)(JTHttpRequest * request))failBlock;

- (id)initWithTarget:(id)target successSelector:(SEL)finishSelector failSelector:(SEL)failSelector;

- (id)initWithTarget:(id)target successBlock:(void(^)(JTHttpRequest *request))successBlock failBlock:(void(^)(JTHttpRequest *request))failBlock;


@end


NS_INLINE JTCallback *Callback_Default(id target)
{
    return [JTCallback callbackWithTarget:target successSelector:nil failSelector:nil];
}

NS_INLINE JTCallback *Callback_Selector(id target,SEL finishSeletor,SEL failSelector)
{
    return [JTCallback callbackWithTarget:target successSelector:finishSeletor failSelector:failSelector];
}

NS_INLINE JTCallback *Callback_Block(id target,void(^successBlock)(JTHttpRequest * request),void(^failBlock)(JTHttpRequest * request))
{
    return [JTCallback callbackWithTarget:target successBlock:successBlock failBlock:failBlock];
}
 

