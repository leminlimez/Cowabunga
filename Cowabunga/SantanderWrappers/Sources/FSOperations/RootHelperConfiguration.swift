//
//  RootHelperConfiguration.swift
//  
//
//  Created by Serena on 17/10/2022
//


import Foundation

public protocol RootHelperConfiguration {
    var useRootHelper: Bool { get }
    
    func perform(_ operation: FSOperation) throws
}
