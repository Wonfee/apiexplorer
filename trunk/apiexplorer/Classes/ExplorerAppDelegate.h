#import <UIKit/UIKit.h>

@interface ExplorerAppDelegate : NSObject <UIApplicationDelegate> {	
  UIWindow *window;
  UINavigationController *navigationController;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UINavigationController *navigationController;

@end

