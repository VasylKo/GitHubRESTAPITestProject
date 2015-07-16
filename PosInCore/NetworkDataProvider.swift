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

public class NetworkDataProvider: NSObject {
    /**
    Execute request and parse response
    
    :param: URLRequest The URL request
    :param: map        Response mapping function
    :param: completion Completion block
    
    :returns: The created request
    */
    public  func jsonRequest<U,V>(
        URLRequest: Alamofire.URLRequestConvertible,
        map: AnyObject?->U?,
        completion: (OperationResult<V>)->Void
        ) -> Alamofire.Request {
            
            let serializer = Alamofire.Request.CustomResponseSerializer(map)
            activityIndicator.increment()
            let r = request(URLRequest).response(serializer: serializer, completionHandler: {
                [unowned self] (request, response, object, error) in
                self.activityIndicator.decrement()
                if let object = object as? Box<V> {
                    completion(.Success(object))
                } else {
                    completion(failure(error ?? ErrorCodes.InvalidResponseError.error()))
                }
                })
            
            return r
    }
    
    /**
    Execute request and parse single object
    
    :param: URLRequest The URL request
    :param: completion Completion block
    
    :returns: The created request
    */
    public func objectRequest<T: Mappable>(
        URLRequest: Alamofire.URLRequestConvertible,
        completion: (OperationResult<T>)->Void
        ) -> Alamofire.Request {
            let mapping: AnyObject? -> T? = { json in
                return Mapper<T>().map(json)
            }
            return jsonRequest(URLRequest, map: mapping, completion: completion)
    }
    
    /**
    Execute request and parse multiple objects
    
    :param: URLRequest The URL request
    :param: completion Completion block
    
    :returns: The created request
    */
    public func arrayRequest<T: Mappable>(
        URLRequest: Alamofire.URLRequestConvertible,
        completion: (OperationResult<[T]>)->Void
        ) -> Alamofire.Request {
            let mapping: AnyObject? -> [T]? = { json in
                return Mapper<T>().mapArray((json))
            }
            return jsonRequest(URLRequest, map: mapping, completion: completion)
    }

    
    /// Used API
    public let apiService: APIService
    
    
    /**
    Designated initializer
    
    :param: api           api service
    :param: configuration session configuration
    
    :returns: new instance
    */
    public init(
        api: APIService,
        configuration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        ) {
            apiService = api
            manager = Alamofire.Manager(configuration: configuration)
    }
    
    /// Singleton instance
//    public class var sharedInstance: NetworkDataProvider {
//        struct Static {
//            static var onceToken: dispatch_once_t = 0
//            static var instance: NetworkDataProvider? = nil
//        }
//        dispatch_once(&Static.onceToken) {
//            Static.instance = NetworkDataProvider(api: .Dev)
//        }
//        return Static.instance!
//    }

    private let manager: Alamofire.Manager
    private let activityIndicator = NetworkActivityIndicatorManager()
    
    internal func request(URLRequest: Alamofire.URLRequestConvertible) -> Alamofire.Request {
        let request = manager.request(URLRequest).validate()
        
        #if DEBUG
            println(request.debugDescription)
        #endif
        
        return request
    }
}

/**
 Protocol that wrap url generation
*/
public protocol APIService: Printable {
    /**
    Returns http request string
    
    :param: endpoint       endpoint
    
    :returns: url string
    */
    func http(endpoint: String) -> String
    /**
    Returns http request string
    
    :param: endpoint       endpoint
    
    :returns: url string
    */
    func https(endpoint: String) -> String
}


private extension Alamofire.Request {
    
    //MARK: - Custom serializer -
    class func CustomResponseSerializer<T>(mapping:AnyObject? -> T?) -> Serializer {
        
        return { (request, response, data) in
            let JSONSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
            let (json: AnyObject?, serializationError) = JSONSerializer(request, response, data)
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

//MARK: - Network errors -

extension NetworkDataProvider {
    /**
    Network error codes
    
    - UnknownError:    Unknown error
    - InvalidRequestError:  Invalid request error
    - TransferError:   Transfer error
    - InvalidResponseError: Invalid response error
    - ParsingError:    Response Parsing error
    */
    enum ErrorCodes: Int {
        static let errorDomain = "com.bekitzur.Network"
        
        case UnknownError, InvalidRequestError, TransferError, InvalidResponseError, ParsingError
        
        /**
        Converting Error code to the NSError
        
        :param: underlyingError underlying error
        
        :returns: NSError instance
        */
        func error(underlyingError: NSError? = nil) -> NSError {
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
            case .UnknownError:
                fallthrough
            default:
                return NSLocalizedString("UnknownError", comment: "Unknown error")
            }
        }
    }
}
