//
//  ShareCell.h
//  botmusic
//
//  Created by Илья Романеня on 16.01.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ShareHeaderCell;

@protocol ShareHeaderCellDelegate <NSObject>

typedef void(^CompletionBlock)();

@required
- (BOOL)isFacebookShared:(ShareHeaderCell*)sender;
- (BOOL)isTwitterShared:(ShareHeaderCell*)sender;

- (void)shareOnFacebook:(ShareHeaderCell*)sender
        completionBlock:(CompletionBlock)completionBlock;
- (void)shareOnTwitter:(ShareHeaderCell*)sender
       completionBlock:(CompletionBlock)completionBlock;

@end

@interface ShareHeaderCell : UITableViewCell

@property (nonatomic, assign) IBOutlet id<ShareHeaderCellDelegate> delegate;

@property (nonatomic, weak) IBOutlet UIButton* facebookButton;
@property (nonatomic, weak) IBOutlet UIButton* twitterButton;

- (void)refreshViews;

- (IBAction)facebookTap:(id)sender;
- (IBAction)twitterTap:(id)sender;

@end
