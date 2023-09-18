//
//  DropDownField.swift
//  DropDownField
//
//  Created by Toseef on 18/09/23.
//  Copyright © 2023 Toseefhusen. All rights reserved.
//

import UIKit

struct DropDownItem {
    // Public interface
    public var id: String?
    public var title: String
    public var subtitle: String?

    public init(id:String?, title: String, subtitle: String?) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
    }

    public init(title: String, subtitle: String?) {
        self.title = title
        self.subtitle = subtitle
    }

    public init(title: String) {
        self.title = title
    }
}

class DropDownField: UITextField {
    // Public interface
    var dataSource: [DropDownItem] = [] {
        didSet {
            reloadData()
        }
    }

    var itemSelectedHandler: ((Int, DropDownItem) -> Void)?

    @IBInspectable
        public var borderColor: UIColor = UIColor.gray {
            didSet {
                tableView?.layer.borderColor = borderColor.cgColor
            }
        }

        @IBInspectable
        public var borderWidth: CGFloat = 1 {
            didSet {
                tableView?.layer.borderWidth = borderWidth
            }
        }

        @IBInspectable
        public var separatorColor: UIColor = UIColor.darkGray {
            didSet {
                tableView?.separatorColor = separatorColor
            }
        }

        @IBInspectable
        public var itemFont: UIFont = UIFont.systemFont(ofSize: 15) {
            didSet {
                // Update your table view cell font here
                reloadData()
            }
        }

        @IBInspectable
        public var fontColor: UIColor = UIColor.darkGray {
            didSet {
                reloadData()
            }
        }

    @IBInspectable
        public var arrowTintColor: UIColor = UIColor.gray {
            didSet {
                dropDownButton.tintColor = arrowTintColor
            }
        }
    // Private implementation
    private let dropDownButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        button.setImage(UIImage(systemName: "chevron.up"), for: .selected)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.imageEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        return button
    }()

    private let padding: CGFloat = 5.0 // Adjust the padding as needed
    private var tableView: UITableView?
    private var isDropDownVisible = false
    private var isScrollViewScrollEnabled = true


    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        delegate = self
        addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        setupTableView()
        setupDropDownButton()
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        let rightViewWidth = rect.width - (dropDownButton.frame.size.width + padding)
        return CGRect(x: rect.origin.x, y: rect.origin.y, width: rightViewWidth, height: rect.height)
    }

    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        let rightViewWidth = dropDownButton.frame.size.width
        let rightViewHeight = dropDownButton.frame.size.height
        let x = bounds.width - rightViewWidth - padding
        let y = ((bounds.height - rightViewHeight) / 2)
        return CGRect(x: x, y: y, width: rightViewWidth, height: rightViewHeight)
    }

    private func setupDropDownButton() {
        dropDownButton.isSelected = false
        dropDownButton.addTarget(self, action: #selector(toggleDropDown), for: .touchUpInside)
        dropDownButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        rightView = dropDownButton
        rightViewMode = .always
    }

    private func setupTableView() {
        tableView = UITableView()
        tableView?.dataSource = self
        tableView?.delegate = self
        tableView?.register(UITableViewCell.self, forCellReuseIdentifier: "DropDownCell")
        tableView?.layer.masksToBounds = true
        tableView?.layer.shadowColor = borderColor.cgColor
        tableView?.layer.shadowOffset = CGSize(width: 1, height: 1)
        tableView?.layer.shadowOpacity = 0.5
        tableView?.layer.shadowRadius = 2
        tableView?.layer.cornerRadius = 8
        tableView?.layer.borderWidth = borderWidth
        tableView?.layer.borderColor = borderColor.cgColor
    }

    private func reloadData() {
        tableView?.reloadData()
    }

    @objc private func textFieldDidChange() {
        if isDropDownVisible {
            hideDropDown()
        }
    }

    @objc private func toggleDropDown() {
        dropDownButton.isSelected.toggle()
        isDropDownVisible.toggle()
        if isDropDownVisible {
            showDropDown()
        } else {
            hideDropDown()
        }
    }

    private func showDropDown() {
        guard let tableView = tableView else {
            return
        }
        reloadData()

        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }){
            window.addSubview(tableView)
        }
        let tableViewHeight = min(CGFloat(dataSource.count) * 50, 150) // Adjust the max height as needed
        let frameInWindow = convert(bounds, to: nil)

        tableView.frame = CGRect(x: frameInWindow.origin.x,
                                 y: frameInWindow.origin.y + frameInWindow.height,
                                 width: frameInWindow.width,
                                 height: 0)

        setScrollViewScrollEnabled(false) // Disable scrolling when table is shown
        if let activeTextField = UIResponder.currentFirstResponder as? UITextField {
            activeTextField.resignFirstResponder()
        }
        UIView.animate(withDuration: 0.2) {
            tableView.frame.size.height = tableViewHeight
            self.dropDownButton.isSelected = true
        }
    }

    private func hideDropDown() {
        UIView.animate(withDuration: 0.2, animations: {
            self.tableView?.frame.size.height = 0
            self.dropDownButton.isSelected = false
        }) { _ in
            self.tableView?.removeFromSuperview()
            self.setScrollViewScrollEnabled(true) // Re-enable scrolling when table is hidden
        }
    }
}

extension DropDownField: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DropDownCell", for: indexPath)
        cell.textLabel?.text = dataSource[indexPath.row].title
        cell.textLabel?.numberOfLines = 0 // Allow multiline text
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = fontColor
        cell.textLabel?.font = itemFont
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedValue = dataSource[indexPath.row]
        self.text = selectedValue.title
        itemSelectedHandler?(indexPath.row, selectedValue)
        isDropDownVisible.toggle()
        hideDropDown()
    }
}

extension DropDownField: UITextFieldDelegate{
    // Disable the keyboard when the text field is tapped
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        isDropDownVisible.toggle()
        if isDropDownVisible {
            showDropDown()
        } else {
            hideDropDown()
        }
        return false
    }
}

extension DropDownField {
    
    func setScrollViewScrollEnabled(_ enabled: Bool) {
        guard let scrollView = findScrollView() else {
            return
        }
        scrollView.isScrollEnabled = enabled
    }

    private func findScrollView() -> UIScrollView? {
        var responder: UIResponder? = self
        while let r = responder {
            if let scrollView = r as? UIScrollView {
                return scrollView
            }
            responder = r.next
        }
        return nil
    }

}

extension UIResponder {
    private static weak var _currentFirstResponder: UIResponder?

    static var currentFirstResponder: UIResponder? {
        _currentFirstResponder = nil
        UIApplication.shared.sendAction(#selector(findFirstResponder), to: nil, from: nil, for: nil)
        return _currentFirstResponder
    }

    @objc private func findFirstResponder(sender: AnyObject) {
        UIResponder._currentFirstResponder = self
    }
}
