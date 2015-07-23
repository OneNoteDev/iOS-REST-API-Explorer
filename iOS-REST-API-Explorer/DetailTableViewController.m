/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license. See full license at the bottom of this file.
 */

#import "DetailTableViewController.h"
#import "ResizableTextTableViewCell.h"
#import "NetworkManager.h"
#import "ParamsListTableViewController.h"
#import "ParamsHelperDelegate.h"
#import "ParamsTextTableViewController.h"

NSString* const kResizableTextCellId = @"resizableCellId";
NSString* const kParamsCellId = @"paramsCellId";
NSString* const kUrlCellId = @"urlCellId";

@interface DetailTableViewController () <ParamsHelperDelegate>

@property (nonatomic, assign) BOOL hasParams;
@property (nonatomic, assign) BOOL hasCustomHeader;

@property (nonatomic, strong) NSString *responseHeader;
@property (nonatomic, strong) NSString *responseBody;

@end

@implementation DetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0;
    
    if(self.operation.params && self.operation.params > 0)
        _hasParams = YES;
    else
        _hasParams = NO;
    
    if(self.operation.customHeader && self.operation.customHeader.count > 0)
        _hasCustomHeader = YES;
    else
        _hasCustomHeader = NO;

    _responseHeader = @"";
    _responseBody = @"";
    
    self.title = self.operation.operationName;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section == 0)
        return @"Operation Description";
    
    if(section == 1)
        return @"API URL";
    
    if(_hasParams && _hasCustomHeader){
        if(section == 2)
            return @"Custom Request Header";
        else if(section == 3)
            return @"Parameters";
        else if(section == 4)
            return @"Response Header";
        else
            return @"Response Body";
    }
    else if(_hasParams){
        if(section == 2)
            return @"Parameters";
        else if(section == 3)
            return @"Response Header";
        else
            return @"Response Body";
        
    }
    else if(_hasCustomHeader){
        if(section == 2)
            return @"Custom Request Header";
        else if(section == 3)
            return @"Response Header";
        else
            return @"Response Body";
    }
    else{
        if(section == 2)
            return @"Response Header";
        else
            return @"Response Body";
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 4 + (_hasParams?1:0) + (_hasCustomHeader?1:0);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if((_hasParams && _hasCustomHeader && section == 3) ||
       (_hasParams && !_hasCustomHeader && section == 2))
        return self.operation.params.count;

    else
        return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Snippet Info
    if(indexPath.section == 0){
        if(indexPath.row == 0){

            ResizableTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kResizableTextCellId];
            
            // resizing of the row height
            cell.textView.text = nil;   // to negate the bug where whole text becomes a link after reload
            if(self.operation){
                cell.textView.text = [NSString stringWithFormat:@"%@\n\nDocumentation link: %@", self.operation.descriptionString, self.operation.documentationLinkString];
            }
            else{
                cell.textView.text = @"";
            }
            cell.textView.editable = NO;
            cell.textView.dataDetectorTypes = UIDataDetectorTypeLink;
            
            cell.heightConstraint.constant = ceilf([[cell textView] sizeThatFits:CGSizeMake(self.tableView.frame.size.width - 20, FLT_MAX)].height);
            
            [cell layoutIfNeeded];
            [cell updateConstraints];
            
            return cell;
        }
        else
            return nil;
    }
    // API URL
    else if(indexPath.section == 1){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kUrlCellId];
        
        cell.textLabel.text = self.operation.operationURLString;
        
        return cell;
    }
    else if(indexPath.section == 2 && _hasCustomHeader){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kParamsCellId];
        
        cell.textLabel.text = [self.operation.customHeader allKeys][indexPath.row];
        cell.detailTextLabel.text = [self.operation.customHeader allValues][indexPath.row];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
    }
    
    // params
    else if((indexPath.section == 2 && _hasParams) ||
            (indexPath.section == 3 && _hasParams && _hasCustomHeader)){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kParamsCellId];
        
        cell.textLabel.text = nil;
        cell.textLabel.text = self.operation.params.allKeys[indexPath.row];
        
        if([[self.operation.params.allValues[indexPath.row] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""])
            cell.detailTextLabel.text = @"Required";
        else
            cell.detailTextLabel.text = self.operation.params.allValues[indexPath.row];
        
        return cell;
    }
    
    // response header
    else if((indexPath.section == 2 && !_hasParams && !_hasCustomHeader) ||
            (indexPath.section == 3 && _hasParams && !_hasCustomHeader) ||
            (indexPath.section == 3 && !_hasParams && _hasCustomHeader) ||
            (indexPath.section == 4 && _hasParams && _hasCustomHeader)){
        ResizableTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kResizableTextCellId];
        
        // resizing of the row height
        cell.textView.text = @"";
        cell.textView.text = self.responseHeader;
        cell.textView.dataDetectorTypes = UIDataDetectorTypeLink;
        cell.heightConstraint.constant = ceilf([[cell textView] sizeThatFits:CGSizeMake(self.tableView.frame.size.width - 20, FLT_MAX)].height);
        
        [cell layoutIfNeeded];
        [cell updateConstraints];
        
        return cell;
        
    }
    else{ // response body
        ResizableTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kResizableTextCellId];
        
        // resizing of the row height
        cell.textView.editable = NO;
        cell.textView.text = @"";
        cell.textView.text = self.responseBody;
        cell.textView.dataDetectorTypes = UIDataDetectorTypeLink;
        cell.heightConstraint.constant = ceilf([[cell textView] sizeThatFits:CGSizeMake(self.tableView.frame.size.width - 20, FLT_MAX)].height);
        
        [cell layoutIfNeeded];
        [cell updateConstraints];
        
        return cell;
    }
 
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if(indexPath.section == 1){
            [self performSegueWithIdentifier:@"showTextEdit" sender:nil];
    }
    
    
    else if((indexPath.section == 2 && _hasParams && !_hasCustomHeader) ||
            (indexPath.section == 3 && _hasParams && _hasCustomHeader)){
        
        int row = (int)indexPath.row;
        NSString *key = self.operation.params.allKeys[row];
        ParamsSourceType type = [[self.operation.paramsSource objectForKey:key] intValue];

        if(type == ParamsSourceTextEdit)
            [self performSegueWithIdentifier:@"showTextEdit" sender:nil];
        else if(type == ParamsSourceGetPages)
            [self performSegueWithIdentifier:@"showListPages" sender:nil];
        else if(type == ParamsSourceGetSections)
            [self performSegueWithIdentifier:@"showListSections" sender:nil];
        else if(type == ParamsSourceGetNotebooks)
            [self performSegueWithIdentifier:@"showListNotebooks" sender:nil];
    }
    
    else{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"showTextEdit"]){
        ParamsTextTableViewController *vc = segue.destinationViewController;
        vc.operation = self.operation;
        
        if(self.tableView.indexPathForSelectedRow.section == 1)
            vc.selectedKey = @"API URL";
        else
            vc.selectedKey = self.operation.params.allKeys[self.tableView.indexPathForSelectedRow.row];
        vc.isEditable = YES;
        vc.delegate = self;
    }
    else if([segue.identifier isEqualToString:@"showListSections"]){
        ParamsListTableViewController *vc = segue.destinationViewController;
        vc.paramsSourceType = ParamsSourceGetSections;
        vc.title = @"SectionID";
        vc.paramsDelegate = self;
    }
    
    else if([segue.identifier isEqualToString:@"showListNotebooks"]){
        ParamsListTableViewController *vc = segue.destinationViewController;
        vc.paramsSourceType = ParamsSourceGetNotebooks;
        vc.title = @"NotebookID";
        vc.paramsDelegate = self;
    }
    else if([segue.identifier isEqualToString:@"showListPages"]){
        ParamsListTableViewController *vc = segue.destinationViewController;
        vc.paramsSourceType = ParamsSourceGetPages;
        vc.title = @"PageID";
        vc.paramsDelegate = self;
    }
    
}



#pragma mark - Run

- (BOOL) paramsTest{
    // check operation loaded
    if(!self.operation){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error"
                                                                                 message:@"Select an operation"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            ;
        }]];
        
        [self presentViewController:alertController animated:YES completion:^{
            ;
        }];
        
        return NO;
    }
    
    // test all params filled
    NSArray *keys = self.operation.params.allKeys;
    NSMutableArray *nonFilledParamsList = [NSMutableArray new];
    
    for (NSString *key in keys){
        if( [[[self.operation.params objectForKey:key] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]){
            [nonFilledParamsList addObject:key];
        }
    }
    
    if(nonFilledParamsList.count == 0)
        return YES;
    else{
        NSMutableString *errorString = [NSMutableString stringWithString:@"The following parameters are not filled in:-\n"];
        for(NSString *key in nonFilledParamsList){
            [errorString appendString:@"\n"];
            [errorString appendString:key];
        }

        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error"
                                                                                 message:errorString
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            ;
        }]];
        
        [self presentViewController:alertController animated:YES completion:^{
            ;
        }];
        
        return NO;
    }
}

- (IBAction)runTapped:(id)sender {
    // Check if operation is valid and all parameters are filled
    if(![self paramsTest]){
        return;
    }

    // Set activity indicator
    UIActivityIndicatorView *ac = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    ac.transform = CGAffineTransformMakeScale(1.5, 1.5);
    [ac startAnimating];
    self.tableView.tableHeaderView = ac;

    // GET
    if(self.operation.operationType == OperationGet){

        [NetworkManager get:self.operation.operationURLString
                queryParams:self.operation.params
             responseAsHTML:self.operation.responseAsHTML
                    success:^(id responseHeader, id responseObject) {
                        self.responseHeader = [NSString stringWithFormat:@"%@", responseHeader];
                        self.responseBody = [NSString stringWithFormat:@"%@", responseObject];;
                        self.tableView.tableHeaderView = nil;

                        [self.tableView reloadData];
                    } failure:^(id responseObject) {
                        self.responseBody = [(NSError *)responseObject localizedDescription];
                        
                        self.tableView.tableHeaderView = nil;
                        [self.tableView reloadData];
                    }];
    }
    
    //Custom POST
    else if(self.operation.operationType == OperationPostCustom) {
        
        [NetworkManager post:self.operation.operationURLString
                customHeader:self.operation.customHeader
                  customBody:self.operation.customBody
                     success:^(id responseHeader, id responseObject) {
                         self.responseHeader = [NSString stringWithFormat:@"%@", responseHeader];
                         self.responseBody = [NSString stringWithFormat:@"%@", responseObject];
                         
                         self.tableView.tableHeaderView = nil;
                         [self.tableView reloadData];
                         
                     } failure:^(id responseObject) {
                         self.responseBody = [(NSError *)responseObject localizedDescription];
                         self.tableView.tableHeaderView = nil;
                         [self.tableView reloadData];
                     }];
    }
    
    // POST
    else if(self.operation.operationType == OperationPost){
        [NetworkManager post:self.operation.operationURLString
                 queryParams:self.operation.params
                     success:^(id responseHeader, id responseObject) {
                         self.responseHeader = [NSString stringWithFormat:@"%@", responseHeader];
                         self.responseBody = [NSString stringWithFormat:@"%@", responseObject];;
                         self.tableView.tableHeaderView = nil;
                         [self.tableView reloadData];
                         
                     } failure:^(id responseObject) {
                         self.responseBody = [(NSError *)responseObject localizedDescription];;
                         self.tableView.tableHeaderView = nil;
                         [self.tableView reloadData];
                     }];
    }
    
    // DELETE
    else if(self.operation.operationType == OperationDelete){
        [NetworkManager deleteOperation:self.operation.operationURLString
                 queryParams:self.operation.params
                     success:^(id responseHeader, id responseObject) {
                         self.responseHeader = [NSString stringWithFormat:@"%@", responseHeader];
                         self.responseBody = [NSString stringWithFormat:@"%@", responseObject];
                        self.tableView.tableHeaderView = nil;
                         [self.tableView reloadData];
                         
                     } failure:^(id responseObject) {
                         self.responseBody = [(NSError *)responseObject localizedDescription];
                         self.tableView.tableHeaderView = nil;
                         [self.tableView reloadData];
                     }];
    }
    
    // POST multipart form
    else if(self.operation.operationType == OperationPostMultiPart){
        [NetworkManager postWithMultipartForm:self.operation.operationURLString
                                  queryParams:self.operation.params
                             multiformObjects:self.operation.multiPartObjectArray
                                      success:^(id responseHeader, id responseObject) {
                                          self.responseHeader = [NSString stringWithFormat:@"%@", responseHeader];
                                          self.responseBody = [NSString stringWithFormat:@"%@", responseObject];
                                          self.tableView.tableHeaderView = nil;
                                          [self.tableView reloadData];
                                      } failure:^(id responseObject) {
                                          self.responseBody = [(NSError *)responseObject localizedDescription];
                                          self.tableView.tableHeaderView = nil;
                                          [self.tableView reloadData];
                                      }];
    }
    
    // PATCH
    else if(self.operation.operationType == OperationPatch){
        [NetworkManager patchOperation:self.operation.operationURLString
                           queryParams:self.operation.params
                               success:^(id responseHeader, id responseObject) {
                                   self.responseHeader = [NSString stringWithFormat:@"%@", responseHeader];
                                   self.responseBody = [NSString stringWithFormat:@"%@", responseObject];
                                   self.tableView.tableHeaderView = nil;
                                   [self.tableView reloadData];
                               } failure:^(id responseObject) {
                                   self.responseBody = [(NSError *)responseObject localizedDescription];
                                   self.tableView.tableHeaderView = nil;
                                   [self.tableView reloadData];
                               }];
    }
}

#pragma mark - Params Delegate

- (void)onSelectedValue:(NSString *)value withParamsType:(ParamsSourceType)sourceType{

    
    if(sourceType == ParamsSourceGetSections || sourceType == ParamsSourceGetNotebooks || sourceType == ParamsSourceGetPages){
        // change the url
        NSString *paramsId;
        if(sourceType == ParamsSourceGetNotebooks)
            paramsId = ParamsNotebookIDKey;
        else if(sourceType == ParamsSourceGetPages)
            paramsId = ParamsPageIDKey;
        else if(sourceType == ParamsSourceGetSections)
            paramsId = ParamsSectionIDKey;
        
        NSMutableString *newURLString = [[NSMutableString alloc] initWithString:self.operation.operationURLString];
        [newURLString replaceOccurrencesOfString:[NSString stringWithFormat:@"{%@}", paramsId]
                                      withString:value options:NSLiteralSearch range:NSMakeRange(0, self.operation.operationURLString.length)];

        self.operation.operationURLString = newURLString;
        
        NSMutableDictionary *newParams = [NSMutableDictionary dictionaryWithDictionary:self.operation.params];
                [newParams setObject:value forKey:paramsId];

        self.operation.params = newParams;
    }
    
    [self.tableView reloadData];
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
