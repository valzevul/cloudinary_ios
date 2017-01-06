//
//  CLDNetworkDownloadRequest.swift
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

internal class CLDNetworkDownloadRequest: CLDNetworkDataRequestImpl, CLDFetchImageRequest {

    
    //MARK: - Handlers
    
    func responseImage(completionHandler: ((responseImage: UIImage?, error: NSError?) -> ())?) -> CLDFetchImageRequest {
        
        return responseData { (responseData, error) -> () in
            if let data = responseData {
                if let image = data.cldToUIImageThreadSafe() {
                    completionHandler?(responseImage: image, error: nil)
                }
                else {
                    let error = CLDError.error(code: .FailedCreatingImageFromData, message: "Failed creating an image from the received data.")
                    completionHandler?(responseImage: nil, error: error)
                }
            }
            else if let err = error {
                completionHandler?(responseImage: nil, error: err)
            }
            else {
                completionHandler?(responseImage: nil, error: CLDError.generalError())
            }
        }
    }
    
    func fetchProgress(block: ((bytes: Int64, totalBytes: Int64, totalBytesExpected: Int64) -> ())?) -> CLDFetchImageRequest {
        super.progress(block)
        return self
    }
    
    // MARK: - Private
    
    internal func responseData(completionHandler: ((responseData: NSData?, error: NSError?) -> ())?) -> CLDFetchImageRequest {
        request.responseData { response in
            if let imageData = response.result.value {
                completionHandler?(responseData: imageData, error: nil)
            }
            else if let err = response.result.error {
                let error = err as NSError
                completionHandler?(responseData: nil, error: error)
            }
            else {
                completionHandler?(responseData: nil, error: CLDError.generalError())
            }
        }
        return self
    }
}
