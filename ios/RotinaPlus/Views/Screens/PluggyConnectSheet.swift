import SwiftUI
import WebKit

/// Abre o widget Pluggy Connect (sandbox) em WebView.
struct PluggyConnectSheet: View {
    let accessToken: String
    var onSuccess: (String) -> Void
    var onCancel: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            PluggyConnectWebView(
                accessToken: accessToken,
                onSuccess: { itemId in
                    onSuccess(itemId)
                    dismiss()
                },
                onClose: {
                    onCancel()
                    dismiss()
                }
            )
            .navigationTitle("Conectar banco")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fechar") {
                        onCancel()
                        dismiss()
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

private struct PluggyConnectWebView: UIViewRepresentable {
    let accessToken: String
    var onSuccess: (String) -> Void
    var onClose: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onSuccess: onSuccess, onClose: onClose)
    }

    func makeUIView(context: Context) -> WKWebView {
        let contentController = WKUserContentController()
        contentController.add(context.coordinator, name: "pluggy")

        let config = WKWebViewConfiguration()
        config.userContentController = contentController

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .black
        webView.loadHTMLString(Self.html(token: accessToken), baseURL: URL(string: "https://cdn.pluggy.ai"))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    final class Coordinator: NSObject, WKScriptMessageHandler {
        let onSuccess: (String) -> Void
        let onClose: () -> Void

        init(onSuccess: @escaping (String) -> Void, onClose: @escaping () -> Void) {
            self.onSuccess = onSuccess
            self.onClose = onClose
        }

        func userContentController(
            _ userContentController: WKUserContentController,
            didReceive message: WKScriptMessage
        ) {
            guard let body = message.body as? [String: Any],
                  let type = body["type"] as? String else { return }

            switch type {
            case "success":
                if let itemId = body["itemId"] as? String {
                    onSuccess(itemId)
                }
            case "close", "error":
                onClose()
            default:
                break
            }
        }
    }

    private static func html(token: String) -> String {
        let safe = token
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "'", with: "\\'")
        return """
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="utf-8" />
          <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1" />
          <style>
            html, body { margin: 0; padding: 0; background: #0D081A; color: #fff; font-family: -apple-system, sans-serif; }
            #hint { padding: 16px; font-size: 13px; opacity: 0.7; }
          </style>
          <script src="https://cdn.pluggy.ai/pluggy-connect/v2.8.0/pluggy-connect.js"></script>
        </head>
        <body>
          <div id="hint">Sandbox Pluggy — escolha o conector Sandbox.<br/>User: <b>user-ok</b> · Senha: <b>password-ok</b></div>
          <script>
            try {
              const pluggyConnect = new PluggyConnect({
                connectToken: '\(safe)',
                includeSandbox: true,
                onSuccess: (data) => {
                  const itemId = data && data.item && data.item.id ? data.item.id : null;
                  window.webkit.messageHandlers.pluggy.postMessage({ type: 'success', itemId: itemId });
                },
                onError: (error) => {
                  window.webkit.messageHandlers.pluggy.postMessage({ type: 'error', message: String(error) });
                },
                onClose: () => {
                  window.webkit.messageHandlers.pluggy.postMessage({ type: 'close' });
                }
              });
              pluggyConnect.init();
            } catch (e) {
              window.webkit.messageHandlers.pluggy.postMessage({ type: 'error', message: String(e) });
            }
          </script>
        </body>
        </html>
        """
    }
}
