/*
 * CPStringDrawing.j
 * AppKit
 *
 * Created by Francisco Tolmasky.
 * Copyright 2008, 280 North, Inc.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

@import <Foundation/CPString.j>


var CPStringReferenceElement    = nil;

@implementation CPString (CPStringDrawing)

/*!
    Returns the string
*/
- (CPString)cssString
{
    return self;
}

- (CGSize)sizeWithFont:(CPFont)aFont
{
    if (!CPStringReferenceElement)
    {
        CPStringReferenceElement = document.createElement("span");
        
        var style = CPStringReferenceElement.style;
        
        style.position = "absolute";
        style.whiteSpace = "pre";
        style.visibility = "visible";
        style.padding = "0px";
        style.margin = "0px";
        
        style.left = "-100000px";
        style.top = "-100000px";
        style.zIndex = "10000";
        style.background = "red";
        
        document.getElementsByTagName("body")[0].appendChild(CPStringReferenceElement);
    }
    
    CPStringReferenceElement.style.font = [aFont ? aFont : [CPFont systemFontOfSize:12.0] cssString];

    if (CPFeatureIsCompatible(CPJavascriptInnerTextFeature))
        CPStringReferenceElement.innerText = self;
    else if (CPFeatureIsCompatible(CPJavascriptTextContentFeature))
        CPStringReferenceElement.textContent = self;

    return CGSizeMake(CPStringReferenceElement.clientWidth, CPStringReferenceElement.clientHeight);
}

@end
