//
//  CLDCloudinary.swift
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

@objc public class CLDCloudinary: NSObject {
    
    /**
     Holds the configuration parameters to be used by the `CLDCloudinary` instance.
     */
    public private(set) var config: CLDConfiguration
    
    /**
     The network coordinator coordinates between the SDK's API level classes to its network adapter layer.
     */
    private var networkCoordinator: CLDNetworkCoordinator
    
    
    // MARK: - SDK Configurations
    
    // MARK: Log Level
    
    /**
     Sets Cludinary SDK's log level, default level is set to **None**.
     */
    public static var logLevel: CLDLogLevel {
        get {
            return CLDLogManager.minimumLogLevel
        }
        set {
            CLDLogManager.minimumLogLevel = newValue
        }
    }
    
    // MARK: Image Cache
    
    /**
     Sets Cloudinary SDK's caching policy for images that are dowloaded via the SDK's CLDDownloader.
     The options are: **None**, **Memory** and **Disk**. default is Disk
     */
    public var cachePolicy: CLDImageCachePolicy {
        get {
            return CLDImageCache.defaultImageCache.cachePolicy
        }
        set {
            CLDImageCache.defaultImageCache.cachePolicy = newValue
        }
    }
    
    /**
     Sets Cloudinary SDK's image cache maximum disk capacity.
     default is 150 MB.     
     */
    public var cacheMaxDiskCapacity: UInt64 {
        get {
            return CLDImageCache.defaultImageCache.maxDiskCapacity
        }
        set {
            CLDImageCache.defaultImageCache.maxDiskCapacity = newValue
        }
    }
    
    // MARK: - Init
    
    /**
    Initializes the `CLDCloudinary` instance with the specified configuration and network adapter.
     
    - parameter configuration:          The configuration used by this CLDCloudinary instance.
    - parameter networkAdapter:         A network adapter that implements `CLDNetworkAdapter`. CLDNetworkDelegate() by default.
    - parameter configuration:          The configuration used to construct the NSURLSession.
    
     - returns: The new `CLDCloudinary` instance.
     */
    public init(configuration: CLDConfiguration, networkAdapter: CLDNetworkAdapter? = nil, sessionConfiguration: NSURLSessionConfiguration? = nil) {
        config = configuration
        if let customNetworkAdapter = networkAdapter {
            networkCoordinator = CLDNetworkCoordinator(configuration: config, networkAdapter: customNetworkAdapter)
        }
        else {            
            if let sessionConfiguration = sessionConfiguration {
                networkCoordinator = CLDNetworkCoordinator(configuration: config, sessionConfiguration: sessionConfiguration)
            } else {
                networkCoordinator = CLDNetworkCoordinator(configuration: config)
            }

        }
        super.init()
    }
    
    // MARK: Factory Methods
    
    /**
    A factory method to create a new `CLDUrl` instance
    
    - returns: A new `CLDUrl` instance.
    */
    public func createUrl() -> CLDUrl {
        return CLDUrl(configuration: config)
    }
    
    /**
     A factory method to create a new `CLDUploader` instance
     
     - returns: A new `CLDUploader` instance.
     */
    public func createUploader() -> CLDUploader {
        return CLDUploader(networkCoordinator: networkCoordinator)
    }
    
    /**
     A factory method to create a new `CLDDownloader` instance
     
     - returns: A new `CLDDownloader` instance.
     */
    public func createDownloader() -> CLDDownloader {
        return CLDDownloader(networkCoordinator: networkCoordinator)
    }
    
    /**
     A factory method to create a new `CLDAdminApi` instance
     
     - returns: A new `CLDAdminApi` instance.
     */
    public func createManagementApi() -> CLDManagementApi {
        return CLDManagementApi(networkCoordinator: networkCoordinator)
    }

    // MARK: - Network Adapter
    
    /**
    The maximum number of queued downloads that can execute at the same time.
    
    default is NSOperationQueueDefaultMaxConcurrentOperationCount.
    
    - parameter maxConcurrentDownloads:     The maximum concurrent downloads to allow.
    */
    @available(iOS 8.0, *)
    public func setMaxConcurrentDownloads(maxConcurrentDownloads: Int) {
        networkCoordinator.setMaxConcurrentDownloads(maxConcurrentDownloads)
    }
    
    // MARK: Background Session
    
    /**
        Set a completion handler provided by the UIApplicationDelegate `application:handleEventsForBackgroundURLSession:completionHandler:` method.
        The handler will be called automatically once the session finishes its events for background URL session.
    
        default is `nil`.
    */
    @available(iOS 8.0, *)
    public func setBackgroundCompletionHandler(newValue: (() -> ())?) {
        networkCoordinator.setBackgroundCompletionHandler(newValue)
    }
    
    // MARK: - Advanced
    /**
    Sets the "USER-AGENT" HTTP header on all network requests to be **"PlatformName/ver CloudinaryiOS/ver"**
    By default the header is set to **"CloudinaryiOS/ver"**
    */
    public func setUserPlatform(platformName: String, version: String) {
        config.setUserPlatform(platformName, version: version)
    }
    
}
