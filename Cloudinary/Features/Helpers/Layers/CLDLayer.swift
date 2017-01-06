//
//  CLDLayer.swift
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
 The CLDLayer is used to help adding an overlay or underlay layer to a transformation.
*/
@objc public class CLDLayer: NSObject {
    
    internal var publicId: String?
    internal var format: String?
    internal var resourceType: String?
    internal var type: String?    
    
    // MARK: - Init
    
    /**
    Initialize a CLDLayer instance.
    
    -returns: The new CLDLayer instance.
    */
    public override init() {
        super.init()
    }
    
    // MARK: - Set Values
    
    /**
    The identifier of the image to use as a layer.
    
    - parameter publicId:      The identifier of the image to use as a layer.
    
    - returns:                 The same instance of CLDLayer.
    */
    public func setPublicId(publicId publicId: String) -> CLDLayer {
        self.publicId = publicId
        return self
    }
    
    /**
     The format of the image to use as a layer.
     
     - parameter format:        The format of the image to use as a layer.
     
     - returns:                 The same instance of CLDLayer.
     */
    public func setFormat(format format: String) -> CLDLayer {
        self.format = format
        return self
    }
    
    /**
     Set the layer resource type.
     
     - parameter resourceType:      The layer resource type.
     
     - returns:                     The same instance of CLDLayer.
     */
    @objc(setResourceTypeFromLayerResourceType:)
    public func setResourceType(resourceType: LayerResourceType) -> CLDLayer {
        return setResourceType(String(resourceType))
    }
    
    /**
     Set the layer resource type.
     
     - parameter resourceType:      The layer resource type.
     
     - returns:                     The same instance of CLDLayer.
     */
    @objc(setResourceTypeFromString:)
    public func setResourceType(resourceType: String) -> CLDLayer {
        self.resourceType = resourceType
        return self
    }
    
    /**
     Set the layer type.
     
     - parameter type:  The layer type.
     
     - returns:         The same instance of CLDLayer.
     */
    @objc(setTypeFromType:)
    public func setType(type: CLDType) -> CLDLayer {
        return setType(String(type))
    }
    
    /**
     Set the layer type.
     
     - parameter type:  The layer type.
     
     - returns:         The same instance of CLDLayer.
     */
    @objc(setTypeFromString:)
    public func setType(rawType: String) -> CLDLayer {
        type = rawType
        return self
    }
    
    // MARK: - Helpers
    
    private func isResourceTypeTextual(resourceType: String?) -> Bool {
        guard let resourceType = resourceType else {
                return false
        }
        return resourceType == String(LayerResourceType.Text) || resourceType == String(LayerResourceType.Subtitles)
    }
    
    internal func getFinalPublicId() -> String? {
        var finalPublicId: String?
        if let pubId = publicId where !pubId.isEmpty, let format = format where !format.isEmpty {
            finalPublicId = "\(pubId).\(format)"
        }
        return finalPublicId ?? publicId
    }
    
    internal func getStringComponents() -> [String]? {
        var components: [String] = []
        
        if publicId == nil, let resourceType = resourceType where resourceType != String(LayerResourceType.Text) {
            printLog(.Error, text: "Must supply publicId for non-text layer")
            return nil
        }
        
        if let resourceType = resourceType where resourceType != String(LayerResourceType.Image) {
            components.append(resourceType)
        }
        if let type = type where type != String(CLDType.Upload) {
            components.append(type)
        }
        
        if !isResourceTypeTextual(resourceType) {
            if let pubId = getFinalPublicId() where !pubId.isEmpty {
                components.append(pubId.stringByReplacingOccurrencesOfString("/", withString: ":"))
            }
        }
        
        return components
    }
    
    // MARK: - Actions
    
    internal func asString() -> String? {
        guard let components = self.getStringComponents() else {
            return nil
        }
        
        return components.joinWithSeparator(":")
    }
    
    // MARK: - Params
    
    @objc public enum LayerResourceType: Int, CustomStringConvertible {
        case Image, Raw, Auto, Text, Subtitles, Video
        
        public var description: String {
            get {
                switch self {
                case .Image:        return "image"
                case .Raw:          return "raw"
                case .Auto:         return "auto"
                case .Text:         return "text"
                case .Subtitles:    return "subtitles"
                case .Video:        return "video"
                }
            }
        }
    }
}
