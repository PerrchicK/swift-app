//
//  UtilsObjC.m
//  SomeApp
//
//  Created by Perry on 2/18/18.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

#import "UtilsObjC.h"

// Everything that is decalred here (the implementation file) is considered as PRIVATE FIELDS & METHODS (as long as they're not exported in the header file).
// Read more at: https://medium.com/@victorleungtw/connection-between-h-and-m-files-in-objective-c-eaf6b7366717

@interface UtilsObjC()

@property (nonatomic, strong) NSDictionary *environmentConfigurations;

@end

@implementation UtilsObjC

+(BOOL)isRunningOnSimulator {
#if TARGET_IPHONE_SIMULATOR
    return YES;
#else
    return NO;
#endif
}

+ (NSString *)dimentionsKey
{
    return @"yo"; // The @"yo" is a shortcut for: [NSString stringWithCString:"yo" encoding:NSUTF8StringEncoding]
}

-(NSInteger)dimension {
    NSNumber *dimensionFromDictionary = [_environmentConfigurations objectForKey:UtilsObjC.dimentionsKey];
    return dimensionFromDictionary.integerValue;
}

-(void)setDimension:(NSInteger)dimension // auto generated 'setter'
{
    // Ignore... in other words, it's read only
}

-(void)alertWithTitle:(NSString *)title andMessage:(NSString *)message inViewController:(UIViewController *) viewController {
    UtilsObjC *__weak weakSelf = self;

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        UtilsObjC *__strong strongSelf = weakSelf;
        if (!strongSelf) {
            // Bail if the needed object (some UtilObjC instance in that case) has gone away.
            return;
        }

        NSString *logMessage = [NSString stringWithFormat:@"ah ah ah ah, 'strongSelf' is staying alive: %@", strongSelf];
        NSLog(@"%@", logMessage);
    }]];
    [viewController presentViewController:alert animated:YES completion:nil];
}

-(CGSize)boardSize
{
    return CGSizeMake(self.dimension, self.dimension);
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        [tempArray addObject:@3]; // The @3 is a shortcut for: [NSNumber numberWithInt:3]
        [tempArray addObject:@4];
        [tempArray addObject:@10]; // The 'addObject' mehod is available only in NSMutableArray
        _supportedDimensions = tempArray; // By using underscore (_filedName) we are skipping the setter usage
    }
    return self;
}

@end
