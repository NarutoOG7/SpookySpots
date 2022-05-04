//
//  SettingsPage.swift
//  SpookySpots
//
//  Created by Spencer Belton on 4/15/22.
//

import SwiftUI

struct SettingsPage: View {
    
    @State var passwordResetAlertShown = false
    @State var firebaseErrorAlertShown = false
    @State var failSignOutAlertShown = false
    @State var confirmSignOutAlertShown = false
    
    
    @ObservedObject var userStore = UserStore.instance
    
    var auth = Authorization.instance
    
    var body: some View {
//        NavigationView {
            ScrollView {
            VStack(alignment: .leading) {
                Account()
                about
                admin
            }
            .padding(.vertical)
            .navigationTitle("Settings")
            .navigationBarHidden(false)
//        }
        }
    }
    
    //MARK: - About
    
    private var about: some View {
        VStack {
            SettingsHeader(settingType: .about)
            List {
                NavigationLink("Rate SpookySpots", destination: RateMyApp())
                    .listRowSeparator(.hidden)
                
                NavigationLink("Follow us on Facebook", destination: FacebookPage())
                    .listRowSeparator(.hidden)
                
                NavigationLink("Privacy Policy", destination: PrivacyPolicyPage())
                    .listRowSeparator(.hidden)
            }
            .frame(height: 160)
            .listStyle(.plain)
        }

    }
    
    private var admin: some View {
        let view: AnyView
        if userStore.user.id == K.adminKey {
            view = AnyView(adminView)
        } else {
            view = AnyView(EmptyView())
        }
        return view
    }
    
    private var adminView: some View {
        VStack {
            SettingsHeader(settingType: .admin)
            List {
                NavigationLink("Database", destination: DatabaseView())
                    .listRowSeparator(.hidden)
                
            }
            .frame(height: 160)
            .listStyle(.plain)
        }
    }
}


struct RateMyApp: View {
    var body: some View {
        Text("Thanks")
    }
}

struct FacebookPage: View {
    var body: some View {
        Text("Facebook")
    }
}

struct PrivacyPolicyPage: View {
    var body: some View {
        Text("Here are the terms and conditions")
    }
}


//MARK: - Header
struct SettingsHeader: View {
    
    var settingType: SettingType
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                settingType.image
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.pink)
                Text(settingType.rawValue.capitalized)
                    .font(.title3)
                    .fontWeight(.semibold)
            }.padding(.horizontal)
            Rectangle()
                .fill(.black)
                .frame(height: 1)
                .padding(.horizontal)
        }
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


//MARK: - Preview
struct SettingsPage_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SettingsPage()
        }
    }
    
}
