//
//  UtilsObjC.h
//  SomeApp
//
//  Created by Perry on 2/18/18.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

#import <UIKit/UIKit.h>

// Everything that is decalred here (the header file) is considered as PUBLIC FIELDS & METHODS
// Read more at: https://medium.com/@victorleungtw/connection-between-h-and-m-files-in-objective-c-eaf6b7366717

/**
 Just for Objective-C demonstrations
 */
@interface UtilsObjC: NSObject

@property (nonatomic, assign) NSInteger dimension;
@property (nonatomic, strong) NSArray *supportedDimensions;

-(BOOL)crashTheAppDueToAnUnimplementedMethodWithParam:(NSString *)stringParam;
-(CGSize)boardSize;
-(void)alertWithTitle:(NSString *)title andMessage:(NSString *)message inViewController:(UIViewController *) viewController;
+(BOOL)isRunningOnSimulator;

@end
