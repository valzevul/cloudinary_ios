//
//  CLDFetchImageRequestImpl.swift
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

internal class CLDFetchImageRequestImpl: CLDFetchImageRequest {
    
    private let url: String
    private let networkCoordinator: CLDNetworkCoordinator
    
    private let closureQueue: NSOperationQueue
    
    private var image: UIImage?
    private var error: NSError?
    
    
    // Requests
    private var imageDownloadRequest: CLDNetworkDownloadRequest?
    private var progress: ((bytes: Int64, totalBytes: Int64, totalBytesExpected: Int64) -> ())?
    
    init(url: String, networkCoordinator: CLDNetworkCoordinator) {
        self.url = url
        self.networkCoordinator = networkCoordinator
        closureQueue = {
            let operationQueue = NSOperationQueue()
            operationQueue.maxConcurrentOperationCount = 1
            operationQueue.suspended = true
            return operationQueue
            }()
    }
    
    // MARK: - Actions
    
    func fetchImage() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            if CLDImageCache.defaultImageCache.hasCachedImageForKey(self.url) {
                CLDImageCache.defaultImageCache.getImageForKey(self.url, completion: { [weak self] (image) -> () in
                    if let fetchedImage = image {
                        self?.image = fetchedImage
                        self?.closureQueue.suspended = false
                    }
                    else {
                        self?.downloadImageAndCacheIt()
                    }
                })
            }
            else {
                self.downloadImageAndCacheIt()
            }
        }
    }
    
    // MARK: Private
    
    private func downloadImageAndCacheIt() {
        imageDownloadRequest = networkCoordinator.download(url) as? CLDNetworkDownloadRequest
        if let progress = progress {
            imageDownloadRequest?.progress(progress)
        }
        
        imageDownloadRequest?.responseData { [weak self] (responseData, responseError) -> () in
            if let data = responseData {
                if let
                    image = data.cldToUIImageThreadSafe(),
                    url = self?.url {
                    self?.image = image
                    CLDImageCache.defaultImageCache.cacheImage(image, data: data, key: url, completion: nil)
                }
                else {
                    let error = CLDError.error(code: .FailedCreatingImageFromData, message: "Failed creating an image from the received data.")
                    self?.error = error
                }
            }
            else if let err = responseError {
                self?.error = err
            }
            else {
                let error = CLDError.error(code: .FailedDownloadingImage, message: "Failed attempting to download image.")
                self?.error = error
            }
            self?.closureQueue.suspended = false
        }
    }
    
    // MARK: - CLDFetchImageRequest
    
    @objc func responseImage(completionHandler: ((responseImage: UIImage?, error: NSError?) -> ())?) -> CLDFetchImageRequest {
        closureQueue.addOperationWithBlock {
            if let image = self.image {
                completionHandler?(responseImage: image, error: nil)
            }
            else if let error = self.error {
                completionHandler?(responseImage: nil, error: error)
            }
            else {                
                completionHandler?(responseImage: nil, error: CLDError.generalError())
            }
        }
        return self
    }
    
    @objc func progress(progress: ((bytes: Int64, totalBytes: Int64, totalBytesExpected: Int64) -> ())?) -> CLDNetworkDataRequest {
        if let downloadRequest = self.imageDownloadRequest {
            downloadRequest.progress(progress)
        }
        else {
            self.progress = progress
        }
        return self
    }
    
    @objc func resume() {
        imageDownloadRequest?.resume()
    }
    
    @objc func suspend() {
        imageDownloadRequest?.suspend()
    }
    
    
    @objc func cancel() {
        imageDownloadRequest?.cancel()
    }
    
    @objc func response(completionHandler: ((response: AnyObject?, error: NSError?) -> ())?) -> CLDNetworkRequest {
        responseImage(completionHandler)
        return self
    }
}
