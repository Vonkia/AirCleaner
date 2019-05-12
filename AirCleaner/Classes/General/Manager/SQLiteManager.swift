//
//  SQLiteManager.swift
//  AirCleaner
//
//  Created by vonkia on 2017/10/7.
//  Copyright © 2017年 vonkia. All rights reserved.
//
import UIKit
import SQLite

// MARK: - 数据库管理类
enum SQLiteManager: String {
    case dataCaches = "默认表"
    case deviceCaches = "设备表"
    
    /// 私有的数据库单例
    private var manager: FPSQLiteManager {
        return FPSQLiteManager.shared
    }
    
    //插入数据
    public func insertData(object: Any?) {
        do {
            switch self {
            case .dataCaches:
                guard let obj = object as? SQLCacheModel else { return }
                try manager.db.run(manager.dataCaches
                    .insert(or: .replace,
                            manager.key <- obj.key,
                            manager.content <- obj.content))
           
            case .deviceCaches:
                guard let obj = object as? ACDeviceModel else { return }
                try manager.db.run(manager.deviceCaches
                    .insert(or: .replace,
                            manager.type <- obj.type,
                            manager.marker <- obj.marker,
                            manager.num <- obj.num,
                            manager.password <- obj.password,
                            manager.isUse <- obj.isUse))
            }
        } catch { DLog(error) }
    }
    
    //批量插入数据
    public func insertData(args: [Any]?) {
        do {
            try manager.db.transaction {
                switch self {
                case .dataCaches:
                    guard let objArr = args as? [SQLCacheModel] else { return }
                    for obj in objArr {
                        try manager.db.run(manager.dataCaches
                            .insert(or: .replace,
                                    manager.key <- obj.key,
                                    manager.content <- obj.content))
                    }

                case .deviceCaches:
                    guard let objArr = args as? [ACDeviceModel] else { return }
                    for obj in objArr {
                        try manager.db.run(manager.deviceCaches
                            .insert(or: .replace,
                                    manager.type <- obj.type,
                                    manager.marker <- obj.marker,
                                    manager.num <- obj.num,
                                    manager.password <- obj.password,
                                    manager.isUse <- obj.isUse))
                    }
                }
            }
        } catch { DLog(error) }
    }
    
    //读取全部数据
    public func readData() -> [Any] {
        var objArr = Array<Any>()
        do {
            switch self {
            case .dataCaches:
                let resultArr = try manager.db.prepare(manager.dataCaches)
                for item in resultArr {
                    let obj = SQLCacheModel(key: item[manager.key],
                                            content: item[manager.content])
                    objArr.append(obj)
                }
                
            case .deviceCaches:
                let resultArr = try manager.db.prepare(manager.deviceCaches)
                for item in resultArr {
                    let obj = ACDeviceModel(num: item[manager.num],
                                            type: item[manager.type],
                                            marker: item[manager.marker],
                                            password: item[manager.password],
                                            isUse: item[manager.isUse])
                    objArr.append(obj)
                }
            }
        } catch { DLog(error) }
        return objArr
    }
    
    //读取数据
    public func readData(_key: String) -> Any? {
        do {
            switch self {
            case .dataCaches:
                guard let result = Array(try manager.db.prepare(manager.dataCaches.filter(manager.key == _key))).first else { return nil }
                return SQLCacheModel(key: result[manager.key],
                                     content: result[manager.content])
                
            case .deviceCaches:
                guard let result = Array(try manager.db.prepare(manager.deviceCaches.filter(manager.num == _key))).first else { return nil }
                return ACDeviceModel(num: result[manager.num],
                                     type: result[manager.type],
                                     marker: result[manager.marker],
                                     password: result[manager.password],
                                     isUse: result[manager.isUse])
            }
        } catch { DLog(error) }
        return nil
    }
    
    //更新数据
    public func updateData(object: Any) {
        do {
            switch self {
            case .dataCaches:
                guard let obj = object as? SQLCacheModel else { return }
                let result = manager.dataCaches.filter(manager.key == obj.key)
                try manager.db.run(result.update(manager.content <- obj.content))
                
            case .deviceCaches:
                guard let obj = object as? ACDeviceModel else { return }
                let result = manager.deviceCaches.filter(manager.num == obj.num)
                try manager.db.run(result.update(manager.type <- obj.type,
                                                 manager.marker <- obj.marker,
                                                 manager.password <- obj.password,
                                                 manager.isUse <- obj.isUse))
            }
        } catch { DLog(error) }
    }
    
    //删除数据
    public func delData(_key: String? = nil) {
        do {
            switch self {
            case .dataCaches:
                if _key == nil {
                    try manager.db.run(manager.dataCaches.delete())
                } else {
                    let result = manager.dataCaches.filter(manager.key == _key!)
                    try manager.db.run(result.delete())
                }
                
            case .deviceCaches:
                if _key == nil {
                    try manager.db.run(manager.deviceCaches.delete())
                } else {
                    let result = manager.deviceCaches.filter(manager.num == _key!)
                    try manager.db.run(result.delete())
                }
            }
        } catch { DLog(error) }
    }
}

// MARK: - 数据库管理类(扩展)
extension SQLiteManager {
    //读取数据
    public func getUseDevice() -> ACDeviceModel? {
        do {
            guard let result = Array(try manager.db.prepare(manager.deviceCaches.filter(manager.isUse == true))).first else { return nil }
            return ACDeviceModel(num: result[manager.num],
                                 type: result[manager.type],
                                 marker: result[manager.marker],
                                 password: result[manager.password],
                                 isUse: result[manager.isUse])
        } catch { DLog(error) }
        return nil
    }
    
    //修改设备字段isUse = false
    public func updateDeviceIsUseField() {
        do {
            try manager.db.run(manager.deviceCaches.update(manager.isUse <- false))
        } catch { DLog(error) }
    }
}


// MARK: - 数据库管理基类
fileprivate class FPSQLiteManager {
    // 单例
    static let shared = FPSQLiteManager()
    var db: Connection!
    
    // 默认时间
    private let date = Expression<Date?>("DATE") //时间
    // 默认表
    fileprivate let dataCaches = Table("DATACACHE_TABLE") //表名
    fileprivate let key = Expression<String>("KEY") //key
    fileprivate let content = Expression<String>("CONTENT") //内容
    // 设备表
    fileprivate let deviceCaches = Table("DEVICECACHE_TABLE") //表名
    fileprivate let type = Expression<String>("TYPE") /// 设备类型
    fileprivate let marker = Expression<String>("MARKER") //设备型号
    fileprivate let num = Expression<String>("NUM") //设备序列号
    fileprivate let password = Expression<String>("PASSWORD") //设备密码
    fileprivate let isUse = Expression<Bool>("ISUSE") //是否是当前使用的设备
    
    
    private init(fileName: String = "AirCleaner.sqlite3") {
        createdsqlite3(fileName: fileName)
    }
    
    //创建数据库文件
    private func createdsqlite3(fileName: String)  {
        let sqlFilePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/\(fileName)"
        if !FileManager.default.fileExists(atPath: sqlFilePath) {
            FileManager.default.createFile(atPath: sqlFilePath, contents: nil, attributes: nil)
            DLog("Create db file success-\(sqlFilePath)")
        } else {
            DLog("Open db file success-\(sqlFilePath)")
        }

        do {
            db = try Connection(sqlFilePath)
            // 默认表
            try db.run(dataCaches.create { t in
                t.column(key, primaryKey: true)
                t.column(content)
                t.column(date, defaultValue: DateFunctions.datetime("now"))
            })
            // 设备表
            try db.run(deviceCaches.create { t in
                t.column(num, primaryKey: true)
                t.column(type)
                t.column(marker)
                t.column(password)
                t.column(isUse)
                t.column(date, defaultValue: DateFunctions.datetime("now"))
            })
        } catch { /* DLog(error) */ }
    }
}

// MARK: - 数据库缓存对象类
class SQLCacheModel: NSObject {
    /// key
    var key: String
    /// 内容
    var content: String
    
    public init(key: String, content: String) {
        self.key = key
        self.content = content
    }
}
