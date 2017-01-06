//
//  CLDBoundingBox.swift
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

@objc public class CLDBoundingBox: CLDBaseResult {
    
    public var topLeft: CGPoint? {
        return CLDBoundingBox.parsePoint(resultJson, key: String(CLDBoundingBoxJsonKey.TopLeft))
    }
    
    public var size: CGSize? {
        return CLDBoundingBox.parseSize(resultJson, key: String(CLDBoundingBoxJsonKey.Size))
    }
    
    internal static func parsePoint(json: [String : AnyObject], key: String) -> CGPoint? {
        guard let
            point = json[key] as? [String : Double],
            x = point[CommonResultKeys.X.description],
            y = point[CommonResultKeys.Y.description] else {
                return nil
        }
        return CGPointMake(CGFloat(x), CGFloat(y))
    }
    
    internal static func parseSize(json: [String : AnyObject], key: String) -> CGSize? {
        guard let
            point = json[key] as? [String : Double],
            width = point[CommonResultKeys.Width.description],
            height = point[CommonResultKeys.Height.description] else {
                return nil
        }
        return CGSizeMake(CGFloat(width), CGFloat(height))
    }
    
    // MARK: - Private Helpers
    
    private func getParam(param: CLDBoundingBoxJsonKey) -> AnyObject? {
        return resultJson[String(param)]
    }
    
    private enum CLDBoundingBoxJsonKey: CustomStringConvertible {
        case TopLeft, Size
        
        var description: String {
            switch self {
            case .TopLeft:  return "tl"
            case .Size:     return "size"
            }
        }
    }
}