//
//  CLDGenericNetworkRequest.swift
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

internal class CLDGenericNetworkRequest: NSObject, CLDNetworkRequest {
    
    internal let request: Request
    
    
    // MARK: - Init
    
    internal init(request: Request) {
        self.request = request
    }

    
    //MARK: - State
    
    /**
    Resume the current request.
    */
    func resume() {
        request.resume()
    }
    
    /**
     Suspend the current request.
     */
    func suspend() {
        request.suspend()
    }
    
    /**
     Cancel the current request.
     */
    func cancel() {
        request.cancel()
    }
    
    //MARK: - Handlers
    
    func response(completionHandler: ((response: AnyObject?, error: NSError?) -> ())?) -> CLDNetworkRequest {
        request.responseJSON { [weak self] response in
            if let value = response.result.value {
                if let error = value["error"] as? [String : AnyObject] {
                    let code = self?.request.response?.statusCode ?? CLDError.CloudinaryErrorCode.GeneralErrorCode.rawValue
                    let err = CLDError.error(code: code, userInfo: error)
                    completionHandler?(response: nil, error: err)
                }
                else {
                    completionHandler?(response: value, error: nil)
                }
            }
            else if let err = response.result.error {
                let error = err as NSError
                completionHandler?(response: nil, error: error)
            }
            else {
                completionHandler?(response: nil, error: CLDError.generalError())
            }
            
        }
        
        return self
    }
    
}
