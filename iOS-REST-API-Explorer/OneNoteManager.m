/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license. See full license at the bottom of this file.
 */

#import "OneNoteManager.h"
#import "NetworkManager.h"
#import "Operation.h"
#import "AuthenticationManager.h"
#import "MultiformObject.h"
#import "OneNoteManagerConf.h"


@interface OneNoteManager()

@end

@implementation OneNoteManager

- (instancetype)init{
    self = [super init];
    if(self){
        // Initialize sections
        _sections = @[@"Notebooks",
                      @"Pages",
                      @"Sections",
                      @"Section Groups"];
        
        // Initialize operations
        _operationsArray = [NSMutableArray new];
        
        
        // Section - Notebooks
        NSMutableArray *notebooksArray = [NSMutableArray new];
        [notebooksArray addObject:[self getListOfAllNotebooks]];
        [notebooksArray addObject:[self getNotebooksAndSectionsExpand]];
        [notebooksArray addObject:[self getNotebookByName]];
        [notebooksArray addObject:[self getNotebookSpecificMetadata]];
        [notebooksArray addObject:[self getNotebookByID]];
        [notebooksArray addObject:[self getNotebookSharedByOthers]];
        [notebooksArray addObject:[self getNotebooksWithSelectedMetadata]];
        [notebooksArray addObject:[self createNotebook]];
        
        
        // Section 2 - Pages
        NSMutableArray *pagesArray = [NSMutableArray new];
        [pagesArray addObject:[self createSimplePage]];
        [pagesArray addObject:[self createPageUnderNamedSection]];
        [pagesArray addObject:[self getAllPages]];
        [pagesArray addObject:[self getPagesSkipAndTop]];
        [pagesArray addObject:[self searchAllPages]];
        [pagesArray addObject:[self deletePage]];
        [pagesArray addObject:[self getPageAsHTML]];
        [pagesArray addObject:[self createPageWithImage]];
        [pagesArray addObject:[self createPageWithURLSnapshot]];
        [pagesArray addObject:[self createPageWithPDF]];
        [pagesArray addObject:[self createPageWithNotetags]];
        [pagesArray addObject:[self createPageWithBusinessCard]];
        [pagesArray addObject:[self createPageWithRecipe]];
        [pagesArray addObject:[self createPageWithProductInfo]];
        [pagesArray addObject:[self getPageSpecificMetadata]];
        [pagesArray addObject:[self getSortedListOfPagesWithSelectedMetadata]];
        [pagesArray addObject:[self getPagesWithSpecificTitle]];
        [pagesArray addObject:[self getPagesInSpecificSection]];
        [pagesArray addObject:[self createPageWithWebPageSnapshot]];
        [pagesArray addObject:[self patchPage]];
        
        
        // Section 3 - Sections
        NSMutableArray *sectionsArray = [NSMutableArray new];
        [sectionsArray addObject:[self getAllSections]];
        [sectionsArray addObject:[self getSectionWithSpecificName]];
        [sectionsArray addObject:[self createSectionInNotebook]];
        [sectionsArray addObject:[self getMetadataOfSpecificSection]];
        [sectionsArray addObject:[self getSpecificNotebookSections]];
        
        // Section 4 - Section Groups
        NSMutableArray *sectionGroupsArray = [NSMutableArray new];
        [sectionGroupsArray addObject:[self getAllSectionGroups]];
        [sectionGroupsArray addObject:[self getSectionGroupsInNotebook]];

        
        
        // Add sections to the array
        [_operationsArray addObject:notebooksArray];
        [_operationsArray addObject:pagesArray];
        [_operationsArray addObject:sectionsArray];
        [_operationsArray addObject:sectionGroupsArray];

        
    }
    return self;
}





#pragma mark - Notebook Snippets


//Queries for all notebooks in OneNote and returns a list
- (Operation*) getListOfAllNotebooks{
    return [[Operation alloc] initWithOperationName:@"GET: List of all notebooks"
                                          urlString:[self createURLString:@"me/notes/notebooks"]
                                      operationType:OperationGet
                                        description:@"Queries for all notebooks in OneNote and returns a list"
                                  documentationLink:@"http://dev.onenote.com/docs#/reference/get-notebooks"
                                             params:nil
                                       paramsSource:nil];
}




//Demonstrates how the $expand query parameter can be used to return all notebooks and their
//descendant sections, sectionGroups in one roundtrip.
-(Operation*) getNotebooksAndSectionsExpand{
    return [[Operation alloc] initWithOperationName:@"GET: Get notebooks and sections ($expand)"
                                          urlString:[self createURLString:@"me/notes/notebooks"]
                                      operationType:OperationGet
                                        description:@"Demonstrates how the $expand query parameter can be used to return all notebooks and their descendant sections, sectionGroups in one roundtrip. In this case we are going to make a GET request on ~/notebooks?$expand=sections,sectionGroups($expand=sections)"
                                  documentationLink:@"http://dev.onenote.com/docs#/reference/get-notebooks"
                                             params:@{@"$expand":@"sections,sectionGroups($expand=sections)"}
                                       paramsSource:@{@"$expand":@(ParamsSourceTextEdit)}];
}

//Query for a list of all notebooks with a given name
-(Operation*) getNotebookByName{
    return [[Operation alloc] initWithOperationName:@"GET: Get notebooks with a specific name"
                                          urlString:[self createURLString:[NSString stringWithFormat:@"me/notes/notebooks"]]
                                      operationType:OperationGet
                                        description:@"Query for a list of all notebooks with a given name."
                                  documentationLink:@"http://dev.onenote.com/docs#/reference/get-notebooks"
                                             params:@{@"filter":@"name eq 'sample name'"}
                                       paramsSource:@{@"filter":@(ParamsSourceTextEdit)}];
    
}

//Get a list of all notebooks and then query the metadata for one of the selected notebooks.
-(Operation*) getNotebookSpecificMetadata{
    return [[Operation alloc] initWithOperationName:@"GET: Metadata of a specific notebook"
                                          urlString:[self createURLString:[NSString stringWithFormat:@"me/notes/notebooks/{%@}", ParamsNotebookIDKey]]
                                      operationType:OperationGet
                                        description:@"Get a list of all notebooks and then query the metadata for one of the selected notebooks.You'll need to provide the notebookID before running. Also this sample uses the notebook name as a parameter by default ($select). You can adjust to other values."
                                  documentationLink:@"http://dev.onenote.com/docs#/reference/get-notebooks"
                                             params:@{ParamsNotebookIDKey:@"",
                                                      @"$select":@"name"}
                                       paramsSource:@{ParamsNotebookIDKey:@(ParamsSourceGetNotebooks),
                                                      @"$select":@(ParamsSourceTextEdit)}];

}


//Query for a list of all notebooks with a given ID
- (Operation*) getNotebookByID{
    return [[Operation alloc] initWithOperationName:@"GET: Get a specific Notebook By ID"
                                          urlString:[self createURLString:[NSString stringWithFormat:@"me/notes/notebooks/{%@}", ParamsNotebookIDKey]]
                                      operationType:OperationGet
                                        description:@"Query for a list of all notebooks with a given ID"
                                  documentationLink:@"http://dev.onenote.com/docs#/reference/get-notebooks"
                                             params:@{ParamsNotebookIDKey:@""}
                                       paramsSource:@{ParamsNotebookIDKey:@(ParamsSourceGetNotebooks)}];
}

//Query for a list of all notebooks where the current user is not an Owner (i.e. the notebooks are
//owned by someone else and were shared with the current user with either a Reader or Contributor
//access level).
- (Operation*) getNotebookSharedByOthers{
    return [[Operation alloc] initWithOperationName:@"GET: Get notebook shared by others"
                                          urlString:[self createURLString:@"me/notes/notebooks"]
                                      operationType:OperationGet
                                        description:@"Query for a list of all notebooks where the current user is not an Owner (i.e. the notebooks are owned by someone else and were shared with the current user with either a Reader or Contributor access level)."
                                  documentationLink:@"http://dev.onenote.com/docs#/reference/get-notebooks"
                                             params:@{@"filter":@"userRole ne Microsoft.OneNote.Api.UserRole'Owner'"}
                                       paramsSource:@{@"filter":@(ParamsSourceTextEdit)}
                                             ];
}

//Get a sorted list of notebooks using the $select query parameter (notebook id, and name)
- (Operation*) getNotebooksWithSelectedMetadata{
    return [[Operation alloc] initWithOperationName:@"GET: Get notebooks with selected metadata"
                                          urlString:[self createURLString:@"me/notes/notebooks"]
                                      operationType:OperationGet
                                        description:@"Get a sorted list of notebooks using the $select query parameter (notebook id, and name)"
                                  documentationLink:@"http://dev.onenote.com/docs#/reference/get-notebooks"
                                             params:@{@"select":@"id, name"}
                                       paramsSource:@{@"select":@(ParamsSourceTextEdit)}
            ];
    
}

//Create a new blank notebook
- (Operation*) createNotebook{
    return [[Operation alloc] initWithOperationName:@"POST: Create new notebook"
                                          urlString:[self createURLString:@"me/notes/notebooks"]
                                      operationType:OperationPost
                                        description:@"Create a new blank notebook. Please provide the new notebook\'s name in the parameters section."
                                  documentationLink:@"http://dev.onenote.com/docs#/reference/get-notebooks"
                                             params:@{@"name":@"notebook name"}
                                       paramsSource:@{@"name":@(ParamsSourceTextEdit)}];
}

#pragma mark - Pages Snippets


//Create a simple page using HTML to describe the page content (under default section)
- (Operation*) createSimplePage{
    
    // Sample HTML Content here
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"simple_page" ofType:@"html" ];
    NSMutableString *htmlString = [NSMutableString stringWithString:[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil]];
    
    Operation *operation = [[Operation alloc] initWithOperationName:@"POST: Create a simple page using HTML"
                                                          urlString:[self createURLString:[NSString stringWithFormat:@"me/notes/sections/{%@}/pages", ParamsSectionIDKey]]
                                                      operationType:OperationPostCustom
                                                       customHeader:@{@"content-type":@"application/xhtml+xml"}
                                                         customBody:htmlString
                                                        description:@"Create a simple page using HTML to describe the page content (under default section)"
                                                  documentationLink:@"http://dev.onenote.com/docs#/reference/post-pages/v10pages"
                                                             params:@{ParamsSectionIDKey:@""}
                                                       paramsSource:@{ParamsSectionIDKey:@(ParamsSourceGetSections)}];
                            
                            
                            
    
    
    return operation;
}

//Create a page under a given section name using the \'sectionName\' query parameter.
- (Operation*) createPageUnderNamedSection{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"simple_page" ofType:@"html" ];
    NSString *htmlString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    Operation *operation = [[Operation alloc] initWithOperationName:@"POST: Create page under a named section"
                                                          urlString:[self createURLString:@"me/notes/pages"]
                                                      operationType:OperationPostCustom customHeader:@{@"content-type":@"application/xhtml+xml"}
                                                         customBody:htmlString
                                                        description:@"Create a page under a given section name using the \'sectionName\' query parameter."

                                                  documentationLink:@"http://dev.onenote.com/docs#/reference/post-pages/v10pages"
                                                             params:@{@"sectionName":@"New Section Created"} paramsSource:@{@"sectionName":@(ParamsSourceTextEdit)}];
    return operation;
                                                                                                                        
}


//Create a page with some formatted text and an image
- (Operation*) createPageWithImage{
    
    // Sample HTML Content here
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"create_page_with_image" ofType:@"html" ];
    NSMutableString *htmlString = [NSMutableString stringWithString:[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil]];

    MultiformObject *htmlPart = [[MultiformObject alloc] init];
    
    htmlPart.body = [htmlString dataUsingEncoding:NSUTF8StringEncoding];
    htmlPart.headers = @{@"Content-Disposition":@"form-data; name=\"Presentation\"",
                         @"Content-type":@"text/html"};
    
    MultiformObject *imagePart = [[MultiformObject alloc] init];
    
    imagePart.body = UIImageJPEGRepresentation([UIImage imageNamed:@"logo.jpg"], 1.0f);
    imagePart.headers = @{@"Content-Disposition":@"form-data; name=\"image1\"",
                          @"Content-type":@"image/jpeg"};
    
    Operation *operation = [[Operation alloc] initWithOperationName:@"POST: Create a page with image"
                                                          urlString:[self createURLString:[NSString stringWithFormat:@"me/notes/sections/{%@}/pages", ParamsSectionIDKey]]
                                                      operationType:OperationPostMultiPart
                                                        description:@"Create a page with some formatted text and an image"
                                                  documentationLink:@"http://dev.onenote.com/docs#/reference/post-pages/v10pages"
                                                   multiPartObjects:@[htmlPart, imagePart]];
    
    
    operation.params = @{ParamsSectionIDKey:@""};
    operation.paramsSource = @{ParamsSectionIDKey:@(ParamsSourceGetSections)};
    
    return operation;
}

//Create a page with a snapshot of the HTML of a web page on it
- (Operation*) createPageWithWebPageSnapshot{
    
    // Sample HTML Content here
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"create_page_with_web_snap" ofType:@"html" ];
    NSMutableString *htmlString = [NSMutableString stringWithString:[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil]];

    MultiformObject *htmlPart = [[MultiformObject alloc] init];
    
    htmlPart.body = [htmlString dataUsingEncoding:NSUTF8StringEncoding];
    htmlPart.headers = @{@"Content-Disposition":@"form-data; name=\"Presentation\"",
                         @"Content-type":@"text/html"};
    
    MultiformObject *webPart = [[MultiformObject alloc] init];
    NSString *webPartPath = [[NSBundle mainBundle] pathForResource:@"create_page_with_web_snap_part1" ofType:@"html"];
    webPart.body = [[NSMutableString stringWithString:[NSString stringWithContentsOfFile:webPartPath encoding:NSUTF8StringEncoding error:nil]] dataUsingEncoding:NSUTF8StringEncoding];
    
    webPart.headers = @{@"Content-Disposition":@"form-data; name=\"embeddedWeb\"",
                          @"Content-type":@"text/html"};
    
    Operation *operation = [[Operation alloc] initWithOperationName:@"POST: Page with snapshot (embedded web page)"
                                                          urlString:[self createURLString:[NSString stringWithFormat:@"me/notes/sections/{%@}/pages", ParamsSectionIDKey]]
                                                      operationType:OperationPostMultiPart
                                                        description:@"Create a page with a snapshot of the HTML of a web page on it"
                                                  documentationLink:@"http://dev.onenote.com/docs#/reference/post-pages/v10pages"
                                                   multiPartObjects:@[htmlPart, webPart]];
    
    
    operation.params = @{ParamsSectionIDKey:@""};
    operation.paramsSource = @{ParamsSectionIDKey:@(ParamsSourceGetSections)};
    
    return operation;
}


//Create a page with a snapshot of the OneNote.com homepage on it
- (Operation*) createPageWithURLSnapshot{
    
    // Sample HTML Content here
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"create_page_with_url_snapshot" ofType:@"html" ];
    NSMutableString *htmlString = [NSMutableString stringWithString:[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil]]; 
    
    Operation *operation = [[Operation alloc] initWithOperationName:@"POST: Page with a snapshot of a URL"
                                                          urlString:[self createURLString:[NSString stringWithFormat:@"me/notes/sections/{%@}/pages", ParamsSectionIDKey]]
                                                      operationType:OperationPostCustom
                                                       customHeader:@{@"content-type":@"application/xhtml+xml"}
                                                         customBody:htmlString
                                                        description:@"Create a page with a snapshot of the OneNote.com homepage on it."
                                                  documentationLink:@"http://dev.onenote.com/docs#/reference/post-pages/v10pages"
                                                             params:@{ParamsSectionIDKey:@""}
                                                       paramsSource:@{ParamsSectionIDKey:@(ParamsSourceGetSections)}];
    
    
    
    
    
    return operation;
}


//Create a page with a PDF file attachment rendered
- (Operation*) createPageWithPDF{
    
    // Sample HTML Content here
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"create_page_with_pdf" ofType:@"html" ];
    NSMutableString *htmlString = [NSMutableString stringWithString:[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil]];

    MultiformObject *htmlPart = [[MultiformObject alloc] init];
    
    htmlPart.body = [htmlString dataUsingEncoding:NSUTF8StringEncoding];
    htmlPart.headers = @{@"Content-Disposition":@"form-data; name=\"Presentation\"",
                         @"Content-type":@"text/html"};
    
    MultiformObject *part = [[MultiformObject alloc] init];
    NSString *partPath = [[NSBundle mainBundle] pathForResource:@"attachment" ofType:@"pdf"];
    part.body = [NSData dataWithContentsOfFile:partPath];
    part.headers = @{@"Content-Disposition":@"form-data; name=\"embeddedPDF\"",
                        @"Content-type":@"application/pdf"};
    
    Operation *operation = [[Operation alloc] initWithOperationName:@"POST: Page with a PDF attachment rendered"
                                                          urlString:[self createURLString:[NSString stringWithFormat:@"me/notes/sections/{%@}/pages", ParamsSectionIDKey]]
                                                      operationType:OperationPostMultiPart
                                                        description:@"Create a page with a PDF file attachment rendered"
                                                  documentationLink:@"http://dev.onenote.com/docs#/reference/post-pages/v10pages"
                                                   multiPartObjects:@[htmlPart, part]];
    
    
    operation.params = @{ParamsSectionIDKey:@""};
    operation.paramsSource = @{ParamsSectionIDKey:@(ParamsSourceGetSections)};
    
    return operation;
}

// Create a page with examples of note tags
- (Operation*) createPageWithNotetags{
    
    // Sample HTML Content here
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"create_page_with_note_tags" ofType:@"html" ];
    NSMutableString *htmlString = [NSMutableString stringWithString:[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil]];
    
    Operation *operation = [[Operation alloc] initWithOperationName:@"POST: Page with a notetags"
                                                          urlString:[self createURLString:[NSString stringWithFormat:@"me/notes/sections/{%@}/pages", ParamsSectionIDKey]]
                                                      operationType:OperationPostCustom
                                                       customHeader:@{@"content-type":@"application/xhtml+xml"}
                                                         customBody:htmlString
                                                        description:@"Create a page with examples of note tags"
                                                  documentationLink:@"http://dev.onenote.com/docs#/reference/post-pages/v10pages"
                                                             params:@{ParamsSectionIDKey:@""}
                                                       paramsSource:@{ParamsSectionIDKey:@(ParamsSourceGetSections)}];
    
    
    
    
    
    return operation;
}

//Create a page with a business card info automatically extracted from an image
- (Operation*) createPageWithBusinessCard{
    
    // Sample HTML Content here
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"create_page_with_business_cards" ofType:@"html" ];
    NSMutableString *htmlString = [NSMutableString stringWithString:[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil]];

    MultiformObject *htmlPart = [[MultiformObject alloc] init];
    
    htmlPart.body = [htmlString dataUsingEncoding:NSUTF8StringEncoding];
    htmlPart.headers = @{@"Content-Disposition":@"form-data; name=\"Presentation\"",
                         @"Content-type":@"text/html"};
    
    MultiformObject *part = [[MultiformObject alloc] init];
    NSString *partPath = [[NSBundle mainBundle] pathForResource:@"bizcard" ofType:@"png"];
    part.body = [NSData dataWithContentsOfFile:partPath];
    
    part.headers = @{@"Content-Disposition":@"form-data; name=\"businessCard\"",
                     @"Content-type":@"image/png"};
    
    Operation *operation = [[Operation alloc] initWithOperationName:@"POST: Page with a business card"
                                                          urlString:[self createURLString:[NSString stringWithFormat:@"me/notes/sections/{%@}/pages", ParamsSectionIDKey]]
                                                      operationType:OperationPostMultiPart
                                                        description:@"Create a page with a business card info automatically extracted from an image"
                                                  documentationLink:@"http://dev.onenote.com/docs#/reference/post-pages/v10pages"
                                                   multiPartObjects:@[htmlPart, part]];
    
    
    operation.params = @{ParamsSectionIDKey:@""};
    operation.paramsSource = @{ParamsSectionIDKey:@(ParamsSourceGetSections)};
    
    return operation;
}

//Create a page with a cooking recipe automatically extracted from an example webpage
- (Operation*) createPageWithRecipe{
    
    // Sample HTML Content here
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"create_page_with_recipe" ofType:@"html" ];
    NSMutableString *htmlString = [NSMutableString stringWithString:[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil]];

    Operation *operation = [[Operation alloc] initWithOperationName:@"POST: Page with a recipe"
                                                          urlString:[self createURLString:[NSString stringWithFormat:@"me/notes/sections/{%@}/pages", ParamsSectionIDKey]]
                                                      operationType:OperationPostCustom
                                                       customHeader:@{@"content-type":@"application/xhtml+xml"}
                                                         customBody:htmlString
                                                        description:@"Create a page with a cooking recipe automatically extracted from an example webpage"
                                                  documentationLink:@"http://dev.onenote.com/docs#/reference/post-pages/v10pages"
                                                             params:@{ParamsSectionIDKey:@""}
                                                       paramsSource:@{ParamsSectionIDKey:@(ParamsSourceGetSections)}];
    
    
    
    
    
    return operation;
}

// Create a page with a product info automatically extracted from an example amazon.com webpage
- (Operation*) createPageWithProductInfo{
    
    // Sample HTML Content here
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"create_page_with_product_info" ofType:@"html" ];
    NSMutableString *htmlString = [NSMutableString stringWithString:[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil]];
    
    Operation *operation = [[Operation alloc] initWithOperationName:@"POST: Page with a product info"
                                                          urlString:[self createURLString:[NSString stringWithFormat:@"me/notes/sections/{%@}/pages", ParamsSectionIDKey]]
                                                      operationType:OperationPostCustom
                                                       customHeader:@{@"content-type":@"application/xhtml+xml"}
                                                         customBody:htmlString
                                                        description:@"Create a page with a product info automatically extracted from an example amazon.com webpage"
                                                  documentationLink:@"http://dev.onenote.com/docs#/reference/post-pages/v10pages"
                                                             params:@{ParamsSectionIDKey:@""}
                                                       paramsSource:@{ParamsSectionIDKey:@(ParamsSourceGetSections)}];
    

    
    return operation;
}




// Delete an existing page
-(Operation*) deletePage{
    
    Operation *operation = [[Operation alloc]initWithOperationName:@"DELETE: Delete a page"
                                                         urlString:[self createURLString:[NSString stringWithFormat:@"me/notes/pages/{%@}", ParamsPageIDKey]]
                                                     operationType:OperationDelete
                                                       description:@"Delete an existing page"
                                                 documentationLink:@"http://dev.onenote.com/docs#/reference/get-pages"
                                                            params:@{ParamsPageIDKey:@""}
                                                      paramsSource:@{ParamsPageIDKey:@(ParamsSourceGetPages)}];
    return operation;
}







//Queries for all pages in OneNote and returns a paginated list.
- (Operation*) getAllPages{
    return [[Operation alloc] initWithOperationName:@"GET: List All Pages"
                                          urlString:[self createURLString:@"me/notes/pages"]
                                      operationType:OperationGet
                                        description:@"Queries for all pages in OneNote and returns a paginated list. By default, paging returns the first 20 pages ordered by last modified time descending (default sort order)."
                                  documentationLink:@"http://dev.onenote.com/docs#/reference/get-pages"
                                             params:nil
                                       paramsSource:nil];
}

//Shows how to use the $skip and $top query parameters
- (Operation*) getPagesSkipAndTop{
    return [[Operation alloc] initWithOperationName:@"GET: Pages Skip And Top"
                                          urlString:[self createURLString:@"me/notes/pages"]
                                      operationType:OperationGet
                                        description:@"Shows how to use the $skip and $top query parameters."
                                  documentationLink:@"http://dev.onenote.com/docs#/reference/get-pages"
                                             params:@{@"$skip":@"1",
                                                      @"$top":@"1"}
                                       paramsSource:@{@"$skip":@(ParamsSourceTextEdit),
                                                      @"$top":@(ParamsSourceTextEdit)}];
}



// This function does not work


//Search all pages and return the paginated list of matching pages that contain the given
//search term (case-insensitive search)
- (Operation*) searchAllPages{
    return [[Operation alloc] initWithOperationName:@"GET: Search all pages"
                                          urlString:[self createURLString:[NSString stringWithFormat:@"me/notes/sections/{%@}/pages", ParamsPageIDKey]]
                                      operationType:OperationGet
                                        description:@"Search all pages and return the paginated list of matching pages that contain the given search term."
            //search term (case-insensitive search)"
                                  documentationLink:@"http://dev.onenote.com/docs#/reference/get-notebooks"
                                             params:@{ParamsPageIDKey:@"",
                                                      @"$search":@"sample search term"}
                                       paramsSource:@{ParamsPageIDKey:@(ParamsSourceGetPages),
                                                      @"$search":@(ParamsSourceTextEdit)}];

}


//Get a paginated list of all pages and then return back the content of one of the selected pages as HTML
- (Operation*) getPageAsHTML
{
    Operation *operation =  [[Operation alloc] initWithOperationName:@"GET: Recall a pages content as HTML"
                                                           urlString:[self createURLString:[NSString stringWithFormat:@"me/notes/pages/{%@}/content", ParamsPageIDKey]]
                                                       operationType:OperationGet
                                                         description:@"Get a paginated list of all pages and then return back the content of one of the selected pages as HTML"
                                                   documentationLink:@"http://dev.onenote.com/docs#/reference/get-pages"
                                                              params:@{ParamsPageIDKey:@"",
                                                                       @"includeIDs":@"true"}
                             
                                                        paramsSource:@{ParamsPageIDKey:@(ParamsSourceGetPages),
                                                                       @"includeIDs":@(ParamsSourceTextEdit)}];
    
    operation.responseAsHTML = YES;
    return operation;
}


//Get a paginated list of all pages and then query the metadata for one of the selected pages.
-(Operation*) getPageSpecificMetadata{
    return [[Operation alloc] initWithOperationName:@"GET: Metadata of a specific page"
                                          urlString:[self createURLString:[NSString stringWithFormat:@"me/notes/pages/{%@}", ParamsPageIDKey]]
                                      operationType:OperationGet
                                        description:@"Get a paginated list of all pages and then query the metadata for one of the selected pages."
                                  documentationLink:@"http://dev.onenote.com/docs#/reference/get-pages"
                                             params:@{ParamsPageIDKey:@"",
                                                      @"$select":@"title"}
                                       paramsSource:@{ParamsPageIDKey:@(ParamsSourceGetPages),
                                                      @"$select":@(ParamsSourceTextEdit)}];
    
}

//Get a sorted list of pages using the $orderBy and $select parameters
- (Operation*) getSortedListOfPagesWithSelectedMetadata{
    return [[Operation alloc] initWithOperationName:@"GET: Sorted list of pages (selected metadata)"
                                          urlString:[self createURLString:@"me/notes/pages"]
                                      operationType:OperationGet
                                        description:@"Get a sorted list of pages using the $orderBy and $select parameters."
                                  documentationLink:@"http://dev.onenote.com/docs#/reference/get-pages"
                                             params:@{
                                                      @"select":@"title, id",
                                                      @"orderby":@"title"}
                                       paramsSource:@{
                                                      @"select":@(ParamsSourceTextEdit),
                                                      @"orderby":@(ParamsSourceTextEdit)}];
}

//Query for a paginated list of pages that contain a given title substring. This example
//shows how to use the $filter=contains(title, \'&lt;term&gt;\') query parameter.
- (Operation*) getPagesWithSpecificTitle{
    return [[Operation alloc] initWithOperationName:@"GET: Get pages with a specific title"
                                          urlString:[self createURLString:@"me/notes/pages"]
                                      operationType:OperationGet
                                        description:@"Query for a paginated list of pages that contain a given title substring. This example shows how to use the $filter=contains(title, \'&lt;term&gt;\') query parameter. Please enter a case-sensitive title substring in the parameters section."
                                  documentationLink:@"http://dev.onenote.com/docs#/reference/get-pages"
                                             params:@{@"filter":@"title eq 'specific title'"}
                                       paramsSource:@{@"filter":@(ParamsSourceTextEdit)}];
}

//Queries for all the pages that belong to a specific section
- (Operation*) getPagesInSpecificSection{
    return [[Operation alloc] initWithOperationName:@"GET: Get pages in a specific section"
                                          urlString:[self createURLString:[NSString stringWithFormat:@"me/notes/sections/{%@}/pages", ParamsSectionIDKey]]
                                      operationType:OperationGet
                                        description:@"Queries for all the pages that belong to a specific section."
                                  documentationLink:@"Queries for all the pages that belong to a specific section"
                                             params:@{ParamsSectionIDKey:@""}
                                       paramsSource:@{ParamsSectionIDKey:@(ParamsSourceGetSections)}];
}


//Add new trailing content to the default outline in an existing page
- (Operation*) patchPage{
    return [[Operation alloc] initWithOperationName:@"PATCH: Append content after body"
                                          urlString:[self createURLString:[NSString stringWithFormat:@"me/notes/pages/{%@}", ParamsPageIDKey]]
                                      operationType:OperationPatch
                                        description:@"Add new trailing content to the default outline in an existing page."
                                  documentationLink:@"http://dev.onenote.com/docs#/reference/get-pages"
                                             params:@{ParamsPageIDKey:@"",
                                                      @"Target":@"body",
                                                      @"Action":@"append",
                                                      @"Position":@"after",
                                                      @"Content":@"content here"}
                                       paramsSource:@{ParamsPageIDKey:@(ParamsSourceGetPages),
                                                      @"Action":@(ParamsSourceTextEdit),
                                                      @"Target":@(ParamsSourceTextEdit),
                                                      @"Position":@(ParamsSourceTextEdit),
                                                      @"Content":@(ParamsSourceTextEdit)}];

    
}
#pragma mark - Section Snippets

//Queries for all sections under all notebooks in OneNote and returns a list
- (Operation*) getAllSections{
    return [[Operation alloc] initWithOperationName:@"GET: List of all sections"
                                          urlString:[self createURLString:@"me/notes/sections"]
                                      operationType:OperationGet
                                        description:@"Queries for all sections under all notebooks in OneNote and returns a list."
                                  documentationLink:@"http://dev.onenote.com/docs#/reference/get-sections"
                                             params:nil
                                       paramsSource:nil];
}


//Query for a list of all sections with a given name. This example shows how to use
//the \'$filter=name eq \'&lt;term&gt;\' query parameter.
- (Operation*) getSectionWithSpecificName{
    return [[Operation alloc] initWithOperationName:@"GET: Sections with a specific name"
                                          urlString:[self createURLString:@"me/notes/sections"]
                                      operationType:OperationGet
                                        description:@"Query for a list of all sections with a given name. This example shows how to use the \'$filter=name eq \'&lt;term&gt;\' query parameter. Please enter the case-sensitive full section name to look for in the parameters section."
                                  documentationLink:@"http://dev.onenote.com/docs#/reference/get-sections"
                                             params:@{@"filter":@"name eq 'Test Section'"}
                                       paramsSource:@{@"filter":@(ParamsSourceTextEdit)}];
}


//Create a new blank section under one of the selected notebooks
- (Operation*) createSectionInNotebook{
    
    Operation *operation = [[Operation alloc]initWithOperationName:@"POST: Create new section"
                                                         urlString:[self createURLString:[NSString stringWithFormat:@"me/notes/notebooks/{%@}/sections", ParamsNotebookIDKey]]
                                                     operationType:OperationPost
                                                       description:@"Create a new blank section under one of the selected notebooks."
                                                 documentationLink:@"http://dev.onenote.com/docs#/reference/post-sections/v10notebooksidsections"
                                                            params:@{ParamsNotebookIDKey:@"",
                                                                     @"name": @"Sample Section Name"}
                                                      paramsSource:@{ParamsNotebookIDKey:@(ParamsSourceGetNotebooks),@"name":@(ParamsSourceTextEdit)}];

    return operation;
    
}

//Query for a list of all sections under one of the selected notebooks
- (Operation*) getSpecificNotebookSections{
    return [[Operation alloc] initWithOperationName:@"GET: List all sections under a specific notebook"
                                          urlString:[self createURLString:[NSString stringWithFormat:@"me/notes/notebooks/{%@}/sections", ParamsNotebookIDKey]]
                                      operationType:OperationGet
                                        description:@"First we get a list of all notebooks and then query for a list of all sections under one of the selected notebooks. Please select a specific notebook from the parameters section."
                                  documentationLink:@"http://dev.onenote.com/docs#/reference/get-sections"
                                             params:@{ParamsNotebookIDKey:@""}
                                       paramsSource:@{ParamsNotebookIDKey:@(ParamsSourceGetNotebooks)}];
}

//Get a list of all sections and then query the metadata for one of the selected sections.
- (Operation*) getMetadataOfSpecificSection{
    
    return [[Operation alloc] initWithOperationName:@"GET: Metadata of a specific sections"
                                          urlString:[self createURLString:[NSString stringWithFormat:@"me/notes/sections/{%@}", ParamsSectionIDKey]]
                                      operationType:OperationGet
                                        description:@"Get a list of all sections and then query the metadata for one of the selected sections."
                                  documentationLink:@"http://dev.onenote.com/docs#/reference/get-sections"
                                             params:@{ParamsSectionIDKey:@"",
                                                      @"select":@"id, name"}
                                       paramsSource:@{ParamsSectionIDKey:@(ParamsSourceGetSections),
                                                      @"select":@(ParamsSourceTextEdit)}];
}

#pragma mark - Section groups

//Queries for all sectionGroups under all notebooks in OneNote and returns a list.
- (Operation*) getAllSectionGroups{
    return [[Operation alloc] initWithOperationName:@"GET: List of all SectionGroups"
                                          urlString:[self createURLString:@"me/notes/sectionGroups"]
                                      operationType:OperationGet
                                        description:@"Queries for all sectionGroups under all notebooks in OneNote and returns a list."
                                  documentationLink:@"http://dev.onenote.com/docs#/reference/get-sectiongroups"
                                             params:nil
                                       paramsSource:nil];
}

//Queries for all section groups in a specific notebook
- (Operation*) getSectionGroupsInNotebook{
    return [[Operation alloc] initWithOperationName:@"GET: List of all SectionGroups in a notebook"
                                          urlString:[self createURLString:[NSString stringWithFormat:@"me/notes/notebooks/{%@}/sectionGroups", ParamsNotebookIDKey]]
                                      operationType:OperationGet
                                        description:@"Queries for all section groups in a specific notebook."
                                  documentationLink:@"http://dev.onenote.com/docs#/reference/get-sectiongroups"
                                             params:@{ParamsNotebookIDKey:@""}
                                       paramsSource:@{ParamsNotebookIDKey:@(ParamsSourceGetNotebooks)}];
}

#pragma mark - helper
- (NSString*) createURLString:(NSString*)path{
    NSMutableString *urlString = [NSMutableString new];
    [urlString appendString:[OneNoteManagerConf protocol]];
    [urlString appendString:@"://"];
    [urlString appendString:[OneNoteManagerConf hostName_beta]];
    [urlString appendString:path];
    return urlString;
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
