//
//  MapViewController.swift
//  ZGParking
//
//  Created by Nikola Gajski on 4/2/17.
//  Copyright © 2017 ngajski. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import MessageUI

class MapViewController: UIViewController {

    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    var zone: ZoneEnum?
    var car: Car?
    
    @IBAction func payButtonTapped(_ sender: UIButton) {
        var licensePlate: String
        if (isManualPaymentEnabled()) {
            licensePlate = licensePlateTextField.text!
        }
        else {
            licensePlate = (car?.licensePlate)!
        }
        if let zone = self.zone, let telefon = zone.brojTelefona{
            sendMessage(forLicensePlate: licensePlate, forZone: telefon)
        }
    }
    @IBOutlet weak var licensePlateTextField: UITextField!
    @IBOutlet weak var zoneLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var carPicker: UIPickerView!
    @IBOutlet weak var zoneLabelTopConstraint: NSLayoutConstraint!
    
    //var pickerData = ["Auto 1", "Auto 2", "Auto 3", "Auto 4", "Auto 5", "Auto 6"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        zoneLabel.text = "Zona:"
        priceLabel.text = "Cijena:"
        
        carPicker.delegate = self
        carPicker.dataSource = self
        
        initLocationManager()
        initGoogleMapView()
        initButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        carPicker.reloadAllComponents()
    }
    
    private func initLocationManager() {
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        placesClient = GMSPlacesClient.shared()
    }
    
    private func initGoogleMapView() {
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        let camera = GMSCameraPosition.camera(withLatitude: 45.813720, longitude: 15.977885, zoom: zoomLevel)
        
        let width = self.view.bounds.width
        let height = self.view.bounds.height / 2
        
        self.mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: width, height: height), camera: camera)
        
        self.mapView.settings.myLocationButton = true
        self.mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.mapView.isMyLocationEnabled = true
        
        // Add the map to the view, hide it until we've got a location update.
        view.addSubview(mapView)
        mapView.isHidden = true
        
        zoneLabelTopConstraint.constant = height + 20
        
    }
    
    private func initButtons() {
        let settingsButton = UIBarButtonItem(title: "Postavke", style: .plain, target: self, action: #selector(settingsButtonTapped))
        navigationItem.rightBarButtonItem = settingsButton
    }
    
    @objc private func settingsButtonTapped(notification: NSNotification) {
        let settingsViewController = SettingsViewController()
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(settingsViewController, animated: true)
        }
    }
    
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
        
        
        //let stringCoordinates = "(" + location.coordinate.latitude.description + "," + location.coordinate.longitude.description + ")"
        zone = ZoneDetectionService.detectZone(location: location)
        guard let zoneText = zone?.rawValue,
            let priceText = zone?.cijena,
            let obracunskaJedinica = zone?.obracunskaJedinica
        else {return}
        zoneLabel.text = ("Zona: \(zoneText)")
        priceLabel.text = ("Cijena: \(priceText)kn/\(obracunskaJedinica)")
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}

extension MapViewController: UIPickerViewDelegate, UIPickerViewDataSource {
 
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let count = PersistenceService.numberOfCars()
        if count == 0 {
            manualPayment(isEnabled: true)
        }
        else {
            manualPayment(isEnabled: false)
        }
        return count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let cars = PersistenceService.getCars() else {return nil}
        car = cars[row]
        return cars[row].name
    }
    
    //Called if no cars are in database, to enter license plate manually
    private func manualPayment(isEnabled: Bool) {
        if (isEnabled) {
            carPicker.isHidden = true
            licensePlateTextField.isHidden = false
        }
        else {
            carPicker.isHidden = false
            licensePlateTextField.isHidden = true
        }
    }
    func isManualPaymentEnabled() -> Bool {
        return carPicker.isHidden
    }
}
extension MapViewController: MFMessageComposeViewControllerDelegate {
    func sendMessage(forLicensePlate licensePlate: String, forZone zone: String) {
        if (MFMessageComposeViewController.canSendText()) {
            let mvc = MFMessageComposeViewController()
            mvc.body = licensePlate
            mvc.recipients = [zone]
            mvc.messageComposeDelegate = self
            self.present(mvc, animated: true, completion: nil)
        }
        else {
            print("messaging services not available")
        }
    }
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
}
