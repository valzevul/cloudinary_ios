//
//  CLDUploadResult.swift
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

@objc public class CLDUploadResult: CLDBaseResult {
    
    
    // MARK: - Getters
    
    public var publicId: String? {
        return getParam(.PublicId) as? String
    }
    
    public var version: String? {
        guard let version = getParam(.Version) else {
            return nil
        }
        return String(version)
    }
    
    public var url: String? {
        return getParam(.Url) as? String
    }
    
    public var secureUrl: String? {
        return getParam(.SecureUrl) as? String
    }
    
    public var resourceType: String? {
        return getParam(.ResourceType) as? String
    }
    
    public var signature: String? {
        return getParam(.Signature) as? String
    }
    
    public var createdAt: String? {
        return getParam(.CreatedAt) as? String
    }
    
    public var length: Double? {
        return getParam(.Length) as? Double
    }
    
    public var tags: [String]? {
        return getParam(.Tags) as? [String]
    }
    
    public var moderation: AnyObject? {
        return getParam(.Moderation)
    }
    
    // MARK: Image Params
    
    public var width: Int? {
        return getParam(.Width) as? Int
    }
    
    public var height: Int? {
        return getParam(.Height) as? Int
    }
    
    public var format: String? {
        return getParam(.Format) as? String
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
    
    public var phash: String? {
        return getParam(.Phash) as? String
    }
    
    public var deleteToken: String? {
        return getParam(.DeleteToken) as? String
    }
    
    public var info: CLDInfo? {
        guard let info = getParam(.Info) as? [String : AnyObject] else {
            return nil
        }
        return CLDInfo(json: info)
    }
    
    // MARK: Video Params
    
    public var video: CLDVideo? {
        guard let video = getParam(.Video) as? [String : AnyObject] else {
            return nil
        }
        return CLDVideo(json: video)
    }
    
    public var audio: CLDAudio? {
        guard let audio = getParam(.Audio) as? [String : AnyObject] else {
            return nil
        }
        return CLDAudio(json: audio)
    }
    
    public var frameRte: Double? {
        return getParam(.FrameRate) as? Double
    }
    
    public var bitRate: Int? {
        return getParam(.BitRate) as? Int
    }
    
    public var duration: Double? {
        return getParam(.Duration) as? Double
    }
    
    // MARK: - Private Helpers
    
    private func getParam(param: UploadResultKey) -> AnyObject? {
        return resultJson[String(param)]
    }
    
    enum UploadResultKey: CustomStringConvertible {
        case Signature
        case DeleteToken // Image
        case Video, Audio, FrameRate, BitRate, Duration // Video
        
        var description: String {
            switch self {
            case .Signature:        return "signature"
                
            case .DeleteToken:      return "delete_token"
                
            case .Video:            return "video"
            case .Audio:            return "audio"
            case .FrameRate:        return "frame_rate"
            case .BitRate:          return "bit_rate"
            case .Duration:         return "duration"
            }
        }
    }
}


// MARK: - Video Result

@objc public class CLDVideo: CLDBaseResult {
    
    public var format: String? {
        return getParam(.PixFormat) as? String
    }
    
    public var codec: String? {
        return getParam(.Codec) as? String
    }
    
    public var level: Int? {
        return getParam(.Level) as? Int
    }
    
    public var bitRate: Int? {
        return getParam(.BitRate) as? Int
    }
    
    // MARK: - Private Helpers
    
    private func getParam(param: VideoKey) -> AnyObject? {
        return resultJson[String(param)]
    }
    
    private enum VideoKey: CustomStringConvertible {
        case PixFormat, Codec, Level, BitRate
        
        var description: String {
            switch self {
            case .PixFormat:        return "pix_format"
            case .Codec:            return "codec"
            case .Level:            return "level"
            case .BitRate:          return "bit_rate"
            }
        }
    }
}

@objc public class CLDAudio: CLDBaseResult {
    
    public var codec: String? {
        return getParam(.Codec) as? String
    }
    
    public var bitRate: Int? {
        return getParam(.BitRate) as? Int
    }
    
    public var frequency: Int? {
        return getParam(.Frequency) as? Int
    }
    
    public var channels: Int? {
        return getParam(.Channels) as? Int
    }
    
    public var channelLayout: String? {
        return getParam(.ChannelLayout) as? String
    }
    
    // MARK: - Private Helpers
    
    private func getParam(param: AudioKey) -> AnyObject? {
        return resultJson[String(param)]
    }
    
    private enum AudioKey: CustomStringConvertible {
        case Codec, BitRate, Frequency, Channels, ChannelLayout
        
        var description: String {
            switch self {
            case .Codec:            return "codec"
            case .BitRate:          return "bit_rate"
            case .Frequency:        return "frequency"
            case .Channels:         return "channels"
            case .ChannelLayout:    return "channel_layout"
            }
        }
    }
}
