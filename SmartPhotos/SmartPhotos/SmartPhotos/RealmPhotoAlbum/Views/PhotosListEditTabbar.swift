//
//  PhotosListEditTabbar.swift
//  Smart Photos
//
//  Created by 林铭杰 on 2019/4/13.
//  Copyright © 2019 林铭杰. All rights reserved.
//

import UIKit

protocol EditablePhotosList: class {
    var isDeleteButtonEnabled: Bool { get }
    var isMoveButtonEnabled: Bool { get }

    func onDeleteButtonTap()
    func onMoveButtonTap()
}

class PhotosListEditTabbar: UIView {
    weak var delegate: EditablePhotosList?

    @IBOutlet weak var deleteButton: UIButton! {
        didSet {
            deleteButton.setTitle("Delete".localized(), for: .normal)
        }
    }
    @IBOutlet weak var moveButton: UIButton! {
        didSet {
            moveButton.setTitle("Move".localized(), for: .normal)
        }
    }

    @IBAction func deleteButtonTap(_ sender: UIButton) {
        delegate?.onDeleteButtonTap()
    }

    @IBAction func moveButtonTap(_ sender: UIButton) {
        delegate?.onMoveButtonTap()
    }

    func toggleButtonsAvailability() {
        deleteButton.isEnabled = delegate?.isDeleteButtonEnabled ?? false
        moveButton.isEnabled = delegate?.isMoveButtonEnabled ?? false
    }
}
