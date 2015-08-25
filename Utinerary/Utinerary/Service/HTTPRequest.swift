//
//  HTTPRequest.swift
//  duress
//
//  Created by Cirrena on 7/1/15.
//  Copyright (c) 2015 Cirrena Pty Ltd. All rights reserved.
//

import UIKit


typealias  successCompletionBlock  = (result : AnyObject?)->Void
typealias   failedCompletionBlock = (result : AnyObject?)->Void

class HTTPRequest : NSObject , NSURLSessionDelegate{
    var mySession : NSURLSession!
    
    private static let timeOutInterval : NSTimeInterval = 30.0
    private static let allowCellularAccess = true
    
    
    init(session : NSURLSession!){
        mySession = session
    }
    convenience override init(){
        let theSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        self.init(session : theSession)
    }
    
    private func send(#urlRequest : NSMutableURLRequest!, successCompletionHandler : successCompletionBlock, failedCompletionHandler : failedCompletionBlock,  returnData : NSObject.Type?, returnParameters : NSDictionary?){

        let myTask : NSURLSessionDataTask =  mySession.dataTaskWithRequest(urlRequest, completionHandler: { [unowned self](myData : NSData!, myResponse :  NSURLResponse!, myError : NSError!) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                var parseError : NSError?
                let newStr = NSString(data: myData, encoding: NSUTF8StringEncoding)
                
                if let jsonObject : AnyObject?  = NSJSONSerialization.JSONObjectWithData(myData, options: NSJSONReadingOptions.MutableContainers, error: &parseError){
                    if let jsonDictionary  = jsonObject as? NSDictionary {
                        var instance = returnData!()
                        if let object = instance as? UtineraryModelData {
                            if returnParameters != nil {
                                object.returnParams = returnParameters
                            }
                            object.parse(jsonDictionary)
                            
                            successCompletionHandler(result: object)
                        }
                    }else{
                        //error
                        if let error = parseError {
                            
                            failedCompletionHandler(result : nil)
                        }
                    }
                }else{
                    //error
                    if let error = parseError {
                        
                        failedCompletionHandler(result : nil)
                    }
                }
            })
        })
        myTask.resume()
    }
    deinit{
        println("\(self) deinit")
        println("\(self.mySession) deinit")
        
        self.mySession.finishTasksAndInvalidate()
        
    }
    
    
    // MARK:
    // MARK: Create Service
    // MARK:
    class func send(httpMethod : String="POST")(returnParameters : NSDictionary?,urlRequest : NSMutableURLRequest!,returnData : NSObject.Type?,successCompletionHandler : successCompletionBlock , failedCompletionHandler : failedCompletionBlock){
        let myService : HTTPRequest  =  HTTPRequest()
        urlRequest.HTTPMethod = httpMethod
        
        myService.send(urlRequest: urlRequest, successCompletionHandler: successCompletionHandler, failedCompletionHandler: failedCompletionHandler, returnData: returnData, returnParameters: returnParameters)
    }
    
    
    static var Post = HTTPRequest.send()
    static var Get = HTTPRequest.send(httpMethod: "GET")
    
    // MARK:
    // MARK: Create Request
    // MARK:
    class func configRequest(#url : NSURL!, httpHeaders : NSDictionary? , jsonDictionary : AnyObject? , postBody : NSDictionary?)->NSMutableURLRequest{
        var urlRequest = NSMutableURLRequest(URL: url!)
        
        urlRequest.timeoutInterval = timeOutInterval
        urlRequest.allowsCellularAccess = allowCellularAccess
        
       
        
        if let myHeaders = httpHeaders {
            for (key , value) in httpHeaders! {
                println("\(key) \(value)")
                urlRequest.setValue(value as? String, forHTTPHeaderField: (key as? String)!)
            }
        }
        
        if let myPostBody = postBody {
            var postString : String?
            for (key , value) in myPostBody {
                println("\(key) \(value)")
                let result : String = "\(key)=\(value)"
                if postString == nil {
                    postString = result
                }else{
                    postString =  postString! + "&" + result
                }
                
            }
            if postString != nil{
                urlRequest.HTTPBody = postString?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
                
                
            }
        }
        
        
        if let myJson: AnyObject = jsonDictionary {
            
            urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
            urlRequest.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
            urlRequest.setValue("gzip", forHTTPHeaderField:"Content-Encoding")
            urlRequest.setValue("gzip", forHTTPHeaderField:"Accept-Encoding")
            
            var myJsonError : NSError?
            
            let myJSONData : NSData? = NSJSONSerialization.dataWithJSONObject(myJson, options: NSJSONWritingOptions.PrettyPrinted, error: &myJsonError)
            urlRequest.HTTPBody = myJSONData
            

        }
        
        return urlRequest
    }
    
}