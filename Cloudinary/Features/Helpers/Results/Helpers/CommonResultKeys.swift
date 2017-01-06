//
//  CommonResultKeys.swift
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

internal enum CommonResultKeys: CustomStringConvertible {
    case PublicId, Format, Version, ResourceType, UrlType, CreatedAt, Length, Width, Height, X, Y, Url, SecureUrl, Exif, Metadata, Faces, Colors, Tags, Moderation, Phash, Info
    
    var description: String {
        switch self {
        case .PublicId:         return "public_id"
        case .Format:           return "format"
        case .Version:          return "version"
        case .ResourceType:     return "resource_type"
        case .UrlType:          return "type"
        case .CreatedAt:        return "created_at"
        case .Length:           return "bytes"
        case .Width:            return "width"
        case .Height:           return "height"
        case .X:                return "x"
        case .Y:                return "y"
        case .Url:              return "url"
        case .SecureUrl:        return "secure_url"
        case .Exif:             return "exif"
        case .Metadata:         return "image_metadata"
        case .Faces:            return "faces"
        case .Colors:           return "colors"
        case .Tags:             return "tags"
        case .Moderation:       return "moderation"
        case .Phash:            return "phash"        
        case .Info:             return "info"
        }
    }
}