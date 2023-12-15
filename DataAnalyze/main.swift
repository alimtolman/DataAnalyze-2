import Foundation

print("Waiting time (min)\t| Food quality\t| Customer satisfaction")
print("------------------------------------------------------------")

let classes = ["Low","High"]
let timeArr = [8,19,17,8,18,15,10,6,6,14,13,7,10,17,9,18,18,14,15,8,18,13,20,8,16,11,20,17,11,18,5,5,13,8,7,7,9,20,15,16,19,18,9,5,15,14,20,18,12,5]
let foodQualityArr = [5,4,3,3,1,3,2,1,5,1,4,3,5,3,1,3,5,3,1,2,5,5,5,4,3,4,4,5,1,5,4,4,4,3,4,4,2,1,4,2,3,1,3,4,1,3,3,1,3,1]
let satisfactionArr = [2,1,1,2,1,1,1,1,2,1,2,2,2,1,1,1,2,1,1,1,2,2,2,2,1,2,1,2,1,2,2,2,2,2,2,1,1,1,1,1,1,1,2,2,1,1,1,1,2,1]
let dataCount = timeArr.count
let inputCount = 2


for i in 0 ..< dataCount {
    print(timeArr[i], "\t\t\t\t\t", foodQualityArr[i], " \t\t\t", classes[satisfactionArr[i] - 1])
}


print("\nNormalized data")
print("Waiting time\t| Food quality\t| Customer satisfaction")
print("------------------------------------------------------------")

let normalTimeArr = calculateNormalValues(timeArr)
let normalFoodQualityArr = calculateNormalValues(foodQualityArr)

for i in 0 ..< dataCount {
    print(format(normalTimeArr[i]), "\t\t\t", format(normalFoodQualityArr[i]), "\t\t\t", classes[satisfactionArr[i] - 1])
}


print("\nExtended membership values")
print("------------------------------------------------------------")

let smlTimeArr = calculateMembershipValues(normalTimeArr)
let smlFoodQualityArr = calculateMembershipValues(normalFoodQualityArr)
let combinations = generateCombinations(limit: inputCount)
let smlExtendedArr = calculateExtendedMembershipValues([smlTimeArr, smlFoodQualityArr], count: dataCount, combinations)

for row in smlExtendedArr {
    var line = String()
    
    for combination in combinations {
        let symbol = combination.joined()
        
        line += (line.isEmpty ? "" : "\t") + symbol + " = " + format(row[symbol]!)
    }
    
    print(line)
}


print("\nSeparating power and classes")
print("------------------------------------------------------------")

let separatorArr = calculateFuzzySeparator(combinations, smlExtendedArr, satisfactionArr)

for combination in combinations {
    let separator = separatorArr[combination]!
    
    print(combination.joined(), " | cp = ", format(separator.cp), " | cls = ", classes[separator.cls - 1])
}


print("\nClassification of random data")
print("Waiting time\t| Food quality\t| Mu\t| Customer satisfaction")
print("------------------------------------------------------------")

let randomTime: [Float] = [0.9, 0.5, 0.7, 1]
let randomFoodQuality: [Float] = [0.4, 0.7, 0.9, 1]

for i in 0 ..< randomTime.count {
    let time = randomTime[i]
    let foodQuality = randomFoodQuality[i]
    let classification = doClassification([time, foodQuality], separatorArr)
    
    print(format(time), "\t\t\t", format(foodQuality), "\t\t\t", classification.max, "\t", classes[classification.index])
}
