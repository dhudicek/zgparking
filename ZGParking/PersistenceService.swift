//
//  PersistenceService.swift
//  ZGParking
//
//  Created by Damjan Hudiček on 11/04/2017.
//  Copyright © 2017 ngajski. All rights reserved.
//

import Foundation
import CoreData
import UIKit

final class PersistenceService {
    static let context = ((UIApplication.shared.delegate) as! AppDelegate).persistentContainer.viewContext
    static let delegate = (UIApplication.shared.delegate) as! AppDelegate
    
    public static func addCar(name: String, licensePlate: String) {
        let car = Car(context: context)
        car.name = name
        car.licensePlate = licensePlate
        delegate.saveContext()
    }
    public static func removeCar(car: Car) {
        context.delete(car)
        delegate.saveContext()
    }
    public static func numberOfCars() -> Int {
        do {
            let count = try context.count(for: Car.fetchRequest())
            return count
        }
        catch {
            print("could not fetch cars")
            return 0
        }
    }
    public static func getCars() -> [Car]? {
        do {
            let cars = try context.fetch(Car.fetchRequest()) as! [Car]
            return cars
        }
        catch {
            print("could not fetch cars")
            return nil
        }
    }
}
