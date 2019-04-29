//
//  CommentsViewController.h
//  botmusic
//
//  Created by Supervisor on 05.07.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommentCell.h"
#import "MGSwipeTableCell+PanHandler.h"
#import "AbstractViewController.h"

@protocol CommentViewControllerDelegate <NSObject>

-(void)didAddComment;
-(void)didRemoveComment;
-(void)willCloseCommentController;

@end

@interface CommentsViewController : AbstractViewController<UITableViewDataSource,UITableViewDelegate,CommentCellDelegate,UIScrollViewDelegate,MGSwipeTableCellDelegate>

@property(nonatomic,strong)MFTrackItem *trackItem;
@property(nonatomic,weak)id<CommentViewControllerDelegate> delegate;

@end
