//
//  LLHomeViewModel.swift
//  LLProgramFrameworkSwift
//
//  Created by 奥卡姆 on 2017/9/6.
//  Copyright © 2017年 aokamu. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Moya
import Alamofire
import MJRefresh

let cellID = "LLHomeCellID"

class LLHomeViewModel: BaseViewModel {
    
    var modelObserable = Variable<[StoryModel]> ([])
    var tableV = UITableView()
    
    public func setConfig() {
        //MARK: Rx 绑定tableView数据
        modelObserable.asObservable()
            .bind(to: tableV.rx.items(cellIdentifier: cellID, cellType: LLHomeCell.self)){ row , model , cell in
                cell.titleLbl.text = model.title
                cell.imageV?.kf.setImage(with: URL.init(string: (model.images?.count)! > 0 ? (model.images?.first)! : ""))
            }.disposed(by: bag)
        
        requestNewDataCommond.subscribe { (event : Event<Bool>) in
            if event.element! {
                // 假装在请求第一页
                self.pageIndex = 0
                self.provider
                    .rx.request(.GetHomeList)
                    .filterSuccessfulStatusCodes()
                    .asObservable()
                    .mapJSON()
                    .mapObject(type: LLHomeModel.self).subscribe(onNext: { (model) in
                        self.modelObserable.value = model.stories!
                        self.refreshStateObserable.value = .endHeaderRefresh
                    }, onError: { (error) in
                        self.refreshStateObserable.value = .endHeaderRefresh
                    }).disposed(by: self.bag)
            } else {
                //  假装请求第二页数据
                self.pageIndex += 1
                self.provider
                    .rx.request(.GetHomeList)
                    .filterSuccessfulStatusCodes()
                    .asObservable()
                    .mapJSON()
                    .mapObject(type: LLHomeModel.self).subscribe(onNext: { (model) in
                        self.modelObserable.value += model.stories!
                        self.refreshStateObserable.value = self.pageIndex > 3 ? .noMoreData : .endFooterRefresh
                    }, onError: { (error) in
                        self.refreshStateObserable.value = .endHeaderRefresh
                    }).disposed(by: self.bag)
            }
        }.disposed(by: bag)
        
        refreshStateObserable.asObservable().subscribe(onNext: { (state) in
            switch state{
            case .beginHeaderRefresh:
                self.tableV.mj_header.beginRefreshing()
            case .endHeaderRefresh:
                self.tableV.mj_header.endRefreshing()
                self.tableV.mj_footer.resetNoMoreData()
            case .beginFooterRefresh:
                self.tableV.mj_footer.beginRefreshing()
            case .endFooterRefresh:
                self.tableV.mj_footer.endRefreshing()
            case .noMoreData:
                self.tableV.mj_footer.endRefreshingWithNoMoreData()
            default:
                break
            }
        }).disposed(by: bag)
    }
}
