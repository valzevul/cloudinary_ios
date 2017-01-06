//
//  CLDUploadRequest.swift
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

/**
 A `CLDUploadRequest` object is returned when creating a data transfer request to Cloudinary, e.g. uploading a file.
 It allows the options to add a progress closure that is called periodically during the transfer
 and a response closure to be called once the transfer has finished,
 as well as performing actions on the request, such as cancelling, suspending or resuming it.
 */
@objc public class CLDUploadRequest: NSObject {
    
    
    internal var networkRequest: CLDNetworkDataRequest
    
    internal init(networkDataRequest: CLDNetworkDataRequest) {
        networkRequest = networkDataRequest
    }
    
    
    // MARK: - Public
    
    /**
     Resume the request.
     */
    public func resume() {
        networkRequest.resume()
    }
    
    /**
     Suspend the request.
     */
    public func suspend() {
        networkRequest.suspend()
    }
    
    /**
     Cancel the request.
     */
    public func cancel() {
        networkRequest.cancel()
    }
    
    //MARK: Handlers
    
    /**
     Set a response closure to be called once the request has finished.
     
     - parameter completionHandler:      The closure to be called once the request has finished, holding either the response object or the error.
     
     - returns:                          The same instance of CLDUploadRequest.
     */
    public func responseRaw(completionHandler: (response: AnyObject?, error: NSError?) -> ()) -> CLDUploadRequest {
        networkRequest.response(completionHandler)
        return self
    }
    
    /**
     Set a response closure to be called once the request has finished.
     
     - parameter completionHandler:      The closure to be called once the request has finished, holding either the response object or the error.
     
     - returns:                          The same instance of CLDUploadRequest.
     */
    public func response(completionHandler: (result: CLDUploadResult?, error: NSError?) -> ()) -> CLDUploadRequest {
        responseRaw { (response, error) in
            if let res = response as? [String : AnyObject] {
                completionHandler(result: CLDUploadResult(json: res), error: nil)
            }
            else if let err = error {
                completionHandler(result: nil, error: err)
            }
            else {
                completionHandler(result: nil, error: CLDError.generalError())
            }
        }
        return self
    }
    
    /**
     Set a progress closure that is called periodically during the data transfer.
     
     - parameter progressBlock:          The closure that is called periodically during the data transfer.
     
     - returns:                          The same instance of CLDUploadRequest.
     */
    func progress(progress: (bytes: Int64, totalBytes: Int64, totalBytesExpected: Int64) -> ()) -> CLDUploadRequest {
        networkRequest.progress(progress)
        return self
    }
}
