import SafariServices
import UIKit
import WebKit

/// The whole app for now: the board in a full-screen web view. The strips under the status bar and the home indicator take the
/// board's own header and background colors (they follow its theme and style), links out to ESPN and the networks open in an
/// in-app Safari sheet, Print goes to the system print sheet, and a retry screen covers the board when it can't be reached.
final class BoardViewController: UIViewController {
    private var webView: WKWebView!
    private let topStrip = UIView()
    private let offlineView = OfflineView()
    private var headerIsDark = true

    /// Hosts that serve the board: the starting one, plus wherever the board's own address forwards to (its .com, later).
    private var boardHosts: Set<String> = [Board.url.host?.lowercased() ?? ""]
    /// True from asking for the board until it has loaded or failed; a forward to a new host is trusted only then.
    private var loadingBoard = false
    /// The board opens a link with window.open and, if that seems to fail, again by navigating; this keeps it to one sheet.
    private var lastOutside: (url: URL, at: Date)?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        headerIsDark ? .lightContent : .darkContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Board.navy
        topStrip.backgroundColor = Board.header

        let content = WKUserContentController()
        let handler = WeakScriptHandler(self)
        for name in ["theme", "open", "print"] {
            content.add(handler, name: name)
        }
        content.addUserScript(WKUserScript(source: BridgeScript.atStart, injectionTime: .atDocumentStart, forMainFrameOnly: true))
        content.addUserScript(WKUserScript(source: BridgeScript.atEnd, injectionTime: .atDocumentEnd, forMainFrameOnly: true))

        let config = WKWebViewConfiguration()
        config.userContentController = content
        config.websiteDataStore = .default()
        config.applicationNameForUserAgent = Board.userAgentTag
        config.allowsInlineMediaPlayback = true

        let web = WKWebView(frame: .zero, configuration: config)
        web.navigationDelegate = self
        web.uiDelegate = self
        web.isOpaque = false
        web.backgroundColor = Board.navy
        web.scrollView.backgroundColor = Board.navy
        web.allowsBackForwardNavigationGestures = false
        web.scrollView.contentInsetAdjustmentBehavior = .never
        webView = web

        for sub in [topStrip, web, offlineView] as [UIView] {
            sub.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(sub)
        }
        let safe = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            topStrip.topAnchor.constraint(equalTo: view.topAnchor),
            topStrip.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topStrip.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topStrip.bottomAnchor.constraint(equalTo: safe.topAnchor),

            web.topAnchor.constraint(equalTo: safe.topAnchor),
            web.leadingAnchor.constraint(equalTo: safe.leadingAnchor),
            web.trailingAnchor.constraint(equalTo: safe.trailingAnchor),
            web.bottomAnchor.constraint(equalTo: safe.bottomAnchor),

            offlineView.topAnchor.constraint(equalTo: safe.topAnchor),
            offlineView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            offlineView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            offlineView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        offlineView.isHidden = true
        offlineView.onRetry = { [weak self] in self?.loadBoard() }

        NotificationCenter.default.addObserver(self, selector: #selector(appBecameActive),
                                               name: UIApplication.didBecomeActiveNotification, object: nil)
        loadBoard()
    }

    private func loadBoard() {
        offlineView.isHidden = true
        loadingBoard = true
        webView.load(URLRequest(url: Board.url))
    }

    /// Back from the background with the retry screen up: try again without waiting for a tap.
    @objc private func appBecameActive() {
        if !offlineView.isHidden {
            loadBoard()
        }
    }

    /// Anything that isn't the board: ESPN, a network's site, a team page. Opens over the board, which stays where it was.
    private func openOutside(_ url: URL) {
        if let last = lastOutside, last.url == url, Date().timeIntervalSince(last.at) < 1.5 {
            return
        }
        lastOutside = (url, Date())
        let scheme = url.scheme?.lowercased() ?? ""
        guard scheme == "http" || scheme == "https" else {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            return
        }
        guard presentedViewController == nil else { return }
        let safari = SFSafariViewController(url: url)
        safari.preferredControlTintColor = Board.gold
        safari.dismissButtonStyle = .done
        present(safari, animated: true)
    }

    private func printBoard() {
        let info = UIPrintInfo(dictionary: nil)
        info.outputType = .general
        info.orientation = .landscape
        info.jobName = "Slate"
        let printer = UIPrintInteractionController.shared
        printer.printInfo = info
        printer.printFormatter = webView.viewPrintFormatter()
        printer.present(animated: true, completionHandler: nil)
    }

    private func applyTheme(top: UIColor?, bottom: UIColor?) {
        if let top = top {
            topStrip.backgroundColor = top
            headerIsDark = top.isDark
            setNeedsStatusBarAppearanceUpdate()
        }
        if let bottom = bottom {
            view.backgroundColor = bottom
            webView.backgroundColor = bottom
            webView.scrollView.backgroundColor = bottom
        }
    }
}

extension BoardViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        guard let url = navigationAction.request.url else { return .cancel }
        let scheme = url.scheme?.lowercased() ?? ""
        if ["about", "data", "blob", "javascript"].contains(scheme) {
            return .allow
        }
        guard scheme == "http" || scheme == "https" else {   // mailto:, tel:, an App Store link and the like
            openOutside(url)
            return .cancel
        }
        guard navigationAction.targetFrame?.isMainFrame ?? false else {
            return .allow                                    // frames inside the board
        }
        let host = url.host?.lowercased() ?? ""
        if boardHosts.contains(host) {
            return .allow
        }
        if loadingBoard && navigationAction.navigationType == .other {
            boardHosts.insert(host)                          // the board's address forwarding to its new home
            return .allow
        }
        openOutside(url)
        return .cancel
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingBoard = false
        offlineView.isHidden = true
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        loadingBoard = false
        let ns = error as NSError
        if ns.domain == NSURLErrorDomain && ns.code == NSURLErrorCancelled { return }
        if ns.domain == "WebKitErrorDomain" && ns.code == 102 { return }   // a navigation the app itself stopped
        offlineView.isHidden = false
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        loadingBoard = false
    }

    /// iOS reclaimed the page while the app sat in the background: bring the board back instead of a blank screen.
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        loadBoard()
    }
}

extension BoardViewController: WKUIDelegate {
    /// A link meant for a new window (target=_blank): open it over the board.
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let url = navigationAction.request.url {
            openOutside(url)
        }
        return nil
    }
}

extension BoardViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "theme":
            guard let body = message.body as? [String: Any] else { return }
            applyTheme(top: UIColor(css: body["top"] as? String), bottom: UIColor(css: body["bottom"] as? String))
        case "open":
            guard let text = message.body as? String, !text.isEmpty,
                  let url = URL(string: text, relativeTo: webView.url)?.absoluteURL else { return }
            openOutside(url)
        case "print":
            printBoard()
        default:
            break
        }
    }
}
