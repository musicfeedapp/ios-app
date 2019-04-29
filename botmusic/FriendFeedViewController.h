//
//  FriendFeedViewController.h
//  botmusic
//
//  Created by Dzionis Brek on 17.03.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import "FeedViewController.h"

//FeedViewController must not be super for self
//incorrect hierarchy
@interface FriendFeedViewController : FeedViewController

@property (nonatomic, strong) NSString* facebookFriendID;
@property (nonatomic, strong) NSString* friendName;


@end
