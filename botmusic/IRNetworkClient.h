//
//  NetworkClient.h
//  TeenDrive
//
//  Created by Илья Романеня on 26.09.13.
//  Copyright (c) 2013 wellnuts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AFNetworking/AFNetworking.h>

@interface IRNetworkClient : AFHTTPClient

@property (nonatomic, strong) AFHTTPClient *profileClient;

typedef void(^RequestSuccessBlockWithArray)(NSArray* array);
typedef void(^RequestSuccessBlockWithDictionary)(NSDictionary* dictionary);
typedef void(^RequestSuccessBlockWithUser)(NSDictionary* userData);
typedef void(^RequestSuccessBlockWithFeed)(NSArray* feedArrayData);
typedef void(^RequestSuccessBlock)();
typedef void(^FailureBlock)(NSString *errorMessage);
typedef void(^RequestSuccessBlockWithUrl)(NSString* url);

+ (IRNetworkClient *)sharedInstance;

- (void)profileWithEmail:(NSString*)email
                   token:(NSString*)token
            successBlock:(RequestSuccessBlockWithUser)successBlock
            failureBlock:(FailureBlock)failureBlock;
-(void)userProfileWithUsername:(NSString*)username
                  successBlock:(RequestSuccessBlockWithDictionary)successBlock
                  failureBlock:(FailureBlock)failureBlock;
-(void)userFollowersWithUsername:(NSString*)username
                    successBlock:(RequestSuccessBlockWithDictionary)successBlock
                    failureBlock:(FailureBlock)failureBlock;
-(void)userFollowingWithUsername:(NSString*)username
                    successBlock:(RequestSuccessBlockWithDictionary)successBlock
                    failureBlock:(FailureBlock)failureBlock;
-(void)refreshProfileWithSuccessBlock:(RequestSuccessBlockWithDictionary)successBlock
                         failureBlock:(FailureBlock)failureBlock;

- (void)loginWithFacebookToken:(NSString*)token
                  successBlock:(RequestSuccessBlockWithUser)successBlock
                  failureBlock:(FailureBlock)failureBlock;

- (void)loginWithEmail:(NSString*)email
              password:(NSString*)password
          successBlock:(RequestSuccessBlockWithUser)successBlock
          failureBlock:(FailureBlock)failureBlock;

- (void)signUpWithEmail:(NSString*)email
               password:(NSString*)password
               userName:(NSString*)userName
           successBlock:(RequestSuccessBlockWithUser)successBlock
           failureBlock:(FailureBlock)failureBlock;

- (void)feedPageWithEmail:(NSString*)email
                    token:(NSString*)token
                 feedType:(NSString*)feedType
        lastFeedTimestamp:(NSString*)lastFeedTimestamp
               lastFeedId:(NSString*)lastFeedId
                  myFeeds:(BOOL)isMyFeeds
             successBlock:(RequestSuccessBlockWithFeed)successBlock
             failureBlock:(FailureBlock)failureBlock;

- (void)feedPageWithEmail:(NSString*)email
                    token:(NSString*)token
         facebookFriendID:(NSString*)facebookID
                 feedType:(NSString*)feedType
        lastFeedTimestamp:(NSString*)lastFeedTimestamp
               lastFeedId:(NSString*)lastFeedId
                  myFeeds:(BOOL)isMyFeeds
             successBlock:(RequestSuccessBlockWithFeed)successBlock
             failureBlock:(FailureBlock)failureBlock;

- (void)proposalsWithEmail:(NSString*)email
                     token:(NSString*)token
             onlyFollowing:(NSNumber*)onlyFollowing
              successBlock:(RequestSuccessBlockWithDictionary)successBlock
              failureBlock:(FailureBlock)failureBlock;

- (void)proposalsFollowedWithEmail:(NSString*)email
                             token:(NSString*)token
                      successBlock:(RequestSuccessBlockWithArray)successBlock
                      failureBlock:(FailureBlock)failureBlock;

- (void)putProposalsWithEmail:(NSString*)email
                        token:(NSString*)token
                    proposals:(NSArray*)proposals
                 successBlock:(RequestSuccessBlock)successBlock
                 failureBlock:(FailureBlock)failureBlock;

- (void)tracksWithEmail:(NSString*)email
                  token:(NSString*)token
           successBlock:(RequestSuccessBlockWithFeed)successBlock
           failureBlock:(FailureBlock)failureBlock;

- (void)addTrackByFeedItemId:(NSString*)feedItemId
                   withEmail:(NSString*)email
                       token:(NSString*)token
                successBlock:(RequestSuccessBlockWithFeed)successBlock
                failureBlock:(FailureBlock)failureBlock;

- (void)removeTrackByFeedItemId:(NSString*)feedItemId
                      withEmail:(NSString*)email
                          token:(NSString*)token
                   successBlock:(RequestSuccessBlockWithDictionary)successBlock
                   failureBlock:(FailureBlock)failureBlock;
-(void)deleteTrackById:(NSString*)trackId
             withEmail:(NSString*)email
                 token:(NSString*)token
          successBlock:(RequestSuccessBlock)successBlock
          failureBlock:(FailureBlock)failureBlock;
-(void)likeTrackById:(NSString*)trackId
             withEmail:(NSString*)email
                 token:(NSString*)token
          successBlock:(RequestSuccessBlock)successBlock
          failureBlock:(FailureBlock)failureBlock;
-(void)unlikeTrackById:(NSString*)trackId
           withEmail:(NSString*)email
               token:(NSString*)token
        successBlock:(RequestSuccessBlock)successBlock
        failureBlock:(FailureBlock)failureBlock;
-(void)getTrackCommentById:(NSString*)trackId
             withEmail:(NSString*)email
                 token:(NSString*)token
          successBlock:(RequestSuccessBlock)successBlock
          failureBlock:(FailureBlock)failureBlock;
-(void)postTrackCommentById:(NSString*)trackId
                    comment:(NSString*)comment
             withEmail:(NSString*)email
                 token:(NSString*)token
          successBlock:(RequestSuccessBlock)successBlock
          failureBlock:(FailureBlock)failureBlock;
-(void)removeTrackCommentByID:(NSString*)trackID
                    commentID:(NSString*)commentID
                 successBlock:(RequestSuccessBlock)successBlock
                 failureBlock:(FailureBlock)failureBlock;
-(void)getUrlByUrl:(NSString*)url
         withEmail:(NSString*)email
             token:(NSString*)token
      successBlock:(RequestSuccessBlockWithUrl)successBlock
      failureBlock:(FailureBlock)failureBlock;
-(void)getIntroWithEmail:(NSString*)email
                   token:(NSString*)token
                   successBlock:(RequestSuccessBlockWithDictionary)successBlock
                   failureBlock:(FailureBlock)failureBlock;
-(void)getSuggestionsWithEmail:(NSString*)email
                         token:(NSString*)token
                  successBlock:(RequestSuccessBlockWithDictionary)successBlock
                  failureBlock:(FailureBlock)failureBlock;
-(void)getSuggestionTimelinesWithArtistId:(NSString*)artistId
                                    email:(NSString*)email
                                    token:(NSString*)token
                             successBlock:(RequestSuccessBlockWithArray)successBlock
                             failureBlock:(FailureBlock)failureBlock;
-(void)followSuggestionWithArtistId:(NSString*)artistId
                       successBlock:(RequestSuccessBlock)successBlock
                       failureBlock:(FailureBlock)failureBlock;
-(void)unfollowSuggestionWithArtistId:(NSString*)artistId
                       successBlock:(RequestSuccessBlock)successBlock
                       failureBlock:(FailureBlock)failureBlock;

-(void)postMusic:(NSString*)tracksInJSON
           email:(NSString*)email
           token:(NSString*)token
    successBlock:(RequestSuccessBlock)successBlock
    failureBlock:(FailureBlock)failureBlock;

-(void)searchWithKeyword:(NSString*)keyWord
              searchType:(NSString*)type
                 success:(RequestSuccessBlockWithDictionary)successBlock
                 failure:(FailureBlock)failureBlock;

-(void)shareFacebook:(BOOL)share
             success:(RequestSuccessBlock)successBlock
             failure:(FailureBlock)FailureBlock;
-(void)shareTwitter:(BOOL)share
             success:(RequestSuccessBlock)successBlock
             failure:(FailureBlock)FailureBlock;

+ (BOOL)isReachable;

// Playlists
- (void)getPlaylistsWithEmail:(NSString*)email
                        token:(NSString*)token
                        extId:(NSString*)extId
                 successBlock:(RequestSuccessBlockWithArray)successBlock
                 failureBlock:(FailureBlock)failureBlock;

- (void)postPlaylistWithTitle:(NSString *)title
                      private:(BOOL)isPrivate
                        email:(NSString *)email
                        token:(NSString *)token
                 successBlock:(RequestSuccessBlockWithDictionary)successBlock
                 failureBlock:(FailureBlock)failureBlock;

- (void)putPlaylistWithId:(NSString *)playlistId
                 newTitle:(NSString *)title
                    email:(NSString *)email
                    token:(NSString *)token
             successBlock:(RequestSuccessBlockWithDictionary)successBlock
             failureBlock:(FailureBlock)failureBlock;

- (void)putPlaylistWithId:(NSString *)playlistId
                 newTitle:(NSString *)title
                  private:(BOOL)isPrivate
                    email:(NSString *)email
                    token:(NSString *)token
             successBlock:(RequestSuccessBlockWithDictionary)successBlock
             failureBlock:(FailureBlock)failureBlock;

- (void)getPlaylistsWithId:(NSString *)playlistId
                     extId:(NSString *)extId
            lastTimelineId:(NSString *)lastTimelineId
              successBlock:(RequestSuccessBlockWithDictionary)successBlock
              failureBlock:(FailureBlock)failureBlock;

- (void)deletePlaylistWithId:(NSString *)playlistId
                       email:(NSString *)email
                       token:(NSString *)token
                successBlock:(RequestSuccessBlockWithDictionary)successBlock
                failureBlock:(FailureBlock)failureBlock;

- (void)postPlaylistWithId:(NSString *)playlistId
                  songsIds:(NSArray *)timelinesIds
                     email:(NSString *)email
                     token:(NSString *)token
              successBlock:(RequestSuccessBlockWithDictionary)successBlock
              failureBlock:(FailureBlock)failureBlock;

- (void)deleteSongsWithPlaylistId:(NSString *)playlistId
                         songsIds:(NSArray *)timelinesIds
                            email:(NSString *)email
                            token:(NSString *)token
                     successBlock:(RequestSuccessBlockWithDictionary)successBlock
                     failureBlock:(FailureBlock)failureBlock;

- (void)getPlaylistsWithUserId:(NSString *)userExtId
                         email:(NSString *)email
                         token:(NSString *)token
                  successBlock:(RequestSuccessBlockWithArray)successBlock
                  failureBlock:(FailureBlock)failureBlock;

- (void)putPlaylistWithId:(NSString *)playlistId
                  private:(BOOL)isPrivate
                    email:(NSString *)email
                    token:(NSString *)token
             successBlock:(RequestSuccessBlockWithDictionary)successBlock
             failureBlock:(FailureBlock)failureBlock;

// Removed tracks
- (void)getRemovedTracksWithEmail:(NSString *)email
                            token:(NSString *)token
                     successBlock:(RequestSuccessBlockWithArray)successBlock
                     failureBlock:(FailureBlock)failureBlock;

- (void)restoreTrackWithId:(NSString *)trackId
                     email:(NSString *)email
                     token:(NSString *)token
              successBlock:(RequestSuccessBlockWithDictionary)successBlock
              failureBlock:(FailureBlock)failureBlock;

// Activities
-(void)getActivitiesByTrackId:(NSString*)trackId
                    withEmail:(NSString*)email
                        token:(NSString*)token
                 successBlock:(RequestSuccessBlockWithArray)successBlock
                 failureBlock:(FailureBlock)failureBlock;

- (void)connectToFacebookID:(NSString*)facebookID
                  withEmail:(NSString*)email
              facebookToken:(NSString*)facebookToken
                      token:(NSString*)token
               successBlock:(RequestSuccessBlockWithUser)successBlock
               failureBlock:(FailureBlock)failureBlock;

- (void)disconnectToFacebookWithToken:(NSString*)token
                            withEmail:(NSString*)email
                         successBlock:(RequestSuccessBlockWithUser)successBlock
                         failureBlock:(FailureBlock)failureBlock;
- (void)getNotificationsWithEmail:(NSString*)email
                            token:(NSString*)token
                             page:(NSInteger)page
                     successBlock:(RequestSuccessBlockWithArray)successBlock
                     failureBlock:(FailureBlock)failureBlock;

- (void)readNotificationByID:(NSNumber*)notif_id
                   withEmail:(NSString*)email
                       token:(NSString*)token
                successBlock:(RequestSuccessBlockWithArray)successBlock
                failureBlock:(FailureBlock)failureBlock;

- (void)getNumberOfUnseenNotificationsSuccessBlock:(RequestSuccessBlockWithArray)successBlock
                                      failureBlock:(FailureBlock)failureBlock;
- (void)postContactList:(NSArray*)contactsList
           successBlock:(RequestSuccessBlockWithDictionary)successBlock
           failureBlock:(FailureBlock)failureBlock;
- (void)postPhoneArtistsList:(NSArray*)contactsList
                successBlock:(RequestSuccessBlockWithArray)successBlock
                failureBlock:(FailureBlock)failureBlock;
- (void)getPhoneArtistsSuccessBlock:(RequestSuccessBlockWithArray)successBlock
                       failureBlock:(FailureBlock)failureBlock;
- (void)getAllGenresSuccessBlock:(RequestSuccessBlockWithArray)successBlock
                    failureBlock:(FailureBlock)failureBlock;
- (void)searchGenresWithKeyword:(NSString*)keyword
                   SuccessBlock:(RequestSuccessBlockWithArray)successBlock
                   failureBlock:(FailureBlock)failureBlock;
- (void)postUserGenres:(NSArray*)genreIds
          SuccessBlock:(RequestSuccessBlockWithArray)successBlock
          failureBlock:(FailureBlock)failureBlock;

- (void)getUserGenresSuccessBlock:(RequestSuccessBlockWithArray)successBlock
                     failureBlock:(FailureBlock)failureBlock;

- (void)findTrackByUrl:(NSString*)url
          SuccessBlock:(RequestSuccessBlockWithDictionary)successBlock
          failureBlock:(FailureBlock)failureBlock;
- (void)findTrackByName:(NSString*)name
                 artist:(NSString*)artist
           SuccessBlock:(RequestSuccessBlockWithDictionary)successBlock
           failureBlock:(FailureBlock)failureBlock;
- (void)getSuggestionsCategoriesWithSuccessBlock:(RequestSuccessBlockWithArray)successBlock
                                    failureBlock:(FailureBlock)failureBlock;
-(void)getSuggestionsFilteredWithEmail:(NSString*)email
                                 token:(NSString*)token
                            filterType:(NSString*)filterType
                          successBlock:(RequestSuccessBlockWithDictionary)successBlock
                          failureBlock:(FailureBlock)failureBlock;
- (void)publishTrackByID:(NSString*)ID
            SuccessBlock:(RequestSuccessBlockWithDictionary)successBlock
            failureBlock:(FailureBlock)failureBlock;
- (void)createUnsignedUserWithArtists:(NSArray*)artists
                         successBlock:(RequestSuccessBlockWithDictionary)successBlock
                         failureBlock:(FailureBlock)failureBlock;
-(void)getFacebookFriendsWithSuccessBlock:(RequestSuccessBlockWithArray)successBlock
                             failureBlock:(FailureBlock)failureBlock;
-(void)updateProfile:(NSDictionary*)profile
              avatar:(UIImage*)avatar
        successBlock:(RequestSuccessBlockWithDictionary)successBlock
        failureBlock:(FailureBlock)failureBlock;
- (void)seenNotificationsByID:(NSArray*)notif_ids
                 successBlock:(RequestSuccessBlockWithArray)successBlock
                 failureBlock:(FailureBlock)failureBlock;
-(void)getTrackByID:(NSString*)trackID
       successBlock:(RequestSuccessBlockWithDictionary)successBlock
       failureBlock:(FailureBlock)failureBlock;
-(void)getTrendingTracksWithSuccessBlock:(RequestSuccessBlockWithArray)successBlock
                            failureBlock:(FailureBlock)failureBlock;
-(void)refreshFacebookToken:(NSString*)token
             expirationDate:(NSDate*)expDate
               successBlock:(RequestSuccessBlockWithDictionary)successBlock
               failureBlock:(FailureBlock)failureBlock;
-(void)editTrackCommentByID:(NSString*)trackID
                  commentID:(NSString*)commentID
                       text:(NSString*)text
               successBlock:(RequestSuccessBlock)successBlock
               failureBlock:(FailureBlock)failureBlock;
@end
