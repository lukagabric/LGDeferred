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
    id exp = [self expectationWithDescription:@""];
    
    __weak id weakSelf = self;
    self.deferred = [LGDeferred newWithCancelBlock:^{
        LGDeferredTests *strongSelf = weakSelf;
        if (!strongSelf) return;
        
        XCTAssertTrue(strongSelf.deferred.cancelled);
    }];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        LGDeferredTests *strongSelf = weakSelf;
        if (!strongSelf) return;
        
        [strongSelf.deferred cancel];
        XCTAssertTrue([strongSelf.deferred.promise resolved]);
        XCTAssertTrue(strongSelf.deferred.cancelled);
        
        [exp fulfill];
    });
    
    PMKPromise *promise = self.deferred.promise;
    
    promise.then(^(id result) {
        NSLog(@"%@", result);
        XCTAssertTrue(NO);
    }).catch(^(NSError *error) {
        LGDeferredTests *strongSelf = weakSelf;
        if (!strongSelf) return;
        
        NSLog(@"Caught error: %@", error);
        
        XCTAssertTrue(strongSelf.deferred.cancelled);
    });
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testReject {
    id exp = [self expectationWithDescription:@""];

    self.deferred = [LGDeferred new];
    
    PMKPromise *promise = self.deferred.promise;
    
    __weak id weakSelf = self;
    promise.then(^(id result) {
        NSLog(@"%@", result);
        XCTAssertTrue(NO);
    }).catch(^(NSError *error) {
        LGDeferredTests *strongSelf = weakSelf;
        if (!strongSelf) return;
        
        NSLog(@"Caught error: %@", error);
        
        XCTAssertTrue(YES);
        [exp fulfill];
    });
    
    [self.deferred reject:[NSError errorWithDomain:@"TestReject" code:0 userInfo:nil]];
    self.deferred = nil;
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testResolve {
    id exp = [self expectationWithDescription:@""];
    
    self.deferred = [LGDeferred new];
    
    PMKPromise *promise = self.deferred.promise;
    
    __weak id weakSelf = self;
    promise.then(^(id result) {
        NSLog(@"%@", result);
        XCTAssertTrue(YES);
        
        [exp fulfill];
    }).catch(^(NSError *error) {
        LGDeferredTests *strongSelf = weakSelf;
        if (!strongSelf) return;
        
        NSLog(@"Caught error: %@", error);
        
        XCTAssertTrue(NO);
    });
    
    [self.deferred resolve:@1];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testResolveReject {
    id exp = [self expectationWithDescription:@""];
    
    self.deferred = [LGDeferred new];
    
    PMKPromise *promise = self.deferred.promise;
    
    __weak id weakSelf = self;
    promise.then(^(id result) {
        NSLog(@"%@", result);
        XCTAssertTrue(YES);
        
        [exp fulfill];
    }).catch(^(NSError *error) {
        LGDeferredTests *strongSelf = weakSelf;
        if (!strongSelf) return;
        
        NSLog(@"Caught error: %@", error);
        
        XCTAssertTrue(NO);
    });
    
    [self.deferred resolve:@1];
    [self.deferred reject:[NSError errorWithDomain:@"TestReject" code:0 userInfo:nil]];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testRejectResolve {
    id exp = [self expectationWithDescription:@""];
    
    self.deferred = [LGDeferred new];
    
    PMKPromise *promise = self.deferred.promise;
    
    __weak id weakSelf = self;
    promise.then(^(id result) {
        NSLog(@"%@", result);
        XCTAssertTrue(NO);
    }).catch(^(NSError *error) {
        LGDeferredTests *strongSelf = weakSelf;
        if (!strongSelf) return;
        
        NSLog(@"Caught error: %@", error);
        
        XCTAssertTrue(YES);
        [exp fulfill];
    });
    
    [self.deferred reject:[NSError errorWithDomain:@"TestReject" code:0 userInfo:nil]];
    [self.deferred resolve:@1];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testCancelResolve {
    id exp = [self expectationWithDescription:@""];
    
    self.deferred = [LGDeferred new];
    
    PMKPromise *promise = self.deferred.promise;
    
    __weak id weakSelf = self;
    promise.then(^(id result) {
        NSLog(@"%@", result);
        XCTAssertTrue(NO);
    }).catch(^(NSError *error) {
        LGDeferredTests *strongSelf = weakSelf;
        if (!strongSelf) return;
        
        NSLog(@"Caught error: %@", error);
        
        XCTAssertTrue(YES);
        [exp fulfill];
    });
    
    [self.deferred cancel];
    [self.deferred resolve:@1];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

@end
