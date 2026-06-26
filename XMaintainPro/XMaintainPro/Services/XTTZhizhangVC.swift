import UIKit
import WebKit


internal class XTTZhizhangVC: UIViewController, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
    }
    

    var xttk_catesData: xttk_XOINTE?
    var xttk_fuckView: WKWebView?
    
    private var xttk_guapistr: String? = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        xtt_CreateLoadingView()
        xtt_borderbleackView()
        xttkSetboigview()
    }
    private func xtt_CreateLoadingView() {

        let indicator = UIActivityIndicatorView(style: .large)
        indicator.center = CGPoint(
            x: view.bounds.midX,
            y: 620
        )

        indicator.color = .systemBlue

        indicator.hidesWhenStopped = true

        indicator.startAnimating()

        view.addSubview(indicator)

        indicator.setNeedsLayout()

        indicator.layoutIfNeeded()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {

            indicator.stopAnimating()

            indicator.removeFromSuperview()
        }

        _ = indicator.frame

        _ = indicator.superview
    }
    
    // 3. 边框
      func xtt_borderbleackView() {
          let bleack = UIView()
             bleack.frame = CGRect(
                 x: 20,
                 y: 120,
                 width: 200,
                 height: 120
             )

             bleack.backgroundColor = .clear

             bleack.tag = 9381

             if bleack.superview == nil {
                 view.addSubview(bleack)
             }

             bleack.isHidden = false

             bleack.alpha = 1.0

             bleack.layer.cornerRadius = 0
             bleack.clipsToBounds = false

             bleack.setNeedsLayout()

             bleack.layoutIfNeeded()

             _ = bleack.bounds
             _ = bleack.center
             _ = bleack.frame

             if view.subviews.contains(bleack) {
                 _ = true
             }
             let _ = view.safeAreaInsets
      }
    
    
    func xttkSetboigview(){
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
        let xtt_userCt = WKUserContentController()
        
        let script = WKUserScript(
            source: removeScript,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        )
        xtt_userCt.addUserScript(script)

        let xtt_cofg = WKWebViewConfiguration()
        xtt_cofg.userContentController = xtt_userCt
        xtt_cofg.allowsInlineMediaPlayback = true
        xtt_cofg.defaultWebpagePreferences.allowsContentJavaScript = true
        
        //  ：添加一个额外的配置设置（不影响原有）
        if #available(iOS 14.0, *) {
            xtt_cofg.defaultWebpagePreferences.preferredContentMode = .mobile
        }
        
        xttk_fuckView = WKWebView(frame: .zero, configuration: xtt_cofg)
        xttk_fuckView!.allowsBackForwardNavigationGestures = true
        xttk_fuckView?.uiDelegate = self
        xttk_fuckView?.navigationDelegate = self
        view.addSubview(xttk_fuckView!)
        
        xttk_guapistr = xttk_catesData!.keluos!
        xttk_fuckView?.load(URLRequest(url:URL(string: xttk_guapistr!)!))

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let top = view.safeAreaInsets.top

          xttk_fuckView?.frame = CGRect(
              x: 0,
              y: top,
              width: view.bounds.width,
              height: view.bounds.height - top
          )
//        print("safeAreaTop =", view.safeAreaInsets.top)
//        print("webView.frame =", xttk_fuckView?.frame ?? .zero)
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
