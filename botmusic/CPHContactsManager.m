//
//  CPHContactsManager.m
//  Watcher
//

#import "CPHContactsManager.h"

@implementation CPHContactsManager

+ (NSMutableArray *)getAllContacts {
    NSMutableArray *allContacts = [[NSMutableArray alloc] init];
    CFErrorRef *createError = nil;
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, createError);
    
    __block BOOL accessGranted = NO;
    if (&ABAddressBookRequestAccessWithCompletion != NULL) {
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    } else {
        accessGranted = YES;
    }
    
    if (accessGranted) {
        addressBook = ABAddressBookCreateWithOptions(NULL, createError);
        
        ABRecordRef source = ABAddressBookCopyDefaultSource(addressBook);
#warning  CHECK IF AUTORELEASE WORKS WELL
        CFAutorelease(source);
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, source, kABPersonSortByFirstName);
        
        CFAutorelease(addressBook);
        CFIndex peopleCount = CFArrayGetCount(allPeople);
      
        for (int i = 0; i < peopleCount; i++) {
            NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
            
            ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
            
            // First name
            [userInfo setValue:(__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty) forKey:@"firstName"];
            // Last Name
            [userInfo setValue:(__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty) forKey:@"lastName"];
            // Company
            [userInfo setValue:(__bridge NSString*)ABRecordCopyValue(person, kABPersonOrganizationProperty)forKey:@"companyName"];
            
           
            // Phone numbers
            NSMutableArray *userPhonesWithLabels = [[NSMutableArray alloc] init];
            ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
            for(CFIndex j = 0; j < ABMultiValueGetCount(phones); j++)
            {
                NSMutableDictionary *phoneWithLabel = [[NSMutableDictionary alloc] init];
                CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(phones, j);
                CFStringRef locLabel = ABMultiValueCopyLabelAtIndex(phones, j);
                [phoneWithLabel setValue: (__bridge NSString*) ABAddressBookCopyLocalizedLabel(locLabel)forKey:@"label"];
                [phoneWithLabel setValue: (__bridge NSString*) ABAddressBookCopyLocalizedLabel(phoneNumberRef)forKey:@"phone"];
                [userPhonesWithLabels addObject:phoneWithLabel];
            }
            
            [userInfo setObject:userPhonesWithLabels forKey:@"phones"];
            
            
            // Emails
            ABMultiValueRef multiEmails = ABRecordCopyValue(person, kABPersonEmailProperty);
            CFStringRef contactEmailRef = ABMultiValueCopyValueAtIndex(multiEmails, 0);
            [userInfo setValue:(__bridge NSString *)contactEmailRef forKey:@"contactEmail"];
            
            if (ABPersonHasImageData(person)) {
                [userInfo setObject:(__bridge id)(ABPersonCopyImageData(person)) forKey:@"avatar"];
            }
            
            if (([userInfo valueForKey:@"firstName"] || [userInfo valueForKey:@"lastName"] || [userInfo valueForKey:@"companyName"]) && (ABMultiValueGetCount(phones) > 0)) {
                [allContacts addObject:userInfo];
            }
            CFAutorelease(person);
            
        }
    
        
        return allContacts;
        
    } else {
        return nil;
    }
}


@end
