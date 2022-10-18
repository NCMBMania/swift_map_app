//
//  ContentView.swift
//  geodemo
//
//  Created by Atsushi Nakatsugawa on 2022/10/18.
//

import SwiftUI
import NCMB

struct ContentView: View {
    // Viewの初期化時に呼ばれるメソッド
    init() {
        // NCMBの初期化
        NCMB.initialize(applicationKey: "9170ffcb91da1bbe0eff808a967e12ce081ae9e3262ad3e5c3cac0d9e54ad941", clientKey: "9e5014cd2d76a73b4596deffdc6ec4028cfc1373529325f8e71b7a6ed553157d")
    }
    var body: some View {
        TabView {
            // 地図画面
            StationView()
                .tabItem {
                    VStack {
                        Image(systemName: "map")
                        Text("地図")
                    }
            }.tag(1)
            // インポート画面
            ImportView()
                .tabItem {
                    VStack {
                        Image(systemName: "gear")
                        Text("Import")
                    }
            }.tag(2)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
