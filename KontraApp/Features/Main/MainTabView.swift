import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var auth: AuthManager
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem { Label("Dashboard", systemImage: "chart.bar.fill") }
                .tag(0)

            PortfolioView()
                .tabItem { Label("Portfolio", systemImage: "briefcase.fill") }
                .tag(1)

            ServicingView()
                .tabItem { Label("Servicing", systemImage: "wrench.and.screwdriver.fill") }
                .tag(2)

            GovernanceView()
                .tabItem { Label("Governance", systemImage: "shield.checkerboard") }
                .tag(3)

            MarketsView()
                .tabItem { Label("Markets", systemImage: "chart.line.uptrend.xyaxis") }
                .tag(4)
        }
        .tint(.kontraAccent)
    }
}

#Preview {
    MainTabView().environmentObject(AuthManager.shared)
}
