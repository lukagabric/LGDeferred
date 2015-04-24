//
//  LGDeferred.m
//  LGDeferred
//
//  Created by Luka Gabric on 24/04/15.
//  Copyright (c) 2015 Luka Gabric. All rights reserved.
//

#import "LGDeferred.h"

#define LGErrorDomainPromiseCancelled @"LGErrorDomainPromiseCancelled"
#define LGErrorDomainUnknown @"LGErrorDomainUnknown"
#define LGErrorRejectionObject @"LGErrorRejectionObject"

@interface LGDeferred ()

@property (strong, nonatomic) PMKPromise *promise;
@property (copy, nonatomic) PMKResolver promiseResolverBlock;
@property (copy, nonatomic) LGCancelDeferred cancelBlock;

@end

@implementation LGDeferred

#pragma mark - Static

+ (LGDeferred *)newWithCancelBlock:(LGCancelDeferred)cancelBlock {
    return [[self alloc] initWithCancelBlock:cancelBlock];
}

#pragma mark - Init

- (instancetype)init {
    self = [super init];
    if (self) {
        self.promise = [PMKPromise promiseWithResolver:^(PMKResolver resolve) {
            self.promiseResolverBlock = resolve;
        }];
    }
    return self;
}

- (instancetype)initWithCancelBlock:(LGCancelDeferred)cancelBlock {
    self = [self init];
    if (self) {
        self.cancelBlock = cancelBlock;
    }
    return self;
}

#pragma mark - Deferred methods

- (void)resolve:(id)result {
    if ([self.promise resolved]) return;

    self.promiseResolverBlock(result);
}

- (void)reject:(NSError *)error {
    if ([self.promise resolved]) return;

    NSError *e = error;
    
    if (![e isKindOfClass:[NSError class]]) {
        e = [NSError errorWithDomain:LGErrorDomainUnknown code:0 userInfo:@{LGErrorRejectionObject: error}];
    }
    
    self.promiseResolverBlock(e);
}

- (void)cancel {
    if ([self.promise resolved]) return;
    
    NSError *cancelError = [NSError errorWithDomain:LGErrorDomainPromiseCancelled code:0 userInfo:nil];
    
    [self reject:cancelError];
    
    if (self.cancelBlock) {
        self.cancelBlock();
    }
}

#pragma mark - Getters

- (BOOL)cancelled {
    id result = [self.promise value];
    if (!result || ![result isKindOfClass:[NSError class]]) return NO;
    
    NSError *error = (NSError *)result;
    
    return [error.domain isEqualToString:LGErrorDomainPromiseCancelled];
}

#pragma mark -

@end
