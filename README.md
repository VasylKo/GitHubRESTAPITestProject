# GitHubRESTAPITestProject

Educational project to get in close touch with REST and JSON. 
This is my Swift app that uses a GitHub web service to get data from the GitHub gists API.
The app is made during reading the book by Christina Moulton - "iOS Apps with REST APIs: Building Web-Driven Apps in Swift".  
I have just left the main idea from the code proposed in the book (actually some parts was not working correctly at all, like pagination, gist loading, and e.t.c.). Also I have redesigned OAuth flow, error handling, made more abstract usage of 3d party libraries, app UI and UX, and other. While the book was written for swift 2.0 syntax, I have upgraded it to latest swift 2.3 syntax and up-to-date pods libraries.

**In this app you can:**  
**Without authorization:**  
1. Look at a list of public gists to see what’s new.  

**After authorization:**  
2. Star a gist so you can find it later.  
3. Look at a list of gists you have starred.  
4. Look at a list of your own gists.  
5. Look at details for a gist in a list.  
6. Create a new gist.  
7. Delete one of your gists.  

**Tech stack:** Swift 2.3, iOS 9, and Xcode 7.3.1  
**Main Pods:** Alamofire v3.4, SwiftyJSON v2.3, PINRemoteImage v2.1, Locksmith v2.0, Eureka v1.6
