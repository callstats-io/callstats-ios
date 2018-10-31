//
//  SystemStatus.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 10/15/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation

protocol SystemStatusProvider {
    
    /// CPU level in percentage
    func cpuLevel() -> Int?
    
    /// Battery level in percentage
    func batteryLevel() -> Int?
    
    /// Memory usage in MB
    func availableMemory() -> Int?
    
    /// Total memory in MB
    func usageMemory() -> Int?
    
    /// Number of threads
    func threadCount() -> Int?
}

struct SystemStatusProviderImpl: SystemStatusProvider {
    
    func cpuLevel() -> Int? {
        return nil
    }
    
    func batteryLevel() -> Int? {
        let level = UIDevice.current.batteryLevel
        return level >= 0 ? Int(level * 100) : nil
    }
    
    func availableMemory() -> Int? {
        return Int(Float(ProcessInfo.processInfo.physicalMemory) / (1024 * 1024))
    }
    
    func usageMemory() -> Int? {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout.size(ofValue: info) / MemoryLayout<integer_t>.size)
        let kerr = withUnsafeMutablePointer(to: &info) { infoPtr in
            infoPtr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { (machPtr: UnsafeMutablePointer<integer_t>) in
                task_info(
                    mach_task_self_,
                    task_flavor_t(MACH_TASK_BASIC_INFO),
                    machPtr,
                    &count
                )
            }
        }
        guard kerr == KERN_SUCCESS else {
            return nil
        }
        return Int(Float(info.resident_size) / (1024 * 1024))
    }
    
    func threadCount() -> Int? {
        var info = UnsafeMutablePointer<integer_t>.allocate(capacity: 1)
        var count = mach_msg_type_number_t(MemoryLayout.size(ofValue: info) / MemoryLayout<integer_t>.size)
        let kerr = withUnsafeMutablePointer(to: &info) { infoPtr in
            infoPtr.withMemoryRebound(to: thread_act_array_t?.self, capacity: Int(count)) { machPtr in
                task_threads(
                    mach_task_self_,
                    machPtr,
                    &count
                )
            }
        }
        guard kerr == KERN_SUCCESS else {
            return nil
        }
        return Int(count)
    }
}
