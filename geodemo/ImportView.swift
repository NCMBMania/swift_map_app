//
//  ImportView.swift
//  geodemo
//
//  Created by Atsushi Nakatsugawa on 2022/10/18.
//

import SwiftUI
import NCMB

struct Station: Codable {
    var name: String
    var latitude: Double
    var longitude: Double
}
 

struct ImportView: View {
    @State private var logs: [String] = []
    
    // すでにデータストアにある駅名データを削除する処理（何度も繰り返せる用）
    private func _removeStations() {
        // 検索対象のデータストアのクラス（DBで言うテーブル名相当）
        var query = NCMBQuery.getQuery(className: "Station")
        // 100件対象とする
        query.limit = 100
        // 検索実行
        query.findInBackground(callback: { result in
            // 処理が成功している場合
            if case let .success(ary)  = result {
                // すべてのデータを削除
                ary.forEach{ station in
                    // 削除処理（非同期）
                    station.deleteInBackground(callback: {_ in
                        // 特に処理なし
                    })
                }
            }
        })
    }
    
    // アセットにあるJSONファイルを読み込む
    private func _loadStations() -> [Station] {
        // インポートする
        guard let url = Bundle.main.url(forResource: "yamanote", withExtension: "json") else {
            fatalError("ファイルが見つからない")
        }
        // 読み込み
        guard let data = try? Data(contentsOf: url) else {
            fatalError("ファイル読み込みエラー")
        }
        // JSONデコード
        let decoder = JSONDecoder()
        guard let stations = try? decoder.decode([Station].self, from: data) else {
            fatalError("JSON読み込みエラー")
        }
        return stations
    }
    
    // 駅名の配列をデータストアに登録する
    private func registerDataStore(stations: [Station]) {
        stations.forEach{ params in
            // 登録するデータストアのクラス（DBで言うテーブル名相当）
            let station = NCMBObject(className: "Station")
            // 駅名をセット
            station["name"] = params.name
            // 位置情報はNCMBGeoPointを利用する
            let geo = NCMBGeoPoint(latitude: params.latitude, longitude: params.longitude)
            // 位置情報をセット
            station["geo"] = geo
            // 保存処理（非同期処理）
            station.saveInBackground(callback: { result in
                // 成功していればログに追記
                if case .success(_)  = result {
                    let log = "保存しました -> \(params.name)"
                    logs.append(log)
                }
            })
        }
    }
    
    private func _execute() {
        // まずデータを削除する
        _removeStations()
        // JSONファイルを読み込む
        let stations = _loadStations()
        // JSONファイルの内容をデータストアに登録する
        registerDataStore(stations: stations)
    }
    
    var body: some View {
        VStack(spacing: 16
        ) {
            Text("駅一覧を読み込みます").padding()
            // ボタンを押したら駅登録処理開始
            Button(action: _execute, label: { Text("インポート実行")})
            if logs.count > 0 {
                // ログ表示用
                Text("ログ")
                List {
                    ForEach(Array(logs.enumerated()), id: \.element) { index, log in
                        Text(logs[index])
                    }
                }
            }
        }
    }
}

struct ImportView_Previews: PreviewProvider {
    static var previews: some View {
        ImportView()
    }
}
