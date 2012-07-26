//
//  CDISettingsViewController.m
//  Cheddar for iOS
//
//  Created by Sam Soffes on 4/20/12.
//  Copyright (c) 2012 Nothing Magical. All rights reserved.
//

#import "CDISettingsViewController.h"
#import "CDIUpgradeViewController.h"
#import "TTTAttributedLabel.h"
#import "UIColor+Cheddar.h"
#import "UIButton+Cheddar.h"
#import "UIFont+Cheddar.h"
#import <MessageUI/MessageUI.h>
#import "CDIAppDelegate.h"
#import "CDISplitViewController.h"
#import "CDIListsViewController.h"

@interface CDISettingsViewController () <MFMailComposeViewControllerDelegate>
@end

@implementation CDISettingsViewController {
	TTTAttributedLabel *_label;
	UIButton *_upgradeButton;
	UIButton *_supportButton;
	UIButton *_signOutButton;
}


#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"Settings";
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
	self.view.backgroundColor = [UIColor cheddarArchesColor];

	CGFloat width = self.view.bounds.size.width;
	_label = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(20.0f, 10.0f, width - 40.0f, 240.0f)];
	_label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	_label.backgroundColor = [UIColor clearColor];
	_label.font = [UIFont cheddarFontOfSize:18.0f];
	_label.numberOfLines = 0;
	_label.textColor = [UIColor cheddarTextColor];
	_label.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
	_label.userInteractionEnabled = YES;
	[self.view addSubview:_label];

	_upgradeButton = [UIButton cheddarBigOrangeButton];
	_upgradeButton.frame = CGRectMake(roundf((width - 280.0f) / 2.0f), 238.0f, 280.0f, 45.0f);
	_upgradeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
	[_upgradeButton setTitle:@"Upgrade to Cheddar Plus" forState:UIControlStateNormal];
	[_upgradeButton addTarget:self action:@selector(upgrade:) forControlEvents:UIControlEventTouchUpInside];
	_upgradeButton.alpha = 0.0f;
	[self.view addSubview:_upgradeButton];

	_supportButton = [UIButton cheddarBigGrayButton];
	_supportButton.frame = CGRectMake(roundf((width - 280.0f) / 2.0f), 292.0f, 280.0f, 45.0f);
	_supportButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
	[_supportButton setTitle:@"Support" forState:UIControlStateNormal];
	[_supportButton addTarget:self action:@selector(support:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_supportButton];

	_signOutButton = [UIButton cheddarBigGrayButton];
	_signOutButton.frame = CGRectMake(roundf((width - 280.0f) / 2.0f), 346.0f, 280.0f, 45.0f);
	_signOutButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
	[_signOutButton setTitle:@"Sign Out" forState:UIControlStateNormal];
	[_signOutButton addTarget:self action:@selector(signOut:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_signOutButton];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_updateUI) name:kCDKPlusDidChangeNotificationName object:nil];
	[self _updateUI];
}


- (void)viewDidUnload {
	[super viewDidUnload];

	[_label removeFromSuperview];
	_label = nil;

	[_upgradeButton removeFromSuperview];
	_upgradeButton = nil;

	[_supportButton removeFromSuperview];
	_supportButton = nil;

	[_signOutButton removeFromSuperview];
	_signOutButton = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? YES : toInterfaceOrientation == UIInterfaceOrientationPortrait;
}


#pragma mark - Actions

- (void)done:(id)sender {
	[self.navigationController dismissModalViewControllerAnimated:YES];
}


- (void)upgrade:(id)sender {
	UIViewController *viewController = [[CDIUpgradeViewController alloc] init];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
	navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
	[self.navigationController presentModalViewController:navigationController animated:YES];
}


- (void)support:(id)sender {
	if ([MFMailComposeViewController canSendMail] == NO) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://cheddarapp.com/support"]];
		return;
	}

	MFMailComposeViewController *viewController = [[MFMailComposeViewController alloc] init];
	viewController.toRecipients = [NSArray arrayWithObject:@"support@cheddarapp.com"];
	viewController.subject = @"Cheddar for iOS Help";
	viewController.mailComposeDelegate = self;
	[self.navigationController presentModalViewController:viewController animated:YES];
}


- (void)signOut:(id)sender {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign Out" message:@"Are you sure you want to sign out of Cheddar?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Sign Out", nil];
	[alert show];
}


#pragma mark - Private

- (void)_updateUI {
	CDKUser *user = [CDKUser currentUser];
	if (user.hasPlus.boolValue) {
		NSString *text = @"You currently have a Plus account. You're awesome! You can create unlimited lists!";
		[_label setText:text afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
			CTFontRef boldFont = CTFontCreateWithName((__bridge CFStringRef)kCDIBoldFontName, 20.0f, NULL);
			if (boldFont) {
				[mutableAttributedString addAttribute:(__bridge NSString *)kCTFontAttributeName value:(__bridge id)boldFont range:NSMakeRange(51, 31)];
				CFRelease(boldFont);
			}		
			return mutableAttributedString;
		}];
		_upgradeButton.enabled = NO;
		_upgradeButton.alpha = 0.0f;
	} else {
		NSString *text = @"You currently have a free account.\n\nWith a plus account, you can create unlimited lists. You only get two lists with a free account.";
		[_label setText:text afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
			CTFontRef boldFont = CTFontCreateWithName((__bridge CFStringRef)kCDIBoldFontName, 20.0f, NULL);
			if (boldFont) {
				[mutableAttributedString addAttribute:(__bridge NSString *)kCTFontAttributeName value:(__bridge id)boldFont range:NSMakeRange(36, 52)];
				CFRelease(boldFont);
			}		
			return mutableAttributedString;
		}];
		_upgradeButton.enabled = YES;
		_upgradeButton.alpha = 1.0f;
	}
}


#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	[controller dismissModalViewControllerAnimated:YES];

	if (result == MFMailComposeResultSent) {
		SSHUDView *hud = [[SSHUDView alloc] init];
		[hud completeQuicklyWithTitle:@"Sent!"];
	}
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex != 1) {
		return;
	}
	
	// Sign out
	[CDKUser setCurrentUser:nil];
	CDIAppDelegate *appDelegate = [CDIAppDelegate sharedAppDelegate];

	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		appDelegate.window.rootViewController = [[CDISplitViewController alloc] init];
	} else {
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[CDIListsViewController alloc] init]];
		appDelegate.window.rootViewController = navigationController;
	}
}


#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (context != (__bridge void *)self) {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
		return;
	}

	if ([keyPath isEqualToString:@"hasPlus"]) {
		[self _updateUI];
	}
}

@end
