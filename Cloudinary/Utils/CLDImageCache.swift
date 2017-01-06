//
//  CLDImageCache.swift
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


@objc public enum CLDImageCachePolicy: Int {
    case None, Memory, Disk
}

private struct Defines {
    static let cacheDefaultName = "defaultImageCache"
    static let cacheBaseName = "com.cloudinary.sdk.imageCache"
    static let readWriteQueueName = "com.cloudinary.sdk.imageCache.readWriteQueue"
    static let defaultMemoryTotalCostLimit = 30 * 1024 * 1024  // 30 MB
    static let defaultMaxDiskCapacity = 150 * 1024 * 1024  // 150 MB
    static let thresholdPercentSize = UInt64(0.8)
}


internal class CLDImageCache {
    
    internal var cachePolicy = CLDImageCachePolicy.Disk
    
    private let memoryCache = NSCache()
    internal var maxMemoryTotalCost: Int = Defines.defaultMemoryTotalCostLimit {
        didSet{
            memoryCache.totalCostLimit = maxMemoryTotalCost
        }
    }
    
    private let diskCacheDir: String
    
    
    // Disk Size Control
    internal var maxDiskCapacity: UInt64 = UInt64(Defines.defaultMaxDiskCapacity) {
        didSet {
            clearDiskToMatchCapacityIfNeeded()
        }
    }
    private var usedCacheSize: UInt64 = 0
    
    private let readWriteQueue: dispatch_queue_t
    
    internal static let defaultImageCache: CLDImageCache = CLDImageCache(name: Defines.cacheDefaultName)
    
    //MARK: - Lifecycle
    
    init(name: String, diskCachePath: String? = nil) {
        
        let cacheName = "\(Defines.cacheBaseName).\(name)"
        memoryCache.name = cacheName
        
        let diskPath = diskCachePath ?? NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first!
        diskCacheDir = diskPath.cldStringByAppendingPathComponent(cacheName)
        
        readWriteQueue = dispatch_queue_create(Defines.readWriteQueueName + name, DISPATCH_QUEUE_SERIAL)
        
        calculateCurrentDiskCacheSize()
        clearDiskToMatchCapacityIfNeeded()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CLDImageCache.clearMemoryCache), name: UIApplicationDidReceiveMemoryWarningNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Get Object
    
    internal func getImageForKey(key: String, completion: (image: UIImage?) -> ()) {
        
        let callCompletionClosureOnMain = { (image: UIImage?) in
            dispatch_async(dispatch_get_main_queue()) {
                completion(image: image)
            }
        }
        
        if let memoryImage = memoryCache.objectForKey(key) as? UIImage {
            let path = getFilePathFromKey(key)
            dispatch_async(readWriteQueue) {
                self.updateDiskImageModifiedDate(path)
            }
            callCompletionClosureOnMain(memoryImage)
        }
        else {
            dispatch_async(readWriteQueue) {
                if let diskImage = self.getImageFromDiskForKey(key) {
                    callCompletionClosureOnMain(diskImage)
                    self.cacheImage(diskImage, data: nil, key: key, includingDisk: false, completion: nil)
                }
                else {
                    callCompletionClosureOnMain(nil)
                }
            }
        }
    }
    
    // MARK: - Set Object
    
    internal func cacheImage(image: UIImage, data: NSData?, key: String, completion: (() -> ())?) {
        cacheImage(image, data: data, key: key, includingDisk: true, completion: completion)
    }
    
    private func cacheImage(image: UIImage, data: NSData?, key: String, includingDisk: Bool, completion: (() -> ())?) {
        
        if cachePolicy == .Memory || cachePolicy == .Disk {
            let cost = Int(image.size.height * image.scale * image.size.width * image.scale)
            memoryCache.setObject(image, forKey: key, cost: cost)
        }
        
        if cachePolicy == .Disk && includingDisk {
            let path = getFilePathFromKey(key)
            dispatch_async(readWriteQueue) {
                // If the original data was passed, save the data to the disk, otherwise default to UIImagePNGRepresentation to create the data from the image
                if let data = data ?? UIImagePNGRepresentation(image) {
                    // create the cach directory if it doesn't exist
                    if !NSFileManager.defaultManager().fileExistsAtPath(self.diskCacheDir) {
                        do {
                            try NSFileManager.defaultManager().createDirectoryAtPath(self.diskCacheDir, withIntermediateDirectories: true, attributes: nil)
                        } catch {
                            printLog(.Warning, text: "Failed while attempting to create the image cache directory.")
                        }
                    }
                    
                    NSFileManager.defaultManager().createFileAtPath(path, contents: data, attributes: nil)
                    self.usedCacheSize += UInt64(data.length)
                    self.clearDiskToMatchCapacityIfNeeded()
                }
                else {
                    printLog(.Warning, text: "Couldn't convert image to data for key: \(key)")
                }
                completion?()
            }
        }
        else {
            completion?()
        }
    }
    
    // MARK: - Remove Object
    
    internal func removeCacheImageForKey(key: String) {
        memoryCache.removeObjectForKey(key)
        let path = getFilePathFromKey(key)
        removeFileAtPath(path)
    }
    
    private func removeFileAtPath(path: String) {
        dispatch_async(readWriteQueue) {
            if let fileAttr = self.getFileAttributes(path) {
                let fileSize = fileAttr.fileSize()
                do {
                    try NSFileManager.defaultManager().removeItemAtPath(path)
                    self.usedCacheSize = self.usedCacheSize > fileSize ? self.usedCacheSize - fileSize : 0
                } catch {
                    printLog(.Warning, text: "Failed while attempting to remove a cached file")
                }
            }
        }
    }
    
    // MARK: - Clear
    
    private func clearDiskToMatchCapacityIfNeeded() {
        if usedCacheSize < maxDiskCapacity {
            return
        }
        
        if let sortedUrls = sortedDiskImagesByModifiedDate() {
            for url in sortedUrls {
                if let path = url.path {
                    removeFileAtPath(path)
                    if usedCacheSize <= UInt64(maxDiskCapacity * Defines.thresholdPercentSize) {
                        break
                    }
                }
            }
        }
    }
    
    @objc private func clearMemoryCache() {
        memoryCache.removeAllObjects()
    }
    
    // MARK: - State
    
    internal func hasCachedImageForKey(key: String) -> Bool {
        var hasCachedImage = false
        if memoryCache.objectForKey(key) != nil {
            hasCachedImage = true
        }
        else {
            let imagePath = getFilePathFromKey(key)
            hasCachedImage = hasCachedDiskImageAtPath(imagePath)
        }
        
        return hasCachedImage
    }
    
    private func hasCachedDiskImageAtPath(path: String) -> Bool {
        var hasCachedImage = false
        dispatch_sync(readWriteQueue) {
            hasCachedImage = NSFileManager.defaultManager().fileExistsAtPath(path)
        }
        return hasCachedImage
    }

    // MARK: - Disk Image Helpers
    
    private func getImageFromDiskForKey(key: String) -> UIImage? {
        if let data = getDataFromDiskForKey(key) {
            return data.cldToUIImageThreadSafe()
        }
        return nil
    }
    
    private func getDataFromDiskForKey(key: String) -> NSData? {
        let imagePath = getFilePathFromKey(key)
        updateDiskImageModifiedDate(imagePath)
        return NSData(contentsOfFile: imagePath)
    }
    
    private func getFilePathFromKey(key: String) -> String {
        let fileName = getFileNameFromKey(key)
        return diskCacheDir.cldStringByAppendingPathComponent(fileName)
    }
    
    private func getFileNameFromKey(key: String) -> String {
        return key.md5()
    }
    
    private func updateDiskImageModifiedDate(path: String) {
        do {
            try NSFileManager.defaultManager().setAttributes([NSFileModificationDate : NSDate()], ofItemAtPath: path)
        } catch {
            printLog(.Warning, text: "Failed attempting to update cached file modified date.")
        }
    }
    
    // MARK: - Disk Capacity Helpers
    
    private func calculateCurrentDiskCacheSize() {
        let fileManager = NSFileManager.defaultManager()
        usedCacheSize = 0
        do {
            let contents = try fileManager.contentsOfDirectoryAtPath(diskCacheDir)
            for pathComponent in contents {
                let filePath = diskCacheDir.cldStringByAppendingPathComponent(pathComponent)
                if let fileAttr = getFileAttributes(filePath) {
                    usedCacheSize += fileAttr.fileSize()
                }
            }
            
        } catch {
            printLog(.Warning, text: "Failed listing cache directiry")
        }
    }
    
    private func sortedDiskImagesByModifiedDate() -> [NSURL]? {
        let dirUrl = NSURL(fileURLWithPath: diskCacheDir)
        do {
            let urlArray = try NSFileManager.defaultManager().contentsOfDirectoryAtURL(dirUrl, includingPropertiesForKeys: [NSURLContentModificationDateKey], options:.SkipsHiddenFiles)
            
            return urlArray.map { url -> (NSURL, NSTimeInterval) in
                var lastModified : AnyObject?
                _ = try? url.getResourceValue(&lastModified, forKey: NSURLContentModificationDateKey)
                return (url, lastModified?.timeIntervalSinceReferenceDate ?? 0)
                }
                .sort({ $0.1 > $1.1 }) // sort descending modification dates
                .map { $0.0 }
        } catch {
            printLog(.Warning, text: "Failed listing cache directiry")
            return nil
        }
    }
    
    private func getFileAttributes(path: String) -> NSDictionary? {
        var fileAttr: NSDictionary?
        do {
            fileAttr = try NSFileManager.defaultManager().attributesOfItemAtPath(path) as NSDictionary
        } catch {
            printLog(.Warning, text: "Failed while attempting to retrive a cached file attributes for filr at path: \(path)")
        }
        return fileAttr
    }    
    
}
