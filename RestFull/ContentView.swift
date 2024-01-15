//
//  ContentView.swift
//  RestFull
//
//  Created by ahmad kaddoura on 1/15/24.
//

import SwiftUI
import CoreML

struct ContentView: View {
    
    @State private var wakeup = defaultWakeTime
    @State private var sleepAmount : Double = 7
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showAlert = false
    
    static var defaultWakeTime : Date{
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    var body: some View {
        NavigationStack{
            
            VStack {
                Text("Set wake up time")
                    .font(.headline)
                DatePicker("Time",selection: $wakeup,displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .padding()
                Stepper("Amount of Sleep:   \(sleepAmount.formatted()) hours", value: $sleepAmount,in: 4...12, step: 0.25)
                    .fontWeight(.bold)
                Stepper("Amount of Coffee:   \(coffeeAmount.formatted()) \(coffeeAmount == 1 ? "cup" : "cups")" , value: $coffeeAmount,in: 0...20, step: 1)
                    .fontWeight(.bold)
            }
            .padding()
            .navigationTitle("RestFull")
            .toolbar{
                Button("Calc", action: calculateBedtime)
            }
            .alert(alertTitle,isPresented: $showAlert){
                Button("ok"){}
            }message: {
                Text(alertMessage)
            }
        }
    }
        func calculateBedtime() {
            do {
                let config = MLModelConfiguration()
                let model = try SleepCalculator(configuration: config)
                
                let components = Calendar.current.dateComponents([.hour, .minute], from: wakeup)
                let hour = (components.hour ?? 0) * 60 * 60
                let minute = (components.minute ?? 0) * 60
                
                let prediction = try model.prediction(wake: Int64(Double(hour + minute)), estimatedSleep: sleepAmount, coffee: Int64(Double(coffeeAmount)))
                
                let sleepTime = wakeup - prediction.actualSleep
                
                alertTitle = "Your ideal bedtime is…"
                alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
            } catch {
                alertTitle = "Error"
                alertMessage = "Sorry, there was a problem calculating your bedtime."
            }
            
            showAlert = true
        
    }
}
#Preview {
    ContentView()
}
