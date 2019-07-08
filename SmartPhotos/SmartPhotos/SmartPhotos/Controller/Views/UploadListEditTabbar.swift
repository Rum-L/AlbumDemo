//
//  PhotosListEditTabbar.swift
//  Smart Photos
//
//  Created by 林铭杰 on 2019/5/8.
//  Copyright © 2019 林铭杰. All rights reserved.
//

import UIKit

protocol EditableUploadList: class {
    var isCreateButtonEnabled: Bool { get }
    var isUploadButtonEnabled: Bool { get }

    func onCreateButtonTap()
    func onUploadButtonTap()
}

class UploadListEditTabbar: UIView {
    weak var delegate: EditableUploadList?

    @IBOutlet weak var createButton: UIButton! {
        didSet {
            createButton.setTitle("生成分类相册".localized(), for: .normal)
        }
    }
    @IBOutlet weak var uploadButton: UIButton! {
        didSet {
            uploadButton.setTitle("上传".localized(), for: .normal)
        }
    }

    @IBAction func createButtonTap(_ sender: UIButton) {
        delegate?.onCreateButtonTap()
    }

    @IBAction func uploadButtonTap(_ sender: UIButton) {
        delegate?.onUploadButtonTap()
    }

    func toggleButtonsAvailability() {
        createButton.isEnabled = delegate?.isCreateButtonEnabled ?? false
        uploadButton.isEnabled = delegate?.isUploadButtonEnabled ?? false
    }
}
