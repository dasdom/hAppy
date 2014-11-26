/***
 * Excerpted from "iOS Recipes",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/cdirec for more book information.
***/
#import "UIApplication+PRPNetworkActivity.h"

static NSInteger prp_networkActivityCount = 0;

@implementation UIApplication (PRPNetworkActivity)


- (void)prp_refreshNetworkActivityIndicator {
    if (![NSThread isMainThread]) {
        SEL sel_refresh = @selector(prp_refreshNetworkActivityIndicator);
        [self performSelectorOnMainThread:sel_refresh
                               withObject:nil 
                            waitUntilDone:NO];
        return;
    }
    
    BOOL active = (self.prp_networkActivityCount > 0);
    self.networkActivityIndicatorVisible = active;
}

- (NSInteger)prp_networkActivityCount {
    @synchronized(self) {
        return prp_networkActivityCount;        
    }
}

- (void)prp_pushNetworkActivity {
    @synchronized(self) {
        prp_networkActivityCount++;
    }
    [self prp_refreshNetworkActivityIndicator];
}

- (void)prp_popNetworkActivity {
    @synchronized(self) {
        if (prp_networkActivityCount > 0) {
            prp_networkActivityCount--;
        } else {
            prp_networkActivityCount = 0;
            dhDebug(@"%s Unbalanced network activity: count already 0.",
                  __PRETTY_FUNCTION__);
        }        
    }
    [self prp_refreshNetworkActivityIndicator];
}

- (void)prp_resetNetworkActivity {
    @synchronized(self) {
        prp_networkActivityCount = 0;
    }
    [self prp_refreshNetworkActivityIndicator];        
}

@end