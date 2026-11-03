import UIKit
import WebKit

/// Where the app finds the board, and the colors it starts in.
///
/// The board is the same page as the home-screen web app, so it updates the moment a change is pushed, with no app update.
/// When the board moves to its own .com, GitHub forwards this address there and the app follows the forward (the new host
/// is trusted because the board's own address sent it there), so this line doesn't have to change.
enum Board {
    static let url = URL(string: "https://pjones7-del.github.io/football-slate/")!

    /// Appended to the web view's user agent, so the page can tell it's running inside the app.
    static var userAgentTag: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"
        return "SlateApp/" + version
    }

    static let navy = UIColor(hex: 0x101722)      // the board's background, dark theme
    static let header = UIColor(hex: 0x151D2A)    // the board's control bar, dark theme
    static let chalk = UIColor(hex: 0xECE9E2)
    static let muted = UIColor(hex: 0x9AA5B5)
    static let gold = UIColor(hex: 0xF5B82E)
    static let goldInk = UIColor(hex: 0x1A1400)
}

/// What the app adds to the page. Before the page's own scripts run, window.open and window.print are pointed at the app
/// (a web view has neither: the board opens ESPN's gamecast and the networks with window.open, and Print ends in window.print).
/// Once the page is up, it reports its header and background colors, and again whenever the theme or the style changes, so the
/// strips under the status bar and the home indicator always match the board.
enum BridgeScript {
    static let atStart = """
    (function () {
      window.open = function (url) {
        try { window.webkit.messageHandlers.open.postMessage(String(url || '')); } catch (e) {}
        return { closed: false, close: function () {}, focus: function () {} };
      };
      window.print = function () {
        try { window.webkit.messageHandlers.print.postMessage(''); } catch (e) {}
      };
    })();
    """

    static let atEnd = """
    (function () {
      function send() {
        try {
          var bar = document.querySelector('.bar');
          var bottom = getComputedStyle(document.body).backgroundColor;
          var top = bar ? getComputedStyle(bar).backgroundColor : bottom;
          window.webkit.messageHandlers.theme.postMessage({ top: top, bottom: bottom });
        } catch (e) {}
      }
      send();
      window.addEventListener('load', send);
      new MutationObserver(function () { setTimeout(send, 30); })
        .observe(document.documentElement, { attributes: true, attributeFilter: ['data-theme', 'data-skin', 'class'] });
      try {
        window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', function () { setTimeout(send, 30); });
      } catch (e) {}
    })();
    """
}

/// Passes script messages on without the content controller holding the view controller (it would never be released).
final class WeakScriptHandler: NSObject, WKScriptMessageHandler {
    private weak var target: WKScriptMessageHandler?

    init(_ target: WKScriptMessageHandler) {
        self.target = target
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        target?.userContentController(userContentController, didReceive: message)
    }
}

extension UIColor {
    convenience init(hex: UInt32) {
        self.init(red: CGFloat((hex >> 16) & 0xFF) / 255,
                  green: CGFloat((hex >> 8) & 0xFF) / 255,
                  blue: CGFloat(hex & 0xFF) / 255,
                  alpha: 1)
    }

    /// A computed CSS color: "rgb(21, 29, 42)", "rgba(21, 29, 42, 1)" or "color(srgb 0.08 0.11 0.16)". Nil for anything else,
    /// and for a color that is mostly transparent (it would let the black behind the window show through).
    convenience init?(css: String?) {
        guard let css = css, let open = css.firstIndex(of: "("), let close = css.lastIndex(of: ")"), open < close else { return nil }
        let inside = css[css.index(after: open)..<close]
        let unitScale: Bool = css.hasPrefix("color(")
        let numbers = inside
            .split(whereSeparator: { $0 == "," || $0 == " " || $0 == "/" })
            .compactMap { Double($0) }
        guard numbers.count >= 3 else { return nil }
        let alpha = numbers.count >= 4 ? numbers[3] : 1
        guard alpha >= 0.5 else { return nil }
        let scale = unitScale ? 1.0 : 255.0
        self.init(red: CGFloat(numbers[0] / scale), green: CGFloat(numbers[1] / scale), blue: CGFloat(numbers[2] / scale), alpha: 1)
    }

    /// True for a color dark enough to want white status-bar text.
    var isDark: Bool {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return 0.2126 * r + 0.7152 * g + 0.0722 * b < 0.5
    }
}
