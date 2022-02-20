//
//  File 2.swift
//  
//
//  Created by logan on 2/20/22.
//

import Foundation
import SwiftUI

struct SetBorder: AnimatableModifier {
    @Namespace private var matchymatch
    @Binding var enable: Bool
    var animatableData: Bool {
        get { enable }
        set {
            enable = newValue
        }
    }
    
    func body(content: Content) -> some View {
        ZStack {
            content
            if enable {
                DashedBorder(width: 4)
                    .fill(palette[8])
                    .matchedGeometryEffect(
                        id: "border",
                        in: matchymatch
                    )
            }
        }
//        if !enable {π
//            content
//        } else {
//            ZStack {
//
//                content
//                DashedBorder(width: 4)
//                    .fill(palette[8])
//                    .matchedGeometryEffect(
//                        id: "border",
//                        in: matchymatch
//                    )
//            }
            
//            ZStack {
//                content
//                Circle()
//                    .fill(.yellow)
//                    .frame(width: 40, height: 40)
//                    .matchedGeometryEffect(
//                        id: "border",
//                        in: matchymatch
//                    )
//                    .transition(.identity)
//            }
            //            content
            //                .overlay(
            //                    Circle()
            //                        .fill(.yellow)
            //                        .frame(width: 40, height: 40)
            //                        .matchedGeometryEffect(
            //                            id: "border",
            //                            in: matchymatch
            //                        )
            //                    Color
            //                        .clear
            //                        .matchedGeometryEffect(
            //                            id: "border",
            //                            in: matchymatch
            //                        )
            //                        .dashedOverlay(.black)
            //                )
//        }
    }
}


struct MatchyHost: View {
    @Namespace private var matchyspace
#warning("should support matching, not just triggers (like popover)")
    @State private var one: Bool = false
    @State private var two: Bool = false
    @State private var tre: Bool = false
    @State private var foh: Bool = false
    
    private func set(_ kp: KeyPath<MatchyHost, Binding<Bool>>) {
        withAnimation(.linear(duration: 0.62)) {
            two = false
            one = false
            tre = false
            foh = false
            self[keyPath: kp].wrappedValue = true
        }
    }
    
    @ViewBuilder
    var border: some View {
        DashedBorder(width: 4)
            .fill(palette[8])
            .zIndex(1)
            .transition(AnyTransition.identity.combined(with: .identity))
//            .matchedGeometryEffect(
//                id: "border",
//                in: matchyspace
//            )
    }
    
    var body: some View {
        VStack {
            HStack {
                ZStack {
                    palette[4]
                    Button("•") {
                        self.set(\.$one)
                    }
                    
                    if one {
                        border
                            .matchedGeometryEffect(
                                id: "border",
                                in: matchyspace
                            )
                    }
                }
                //                .modifier(SetBorder(enable: $one))
                
                ZStack {
                    palette[5]
                    Button("•") {
                        self.set(\.$two)
                    }
                    
                    if two {
                        border
                            .matchedGeometryEffect(
                                id: "border",
                                in: matchyspace
                            )
                    }
                }
//                .modifier(SetBorder(enable: $two))
            }
            HStack {
                ZStack {
                    palette[6]
                    Button("•") {
                        self.set(\.$tre)
                    }
                    if tre {
                        border
                            .matchedGeometryEffect(
                                id: "border",
                                in: matchyspace
                            )
                    }
                }
//                .modifier(SetBorder(enable: $tre))
                
                ZStack {
                    palette[7]
                    Button("•") {
                        self.set(\.$foh)
                    }
                    
                    if foh {
                        border
                            .matchedGeometryEffect(
                                id: "border",
                                in: matchyspace
                            )
                    }
                }
//                .modifier(SetBorder(enable: $foh))
            }
        }
        .frame(width: 200, height: 200)
    }
}

struct MatchedEffectPreview: PreviewProvider {
    static var previews: some View {
        MatchyHost()
    }
}
