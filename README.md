# LGDeferred

LGDeferred is a wrapper around PMKPromise. It provides convenience methods to resolve, reject or cancel a promise and it's async task using a cancel block that is invoked when deferred is cancelled.

Cancel
------

Cancellation is actually a rejection with specific cancellation error.

    self.deferred = [LGDeferred newWithCancelBlock:^{
      //e.g. cancel download task (don't forget weakify/strongify)
      [self.downloadTask cancel];
    }];

Cancel block is used to cancel the underlying async task. The block is performed when deferred is cancelled. 
