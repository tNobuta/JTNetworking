//
//  NSMutableURLRequest+FormData.h
//  JTNetworkingDemo
//
//  Created by Admin on 10/15/13.
//  Copyright (c) 2013 nobuta. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableURLRequest (FormData)
- (void)setFormDataWithTextField:(NSDictionary *)textField withFileField:(NSDictionary *)fileField;
@end
