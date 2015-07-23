/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license. See full license at the bottom of this file.
 */

#import "NetworkManager.h"
#import <AFNetworking.h>
#import "AuthenticationManager.h"
#import "Operation.h"
#import "AFHTTPResponseSerializerHTML.h"

@interface NetworkManager ()

@property (nonatomic, strong) NSString *protocol;
@property (nonatomic, strong) NSString *host;
@property (nonatomic, strong) NSArray *keysToRemove;
@end

@implementation NetworkManager

// Some values are handled in URL manipulation, no need to be included as
// parameters in the request.
+ (NSArray*) keysToRemove{
    static NSArray *_keysToRemove;
    if(_keysToRemove == nil)
        _keysToRemove = @[ParamsSectionIDKey, ParamsPageIDKey, ParamsNotebookIDKey];
    return _keysToRemove;
}

+ (NSDictionary*) paramsRemove:(NSArray*)keys from:(NSDictionary*)params{
    NSMutableDictionary *newParams = [NSMutableDictionary dictionaryWithDictionary:params];
    [newParams removeObjectsForKeys:keys];
    return newParams;
}

+ (void)get:(NSString*)path queryParams:(NSDictionary*)queryParams
responseAsHTML:(BOOL)responseAsHTML
    success:(void (^)(id responseHeader, id responseObject))success
    failure:(void (^)(id responseObject))failure{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", [[AuthenticationManager sharedInstance] accessToken]]
                     forHTTPHeaderField:@"Authorization"];
   
    if(responseAsHTML){
        manager.responseSerializer = [[AFHTTPResponseSerializerHTML alloc] init];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    }
    
    [manager GET:path
      parameters:[self paramsRemove:self.keysToRemove from:queryParams]
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             success(operation.response.allHeaderFields, responseObject);
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             failure(error);
         }];
}

+ (void)post:(NSString*)path queryParams:(NSDictionary*)queryParams
     success:(void (^)(id responseHeader, id responseObject))success
     failure:(void (^)(id responseObject))failure{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
    [serializer setValue:[NSString stringWithFormat:@"Bearer %@", [[AuthenticationManager sharedInstance] accessToken]]
      forHTTPHeaderField:@"Authorization"];
    manager.requestSerializer = serializer;
    
    [manager POST:path
       parameters:[self paramsRemove:self.keysToRemove from:queryParams]
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              success(operation.response.allHeaderFields, responseObject);
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              failure(error);
          }];
    
}

+ (void)deleteOperation:(NSString*)path queryParams:(NSDictionary*)queryParams
                success:(void (^)(id responseHeader, id responseObject))success
                failure:(void (^)(id responseObject))failure{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", [[AuthenticationManager sharedInstance] accessToken]]
                     forHTTPHeaderField:@"Authorization"];
    
    [manager DELETE:path
         parameters:[self paramsRemove:self.keysToRemove from:queryParams]
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                success(operation.response.allHeaderFields, responseObject);
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                failure(error);
            }];
    
}

+ (void)patchOperation:(NSString*)path queryParams:(NSDictionary*)queryParams
               success:(void (^)(id responseHeader, id responseObject))success
               failure:(void (^)(id responseObject))failure{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
    [serializer setValue:[NSString stringWithFormat:@"Bearer %@", [[AuthenticationManager sharedInstance] accessToken]]
      forHTTPHeaderField:@"Authorization"];
    [serializer setValue:@"" forHTTPHeaderField:@"Accept-Encoding"];
    
    manager.requestSerializer = serializer;

    [manager PATCH:path
        parameters:[NSArray arrayWithObject:[self paramsRemove:self.keysToRemove from:queryParams]]
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                success(operation.response.allHeaderFields, responseObject);
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                failure(error);
            }];
    
}


+ (void)post:(NSString*)path
customHeader:(NSDictionary*)customHeader
  customBody:(NSString*)bodyString
     success:(void (^)(id responseHeader, id responseObject))success
     failure:(void (^)(id responseObject))failure{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:path]];
    [request setHTTPMethod:@"POST"];

    [request addValue:[NSString stringWithFormat:@"Bearer %@", [[AuthenticationManager sharedInstance] accessToken]]
   forHTTPHeaderField:@"Authorization"];

    //set headers
    NSArray *customHeaderArray = [customHeader allKeys];
    for(NSString *key in customHeaderArray){
        [request addValue:[customHeader objectForKey:key] forHTTPHeaderField:key];
    }
    //create the body
    NSMutableData *postBody = [NSMutableData data];
    [postBody appendData:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
    
    //post
    [request setHTTPBody:postBody];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]
                                         initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation.response.allHeaderFields, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
    [operation start];
}

+ (void)postWithMultipartForm:(NSString*)path
                  queryParams:(NSDictionary*)queryParams
             multiformObjects:(NSArray*)multiformObjects
                      success:(void (^)(id responseHeader, id responseObject))success
                      failure:(void (^)(id responseObject))failure{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", [[AuthenticationManager sharedInstance] accessToken]]
                     forHTTPHeaderField:@"Authorization"];
    
    
    [manager POST:path parameters:[self paramsRemove:self.keysToRemove from:queryParams] constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {

        for (MultiformObject *obj in multiformObjects){
            [formData appendPartWithHeaders:obj.headers body:obj.body];
        }
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation.response.allHeaderFields, responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
    
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
