//
//  Car.swift
//  ZGParking
//
//  Created by Damjan Hudiček on 11/04/2017.
//  Copyright © 2017 ngajski. All rights reserved.
//

import Foundation
import CoreData

final class Car: NSManagedObject {
    @NSManaged var name: String?
    @NSManaged var licensePlate: String?
}
