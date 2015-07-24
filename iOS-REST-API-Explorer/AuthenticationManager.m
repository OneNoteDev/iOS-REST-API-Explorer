/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license. See full license at the bottom of this file.
 */

#import "AuthenticationManager.h"
#import <ADAuthenticationResult.h>
#import "O365Auth.h"
#import <ADTokenCacheStoreItem.h>

//The buffer in number of seconds added to the current time when checking if the access token expired
NSInteger const TokenExpirationBuffer = 300;

@interface AuthenticationManager()

@property (nonatomic, assign) BOOL isRefreshing;
@property (nonatomic, strong) O365Auth *o365Auth;
@end

@implementation AuthenticationManager

// Use a single authentication manager for the application.
+ (AuthenticationManager *)sharedInstance
{
    static AuthenticationManager *sharedInstance;
    static dispatch_once_t onceToken;
    
    // Initialize the AuthenticationManager only once.
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AuthenticationManager alloc] init];
        sharedInstance.isRefreshing = NO;
        sharedInstance.o365Auth = [[O365Auth alloc] init];
    });
    
    return sharedInstance;
}


#pragma mark - properties
- (void) setIsO365Connected:(BOOL)isAzureConnected{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:isAzureConnected forKey:@"O365Connected"];
    [userDefaults synchronize];
}

- (BOOL) isO365Connected{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"O365Connected"];
}

#pragma mark - O365 connection
- (void)connectO365{
    self.o365Auth.delegate = self;
    [self.o365Auth acquireAuthToken];
}


#pragma mark - Refresh roken
- (void)checkAndRefreshToken{
    if(self.refreshToken) {
        NSDate *now = [NSDate dateWithTimeIntervalSinceNow:TokenExpirationBuffer];
        NSComparisonResult result = [self.expiresDate compare:now];
        switch (result) {
            case NSOrderedSame:
            case NSOrderedAscending:{
                self.isRefreshing = YES;
                [self.o365Auth refreshToken:self.refreshToken];
            }
                break;
            case NSOrderedDescending:
                break;
            default:
                break;
        }
    }
    
}


#pragma mark - AuthHelper Delegates

- (void) authCompleteWithToken:(NSString *)authToken
                    refreshToken:(NSString *)refreshToken
                       expirates:(NSDate *)expiresOn
                        authType:(AuthType)authType{
    self.accessToken = authToken;
    self.refreshToken = refreshToken;
    self.expiresDate = expiresOn;
    
    self.isO365Connected = YES;

    [self.authDelegate authSuccess];
}

- (void) authFailure:(NSError *)error
              authType:(AuthType)authType{
    [self disconnect];
    [self.authDelegate authFailure:error];
}

- (void) refreshToken:(NSString *)accessToken
           refreshToken:(NSString *)refreshToken
              expirates:(NSDate *)expiresOn
               authType:(AuthType)authType{
    self.isRefreshing = NO;
    self.accessToken = accessToken;
    self.refreshToken = refreshToken;
    self.expiresDate = expiresOn;
}

- (void) refreshTokenFailure:(NSError *)error
                      authType:(AuthType)authType{
    self.isRefreshing = NO;
    [self disconnect];
    [self.authDelegate authDisconnect:error];
}



#pragma mark - disconnect

- (void)disconnect{
    if (self.o365Auth){
        [self.o365Auth clearCredentials];
    }

    self.isO365Connected = NO;
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
