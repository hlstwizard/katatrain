//
//  AI.swift
//  katatrain
//
//  Created by Yiming Huang on 2021/12/3.
//

import Foundation


let CALIBRATED_RANK_ELO = [
    (-21.679482223451032, 18),
    (42.60243194422105, 17),
    (106.88434611189314, 16),
    (171.16626027956522, 15),
    (235.44817444723742, 14),
    (299.7300886149095, 13),
    (364.0120027825817, 12),
    (428.2939169502538, 11),
    (492.5758311179259, 10),
    (556.8577452855981, 9),
    (621.1396594532702, 8),
    (685.4215736209424, 7),
    (749.7034877886144, 6),
    (813.9854019562865, 5),
    (878.2673161239586, 4),
    (942.5492302916308, 3),
    (1006.8311444593029, 2),
    (1071.113058626975, 1),
    (1135.3949727946472, 0),
    (1199.6768869623193, -1),
    (1263.9588011299913, -2),
    (1700, -4),
]


let AI_WEIGHTED_ELO = [
    (0.5, 1591.5718897531551),
    (1.0, 1269.9896556526198),
    (1.25, 1042.25179764667),
    (1.5, 848.9410084463602),
    (1.75, 630.1483212024823),
    (2, 575.3637091858013),
    (2.5, 410.9747543504796),
    (3.0, 219.8667371799533),
]

let AI_SCORELOSS_ELO = [
    (0.0, 539),
    (0.05, 625),
    (0.1, 859),
    (0.2, 1035),
    (0.3, 1201),
    (0.4, 1299),
    (0.5, 1346),
    (0.75, 1374),
    (1.0, 1386),
]


let AI_LOCAL_ELO_GRID = [
    [0.0, 0.05, 0.1, 0.2, 0.3, 0.5, 0.75, 1.0],
    [0, 5, 10, 15, 25, 50],
    [
        [-204.0, 791.0, 1154.0, 1372.0, 1402.0, 1473.0, 1700.0, 1700.0],
        [174.0, 1094.0, 1191.0, 1384.0, 1435.0, 1522.0, 1700.0, 1700.0],
        [619.0, 1155.0, 1323.0, 1390.0, 1450.0, 1558.0, 1700.0, 1700.0],
        [975.0, 1289.0, 1332.0, 1401.0, 1461.0, 1575.0, 1700.0, 1700.0],
        [1344.0, 1348.0, 1358.0, 1467.0, 1477.0, 1616.0, 1700.0, 1700.0],
        [1425.0, 1474.0, 1489.0, 1524.0, 1571.0, 1700.0, 1700.0, 1700.0],
    ],
]

let AI_TENUKI_ELO_GRID = [
    [0.0, 0.05, 0.1, 0.2, 0.3, 0.5, 0.75, 1.0],
    [0, 5, 10, 15, 25, 50],
    [
        [47.0, 335.0, 530.0, 678.0, 830.0, 1070.0, 1376.0, 1700.0],
        [99.0, 469.0, 546.0, 707.0, 855.0, 1090.0, 1413.0, 1700.0],
        [327.0, 513.0, 605.0, 745.0, 875.0, 1110.0, 1424.0, 1700.0],
        [429.0, 519.0, 620.0, 754.0, 900.0, 1130.0, 1435.0, 1700.0],
        [492.0, 607.0, 682.0, 797.0, 1000.0, 1208.0, 1454.0, 1700.0],
        [778.0, 830.0, 909.0, 949.0, 1169.0, 1461.0, 1483.0, 1700.0],
    ],
]

let AI_TERRITORY_ELO_GRID = [
    [0.0, 0.05, 0.1, 0.2, 0.3, 0.5, 0.75, 1.0],
    [0, 5, 10, 15, 25, 50],
    [
        [34.0, 383.0, 566.0, 748.0, 980.0, 1264.0, 1527.0, 1700.0],
        [131.0, 450.0, 586.0, 826.0, 995.0, 1280.0, 1537.0, 1700.0],
        [291.0, 517.0, 627.0, 850.0, 1010.0, 1310.0, 1547.0, 1700.0],
        [454.0, 526.0, 696.0, 870.0, 1038.0, 1340.0, 1590.0, 1700.0],
        [491.0, 603.0, 747.0, 890.0, 1050.0, 1390.0, 1635.0, 1700.0],
        [718.0, 841.0, 1039.0, 1076.0, 1332.0, 1523.0, 1700.0, 1700.0],
    ],
]

let AI_INFLUENCE_ELO_GRID = [
    [0.0, 0.05, 0.1, 0.2, 0.3, 0.5, 0.75, 1.0],
    [0, 5, 10, 15, 25, 50],
    [
        [217.0, 439.0, 572.0, 768.0, 960.0, 1227.0, 1449.0, 1521.0],
        [302.0, 551.0, 580.0, 800.0, 1028.0, 1257.0, 1470.0, 1529.0],
        [388.0, 572.0, 619.0, 839.0, 1077.0, 1305.0, 1490.0, 1561.0],
        [467.0, 591.0, 764.0, 878.0, 1097.0, 1390.0, 1530.0, 1591.0],
        [539.0, 622.0, 815.0, 953.0, 1120.0, 1420.0, 1560.0, 1601.0],
        [772.0, 912.0, 958.0, 1145.0, 1318.0, 1511.0, 1577.0, 1623.0],
    ],
]

let AI_PICK_ELO_GRID = [
    [0.0, 0.05, 0.1, 0.2, 0.3, 0.5, 0.75, 1.0],
    [0, 5, 10, 15, 25, 50],
    [
        [-533.0, -515.0, -355.0, 234.0, 650.0, 1147.0, 1546.0, 1700.0],
        [-531.0, -450.0, -69.0, 347.0, 670.0, 1182.0, 1550.0, 1700.0],
        [-450.0, -311.0, 140.0, 459.0, 693.0, 1252.0, 1555.0, 1700.0],
        [-365.0, -82.0, 265.0, 508.0, 864.0, 1301.0, 1619.0, 1700.0],
        [-113.0, 273.0, 363.0, 641.0, 983.0, 1486.0, 1700.0, 1700.0],
        [514.0, 670.0, 870.0, 1128.0, 1305.0, 1550.0, 1700.0, 1700.0],
    ],
]

// dan ranks, backup if model is missing. TODO: remove some?
let AI_STRENGTH: [AIStrategy: Int] = [
  .antimirror: 9,
  .policy: 5,
  .simple_ownership: 2,
  .settle_stones: 2
]

fileprivate func interp_ix<T: FloatingPoint>(lst: [T], x: T) -> (Int, T) {
  var i = 0
  while i + 1 < lst.count - 1 && lst[i + 1] < x {
    i += 1
  }
  let t = max(0, min(1, (x - lst[i]) / (lst[i + 1] - lst[i])))
  return (i, t)
}

fileprivate func interp1d(lst: [(Double, Double)], x: Double) -> Double {
  let (xs, ys) = unzip(lst)
  let (i, t) = interp_ix(lst: xs, x: x)
  return (1 - t) * ys[i] + t * ys[i+1]
}

fileprivate func interp2d(gridSpec: [Any], x: Double, y: Double) -> Double {
  let xs = gridSpec[0] as! [Double]
  let ys = gridSpec[1] as! [Double]
  let matrix = gridSpec[2] as! [[Double]]
  
  let (i, t) = interp_ix(lst: xs, x: x)
  let (j, s) = interp_ix(lst: ys, x: y)
  return matrix[j][i] * (1-t) * (1-s) +
  matrix[j][i+1] * t * (1-s) +
  matrix[j+1][i] * (1-t) * s +
  matrix[j+1][i+1] * t * s
}


func ai_rank_estimation(strategy: AIStrategy, settings: [String: Double]) -> Int {
  let elo: Double
  switch strategy {
  case .handicap, .jigo:
    return 9
  case .rank:
    return 1 - Int(settings["kyu_rank"]!)
  case .scoreloss:
    elo = interp1d(lst: AI_SCORELOSS_ELO.map { ($0.0, Double($0.1)) }, x: settings["strength"]!)
  case .weighted:
    elo = interp1d(lst: AI_WEIGHTED_ELO, x: settings["weaken_frac"]!)
  case .pick:
    elo = interp2d(gridSpec: AI_PICK_ELO_GRID, x: settings["pick_frac"]!, y: settings["pick_n"]!)
  case .local:
    elo = interp2d(gridSpec: AI_LOCAL_ELO_GRID, x: settings["pick_frac"]!, y: settings["pick_n"]!)
  case .tenuki:
    elo = interp2d(gridSpec: AI_TENUKI_ELO_GRID, x: settings["pick_frac"]!, y: settings["pick_n"]!)
  case .territory:
    elo = interp2d(gridSpec: AI_TERRITORY_ELO_GRID, x: settings["pick_frac"]!, y: settings["pick_n"]!)
  case .influence:
    elo = interp2d(gridSpec: AI_INFLUENCE_ELO_GRID, x: settings["pick_frac"]!, y: settings["pick_n"]!)
  case .antimirror, .policy, .simple_ownership, .settle_stones:
    return AI_STRENGTH[strategy]!
  default:
    return 9
  }
  let kyu = Int(interp1d(lst: CALIBRATED_RANK_ELO.map { ($0.0, Double($0.1)) }, x: elo))
  return 1 - kyu
}
