//
//  FriendsView.swift
//  calendarTest
//
//  Created by David Medina on 12/12/24.
//

import SwiftUI

struct FriendCell: View {
   var username: String
   
   var body: some View {
       HStack(spacing: 12) {
           // Profile circle with first letter
           Circle()
               .fill(Color.blue.opacity(0.1))
               .frame(width: 50, height: 50)
               .overlay(
                   Text(String(username.prefix(1)).uppercased())
                       .font(.title2)
                       .fontWeight(.semibold)
                       .foregroundColor(.blue)
               )
           
           VStack(alignment: .leading, spacing: 4) {
               Text(username)
                   .font(.headline)
               
               Text("Friend")
                   .font(.subheadline)
                   .foregroundStyle(.gray)
           }
           
           Spacer()
           
           // Message/Connect button
           Button(action: {
               // Handle message/connect action
           }) {
               Image(systemName: "message.fill")
                   .foregroundStyle(.blue)
                   .padding(8)
                   .background(Color.blue.opacity(0.1))
                   .clipShape(Circle())
           }
       }
       .padding()
       .background(Color.gray.opacity(0.05))
       .clipShape(RoundedRectangle(cornerRadius: 12))
       .padding(.horizontal)
   }
}

struct FriendsView: View {
   @State private var searchText = ""
    @StateObject var viewModel: NotificationViewModel
    @EnvironmentObject var userObj: AuthService

    init(viewModel: NotificationViewModel = NotificationViewModel()) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
   
   var body: some View {
       VStack(spacing: 0) {
           // Search bar
           HStack {
               Button(action: {
                   if let user: User = userObj.currentUser {
                       viewModel.sendFriendRequest(toUserName: searchText, fromUserObj: user)
                       print("Friend Request Sent From: \(user.username)")
                       print("Friend Request Sent To: \(searchText)")
                   }
               }) {
                   Image(systemName: "magnifyingglass")
                       .foregroundStyle(.gray)
               }
               
               TextField("Search friends", text: $searchText)
                   .textFieldStyle(.plain)
               
               if !searchText.isEmpty {
                   Button(action: { searchText = "" }) {
                       Image(systemName: "xmark.circle.fill")
                           .foregroundStyle(.gray)
                   }
               }
           }
           .padding()
           .background(Color.gray.opacity(0.1))
           .clipShape(RoundedRectangle(cornerRadius: 12))
           .padding()
           
           // Friend list
           ScrollView {
               VStack(spacing: 12) {
                   // Filter friends based on search text
                   if searchText.isEmpty {
                       FriendCell(username: "JohnDoe")
                       FriendCell(username: "SarahSmith")
                       FriendCell(username: "MikeJones")
                   } else {
                       // Show filtered results
                       let filtered = ["JohnDoe", "SarahSmith", "MikeJones"].filter {
                           $0.lowercased().contains(searchText.lowercased())
                       }
                       
                       if filtered.isEmpty {
                           Text("No results found")
                               .foregroundStyle(.gray)
                               .padding(.top)
                       } else {
                           ForEach(filtered, id: \.self) { username in
                               FriendCell(username: username)
                           }
                       }
                   }
               }
           }
       }
   }
}
