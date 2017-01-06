//
//  CLDRekognitionFace.swift
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

@objc public class CLDRekognitionFace: CLDBaseResult {
    
    public var status: String? {
        return getParam(.Status) as? String
    }
    
    public var faces: [CLDFace]? {
        guard let facesArr = getParam(.Faces) as? [[String : AnyObject]] else {
            return nil
        }
        var faces: [CLDFace] = []
        for face in facesArr {
            faces.append(CLDFace(json: face))
        }
        return faces
    }
    
    // MARK: - Private Helpers
    
    private func getParam(param: CLDRekognitionFaceKey) -> AnyObject? {
        return resultJson[String(param)]
    }
    
    private enum CLDRekognitionFaceKey: CustomStringConvertible {
        case Status, FacesData
        
        var description: String {
            switch self {
            case .Status:           return "status"
            case .FacesData:        return "data"
            }
        }
    }
}