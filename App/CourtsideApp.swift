import SwiftUI
import WidgetKit


@main
struct CourtsideApp: App {
    @State private var widgetToken: String?
    @State private var widgetStatus = "Checking installed widget configurations…"


    var body: some Scene {
        WindowGroup {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Image(systemName: "basketball.fill")
                        .font(.system(size: 48)).foregroundStyle(.orange)
                    Text("COURTSIDE").font(.largeTitle.bold())
                    Text("Native installation test").font(.title3).foregroundStyle(.secondary)
                    Label("App launch successful", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    GroupBox("Widget verification") {
                        VStack(alignment: .leading, spacing: 14) {
                            Text(widgetStatus)
                            Text("Add Courtside Test from the Home Screen widget gallery. Test small, medium, and large sizes, then tap a widget.")
                            if let token = widgetToken {
                                Label("Widget link received", systemImage: "checkmark.seal.fill")
                                    .foregroundStyle(.green)
                                Text("Token: " + token).font(.caption.monospaced())
                                    .textSelection(.enabled)
                            } else {
                                Text("Waiting for a widget tap").foregroundStyle(.orange)
                            }
                            Button("Check widgets again") { checkWidgets() }
                        }.frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Text("This diagnostic contains no NBA scores. A successful app launch alone does not prove widget installation.")
                        .font(.footnote).foregroundStyle(.secondary)
                    Text("Build 0.1.0 • iOS 17+").font(.caption.monospaced())
                }.padding(24)
            }
            .background(Color(red: 0.04, green: 0.05, blue: 0.08))
            .preferredColorScheme(.dark)
            .onOpenURL { url in
                if let token = ProbeLink.token(from: url) { widgetToken = token }
                checkWidgets()
            }
            .onAppear { checkWidgets() }
        }
    }


    private func checkWidgets() {
        WidgetCenter.shared.getCurrentConfigurations { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let widgets):
                    let count = widgets.filter { $0.kind == "CourtsideProbe" }.count
                    widgetStatus = count == 0
                        ? "No Courtside widgets added yet."
                        : String(count) + " Courtside widget configuration(s) detected."
                case .failure(let error):
                    widgetStatus = "Widget check failed: " + error.localizedDescription
                }
            }
        }
    }
}

