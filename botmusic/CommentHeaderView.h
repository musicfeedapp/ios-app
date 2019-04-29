//
//  CommentHeaderView.h
//  botmusic
//
//  Created by Supervisor on 03.07.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CommentHeaderViewDelegate <NSObject>

-(void)didSelectHeaderView;

@end

@interface CommentHeaderView : UIView

@property(nonatomic,weak)id<CommentHeaderViewDelegate> delegate;

-(IBAction)didSelectButton:(id)sender;

@end
