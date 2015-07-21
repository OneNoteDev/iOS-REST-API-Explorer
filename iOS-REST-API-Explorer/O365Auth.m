/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license. See full license at the bottom of this file.
 */

#import "O365Auth.h"
#import <ADAuthenticationContext.h>
#import <ADAuthenticationSettings.h>

// ENTER: Set your application's clientId and redirect URI here. You get
// these when you register your application in Azure AD.
static NSString * const REDIRECT_URL_STRING = @"REDIRECT_URL_STRING";
static NSString * const CLIENT_ID           = @"CLIENT_ID";
static NSString * const AUTHORITY           = @"https://login.microsoftonline.com/common";

@interface O365Auth ()

@property (strong,   nonatomic) ADAuthenticationContext *authContext;
@property (readonly, nonatomic) NSURL    *redirectURL;
@property (readonly, nonatomic) NSString *authority;
@property (readonly, nonatomic) NSString *clientId;

@end

@implementation O365Auth


- (instancetype)init
{
    self = [super init];
    
    if (self) {
        // These are settings that you need to set based on your
        // client registration in Azure AD.
        _redirectURL = [NSURL URLWithString:REDIRECT_URL_STRING];
        _authority = AUTHORITY;
        _clientId = CLIENT_ID;
    }
    
    return self;
}


- (void) acquireAuthToken{
    [self acquireAuthTokenWithResourceId:@"https://onenote.com"
                             redirectURL:self.redirectURL
                               authority:self.authority
                                clientID:self.clientId
                       completionHandler:^(ADAuthenticationResult *result) {
                           if(AD_SUCCEEDED == result.status){
                               [self.delegate authCompleteWithToken:result.tokenCacheStoreItem.accessToken
                                                         refreshToken:result.tokenCacheStoreItem.refreshToken
                                                            expirates:result.tokenCacheStoreItem.expiresOn
                                                             authType:AuthType_O365];
                           }
                           else{
                               [self.delegate authFailure:[self generateError:result] authType:AuthType_O365];
                           }
                       }];
}


- (void) refreshToken:(NSString *)refreshToken{
    [self.authContext acquireTokenByRefreshToken:refreshToken
                                        clientId:CLIENT_ID
                                 completionBlock:^(ADAuthenticationResult *result) {
                                     if(AD_SUCCEEDED == result.status){
                                         [self.delegate refreshToken:result.tokenCacheStoreItem.accessToken
                                                          refreshToken:result.tokenCacheStoreItem.refreshToken
                                                             expirates:result.tokenCacheStoreItem.expiresOn
                                                              authType:AuthType_O365];
                                     }
                                     else{
                                         [self.delegate refreshTokenFailure:[self generateError:result] authType:AuthType_O365];
                                     }
                                 }];
}

// Acquire access and refresh tokens from Azure AD for the user
- (void)acquireAuthTokenWithResourceId:(NSString *)resourceId
                           redirectURL:(NSURL *)redirectURL
                             authority:(NSString *)authority
                              clientID:(NSString *)clientId
                     completionHandler:(void (^)(ADAuthenticationResult *result))completionHandler
{
    ADAuthenticationError *ADerror;
    self.authContext = [ADAuthenticationContext authenticationContextWithAuthority:self.authority
                                                                             error:&ADerror];
    
    // The first time this application is run, the [ADAuthenticationContext acquireTokenWithResource]
    // manager will send a request to the AUTHORITY (see the const at the top of this file) which
    // will redirect you to a login page. You will provide your credentials and the response will
    // contain your refresh and access tokens. The second time this application is run, and assuming
    // you didn't clear your token cache, the authentication manager will use the access or refresh
    // token in the cache to authenticate client requests.
    // This will result in a call to the service if you need to get an access token.
    [self.authContext acquireTokenWithResource:resourceId
                                      clientId:clientId
                                   redirectUri:redirectURL
                               completionBlock:^(ADAuthenticationResult *result){
                                   completionHandler(result);
                               }];
    
}

- (void) clearCredentials{
    id<ADTokenCacheStoring> cache = [ADAuthenticationSettings sharedInstance].defaultTokenCacheStore;
    ADAuthenticationError *error;
    
    // Clear the token cache.
    if ([[cache allItemsWithError:&error] count] > 0)
        [cache removeAllWithError:&error];
    
    // Remove all the cookies from this application's sandbox. ADAL will try to
    // get to access tokens based on auth code in the cookie.
    NSHTTPCookieStorage *cookieStore = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in cookieStore.cookies) {
        [cookieStore deleteCookie:cookie];
    }
}



- (NSError*) generateError:(ADAuthenticationResult *)result{
    NSError *error;
    
    if(result.status == AD_USER_CANCELLED){
        // Let's just say 101 is user cancel
        error = [NSError errorWithDomain:@"O365-iOS-OneNoteSample"
                                    code:101 userInfo:nil];
        
    }
    else{
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:@"Failed to acquire a token" forKey:NSLocalizedDescriptionKey];
        [errorDetail setObject:result.error.description forKey:@"ADALErrorDescription"];
        [errorDetail setObject:result.error.protocolCode forKey:@"ADALErrorProtocolCode"];
        
        //let's pick a unique error code of 100
        error = [NSError errorWithDomain:@"iOS-REST-API-Explorer"
                                    code:100 userInfo:errorDetail];
        
    }
    return error;
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
