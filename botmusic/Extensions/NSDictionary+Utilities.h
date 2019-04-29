//
//  NSDictionary+Utilities.h
//
//  Created by Илья Романеня.
//  Copyright (c) 2013 wellnuts. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Utilities)

- (id)validStringForKey:(NSString *)key;
- (id)validObjectForKey:(NSString *)key;
- (NSString*)makeStringForKey:(NSString *)key;
@end
