//
//  SwiftBridgedClass.m
//  SomeApp
//
//  Created by Perry on 8/18/18.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

//#import "SomeApp-Swift.h" // From: https://stackoverflow.com/questions/24102104/how-can-i-import-swift-code-to-objective-c

#import "SwiftBridgedClass.h"

//#import <Foundation/Foundation.h>

@interface SwiftBridgedClass()

+ (void)swiftyInitialize;
+ (void)swiftyLoad;

@end

// Will cause the following warnings: "Method definition for 'swiftyInitialize' not found" & "Method definition for 'swiftyLoad' not found"
// They really aren't found... here in the ObjC part, but they are be covered in the Swift part as extension methods.
@implementation SwiftBridgedClass

+(void)initialize {
    [self swiftyInitialize];
}

+ (void)load {
    [self swiftyLoad];
}

@end
