//
//  CommonTypes.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 16/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation

/**
*  Functor's fmap
*/
infix operator <^> { associativity left } //

public func <^><A, B>(f: A -> B, a: A?) -> B? {
    if let x = a {
        return f(x)
    } else {
        return .None
    }
}

/**
*  Applicative's apply operator
*/
infix operator <*> { associativity left }

public func <*><A, B>(f: (A -> B)?, a: A?) -> B? {
    if let x = a {
        if let fx = f {
            return fx(x)
        }
    }
    return .None
}

/**
*  Generic wrapper, used in OperationResult because of the enum limitations
*/
public final class Box<A> {
    let unbox: A
    public init(_ value: A) { self.unbox = value }
}

/**
Common operation result enum

- Failure: Contains operation error
- Success: Contains operation result
*/
public enum OperationResult<T> {
    /// operation error
    case Failure(NSError)
    /// operation result
    case Success(Box<T>)
    /// result value if exist
    public var value: T! {
        switch (self) {
        case .Success(let box):
            return box.unbox
        default:
            return nil
        }
    }
}

/**
Shortcut for creating OperationResult

:param: value operation value

:returns: new OperationResult.Success value
*/
public func success<T>(value:T) -> OperationResult<T> {
    return .Success(Box(value))
}

/**
Shortcut for creating OperationResult

:param: error operation

:returns: new OperationResult.Failure value
*/
public func failure<T>(error: NSError) -> OperationResult<T> {
    return .Failure(error)
}
