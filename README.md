# OneNote REST API Explorer for iOS
[![Build Status](https://travis-ci.org/OneNoteDev/iOS-REST-API-Explorer.svg)](https://travis-ci.org/OneNoteDev/iOS-REST-API-Explorer)

**Table of contents**

* [Introduction](#introduction)
* [Change History](#change-history)
* [Prerequisites](#prerequisites)
* [Set Up Your Environment](#set-up-your-environment)
* [Understand the code](#understand-the-code)
* [Questions and comments](#questions-and-comments)
* [Additional resources](#additional-resources)



**Introduction**

The OneNote REST API Explorer for iOS explores the simple REST calls that access, add, update, and delete OneNote entities such as notebooks, section groups, sections, and pages. The app lets you authenticate against an Office 365 tenant and perform standard operations against the OneNote service in Office 365.

This sample includes the following operations for OneNote:

**Notebook**

* Get a list of your notebooks
* Get notebooks and expand notebook sections
* Get a notebook by id
* Get metadata for a notebook
* Get notebooks by name
* Get notebook shared by others
* Get a sorted list of notebooks with metadata
* Create a new notebook

**Section group**

* Get a list of section groups
* Get a list of all section groups in a notebook
  
**Sections**

* Get a list of sections in a notebook
* Get a list of all sections
* Get sections with a specific name
* Get sections by name
* Get metadata for a section
* Create a section

**Pages**

* Post a simple page with HTML content
* Post a page with an embedded image
* Post a page under a named section
* Post a page with a PDF attachment
* Get pages with a specific title
* Post a page with a snapshot of a web 
* Delete a page
* Append text to a page
* Post a page with an Url snapshot
* Get the pages in a section
* Post pages with rendered attachments
* Post a page with note tags
* Post a page with business card image text
* Post a page with extracted webpage text
* Post a page with a recipe
* Post a page with product info
* Get a list of all pages
* Get a paged list of pages
* Get a sorted list of pages
* Get the HTML contents of a page
* Get metadata of a specific page
* Search all pages

**Note:** Currently this sample does not support MSA authentication with accounts such as Outlook.com. This functionality will be included in future updates.

 
##Change History
July 2015:
* Initial release


##Prerequisites
* [Xcode](https://developer.apple.com/) from Apple.
* An Office 365 account. You can get an Office 365 account by signing up for an [Office 365 Developer site](http://msdn.microsoft.com/library/office/fp179924.aspx). This will give you access to the APIs that you can use to create apps that target Office 365 data.
* A Microsoft Azure tenant to register your application. Azure Active Directory provides identity services that applications use for authentication and authorization. A trial subscription can be acquired here: [Microsoft Azure](https://account.windowsazure.com/SignUp).

**Important**: You will also need to ensure your Azure subscription is bound to your Office 365 tenant. To do this see the Active Directory team's blog post, [Creating and Managing Multiple Windows Azure Active Directories](http://blogs.technet.com/b/ad/archive/2013/11/08/creating-and-managing-multiple-windows-azure-active-directories.aspx). The section **Adding a new directory** will explain how to do this. You can also read [Set up Azure Active Directory access for your Developer Site](http://msdn.microsoft.com/office/office365/howto/setup-development-environment#bk_CreateAzureSubscription) for more information.


* Installation of [CocoaPods](https://cocoapods.org/) as a dependency manager. CocoaPods will allow you to pull the  required dependencies into the project.


* A registered Azure application with a client id and redirect uri value. This procedure will be discussed in below section **Register your app with Microsoft Azure.** 

 

##Set Up Your Environment
Once you have an Office 365 account, an Azure Active Directory (AD) account that is bound to your Office 365 Developer site, you'll need to perform the following steps:

1. Install and use CocoaPods to get the required dependencies into your project. We'll show you how to do later in the section **Use CocoaPods to import the required dependencies**.
2. Register your application with Microsoft Azure, and configure the appropriate OneNote permissions.
3. Enter the Azure app registration specifics (ClientID and RedirectUri) into the OneNote REST API Explorer for iOS app.

## Use CocoaPods to import the required dependencies
Note: If you've never before used CocoaPods as a dependency manager you'll need to install it prior to getting the  dependencies into your project. If you already have it installed, you may skip this installation step and move on to **Getting the iOS dependencies in your project**.

Enter both of these lines of code from the **Terminal** app on your Mac.

    sudo gem install cocoapods
    pod setup

If the install and setup were successful, you should see the message **Setup completed in Terminal**. For more information about CocoaPods and its usage, see [CocoaPods](https://cocoapods.org/).


**Getting the iOS dependencies in your project.**
The iOS-OneNote-REST Explorer sample has a dependency on the Active Directory Authentication Library for iOS (ADAL) for enabling client to access OneNote for enterprise notebooks. The ADAL provides protocol support for OAuth 2.0, Web API integration with user level consent, and two-factor authentication.  It also uses AFNetworking to help manage REST communication between the app and the OneNote service. The sample contains a podfile that will get the ADAL and AFNetworking components (pods) into your project. It's located in the root ("Podfile"). The syntax should look something similar to this:


	pod 'AFNetworking', '2.5.4'
	pod 'ADALiOS', '1.2.4'


You'll simply need to navigate to the project directory in the **Terminal** (root of the project folder) and run the following command.


    pod install

Note: You should receive confirmation that these dependencies have been added to the project.  If there is a syntax error in the Podfile, you will encounter an error when you run the install command.

## Register your app with Microsoft Azure
1.	Sign in to the [Azure Management Portal](https://manage.windowsazure.com), using your Azure AD credentials.
2.	Click **Active Directory** on the left menu, then select the directory for your Office 365 developer site.
3.	On the top menu, click **Applications**.
4.	Click **Add** from the bottom menu.
5.	On the **What do you want to do page**, click **Add an application my organization is developing**.
6.	On the **Tell us about your application page**, specify **OneNote REST API Explorer** for the application name and select **NATIVE CLIENT APPLICATION** for type.
7.	Click the arrow icon on the lower-right corner of the page.
8.	On the **Application information** page, specify a **Redirect URI**, for this example, you can specify http://localhost/OneNoteRESTExplorer, and then select the check box in the lower-right hand corner of the page. Remember this value for the section below **Getting the ClientID and RedirectUri into the project**.
9.	Once the application has been successfully added, you will be taken to the **Quick Start** page for the application. From there, select **Configure** in the top menu.
10.	Under **permissions to other applications**, select **Add application.** Select OneNote and then the check box to proceed.
11.	For the **OneNote** application, add the following permissions:
    * View and modify OneNote notebooks in your organization
    * View and modify OneNote notebooks
    * Create pages in OneNote notebooks
![Add permissions for your OneNote app.](/readme-images/OneNotePermissions.jpg)

12. For the **Windows Azure Active Directory** application, add or make sure the following permission is enabled:
	* Enable sign-on and read users' profiles

13.	Copy the value specified for **Client ID** on the **Configure** page. Remember this value for the section below **Getting the ClientID and RedirectUri into the project**.
14.	Click **Save** in the bottom menu.




## Get the Client ID and Redirect Uri into the project

Finally, you'll need to add the Client ID and Redirect Uri you recorded from the previous section **Register your app with Microsoft Azure**.

Browse the **iOS-REST-API-Explorer** project directory and open up the workspace (iOS-REST-API-Explorer). In the **O365Auth.m** file (located at iOS-REST-API_Explorer/Library/Authentication/O365Auth.m), you'll see that the **ClientID** and **RedirectUri** values can be added to the top of the file. Supply the necessary values here:

    // You will set your application's clientId and redirect URI. You get
    // these when you register your application in Azure AD.
    static NSString * const REDIRECT_URL_STRING = @"ENTER_REDIRECT_URI_HERE";
    static NSString * const CLIENT_ID           = @"ENTER_CLIENT_ID_HERE";
    static NSString * const AUTHORITY           = @"https://login.microsoftonline.com/common";



##Understand the code
The REST API Explorer for iOS project uses these classes to manage interactions with OneNote.

###Sample project organization

This sample demonstrates OneNote REST calls across the notebook, pages, sections, and section groups entities in Office 365.  We use the Master-Detail app template in Xcode as a base. There are three primary sections of interest in the sample hierarchy:

- **Authentication (located in Library/Authentication)** - The OneNote API for iOS uses the Azure Active Directory Library (ADAL) for iOS for connecting your app to Office 365. The ADAL provides protocol support for OAuth2, Web API integration with user level consent, and two-factor authentication. The REST API Explorer uses the ADAL library to authenticate a user who wants to access OneNote for enterprise notebooks. The **Authentication** folder classes Authentication Manager and O365Auth that are responsible for authenticating the app to Office 365. Although not supported in this release, the code for authenticating with Microsoft accounts (office.com, live.com) will be added in a future release.

- **OneNote Operations (located in OneNoteOperations)** - The class **OneNoteManager** is the library of REST operations that can be performed in this sample against OneNote (GET, POST, DELETE, and PATCH). We've also created an **Operations class (Operation.h/Operation.m)** that represents a single REST operation - it captures the operation name, REST URL, and other metadata.

- **Networking (located in Network)**  - This sample uses the [AFNetworking](https://github.com/AFNetworking/AFNetworking) library for REST operations that will be downloaded with the pod install. See the class **NetworkManager** for the construction of each type of request.


## Questions and comments
We'd love to get your feedback about the OneNote REST API Explorer for iOS sample. You can send your feedback to us in the [Issues](https://github.com/OneNoteDev/iOS-REST-API-Explorer/issues) section of this repository. <br/>
General questions about Office 365 development should be posted to [Stack Overflow](http://stackoverflow.com/questions/tagged/Office365+API). Make sure that your questions are tagged with [Office365], [API], and [OneNote].

## Additional resources

* [OneNote APIs documentation](https://msdn.microsoft.com/en-us/library/office/dn575420.aspx)
* [OneNote developer center](http://dev.onenote.com/)
* [Microsoft Office 365 API Tools](https://visualstudiogallery.msdn.microsoft.com/a15b85e6-69a7-4fdf-adda-a38066bb5155)
* [Office Dev Center](http://dev.office.com/)
* [Office 365 APIs starter projects and code samples](http://msdn.microsoft.com/en-us/office/office365/howto/starter-projects-and-code-samples)


This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Copyright
Copyright (c) 2015 Microsoft. All rights reserved.

