//
//  NetworkClient.m
//  TeenDrive
//
//  Created by Илья Романеня on 26.09.13.
//  Copyright (c) 2013 wellnuts. All rights reserved.
//

#import "IRNetworkClient.h"
#import "Reachability.h"
#import "MFNotificationManager.h"
#import <Mixpanel.h>
#import "FBSDKCoreKit.h"

@implementation IRNetworkClient

+ (IRNetworkClient *)sharedInstance
{
    static IRNetworkClient *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      sharedInstance = [[IRNetworkClient alloc] initWithBaseURL:BASE_URL];
                      // Do any other initialisation stuff here
                  });
    return sharedInstance;
}

- (id)initWithBaseURL:(NSURL*)url
{
    self = [super initWithBaseURL:url];
	
    if (self) {
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        self.parameterEncoding = AFJSONParameterEncoding;
        self.profileClient = [[AFHTTPClient alloc] initWithBaseURL:V2_BASE_URL];
        if (self.profileClient) {
            [self.profileClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
            self.profileClient.parameterEncoding = AFJSONParameterEncoding;
        }
    }
	
    return self;
}

+ (BOOL)isReachable
{
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - Base requests

- (void)profileWithEmail:(NSString*)email
                   token:(NSString*)token
            successBlock:(RequestSuccessBlockWithUser)successBlock
            failureBlock:(FailureBlock)failureBlock
{
    NSString* path = [NSString stringWithFormat:@"v3/profile.json"];
    
    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{
                                       }];

	[self getPath:path
                     parameters:params
                        success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLogExt(@"Login success.");
         if ([responseObject isKindOfClass:[NSDictionary class]])
         {
             successBlock(responseObject);
         }
         else
         {
             failureBlock(nil);
         }
         
     }
                        failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [self handleOperationFailure:operation];
         failureBlock(nil);
     }];
}

-(void)userProfileWithUsername:(NSString*)username
                  successBlock:(RequestSuccessBlockWithDictionary)successBlock
                  failureBlock:(FailureBlock)failureBlock
{
    NSString* path = [NSString stringWithFormat:@"v3/profile/show.json"];

    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{
                                       @"username":username
                                       }];

	[self getPath:path
                     parameters:params
                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                            NSLogExt(@"Login success.");
                            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                                successBlock(responseObject);
                            }
                            else {
                                failureBlock(nil);
                            }
                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            failureBlock(nil);
                        }
    ];
    
}

-(void)userFollowersWithUsername:(NSString*)username
                  successBlock:(RequestSuccessBlockWithDictionary)successBlock
                  failureBlock:(FailureBlock)failureBlock
{
    NSString* path = [NSString stringWithFormat:@"v3/profile/followers.json"];

    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{
                                       @"username":username
                                       }];

    [self getPath:path
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLogExt(@"Login success.");
              if ([responseObject isKindOfClass:[NSDictionary class]]) {
                  successBlock(responseObject);
              }
              else {
                  failureBlock(nil);
              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              failureBlock(nil);
          }
     ];
    
}

-(void)userFollowingWithUsername:(NSString*)username
                  successBlock:(RequestSuccessBlockWithDictionary)successBlock
                  failureBlock:(FailureBlock)failureBlock
{
    NSString* path = [NSString stringWithFormat:@"v3/profile/following.json"];
    

    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{
                                       @"username":username
                                       }];

    [self getPath:path
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLogExt(@"Login success.");
              if ([responseObject isKindOfClass:[NSDictionary class]]) {
                  successBlock(responseObject);
              }
              else {
                  failureBlock(nil);
              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              failureBlock(nil);
          }
     ];
    
}

-(void)refreshProfileWithSuccessBlock:(RequestSuccessBlockWithDictionary)successBlock
                         failureBlock:(FailureBlock)failureBlock
{
    NSString* path = [NSString stringWithFormat:@"profile/refresh.json"];
    

    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{
                                       }];

    [self getPath:path
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLogExt(@"Login success.");
         if ([responseObject isKindOfClass:[NSDictionary class]])
         {
             successBlock(responseObject);
         }
         else
         {
             failureBlock(nil);
         }
         
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         failureBlock(nil);
     }];
}

- (void)loginWithFacebookToken:(NSString*)token
                  successBlock:(RequestSuccessBlockWithUser)successBlock
                  failureBlock:(FailureBlock)failureBlock
{
    NSString * path = [NSString stringWithFormat:@"users/facebook.json"];

    NSDictionary* params = @{@"auth_token" : token};


    [self postPath:path
        parameters:params
           success:^(AFHTTPRequestOperation *operation, id responseObject){

               if ([responseObject isKindOfClass:[NSDictionary class]]){



                   successBlock(responseObject);

               }else{
                   failureBlock(nil);
               }
           }
           failure:^(AFHTTPRequestOperation *operation, NSError *error)
           {
               failureBlock([self handleServerError:error]);
           }];
}

- (void)loginWithEmail:(NSString*)email
              password:(NSString*)password
          successBlock:(RequestSuccessBlockWithUser)successBlock
          failureBlock:(FailureBlock)failureBlock
{
    NSString * path = [NSString stringWithFormat:@"users/signin.json"];
    
    NSDictionary* params = @{@"email" : email,
                             @"password" : password};


    [self postPath:path
        parameters:params
           success:^(AFHTTPRequestOperation *operation, id responseObject){
               
               if ([responseObject isKindOfClass:[NSDictionary class]]){
                   
                   
                   
                   successBlock(responseObject);
                   
               }else{
                   failureBlock(nil);
               }
           }
           failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         
         failureBlock([self handleServerError:error]);
     }];
}

- (void)signUpWithEmail:(NSString*)email
               password:(NSString*)password
               userName:(NSString*)userName
           successBlock:(RequestSuccessBlockWithUser)successBlock
           failureBlock:(FailureBlock)failureBlock
{
    NSString * path = [NSString stringWithFormat:@"users/signup.json"];

    NSDictionary* params = @{@"email" : email,
            @"password" : password,
            @"name" : userName};


    [self postPath:path
        parameters:params
           success:^(AFHTTPRequestOperation *operation, id responseObject){

               if ([responseObject isKindOfClass:[NSDictionary class]]){

                   successBlock(responseObject);

               } else {

                   failureBlock(nil);

               }
           }
           failure:^(AFHTTPRequestOperation *operation, NSError *error)
           {
               failureBlock([self handleServerError:error]);
           }];
}


#pragma mark - Feed requests

- (void)feedPageWithEmail:(NSString*)email
                    token:(NSString*)token
                 feedType:(NSString*)feedType
        lastFeedTimestamp:(NSString*)lastFeedTimestamp
               lastFeedId:(NSString*)lastFeedId
                  myFeeds:(BOOL)isMyFeeds
             successBlock:(RequestSuccessBlockWithFeed)successBlock
             failureBlock:(FailureBlock)failureBlock;
{
    [self feedPageWithEmail:email
                      token:token
           facebookFriendID:nil
                   feedType:feedType
          lastFeedTimestamp:lastFeedTimestamp
                 lastFeedId:lastFeedId
                    myFeeds:isMyFeeds
               successBlock:successBlock
               failureBlock:failureBlock];
    
}

- (void)feedPageWithEmail:(NSString*)email
                    token:(NSString*)token
         facebookFriendID:(NSString*)facebookID
                 feedType:(NSString*)feedType
        lastFeedTimestamp:(NSString*)lastFeedTimestamp
               lastFeedId:(NSString*)lastFeedId
                  myFeeds:(BOOL)isMyFeeds
             successBlock:(RequestSuccessBlockWithFeed)successBlock
             failureBlock:(FailureBlock)failureBlock
{
    NSString* path = [NSString stringWithFormat:@"timelines.json"];
    
    NSMutableDictionary* params = [self initalParams];

    if (!userManager.isLoggedIn) {
        path = [NSString stringWithFormat:@"v4/unsigned/tracks.json"];
        params = [@{
                    @"device_id":[self getDeviceId],
                    @"anonymous_mode":@"true",
                    } mutableCopy];
    } else {
        [params setObject:@(isMyFeeds) forKey:@"my"];

    }

    if (lastFeedTimestamp)
    {
        [params setObject:lastFeedTimestamp forKey:@"timestamp"];
    }
    if (![feedType isEqualToString:@"all"])
    {
        [params setObject:feedType forKey:@"feed_type"];
    }
    if (lastFeedId)
    {
        [params setObject:lastFeedId forKey:@"last_timeline_id"];
    }
    if (facebookID)
    {
        [params setObject:facebookID forKey:@"facebook_user_id"];
    }

	[self getPath:path
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLogExt(@"Feed request success.");

         if ([responseObject isKindOfClass:[NSArray class]])
         {
             successBlock(responseObject);
         }
         else
         {
             failureBlock(nil);
         }
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSString* errorReason = nil;
         
         if (operation.response)
         {
             errorReason = error.localizedRecoverySuggestion;
         }
         
         failureBlock([self handleServerError:error]);
     }];
}

#pragma mark - Follow requests

- (void)proposalsWithEmail:(NSString*)email
                     token:(NSString*)token
             onlyFollowing:(NSNumber*)onlyFollowing
              successBlock:(RequestSuccessBlockWithDictionary)successBlock
              failureBlock:(FailureBlock)failureBlock
{
    NSString* path = [NSString stringWithFormat:@"proposals.json"];

#ifdef DEBUG
    //email=@"alex.korsak@gmail.com";
    //token=@"alex.korsak@gmail.com";
#endif


    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{
                                       @"following" : onlyFollowing
                                       }];

	[self getPath:path
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLogExt(@"Proposals request success.");

         if ([responseObject isKindOfClass:[NSDictionary class]])
         {
             successBlock(responseObject);
         }
         else
         {
             failureBlock(nil);
         }
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSString* errorReason = nil;
         
         if (operation.response)
         {
             errorReason = error.localizedRecoverySuggestion;
         }
         
         failureBlock([self handleServerError:error]);
     }];
}

- (void)proposalsFollowedWithEmail:(NSString*)email
                             token:(NSString*)token
                      successBlock:(RequestSuccessBlockWithArray)successBlock
                      failureBlock:(FailureBlock)failureBlock
{
    NSString* path = [NSString stringWithFormat:@"proposals/followed.json"];
    
#ifdef DEBUG
    //email=@"alex.korsak@gmail.com";
    //token=@"alex.korsak@gmail.com";
#endif

    NSMutableDictionary* params = [self initalParams];


	[self getPath:path
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLogExt(@"Proposals request success.");

         if ([responseObject isKindOfClass:[NSArray class]])
         {
             successBlock(responseObject);
         }
         else
         {
             failureBlock(nil);
         }
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSString* errorReason = nil;
         
         if (operation.response)
         {
             errorReason = error.localizedRecoverySuggestion;
         }
         
         failureBlock([self handleServerError:error]);
     }];
}

- (void)putProposalsWithEmail:(NSString*)email
                        token:(NSString*)token
                    proposals:(NSArray*)proposals
                 successBlock:(RequestSuccessBlock)successBlock
                 failureBlock:(FailureBlock)failureBlock
{
    NSString* path = [NSString stringWithFormat:@"proposals.json"];

    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{
                                       @"ext_ids" : proposals
                                       }];

	[self.profileClient putPath:path
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLogExt(@"Proposals request success.");

         if ([responseObject isKindOfClass:[NSArray class]])
         {
             successBlock(responseObject);
         }
         else
         {
             failureBlock(nil);
         }
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         if (error.code == 3840)
         {
             successBlock(nil);
         }
         else
         {
             NSString* errorReason = nil;
             
             if (operation.response)
             {
                 errorReason = error.localizedRecoverySuggestion;
             }
             [self handleOperationFailure:operation];
             failureBlock([self handleServerError:error]);
         }
     }];
}

#pragma mark - Track requests

- (void)tracksWithEmail:(NSString*)email
                  token:(NSString*)token
           successBlock:(RequestSuccessBlockWithFeed)successBlock
           failureBlock:(FailureBlock)failureBlock
{
    NSString* path = [NSString stringWithFormat:@"songs.json"];
    
#ifdef DEBUG
    //email=@"alex.korsak@gmail.com";
    //token=@"alex.korsak@gmail.com";
#endif

    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{
                                       }];

	[self getPath:path
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLogExt(@"Tracks request success.");

         if ([responseObject isKindOfClass:[NSArray class]])
         {
             successBlock(responseObject);
         }
         else
         {
             failureBlock(nil);
         }
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSString* errorReason = nil;
         
         if (operation.response)
         {
             errorReason = error.localizedRecoverySuggestion;
         }
         
         failureBlock([self handleServerError:error]);
     }];
    
}


- (void)addTrackByFeedItemId:(NSString*)feedItemId
                   withEmail:(NSString*)email
                       token:(NSString*)token
                successBlock:(RequestSuccessBlockWithFeed)successBlock
                failureBlock:(FailureBlock)failureBlock
{
    NSString* path = [NSString stringWithFormat:@"songs.json"];
    
#ifdef DEBUG
    //email=@"alex.korsak@gmail.com";
    //token=@"alex.korsak@gmail.com";
#endif

    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{
                                       @"timeline_id" : feedItemId,
                                       }];

	[self postPath:path
        parameters:params
           success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         successBlock(responseObject);
     }
           failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSString* errorReason = nil;
         
         if (operation.response)
         {
             errorReason = error.localizedRecoverySuggestion;
         }
         [self handleOperationFailure:operation];
         failureBlock([self handleServerError:error]);
     }];
    
}

- (void)removeTrackByFeedItemId:(NSString*)feedItemId
                      withEmail:(NSString*)email
                          token:(NSString*)token
                   successBlock:(RequestSuccessBlockWithDictionary)successBlock
                   failureBlock:(FailureBlock)failureBlock
{
    NSString* path = [NSString stringWithFormat:@"songs/%@.json", feedItemId];
    
#ifdef DEBUG
    //email=@"alex.korsak@gmail.com";
    //token=@"alex.korsak@gmail.com";
#endif

    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{
                                       @"id" : feedItemId,
                                       }];

	[self deletePath:path
          parameters:params
             success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         successBlock(responseObject);
     }
             failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSString* errorReason = nil;
         
         if (operation.response)
         {
             errorReason = error.localizedRecoverySuggestion;
         }
         [self handleOperationFailure:operation];
         failureBlock([self handleServerError:error]);
     }];
}

#pragma mark - Timeline actions

-(void)deleteTrackById:(NSString*)trackId
             withEmail:(NSString*)email
                 token:(NSString*)token
          successBlock:(RequestSuccessBlock)successBlock
          failureBlock:(FailureBlock)failureBlock
{
    NSString* path = [NSString stringWithFormat:@"timelines/%@.json", trackId];

    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{
                                       @"id" : trackId,
                                       }];

	[self deletePath:path
          parameters:params
             success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [[Mixpanel sharedInstance] track:@"Track removed from feed"];
         [FBSDKAppEvents logEvent:@"Track removed from feed" parameters:@{@"trackID": trackId}];
         successBlock(responseObject);
     }
             failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSString* errorReason = nil;
         
         if (operation.response)
         {
             errorReason = error.localizedRecoverySuggestion;
         }
         [self handleOperationFailure:operation];
         failureBlock([self handleServerError:error]);
     }];
}
-(void)likeTrackById:(NSString*)trackId
           withEmail:(NSString*)email
               token:(NSString*)token
        successBlock:(RequestSuccessBlock)successBlock
        failureBlock:(FailureBlock)failureBlock
{
    NSString* path = [NSString stringWithFormat:@"timelines/%@/like.json", trackId];

    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{
                                       @"id" : trackId,
                                       }];

	[self putPath:path
          parameters:params
             success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [[Mixpanel sharedInstance] track:@"Track liked" properties:@{@"trackID": trackId}];
         [FBSDKAppEvents logEvent:@"Track liked" parameters:@{@"trackID": trackId}];
         successBlock(responseObject);
     }
             failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSString* errorReason = nil;
         
         if (operation.response)
         {
             errorReason = error.localizedRecoverySuggestion;
         }
         [self handleOperationFailure:operation];
         failureBlock([self handleServerError:error]);
     }];
}
-(void)unlikeTrackById:(NSString*)trackId
             withEmail:(NSString*)email
                 token:(NSString*)token
          successBlock:(RequestSuccessBlock)successBlock
          failureBlock:(FailureBlock)failureBlock
{
    NSString* path = [NSString stringWithFormat:@"timelines/%@/unlike.json", trackId];

    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{
                                       @"id" : trackId,
                                       }];

	[self putPath:path
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         successBlock(responseObject);
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSString* errorReason = nil;
         
         if (operation.response)
         {
             errorReason = error.localizedRecoverySuggestion;
         }
         [self handleOperationFailure:operation];
         failureBlock([self handleServerError:error]);
     }];
}

#pragma mark - Comment's requests

-(void)getTrackCommentById:(NSString*)trackId
                 withEmail:(NSString*)email
                     token:(NSString*)token
              successBlock:(RequestSuccessBlock)successBlock
              failureBlock:(FailureBlock)failureBlock
{
    NSString* path = [NSString stringWithFormat:@"timelines/%@/comments.json", trackId];
    
#ifdef DEBUG
    //email=@"alex.korsak@gmail.com";
    //token=@"alex.korsak@gmail.com";
#endif

    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{
                                       @"id" : trackId,
                                       }];

	[self getPath:path
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         successBlock(responseObject);
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSString* errorReason = nil;
         
         if (operation.response)
         {
             errorReason = error.localizedRecoverySuggestion;
         }
         
         failureBlock([self handleServerError:error]);
     }];
}
-(void)postTrackCommentById:(NSString*)trackId
                    comment:(NSString*)comment
                  withEmail:(NSString*)email
                      token:(NSString*)token
               successBlock:(RequestSuccessBlock)successBlock
               failureBlock:(FailureBlock)failureBlock
{
    NSString* path = [NSString stringWithFormat:@"timelines/%@/comments.json", trackId];

    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{
                                       @"id" : trackId,
                                       @"comment":comment,
                                       }];

	[self postPath:path
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         successBlock(responseObject);
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSString* errorReason = nil;
         
         if (operation.response)
         {
             errorReason = error.localizedRecoverySuggestion;
         }
         [self handleOperationFailure:operation];
         failureBlock([self handleServerError:error]);
     }];
}
-(void)removeTrackCommentByID:(NSString*)trackID
                    commentID:(NSString*)commentID
                 successBlock:(RequestSuccessBlock)successBlock
                 failureBlock:(FailureBlock)failureBlock
{
    NSString* path = [NSString stringWithFormat:@"v2/timelines/%@/comments/%@.json", trackID,commentID];

    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{
                                       @"timeline_id" : trackID,
                                       }];

	[self deletePath:path
        parameters:params
           success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         successBlock();
     }
           failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSString* errorReason = nil;
         
         if (operation.response)
         {
             errorReason = error.localizedRecoverySuggestion;
         }
         [self handleOperationFailure:operation];
         failureBlock([self handleServerError:error]);
     }];
}

-(void)editTrackCommentByID:(NSString*)trackID
                    commentID:(NSString*)commentID
                       text:(NSString*)text
                 successBlock:(RequestSuccessBlock)successBlock
                 failureBlock:(FailureBlock)failureBlock
{
    NSString* path = [NSString stringWithFormat:@"v2/timelines/%@/comments/%@.json", trackID,commentID];

    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{
                                       @"comment" : text,
                                       }];

    [self putPath:path
          parameters:params
             success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         successBlock();
     }
             failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSString* errorReason = nil;

         if (operation.response)
         {
             errorReason = error.localizedRecoverySuggestion;
         }
         [self handleOperationFailure:operation];
         failureBlock([self handleServerError:error]);
     }];
}

#pragma mark - Get video url

-(void)getUrlByUrl:(NSString*)url
         withEmail:(NSString*)email
             token:(NSString*)token
      successBlock:(RequestSuccessBlockWithUrl)successBlock
      failureBlock:(FailureBlock)failureBlock
{
    NSString* path = @"direct.json";
    
#ifdef DEBUG
    //email=@"alex.korsak@gmail.com";
    //token=@"alex.korsak@gmail.com";
#endif
    

    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{
                                       @"url" : url,
                                       }];

	[self postPath:path
        parameters:params
           success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSDictionary *responseDictionary=(NSDictionary*)responseObject;
         successBlock(responseDictionary[@"url"]);
     }
           failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSString* errorReason = nil;
         
         if (operation.response)
         {
             errorReason = error.localizedRecoverySuggestion;
         }
         
         failureBlock([self handleServerError:error]);
     }];
}

#pragma mark - Intro requests

-(void)getIntroWithEmail:(NSString*)email
                   token:(NSString*)token
                   successBlock:(RequestSuccessBlockWithDictionary)successBlock
                   failureBlock:(FailureBlock)failureBlock
{
    NSString* path = @"intro.json";
    
#ifdef DEBUG
    //email=@"alex.korsak@gmail.com";
    //token=@"alex.korsak@gmail.com";
#endif

    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{
                                       }];

	[self getPath:path
        parameters:params
           success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         @try {
             NSDictionary *responseDictionary=(NSDictionary*)responseObject;
             successBlock(responseDictionary);
         }
         @catch (NSException *exception) {
//             [EBNotifier logException:[NSException exceptionWithName:exception.name reason:exception.reason userInfo:responseObject] parameters:responseObject];
             failureBlock(@"Server error");
         }
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSString* errorReason = nil;
         
         if (operation.response)
         {
             errorReason = error.localizedRecoverySuggestion;
         }
         
         failureBlock([self handleServerError:error]);
     }];
}

#pragma mark - Suggestions request

-(void)getSuggestionsWithEmail:(NSString*)email
                         token:(NSString*)token
                  successBlock:(RequestSuccessBlockWithDictionary)successBlock
                  failureBlock:(FailureBlock)failureBlock
{
    NSString* path =@"suggestions.json";
    

    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{
                                       }];

	[self.profileClient getPath:path
        parameters:params
           success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         successBlock(responseObject);
     }
           failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSString* errorReason = nil;
         
         if (operation.response)
         {
             errorReason = error.localizedRecoverySuggestion;
         }
         
         failureBlock([self handleServerError:error]);
     }];
}

-(void)getSuggestionsFilteredWithEmail:(NSString*)email
                                 token:(NSString*)token
                            filterType:(NSString*)filterType
                          successBlock:(RequestSuccessBlockWithDictionary)successBlock
                          failureBlock:(FailureBlock)failureBlock
{
    NSString* path =@"v5/suggestions.json";
    

    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{
                                       }];

    if (filterType && ![filterType isEqualToString:@""]) {
        [params setValue:filterType forKey:@"filter_type"];
    }


    [self getPath:path
                     parameters:params
                        success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         successBlock(responseObject);
     }
                        failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSString* errorReason = nil;
         
         if (operation.response)
         {
             errorReason = error.localizedRecoverySuggestion;
         }
         
         failureBlock([self handleServerError:error]);
     }];
}

-(void)getSuggestionTimelinesWithArtistId:(NSString*)artistId
                                    email:(NSString*)email
                                    token:(NSString*)token
                             successBlock:(RequestSuccessBlockWithArray)successBlock
                             failureBlock:(FailureBlock)failureBlock
{
    NSString* path =[NSString stringWithFormat:@"suggestions/%@/timelines.json",artistId];
#ifdef DEBUG
    //email=@"alex.korsak@gmail.com";
    //token=@"alex.korsak@gmail.com";
#endif

    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{
                                       @"artist_id":artistId,
                                       }];

	[self getPath:path
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         successBlock(responseObject);
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSString* errorReason = nil;
         
         if (operation.response)
         {
             errorReason = error.localizedRecoverySuggestion;
         }
         
         failureBlock([self handleServerError:error]);
     }];
}

-(void)followSuggestionWithArtistId:(NSString*)artistId
                       successBlock:(RequestSuccessBlock)successBlock
                       failureBlock:(FailureBlock)failureBlock
{
    NSString* path =[NSString stringWithFormat:@"suggestions/%@/follow.json",artistId];
    

    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{
                                       @"artist_id":artistId,
                                       }];

	[self.profileClient postPath:path
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         successBlock(responseObject);
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSString* errorReason = nil;
         
         if (operation.response)
         {
             errorReason = error.localizedRecoverySuggestion;
         }
         [self handleOperationFailure:operation];
         failureBlock([self handleServerError:error]);
     }];
    
}

-(void)unfollowSuggestionWithArtistId:(NSString*)artistId
                         successBlock:(RequestSuccessBlock)successBlock
                         failureBlock:(FailureBlock)failureBlock
{
    successBlock();
    return;
}

#pragma mark - Post iTunes libary

-(void)postMusic:(NSString*)tracksInJSON
           email:(NSString*)email
           token:(NSString*)token
    successBlock:(RequestSuccessBlock)successBlock
    failureBlock:(FailureBlock)failureBlock
{
    NSString* path =@"/api/client/itunes";
    
#ifdef DEBUG
    //email=@"alex.korsak@gmail.com";
    //token=@"alex.korsak@gmail.com";
#endif
    

    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{
                                       @"tracks":tracksInJSON,
                                       }];

    [self postPath:path
        parameters:params
           success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         successBlock(responseObject);
     }
           failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSString* errorReason = nil;
         
         if (operation.response)
         {
             errorReason = error.localizedRecoverySuggestion;
         }
         
         failureBlock([self handleServerError:error]);
     }];
}

#pragma mark - Search

-(void)searchWithKeyword:(NSString*)keyWord
              searchType:(NSString*)type
                 success:(RequestSuccessBlockWithDictionary)successBlock
                 failure:(FailureBlock)failureBlock
{
    NSString* path =@"v3/search.json";

    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{
                                       @"keywords":keyWord,
                                       @"search_type": type,
                                       }];
    for (AFHTTPRequestOperation* operation in self.operationQueue.operations) {
        if ([operation.request.URL.path containsString:@"v3/search"]) {
            [operation cancel];
        }
    }
    [self getPath:path
        parameters:params
           success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         successBlock(responseObject);
     }
           failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSString* errorReason = nil;
         
         if (operation.response)
         {
             errorReason = error.localizedRecoverySuggestion;
         }
         
         failureBlock([self handleServerError:error]);
     }];
}

#pragma mark - Sharing

-(void)shareFacebook:(BOOL)share
             success:(RequestSuccessBlock)successBlock
             failure:(FailureBlock)failureBlock{
    NSString* path =@"share/facebook.json";
    

    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{
                                       @"share":@(share),
                                       }];

    [self postPath:path
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         successBlock();
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [self handleOperationFailure:operation];
         failureBlock(error.localizedDescription);
     }];
}
-(void)shareTwitter:(BOOL)share
             success:(RequestSuccessBlock)successBlock
             failure:(FailureBlock)failureBlock{
    NSString* path =@"share/twitter.json";

    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{
                                       @"share":@(share),
                                       }];

    [self postPath:path
        parameters:params
           success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         successBlock();
     }
           failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSString* errorReason = nil;
         
         if (operation.response)
         {
             errorReason = error.localizedRecoverySuggestion;
         }
         [self handleOperationFailure:operation];
         failureBlock([self handleServerError:error]);
     }];
}

#pragma mark - Playlists requests

- (void)getPlaylistsWithEmail:(NSString*)email
                        token:(NSString*)token
                        extId:(NSString*)extId
                 successBlock:(RequestSuccessBlockWithArray)successBlock
                 failureBlock:(FailureBlock)failureBlock
{
    NSString *path = [NSString stringWithFormat:@"playlists.json"];
    

    NSMutableDictionary* params = [self initalParams];
    if (extId){
        [params addEntriesFromDictionary:@{
                                       @"ext_id" : extId
                                       }];
    }
    [self getPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLogExt(@"Playlists request success.");

        if ([responseObject isKindOfClass:[NSArray class]]) {
            successBlock(responseObject);
        } else {
            failureBlock(nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *errorReason = nil;
        if (operation.response) {
            errorReason = error.localizedRecoverySuggestion;
        }
        failureBlock([self handleServerError:error]);
    }];
}

- (void)postPlaylistWithTitle:(NSString *)title
                      private:(BOOL)isPrivate
                        email:(NSString *)email
                        token:(NSString *)token
                 successBlock:(RequestSuccessBlockWithDictionary)successBlock
                 failureBlock:(FailureBlock)failureBlock
{
    NSString* path = [NSString stringWithFormat:@"playlists.json"];

    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{
                                       @"title" : title,
                                       @"is_private" : @(isPrivate),
                                       }];

    [self postPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            successBlock(responseObject);
        } else {
            failureBlock(nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *errorReason = nil;
        if (operation.response) {
            errorReason = error.localizedRecoverySuggestion;
        }
        [self handleOperationFailure:operation];
        failureBlock([self handleServerError:error]);
    }];
}

- (void)putPlaylistWithId:(NSString *)playlistId
                 newTitle:(NSString *)title
                    email:(NSString *)email
                    token:(NSString *)token
             successBlock:(RequestSuccessBlockWithDictionary)successBlock
             failureBlock:(FailureBlock)failureBlock
{
    NSString* path = [NSString stringWithFormat:@"playlists/%@.json", playlistId];
    

    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{
                                       @"title" : title
                                       }];

    [self putPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            successBlock(responseObject);
        } else {
            failureBlock(nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *errorReason = nil;
        if (operation.response) {
            errorReason = error.localizedRecoverySuggestion;
        }
        [self handleOperationFailure:operation];
        failureBlock([self handleServerError:error]);
    }];
}

- (void)getPlaylistsWithId:(NSString *)playlistId
                     extId:(NSString *)extId
            lastTimelineId:(NSString *)lastTimelineId
              successBlock:(RequestSuccessBlockWithDictionary)successBlock
              failureBlock:(FailureBlock)failureBlock
{
    NSString *path = [NSString stringWithFormat:@"playlists/%@.json", playlistId];
    
//#ifdef DEBUG
//    email = @"alex.korsak@gmail.com";
//    token = @"alex.korsak@gmail.com";
//#endif
    
    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{
                                       }];
    if (extId) {
        [params setObject:extId forKey:@"ext_id"];
    }
    if (lastTimelineId) {
        [params setObject:lastTimelineId forKey:@"last_timeline_id"];
    }

    [self getPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLogExt(@"Playlists request success.");

        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            successBlock(responseObject);
        } else {
            failureBlock(nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *errorReason = nil;
        if (operation.response) {
            errorReason = error.localizedRecoverySuggestion;
        }
        failureBlock([self handleServerError:error]);
    }];
}

- (void)deletePlaylistWithId:(NSString *)playlistId
                       email:(NSString *)email
                       token:(NSString *)token
                successBlock:(RequestSuccessBlockWithDictionary)successBlock
                failureBlock:(FailureBlock)failureBlock
{
    NSString *path = [NSString stringWithFormat:@"playlists/%@.json", playlistId];

    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{
                                       }];

    [self deletePath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            successBlock(responseObject);
        } else {
            failureBlock(nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *errorReason = nil;
        if (operation.response) {
            errorReason = error.localizedRecoverySuggestion;
        }
        [self handleOperationFailure:operation];
        failureBlock([self handleServerError:error]);
    }];
}

- (void)postPlaylistWithId:(NSString *)playlistId
                  songsIds:(NSArray *)timelinesIds
                     email:(NSString *)email
                     token:(NSString *)token
              successBlock:(RequestSuccessBlockWithDictionary)successBlock
              failureBlock:(FailureBlock)failureBlock
{
    NSString* path = [NSString stringWithFormat:@"playlists/%@/add.json", playlistId];

    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{
                                       @"timelines_ids" : timelinesIds
                                       }];

    [self postPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            
            [[Mixpanel sharedInstance] track:@"Track added into playlist"];
            [FBSDKAppEvents logEvent:@"Track added into playlist" parameters:@{@"trackID": [timelinesIds firstObject]}];
            successBlock(responseObject);
        } else {
            failureBlock(nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *errorReason = nil;
        if (operation.response) {
            errorReason = error.localizedRecoverySuggestion;
        }
        [self handleOperationFailure:operation];
        failureBlock([self handleServerError:error]);
    }];
}

- (void)deleteSongsWithPlaylistId:(NSString *)playlistId
                         songsIds:(NSArray *)timelinesIds
                            email:(NSString *)email
                            token:(NSString *)token
                     successBlock:(RequestSuccessBlockWithDictionary)successBlock
                     failureBlock:(FailureBlock)failureBlock
{
    NSString* path = [NSString stringWithFormat:@"playlists/%@/remove.json", playlistId];

    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{
                                       @"timelines_ids" : timelinesIds
                                       }];

    [self deletePath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            successBlock(responseObject);
        } else {
            failureBlock(nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *errorReason = nil;
        if (operation.response) {
            errorReason = error.localizedRecoverySuggestion;
        }
        [self handleOperationFailure:operation];

        failureBlock([self handleServerError:error]);
    }];
}


- (void)getPlaylistsWithUserId:(NSString *)userExtId
                         email:(NSString *)email
                         token:(NSString *)token
                  successBlock:(RequestSuccessBlockWithArray)successBlock
                  failureBlock:(FailureBlock)failureBlock
{
    NSString* path = [NSString stringWithFormat:@"playlists.json"];
    

    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{
                                       @"ext_id" : userExtId
                                       }];

    [self getPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLogExt(@"Playlists request success.");

        if ([responseObject isKindOfClass:[NSArray class]]) {
            successBlock(responseObject);
        } else {
            failureBlock(nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *errorReason = nil;
        if (operation.response) {
            errorReason = error.localizedRecoverySuggestion;
        }
        failureBlock([self handleServerError:error]);
    }];
}

- (void)putPlaylistWithId:(NSString *)playlistId
                  private:(BOOL)isPrivate
                    email:(NSString *)email
                    token:(NSString *)token
             successBlock:(RequestSuccessBlockWithDictionary)successBlock
             failureBlock:(FailureBlock)failureBlock
{
    NSString *path = [NSString stringWithFormat:@"playlists/%@.json", playlistId];

    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{
                                       @"is_private" : @(isPrivate)
                                       }];

    [self putPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            successBlock(responseObject);
        } else {
            failureBlock(nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *errorReason = nil;
        if (operation.response) {
            errorReason = error.localizedRecoverySuggestion;
        }
        [self handleOperationFailure:operation];

        failureBlock([self handleServerError:error]);
    }];
}

- (void)putPlaylistWithId:(NSString *)playlistId
                 newTitle:(NSString *)title
                  private:(BOOL)isPrivate
                    email:(NSString *)email
                    token:(NSString *)token
             successBlock:(RequestSuccessBlockWithDictionary)successBlock
             failureBlock:(FailureBlock)failureBlock
{
    NSString *path = [NSString stringWithFormat:@"playlists/%@.json", playlistId];

    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{
                                       @"is_private" : @(isPrivate),
                                       @"title" : title
                                       }];

    [self putPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            successBlock(responseObject);
        } else {
            failureBlock(nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *errorReason = nil;
        if (operation.response) {
            errorReason = error.localizedRecoverySuggestion;
        }
        [self handleOperationFailure:operation];

        failureBlock([self handleServerError:error]);
    }];
}

#pragma mark - Removed Tracks requests

- (void)getRemovedTracksWithEmail:(NSString *)email
                            token:(NSString *)token
                     successBlock:(RequestSuccessBlockWithArray)successBlock
                     failureBlock:(FailureBlock)failureBlock
{
    NSString *path = [NSString stringWithFormat:@"timelines/removed.json"];

    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{
                                       }];

    [self getPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLogExt(@"Removed tracks request success.");

        if ([responseObject isKindOfClass:[NSArray class]]) {
            successBlock(responseObject);
        } else {
            failureBlock(nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *errorReason = nil;
        if (operation.response) {
            errorReason = error.localizedRecoverySuggestion;
        }
        failureBlock([self handleServerError:error]);
    }];
}

- (void)restoreTrackWithId:(NSString *)trackId
                     email:(NSString *)email
                     token:(NSString *)token
              successBlock:(RequestSuccessBlockWithDictionary)successBlock
              failureBlock:(FailureBlock)failureBlock
{
    NSString* path = [NSString stringWithFormat:@"timelines/removed/%@/restore.json", trackId];
    

    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{
                                       }];

    [self postPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            successBlock(responseObject);
        } else {
            failureBlock(nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *errorReason = nil;
        if (operation.response) {
            errorReason = error.localizedRecoverySuggestion;
        }
        [self handleOperationFailure:operation];

        failureBlock([self handleServerError:error]);
    }];
}

#pragma mark - Activities requests

-(void)getActivitiesByTrackId:(NSString*)trackId
                    withEmail:(NSString*)email
                        token:(NSString*)token
                 successBlock:(RequestSuccessBlockWithArray)successBlock
                 failureBlock:(FailureBlock)failureBlock
{
    NSString* path = [NSString stringWithFormat:@"timelines/%@/comments.json", trackId];

    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{
                                       }];

    [self.profileClient getPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            successBlock(responseObject);
        } else {
            failureBlock(nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *errorReason = nil;
        if (operation.response) {
            errorReason = error.localizedRecoverySuggestion;
        }
        failureBlock([self handleServerError:error]);
    }];
}

- (void)connectToFacebookID:(NSString*)facebookID
                  withEmail:(NSString*)email
              facebookToken:(NSString*)facebookToken
                      token:(NSString*)token
               successBlock:(RequestSuccessBlockWithUser)successBlock
               failureBlock:(FailureBlock)failureBlock
{
    NSString* path = [NSString stringWithFormat:@"v3/profile.json"];

    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{
                                       @"facebook":
                                           @{
                                               @"auth_token": facebookToken,
                                               @"uid": facebookID
                                               },
                                       }];

    [self putPath:path
                     parameters:params
                        success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         if ([responseObject isKindOfClass:[NSArray class]])
         {
             successBlock(responseObject);
         }
         else
         {
             failureBlock(nil);
         }
         
     }
                        failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [self handleOperationFailure:operation];
         failureBlock(nil);
     }];
}

- (void)disconnectToFacebookWithToken:(NSString*)token
                            withEmail:(NSString*)email
                         successBlock:(RequestSuccessBlockWithUser)successBlock
                         failureBlock:(FailureBlock)failureBlock
{
    NSString* path = [NSString stringWithFormat:@"v3/profile.json"];
    

    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{
                                       @"facebook":
                                           @{
                                               @"destroy": @1,
                                               },
                                       }];

    [self putPath:path
                     parameters:params
                        success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         if ([responseObject isKindOfClass:[NSDictionary class]])
         {
             successBlock(responseObject);
         }
         else
         {
             failureBlock(nil);
         }
         
     }
                        failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [self handleOperationFailure:operation];
         failureBlock(nil);
     }];}

#pragma mark - Internal methods

- (void)handleOperationFailure:(AFHTTPRequestOperation *)operation
{
    if (!userManager.isLoggedIn && ([operation.response statusCode] == 401 || [operation.response statusCode] == 403)) {
        //Unauthorized
        [MFNotificationManager postUserUnauthorizedNotification];
    }
}

- (void)getNotificationsWithEmail:(NSString*)email
                            token:(NSString*)token
                             page:(NSInteger)page
                     successBlock:(RequestSuccessBlockWithArray)successBlock
                     failureBlock:(FailureBlock)failureBlock
{
    NSString* path = [NSString stringWithFormat:@"v3/notifications.json"];

    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{
                                       @"page_no" : @(page)
                                       }];

    [self getPath:path
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         if ([responseObject isKindOfClass:[NSArray class]])
         {
             successBlock(responseObject);
         }
         else
         {
             failureBlock(nil);
         }
         
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [self handleOperationFailure:operation];
         failureBlock(nil);
     }];
}

- (void)getNumberOfUnseenNotificationsSuccessBlock:(RequestSuccessBlockWithArray)successBlock
                                      failureBlock:(FailureBlock)failureBlock
{
    NSString* path = [NSString stringWithFormat:@"v3/notifications/unreviewed_notifications_count.json"];

    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{
                                       }];

    [self getPath:path
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         if ([responseObject isKindOfClass:[NSNumber class]])
         {
             successBlock(@[responseObject]);
         }
         else
         {
             failureBlock(nil);
         }

     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {

         [self handleOperationFailure:operation];
         if (operation.responseString.length<5) {
             NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
             f.numberStyle = NSNumberFormatterDecimalStyle;
             NSNumber* number = [f numberFromString:operation.responseString];
             if (number && [number integerValue]>=0 && [number integerValue]<10000) {
                 successBlock(@[number]);
             } else {
                 failureBlock(nil);
             }
         } else{
             failureBlock(nil);
         }
     }];
}


- (void)readNotificationByID:(NSNumber*)notif_id
                   withEmail:(NSString*)email
                       token:(NSString*)token
                successBlock:(RequestSuccessBlockWithArray)successBlock
                failureBlock:(FailureBlock)failureBlock
{
    NSString* path = [NSString stringWithFormat:@"v3/notifications/read.json"];


    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{
                                       @"notification_id" : notif_id
                                       }];

    [self postPath:path
        parameters:params
           success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         if ([responseObject isKindOfClass:[NSDictionary class]])
         {
             successBlock(responseObject);
         }
         else
         {
             failureBlock(nil);
         }

     }
           failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [self handleOperationFailure:operation];
         failureBlock(nil);
     }];
}

- (void)seenNotificationsByID:(NSArray*)notif_ids
                 successBlock:(RequestSuccessBlockWithArray)successBlock
                 failureBlock:(FailureBlock)failureBlock
{
    NSString* path = [NSString stringWithFormat:@"v3/notifications/seen_all.json"];


    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{
                                       @"notifications_ids" : notif_ids
                                       }];

    [self postPath:path
        parameters:params
           success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         if ([responseObject isKindOfClass:[NSArray class]])
         {
             successBlock(responseObject);
         }
         else
         {
             failureBlock(nil);
         }

     }
           failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [self handleOperationFailure:operation];
         failureBlock(nil);
     }];
}

- (void)postContactList:(NSArray*)contactsList
              successBlock:(RequestSuccessBlockWithDictionary)successBlock
              failureBlock:(FailureBlock)failureBlock
{
    NSString* path = @"v5/contacts.json";

    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{
                                       @"contact_list" : contactsList
                                       }];

    [self postPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {

            successBlock(responseObject);
        } else {
            failureBlock(nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *errorReason = nil;
        if (operation.response) {
            errorReason = error.localizedRecoverySuggestion;
        }
        failureBlock([self handleServerError:error]);
    }];
}

- (void)postPhoneArtistsList:(NSArray*)contactsList
                successBlock:(RequestSuccessBlockWithArray)successBlock
                failureBlock:(FailureBlock)failureBlock
{
    NSString* path = @"v5/phone_artists.json";

    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{
                                       @"phone_artists" : contactsList
                                       }];

    [self postPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //if ([responseObject isKindOfClass:[NSArray class]]) {

            successBlock(responseObject);

        //} else {
            //failureBlock(nil);
        //}
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *errorReason = nil;
        if (operation.response) {
            errorReason = error.localizedRecoverySuggestion;
        }
        failureBlock([self handleServerError:error]);
    }];
}

- (void)getPhoneArtistsSuccessBlock:(RequestSuccessBlockWithArray)successBlock
                failureBlock:(FailureBlock)failureBlock
{
    NSString* path = @"v5/phone_artists.json";

    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{
                                       }];

    [self getPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {

            successBlock(responseObject[@"artists"]);

        } else {
            failureBlock(nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *errorReason = nil;
        if (operation.response) {
            errorReason = error.localizedRecoverySuggestion;
        }
        failureBlock([self handleServerError:error]);
    }];
}

- (void)getAllGenresSuccessBlock:(RequestSuccessBlockWithArray)successBlock
                    failureBlock:(FailureBlock)failureBlock
{
    NSString* path = @"v5/genres/index.json";


    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{
                                       }];

    [self getPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {

            successBlock(responseObject);

        } else {
            failureBlock(nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *errorReason = nil;
        if (operation.response) {
            errorReason = error.localizedRecoverySuggestion;
        }
        failureBlock([self handleServerError:error]);
    }];
}

- (void)searchGenresWithKeyword:(NSString*)keyword
                   SuccessBlock:(RequestSuccessBlockWithArray)successBlock
                    failureBlock:(FailureBlock)failureBlock
{
    NSString* path = @"v5/genres/search.json";

    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{
                                       @"keyword": keyword
                                       }];
    [self getPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {

            successBlock(responseObject);

        } else {
            failureBlock(nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *errorReason = nil;
        if (operation.response) {
            errorReason = error.localizedRecoverySuggestion;
        }
        failureBlock([self handleServerError:error]);
    }];
}

- (void)postUserGenres:(NSArray*)genreIds
                SuccessBlock:(RequestSuccessBlockWithArray)successBlock
                   failureBlock:(FailureBlock)failureBlock
{
    NSString* path = @"v5/genres/user_genres.json";

    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{
                                       @"genre_ids": genreIds
                                       }];
    [self postPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {

            successBlock(responseObject);

        } else {
            failureBlock(nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *errorReason = nil;
        if (operation.response) {
            errorReason = error.localizedRecoverySuggestion;
        }
        [self handleOperationFailure:operation];

        failureBlock([self handleServerError:error]);
    }];
}

- (void)getUserGenresSuccessBlock:(RequestSuccessBlockWithArray)successBlock
                     failureBlock:(FailureBlock)failureBlock
{
    NSString* path = @"v5/genres/user_genres.json";

    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{

                                       }];
    [self getPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {

            successBlock(responseObject);

        } else {
            failureBlock(nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *errorReason = nil;
        if (operation.response) {
            errorReason = error.localizedRecoverySuggestion;
        }
        [self handleOperationFailure:operation];

        failureBlock([self handleServerError:error]);
    }];
}


- (void)findTrackByUrl:(NSString*)url
          SuccessBlock:(RequestSuccessBlockWithDictionary)successBlock
          failureBlock:(FailureBlock)failureBlock
{
    NSString* path = @"v5/publisher/find.json";
    
    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{
                                       @"url": url
                                       }];
    
    [self getPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            
            successBlock(responseObject);
            
        } else {
            failureBlock(nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *errorReason = nil;
        if (operation.response) {
            errorReason = error.localizedRecoverySuggestion;
        }
        failureBlock([self handleServerError:error]);
    }];
}

- (void)findTrackByName:(NSString*)name
                 artist:(NSString*)artist
           SuccessBlock:(RequestSuccessBlockWithDictionary)successBlock
           failureBlock:(FailureBlock)failureBlock
{
    NSString* path = @"v5/publisher/find.json";

    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{
                                       @"track": name,
                                       @"artist": artist
                                       }];

    [self getPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {

            successBlock(responseObject);

        } else {
            failureBlock(nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *errorReason = nil;
        if (operation.response) {
            errorReason = error.localizedRecoverySuggestion;
        }
        failureBlock([self handleServerError:error]);
    }];
}

- (void)publishTrackByID:(NSString*)ID
          SuccessBlock:(RequestSuccessBlockWithDictionary)successBlock
          failureBlock:(FailureBlock)failureBlock
{
    NSString* path = [NSString stringWithFormat: @"v5/publisher/publish/%@.json", ID];

    NSDictionary* params = [self initalParams];

    [self postPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {

            successBlock(responseObject);

        } else {
            failureBlock(nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *errorReason = nil;
        if (operation.response) {
            errorReason = error.localizedRecoverySuggestion;
        }
        [self handleOperationFailure:operation];
        failureBlock([self handleServerError:error]);
    }];
}

- (void)getSuggestionsCategoriesWithSuccessBlock:(RequestSuccessBlockWithArray)successBlock
                                    failureBlock:(FailureBlock)failureBlock
{
    NSString* path = @"v5/suggestions/categories.json";


    NSDictionary* params = [self initalParams];
    
    [self getPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            
            successBlock(responseObject);
            
        } else {
            failureBlock(nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *errorReason = nil;
        if (operation.response) {
            errorReason = error.localizedRecoverySuggestion;
        }
        failureBlock([self handleServerError:error]);
    }];
}

- (void)createUnsignedUserWithArtists:(NSArray*)artists
                          successBlock:(RequestSuccessBlockWithDictionary)successBlock
                          failureBlock:(FailureBlock)failureBlock
{
    NSString* path = @"v4/unsigned/user.json";

    NSDictionary* params = @{
                             @"device_id": [self getDeviceId],
                             @"phone_artists": artists
                             };

    [self postPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {

            successBlock(responseObject);

        } else {
            failureBlock(nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *errorReason = nil;
        if (operation.response) {
            errorReason = error.localizedRecoverySuggestion;
        }
        failureBlock([self handleServerError:error]);
    }];
}

-(void)getFacebookFriendsWithSuccessBlock:(RequestSuccessBlockWithArray)successBlock
                      failureBlock:(FailureBlock)failureBlock
{
    
    NSString* path = @"v5/users/friends.json";
    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{
                                       }];

    [self getPath:path
            parameters:params
            success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         successBlock(responseObject);
     }
                        failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSString* errorReason = nil;

         if (operation.response)
         {
             errorReason = error.localizedRecoverySuggestion;
         }

         failureBlock([self handleServerError:error]);
     }];
}

-(void)getTrendingTracksWithSuccessBlock:(RequestSuccessBlockWithArray)successBlock
                             failureBlock:(FailureBlock)failureBlock
{

    NSString* path = @"timelines/trending_tracks.json";
    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{
                                       }];

    [self getPath:path
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         successBlock(responseObject);
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSString* errorReason = nil;

         if (operation.response)
         {
             errorReason = error.localizedRecoverySuggestion;
         }

         failureBlock([self handleServerError:error]);
     }];
}

- (NSString *)getDeviceId
{
    NSString *udid = @"";

    if ([[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)]) {
        udid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    }


    return udid;
}

- (NSMutableDictionary*) initalParams{
    if (userManager.isLoggedIn) {

        NSMutableDictionary* dictionary = [@{
                                            @"email" : userManager.userInfo.email,
                                            @"authentication_token" : userManager.fbToken,
                                            } mutableCopy];
        return dictionary;

    } else {

        NSMutableDictionary* dictionary = [@{
                                             @"email" : @"anonymous",
                                             @"authentication_token" : @"anonymous",
                                             @"device_id":[self getDeviceId],
                                             @"anonymous_mode":@"true"
                                             } mutableCopy];
        return dictionary;

    }
}

-(void)updateProfile:(NSDictionary*)profile
              avatar:(UIImage*)avatar
        successBlock:(RequestSuccessBlockWithDictionary)successBlock
        failureBlock:(FailureBlock)failureBlock
{

    NSString* path = @"v5/users/update_profile.json";
    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{
                                       @"user": profile
                                       }];

//    [self putPath:path
//       parameters:params
//          success:^(AFHTTPRequestOperation *operation, id responseObject)
//     {
//         successBlock(responseObject);
//     }
//          failure:^(AFHTTPRequestOperation *operation, NSError *error)
//     {
//         NSString* errorReason = nil;
//
//         if (operation.response)
//         {
//             errorReason = error.localizedRecoverySuggestion;
//         }
//
//         failureBlock([self handleServerError:error]);
//     }];




    NSMutableURLRequest *request = [self multipartFormRequestWithMethod:@"PUT" path:path parameters:params constructingBodyWithBlock:^(id <AFMultipartFormData>formData) {
        if (avatar) {

            NSData *avatarData = UIImageJPEGRepresentation(avatar, 1.0);
            [formData appendPartWithFileData:avatarData
                                      name:@"user[avatar]"
                                    fileName:@"avatar.jpg" mimeType:@"image/jpeg"];
        }

    }];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        responseObject = [NSJSONSerialization JSONObjectWithData:responseObject options:nil error:nil];
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            successBlock(responseObject);
        } else {
            failureBlock(nil);
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString* errorReason = nil;

        if (operation.response)
        {
            errorReason = error.localizedRecoverySuggestion;
        }

        failureBlock([self handleServerError:error]);
    }];

    [self enqueueHTTPRequestOperation:operation];



}

-(void)getTrackByID:(NSString*)trackID
        successBlock:(RequestSuccessBlockWithDictionary)successBlock
        failureBlock:(FailureBlock)failureBlock
{

    NSString* path = [NSString stringWithFormat:@"timelines/%@.json", trackID];
    NSMutableDictionary* params = [self initalParams];
    [params addEntriesFromDictionary:@{
                                       }];

    [self getPath:path
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         successBlock(responseObject);
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSString* errorReason = nil;

         if (operation.response)
         {
             errorReason = error.localizedRecoverySuggestion;
         }

         failureBlock([self handleServerError:error]);
     }];
}

-(void)refreshFacebookToken:(NSString*)token
             expirationDate:(NSDate*)expDate
       successBlock:(RequestSuccessBlockWithDictionary)successBlock
       failureBlock:(FailureBlock)failureBlock
{

    NSString* path = @"v5/users/update_token";
    NSMutableDictionary* params = [self initalParams];
//    NSDateFormatter* f = [[NSDateFormatter alloc] init];
//    NSString* dateString = [f stringFromDate:expDate];
    [params addEntriesFromDictionary:@{
                                       @"auth_token": token,
                                       @"expires_at": [expDate description]
                                       }];

    [self putPath:path
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         successBlock(responseObject);
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSString* errorReason = nil;

         if (operation.response)
         {
             errorReason = error.localizedRecoverySuggestion;
         }

         failureBlock([self handleServerError:error]);
     }];
}

- (NSString*) handleServerError:(NSError*)error{
    NSString* jsonString = error.localizedRecoverySuggestion;
    if (jsonString) {
        NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if (json && [json isKindOfClass:[NSDictionary class]]) {
            NSDictionary* dict = json;
            NSArray* errors = dict[@"errors"];
            if (errors && [errors isKindOfClass:[NSArray class]] && errors.count > 0) {
                return [self titleForErrorId:errors[0][@"id"]];
            }
        }
    }

    return nil;
}

- (NSString*) titleForErrorId:(NSString*)errorID{
    if ([errorID isEqualToString:@"not_found_user"]) {
        return @"The email or password is incorrect";
    }
    if ([errorID isEqualToString:@"password"]) {
        return @"Passwords should be at least 6 characters, letters and numbers only";
    }
    if ([errorID isEqualToString:@"email"]) {
        return @"The email address is already in use";
    }

    return nil;
}
@end
