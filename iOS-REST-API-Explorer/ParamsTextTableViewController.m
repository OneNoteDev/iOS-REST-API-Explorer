/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license. See full license at the bottom of this file.
 */

#import "ParamsTextTableViewController.h"
#import "Operation.h"

@interface ParamsTextTableViewController () <UITextFieldDelegate>

@end

@implementation ParamsTextTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = self.selectedKey;
    self.textField.delegate = self;

    if([self.selectedKey isEqualToString:@"API URL"]){
        self.textField.text = self.operation.operationURLString;
        self.textField.placeholder = self.selectedKey;
    }

    else{
        self.textField.text = [self.operation.params objectForKey:self.selectedKey];
        self.textField.placeholder = self.selectedKey;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textFieldDidEndEditing:(UITextField *)textField{

    if([self.selectedKey isEqualToString:@"API URL"])
        self.operation.operationURLString = self.textField.text;
    
    else{
   
        NSMutableDictionary *newParams = [NSMutableDictionary dictionaryWithDictionary:self.operation.params];
        [newParams setObject:self.textField.text forKey:self.selectedKey];
        self.operation.params = newParams;
    }
    [self.delegate onSelectedValue:self.textField.text withParamsType:ParamsSourceTextEdit];
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
