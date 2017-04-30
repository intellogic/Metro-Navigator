//
//  BinaryHeap.swift
//  Metro Navigator
//
//  Created by Illia Lysenko on 4/30/17.
//  Copyright © 2017 intellogic. All rights reserved.
//

import Foundation

struct Node <Key: Any, Value: Comparable> {
    let key: Key
    var value: Value
    
}

class BinaryHeap <Key: Comparable, Value: Comparable> {
    var nodes: [Node<Key, Value>] = []
    var size: Int {
        return nodes.count
    }
    
    init(with nodes: [Node<Key, Value>]){
        self.nodes = nodes
        heapify()
    }
    
    private func parent(for node: Int) -> Int {
        return (node - 1) / 2
    }
    
    private func left(for node: Int) -> Int{
        return 2 * node + 1
    }
    
    private func right(for node: Int) -> Int{
        return 2 * node + 2
    }
    
    private func minHeapify(for node: Int){
        let leftNode = left(for: node)
        let rightNode = right(for: node)
        var minNode: Int
        if leftNode < size && nodes[leftNode].value < nodes[node].value {
            minNode = leftNode
        } else {
            minNode = node
        }
        if rightNode < size && nodes[rightNode].value < nodes[minNode].value {
            minNode = rightNode
        }
        
        if (minNode != node){
            swap(&nodes[node], &nodes[minNode])
            minHeapify(for: minNode)
        }
    }
    
    private func heapify(){
        for currentNode in (0...((size - 1)/2)).reversed() {
            minHeapify(for: currentNode)
        }
    }
    
    private func decreaseKey(for node: Int){
        var currentNode = node
        while (currentNode > 0 && nodes[parent(for: currentNode)].value > nodes[currentNode].value) {
            swap(&nodes[parent(for: currentNode)], &nodes[currentNode])
            currentNode = parent(for: currentNode)
        }
    }
    
    public func getMin() -> Node<Key, Value> {
        return nodes.remove(at: 0)
    }
    
    public func updateValue(for key : Key, with newValue: Value){
        for index in 0..<size {
            if nodes[index].key == key {
                nodes[index].value = newValue
                decreaseKey(for: index)
            }
        }
    }
    
    func printHeap() {
        for node in nodes {
            print(node.value)
        }
    }
}
