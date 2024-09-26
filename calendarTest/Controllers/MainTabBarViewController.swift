import SwiftUI

struct MainTabBarViewController: View {
    @EnvironmentObject var dateHolder: DateHolder
    var body: some View {
        TabView {
            FeedViewController()
                .tabItem {
                    Label("My Feed", systemImage: "house")
                        .font(.headline)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
            
            ScheduleViewController()
                .environmentObject(dateHolder)
                .tabItem {
                    Label("Schedule", systemImage: "calendar")
                        .font(.headline)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
            
            PlannerViewController()
                .tabItem {
                    Label("My Plans", systemImage: "square.and.pencil")
                        .font(.headline)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
            AccountViewController()
                .tabItem {
                    Label("My Account", systemImage: "person")
                        .font(.headline)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
        }
    }
}

#Preview {
    MainTabBarViewController()
        .environmentObject(DateHolder())
}