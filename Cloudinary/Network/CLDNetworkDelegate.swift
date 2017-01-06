//
//  CLDNetworkDelegate.swift
//
//  Copyright (c) 2016 Cloudinary (http://cloudinary.com)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation
import Alamofire


internal class CLDNetworkDelegate: NSObject, CLDNetworkAdapter {
    
    private struct SessionProperties {
        static let identifier: String = NSBundle.mainBundle().bundleIdentifier ?? "" + ".cloudinarySDKbackgroundSession"
    }
    
    private let manager: Alamofire.Manager
    
    private let downloadQueue: NSOperationQueue = NSOperationQueue()
    
    internal static let sharedNetworkDelegate = CLDNetworkDelegate()
    
    // MARK: - Init
    
    init(configuration: NSURLSessionConfiguration? = nil) {
        if let configuration = configuration {
            manager = Manager(configuration: configuration)
        } else {
            let configuration: NSURLSessionConfiguration = {
                let configuration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(SessionProperties.identifier)
                configuration.HTTPAdditionalHeaders = Manager.defaultHTTPHeaders
                return configuration
            }()
            manager = Manager(configuration: configuration)
        }
        manager.startRequestsImmediately = false
    }
    
    // MARK: Features
    
    internal func cloudinaryRequest(url: String, headers: [String : String], parameters: [String : AnyObject]) -> CLDNetworkRequest {
        let req: Request = manager.request(.POST, url, parameters: parameters, headers: headers)
        req.resume()
        return CLDGenericNetworkRequest(request: req)
    }
    
    internal func uploadToCloudinary(url: String, headers: [String : String], parameters: [String : AnyObject], data: AnyObject) -> CLDNetworkDataRequest {
        
        let asyncUploadRequest = CLDAsyncNetworkUploadRequest()
        manager.upload(.POST, url, headers: headers, multipartFormData: { (multipartFormData) in
            
            if let data = data as? NSData {
                multipartFormData.appendBodyPart(data: data, name: "file", fileName: "file", mimeType: "application/octet-stream")
            } else if let fileUrl = data as? NSURL {
                var absoluteString: String
                #if swift(>=2.3)
                    absoluteString = fileUrl.absoluteString!
                #else
                    absoluteString = fileUrl.absoluteString
                #endif
                if absoluteString.rangeOfString("^ftp:|^https?:|^s3:|^data:[^;]*;base64,([a-zA-Z0-9/+\n=]+)$", options: [NSStringCompareOptions.RegularExpressionSearch, NSStringCompareOptions.CaseInsensitiveSearch], range: nil, locale: nil) != nil {
                    if let urlAsData = absoluteString.dataUsingEncoding(NSUTF8StringEncoding) {
                        multipartFormData.appendBodyPart(data: urlAsData, name: "file")
                    }
                } else {
                    multipartFormData.appendBodyPart(fileURL: fileUrl, name: "file", fileName: fileUrl.lastPathComponent!, mimeType: "application/octet-stream")
                }
            }
            
            for key in parameters.keys {
                if let value = parameters[key] where value is [String] {
                    if let valueArr = value as? [String] {
                        for paramValue in valueArr {
                            if let valueData = paramValue.dataUsingEncoding(NSUTF8StringEncoding) {
                                multipartFormData.appendBodyPart(data: valueData, name: key + "[]")
                            }
                        }
                    }
                } else if let value = parameters[key] as? String {
                    if value.isEmpty {
                        continue
                    }
                    
                    if let valueData = value.dataUsingEncoding(NSUTF8StringEncoding) {
                        multipartFormData.appendBodyPart(data: valueData, name: key)
                    }
                } else if let value = parameters[key] as? Bool {
                    if let valueData = String(NSNumber(bool: value)).dataUsingEncoding(NSUTF8StringEncoding) {
                        multipartFormData.appendBodyPart(data: valueData, name: key)
                    }
                }
            }
            
        }) { (encodingResult) in
            switch encodingResult {
            case .Success(let upload, _, _):
                upload.resume()
                let uploadRequest = CLDNetworkDataRequestImpl(request: upload)
                asyncUploadRequest.networkDataRequest = uploadRequest
            case .Failure(let encodingError):
                asyncUploadRequest.networkDataRequest = CLDRequestError(error: encodingError as NSError)
            }
        }
        
        return asyncUploadRequest
    }
    
    
    internal func downloadFromCloudinary(url: String) -> CLDFetchImageRequest {
        let req: Request = manager.request(.GET, url)
        downloadQueue.addOperationWithBlock { () -> () in
            req.resume()
        }
        return CLDNetworkDownloadRequest(request: req)
        
        
    }
    
    // MARK: - Setters
    
    internal func setBackgroundCompletionHandler(newValue: (() -> ())?) {
        manager.backgroundCompletionHandler = newValue
    }
    
    internal func setMaxConcurrentDownloads(maxConcurrentDownloads: Int) {
        downloadQueue.maxConcurrentOperationCount = maxConcurrentDownloads
    }
    
    // MARK: - Getters
    
    internal func getBackgroundCompletionHandler() -> (() -> ())? {
        return manager.backgroundCompletionHandler
    }    
}
