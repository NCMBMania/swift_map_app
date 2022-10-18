import SwiftUI
import MapKit
import UIKit

protocol TapplableMapViewDelegate: AnyObject {
    func mapViewDidTap(location: CLLocationCoordinate2D)
}

class TapplableMapView: UIView, MKMapViewDelegate {
    private lazy var mapView = MKMapView()
    weak var delegate: TapplableMapViewDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.addTarget(self, action: #selector(onTap(sender:)))
        // 初期表示の中心点
        let coordinate = CLLocationCoordinate2DMake(35.6585805, 139.7454329)
        // 拡大率
        let span = MKCoordinateSpan(latitudeDelta: 0.065, longitudeDelta: 0.065)
        // 中心を設定
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: false)
        // ジェスチャー認識用
        mapView.addGestureRecognizer(tapGestureRecognizer)
        mapView.delegate = self
        self.backgroundColor = .red
        addSubview(mapView)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "something")
        if annotation.title == "tap" {
            annotationView.markerTintColor = .green
        } else {
            annotationView.markerTintColor = .blue
        }
        return annotationView
    }
    
    override func layoutSubviews() {
        mapView.frame =  CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
    }
    
    @objc func onTap(sender: UITapGestureRecognizer) {
        let tapPoint = sender.location(in: mapView)
        let location = mapView.convert(tapPoint, toCoordinateFrom: mapView)
        delegate?.mapViewDidTap(location: location)
    }
    
    func addAnnotation(_ annotation: MKAnnotation) {
        mapView.addAnnotation(annotation)
    }
    
    func clearAnnotation() {
        mapView.removeAnnotations(mapView.annotations)
    }
}

struct MapView: UIViewRepresentable {
    @Binding var locations: [CLLocationCoordinate2D]
    @Binding var stattions: [CLLocationCoordinate2D]
    
    let mapViewDidTap: (_ location: CLLocationCoordinate2D) -> Void
    final class Coordinator: NSObject, TapplableMapViewDelegate {
        private var mapView: MapView
        let mapViewDidTap: (_ location: CLLocationCoordinate2D) -> Void
        
        init(_ mapView: MapView, mapViewDidTap: @escaping (_ location: CLLocationCoordinate2D) -> Void) {
            self.mapView = mapView
            self.mapViewDidTap = mapViewDidTap
        }
        
        func mapViewDidTap(location: CLLocationCoordinate2D) {
            mapViewDidTap(location)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, mapViewDidTap: mapViewDidTap)
    }
    
    func makeUIView(context: Context) -> TapplableMapView {
        let mapView = TapplableMapView()
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ uiView: TapplableMapView, context: Context) {
        uiView.clearAnnotation()
        for location in locations {
            let annotation = MKPointAnnotation()
            let centerCoordinate = location
            annotation.coordinate = centerCoordinate
            annotation.title = "tap"
            uiView.addAnnotation(annotation)
        }
        for location in stattions {
            let annotation = MKPointAnnotation()
            let centerCoordinate = location
            annotation.coordinate = centerCoordinate
            annotation.title = "station"
            uiView.addAnnotation(annotation)
        }
    }
}
