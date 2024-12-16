//
//  FirebaseManager.swift
//  calendarTest
//
//  Created by David Medina on 9/23/24.
//

import Foundation
import Firebase
import FirebaseDatabase

class FirebaseManager {
    static let shared = FirebaseManager()
    let ref: DatabaseReference

    private init() {
        ref = Database.database().reference()
    }
    
    func fetchUserByName(username: String) async throws -> String {
<<<<<<< Updated upstream
        let userRef = ref.child("usernames").child(username)
        let snapshot = try await userRef.getData()
        
        print(snapshot.value ?? "No data")
        
        guard let id = snapshot.value as? String else {
            throw FirebaseError.failedToFetchUser
        }
        
        return id
=======
        let userRef = ref.child("users")
            .queryOrdered(byChild: "username")
            .queryEqual(toValue: username)
        
        let snapshot = try await userRef.getData()
        
        guard let userData = snapshot.value as? [String: Any] else {
            throw FirebaseError.failedToFetchUser
        }
        
        // only create a user object if we receive all parameters from the DB
        if
            let id = userData["id"] as? String {
            
            return id
            
        } else {
            throw UserError.invalidData
        }
        
>>>>>>> Stashed changes
    }
    
    func fetchUserAsync(id: String) async throws -> User {
        
        // Store a reference to the child node of the users node in the Firebase DB
        let userRef = ref.child("users").child(id)
        
        // getData is a Firebase function that returns a DataSnapshot object
        let snapshot = try await userRef.getData()
        
        // The DataSnapshot object is returned as an object with key value pairs as Strings
        guard let userData = snapshot.value as? [String: Any] else {
            throw FirebaseError.failedToFetchUser
        }
        
        // only create a user object if we receive all parameters from the DB
        
        let schedules = userData["schedules"] as? [String] ?? []
        let profileImage = userData["profileImage"] as? String ?? ""
        let requestIds = userData["incomingRequests"] as? [String : Bool] ?? [:]
        let friendIds = userData["friends"] as? [String : Bool] ?? [:]
        
        if
            let id = userData["id"] as? String,
            let username = userData["username"] as? String,
            let email = userData["email"] as? String,
<<<<<<< Updated upstream
            let createdAt = userData["creationDate"] as? Double {
            
            let user = User(id: id, username: username, email: email, schedules: schedules, profileImage: profileImage, requestIds: Array(requestIds.keys), friendIds: Array(friendIds.keys), creationDate: createdAt)
            
=======
            let schedules = userData["scheduleIds"] as? [String],
            let profileImage = userData["profileImage"] as? String,
            let createdAt = userData["creationDate"] as? Double {
            
            let user = User(id: id, username: username, email: email, schedules: schedules, profileImage: profileImage, creationDate: createdAt)
>>>>>>> Stashed changes
            return user
            
        } else {
            throw UserError.invalidData
        }
    }
    
    func observeUserChanges(id: String, completion: @escaping (User?) -> Void) -> DatabaseHandle {
        let userRef = ref.child("users").child(id)
        return userRef.observe(.value) { snapshot, _ in
            guard let userData = snapshot.value as? [String: Any] else {
                completion(nil)
                return
            }
            
            let schedules = userData["schedules"] as? [String] ?? []
            let profileImage = userData["profileImage"] as? String ?? ""
            let requestIds = userData["incomingRequests"] as? [String : Bool] ?? [:]
            let friendIds = userData["friends"] as? [String : Bool] ?? [:]
            
            if
                let id = userData["id"] as? String,
                let username = userData["username"] as? String,
                let email = userData["email"] as? String,
                let createdAt = userData["creationDate"] as? Double {
                
                let user = User(id: id, username: username, email: email, schedules: schedules, profileImage: profileImage, requestIds: Array(requestIds.keys), friendIds: Array(friendIds.keys), creationDate: createdAt)
                completion(user)
                
            } else {
                completion(nil)
            }
        }
    }
    
    func removeUserObserver(handle: DatabaseHandle) {
        let userRef = ref.child("users")  // assuming 'ref' is your database reference
        userRef.removeObserver(withHandle: handle)
    }
    
    func saveNewUserAsync(userData: User) async throws -> Void {
        
        let id = userData.id
        
        let encoder = JSONEncoder()
        do {
            // Encode the User object into JSON data
            let jsonData = try encoder.encode(userData)
            
            // Convert JSON data to a dictionary
            guard let jsonDictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
                throw UserError.serializationFailed
            }
            
            let updates: [String : Any] = [
                "/users/\(id)" : jsonDictionary,
                "/usernames/\(userData.username)" : id
            ]
            
            // Given that we have valid JSON dictionary, let's write to the DB
            try await ref.updateChildValues(updates)
            return
            
        } catch {
            throw FirebaseError.failedToCreateUser
        }
        
    }
    
    func fetchScheduleAsync(id: String) async throws -> Schedule {
        
        // Store a reference to the child node of the schedules node in the Firebase DB
        let scheduleRef = ref.child("schedules").child(id)
            
        // getData is a Firebase function that returns a DataSnapshot object
        let snapshot = try await scheduleRef.getData()
        
        // The DataSnapshot object is returned as an object with key value pairs as Strings
        guard let scheduleData = snapshot.value as? [String: Any] else {
            throw FirebaseError.failedToFetchSchedule
        }
        
        // only create a user object if we receive all parameters from the DB
        
        let events = scheduleData["eventIds"] as? [String : Bool] ?? [:]
        
        if
            let id = scheduleData["id"] as? String,
            let userId = scheduleData["userId"] as? String,
            let title = scheduleData["title"] as? String,
            let createdAt = scheduleData["creationDate"] as? Double {
            
            let schedule = Schedule(id: id, userId: userId, events: Array(events.keys), title: title, creationDate: createdAt)
            return schedule
            
        } else {
            throw ScheduleError.invalidScheduleData
        }
        
    }
    
    func createNewScheduleAsync(scheduleData: Schedule, userId: String) async throws -> String {
        
        var copyScheduleData = scheduleData
        let id = ref.child("schedules").childByAutoId().key ?? UUID().uuidString
        let createdAt = Date().timeIntervalSince1970
        copyScheduleData.id = id
        copyScheduleData.creationDate = createdAt
        
        let encoder = JSONEncoder()
        do {
            // Encode the Schedule object into JSON data
            let jsonData = try encoder.encode(copyScheduleData)
            
            // Convert JSON data to a dictionary
            guard let jsonDictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
                throw ScheduleError.scheduleDataSerializationFailed
            }
            
            let updates: [String: Any] = [
                "/schedules/\(id)" : jsonDictionary
            ]
            
            try await ref.updateChildValues(updates)
            return id
            
        } catch {
            throw FirebaseError.failedToCreateSchedule
        }
        
    }
    
    func fetchEventAsync(id: String) async throws -> Event {
        
        // Store a reference to the child node of the events node in the Firebase DB
        let eventRef = ref.child("events").child(id)
            
        // getData is a Firebase function that returns a DataSnapshot object
        let snapshot = try await eventRef.getData()
        
        // The DataSnapshot object is returned as an object with key value pairs as Strings
        guard let eventData = snapshot.value as? [String: Any] else {
            throw FirebaseError.failedToFetchEvent
        }
        
        // only create a user object if we receive all parameters from the DB
        if
            let id = eventData["id"] as? String,
            let scheduleId = eventData["scheduleId"] as? String,
            let title = eventData["title"] as? String,
            let description = eventData["description"] as? String,
            let startTime = eventData["startTime"] as? Double,
            let endTime = eventData["endTime"] as? Double,
            let createdAt = eventData["creationDate"] as? Double {
            
            let event = Event(id: id, scheduleId: scheduleId, title: title, description: description, startTime: startTime, endTime: endTime, creationDate: createdAt)
            return event
            
        } else {
            throw EventError.invalidEventData
        }

    }
    
    func fetchEventsForScheduleAsync(eventIDs: [String]) async throws -> [Event] {
        var events: [Event] = []
        
        if eventIDs.isEmpty {
            return events
        } else {
            // Use TaskGroup for concurrency
            try await withThrowingTaskGroup(of: Event.self) { group in
                for id in eventIDs {
                    group.addTask {
                        try await self.fetchEventAsync(id: id)
                    }
                }
                
                // Collect all results
                for try await event in group {
                    events.append(event)
                }
            }
            
            return events
        }
    }
    
    func createNewEventAsync(eventData: Event) async throws -> Event {
        var copyEventData = eventData
        let id = ref.child("events").childByAutoId().key ?? UUID().uuidString

        copyEventData.id = id
        
        
//        let scheduleRef = ref.child("schedules").child(copyEventData.scheduleId).child("eventIds")
        
        let encoder = JSONEncoder()
        do {
            // Encode the Schedule object into JSON data
            let jsonData = try encoder.encode(copyEventData)
            
            // Convert JSON data to a dictionary
            guard let jsonDictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
                throw EventError.eventDataSerializationFailed
            }
            
//            let snapshot = try await scheduleRef.getData()
//            var eventIds = (snapshot.value as? [String]) ?? []
//            
//            // Append new event ID
//            eventIds.append(id)
            
            // Create updates dictionary
            let updates: [String: Any] = [
                "/events/\(id)": jsonDictionary,
                "/schedules/\(copyEventData.scheduleId)/eventIds/\(id)": true
            ]
            
            // Perform atomic update
            try await ref.updateChildValues(updates)
            return copyEventData
            
        } catch {
            throw FirebaseError.failedToCreateEvent
        }
    }
    
<<<<<<< Updated upstream
    func createPostAsync(postData: Post, userId: String, friendIds: [String]) async throws {
        var copyPostData = postData
=======
    func createPostAsync(postData: Post, userId: String, friendIds: [String]) async throws -> Post {
        let copyPostData = postData
>>>>>>> Stashed changes
        let id = ref.child("posts").childByAutoId().key ?? UUID().uuidString
        copyPostData.id = id
        
        // Update feeds for each friend
        var feedUpdates: [String: Any] = [:]
        for friendId in friendIds {
            feedUpdates["feeds/\(friendId)/\(id)"] = postData.creationDate
        }
        
        let encoder = JSONEncoder()
        do {
            // Encode the Post object into JSON data
            let jsonData = try encoder.encode(copyPostData)
            
            // Convert JSON data to a dictionary
            guard let jsonDictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
                throw PostError.postDataSerializationFailed
            }
            
            feedUpdates["posts/\(id)"] = jsonDictionary
            feedUpdates["user-posts/\(userId)/\(id)"] = true
            
            try await ref.updateChildValues(feedUpdates)
<<<<<<< Updated upstream
=======
            return copyPostData
>>>>>>> Stashed changes
        } catch {
            throw FirebaseError.failedToCreatePost
        }
    }
    
<<<<<<< Updated upstream
    @MainActor
=======
>>>>>>> Stashed changes
    func fetchPostAsync(id: String) async throws -> Post {
        let postsRef = ref.child("posts").child(id)
        let snapshot = try await postsRef.getData()
        
<<<<<<< Updated upstream
        // Capture all the data first
=======
        // The DataSnapshot object is returned as an object with key value pairs as Strings
>>>>>>> Stashed changes
        guard let postData = snapshot.value as? [String: Any] else {
            throw FirebaseError.failedToFetchPost
        }
        
<<<<<<< Updated upstream
        // Get all values before creating Post
        guard
            let id = postData["id"] as? String,
            let title = postData["title"] as? String,
            let description = postData["description"] as? String,
            let likes = postData["likes"] as? Int,
            let eventLocation = postData["eventLocation"] as? String,
            let creationDate = postData["creationDate"] as? Double
        else {
            throw PostError.invalidPostData
        }
        
        let eventPhotos = postData["eventPhotos"] as? [String] ?? []
        let taggedUsers = postData["taggedUsers"] as? [String] ?? []
        let comments = postData["comments"] as? [String] ?? []

        // Create post on main thread since this is a @MainActor function
        return await MainActor.run {
            Post(
                id: id,
                title: title,
                description: description,
                eventPhotos: eventPhotos,
                comments: comments,
                likes: Double(likes),  // Convert Int to Double since your Post model uses Double
                taggedUsers: taggedUsers,
                eventLocation: eventLocation,
                creationDate: creationDate
            )
        }
    }
    
    @MainActor
    func fetchFriendsPosts(id: String) async throws -> [Post] {
        let postsRef = ref.child("feeds").child(id)
        let snapshot = try await postsRef.getData()
        
        guard let result = snapshot.value as? [String: Double] else {
            throw FirebaseError.failedToFetchFriendsPostsIds
        }
        
        let postIds: [String] = Array(result.keys)
        var posts: [Post] = []
        
        if postIds.isEmpty {
            return posts
        }
        
        // Create posts in batches
        try await withThrowingTaskGroup(of: Post.self) { group in
            for id in postIds {
                group.addTask {
                    try await self.fetchPostAsync(id: id)
                }
                
                // Collect results in batches
=======
        // only create a post object if we receive all parameters from the DB
        if
            let id = postData["id"] as? String,
            let title = postData["title"] as? String,
            let description = postData["description"] as? String,
            let eventPhotos = postData["eventPhotos"] as? [String],
            let likes = postData["liked"] as? Int,
            let comments = postData["comments"] as? [Comment],
            let permission = postData["permission"] as? Bool,
            let taggedUsers = postData["taggedUsers"] as? [String],
            let eventLocation = postData["eventLocation"] as? String,
            let creationDate = postData["creationDate"] as? Double {
            
            let post = Post(id: id, title: title, description: description, eventPhotos: eventPhotos, comments: comments, likes: likes, permission: permission, taggedUsers: taggedUsers, eventLocation: eventLocation, creationDate: creationDate)
            return post
            
        } else {
            throw PostError.invalidPostData
        }
        
    }
    
    func fetchFriendsPosts(id: String) async throws -> [Post] {
        var posts: [Post] = []
        let postsRef = ref.child("feeds").child(id)
        
        let snapshot = try await postsRef.getData()
        
        guard let postIds = snapshot.value as? [String: Any] else {
            throw FirebaseError.failedToFetchFriendsPostsIds
        }
        
        if postIds.isEmpty {
            return posts
        } else {
            // Use TaskGroup for concurrency
            try await withThrowingTaskGroup(of: Post.self) { group in
                for (id, _) in postIds {
                    group.addTask {
                        try await self.fetchPostAsync(id: id)
                    }
                }
                
                // Collect all results
>>>>>>> Stashed changes
                for try await post in group {
                    posts.append(post)
                }
            }
<<<<<<< Updated upstream
        }
        
        return posts
    }
    
    func fetchIncomingFriendRequest(id: String) async throws -> FriendRequests {
        let requestRef = ref.child("friendRequests").child(id)
        
        let snapshot = try await requestRef.getData()
        
        guard let requestData = snapshot.value as? [String: Any] else {
            throw FirebaseError.failedToFetchFriendsPostsIds
        }
        
        guard
            let fromUserId = requestData["fromUserId"] as? String,
            let toUserId = requestData["toUserId"] as? String,
            let status = requestData["status"] as? String,
            let senderName = requestData["senderName"] as? String,
            let senderProfileImage = requestData["senderProfileImage"] as? String
        else {
            throw FirebaseError.failedToFetchFriendsPostsIds
        }
        
        return await MainActor.run {
            FriendRequests(
                id: id,
                fromUserId: fromUserId,
                toUserId: toUserId,
                status: status,
                senderName: senderName,
                sendProfileImage: senderProfileImage)
        }
        
    }
    
    func fetchIncomingFriendRequests(requestIds: [String]) async throws -> [FriendRequests] {
        
        var requests: [FriendRequests] = []
        
        if requestIds.isEmpty {
            return requests
        } else {
            try await withThrowingTaskGroup(of: FriendRequests.self) { group in
                for id in requestIds {
                    group.addTask {
                        try await self.fetchIncomingFriendRequest(id: id)
                    }
                }
                
                for try await request in group {
                    requests.append(request)
                }
            }
            
            print(requests)
            return requests
        }
    }
    
    func handleFriendRequest(fromUserObj: User, toUserName: String) async throws -> Void {
        let otherUserId = "1PX5iLyRh2PAQ1byEYSAPqo2bbn1"
        let requestId = "\(fromUserObj.id)_\(otherUserId)"
        print(otherUserId)
        print(fromUserObj.id)
=======
            
            return posts
        }
        
    }
    
    func handleFriendRequest(fromUserObj: User, toUserName: String) async throws {
        let otherUserId = try await fetchUserByName(username: toUserName)
        let requestId = "\(fromUserObj.id)_\(otherUserId)"
>>>>>>> Stashed changes
        
        let request: [String: Any] = [
            "fromUserId": fromUserObj.id,
            "toUserId": otherUserId,
            "status" : "pending",
<<<<<<< Updated upstream
            "timestamp": Date().timeIntervalSince1970,
=======
            "timestamp": ServerValue.timestamp,
>>>>>>> Stashed changes
            "senderName": fromUserObj.username,
            "senderProfileImage": fromUserObj.profileImage ?? ""
        ]
        
        do {
            try await ref.child("friendRequests").child(requestId).setValue(request)
            try await ref.child("users").child(otherUserId).child("incomingRequests").child(requestId).setValue(true)
            try await ref.child("users").child(fromUserObj.id).child("outgoingRequests").child(requestId).setValue(true)
        } catch {
            throw FirebaseError.failedToHandleFriendRequest
        }
    }
    
<<<<<<< Updated upstream
    func handleFriendRequestResponse(requestId: String, response: Bool) async throws -> Void {
=======
    func handleFriendRequestResponse(requestId: String, response: Bool) async throws {
>>>>>>> Stashed changes
        let requestInfo = requestId.split(separator: "_")
        
        if requestInfo.count == 2 {
            let fromUserId = String(requestInfo[0])
            let toUserId = String(requestInfo[1])
                    
            if response {
                
                let queryRequest: [String: Any] = [
                    "/friendRequests/\(requestId)/status": "accepted",
                    "/users/\(toUserId)/friends/\(fromUserId)": true,
                    "/users/\(fromUserId)/friends/\(toUserId)": true,
                    "/users/\(toUserId)/incomingRequests/\(requestId)": NSNull(),
                    "/users/\(fromUserId)/outgoingRequests/\(requestId)": NSNull()
                ]
                
                do {
                    try await ref.updateChildValues(queryRequest)
                } catch {
                    throw FirebaseError.failedToUpdateFriendRequest
                }
            } else {
                
                let queryRequest: [String: Any] = [
                    "/friendRequests/\(requestId)/status": "declined",
                    "/users/\(toUserId)/incomingRequests/\(requestId)": NSNull(),
                    "/users/\(fromUserId)/outgoingRequests/\(requestId)": NSNull()
                ]
                
                do {
                    try await ref.updateChildValues(queryRequest)
                } catch {
                    throw FirebaseError.failedToUpdateFriendRequest
                }
            }
            
        } else {
            throw FirebaseError.incorrectFriendRequestId
        }
    }
    
}
