//
//  ContentView.swift
//  collatz
//
//  Created by Stuart Breckenridge on 03/06/2021.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var model = CollatzViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(model.collatzResults, id: \.key , content: { item in
                        VStack(alignment: .leading) {
                            Text(String(describing: item.key)).bold()
                            Text(String(describing: item.value))
                        }
                        Divider()
                    })
                }.padding()
            }
            .navigationBarItems(leading: loadingView(),
                                trailing: Menu(content: {
                                    ForEach(CollatzCount.allCases, content: { item in
                                        Button(action: {
                                            model.selectedCount = item
                                        }, label: {
                                            Label(
                                                title: { Text(String(describing: item.value)) },
                                                icon: { model.selectedCount == item ? AnyView(Image(systemName: "checkmark")) : AnyView(EmptyView())})
                                        })
                                    })
                                    Button(action: {
                                            model.collatzResults.removeAll()
                                    }, label: {
                                        Text("Clear")
                                    })
                                }, label: {
                                    Text("Select")
                                }))
            .navigationTitle(Text("Collatz"))
            .onAppear(perform: {
                detach {
                    await model.getCollatz()
                }
            })
            .onChange(of: model.selectedCount, perform: { _ in
                detach {
                    await model.getCollatz()
                }
            })
        }
    }
    
    func loadingView() -> AnyView {
        model.isLoading ? AnyView(prog()) : AnyView(EmptyView())
    }
    
    func prog() -> some View {
        ProgressView(value: model.loadingPercent)
            .frame(width: 50)
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
