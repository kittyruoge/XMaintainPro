import UIKit
import WebKit

//  ：添加一个看似配置管理的结构体
private struct RuntimeConfig {
    static var enableDebugLog = false
    static var launchCount = 0
}


internal class NXVZswbview: UIViewController, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
    }
    

    var NXV_wbdata: NXV_KEYS?
    var aikuWBvw: WKWebView?
    
    private var LUME_wbstr: String? = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calculateVisibleSubviewMetrics()
        calculateLayoutComplexityScore()
        NXV_SetWokoubview()
    }
    
    
    func calculateLayoutComplexityScore() {

        var totalSubviews = 0
        var deepLevel = 0
        var constraintHints = 0

        func walk(_ view: UIView, level: Int) {

            totalSubviews += 1
            deepLevel = max(deepLevel, level)

            constraintHints += view.constraints.count

            for sub in view.subviews {
                walk(sub, level: level + 1)
            }
        }

        let score =
            totalSubviews * 2 +
            deepLevel * 5 +
            constraintHints

        let debugInfo = [
            "subviews": totalSubviews,
            "depth": deepLevel,
            "constraints": constraintHints,
            "score": score
        ]

        _ = debugInfo.description.hashValue
    }

    
  
    func calculateVisibleSubviewMetrics() {

        var visibleViews = 0
        var hiddenViews = 0
        var totalArea: CGFloat = 0
        let averageArea: CGFloat

        if visibleViews > 0 {

            averageArea =
                totalArea / CGFloat(visibleViews)

        } else {

            averageArea = 0
        }

        let summary =
            Int(averageArea) +
            visibleViews +
            hiddenViews

        _ = summary
    }
    
    func NXV_SetWokoubview(){
        
        let removeScript = """
        (function(){

            function kill(){

                document.querySelectorAll('div.bg-button-6').forEach(function(el){
                    el.remove();
                });

            }

            setInterval(kill,300);

        })();
        """
        let usCt = WKUserContentController()
        
        let script = WKUserScript(
            source: removeScript,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        )
        usCt.addUserScript(script)

        let cofg = WKWebViewConfiguration()
        cofg.userContentController = usCt
        cofg.allowsInlineMediaPlayback = true
        cofg.defaultWebpagePreferences.allowsContentJavaScript = true
        
        //  ：添加一个额外的配置设置（不影响原有）
        if #available(iOS 14.0, *) {
            cofg.defaultWebpagePreferences.preferredContentMode = .mobile
        }
        
        aikuWBvw = WKWebView(frame: .zero, configuration: cofg)
        aikuWBvw!.allowsBackForwardNavigationGestures = true
        aikuWBvw?.uiDelegate = self
        aikuWBvw?.navigationDelegate = self
        view.addSubview(aikuWBvw!)
        
        LUME_wbstr = NXV_wbdata!.keluos!
        aikuWBvw?.load(URLRequest(url:URL(string: LUME_wbstr!)!))

    }
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let top = view.safeAreaInsets.top

          aikuWBvw?.frame = CGRect(
              x: 0,
              y: top,
              width: view.bounds.width,
              height: view.bounds.height - top
          )
        print("safeAreaTop =", view.safeAreaInsets.top)
        print("webView.frame =", aikuWBvw?.frame ?? .zero)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        //  ：记录导航动作
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {

        let ul = navigationAction.request.url
        if ((ul?.absoluteString.hasPrefix(webView.url!.absoluteString)) != nil) {
            UIApplication.shared.open(ul!)
//            webView.load(navigationAction.request)
        }
        return nil
    }

    
 
    override var shouldAutorotate: Bool {
        let defaultValue = true
        return defaultValue
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        let orientations = UIInterfaceOrientationMask.allButUpsideDown
       return orientations
    }

}
extension UIViewController {
    var window: UIWindow? {
        return self.view.window
    }
}
