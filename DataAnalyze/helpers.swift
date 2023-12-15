import Foundation

let symbols = ["S", "M", "L"]
let normalizator: Float = 1


func format(_ value: Float) -> String {
    return String(format: "%.2f", value)
}

func findMinMax(_ data: [Int]) -> MinMax {
    var result = MinMax(min: data[0], max: data[1])
    
    for i in 0 ..< data.count {
        let item = data[i]
        
        result.min = min(result.min, item)
        result.max = max(result.max, item)
    }
    
    return result
}

func findMaxIndex(_ data: [Float]) -> MaxIndex {
    var result = MaxIndex(max: data[0], index: 0)
    
    for i in 1 ..< data.count {
        if data[i] >= result.max {
            result.max = data[i]
            result.index = i
        }
    }
    
    return result
}

func calculateNormalValues(_ data: [Int]) -> [Float] {
    let minMax = findMinMax(data)
    var result: [Float] = []
    
    for i in 0 ..< data.count {
        result.append(Float(data[i] - minMax.min) / Float(minMax.max - minMax.min) * normalizator)
    }
    
    return result
}

func calculateMembershipValues(_ data: [Float]) -> [[String: Float]] {
    var result: [[String: Float]] = []
    
    for item in data {
        let small = normalizator - item
        let medium = 1 - abs(2 * item - normalizator)
        let large = item
        
        result.append([symbols[0]: small, symbols[1]: medium, symbols[2]: large])
    }
    
    return result
}

func generateCombinations(limit: Int, _ rule: [String] = [], _ result: [[String]] = []) -> [[String]] {
    if rule.count == limit {
        return result + [rule]
    }
    
    var newResult = result

    for item in symbols {
        let subResult = generateCombinations(limit: limit, rule + [item], result)
        
        newResult += subResult
    }
    
    return newResult
}

func calculateExtendedMembership(_ row: [[String: Float]], _ combinations: [[String]]) -> [String: Float] {
    var result: [String: Float] = [:]
    
    for i in 0 ..< combinations.count {
        var value: Float = 1
        var rule = String()
        
        for j in 0 ..< combinations[i].count {
            value *= row[j][combinations[i][j]]!
            rule += combinations[i][j]
        }
        
        result[rule] = value
    }
    
    return result
}

func calculateExtendedMembershipValues(_ data: [[[String: Float]]], count: Int, _ combinations: [[String]]) -> [[String: Float]] {
    var result: [[String: Float]] = []
    
    for i in 0 ..< count {
        var row: [[String: Float]] = []
        
        for item in data {
            row.append(item[i])
        }
        
        result.append(calculateExtendedMembership(row, combinations))
    }
    
    return result
}

func calculateFuzzySeparator(_ combinations: [[String]], _ data: [[String: Float]], _ classes: [Int]) -> [[String]: FuzzySeparator] {
    var result: [[String]: FuzzySeparator] = [:]
    var betaDict: [[String]: [Float]] = [:]
    
    for combination in combinations {
        betaDict[combination] = [Float](repeating: 0, count: combination.count)
    }

    for i in 0 ..< data.count {
        for combination in combinations {
            let symbol = combination.joined()
            let value = data[i][symbol]!
            let cls = classes[i]
            var betaArr = betaDict[combination]!
            
            betaArr[cls - 1] += value
            betaDict[combination] = betaArr
        }
    }
    
    for combination in combinations {
        let betaArr = betaDict[combination]!
        let cls = findMaxIndex(betaArr).index + 1
        var numerator = betaArr[0]
        var denominator = betaArr[0]
        
        for i in 1 ..< betaArr.count {
            numerator -= betaArr[i]
            denominator += betaArr[i]
        }

        result[combination] = FuzzySeparator(cp: abs(numerator) / denominator, cls: cls)
    }
 
    return result
}

func calculateMu(_ symbol: String, _ value: Float) -> Float {
    switch symbol {
    case symbols[0]: // S
        return normalizator - value
    case symbols[1]: // M
        return normalizator - abs(2 * value - normalizator)
    case symbols[2]: // L
        return value
    default:
        return 0
    }
}

func doClassification(_ input: [Float], _ fuzzySeparator: [[String]: FuzzySeparator]) -> MaxIndex {
    var muMax = [Float](repeating: 0, count: input.count)
    
    for separator in fuzzySeparator {
        var mu = [Float](repeating: 0, count: input.count)
        
        for i in 0 ..< input.count {
            mu[i] = calculateMu(separator.key[i], input[i])
            muMax[i] = max(muMax[i], mu[i])
        }
    }
    
    return findMaxIndex(muMax)
}
