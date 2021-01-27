//
//  AdminBanView.swift
//  Twittersky
//
//  Created by Eduard Dzhumagaliev on 01.02.2021.
//

import SwiftUI

struct AdminBanView: View {
    @Binding var startDate: Date
    @Binding var endDate: Date
    @Binding var cancel: () -> Void
    @Binding var confirm: () -> Void
    
    var body: some View {
        VStack {
            Text("Please choose the ban interval")
            HStack{
                DatePicker("Start", selection: $startDate)
                DatePicker("End", selection: $endDate)
            }
            HStack{
                Button("Cancel", action: cancel)
                Button("Confirm", action: confirm)
            }
        }
    }
}
