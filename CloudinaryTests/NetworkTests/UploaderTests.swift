//
//  UploaderTests.swift
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

import XCTest
import Cloudinary

class UploaderTests: NetworkBaseTest {
    
    // MARK: - Tests
    
    func testUploadImageData() {
        
        XCTAssertNotNil(cloudinary!.config.apiSecret, "Must set api secret for this test")
        
        let expectation = expectationWithDescription("Upload should succeed")
        let data = TestResourceType.defaultResource.data
        
        var result: CLDUploadResult?
        var error: NSError?
        
        let params = CLDUploadRequestParams()
        params.setColors(true)
        cloudinary!.createUploader().signedUpload(data: data, params: params).response({ (resultRes, errorRes) in
            result = resultRes
            error = errorRes
            
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(timeout, handler: nil)
        
        XCTAssertNotNil(result, "result should not be nil")
        XCTAssertNil(error, "error should be nil")
    }
    
    func testUploadImageFile() {
        
        XCTAssertNotNil(cloudinary!.config.apiSecret, "Must set api secret for this test")
        
        let expectation = expectationWithDescription("Upload should succeed")
        let url = TestResourceType.defaultResource.url
        
        var result: CLDUploadResult?
        var error: NSError?
        
        let params = CLDUploadRequestParams()
        params.setColors(true)
        cloudinary!.createUploader().signedUpload(url: url, params: params).response({ (resultRes, errorRes) in
            result = resultRes
            error = errorRes
            
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(timeout, handler: nil)
        
        XCTAssertNotNil(result, "result should not be nil")
        XCTAssertNil(error, "error should be nil")
    }
    
    func testUploadVideoData() {
        
        XCTAssertNotNil(cloudinary!.config.apiSecret, "Must set api secret for this test")
        
        let expectation = expectationWithDescription("Upload should succeed")
        let data = TestResourceType.dog.data
        
        var result: CLDUploadResult?
        var error: NSError?
        
        let params = CLDUploadRequestParams().setColors(true)
        params.setResourceType(.Video)
        cloudinary!.createUploader().signedUpload(data: data, params: params).response({ (resultRes, errorRes) in
            result = resultRes
            error = errorRes
            
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(60.0, handler: nil)
        
        XCTAssertNotNil(result, "result should not be nil")
        XCTAssertNil(error, "error should be nil")
    }
    
    func testUploadVideoFile() {
        
        XCTAssertNotNil(cloudinary!.config.apiSecret, "Must set api secret for this test")
        
        let expectation = expectationWithDescription("Upload should succeed")
        let url = TestResourceType.dog.url
        
        var result: CLDUploadResult?
        var error: NSError?
        
        let params = CLDUploadRequestParams().setColors(true)
        params.setResourceType(.Video)
        cloudinary!.createUploader().signedUpload(url: url, params: params).response({ (resultRes, errorRes) in
            result = resultRes
            error = errorRes
            
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(60.0, handler: nil)
        
        XCTAssertNotNil(result, "result should not be nil")
        XCTAssertNil(error, "error should be nil")
    }
    
    
    func testUnsignedUploadImageFile() {
        
        let prefix = cloudinary!.config.apiSecret != nil ? "\(cloudinary!.config.apiKey!):\(cloudinary!.config.apiSecret!)" : cloudinary!.config.apiKey!
        let uploadPresetUrl = "https://\(prefix)@api.cloudinary.com/v1_1/\(cloudinary!.config.cloudName!)/upload_presets"
        let presetName = "ios_unsigned_upload"
        let dict = NSProcessInfo.processInfo().environment
        guard let configUrl = dict["CLOUDINARY_URL_NO_SECRET"]
            else {
                XCTFail("you must set an environment variables for CLOUDINARY_URL_NO_SECRET with no secret to test unsigned upload.")
                return
        }
        let config = CLDConfiguration(cloudinaryUrl: configUrl)!
        cloudinary = CLDCloudinary(configuration: config, sessionConfiguration: NSURLSessionConfiguration.defaultSessionConfiguration())
        
        XCTAssertNil(cloudinary!.config.apiSecret, "api secret should not be set to test unsigned upload")
        
        createUploadPresetIfNeeded(uploadPresetUrl, presetName: presetName)
        
        let expectation = expectationWithDescription("Upload should succeed")
        let url = TestResourceType.defaultResource.url
        
        var result: CLDUploadResult?
        var error: NSError?
        
        cloudinary!.createUploader().upload(url: url, uploadPreset: presetName, params: CLDUploadRequestParams()).response({ (resultRes, errorRes) in
            result = resultRes
            error = errorRes
            
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(timeout, handler: nil)
        
        XCTAssertNotNil(result, "result should not be nil")
        XCTAssertNil(error, "error should be nil")

        if let
            pubId = result?.publicId,
            version = result?.version,
            sig = result?.signature
        {
            let toSign = ["public_id" : pubId, "version" : version]
            
            let config = CLDConfiguration.initWithEnvParams()
            cloudinary = CLDCloudinary(configuration: config!, sessionConfiguration: NSURLSessionConfiguration.defaultSessionConfiguration())
            
            let expectedSignature = cloudinarySignParamsUsingSecret(toSign, cloudinaryApiSecret: (cloudinary!.config.apiSecret)!)
            XCTAssertEqual(sig, expectedSignature)
        }
        else {
            XCTFail("Need to receive public_id, version and signature in the response")
        }
    }
    
    
    func testUploadRemoteUrl() {
        
        XCTAssertNotNil(cloudinary!.config.apiSecret, "Must set api secret for this test")
        
        let expectation = expectationWithDescription("Upload should succeed")
        
        var result: CLDUploadResult?
        var error: NSError?
        
        let params = CLDUploadRequestParams()
        cloudinary!.createUploader().signedUpload(url: NSURL(string: "http://cloudinary.com/images/old_logo.png")!, params: params).response({ (resultRes, errorRes) in
            result = resultRes
            error = errorRes
            
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(timeout, handler: nil)
        
        XCTAssertNotNil(result, "result should not be nil")
        XCTAssertNil(error, "error should be nil")
        
    }
    
    
    func testUseFilename() {
        
        XCTAssertNotNil(cloudinary!.config.apiSecret, "Must set api secret for this test")
        
        let expectation = expectationWithDescription("Upload should succeed")
        let url = TestResourceType.defaultResource.url
        var result: CLDUploadResult?
        var error: NSError?
        
        let params = CLDUploadRequestParams()
        params.setUseFilename(true)
        cloudinary!.createUploader().signedUpload(url: url, params: params).response({ (resultRes, errorRes) in
            result = resultRes
            error = errorRes
            
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(timeout, handler: nil)
        
        XCTAssertNotNil(result, "result should not be nil")
        XCTAssertNil(error, "error should be nil")
        
        var matches = 0
        if let publicId = result?.publicId {
            let regex = try! NSRegularExpression(pattern: "\(TestResourceType.defaultResource.fileName)_[a-z0-9]{6}", options: NSRegularExpressionOptions(rawValue: 0))
            matches = regex.numberOfMatchesInString(publicId, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, publicId.characters.count))
        }
        
        XCTAssertEqual(1, matches)
    }
    
    func testUniqueFilename() {
        
        XCTAssertNotNil(cloudinary!.config.apiSecret, "Must set api secret for this test")
        
        let expectation = expectationWithDescription("Upload should succeed")
        let url = TestResourceType.defaultResource.url
        var result: CLDUploadResult?
        var error: NSError?
        
        let params = CLDUploadRequestParams()
        params.setUseFilename(true).setUniqueFilename(false)
        cloudinary!.createUploader().signedUpload(url: url, params: params).response({ (resultRes, errorRes) in
            result = resultRes
            error = errorRes
            
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(timeout, handler: nil)
        
        XCTAssertNotNil(result, "result should not be nil")
        XCTAssertNil(error, "error should be nil")
        
        XCTAssertEqual(result?.publicId ?? "", TestResourceType.defaultResource.fileName)
    }
    
    func testEager() {
        
        XCTAssertNotNil(cloudinary!.config.apiSecret, "Must set api secret for this test")
        
        let expectation = expectationWithDescription("Upload should succeed")
        let url = TestResourceType.defaultResource.url
        var result: CLDUploadResult?
        var error: NSError?
        
        let params = CLDUploadRequestParams()
        let trans = CLDTransformation().setCrop(.Crop).setWidth(2.0)
        params.setEager([trans])
        cloudinary!.createUploader().signedUpload(url: url, params: params).response({ (resultRes, errorRes) in
            result = resultRes
            error = errorRes
            
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(timeout, handler: nil)
        
        XCTAssertNotNil(result, "result should not be nil")
        XCTAssertNil(error, "error should be nil")
        
        XCTAssertNotNil(result?.resultJson["eager"])
    }
    
    func testHeaders() {
        
        XCTAssertNotNil(cloudinary!.config.apiSecret, "Must set api secret for this test")
        
        let expectation = expectationWithDescription("Upload should succeed")
        let url = TestResourceType.defaultResource.url
        var result: CLDUploadResult?
        var error: NSError?
        
        let params = CLDUploadRequestParams()
        params.setHeaders(["Link" : "1"])
        params.setContext(["caption" : "My Logo"])
        cloudinary!.createUploader().signedUpload(url: url, params: params).response({ (resultRes, errorRes) in
            result = resultRes
            error = errorRes
            
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(timeout, handler: nil)
                
        XCTAssertNotNil(result, "result should not be nil")
        XCTAssertNil(error, "error should be nil")
    }
    
    func testFaceCoordinates() {
        
        XCTAssertNotNil(cloudinary!.config.apiSecret, "Must set api secret for this test")
        
        let expectation = expectationWithDescription("Upload should succeed")
        let url = TestResourceType.defaultResource.url
        var result: CLDUploadResult?
        var error: NSError?
        
        let params = CLDUploadRequestParams()
        let coordinate = CLDCoordinate(rect: CGRectMake(10, 10, 100, 100))
        params.setFaceCoordinates([coordinate])
        cloudinary!.createUploader().signedUpload(url: url, params: params).response({ (resultRes, errorRes) in
            result = resultRes
            error = errorRes
            
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(timeout, handler: nil)
        
        XCTAssertNotNil(result, "result should not be nil")
        XCTAssertNil(error, "error should be nil")
    }
    
    func testCustomCoordinates() {
        
        XCTAssertNotNil(cloudinary!.config.apiSecret, "Must set api secret for this test")
        
        let expectation = expectationWithDescription("Upload should succeed")
        let url = TestResourceType.defaultResource.url
        var result: CLDUploadResult?
        var error: NSError?
        
        let params = CLDUploadRequestParams()
        let coordinate = CLDCoordinate(rect: CGRectMake(10, 10, 100, 100))
        params.setCustomCoordinates([coordinate])
        cloudinary!.createUploader().signedUpload(url: url, params: params).response({ (resultRes, errorRes) in
            result = resultRes
            error = errorRes
            
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(timeout, handler: nil)
        
        XCTAssertNotNil(result, "result should not be nil")
        XCTAssertNil(error, "error should be nil")
    }
    
    func testManualModeration() {
        
        XCTAssertNotNil(cloudinary!.config.apiSecret, "Must set api secret for this test")
        
        let expectation = expectationWithDescription("Upload should succeed")
        let url = TestResourceType.defaultResource.url
        var result: CLDUploadResult?
        var error: NSError?
        
        let params = CLDUploadRequestParams()
        params.setModeration(.Manual)
        cloudinary!.createUploader().signedUpload(url: url, params: params).response({ (resultRes, errorRes) in
            result = resultRes
            error = errorRes
            
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(timeout, handler: nil)
        
        XCTAssertNotNil(result, "result should not be nil")
        XCTAssertNil(error, "error should be nil")
        
        if let moderationArr = result?.moderation as? NSArray {
            if let mod = moderationArr.firstObject as? NSDictionary,
                let status = mod["status"] as? String,
                let kind = mod["kind"] as? String {
                XCTAssertEqual(status, "pending")
                XCTAssertEqual(kind, "manual")
            }
            else {
                XCTFail("Moderation dictionary should hold its status and kind.")
            }
        }
        else {
            XCTFail("Manual moderation response should be a dictionary holding a moderation dictionary.")
        }
        
    }
    
    func testRawConversion() {
        
        XCTAssertNotNil(cloudinary!.config.apiSecret, "Must set api secret for this test")
        
        let expectation = expectationWithDescription("Upload should succeed")
        let url = TestResourceType.docx.url
        var result: CLDUploadResult?
        var error: NSError?
        
        let params = CLDUploadRequestParams()
        params.setRawConvert("illegal")
        params.setResourceType(.Raw)
        cloudinary!.createUploader().signedUpload(url: url, params: params).response({ (resultRes, errorRes) in
            result = resultRes
            error = errorRes
            
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(timeout, handler: nil)
        
        XCTAssertNil(result, "result should be nil")
        XCTAssertNotNil(error, "error should not be nil")
        
        if let errMessage = error?.userInfo["message"] as? String {
            XCTAssertNotNil(errMessage.rangeOfString("illegal is not a valid"))
        }
        else {
            XCTFail("Error should hold a message in its user info.")
        }
    }
    
    func testCategorization() {
        
        XCTAssertNotNil(cloudinary!.config.apiSecret, "Must set api secret for this test")
        
        let expectation = expectationWithDescription("Upload should succeed")
        let url = TestResourceType.defaultResource.url
        var result: CLDUploadResult?
        var error: NSError?
        
        let params = CLDUploadRequestParams()
        params.setCategorization("illegal")
        cloudinary!.createUploader().signedUpload(url: url, params: params).response({ (resultRes, errorRes) in
            result = resultRes
            error = errorRes
            
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(timeout, handler: nil)
        
        XCTAssertNil(result, "result should be nil")
        XCTAssertNotNil(error, "error should not be nil")
        
        if let errMessage = error?.userInfo["message"] as? String {
            XCTAssertNotNil(errMessage.rangeOfString("Categorization is invalid"))
        }
        else {
            XCTFail("Error should hold a message in its user info.")
        }
    }
    
    func testDetection() {
        
        XCTAssertNotNil(cloudinary!.config.apiSecret, "Must set api secret for this test")
        
        let expectation = expectationWithDescription("Upload should succeed")
        let url = TestResourceType.defaultResource.url
        var result: CLDUploadResult?
        var error: NSError?
        
        let params = CLDUploadRequestParams()
        params.setDetection("illegal")
        cloudinary!.createUploader().signedUpload(url: url, params: params).response({ (resultRes, errorRes) in
            result = resultRes
            error = errorRes
            
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(timeout, handler: nil)
        
        XCTAssertNil(result, "result should be nil")
        XCTAssertNotNil(error, "error should not be nil")
        
        if let errMessage = error?.userInfo["message"] as? String {
            XCTAssertNotNil(errMessage.rangeOfString("illegal is not a valid"))
        }
        else {
            XCTFail("Error should hold a message in its user info.")
        }
    }
    
    func testAutoTagging() {
        
        XCTAssertNotNil(cloudinary!.config.apiSecret, "Must set api secret for this test")
        
        let expectation = expectationWithDescription("Upload should succeed")
        let url = TestResourceType.defaultResource.url
        var result: CLDUploadResult?
        var error: NSError?
        
        let params = CLDUploadRequestParams()
        params.setAutoTagging(0.5)
        cloudinary!.createUploader().signedUpload(url: url, params: params).response({ (resultRes, errorRes) in
            result = resultRes
            error = errorRes
            
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(timeout, handler: nil)
        
        XCTAssertNil(result, "result should be nil")
        XCTAssertNotNil(error, "error should not be nil")
        
        if let errMessage = error?.userInfo["message"] as? String {
            XCTAssertNotNil(errMessage.rangeOfString("Must use "))
        }
        else {
            XCTFail("Error should hold a message in its user info.")
        }
    }
    
    
    //MARK: - Helpers
    
    func createUploadPresetIfNeeded(uploadPresetUrl: String, presetName: String) {
        let semaphore = dispatch_semaphore_create(0)
        if let url = NSURL(string: "\(uploadPresetUrl)/\(presetName)") {
            let request = NSMutableURLRequest(URL: url)
            let session = NSURLSession.sharedSession()            
            session.dataTaskWithRequest(request, completionHandler: { (returnData, response, error) -> () in
                if let returnData = returnData {
                    if let strData = String(data: returnData, encoding: NSUTF8StringEncoding) {
                        if strData.rangeOfString("Can't find upload preset named") != nil {
                            if let url = NSURL(string: uploadPresetUrl) {
                                let request = NSMutableURLRequest(URL: url)
                                request.HTTPMethod = "POST"
                                request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                                let params = "name=\(presetName)&unsigned=true&tags=ios_sdk_test"
                                let httpData = params.dataUsingEncoding(NSUTF8StringEncoding)
                                request.HTTPBody = httpData
                                session.dataTaskWithRequest(request, completionHandler: { (returnData, response, error) -> () in
                                    if let returnData = returnData {
                                        let strData = String(data: returnData, encoding: NSUTF8StringEncoding)
                                        print(strData)
                                    }
                                    dispatch_semaphore_signal(semaphore)
                                }).resume()
                            }
                            else {
                                XCTFail("preset request failed")
                                dispatch_semaphore_signal(semaphore)
                            }
                        }
                        else {
                            dispatch_semaphore_signal(semaphore)
                        }
                    }
                    else {
                        XCTFail("preset request failed")
                        dispatch_semaphore_signal(semaphore)
                    }
                }
                else {
                    XCTFail("preset request failed")
                    dispatch_semaphore_signal(semaphore)
                }
            }).resume()
        }
        else {
            XCTFail("preset request failed")
            dispatch_semaphore_signal(semaphore)
        }
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    }
}


