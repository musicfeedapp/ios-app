//
//  ArtistCell.h
//  botmusic
//
//  Created by Supervisor on 29.05.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IRSuggestion.h"


@protocol ArtistCellDelegate <NSObject>

-(void)didSelectPlay:(NSIndexPath*)indexPath;
-(void)didSelectPause:(NSIndexPath*)indexPath;
-(void)didSelectFollow:(NSIndexPath*)indexPath;
-(void)showUserProfileWithUserInfo:(MFUserInfo*)userInfo;
@end

@interface ArtistCell : UIView

@property(nonatomic,strong)NSIndexPath *indexPath;
@property(nonatomic,weak)id<ArtistCellDelegate> delegate;

@property (nonatomic) BOOL showGradient;

-(void)setArtistInfo:(IRSuggestion*)suggestion;
-(void)setFollowInfo:(MFFollowItem*)followItem;

-(BOOL)isSelected;
-(void)setIsSelected:(BOOL)isSelected;

-(IBAction)didSelectPlay:(id)sender;
-(IBAction)didSelectFollow:(id)sender;
+(int)sizeOfArtistCell;

@end
