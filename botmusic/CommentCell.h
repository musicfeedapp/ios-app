//
//  CommentCell.h
//  botmusic
//
//  Created by Supervisor on 01.07.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFCommentItem+Behavior.h"
#import "MFFollowItem+Behavior.h"
#import "SSSliderView.h"
#import "MGSwipeTableCell+PanHandler.h"

@class CommentCell;

@protocol CommentCellDelegate <NSObject>

-(void)didOpenDelete:(CommentCell*)cell;
-(void)didCloseDelete:(CommentCell*)cell;
-(void)didSelectDelete:(CommentCell*)cell;

@end

@interface CommentCell : UITableViewCell<SSSliderViewDelegate>

@property(nonatomic,weak)IBOutlet SSSliderView *sliderView;

@property(nonatomic,assign)BOOL canEdit;

@property(nonatomic,weak)id<CommentCellDelegate> delegate;

-(void)setCommentInfo:(MFCommentItem*)commentItem;
-(void)setProposalInfo:(MFFollowItem*)followItem;

+(CGFloat)heightForComment:(MFCommentItem*)commentItem;

@end
