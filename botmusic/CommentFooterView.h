//
//  CommentFooterView.h
//  botmusic
//
//  Created by Supervisor on 03.07.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CommentFooterViewDelegate <NSObject>

-(void)didSelectFooterView;

@end

static CGFloat const COMMENT_FOOTER_HEIGHT=27.0f;

@interface CommentFooterView : UIView

@property(nonatomic,weak)id<CommentFooterViewDelegate> delegate;

-(IBAction)didSelectButton:(id)sender;

+(CommentFooterView*)createCommentFooterView;

@end
