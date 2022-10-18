//
//  MapView.swift
//  geodemo
//
//  Created by Atsushi Nakatsugawa on 2022/10/18.
//

import SwiftUI
import MapKit
import NCMB

struct StationView: View {
    // タップされた際にtrueになる
    @State var showingAlert = false
    // タップされた場所が入ってくる
    @State var selectedLocation: CLLocationCoordinate2D?
    // タップされた場所（最大2つ）が入る
    @State var tapLocations: [CLLocationCoordinate2D] = []
    // 検索結果の駅一覧の位置情報が入る配列
    @State var stations: [CLLocationCoordinate2D] = []
    
    var body: some View {
        ZStack {
            MapView(locations: $tapLocations, stattions: $stations) { location in
                self.selectedLocation = location
                self.showingAlert = true
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: _removeMarkers, label: {
                        Image(systemName: "trash")
                            .foregroundColor(.white)
                            .font(.system(size: 24)) // --- 4
                    })
                    .frame(width: 60, height: 60)
                    .background(Color.orange)
                    .cornerRadius(30.0)
                    .shadow(color: .gray, radius: 3, x: 3, y: 3)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 16.0, trailing: 16.0)) // --- 5
                    
                }
            }
        }
        // 地図をタップされた際に呼ばれるイベント
        .onChange(of: showingAlert) { value in
            // フラグを落とした際にも呼ばれるので、二重処理防止用
            if showingAlert == false {
                return
            }
            // タップされた位置情報を取得
            if let location = selectedLocation {
                // 位置情報を追加
                _addLocation(location: location)
                // フラグを落とす
                showingAlert = false
            }
        }
    }
        
    // すべてのマーカーを削除する処理
    private func _removeMarkers() {
        tapLocations.removeAll()
        stations.removeAll()
    }
    
    // タップされた際に呼ばれる処理
    private func _addLocation(location: CLLocationCoordinate2D) {
        // すでに2つマーカーがあるかどうか
        if tapLocations.count == 2 {
            // あれば最初のマーカーを消して、新しいマーカーを1つ目にする
            tapLocations[0] = tapLocations[1]
            tapLocations.remove(at: 1)
        }
        // タップした場所を追加
        tapLocations.append(location)
        // マーカーの数によって検索条件を変える
        if tapLocations.count == 2 {
            // 矩形検索
            _geoBoxSearch()
        } else {
            // 近距離検索
            _nearBySearch()
        }
    }
    
    // タップしたマーカーの付近にある駅を検索する
    private func _nearBySearch() {
        // 検索対象のデータストアのクラス（DBで言うテーブル名相当）
        var query = NCMBQuery.getQuery(className: "Station")
        // 検索条件になる位置情報を作成
        let geo = NCMBGeoPoint(latitude: selectedLocation!.latitude, longitude: selectedLocation!.longitude)
        // nearGeoPointで検索を行う
        query.where(field: "geo", nearGeoPoint: geo,
                    withinKilometers: 3.0)
        // 検索実行
        query.findInBackground(callback: { result in
            // 検索処理がうまくいっていれば、駅を配列に登録する
            if case let .success(ary)  = result {
                _appendStations(ary: ary)
            }
        })
    }
    
    // 二点間の矩形検索を行う
    private func _geoBoxSearch() {
        // 検索対象のデータストアのクラス（DBで言うテーブル名相当）
        var query = NCMBQuery.getQuery(className: "Station")
        // 二点の位置情報オブジェクトを作成
        let geo1 = NCMBGeoPoint(latitude: tapLocations[0].latitude, longitude: tapLocations[0].longitude)
        let geo2 = NCMBGeoPoint(latitude: tapLocations[1].latitude, longitude: tapLocations[1].longitude)
        // withinGeoBoxFromSouthwestで検索を行う
        query.where(field: "geo", withinGeoBoxFromSouthwest: geo1, toNortheast: geo2)
        // 検索実行
        query.findInBackground(callback: { result in
            // 検索処理がうまくいっていれば、駅を配列に登録する
            if case let .success(ary)  = result {
                _appendStations(ary: ary)
            }
        })
    }
    
    private func _appendStations(ary: [NCMBObject]) {
        stations.removeAll()
        ary.forEach { station in
            let geo = station["geo"]! as NCMBGeoPoint
            let location = CLLocationCoordinate2D(latitude: geo.latitude, longitude: geo.longitude)
            stations.append(location)
        }

    }
}

struct StationView_Previews: PreviewProvider {
    static var previews: some View {
        StationView()
    }
}
