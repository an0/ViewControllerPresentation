//
//  ColorPickerController.swift
//  Annotable
//
//  Created by Ling Wang on 2/24/17.
//  Copyright © 2017 Moke. All rights reserved.
//

import UIKit

class ColorPickerController: UIViewController {

    private class ColorPickerView: UIView {

        private class ColorSlider: UIView {

            init() {
                sliderControl = SliderControl()

                super.init(frame: .zero)

                addSubview(sliderControl)
            }

            required init?(coder aDecoder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }

            private let sliderControl: SliderControl

            var thumbSize: CGFloat {
                get {
                    return sliderControl.thumbSize
                }

                set {
                    sliderControl.thumbSize = newValue
                    invalidateIntrinsicContentSize()
                    setNeedsLayout()
                }
            }

            override var intrinsicContentSize: CGSize {
                return CGSize(width: thumbSize, height: UIView.noIntrinsicMetric)
            }

            override func layoutSubviews() {
                super.layoutSubviews()

                sliderControl.frame = CGRect(center: bounds.center, size: CGSize(width: thumbSize, height: bounds.height))
            }

            override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
                return sliderControl.point(inside: convert(point, to: sliderControl), with: event)
            }

            private class SliderControl: UIControl {

                init() {
                    track = UIView()
                    track.backgroundColor = .black
                    thumb = Thumb(frame: CGRect(origin: .zero, size: CGSize(width: thumbSize, height: thumbSize)))

                    super.init(frame: .zero)

                    addSubview(track)
                    addSubview(thumb)
                }

                required init?(coder aDecoder: NSCoder) {
                    fatalError("init(coder:) has not been implemented")
                }

                private let track: UIView
                private let thumb: UIView

                var thumbSize: CGFloat = 30 {
                    didSet {
                        thumb.bounds = CGRect(origin: .zero, size: CGSize(width: thumbSize, height: thumbSize))
                        invalidateIntrinsicContentSize()
                    }
                }

                override var intrinsicContentSize: CGSize {
                    return CGSize(width: thumbSize, height: UIView.noIntrinsicMetric)
                }

                // MARK: Layout

                private func trackRect(forBounds bounds: CGRect) -> CGRect {
                    return CGRect(center: bounds.center, size: CGSize(width: thumb.frame.width / 2, height: bounds.height - thumb.frame.height))
                }

                override func layoutSubviews() {
                    let trackRect = self.trackRect(forBounds: bounds)
                    track.frame = trackRect
                }

                // MARK: Interactions

                private var isSliding = false

                private func locationOnTrack(location: CGPoint) -> CGPoint {
                    let trackRect = self.trackRect(forBounds: bounds)
                    return CGPoint(x: trackRect.midX, y: location.limited(in: trackRect).y)
                }

                override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
                    return thumb.point(inside: convert(point, to: thumb), with: event) || bounds.contains(point)
                }

                override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
                    print("touchesBegan")

                    guard touches.count == 1, let touch = touches.first else {
                        // Only handle single touch.
                        return
                    }

                    guard let hitView = hitTest(touch.location(in: self), with: event) else {
                        return
                    }

                    if thumb == hitView {
                        isSliding = true
                        thumb.center = locationOnTrack(location: touch.location(in: self))
                    }
                }

                override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
                    print("touchesMoved")

                    guard touches.count == 1, let touch = touches.first else {
                        // Only handle single touch.
                        return
                    }

                    guard isSliding else { return }

                    thumb.center = locationOnTrack(location: touch.location(in: self))
                }

                override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
                    print("touchesEnded")

                    isSliding = false
                }

                override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
                    print("touchesCancelled")

                    isSliding = false
                }

                private class Thumb: UIView {

                    override init(frame: CGRect) {
                        super.init(frame: frame)

                        backgroundColor = .green
                        layer.cornerRadius = bounds.width / 2
                    }

                    required init?(coder aDecoder: NSCoder) {
                        fatalError("init(coder:) has not been implemented")
                    }

                    override var bounds: CGRect {
                        didSet {
                            guard bounds.size != oldValue.size else { return }

                            layer.cornerRadius = bounds.width / 2
                        }
                    }

                }

            }

        }

        private let greenSlider: ColorSlider

        init() {
            greenSlider = ColorSlider()

            super.init(frame: .zero)

            preservesSuperviewLayoutMargins = true

            addSubview(greenSlider)
            greenSlider.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                greenSlider.centerXAnchor.constraint(equalTo: centerXAnchor),
                greenSlider.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
                greenSlider.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
                ])
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

    }

    private var colorPickerView: ColorPickerView!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        colorPickerView = ColorPickerView()
        view.addSubview(colorPickerView)
        colorPickerView.translatesAutoresizingMaskIntoConstraints = false
        colorPickerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        colorPickerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        colorPickerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        colorPickerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismiss(_:)))
    }

    @IBAction func dismiss(_ sender: Any) {
        dismiss(animated: true)
    }

}

extension CGRect {

    init(center: CGPoint, size: CGSize) {
        self.init(x: center.x - size.width / 2, y: center.y - size.height / 2, width: size.width, height: size.height)
    }

    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }

}


public extension CGPoint {

    func limited(in rect: CGRect) -> CGPoint {
        guard !rect.isNull else { return self }
        return CGPoint(x: min(max(x, rect.minX), rect.maxX), y: min(max(y, rect.minY), rect.maxY))
    }

}
