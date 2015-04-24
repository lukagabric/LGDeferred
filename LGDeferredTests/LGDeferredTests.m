//
//  LGDeferredTests.m
//  LGDeferredTests
//
//  Created by Luka Gabric on 24/04/15.
//  Copyright (c) 2015 Luka Gabric. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "LGDeferred.h"

@interface LGDeferredTests : XCTestCase

@property (strong, nonatomic) LGDeferred *deferred;

@end

@implementation LGDeferredTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCancel {
    id ex1 = [self expectationWithDescription:@""];
    
    __weak id weakSelf = self;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        LGDeferredTests *strongSelf = weakSelf;
        if (!strongSelf) return;
        
        [strongSelf.deferred cancel];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        LGDeferredTests *strongSelf = weakSelf;
        if (!strongSelf) return;
        
        if (![strongSelf.deferred cancelled]) {
            [strongSelf.deferred resolve:@2];
            XCTAssertTrue(NO);
        }
        else {
            XCTAssertTrue(YES);
        }
        
        [ex1 fulfill];
    });
    
    self.deferred = [[LGDeferred alloc] initWithCancelBlock:^{
        LGDeferredTests *strongSelf = weakSelf;
        if (!strongSelf) return;
        
        BOOL cancelled = [strongSelf.deferred cancelled];
        XCTAssertTrue(cancelled);
    }];
    
    PMKPromise *promise = self.deferred.promise;
    
    promise.then(^(id result) {
        NSLog(@"%@", result);
        XCTAssertTrue(NO);
    }).catch(^(NSError *error) {
        LGDeferredTests *strongSelf = weakSelf;
        if (!strongSelf) return;
        
        NSLog(@"Caught error: %@", error);
        
        BOOL cancelled = [strongSelf.deferred cancelled];
        XCTAssertTrue(cancelled);
    });
    
    [self waitForExpectationsWithTimeout:3 handler:nil];
}

@end
