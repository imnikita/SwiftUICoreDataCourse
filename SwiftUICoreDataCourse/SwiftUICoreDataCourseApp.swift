//
//  SwiftUICoreDataCourseApp.swift
//  SwiftUICoreDataCourse
//
//  Created by CMDB-127710 on 14.11.2022.
//

import SwiftUI

@main
struct SwiftUICoreDataCourseApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
