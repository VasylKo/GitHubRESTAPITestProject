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
import Box
import MobileCoreServices

public class NetworkDataProvider: NSObject {
    
    /**
    Create request for mappable object
    
    :param: URLRequest The URL request
    
    :returns: Tuple with request and future
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
    
    :param: URLRequest The URL request
    
    :returns: Tuple with request and future
    */
    public func arrayRequest<T: Mappable>(
        URLRequest: Alamofire.URLRequestConvertible,
        validation: Alamofire.Request.Validation? = nil
        ) -> (Alamofire.Request, Future<[T], NSError>) {
            let mapping: AnyObject? -> [T]? = { json in
                return Mapper<T>().mapArray((json))
            }
            return jsonRequest(URLRequest, map: mapping, validation: validation)
    }
    
    /**
    Create request with JSON mapping
    
    :param: URLRequest The URL request
    :param: map        Response mapping function
    
    :returns: Tuple with request and future
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
    
    :param: api           api service
    :param: configuration session configuration
    
    :returns: new instance
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
    
    :param: URLRequest The URL request
    :param: serializer Response serializer
    
    :returns: Tuple with request and future
    */
    private func request<V,Serializer: Alamofire.ResponseSerializer where Serializer.SerializedObject == Box<V>>(
        URLRequest: Alamofire.URLRequestConvertible,
        serializer: Serializer,
        validation: Alamofire.Request.Validation?
        ) -> (Alamofire.Request, Future<V, NSError>) {
            let p = Promise<V, NSError>()
        
            activityIndicator.increment()
            let request =  self.request(URLRequest, validation: validation).response(
                queue: Queue.global.underlyingQueue,
                responseSerializer: serializer) {
                    [unowned self] (request, response, object, error) in
                    self.activityIndicator.decrement()
                    if let object = object  {
                        p.success(object.value)
                    } else {
                        let e: NSError = {
                            if let statusCode = response?.statusCode where statusCode == 401 {
                                return ErrorCodes.InvalidSessionError.error(underlyingError: error)
                            }
                            return error ?? ErrorCodes.InvalidResponseError.error()
                        }()
                        p.failure(e)
                    }
            }
        return (request, p.future)
    }
    
    private func request(URLRequest: Alamofire.URLRequestConvertible, validation: Alamofire.Request.Validation?) -> Alamofire.Request {
        let request = manager.request(URLRequest).validate()
//        #if DEBUG
        println("Request:\n\(request.debugDescription)")
//        #endif
        if let validation = validation {
            return request.validate(validation)
        } else {
            return request.validate()
        }
    }
}


private extension Alamofire.Request {
    
    //MARK: - Custom serializer -
    class func CustomResponseSerializer<T>(mapping:AnyObject? -> T?) -> GenericResponseSerializer<Box<T>> {
        return GenericResponseSerializer { request, response, data in
            let JSONSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
            let (json: AnyObject?, serializationError) = JSONSerializer.serializeResponse(request, response, data)
            switch (response, json, serializationError) {
            case (.None, _, _):
                return (nil, NetworkDataProvider.ErrorCodes.TransferError.error())
            case (_, _, .Some(let error)):
                return (nil, NetworkDataProvider.ErrorCodes.ParsingError.error(underlyingError: error))
            default:
                if let object  = mapping(json) {
                    return (Box(object), nil)
                } else {
                    return (nil, NetworkDataProvider.ErrorCodes.InvalidResponseError.error())
                }
            } // switch
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
        public static let errorDomain = "com.bekitzur.Network"
        
        case UnknownError, InvalidRequestError, TransferError, InvalidResponseError, ParsingError, InvalidSessionError
        
        /**
        Trying to construct Error code from NSError
        
        :param: error NSError instance
        
        :returns: Error code or nil
        */
        public static func fromError(error: NSError) -> ErrorCodes? {
            if error.domain == ErrorCodes.errorDomain {
                return ErrorCodes(rawValue: error.code)
            }
            return nil
        }
        
        /**
        Converting Error code to the NSError
        
        :param: underlyingError underlying error
        
        :returns: NSError instance
        */
        public func error(underlyingError: NSError? = nil) -> NSError {
            let description = NSString(format: NSLocalizedString("Network error: %@", comment: "Localized network error description"),
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
            filename = name.stringByAppendingPathExtension(fileExtension) ?? name
        }
    }
    
    /**
    Uploads a files
    
    :param: URLRequest url request
    :param: urls       files info
    
    :returns: Request future
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
                        //Success(request: Request, streamingFromDisk: Bool, streamFileURL: NSURL?)
                    case .Success(let upload, let streamingFromDisk, let streamFileURL):
                        println("Request:\n\(upload.debugDescription)")
                        
                        upload.validate(statusCode: [201]).responseJSON { request, response, JSON, uploadError in
                            if let error = uploadError {
                                p.failure(error)
                            } else {
                                p.success(JSON)
                            }
                        }
                    case .Failure(let encodingError):
                        p.failure(encodingError)
                    }
            })
            return p.future
    }
}

private func copyTag(tag: CFString!, fromUTI dataUTI: String, #defaultValue: String) -> String {
    var str = UTTypeCopyPreferredTagWithClass(dataUTI, tag)
    if (str == nil) {
        return defaultValue
    } else {
        return str.takeUnretainedValue() as String
    }
}