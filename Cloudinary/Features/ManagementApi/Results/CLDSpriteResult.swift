//
//  CLDSpriteResult.swift
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

@objc public class CLDSpriteResult: CLDBaseResult {
    
    // MARK: - Getters
    
    public var cssUrl: String? {
        return getParam(.CssUrl) as? String
    }
    
    public var secureCssUrl: String? {
        return getParam(.SecureCssUrl) as? String
    }
    
    public var imageUrl: String? {
        return getParam(.ImageUrl) as? String
    }
    
    public var jsonUrl: String? {
        return getParam(.JsonUrl) as? String
    }
    
    public var publicId: String? {
        return getParam(.PublicId) as? String
    }
    
    public var version: String? {
        guard let version = getParam(.Version) else {
            return nil
        }
        return String(version)
    }
    
    public var imageInfos: [String : CLDImageInfo]? {
        guard let imageInfosDic = getParam(.ImageInfos) as? [String : AnyObject] else {
            return nil
        }
        var imageInfos: [String : CLDImageInfo] = [:]
        for key in imageInfosDic.keys {
            if let imgInfo = imageInfosDic[key] as? [String : AnyObject] {
                imageInfos[key] = CLDImageInfo(json: imgInfo)
            }
        }
        return imageInfos
    }
    
    
    // MARK: - Private Helpers
    
    private func getParam(param: SpriteResultKey) -> AnyObject? {
        return resultJson[String(param)]
    }
    
    private enum SpriteResultKey: CustomStringConvertible {
        case CssUrl, SecureCssUrl, ImageUrl, JsonUrl, ImageInfos
        
        var description: String {
            switch self {
            case .CssUrl:               return "css_url"
            case .SecureCssUrl:         return "secure_css_url"
            case .ImageUrl:             return "image_url"
            case .JsonUrl:              return "json_url"
            case .ImageInfos:           return "image_infos"
            }
        }
    }
}


@objc public class CLDImageInfo: CLDBaseResult {
    
    public var x: Int? {
        return getParam(.X) as? Int
    }
    
    public var y: Int? {
        return getParam(.Y) as? Int
    }
    
    public var width: Int? {
        return getParam(.Width) as? Int
    }
    
    public var height: Int? {
        return getParam(.Height) as? Int
    }    
}

