//
//  RootViewController.swift
//  XMWorkArea
//
//  Created by 徐一丁 on 2020/5/18.
//  Copyright © 2020 徐一丁. All rights reserved.
//

import UIKit

///DEMO 入口
class RootViewController: UIViewController {
    
    //MARK: Interface
    
    struct CellInfo {
        var name: String
        
        enum Modal {
            case push
            case present
        }
        var modal: Modal = .push
    }
    private let cells: [CellInfo] = [.init(name: "VideoScanViewController"),
                                     .init(name: "AlbumViewController"),
                                     .init(name: "AVCamViewController")
                                     ]
    
    //MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadViewsForRoot(box: view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "Work Area"
    }
    
    //MARK: View
    
    override func viewDidLayoutSubviews() {
        tableView.frame = view.bounds
    }
    
    private func loadViewsForRoot(box: UIView) {
        box.addSubview(tableView)
    }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 44.0
        tableView.register(Cell.self, forCellReuseIdentifier: "Cell")
        return tableView
    }()
    
    //MARK: Sub Class
    
    @objc(RootViewControllerCell)
    class Cell: UITableViewCell {
        
        //MARK: Interface
        
        func configCell(data: CellInfo) {
            titleLabel.text = data.name
        }
        
        //MARK: Life Cycle
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            self.selectionStyle = .none
            
            loadViewsForCell(box: contentView)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        //MARK: View
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            titleLabel.frame = CGRect(x: 16.0,
                                      y: 0,
                                      width: contentView.bounds.width - 32.0,
                                      height: 44.0)
            singleLine.frame = CGRect(x: 0,
                                      y: contentView.bounds.height - 0.5,
                                      width: contentView.bounds.width,
                                      height: 0.5)
        }
        
        private func loadViewsForCell(box: UIView) {
            box.addSubview(titleLabel)
            box.addSubview(singleLine)
        }
        
        private lazy var titleLabel: UILabel = {
            let titleLabel = UILabel()
            titleLabel.font = UIFont.systemFont(ofSize: 15.0, weight: .regular)
            titleLabel.textColor = .darkGray
            titleLabel.text = " "
            titleLabel.numberOfLines = 0
            return titleLabel
        }()
        
        private lazy var singleLine: UIView = {
            let singleLine = UIView()
            singleLine.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
            return singleLine
        }()
        
    }
    
}

extension RootViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellInfo = cells[indexPath.row]
        let projName = Bundle.main.infoDictionary?[kCFBundleExecutableKey as String]
        let type = NSClassFromString("\(projName ?? "").\(cellInfo.name)") as? UIViewController.Type
        guard let vc = type?.init() else {
            return
        }
        
        switch cellInfo.name {
//        case "ClueManagerGuideAlertController":
//            let guideVC = vc as? ClueManagerGuideAlertController
//            guideVC?.configData(with: .saleManager)
        default:
            break
        }
        
        switch cellInfo.modal {
        case .push:
            navigationController?.pushViewController(vc, animated: true)
        case .present:
            present(vc, animated: true, completion: nil)
        }
    }
}

extension RootViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? Cell
        cell?.configCell(data: cells[indexPath.row])
        return cell ?? UITableViewCell()
    }
}


