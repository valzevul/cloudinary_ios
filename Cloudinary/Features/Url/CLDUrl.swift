//
//  CLDUrl.swift
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
 The CLDUrl class represents a URL to a remote asset either on your Cloudinary cloud, or from another remote source.
*/
@objc public class CLDUrl: NSObject {
    
    private struct CLDUrlConsts {
        static let CLD_OLD_AKAMAI_CHARED_CDN = "cloudinary-a.akamaihd.net"
        static let CLD_SHARED_CDN = "res\(CLD_COM)"
        static let CLD_COM = ".cloudinary.com"
    }
    
    /**
     The current Cloudinary session configuration.
    */
    private var config: CLDConfiguration!
    
    /**
     The media source of the URL. default is upload.
     */
    private var type: String = String(CLDType.Upload)
    
    /**
     The resource type of the remote asset that the URL points to. default is image.
     */
    private var resourceType: String = String(CLDUrlResourceType.Image)
    
    /**
     The format of the remote asset that the URL points to.
     */
    private var format: String?
    
    /**
     The version of the remote asset that the URL points to.
     */
    private var version: String?
    
    /**
     A suffix to the URL that points to the remote asset (private CDN only, image/upload and raw/upload only).
     */
    private var suffix: String?
    
    /**
     A boolean parameter indicating whether or not to use a root path instead of a full path (image/upload only).
     */
    private var useRootPath: Bool = false
    
    /**
     A boolean parameter indicating whether or not to use a shorten URL (image/upload only).
     */
    private var shortenUrl: Bool = false
    
    /**
     The transformation to be apllied on the remote asset.
     */
    private var transformation: CLDTransformation?
    
    // MARK: - Init
    
    private override init() {
        super.init()
    }
    
    internal init(configuration: CLDConfiguration) {
        config = configuration
        super.init()
    }

    // MARK: - Set Values
    
    /**
    Set the media source of the URL.
    
    - parameter type:       the media source to set.
    
    - returns:               the same instance of CLDUrl.
    */
    @objc(setTypeFromType:)
    public func setType(type: CLDType) -> CLDUrl {
        return setType(String(type))
    }
    
    /**
     Set the media source of the URL.
     
     - parameter type:       the media source to set.
     
     - returns:               the same instance of CLDUrl.
     */
    public func setType(type: String) -> CLDUrl {
        self.type = type
        return self
    }
    
    /**
     Set the resource type of the asset the URL points to.
     
     - parameter resourceType:      the resource type to set.
     
     - returns:                      the same instance of CLDUrl.
     */
    @objc(setResourceTypeFromUrlResourceType:)
    public func setResourceType(resourceType: CLDUrlResourceType) -> CLDUrl {
        return setResourceType(String(resourceType))
    }
    
    /**
     Set the resource type of the asset the URL points to.
     
     - parameter resourceType:      the resource type to set.
     
     - returns:                      the same instance of CLDUrl.
     */
    public func setResourceType(resourceType: String) -> CLDUrl {
        self.resourceType = resourceType
        return self
    }
    
    /**
     Set the format of the asset the URL points to.
     
     - parameter format:            the format to set.
     
     - returns:                      the same instance of CLDUrl.
     */
    public func setFormat(format: String) -> CLDUrl {
        self.format = format
        return self
    }
    
    
    /**
     Set the version of the asset the URL points to.
     
     - parameter format:            the format to set.
     
     - returns:                      the same instance of CLDUrl.
     */
    public func setVersion(version: String) -> CLDUrl {
        self.version = version
        return self
    }
    
    /**
     Set the suffix of the URL. (private CDN only, image/upload and raw/upload only).
     
     - parameter suffix:            the suffix to set.
     
     - returns:                      the same instance of CLDUrl.
     */
    public func setSuffix(suffix: String) -> CLDUrl {
        self.suffix = suffix
        return self
    }
    
    /**
     Set whether or not to use a root path instead of a full path. (image/upload only).
     
     - parameter useRootPath:       A boolean parameter indicating whether or not to use a root path instead of a full path.
     
     - returns:                      the same instance of CLDUrl.
     */
    public func setUseRootPath(useRootPath: Bool) -> CLDUrl {
        self.useRootPath = useRootPath
        return self
    }
    
    /**
     Set whether or not to use a shorten URL. (image/upload only).
     
     - parameter shortenUrl:       A boolean parameter indicating whether or not to use a shorten URL.
     
     - returns:                      the same instance of CLDUrl.
     */
    public func setShortenUrl(shortenUrl: Bool) -> CLDUrl {
        self.shortenUrl = shortenUrl
        return self
    }
    
    /**
     Set the transformation to be apllied on the remote asset.
     
     - parameter transformation:    The transformation to be apllied on the remote asset.
     
     - returns:                      the same instance of CLDUrl.
     */
    public func setTransformation(transformation: CLDTransformation) -> CLDUrl {
        self.transformation = transformation
        return self
    }
    
    // MARK: - Actions    
    
    /**
     Generate a string URL representation of the CLDUrl.
     
     - parameter publicId:      The remote asset's name (e.g. the public id of an uploaded image).
     - parameter signUrl:       A boolean parameter indicating whether or not to generate a signiture out of the API secret and add it to the generated URL. Default is false.
     
     - returns:                  The generated string URL representation.
     */
    public func generate(publicId: String, signUrl: Bool = false) -> String? {
        
        if signUrl && config.apiSecret == nil {
            printLog(.Error, text: "Must supply api_secret for signing urls")
            return nil
        }
        
        var sourceName = publicId
        var resourceType = self.resourceType
        var type = self.type
        var version = self.version ?? String()
        var format = self.format
        
        
        let preloadedComponentsMatch = GenerateUrlRegex.preloadedRegex.matchesInString(sourceName, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, sourceName.characters.count))
        if preloadedComponentsMatch.count > 0 {
            if let preloadedComponents = preloadedComponentsMatch.first {
                resourceType = (sourceName as NSString).substringWithRange(preloadedComponents.rangeAtIndex(1))
                type = (sourceName as NSString).substringWithRange(preloadedComponents.rangeAtIndex(2))
                version = (sourceName as NSString).substringWithRange(preloadedComponents.rangeAtIndex(3))
                sourceName = (sourceName as NSString).substringWithRange(preloadedComponents.rangeAtIndex(4))
            }
        }
        
        let transformation = self.transformation ?? CLDTransformation()
        if let unwrappedFormat = format where !unwrappedFormat.isEmpty && type == String(CLDType.Fetch) {
            transformation.setFetchFormat(unwrappedFormat)
            format = nil
        }
        
        guard let transformationStr = transformation.asString() else {
                printLog(.Error, text: "An invalid transformation was added.")
                return nil
        }
        
        if  version.isEmpty &&
            sourceName.containsString("/") &&
            sourceName.rangeOfString("^v[0-9]+/.*", options: NSStringCompareOptions.RegularExpressionSearch, range: nil, locale: nil) == nil &&
            sourceName.rangeOfString("^https?:/.*", options: [NSStringCompareOptions.RegularExpressionSearch, NSStringCompareOptions.CaseInsensitiveSearch], range: nil, locale: nil) == nil
        {
            version = "1"
        }
        
        if !version.isEmpty {
            version = "v\(version)"
        }
        
        var toSign: String = String()
        if !transformationStr.isEmpty {
            toSign.appendContentsOf("\(transformationStr)/")
        }
        
        if sourceName.rangeOfString("^https?:/.*", options: [NSStringCompareOptions.RegularExpressionSearch, NSStringCompareOptions.CaseInsensitiveSearch], range: nil, locale: nil) != nil {
            if let encBasename = sourceName.cldSmartEncodeUrl() {
                toSign.appendContentsOf(encBasename)
                sourceName = encBasename
            }
        }
        else {
            if let encBasename = sourceName.stringByRemovingPercentEncoding?.cldSmartEncodeUrl() {
                toSign.appendContentsOf(encBasename)
                sourceName = encBasename
            }
            
            if let suffix = suffix where !suffix.isEmpty {
                if suffix.rangeOfString("[/\\.]", options: NSStringCompareOptions.RegularExpressionSearch, range: nil, locale: nil) != nil {
                    printLog(.Error, text: "URL Suffix should not include . or /")
                    return nil
                }
                sourceName = "\(sourceName)/\(suffix)"
            }
            
            if let unwrappedFormat = format {
                sourceName = "\(sourceName).\(unwrappedFormat)"
                toSign.appendContentsOf(".\(unwrappedFormat)")
            }
        }
        
        let prefix = finalizePrefix(sourceName)
        guard let resourceTypeAndType = finalizeResourceTypeAndType(resourceType, type: type)
            else {
                return nil
        }
        
        var signature = String()
        if signUrl {
            if let apiSecret = config.apiSecret {
                toSign.appendContentsOf(apiSecret)
            }
            let encoded = toSign.sha1_base64()
            signature = "s--\(encoded[0...7])--"
        }
        
        let url = [prefix, resourceTypeAndType, signature, transformationStr, version ?? String(), sourceName].joinWithSeparator("/")
        
        let regex = try! NSRegularExpression(pattern: "([^:])\\/+", options: NSRegularExpressionOptions.CaseInsensitive)
        
        return regex.stringByReplacingMatchesInString(url, options: [], range: NSMakeRange(0, url.characters.count), withTemplate: "$1/")
    }
    
    private struct GenerateUrlRegex {
        private static let preloadedRegexString = "^([^/]+)/([^/]+)/v([0-9]+)/([^#]+)(#[0-9a-f]+)?$"
        static let preloadedRegex: NSRegularExpression = {
            return try! NSRegularExpression(pattern:preloadedRegexString, options: NSRegularExpressionOptions.CaseInsensitive)
        }()
    }
    
    // MARK: - Helpers
    
    private func finalizePrefix(basename: String) -> String {
        var prefix = String()

        if config.secure {
            var secureDistribution = String()
            if let secureDist = config.secureDistribution where (secureDist != CLDUrlConsts.CLD_OLD_AKAMAI_CHARED_CDN && !secureDist.isEmpty) {
                secureDistribution = secureDist
            }
            else {
                secureDistribution = config.privateCdn ? "\(config.cloudName)-\(CLDUrlConsts.CLD_SHARED_CDN)" : CLDUrlConsts.CLD_SHARED_CDN
            }
            
            if config.secureCdnSubdomain {
                let sharedDomain = "res-\(basename.toCRC32() % 5 + 1)\(CLDUrlConsts.CLD_COM)"
                secureDistribution = secureDistribution.stringByReplacingOccurrencesOfString(CLDUrlConsts.CLD_SHARED_CDN, withString: sharedDomain)
            }
            
            prefix = "https://\(secureDistribution)"
        }
        else if let cname = config.cname {
            prefix = "http://"
            if config.cdnSubdomain {
                prefix += "a\(basename.toCRC32() % 5 + 1)."
            }
            
            prefix += cname
        }
        else {
            prefix = "http://"
            if config.privateCdn {
                prefix += "\(config.cloudName)-"
            }
            prefix += "res"
            if config.cdnSubdomain {
                prefix += "-\(basename.toCRC32() % 5 + 1)"
            }
            prefix += CLDUrlConsts.CLD_COM
        }
        
        if !config.privateCdn {
            prefix += "/\(config.cloudName)"
        }
        return prefix
    }
    
    private func finalizeResourceTypeAndType(resourceType: String, type: String) -> String? {
        if !config.privateCdn, let urlSuffix = suffix where !urlSuffix.isEmpty {
            printLog(.Error, text: "URL Suffix only supported in private CDN")
            return nil
        }
        
        var resourceTypeAndType = "\(resourceType)/\(type)"
        if let urlSuffix = suffix where !urlSuffix.isEmpty {
            if resourceTypeAndType == "\(String(CLDUrlResourceType.Image))/\(String(CLDType.Upload))" {
               resourceTypeAndType = "images"
            }
            else if resourceTypeAndType == "\(String(CLDUrlResourceType.Raw))/\(String(CLDType.Upload))" {
                resourceTypeAndType = "files"
            }
            else {
                printLog(.Error, text: "URL Suffix only supported for image/upload and raw/upload")
                return nil
            }
        }
        
        if useRootPath {
            if resourceTypeAndType == "\(String(CLDUrlResourceType.Image))/\(String(CLDType.Upload))" || resourceTypeAndType == "images" {
               resourceTypeAndType = String()
            }
            else {
                printLog(.Error, text: "Root path only supported for image/upload")
                return nil
            }
        }
        
        if shortenUrl && resourceTypeAndType == "\(String(CLDUrlResourceType.Image))/\(String(CLDType.Upload))" {
            resourceTypeAndType = "iu"
        }
        
        return resourceTypeAndType
    }
    
}








