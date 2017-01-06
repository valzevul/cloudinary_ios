//
//  CLDDefinitions.swift
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

// MARK: URL Type

@objc public enum CLDType: Int, CustomStringConvertible {
    case Upload, Fetch, Facebook, Twitter, TwitterName, Sprite, Private, Authenticated
    
    public var description: String {
        get {
            switch self {
            case .Upload:               return "upload"
            case .Facebook:             return "facebook"
            case .Fetch:                return "fetch"
            case .Twitter:              return "twitter"
            case .TwitterName:          return "twitter_name"
            case .Sprite:               return "sprite"
            case .Private:              return "private"
            case .Authenticated:        return "authenticated"
            }
        }
    }
}

// MARK: Resource Type

@objc public enum CLDUrlResourceType: Int, CustomStringConvertible {
    case Image, Raw, Video, Auto
    
    public var description: String {
        get {
            switch self {
            case .Image:        return "image"
            case .Raw:          return "raw"
            case .Video:        return "video"
            case .Auto:         return "auto"
            }
        }
    }
}

// MARK: - Upload Params

@objc public enum CLDModeration: Int, CustomStringConvertible {
    case Manual, Webpurify
    
    public var description: String {
        get {
            switch self {
            case .Manual:           return "manual"
            case .Webpurify:        return "webpurify"
            }
        }
    }
}

// MARK: - Text Params

@objc public enum CLDFontWeight: Int, CustomStringConvertible {
    case Normal, Bold
    
    public var description: String {
        get {
            switch self {
            case .Normal:           return "normal"
            case .Bold:             return "bold"
            }
        }
    }
}

@objc public enum CLDFontStyle: Int, CustomStringConvertible {
    case Normal, Italic
    
    public var description: String {
        get {
            switch self {
            case .Normal:           return "normal"
            case .Italic:           return "italic"
            }
        }
    }
}

@objc public enum CLDTextDecoration: Int, CustomStringConvertible {
    case None, Underline
    
    public var description: String {
        get {
            switch self {
            case .None:             return "none"
            case .Underline:        return "underline"
            }
        }
    }
}

