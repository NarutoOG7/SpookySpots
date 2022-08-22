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
                addLocationView
            }
            .padding(.vertical, 30)
            .navigationTitle("Settings")
            .navigationBarHidden(false)
//        }
        }
            .background(K.Colors.WeenyWitch.black)
    }
    
    //MARK: - About
    
    private var about: some View {
        VStack {
            SettingsHeader(settingType: .about)
            List {
                NavigationLink(destination: RateMyApp()) {
                    Text("Rate SpookySpots")
                        .foregroundColor(K.Colors.WeenyWitch.lighter)
                }.listRowSeparator(.hidden)
                    .listRowBackground(K.Colors.WeenyWitch.black)
                NavigationLink(destination: PrivacyPolicyPage()) {
                    Text("Privacy Policy")
                        .foregroundColor(K.Colors.WeenyWitch.lighter)
                }                    .listRowSeparator(.hidden)
                    .listRowBackground(K.Colors.WeenyWitch.black)
            }
            .frame(height: 120)
            .listStyle(.plain)
        }

    }
    
    //MARK: - Admin
    
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
                NavigationLink(destination: DatabaseView()) {
                    Text("Database")
                        .foregroundColor(K.Colors.WeenyWitch.lighter)
                    
                }.listRowSeparator(.hidden)
                    .listRowBackground(K.Colors.WeenyWitch.black)
            }
            .frame(height: 50)
            .listStyle(.plain)
        }
    }
    
    //MARK: - Add Location
    private var addLocationView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Know of any spooky locations not listed that you would like to share?")
                .foregroundColor(K.Colors.WeenyWitch.light)
                .italic()
            NavigationLink {
                AddLocationView()
            } label: {
                Text("Submit basic information")
                    .foregroundColor(K.Colors.WeenyWitch.orange)
                    .underline()
            }

        }
        .padding()
    }
}


struct RateMyApp: View {
    var body: some View {
        Text("Thanks")
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
                    .foregroundColor(K.Colors.WeenyWitch.orange)
                Text(settingType.rawValue.capitalized)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(K.Colors.WeenyWitch.lighter)
            }.padding(.horizontal)
            Rectangle()
                .fill(K.Colors.WeenyWitch.orange)
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
