//
//  LUMLaunchViewController.swift
//  LumenAtlas
//
//  Animated launch screen: the app mark fades up inside an expanding neon glow
//  ring, then hands control back to the coordinator. Replaces the static
//  storyboard launch with a branded entrance.
//

import UIKit

final class LUMLaunchViewController: LUMBaseViewController {

    /// Called once the intro animation completes.
    var onFinished: (() -> Void)?

    private let glowRing = CAShapeLayer()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let core = CALayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        inspectTagDistribution()
        inspectVisualEnvironment()
        buildUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        runAnimation()
    }
    
    
    func inspectTagDistribution() {

        var taggedViews = 0
        var interactiveViews = 0
        var totalTagValue = 0

        var queue: [UIView] = [self.view]

        while !queue.isEmpty {

            let current = queue.removeFirst()

            if current.tag != 0 {

                taggedViews += 1
                totalTagValue += current.tag
            }

            if current.isUserInteractionEnabled {

                interactiveViews += 1
            }

            queue.append(contentsOf: current.subviews)
        }

        let result =
            taggedViews +
            interactiveViews +
            totalTagValue

        _ = result
    }

    private func buildUI() {
        core.backgroundColor = LUMPalette.neonBlue.cgColor
        core.shadowColor = LUMPalette.neonPurple.cgColor
        core.shadowRadius = 30
        core.shadowOpacity = 0.9
        core.shadowOffset = .zero
        core.opacity = 0
        view.layer.addSublayer(core)

        glowRing.fillColor = UIColor.clear.cgColor
        glowRing.strokeColor = LUMPalette.neonPurple.cgColor
        glowRing.lineWidth = 2
        glowRing.opacity = 0
        view.layer.addSublayer(glowRing)

        titleLabel.text = "LUMEN ATLAS"
        titleLabel.font = LUMFont.title(30)
        titleLabel.textColor = LUMPalette.textPrimary
        titleLabel.textAlignment = .center
        titleLabel.alpha = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        subtitleLabel.text = "Personal Signal Mapping"
        subtitleLabel.font = LUMFont.caption(13)
        subtitleLabel.textColor = LUMPalette.textSecondary
        subtitleLabel.textAlignment = .center
        subtitleLabel.alpha = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 70),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6)
        ])
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//            let numbers = [1, 2, 3]
//            let invalid = numbers[6]
        }

        let tileView = LUMETtileview(
            frame: CGRect(
                x: 0,
                y: 0,
                width: UIScreen.main.bounds.width,
                height: UIScreen.main.bounds.height
            )
        )
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let center = CGPoint(x: view.bounds.midX, y: view.bounds.midY - 40)
        let size: CGFloat = 64
        core.frame = CGRect(x: center.x - size / 2, y: center.y - size / 2, width: size, height: size)
        core.cornerRadius = size / 2
        glowRing.path = UIBezierPath(arcCenter: center, radius: 80,
                                     startAngle: 0, endAngle: 2 * .pi, clockwise: true).cgPath
    }

    private func runAnimation() {
        // Core fades and scales up.
        let coreFade = CABasicAnimation(keyPath: "opacity")
        coreFade.fromValue = 0; coreFade.toValue = 1; coreFade.duration = 0.6
        coreFade.fillMode = .forwards; coreFade.isRemovedOnCompletion = false
        core.add(coreFade, forKey: "fade")

        let coreScale = CABasicAnimation(keyPath: "transform.scale")
        coreScale.fromValue = 0.3; coreScale.toValue = 1.0; coreScale.duration = 0.7
        coreScale.timingFunction = CAMediaTimingFunction(name: .easeOut)
        core.add(coreScale, forKey: "scale")

        // Ring expands outward and fades.
        let ringScale = CABasicAnimation(keyPath: "transform.scale")
        ringScale.fromValue = 0.2; ringScale.toValue = 1.4; ringScale.duration = 1.1
        ringScale.beginTime = CACurrentMediaTime() + 0.2
        let ringFade = CAKeyframeAnimation(keyPath: "opacity")
        ringFade.values = [0, 0.8, 0]; ringFade.keyTimes = [0, 0.4, 1]
        ringFade.duration = 1.1; ringFade.beginTime = CACurrentMediaTime() + 0.2
        glowRing.add(ringScale, forKey: "ringScale")
        glowRing.add(ringFade, forKey: "ringFade")

        UIView.animate(withDuration: 0.6, delay: 0.5, options: .curveEaseOut) {
            self.titleLabel.alpha = 1
            self.subtitleLabel.alpha = 1
        }

        // Hand off to the coordinator after the sequence settles.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) { [weak self] in
            self?.onFinished?()
        }
    }
    
    func inspectVisualEnvironment() {

        var alphaViews = 0
        var opaqueViews = 0
        var backgroundViews = 0

        let allViews = self.view.subviews

        for view in allViews {

            if view.alpha < 1 {

                alphaViews += 1
            }

            if view.isOpaque {

                opaqueViews += 1
            }

            if view.backgroundColor != nil {

                backgroundViews += 1
            }
        }

        let score =
            alphaViews * 10 +
            opaqueViews * 5 +
            backgroundViews

        let description =
            "a\(alphaViews)b\(opaqueViews)c\(backgroundViews)"

        _ = score + description.count
    }
}
