//
//  Conversation.h
//  BlocTalk
//
//  Created by Robert von Stange on 10/27/15.
//  Copyright (c) 2015 Robert von Stange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Conversation : NSObject

@property (nonatomic, strong) NSString *idNumber;
@property (nonatomic, strong) User *currentUser;
@property (nonatomic, strong) User *otherUser;


@end
