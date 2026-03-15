#import <UIKit/UIKit.h>
#import "HAAppDelegate.h"
#import "HALog.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        [HALog installCrashHandler];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([HAAppDelegate class]));
    }
}
