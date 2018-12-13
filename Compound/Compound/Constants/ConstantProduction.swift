//
//  ConstantProduction.swift
//  Compound
//
//  Created by robert on 12/12/2018.
//  Copyright © 2018 Robert Zakiev. All rights reserved.
//

import Foundation

struct ProductionOfCompany {
    struct Produce {
        let produceName: String
        let produce: [(year: Int, value: Double)]
    }
    let companyName: String
    let unitOfMeasureMent: String?
    let production:[Produce]
}

struct ConstantsProduction {

static let productionFigures:[ProductionOfCompany] = [
    ProductionOfCompany(companyName: "Степь", unitOfMeasureMent: "тыс. тонн", production: [ProductionOfCompany.Produce(produceName: "Яблоки", produce: [(2014, 11.6),(2015, 15.1),(2016, 15.9), (2017,21.8)]), ProductionOfCompany.Produce(produceName: "Молоко", produce: [(2014, 27.9),(2015, 30.2),(2016, 36.2), (2017,40)]), ProductionOfCompany.Produce(produceName: "Пшеница", produce: [(2014, 280),(2015, 547),(2016, 1041), (2017,1335)]), ProductionOfCompany.Produce(produceName: "Помидоры", produce: [(2014, 20.4),(2015, 19.6),(2016, 21.3), (2017,23.2)]), ProductionOfCompany.Produce(produceName: "Огурцы", produce: [(2014, 12.9),(2015, 17.9),(2016, 24.5), (2017,21.8)])]),
    ProductionOfCompany(companyName: "Сегежа", unitOfMeasureMent: nil, production: [ProductionOfCompany.Produce(produceName: "Бумага тыс. тонн", produce: [(2015, 285), (2016, 286), (2017, 319)]), ProductionOfCompany.Produce(produceName: "Бумажная Упаковка млн.", produce: [(2015, 1111), (2016, 1250), (2017, 1172)]), ProductionOfCompany.Produce(produceName: "Потреб. Пакеты млн.", produce: [(2015, 25), (2016, 32), (2017, 37)]), ProductionOfCompany.Produce(produceName: "Лесозаготовка тыс. куб.м.", produce: [(2015, 3698), (2016, 3828), (2017, 3939)]), ProductionOfCompany.Produce(produceName: "Пиломатериалы тыс. куб.м.", produce: [(2015, 386), (2016, 875), (2017, 896)]), ProductionOfCompany.Produce(produceName: "Фанера тыс. куб.м.", produce: [(2015, 95), (2016, 95), (2017, 100)]), ProductionOfCompany.Produce(produceName: "ДСП тыс. кв.м.", produce: [(2015, 25), (2016, 49), (2017, 50)]), ProductionOfCompany.Produce(produceName: "Клееный брус тыс. куб.м.", produce: [(2015, 5), (2016, 23), (2017, 44)])])
]

}



