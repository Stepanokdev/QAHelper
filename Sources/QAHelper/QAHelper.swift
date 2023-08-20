//public struct QAHelper {
//    public private(set) var text = "Hello, World!"
//
//    public init() {
//    }
//}

import SwiftUI

struct ConsoleModel {
    var text: String
    var color: Color
}

public class QAModel: ObservableObject {
    
    @Published var console: [ConsoleModel] = []
    
    public func Print(_ string: String?, color: Color = .white) {
        guard let string else { return }
        DispatchQueue.main.async {
            self.console.append(ConsoleModel(text: string, color: color))
        }
    }
        
}

public let QA = QAModel()

public struct QAPanelView<Content: View>: View {
    
    @State var expand: Bool = false
    @Namespace var namespace
    
    @ObservedObject var QAModel: QAModel
    
    @State var geometry: GeometryProxy?
    @State private var DragXPosition: CGFloat = 0
    @State private var OldDragXPosition: CGFloat = 0
    @State private var DragYPosition: CGFloat = 180
    @State var alignment: Alignment = .topLeading
    @State var padding: Edge.Set = .leading
    private var idiom: UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
    
    let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.QAModel = QA
        self.content = content()
    }
    
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 30, coordinateSpace: .local)
            .onChanged { value in
                    DragYPosition = value.location.y - 25
                if !expand {
                    DragXPosition = value.location.x - 40
                }
            }
            .onEnded { value in
                let horizontalLimit = geometry!.size.width - 90
                if value.location.y < 10 {
                    withAnimation {
                        DragYPosition = 5
                    }
                }
                if value.location.y > geometry!.size.height - 15 {
                    withAnimation {
                        DragYPosition = geometry!.size.height - 40
                    }
                }
                if value.location.x < geometry!.size.width / 2 {
                    withAnimation {
                        if !expand {
                            DragXPosition = 0
                            alignment = .topLeading
                            padding = .leading
                        }
                    }
                }
                if value.location.x > geometry!.size.width / 2 {
                    withAnimation {
                        if !expand {
                            DragXPosition = horizontalLimit
                            OldDragXPosition = horizontalLimit
                            alignment = .topTrailing
                            padding = .trailing
                        }
                        
                    }
                }
            }
    }
    
    public var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.clear
            GeometryReader { reader in
                ZStack(alignment: alignment) {
                    if expand {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(.black.opacity(0.6))
                                .matchedGeometryEffect(id: "bg", in: namespace)
                            VStack(alignment: .leading) {
                                VStack(alignment: .leading) {
                                    content
                                        .foregroundColor(Color.white)
                                    Text("Console:")
                                        .padding(.top, 8)
                                        .font(.system(size: 10, weight: .medium, design: .default))
                                        .foregroundColor(Color.white)
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 6)
                                            .foregroundColor(.black.opacity(0.4))
                                        ScrollViewReader { scroll in
                                            ScrollView {
                                                VStack(alignment: .leading, spacing: 10) {
                                                ForEach(Array(QAModel.console.enumerated()), id: \.offset) { index, print in
                                                    Text(LocalizedStringKey(print.text))
                                                        .foregroundColor(print.color)
                                                        .id(index)
                                                        .onAppear {
                                                            withAnimation {
                                                                scroll.scrollTo(index, anchor: .bottom)
                                                            }
                                                        }
                                                }
                                            }
                                        }
                                    }.frame(maxWidth: .infinity, maxHeight: 200, alignment: .leading)
                                        .padding(8)
                                        .foregroundColor(Color.white)
                                    
                                        .font(.system(size: 10, weight: .light, design: .default))
                                        }
                                }
                                        .fixedSize(horizontal: false, vertical: true)
                                
                            }
                            .frame(width: reader.size.width - 100)
                            .padding(10)
                            .padding(padding, 45)
                            }
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    VStack {
                        ZStack {
                            if !expand {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(.black.opacity(0.3))
                                    .matchedGeometryEffect(id: "bg", in: namespace)
                            }
                            Circle()
                                .frame(width: 25)
                                .foregroundColor(.white.opacity(0.5))
                            Circle()
                                .frame(width: 33)
                                .foregroundColor(.white.opacity(0.3))
                            Circle()
                                .frame(width: 40)
                                .foregroundColor(.white.opacity(0.3))
                        }.padding(.top, expand ? 7.5 : 0).padding(padding, expand ? 7.5 : 0)
                    }.onTapGesture {
                        withAnimation {
                            expand.toggle()
                            if padding == .trailing {
                                if expand {
                                    DragXPosition = 5
                                } else {
                                    DragXPosition = OldDragXPosition
                                }
                            }
                        }
                    }
                    
                    
                }.frame(width: expand ? nil : 55, height: 55)
                    .fixedSize(horizontal: true, vertical: true)
                    .padding(.vertical, expand ? 36 : 0)
                    .padding(.horizontal, 16)
                    .offset(x: DragXPosition, y: DragYPosition)
                    .gesture(dragGesture)
                    .onAppear {
                        self.geometry = reader
                    }
            }
        }

    }
}

struct AdminPanelView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.blue
                .ignoresSafeArea()
            QAPanelView() {
              Text("Test Content inside")
                Button("Test Button", action: {
                    
                })
                Text("Test Content with very very very long text")
                Text("Test Content inside")
            }
            .onAppear {
                QA.Print("""
{
  "status": "success",
  "data": {
    "user": {
      "id": 54321,
      "username": "sample_user",
      "email": "sample_user@example.com",
      "profile": {
        "avatar_url": "https://example.com/avatar.jpg",
        "followers": 1200,
        "following": 450,
        "bio": "Mocking the way to success!"
      }
    },
    "posts": [
      {
        "id": 123,
        "title": "Advanced Mocking Techniques",
        "content": "Exploring the intricacies of generating mock data.",
        "timestamp": "2023-08-20T10:15:30Z",
        "comments": [
          {
            "id": 987,
            "user": "commenter1",
            "text": "Great post, very informative!",
            "timestamp": "2023-08-20T11:30:45Z"
          },
          {
            "id": 876,
            "user": "commenter2",
            "text": "I learned a lot, thanks for sharing.",
            "timestamp": "2023-08-20T12:45:15Z"
          }
        ]
      },
      {
        "id": 456,
        "title": "Deep Dive into Mock APIs",
        "content": "Simulating realistic API responses for testing purposes.",
        "timestamp": "2023-08-19T14:20:00Z",
        "comments": [
          {
            "id": 765,
            "user": "commenter3",
            "text": "Looking forward to more content like this!",
            "timestamp": "2023-08-19T15:10:20Z"
          }
        ]
      }
    ]
  }
}

""")
                QA.Print("getMyProfile() ✅✅✅✅✅✅✅")
                QA.Print("""
{
  "status": "success",
  "data": {
    "user": {
      "id": 12345,
      "username": "mock_user",
      "email": "mock_user@example.com"
    },
    "posts": [
      {
        "id": 9876,
        "title": "Mock Post 1",
        "content": "This is a mock post generated for testing.",
        "timestamp": "2023-08-20 15:00:00"
      },
      {
        "id": 5432,
        "title": "Mock Post 2",
        "content": "Another mock post for testing purposes.",
        "timestamp": "2023-08-20 16:30:00"
      }
    ]
  }
}

""", color: .red)
            }
        }
    }
}
