//
//  _Clipper.mm
//  RSClipperWrapper
//
//  Created by Matthias Fey on 07.08.15.
//  Copyright © 2015 Matthias Fey. All rights reserved.
//

#import "_Clipper.h"

#include "clipper.hpp"

#define kClipperScale 1000000.0f

@implementation _Clipper


+ (ClipperLib::PolyFillType) clipperFillTypeFor: (_FillType) fillType {
    switch (fillType) {
        case EvenOdd:
            return ClipperLib::PolyFillType::pftEvenOdd;
        case NonZero:
            return ClipperLib::PolyFillType::pftNonZero;
        case Positive:
            return ClipperLib::PolyFillType::pftPositive;
        case Negative:
            return ClipperLib::PolyFillType::pftNegative;
    }
}

+ (NSArray *) simplifyPolygon: (NSArray *) polygon fillType:(_FillType) fillType {
    ClipperLib::Clipper clipper;
    ClipperLib::Path path;
    for (NSValue *vertex : polygon) {
        path.push_back(ClipperLib::IntPoint(kClipperScale*vertex.CGPointValue.x, kClipperScale*vertex.CGPointValue.y));
    }
    ClipperLib::Paths paths;
    
    ClipperLib::SimplifyPolygon(path, paths, [_Clipper clipperFillTypeFor:fillType]);
    NSMutableArray *polygons = [NSMutableArray array];
    for (int i = 0; i < paths.size(); i++) {
        ClipperLib::Path path = paths[i];
        NSMutableArray *polygon = [NSMutableArray array];
        for (int j = 0; j < path.size(); j++) {
            [polygon addObject:[NSValue valueWithCGPoint:CGPointMake(path[j].X/kClipperScale, path[j].Y/kClipperScale)]];
        }
        [polygons addObject:polygon];
    }
    return polygons;
}

+ (NSArray *) unionPolygons:(NSArray *)subjPolygons subjFillType:(_FillType)subjFillType withPolygons:(NSArray *)clipPolygons clipFillType:(_FillType)clipFillType {
    
    return [_Clipper executePolygons:subjPolygons subjFillType:subjFillType withPolygons:clipPolygons clipFillType:clipFillType clipType:ClipperLib::ClipType::ctUnion];
}

+ (NSArray *) differencePolygons:(NSArray *)subjPolygons subjFillType:(_FillType)subjFillType fromPolygons:(NSArray *)clipPolygons clipFillType:(_FillType)clipFillType {
    
    return [_Clipper executePolygons:subjPolygons subjFillType:subjFillType withPolygons:clipPolygons clipFillType:clipFillType clipType:ClipperLib::ClipType::ctDifference];
}

+ (NSArray *) intersectPolygons:(NSArray *)subjPolygons subjFillType:(_FillType)subjFillType withPolygons:(NSArray *)clipPolygons clipFillType:(_FillType)clipFillType {
    
    return [_Clipper executePolygons:subjPolygons subjFillType:subjFillType withPolygons:clipPolygons clipFillType:clipFillType clipType:ClipperLib::ClipType::ctIntersection];
}

+ (NSArray *) xorPolygons:(NSArray *)subjPolygons subjFillType:(_FillType)subjFillType withPolygons:(NSArray *)clipPolygons clipFillType:(_FillType)clipFillType {
    
    return [_Clipper executePolygons:subjPolygons subjFillType:subjFillType withPolygons:clipPolygons clipFillType:clipFillType clipType:ClipperLib::ClipType::ctXor];
}



+(NSArray *) executePolygons:(NSArray *)subjPolygons subjFillType:(_FillType)subjFillType withPolygons:(NSArray *)clipPolygons clipFillType:(_FillType)clipFillType clipType:(ClipperLib::ClipType)clipType {
    
    ClipperLib::Clipper clipper;
    clipper.StrictlySimple();
    
    for (NSArray *polygon : subjPolygons) {
        ClipperLib::Path path;
        for (NSValue *vertex : polygon) {
            path.push_back(ClipperLib::IntPoint(kClipperScale*vertex.CGPointValue.x, kClipperScale*vertex.CGPointValue.y));
        }
        clipper.AddPath(path, ClipperLib::PolyType::ptSubject, YES);
    }
    
    for (NSArray *polygon : clipPolygons) {
        ClipperLib::Path path;
        for (NSValue *vertex : polygon) {
            path.push_back(ClipperLib::IntPoint(kClipperScale*vertex.CGPointValue.x, kClipperScale*vertex.CGPointValue.y));
        }
        clipper.AddPath(path, ClipperLib::PolyType::ptClip, YES);
    }
    
    ClipperLib::Paths paths;
    clipper.Execute(clipType, paths, [_Clipper clipperFillTypeFor:subjFillType], [_Clipper clipperFillTypeFor:clipFillType]);

    NSMutableArray *polygons = [NSMutableArray arrayWithCapacity:paths.size()];
    for (int i = 0; i < paths.size(); i++) {
        ClipperLib::Path path = paths[i];

        NSMutableArray *polygon = [NSMutableArray arrayWithCapacity:path.size()];
        for (int j = 0; j < path.size(); j++) {
            [polygon addObject:[NSValue valueWithCGPoint:CGPointMake(path[j].X/kClipperScale, path[j].Y/kClipperScale)]];
        }
        
        [polygons addObject:polygon];
    }
    
    return polygons;
}

+ (Boolean) polygon:(NSArray *)polygon containsPoint:(CGPoint)point {
    
    ClipperLib::IntPoint aPoint = ClipperLib::IntPoint(kClipperScale*point.x, kClipperScale*point.y);
    
    ClipperLib::Path path;
    for (NSValue *vertex : polygon) {
        path.push_back(ClipperLib::IntPoint(kClipperScale*vertex.CGPointValue.x, kClipperScale*vertex.CGPointValue.y));
    }
    
    int result = ClipperLib::PointInPolygon(aPoint, path);
    
    return result != 0;
}

@end
