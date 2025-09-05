//
//  PakistanData.swift
//  Gift Wave
//
//  Created by Abdullah Latif on 04/08/2025.
//

import Foundation

struct PakistanData {
    
    static let provinces = [
        "Punjab",
        "Sindh", 
        "Khyber Pakhtunkhwa",
        "Balochistan",
        "Gilgit-Baltistan",
        "Azad Jammu & Kashmir"
    ]
    
    static let majorCities = [
        "Punjab": [
            "Lahore",
            "Faisalabad",
            "Rawalpindi",
            "Multan",
            "Gujranwala",
            "Sialkot",
            "Bahawalpur",
            "Sargodha",
            "Jhang",
            "Sheikhupura",
            "Rahim Yar Khan",
            "Gujrat",
            "Kasur",
            "Okara",
            "Sahiwal",
            "Wah Cantonment",
            "Mianwali",
            "Chiniot",
            "Kamoke",
            "Hafizabad"
        ],
        "Sindh": [
            "Karachi",
            "Hyderabad",
            "Sukkur",
            "Larkana",
            "Nawabshah",
            "Mirpur Khas",
            "Jacobabad",
            "Shikarpur",
            "Khairpur",
            "Dadu",
            "Tando Allahyar",
            "Tando Adam",
            "Badin",
            "Thatta",
            "Umerkot"
        ],
        "Khyber Pakhtunkhwa": [
            "Peshawar",
            "Mardan",
            "Mingora",
            "Kohat",
            "Abbottabad",
            "Dera Ismail Khan",
            "Mansehra",
            "Swabi",
            "Nowshera",
            "Charsadda",
            "Bannu",
            "Haripur",
            "Chitral",
            "Batkhela",
            "Timergara"
        ],
        "Balochistan": [
            "Quetta",
            "Turbat",
            "Khuzdar",
            "Chaman",
            "Hub",
            "Sibi",
            "Loralai",
            "Dera Murad Jamali",
            "Gwadar",
            "Dera Allah Yar",
            "Usta Muhammad",
            "Sui",
            "Saranan",
            "Kalat",
            "Mastung"
        ],
        "Gilgit-Baltistan": [
            "Gilgit",
            "Skardu",
            "Chilas",
            "Astore",
            "Ghanche",
            "Diamer",
            "Hunza",
            "Nagar",
            "Shigar",
            "Kharmang"
        ],
        "Azad Jammu & Kashmir": [
            "Muzaffarabad",
            "Mirpur",
            "Rawalakot",
            "Kotli",
            "Bhimber",
            "Bagh",
            "Hattian Bala",
            "Neelum",
            "Haveli",
            "Sudhnuti"
        ]
    ]
    
    static let popularGiftCategories = [
        "Birthday Gifts",
        "Wedding Gifts", 
        "Eid Gifts",
        "Anniversary Gifts",
        "House Warming Gifts",
        "Get Well Soon Gifts",
        "Congratulations Gifts",
        "Condolence Gifts",
        "Ramadan Gifts",
        "Eid ul Fitr Gifts",
        "Eid ul Adha Gifts",
        "Valentine's Day Gifts",
        "Mother's Day Gifts",
        "Father's Day Gifts",
        "Graduation Gifts"
    ]
    
    static let popularGiftItems = [
        "Flowers & Bouquets",
        "Cakes & Pastries",
        "Chocolates & Sweets",
        "Perfumes & Cosmetics",
        "Jewelry & Accessories",
        "Clothing & Textiles",
        "Electronics & Gadgets",
        "Books & Stationery",
        "Toys & Games",
        "Home Decor",
        "Kitchen Items",
        "Personal Care Products",
        "Traditional Pakistani Gifts",
        "Islamic Books & Items",
        "Customized Gifts"
    ]
    
    static let deliveryFeeRanges = [
        "Same City": (100.0, 300.0),
        "Same Province": (300.0, 800.0),
        "Different Province": (800.0, 2000.0),
        "Remote Areas": (1500.0, 3500.0)
    ]
    
    static let currency = "PKR"
    static let currencySymbol = "₨"
    
    static func getCities(for province: String) -> [String] {
        return majorCities[province] ?? []
    }
    
    static func getAllCities() -> [String] {
        return majorCities.values.flatMap { $0 }.sorted()
    }
    
    static func getProvince(for city: String) -> String? {
        for (province, cities) in majorCities {
            if cities.contains(city) {
                return province
            }
        }
        return nil
    }
} 