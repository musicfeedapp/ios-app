//
//  MFMigrationManager.m
//  botmusic
//
//  Created by Panda Systems on 4/9/15.
//
//

#import "MFMigrationManager.h"

@implementation MFMigrationManager
static NSString *AppVersionString = nil;
static NSString *MigrationParamsKey = @"MigrationParamsKey";

static NSString *isMigratedTo_1_1_13 = @"isMigratedTo_1_1_13";

+ (void)performMigration {
    
    NSDictionary* migrationInfo = [MFMigrationManager migrationInfo];
    if((![migrationInfo valueForKey:isMigratedTo_1_1_13])||([[migrationInfo valueForKey:isMigratedTo_1_1_13] boolValue] == NO)){
        [MFMigrationManager performMigrationVersion_1_1_13];
    }
}

#pragma mark - Version Targeted Migrations


+ (void)performMigrationVersion_1_1_13 {
    
    [userManager setLastTimelinesCheck:nil];
    
    NSMutableDictionary* migrationInfo = [NSMutableDictionary dictionary];
    [migrationInfo addEntriesFromDictionary:[MFMigrationManager migrationInfo]];
    [migrationInfo setObject:@(YES) forKey:isMigratedTo_1_1_13];
    [MFMigrationManager setMigrationInfo:migrationInfo];
}

+ (NSDictionary*) migrationInfo {
    NSDictionary* migrationInfo = [[NSUserDefaults standardUserDefaults] objectForKey:MigrationParamsKey];
    if(!migrationInfo){
        migrationInfo = [[NSDictionary alloc] init];
    }
    return migrationInfo;
}

+ (void) setMigrationInfo:(NSDictionary*)migrationInfo {
    [[NSUserDefaults standardUserDefaults] setObject:migrationInfo forKey:MigrationParamsKey];
}
@end
