//
//  LGDeferred.h
//  LGDeferred
//
//  Created by Luka Gabric on 24/04/15.
//  Copyright (c) 2015 Luka Gabric. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Promise.h"

typedef void(^LGCancelDeferred)(void);

@interface LGDeferred : NSObject

@property (readonly, nonatomic) PMKPromise *promise;
@property (readonly, nonatomic) BOOL cancelled;

- (instancetype)initWithCancelBlock:(LGCancelDeferred)cancelBlock;

- (void)resolve:(id)result;
- (void)reject:(NSError *)error;
- (void)cancel;

+ (LGDeferred *)newWithCancelBlock:(LGCancelDeferred)cancelBlock;

@end
