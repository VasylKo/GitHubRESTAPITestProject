//
//  NetworkDataProvider.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 16/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper
import BrightFutures
import MobileCoreServices

public class NetworkDataProvider {
    
    /**
    Create request for mappable object
    
    - parameter URLRequest: The URL request
    
    - returns: Tuple with request and future
    */
    public func objectRequest<T: Mappable>(
        URLRequest: Alamofire.URLRequestConvertible,
        validation: Alamofire.Request.Validation? = nil
        ) -> (Alamofire.Request, Future<T, NSError>) {
            let mapping: AnyObject? -> T? = { json in
                return Mapper<T>().map(json)
            }
            return jsonRequest(URLRequest, map: mapping, validation: validation)
    }
    
    /**
    Create request for multiple mappable objects
    
    - parameter URLRequest: The URL request
    
    - returns: Tuple with request and future
    */
    public func arrayRequest<T: Mappable>(
        URLRequest: Alamofire.URLRequestConvertible,
        validation: Alamofire.Request.Validation? = nil
        ) -> (Alamofire.Request, Future<[T], NSError>) {
            let mapping: AnyObject? -> [T]? = { json in
                return Mapper<T>().mapArray(json)
            }
            return jsonRequest(URLRequest, map: mapping, validation: validation)
    }
    
    /**
    Create request with JSON mapping
    
    - parameter URLRequest: The URL request
    - parameter map:        Response mapping function
    
    - returns: Tuple with request and future
    */
    public  func jsonRequest<V>(
        URLRequest: Alamofire.URLRequestConvertible,
        map: AnyObject?->V?,
        validation: Alamofire.Request.Validation? = nil
        ) -> (Alamofire.Request, Future<V, NSError>) {
            let serializer = Alamofire.Request.CustomResponseSerializer(map)
            return request(URLRequest, serializer: serializer, validation: validation)
    }
    
    
    /**
    Designated initializer
    
    - parameter api:           api service
    - parameter configuration: session configuration
    
    - returns: new instance
    */
    public init(
        configuration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration(),
        trustPolicies: [String: ServerTrustPolicy]? = nil
        ) {
            let serverTrustPolicyManager = trustPolicies.map { ServerTrustPolicyManager(policies: $0) }
            manager = Alamofire.Manager(configuration: configuration, serverTrustPolicyManager: serverTrustPolicyManager)
    }
    
    /// Singleton instance
    public class var sharedInstance: NetworkDataProvider {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: NetworkDataProvider? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = NetworkDataProvider()
        }
        return Static.instance!
    }

    private let manager: Alamofire.Manager
    private let activityIndicator = NetworkActivityIndicatorManager()
    
    /**
    Create request with serializer
    
    - parameter URLRequest: The URL request
    - parameter serializer: Response serializer
    
    - returns: Tuple with request and future
    */
    public func request<V, Serializer: Alamofire.ResponseSerializerType where Serializer.SerializedObject == V, Serializer.ErrorObject == NSError> (
        URLRequest: Alamofire.URLRequestConvertible,
        serializer: Serializer,
        validation: Alamofire.Request.Validation?
        ) -> (Alamofire.Request, Future<V, NSError>) {
            let p = Promise<V, NSError>()
        
            activityIndicator.increment()
            let request =  self.request(URLRequest, validation: validation).response(
                queue: Queue.global.underlyingQueue,
                responseSerializer: serializer) { [unowned self] response in
                    self.activityIndicator.decrement()
                    switch response.result {
                    case .Success(let value):
                        p.success(value)
                    case .Failure(let error):
                        p.failure(error)
                    }
                    
            }
            
        return (request, p.future)
    }
    
    private func request(URLRequest: Alamofire.URLRequestConvertible, validation: Alamofire.Request.Validation?) -> Alamofire.Request {
        let request = manager.request(URLRequest)
//        #if DEBUG
        print("Request:\n\(request.debugDescription)")
//        #endif
        if let validation = validation {
            return request.validate(validation)
        } else {
            return request.validate(statusCode: [] + (200..<300) + (400..<600) )
        }
    }
}


private extension Alamofire.Request {
    
    //MARK: - Custom serializer -
    private static func CustomResponseSerializer<T>(mapping: AnyObject? -> T?) -> ResponseSerializer<T, NSError> {
        return ResponseSerializer { request, response, data, error in
            guard error == nil else { return .Failure(error!) }
            
            let JSONResponseSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
            let result = JSONResponseSerializer.serializeResponse(request, response, data, error)
            
            switch result {
            case .Success(let json):
                guard let object = mapping(json) else {
                    if  let jsonDict = json as? [String: AnyObject],
                        let msg = jsonDict["error"] as? String {
                            if let statusCode = response?.statusCode where statusCode == 401 {
                                return .Failure(NetworkDataProvider.ErrorCodes.InvalidSessionError.error(localizedDescription: msg))
                            } else {
                                return .Failure(NetworkDataProvider.ErrorCodes.TransferError.error(localizedDescription: msg))
                            }
                    }
                    return .Failure(NetworkDataProvider.ErrorCodes.InvalidResponseError.error())
                }
                return .Success(object)
            case .Failure(let error):
                return .Failure(NetworkDataProvider.ErrorCodes.ParsingError.error(error))
            }
        }
    }
}

//MARK: - Network error codes -

extension NetworkDataProvider {
    /**
    Network error codes
    
    - UnknownError:    Unknown error
    - InvalidRequestError:  Invalid request error
    - TransferError:   Transfer error
    - InvalidResponseError: Invalid response error
    - ParsingError:    Response Parsing error
    */
    public enum ErrorCodes: Int {
        public static let errorDomain = "com.bekitzur.network"
        
        case UnknownError, InvalidRequestError, TransferError, InvalidResponseError, ParsingError, InvalidSessionError
        
        /**
        Trying to construct Error code from NSError
        
        - parameter error: NSError instance
        
        - returns: Error code or nil
        */
        public static func fromError(error: NSError) -> ErrorCodes? {
            if error.domain == ErrorCodes.errorDomain {
                return ErrorCodes(rawValue: error.code)
            }
            return nil
        }
        
        /**
        Converting Error code to the NSError
        
        - parameter underlyingError: underlying error
        - parameter description: Localized description
        
        - returns: NSError instance
        */
        public func error(underlyingError: NSError? = nil, localizedDescription: String? = nil) -> NSError {
            let description = localizedDescription ?? NSString(
                format: NSLocalizedString("Network error: %@", comment: "Localized network error description"),
                self.reason)
        
            var userInfo: [NSObject : AnyObject] = [
                NSLocalizedDescriptionKey: description,
                NSLocalizedFailureReasonErrorKey: self.reason,
            ]
            
            if let underlyingError = underlyingError {
                userInfo[NSUnderlyingErrorKey] = underlyingError
            }
            return NSError(domain:ErrorCodes.errorDomain, code: self.rawValue, userInfo: userInfo)
        }
        
        /// Localized failure reason
        var reason: String {
            switch self {
            case .InvalidRequestError:
                return NSLocalizedString("InvalidRequestError", comment: "Invalid request")
            case .InvalidResponseError:
                return NSLocalizedString("InvalidResponseError", comment: "Invalid response")
            case .ParsingError:
                return NSLocalizedString("ParsingError", comment: "Parsing error")
            case .TransferError:
                return NSLocalizedString("TransferError", comment: "Data transfer error")
            case .InvalidSessionError:
                return NSLocalizedString("InvalidSessionError", comment: "Session error")
            case .UnknownError:
                fallthrough
            default:
                return NSLocalizedString("UnknownError", comment: "Unknown error")
            }
        }
    }
}

//MARK: Upload
extension NetworkDataProvider {
    
    /// File upload info
    final public class FileUpload {
        let data: NSData
        let name: String
        let filename: String
        let mimeType: String
        
        public init (data: NSData, dataUTI: String, name: String = "file") {
            self.name = name
            self.data = data
            mimeType = copyTag(kUTTagClassMIMEType, fromUTI: dataUTI, defaultValue: "application/octet-stream")
            let fileExtension = copyTag(kUTTagClassFilenameExtension, fromUTI: dataUTI, defaultValue: "png")
            filename = (name as NSString).stringByAppendingPathExtension(fileExtension) ?? name
        }
    }
    
    /**
    Uploads a files
    
    - parameter URLRequest: url request
    - parameter urls:       files info
    
    - returns: Request future
    */
    public func upload(
        URLRequest: Alamofire.URLRequestConvertible,
        files: [FileUpload]
        ) -> (Future<AnyObject?, NSError>) {
            let p = Promise<AnyObject?, NSError>()
            
            manager.upload(URLRequest,
                multipartFormData: { multipartFormData in
                    for fileInfo in files {
                        multipartFormData.appendBodyPart(
                            data: fileInfo.data,
                            name: fileInfo.name,
                            fileName: fileInfo.filename,
                            mimeType: fileInfo.mimeType
                        )
                    }
                },
                encodingCompletion:{ encodingResult in
                    switch encodingResult {
                    case .Success(let upload, _, _):
                        print("Request:\n\(upload.debugDescription)")
                        upload.validate(statusCode: [201]).responseJSON { response in
                            switch response.result {
                            case .Success(let JSON):
                                p.success(JSON)
                            case .Failure(let error):
                                p.failure(error)
                            }
                        }
                    case .Failure(let encodingError):
                        p.failure(encodingError as NSError)
                    }
            })
            return p.future
    }
}

private func copyTag(tag: CFString!, fromUTI dataUTI: String, defaultValue: String) -> String {
    guard let str = UTTypeCopyPreferredTagWithClass(dataUTI, tag) else {
        return defaultValue
    }
    return str.takeRetainedValue() as String
}