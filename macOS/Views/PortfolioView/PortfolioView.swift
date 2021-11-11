//
//  PortfolioView.swift
//  Returns (macOS)
//
//  Created by James Chen on 2021/11/02.
//

import SwiftUI

struct PortfolioView: View {
    @ObservedObject var portfolio: Portfolio
    @Binding var showingConfigureSheet: Bool
    @Binding var showingCalculationsView: Bool

    var body: some View {
        VStack {
            Text("todo")

            Text("Growth Chart")
                .font(.title)
            GrowthChart(portfolio: portfolio)

            Text("Assets Overview")
                .font(.title)
            OverviewChart(portfolio: portfolio)
        }
        .navigationTitle(portfolio.name ?? "")
        .navigationSubtitle("Since: \(portfolio.sinceString)")
        .toolbar {
            ToolbarItemGroup {
                Button {
                    showingConfigureSheet = true
                } label: {
                    Label("Configure...", systemImage: "folder.badge.gearshape")
                }
                Button {
                    showingCalculationsView = true
                } label: {
                    Label("Calculations", systemImage: "calendar.badge.clock")
                }
            }
        }
    }
}

struct PortfolioView_Previews: PreviewProvider {
    static var previews: some View {
        PortfolioView(portfolio: testPortfolio, showingConfigureSheet: .constant(false), showingCalculationsView: .constant(false))
    }

    static var testPortfolio: Portfolio {
        let context = PersistenceController.preview.container.viewContext
        let portfolio = Portfolio(context: context)
        portfolio.name = "My Portfolio"
        let account = Account(context: context)
        account.name = "My Account #1"
        account.portfolio = portfolio
        return portfolio
    }
}
