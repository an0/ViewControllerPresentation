//
//  ViewController.swift
//  ViewControllPresentation
//
//  Created by Ling Wang on 6/18/19.
//  Copyright © 2019 Moke. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private var level = 0

    @IBOutlet weak var label: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        switch presentingViewController {
        case let vc as ViewController:
            level = vc.level + 1

        case let navController as UINavigationController:
            level = (navController.topViewController as! ViewController).level + 1

        default:
            level = 0
        }

        title = "\(level). \((navigationController?.modalPresentationStyle ?? .none).description)"
        label.text = title
        view.backgroundColor = UIColor.random
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismiss(_:)))
    }
    
    @IBAction func present(_ sender: UIBarButtonItem) {
        guard let vc = storyboard?.instantiateInitialViewController() else {
            return
        }

        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = UIModalPresentationStyle(sender.title!)!
        if navController.modalPresentationStyle == .popover {
            navController.popoverPresentationController?.barButtonItem = sender
            if sender.title!.hasSuffix("!") {
                navController.popoverPresentationController?.delegate = self
            }
        }
        present(navController, animated: true)
    }

    @IBAction func dismiss(_ sender: Any) {
        dismiss(animated: true)
    }

}

extension ViewController: UIPopoverPresentationControllerDelegate {

    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }

}

extension UIModalPresentationStyle: LosslessStringConvertible {

    public var description: String {
        switch self {
        case .automatic:
            return "automatic"

        case .currentContext:
            return "currentContext"

        case .custom:
            return "custom"

        case .formSheet:
            return "formSheet"

        case .fullScreen:
            return "fullScreen"

        case .none:
            return "none"

        case .overCurrentContext:
            return "overCurrentContext"

        case .overFullScreen:
            return "overFullScreen"

        case .pageSheet:
            return "pageSheet"

        case .popover:
            return "popover"

        @unknown default:
            fatalError()
        }
    }

    public init?(_ description: String) {
        switch description {
        case "automatic":
            self = .automatic

        case "currentContext":
            self = .currentContext

        case "custom":
            self = .custom

        case "formSheet":
            self = .formSheet

        case "fullScreen":
            self = .fullScreen

        case "none":
            self = .none

        case "overCurrentContext":
            self = .overCurrentContext

        case "overFullScreen":
            self = .overFullScreen

        case "pageSheet":
            self = .pageSheet

        case "popover", "popover!":
            self = .popover

        default:
            return nil
        }
    }

}

extension UIColor {

    static var random: UIColor {
        UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 0.7)
    }

}
