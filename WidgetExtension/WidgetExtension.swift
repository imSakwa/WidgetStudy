//
//  WidgetExtension.swift
//  WidgetExtension
//
//  Created by ChangMin on 2022/01/03.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: TimelineProvider {
    // 현재 시간이나 상태를 나타내는 타임라인 엔트리 제공
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(
            date: Date(),
            tasks: [Task(status: .request, title: "snapshot", assign: ["윙"])]
        )
        completion(entry)
    }
    
    // 현재 시간이나 위젯을 업데이트할 시간에 대한 타임라인 엔트리 배열을 제공
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        var entries: [SimpleEntry] = []
        let currentDate = Date()
        let tasks: [Task] = [
            Task(
                status: .request,
                title: "플로우 테크 세미나 준비",
                assign: ["나"]
            ),
            Task(
                status: .progress,
                title: "테크 세미나 피피티 자료 준비하기",
                assign: ["나"]
            ),
            Task(
                status: .feedback,
                title: "업무명의 길이가 길어진다면 어떻게 될까아아요?",
                assign: ["나"]
            ),
            Task(
                status: .complete,
                title: "이건 완료 업무",
                assign: ["나"]
            ),
            Task(
                status: .hold,
                title: "보류 업무",
                assign: ["나"]
            )
        ]
        
        // 3분마다 위젯 갱신
        for minuteOffset in 0 ..< 3 {
            let entryDate = Calendar.current.date(
                byAdding: .minute,
                value: minuteOffset,
                to: currentDate
            )!
            let entry = SimpleEntry(date: entryDate, tasks: tasks)
            
            entries.append(entry)
        }

        // policy에 따라 entries 값을 가지고 리로드 해주는 부분
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    // placeholder버전을 나타내는 타임라인 엔트리를 제공
    func placeholder(in context: Context) -> SimpleEntry {
        return SimpleEntry(
            date: Date(),
            tasks: [Task(status: .request, title: "placeholder", assign: ["윙"])]
        )
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let tasks: [Task]
}

struct TaskWidgetView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family: WidgetFamily
    
    var body: some View {
        switch family {
        case .systemMedium:
            TaskWidgetMedium(tasks: entry.tasks)
            
        case .systemLarge:
            TaskWidgetNewLarge(tasks: entry.tasks)
                .padding(.top)
            
        case .accessoryRectangular:
            TaskWidgetRectangle(tasks: entry.tasks)
                .frame(maxWidth: .infinity)
            
        default:
            Text("지원하지 않아요")
        }
    }
}

@available(iOSApplicationExtension 16.0, *)
@main
struct WidgetExtension: Widget {
    private let kind: String = "WidgetExtension"
    
    // 위젯 추가 화면
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: Provider()
        ) { entry in
            TaskWidgetView(entry: entry)
        }
        .configurationDisplayName("위젯 공부")
        .description("위젯 설명 블라블라블라")
        .supportedFamilies([
            .systemMedium,
            .systemLarge,
            .accessoryRectangular
        ])
    }
}

struct WidgetExtension_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TaskWidgetView(
                entry: SimpleEntry(date: Date(), tasks:  [
                    Task(status: .request, title: "snapshot", assign: ["윙"])
                ])
            )
            .previewContext(
                WidgetPreviewContext(family: .systemMedium)
            )
            .previewDisplayName("Medium Size")
            
            TaskWidgetView(
                entry: SimpleEntry(date: Date(), tasks: [
                    Task(status: .request, title: "snapshot", assign: ["윙"])
                ])
            )
            .previewContext(
                WidgetPreviewContext(family: .systemLarge)
            )
            .previewDisplayName("Large Size")
            
            if #available(iOSApplicationExtension 16.0, *) {
                TaskWidgetView(
                    entry: SimpleEntry(date: Date(), tasks: [
                        Task(status: .request, title: "snapshot", assign: ["윙"])
                    ])
                )
                .previewContext(
                    WidgetPreviewContext(family: .accessoryRectangular)
                )
                .previewDisplayName("Rectangular")
            } else {
                // Fallback on earlier versions
            }
        }
    }
}
