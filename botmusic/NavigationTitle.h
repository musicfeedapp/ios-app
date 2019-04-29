//
//  NavigationTitle.h
//  botmusic
//
//  Created by Supervisor on 20.05.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    NavigationTitleStateDown,
    NavigationTitleStateUp
}NavigationTitleState;

@protocol  NavigationTitleDelegate<NSObject>

-(void)didTapAtTitle;

@end

@interface NavigationTitle : UIView

@property(nonatomic)IBOutlet UILabel *titleLabel;
@property(nonatomic)IBOutlet UIImageView *arrowImage;

@property(nonatomic)NavigationTitleState state;

@property(nonatomic)id<NavigationTitleDelegate> delegate;

-(void)setNavigationTitle:(NSString*)title;
-(void)setNavigationTitle:(NSString*)title andState:(NavigationTitleState)state;

+(NavigationTitle*)createNavigationTitle;

@end
