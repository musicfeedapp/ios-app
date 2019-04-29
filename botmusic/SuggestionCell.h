//
//  SuggestionCell.h
//  botmusic
//
//  Created by Supervisor on 12.08.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IRSuggestion.h"

@interface SuggestionCell : UITableViewCell

@property(nonatomic,assign)BOOL isMenuSearch;

-(void)setSuggestionInfo:(IRSuggestion*)suggestion;

@end
