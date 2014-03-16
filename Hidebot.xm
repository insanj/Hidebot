#import <UIKit/UIKit.h>

// Tab Bar:
// 	[UIApplication sharedApplication].keyWindow.rootViewController.tabBar
// Navigation Bar:
// 	[UIApplication sharedApplication].keyWindow.rootViewController.selectedNavigationController.navigationBar

@interface PTHTweetbotAccountController : UITabBarController <UITabBarControllerDelegate>
@property (nonatomic, copy) UIViewController *selectedRootViewController;
@property (nonatomic, copy) UINavigationController *selectedNavigationController;
@property (nonatomic, copy) UIViewController *currentViewController;
-(id)initWithAccount:(id)arg1;
@end

%hook UINavigationBar

- (void)willMoveToSuperview:(UIView *)newSuperview {
	%orig(newSuperview);

	NSLog(@"[Hidebot] Adding swipe gesture recognizer to navigation bar...");
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hb_hideBars:)];
	swipe.direction = UISwipeGestureRecognizerDirectionUp;
    [self addGestureRecognizer:swipe];
}

// Essentially anonymous methods that allow for the changing of navigation and tab bar properties from
// anywhere. I chose here, so every possible bar could be utilized.

%new - (void)hb_hideBars:(UISwipeGestureRecognizer *)sender {
	if (sender.state == UIGestureRecognizerStateEnded) {
		NSLog(@"[Hidebot] Detected long-press, hiding away...");
		PTHTweetbotAccountController *rootViewController = (PTHTweetbotAccountController *) [UIApplication sharedApplication].keyWindow.rootViewController;
		UINavigationBar *navigationBar = rootViewController.selectedNavigationController.navigationBar;
		UITabBar *tabBar = rootViewController.tabBar;

		CGRect upFrame = navigationBar.frame;
		upFrame.origin.y -= (upFrame.size.height - 21.0);

		CGRect downFrame = tabBar.frame;
		downFrame.origin.y += downFrame.size.height;

		[UIView animateWithDuration:0.25 animations:^{
			navigationBar.alpha = 0.25;

			[navigationBar setFrame:upFrame];
			[tabBar setFrame:downFrame];
		} completion:^(BOOL finished){
			sender.direction = UISwipeGestureRecognizerDirectionDown;

			[sender addTarget:self action:@selector(hb_showBars:)];
			[sender removeTarget:self action:@selector(hb_hideBars:)];
		}];
	}
}

%new - (void)hb_showBars:(UISwipeGestureRecognizer *)sender {
	if (sender.state == UIGestureRecognizerStateEnded) {
		NSLog(@"[Hidebot] Detected long-press, showing away...");
		PTHTweetbotAccountController *rootViewController = (PTHTweetbotAccountController *) [UIApplication sharedApplication].keyWindow.rootViewController;
		UINavigationBar *navigationBar = rootViewController.selectedNavigationController.navigationBar;
		UITabBar *tabBar = rootViewController.tabBar;

		CGRect downFrame = navigationBar.frame;
		downFrame.origin.y = 20.0;

		CGRect upFrame = tabBar.frame;
		upFrame.origin.y = rootViewController.view.frame.size.height - tabBar.frame.size.height;

		[UIView animateWithDuration:0.25 animations:^{
			navigationBar.alpha = 1.0;

			[navigationBar setFrame:downFrame];
			[tabBar setFrame:upFrame];
		} completion:^(BOOL finished){
			sender.direction = UISwipeGestureRecognizerDirectionUp;

			[sender addTarget:self action:@selector(hb_hideBars:)];
			[sender removeTarget:self action:@selector(hb_showBars:)];
		}];
	}
}

%end
