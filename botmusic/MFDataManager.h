//
//  MFDataManager.h
//  botmusic
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MFTrackItem+Behavior.h"
#import "MFFollowItem+Behavior.h"

typedef enum : NSUInteger {
    MFUserInfoTypeFacebook,
    MFUserInfoTypeContacts,
    MFUserInfoTypeImportedArtists,
} MFUserInfoType;

@interface MFDataManager : NSObject


+ (MFDataManager *)sharedInstance;
- (MFUserInfo*) getMyUserInfoInContext;
-(BOOL) addFeedTracksToDatabase:(NSArray*) actualArray;
-(BOOL) addFeedTracksToDatabase:(NSArray*) actualArray ofUser:(MFUserInfo*)user;
-(NSArray*) convertAndAddTracksToDatabase:(NSArray*) actualArray;
-(void) convertAndAddTracksToDatabaseAsync:(NSArray*)actualArray playlist:(MFPlaylistItem*)playlist completion:(RequestSuccessBlockWithArray)completion;
-(void) convertAndAddTracksToDatabaseAsync:(NSArray*)actualArray completion:(RequestSuccessBlockWithArray)completion;
-(NSArray*) convertAndAddFollowItemsToDatabase:(NSArray*) actualArray;
-(MFUserInfo*) convertAndAddUserInfoToDatabase:(NSDictionary*) dictionary;
//-(MFUserInfo*) getUserInfoInContextbyFacebookID:(NSString*)facebookID;
-(NSArray*) convertAndAddPlaylistsToDatabase:(NSArray*) actualArray ofUser:(MFUserInfo*) userInfo;
-(NSArray*) convertAndAddCommentItemsToDatabase:(NSArray*) actualArray;
-(NSArray*) convertAndAddActivityItemsToDatabase:(NSArray*) actualArray;
-(NSArray*) convertAndAddSuggestionItemsToDatabase:(NSArray*) actualArray;
-(void) convertAndAddSuggestionItemsToDatabaseAsync:(NSArray*) actualArray completion:(RequestSuccessBlockWithArray)completion;
- (MFUserInfo*) getUserInfoInContextbyExtID:(NSString*)ExtID;
- (MFPlaylistItem*) getPlaylistInContextbyID:(NSString*)ID;
-(void)clearFeed;
-(void)clearNotifications;
-(void)getLastPlayedTracks:(int)number completion:(RequestSuccessBlockWithArray)completion;
-(void)updateTrackPlayedTime:(MFTrackItem*)trackItem;
-(NSArray*) convertAndAddNotificationItemsToDatabase:(NSArray*) actualArray;
-(NSArray*) processSuggestions:(NSArray*) actualArray;
- (MFUserInfo*) getAnonUserInfo;
-(NSArray*) convertAndAddUserInfosToDatabase:(NSArray*) actualArray userInfoType:(MFUserInfoType) userInfoType;

@end
