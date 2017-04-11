//
//  ZoneEnum.swift
//  ZGParking
//
//  Created by Damjan Hudiček on 11/04/2017.
//  Copyright © 2017 ngajski. All rights reserved.
//

import Foundation

enum ZoneEnum: String {
    case prva = "1."
    case jedan_jedan = "1.1"
    case druga = "2"
    case treca = "3"
    case cetiri_jedan = "4.1"
    case cetiri_dva = "4.2"
    var cijena: Double {
        switch self {
        case .prva:
            return 6.0
        case .druga:
            return 3.0
        case .jedan_jedan:
            return 150.0
        case .treca:
            return 1.50
        case .cetiri_jedan:
            return 5.0
        case .cetiri_dva:
            return 10.0
        }
    }
    var obracunskaJedinica: String {
        switch self {
        case .prva, .druga, .treca:
            return "sat"
        default:
            return "dan"
        }
    }
    var brojTelefona: String? {
        switch self {
        case .prva:
            return "700101"
        case .jedan_jedan:
            return nil
        case .druga:
            return "700102"
        case .treca:
            return "700103"
        case .cetiri_jedan:
            return "700105"
        case .cetiri_dva:
            return "700104"
        }
    }
}
