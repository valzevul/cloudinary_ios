//
//  CLDRenameResult.swift
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

@objc public class CLDRenameResult: CLDBaseResult {
    
    // MARK: - Getters
    
    public var publicId: String? {
        return getParam(.PublicId) as? String
    }
    
    public var format: String? {
        return getParam(.Format) as? String
    }
    
    public var version: String? {
        guard let version = getParam(.Version) else {
            return nil
        }
        return String(version)
    }
    
    public var resourceType: String? {
        return getParam(.ResourceType) as? String
    }
    
    public var type: String? {
        return getParam(.UrlType) as? String
    }
    
    public var createdAt: String? {
        return getParam(.CreatedAt) as? String
    }
    
    public var length: Double? {
        return getParam(.Length) as? Double
    }
    
    public var width: Int? {
        return getParam(.Width) as? Int
    }
    
    public var height: Int? {
        return getParam(.Height) as? Int
    }
    
    public var url: String? {
        return getParam(.Url) as? String
    }
    
    public var secureUrl: String? {
        return getParam(.SecureUrl) as? String
    }
    
    public var nextCursor: String? {
        return getParam(.NextCursor) as? String
    }
    
    public var exif: [String : String]? {
        return getParam(.Exif) as? [String : String]
    }
    
    public var metadata: [String : String]? {
        return getParam(.Metadata) as? [String : String]
    }
    
    public var faces: AnyObject? {
        return getParam(.Faces)
    }
    
    public var colors: AnyObject? {
        return getParam(.Colors)
    }
    
    public var derived: CLDDerived? {
        guard let derived = getParam(.Derived) as? [String : AnyObject] else {
            return nil
        }
        return CLDDerived(json: derived)
    }
    
    public var tags: [String]? {
        return getParam(.Tags) as? [String]
    }
    
    public var moderation: AnyObject? {
        return getParam(.Moderation)
    }
    
    public var context: AnyObject? {
        return getParam(.Context)
    }
    
    public var phash: String? {
        return getParam(.Phash) as? String
    }
    
    public var predominant: CLDPredominant? {
        guard let predominant = getParam(.Predominant) as? [String : AnyObject] else {
            return nil
        }
        return CLDPredominant(json: predominant)
    }
    
    public var coordinates: CLDCoordinates? {
        guard let coordinates = getParam(.Coordinates) as? [String : AnyObject] else {
            return nil
        }
        return CLDCoordinates(json: coordinates)
    }
    
    public var info: CLDInfo? {
        guard let info = getParam(.Info) as? [String : AnyObject] else {
            return nil
        }
        return CLDInfo(json: info)
    }
    
    // MARK: - Private Helpers
    
    private func getParam(param: RenameResultKey) -> AnyObject? {
        return resultJson[String(param)]
    }

    private enum RenameResultKey: CustomStringConvertible {
        case NextCursor, Derived, Context, Predominant, Coordinates
        
        var description: String {
            switch self {
            case .NextCursor:       return "next_cursor"
            case .Derived:          return "derived"            
            case .Context:          return "context"
            case .Predominant:      return "predominant"
            case .Coordinates:      return "coordinates"
            }
        }
    }
}


// MARK: - CLDCoordinates

@objc public class CLDCoordinates: CLDBaseResult {
    
    public var custom: AnyObject? {
        return getParam(.Custom)
    }
    
    public var faces: AnyObject? {
        return getParam(.Faces)
    }
    
    // MARK: Private Helpers
    
    private func getParam(param: CLDCoordinatesKey) -> AnyObject? {
        return resultJson[String(param)]
    }
    
    private enum CLDCoordinatesKey: CustomStringConvertible {
        case Custom
        
        var description: String {
            switch self {
            case .Custom:           return "custom"
            }
        }
    }
}


// MARK: - CLDPredominant

@objc public class CLDPredominant: CLDBaseResult {
    
    public var google: AnyObject? {
        return getParam(.Google)
    }
    
    // MARK: - Private Helpers
    
    private func getParam(param: CLDPredominantKey) -> AnyObject? {
        return resultJson[String(param)]
    }
    
    private enum CLDPredominantKey: CustomStringConvertible {
        case Google
        
        var description: String {
            switch self {
            case .Google:           return "google"
            }
        }
    }
}


// MARK: - CLDDerived

@objc public class CLDDerived: CLDBaseResult {
    
    public var transformation: String? {
        return getParam(.Transformation) as? String
    }
    
    public var format: String? {
        return getParam(.Format) as? String
    }
    
    public var length: Double? {
        return getParam(.Length) as? Double
    }
    
    public var identifier: String? {
        return getParam(.Id) as? String
    }
    
    public var url: String? {
        return getParam(.Url) as? String
    }
    
    public var secureUrl: String? {
        return getParam(.SecureUrl) as? String
    }
    
    // MARK: - Private Helpers
    
    private func getParam(param: CLDDerivedKey) -> AnyObject? {
        return resultJson[String(param)]
    }
    
    private enum CLDDerivedKey: CustomStringConvertible {
        case Transformation, Id
        
        var description: String {
            switch self {
            case .Transformation:           return "transformation"
            case .Id:                       return "id"
            }
        }
    }
}