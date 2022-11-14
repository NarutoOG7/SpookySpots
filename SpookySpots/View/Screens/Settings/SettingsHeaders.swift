//
//  SettingsHeaders.swift
//  SpookySpots
//
//  Created by Spencer Belton on 11/13/22.
//

import SwiftUI

struct SettingsHeader: View {
    
    var settingType: SettingType
    
    let weenyWitch = K.Colors.WeenyWitch.self
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                iconView
                headerText
            }.padding(.horizontal)
            Rectangle()
                .fill(weenyWitch.orange)
                .frame(height: 1)
                .padding(.horizontal)
        }
    }
    
    private var iconView: some View {
        settingType.image
            .resizable()
            .frame(width: 20, height: 20)
            .foregroundColor(weenyWitch.orange)
    }
    
    private var headerText: some View {
        Text(settingType.rawValue.capitalized)
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundColor(weenyWitch.lighter)
    }
    
    enum SettingType: String {
        case account
        case about
        case admin
        
        var image: Image {
            switch self {
            case .account:
                return Image(systemName: "person")
            case .about:
                return Image(systemName: "gearshape")
            case .admin:
                return Image(systemName: "checkerboard.shield")
            }
        }
    }
}



struct SettingsHeaders_Previews: PreviewProvider {
    static var previews: some View {
        SettingsHeader(settingType: .account)
    }
}
