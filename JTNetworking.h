//
//  JTDataKit.h
//  dadadada
//
//  Created by tmy on 13-6-21.
//  Copyright (c) 2013年 tmy. All rights reserved.
//


#ifndef JTDataKit_h
#define JTDataKit_h

#import "JTDataLoader.h"
#import "JTCallback.h"
#import "JTHttpRequest.h"

#if (defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000 )
#import "JTURLSessionManager.h"
#import "JTDataTask.h"
#import "JTDownloadTask.h"
#import "JTUploadTask.h"
#import "JTDataCallback.h"
#import "JTDownloadCallback.h"
#import "JTUploadCallback.h"

#endif

#endif
