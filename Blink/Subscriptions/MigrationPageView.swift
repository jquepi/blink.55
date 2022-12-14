////////////////////////////////////////////////////////////////////////////////
//
// B L I N K
//
// Copyright (C) 2016-2019 Blink Mobile Shell Project
//
// This file is part of Blink.
//
// Blink is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Blink is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Blink. If not, see <http://www.gnu.org/licenses/>.
//
// In addition, Blink is also subject to certain additional terms under
// GNU GPL version 3 section 7.
//
// You should have received a copy of these additional terms immediately
// following the terms and conditions of the GNU General Public License
// which accompanied the Blink Source Code. If not, see
// <http://www.github.com/blinksh/blink>.
//
////////////////////////////////////////////////////////////////////////////////

import Foundation
import SwiftUI
import Purchases
import Network

struct MigrationPageView: Page {
  
  @ObservedObject private var _model: PurchasesUserModel = .shared
  @ObservedObject private var _entitlements: EntitlementsManager = .shared
  
  
  var horizontal: Bool
  var switchTab: (_ idx: Int) -> ()
  
  init(horizontal: Bool, switchTab: @escaping (Int) -> ()) {
    self.horizontal = horizontal
    self.switchTab = switchTab
  }
  
  var body: some View {
    VStack(alignment: .leading) {
      header()
      Spacer().frame(maxHeight: horizontal ? 20 : 30)
      rows()
      Spacer().frame(maxHeight: horizontal ? 20 : 54)
      HStack {
        Spacer()
        if _model.dataCopied {
          Button("Close") {
            _model.closeMigration()
          }
          .buttonStyle(.borderedProminent)
        } else if _entitlements.unlimitedTimeAccess.active == true {
          Button("Migrate Data") {
            _model.startDataMigration()
          }
          .buttonStyle(.borderedProminent)
          .alert(errorMessage: $_model.alertErrorMessage)
        } else if _model.zeroPriceUnlocked {
          if _model.purchaseInProgress {
            ProgressView()
          } else {
            Button("Unlock with $0 Price") {
              _model.purchaseClassic()
            }
            .buttonStyle(.borderedProminent)
            .alert(errorMessage: $_model.alertErrorMessage)
          }
        } else {
          Button("Start Migration") {
            _model.startMigration()
          }
          .buttonStyle(.borderedProminent)
          .alert(errorMessage: $_model.alertErrorMessage)
        }
        Spacer()
      }
      Spacer()
      HStack {
        Spacer()
        Button {
          _model.openMigrationHelp();
        } label: {
          Label("Migration help", systemImage: "questionmark.circle.fill")
        }.padding(.trailing)
        Button("Privacy Policy", action: {
          _model.openPrivacyAndPolicy()
        }).padding(.trailing)
        Button("Terms of Use", action: {
          _model.openTermsOfUse()
        })
        Spacer()
      }.multilineTextAlignment(.center)
      .font(.footnote)
      .padding(.bottom, self.horizontal ? 32 : 40)
      
    }.padding()
      .frame(maxWidth: horizontal ? 700 : 460)      
  }
  
  func header() -> some View {
    Group {
      Spacer()
      Text("Migration Assistant")
        .fontWeight(.bold)
        .font(.largeTitle)
      
      Spacer().frame(maxHeight: horizontal ? 24 : 30)
      
      Text("Make yourself at home in three simple steps.")
        .font(.title2)
    }
  }
  
  func rows() -> some View {
    GroupBox() {
      CheckmarkRow(text: "Verify receipt within Blink Shell 14 app.", checked: _model.receiptIsVerified, failed: _model.receiptVerificationFailed)
      Spacer().frame(maxHeight: 10)
      CheckmarkRow(text: "Unlock Zero cost lifetime purchase.", checked: _model.zeroPriceUnlocked)
      Spacer().frame(maxHeight: 10)
      CheckmarkRow(text: "Copy settings from Blink Shell 14 app.", checked: _model.dataCopied, failed: _model.dataCopyFailed)
    }
  }
}
