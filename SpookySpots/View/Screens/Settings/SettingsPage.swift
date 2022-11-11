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
    
    let weenyWitch = K.Colors.WeenyWitch.self
    
    var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 50) {
                Account()
//                    .padding(.bottom, 20)
                about
                admin
                addLocationView
            }
            .padding(.vertical, 30)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(false)
        }
            .background(weenyWitch.black)
    }
    
    
    //MARK: - About
    private var about: some View {
        VStack {
            SettingsHeader(settingType: .about)
            List {
                // rateApp
//                    .listRowBackground(weenyWitch.black)
                privacyPolicy
                    .listRowBackground(weenyWitch.black)
                termsOfUse
                    .listRowBackground(weenyWitch.black)

                    .padding(.bottom)
            }
            .listStyle(.plain)
            .frame(minHeight: 80)
            .modifier(ListBackgroundModifier())
        }

    }
    
//    private var rateApp: some View {
//        NavigationLink(destination: RateMyApp()) {
//            Text("Rate SpookySpots")
//                .foregroundColor(weenyWitch.lighter)
//        }.listRowSeparator(.hidden)
//    }
    
    private var privacyPolicy: some View {
        let view: AnyView
        if let url = URL(string: "https://pages.flycricket.io/spookyspots/privacy.html") {
            view = AnyView(
                Link(destination: url, label: {
                    Text("Privacy Policy")
                        .foregroundColor(weenyWitch.lighter)
                })
            )
        } else {
            view = AnyView(EmptyView())
        }
        return view
    }
    
    private var termsOfUse: some View {
        let view: AnyView
        if let url = URL(string: "https://pages.flycricket.io/spookyspots/terms.html") {
            view = AnyView(
                Link(destination: url, label: {
                    Text("Terms Of Use")
                        .foregroundColor(weenyWitch.lighter)
                })
            )
        } else {
            view = AnyView(EmptyView())
        }
        return view
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
                        .foregroundColor(weenyWitch.lighter)
                    
                }.listRowSeparator(.hidden)
                    .listRowBackground(weenyWitch.black)
            }
            .modifier(ListBackgroundModifier())
            .frame(minHeight: 50)
            .listStyle(.plain)
        }
    }
    
    //MARK: - Add Location
    private var addLocationView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Know of any spooky locations not listed that you would like to share?")
                .foregroundColor(weenyWitch.light)
                .italic()
            NavigationLink {
                AddLocationView()
            } label: {
                Text("Submit basic information")
                    .foregroundColor(weenyWitch.orange)
                    .underline()
            }

        }
        .padding(.horizontal)
    }
    
}

//MARK: - Header
struct SettingsHeader: View {
    
    var settingType: SettingType
    
    let weenyWitch = K.Colors.WeenyWitch.self
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                settingType.image
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(weenyWitch.orange)
                Text(settingType.rawValue.capitalized)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(weenyWitch.lighter)
            }.padding(.horizontal)
            Rectangle()
                .fill(weenyWitch.orange)
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
