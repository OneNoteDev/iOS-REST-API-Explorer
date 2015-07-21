/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license. See full license at the bottom of this file.
 */

#import "ParamsListTableViewController.h"
#import "NetworkManager.h"
#import "Operation.h"
#import "OneNoteManager.h"


@interface ParamsListTableViewController ()

@property (nonatomic, strong) NSMutableArray *displayArray;
@property (nonatomic, strong) NSMutableArray *guidArray;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation ParamsListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _displayArray = [NSMutableArray new];
    _guidArray = [NSMutableArray new];
    
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicator.transform = CGAffineTransformMakeScale(1.5, 1.5);
    self.tableView.tableHeaderView = self.activityIndicator;
    [self.activityIndicator startAnimating];
    
    
    if(self.paramsSourceType == ParamsSourceGetSections)
        [self loadSections];
    else if(self.paramsSourceType == ParamsSourceGetNotebooks)
        [self loadNotebooks];
    else if(self.paramsSourceType == ParamsSourceGetPages)
        [self loadPages];

}

- (void) loadSections {
    // populate array with sections
    
    Operation *getSectionsOperation = [[[OneNoteManager alloc] init] getAllSections];
    
    [NetworkManager get:getSectionsOperation.operationURLString
            queryParams:getSectionsOperation.params
         responseAsHTML:NO
                success:^(id responseHeader, id responseObject) {
                    // population
                    [self.displayArray removeAllObjects];
                    [self.guidArray removeAllObjects];
                    
                    NSArray *sections = [responseObject objectForKey:@"value"];

                    for(id section in sections){
                        [self.displayArray addObject:[section objectForKey:@"name"]];
                        [self.guidArray addObject:[section objectForKey:@"id"]];
                    }
                    
                    // reload tableview
                    [self.activityIndicator stopAnimating];
                    [self.tableView reloadData];
                } failure:^(id responseObject) {
                    // fail
                    [self.activityIndicator stopAnimating];
                }];


}

- (void) loadNotebooks {
    // populate array with notebooks
    
    Operation *getNotebooksOperation = [[[OneNoteManager alloc] init] getListOfAllNotebooks];
    
    [NetworkManager get:getNotebooksOperation.operationURLString
            queryParams:getNotebooksOperation.params
         responseAsHTML:NO
                success:^(id responseHeader, id responseObject) {
                    // population
                    [self.displayArray removeAllObjects];
                    [self.guidArray removeAllObjects];
                    
                    NSArray *notebooks = [responseObject objectForKey:@"value"];
                    
                    for(id note in notebooks){
                        [self.displayArray addObject:[note objectForKey:@"name"]];
                        [self.guidArray addObject:[note objectForKey:@"id"]];
                    }
                    
                    // reload tableview
                    [self.activityIndicator stopAnimating];
                    [self.tableView reloadData];
                } failure:^(id responseObject) {
                    // fail
                    [self.activityIndicator stopAnimating];
                }];
}

- (void) loadPages {
    // populate array with pages
    Operation *getPagesOperation = [[[OneNoteManager alloc] init] getAllPages];
    
    [NetworkManager get:getPagesOperation.operationURLString
            queryParams:getPagesOperation.params
         responseAsHTML:NO
                success:^(id responseHeader, id responseObject) {
                    // population
                    [self.displayArray removeAllObjects];
                    [self.guidArray removeAllObjects];
                    
                    NSArray *pages = [responseObject objectForKey:@"value"];
                    
                    for(id page in pages){
                        [self.displayArray addObject:[page objectForKey:@"title"]];
                        [self.guidArray addObject:[page objectForKey:@"id"]];
                    }
                    
                    // reload tableview
                    [self.activityIndicator stopAnimating];
                    [self.tableView reloadData];
                } failure:^(id responseObject) {
                    // fail
                    [self.activityIndicator stopAnimating];
                }];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.displayArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = self.displayArray[indexPath.row];
    cell.detailTextLabel.text = self.guidArray[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.paramsDelegate onSelectedValue:self.guidArray[indexPath.row] withParamsType:self.paramsSourceType];
    [self.navigationController popViewControllerAnimated:YES];
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