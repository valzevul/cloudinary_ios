//
//  CLDFace.swift
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

@objc public class CLDFace: CLDBaseResult {
    
    public var boundingBox: CLDBoundingBox? {
        guard let bb = getParam(.BoundingBox) as? [String : AnyObject] else {
            return nil
        }
        return CLDBoundingBox(json: bb)
    }
    
    public var confidence: Double? {
        return getParam(.Confidence) as? Double
    }
    
    public var age: Double? {
        return getParam(.Age) as? Double
    }
    
    public var smile: Double? {
        return getParam(.Smile) as? Double
    }
    
    public var glasses: Double? {
        return getParam(.Glasses) as? Double
    }
    
    public var sunglasses: Double? {
        return getParam(.Sunglasses) as? Double
    }
    
    public var beard: Double? {
        return getParam(.Beard) as? Double
    }
    
    public var mustache: Double? {
        return getParam(.Mustache) as? Double
    }
    
    public var eyeClosed: Double? {
        return getParam(.EyeClosed) as? Double
    }
    
    public var mouthOpenWide: Double? {
        return getParam(.MouthOpenWide) as? Double
    }
    
    public var beauty: Double? {
        return getParam(.Beauty) as? Double
    }
    
    public var gender: Double? {
        return getParam(.Gender) as? Double
    }
    
    public var race: [String : Double]? {
        return getParam(.Race) as? [String : Double]
    }
    
    public var emotion: [String : Double]? {
        return getParam(.Emotion) as? [String : Double]
    }
    
    public var quality: [String : Double]? {
        return getParam(.Quality) as? [String : Double]
    }
    
    public var pose: [String : Double]? {
        return getParam(.Pose) as? [String : Double]
    }
    
    public var eyeLeftPosition: CGPoint? {
        return CLDBoundingBox.parsePoint(resultJson, key: String(CLDFaceKey.EyeLeftPosition))
    }
    
    public var eyeRightPosition: CGPoint? {
        return CLDBoundingBox.parsePoint(resultJson, key: String(CLDFaceKey.EyeRightPosition))
    }
    
    public var eyeLeft_Left: CGPoint? {
        return CLDBoundingBox.parsePoint(resultJson, key: String(CLDFaceKey.EyeLeft_Left))
    }
    
    public var eyeLeft_Right: CGPoint? {
        return CLDBoundingBox.parsePoint(resultJson, key: String(CLDFaceKey.EyeLeft_Right))
    }
    
    public var eyeLeft_Up: CGPoint? {
        return CLDBoundingBox.parsePoint(resultJson, key: String(CLDFaceKey.EyeLeft_Up))
    }
    
    public var eyeLeft_Down: CGPoint? {
        return CLDBoundingBox.parsePoint(resultJson, key: String(CLDFaceKey.EyeLeft_Down))
    }
    
    public var eyeRight_Left: CGPoint? {
        return CLDBoundingBox.parsePoint(resultJson, key: String(CLDFaceKey.EyeRight_Left))
    }
    
    public var eyeRight_Right: CGPoint? {
        return CLDBoundingBox.parsePoint(resultJson, key: String(CLDFaceKey.EyeRight_Right))
    }
    
    public var eyeRight_Up: CGPoint? {
        return CLDBoundingBox.parsePoint(resultJson, key: String(CLDFaceKey.EyeRight_Up))
    }
    
    public var eyeRight_Down: CGPoint? {
        return CLDBoundingBox.parsePoint(resultJson, key: String(CLDFaceKey.EyeRight_Down))
    }
    
    public var nosePosition: CGPoint? {
        return CLDBoundingBox.parsePoint(resultJson, key: String(CLDFaceKey.NosePosition))
    }
    
    public var noseLeft: CGPoint? {
        return CLDBoundingBox.parsePoint(resultJson, key: String(CLDFaceKey.NoseLeft))
    }
    
    public var noseRight: CGPoint? {
        return CLDBoundingBox.parsePoint(resultJson, key: String(CLDFaceKey.NoseRight))
    }
    
    public var mouthLeft: CGPoint? {
        return CLDBoundingBox.parsePoint(resultJson, key: String(CLDFaceKey.MouthLeft))
    }
    
    public var mouthRight: CGPoint? {
        return CLDBoundingBox.parsePoint(resultJson, key: String(CLDFaceKey.MouthRight))
    }
    
    public var mouthUp: CGPoint? {
        return CLDBoundingBox.parsePoint(resultJson, key: String(CLDFaceKey.MouthUp))
    }
    
    public var mouthDown: CGPoint? {
        return CLDBoundingBox.parsePoint(resultJson, key: String(CLDFaceKey.MouthDown))
    }
    
    // MARK: - Private Helpers
    
    private func getParam(param: CLDFaceKey) -> AnyObject? {
        return resultJson[String(param)]
    }
    
    private enum CLDFaceKey: CustomStringConvertible {
        case BoundingBox, Confidence, Age, Smile, Glasses, Sunglasses, Beard, Mustache, EyeClosed, MouthOpenWide, Beauty, Gender, Race, Emotion, Quality, Pose, EyeLeftPosition, EyeRightPosition, EyeLeft_Left, EyeLeft_Right, EyeLeft_Up, EyeLeft_Down, EyeRight_Left, EyeRight_Right, EyeRight_Up, EyeRight_Down, NosePosition, NoseLeft, NoseRight, MouthLeft, MouthRight, MouthUp, MouthDown
        
        var description: String {
            switch self {
            case .BoundingBox:          return "boundingbox"
            case .Confidence:           return "confidence"
            case .Age:                  return "age"
            case .Smile:                return "smile"
            case .Glasses:              return "glasses"
            case .Sunglasses:           return "sunglasses"
            case .Beard:                return "beard"
            case .Mustache:             return "mustache"
            case .EyeClosed:            return "eye_closed"
            case .MouthOpenWide:        return "mouth_open_wide"
            case .Beauty:               return "beauty"
            case .Gender:               return "sex"
            case .Race:                 return "race"
            case .Emotion:              return "emotion"
            case .Quality:              return "quality"
            case .Pose:                 return "pose"
            case .EyeLeftPosition:      return "eye_left"
            case .EyeRightPosition:     return "eye_right"
            case .EyeLeft_Left:         return "e_ll"
            case .EyeLeft_Right:        return "e_lr"
            case .EyeLeft_Up:           return "e_lu"
            case .EyeLeft_Down:         return "e_ld"
            case .EyeRight_Left:        return "e_rl"
            case .EyeRight_Right:       return "e_rr"
            case .EyeRight_Up:          return "e_ru"
            case .EyeRight_Down:        return "e_rd"
            case .NosePosition:         return "nose"
            case .NoseLeft:             return "n_l"
            case .NoseRight:            return "n_r"
            case .MouthLeft:            return "mouth_l"
            case .MouthRight:           return "mouth_r"
            case .MouthUp:              return "m_u"
            case .MouthDown:            return "m_d"
            }
        }
    }
}