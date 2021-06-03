//
//  CollatzViewModel.swift
//  collatz
//
//  Created by Stuart Breckenridge on 03/06/2021.
//

import Foundation
import Combine

public enum CollatzCount: CaseIterable, Identifiable {
    public var id: Int {
        value
    }
    
    case oneHundred, oneThousand, tenThousand, fiftyThousand, oneHundredThousand, oneMillion
    
    var value: Int {
        switch self {
        case .oneHundred:
            return 100
        case .oneThousand:
            return 1000
        case .tenThousand:
            return 10000
        case .fiftyThousand:
            return 50000
        case .oneHundredThousand:
            return 100000
        case .oneMillion:
            return 1000000
        }
    }
    
}


class CollatzViewModel: ObservableObject {
    
    @Published var collatzResults =  [Dictionary<Int, [Int]>.Element]()
    @Published var isLoading: Bool = false
    @Published var loadingPercent: Float = 0.0
    @Published var selectedCount: CollatzCount = .oneHundred
    
    func getCollatz() async {
        await toggleLoading()
        await publishCollatz(collatz())
        await toggleLoading()
    }
        
    @MainActor
    private func toggleLoading() {
        print(#function, "Started")
        isLoading.toggle()
        print(#function, "Finished")
    }
    
    @MainActor
    private func publishCollatz(_ collatz: [Int: [Int]]) {
        print(#function, "Started")
        collatzResults = collatz.sorted(by: { $0.key < $1.key})
        print(#function, "Finished")
    }
    
    @MainActor
    private func publishProgress(_ progress: Float) {
        print(#function, "Started")
        loadingPercent = progress
        print(#function, "Finished")
    }
    
    private func collatz() async -> [Int: [Int]] {
        print(#function, "Started")
        let sequence = Task { () -> [Int: [Int]]  in
            var collatzSequences = [Int: [Int]]()
            for i in (1...selectedCount.value).reversed() {
                collatzSequences[i] = await generateCollatzSequence(start: i)
                let progress = Float(selectedCount.value - i)/Float(selectedCount.value)
                DispatchQueue.main.async {
                    self.loadingPercent = progress
                }
            }
            return collatzSequences
        }
        print(#function, "Finished")
        return await sequence.value
    }
    
    
    private func generateCollatzSequence(start:Int, initial:Bool = true) async -> [Int] {
        await withCheckedContinuation { continuation in
            var n = start
            var sequence = [Int]()
            
            if initial == true {
                sequence.append(start)
            }
            
            if start == 1 {
                continuation.resume(returning: [start])
                return
            }
            
            while n != 1 {
                if n % 2 == 0 {
                    n /= 2
                    sequence.append(n)
                } else {
                    n = (3 * n) + 1
                    sequence.append(n)
                }
            }
            
            continuation.resume(returning: sequence)
        }
    }
    
}
