/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license. See full license at the bottom of this file.
 */

#import "ConnectViewController.h"
#import "AuthenticationManager.h"
#import <ADAuthenticationResult.h>
#import <ADAuthenticationError.h>
#import "DetailTableViewController.h"

@interface ConnectViewController () <AuthManagerDelegates, UISplitViewControllerDelegate>

@end

@implementation ConnectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)authenticateWithAzureTapped:(id)sender {
    [AuthenticationManager sharedInstance].authDelegate = self;
    [[AuthenticationManager sharedInstance] connectO365];
}


#pragma mark - Authentication delegates
- (void)authSuccess{
    [self performSegueWithIdentifier:@"showSplitView" sender:nil];
}

- (void)authFailure:(NSError *)error{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                   message:[NSString stringWithFormat:@"Unable to authenticate\n%@", error.localizedDescription]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        ;
    }]];
    [self presentViewController:alert animated:YES completion:^{
        ;
    }];
}

- (void)authDisconnect:(NSError *)error{
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UISplitViewController *splitViewController = segue.destinationViewController;
    splitViewController.delegate = self;
}


- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController {
    if ([secondaryViewController isKindOfClass:[UINavigationController class]] && [[(UINavigationController *)secondaryViewController topViewController] isKindOfClass:[DetailTableViewController class]] && ([(DetailTableViewController *)[(UINavigationController *)secondaryViewController topViewController] operation] == nil)) {
        // Return YES to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
        return YES;
    } else {
        return NO;
    }
}

@end


// *********************************************************
//
// OneNote REST API Explorer for iOS, https://github.com/OneNoteDev/iOS-REST-API-Explorer
//
// Copyright (c) Microsoft Corporation
// All rights reserved.
//
// MIT License:
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
// *********************************************************
