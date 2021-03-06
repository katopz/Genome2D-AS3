package com.genome2d.components.renderables {

import com.genome2d.context.filters.GFilter;
import com.genome2d.context.GContextCamera;
import com.genome2d.signals.GMouseSignalType;
import com.genome2d.node.GNode;
import com.genome2d.components.GComponent;
import com.genome2d.signals.GMouseSignal;
import com.genome2d.textures.GTexture;

import flash.geom.Matrix;
import flash.geom.Rectangle;

/**
 * ...
 * @author Peter "sHTiF" Stefcek
 */
public class GTexturedQuad extends GComponent implements IRenderable
{
    /**
     *  Blend mode used for rendering
     **/
    public var blendMode:int = 1;

    /**
     *  Enable/disable pixel perfect mouse detection, not supported by all contexts.
     *  Default false
     **/
    public var mousePixelEnabled:Boolean = false;
    /**
     *  Specify alpha treshold for pixel perfect mouse detection, works with mousePixelEnabled true
     **/
    public var mousePixelTreshold:int = 0;

    /**
     *  Texture used for rendering
     **/
	public var texture:GTexture;

    /**
     *  Filter used for rendering
     **/
    public var filter:GFilter;

    /**
     *  @private
     **/
	public function GTexturedQuad(p_node:GNode) {
		super(p_node);
	}

    /**
     *  @private
     **/
	public function render(p_camera:GContextCamera, p_useMatrix:Boolean):void {
		if (texture != null) {
			//trace(node.transform.g2d_worldScaleX + "," + node.transform.g2d_worldScaleY);
            if (p_useMatrix) {
                var matrix:Matrix = node.core.g2d_renderMatrix;
                g2d_node.core.g2d_context.drawMatrix(texture, matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty, node.transform.g2d_worldRed, node.transform.g2d_worldGreen, node.transform.g2d_worldBlue, node.transform.g2d_worldAlpha, blendMode, filter);
            } else {
                g2d_node.core.g2d_context.draw(texture, node.transform.g2d_worldX, node.transform.g2d_worldY, node.transform.g2d_worldScaleX, node.transform.g2d_worldScaleY, node.transform.g2d_worldRotation, node.transform.g2d_worldRed, node.transform.g2d_worldGreen, node.transform.g2d_worldBlue, node.transform.g2d_worldAlpha, blendMode, filter);
            }
		}
	}

    public function hitTestPoint(p_x:Number, p_y:Number, p_pixelEnabled:Boolean = false):Boolean {
        var tx:Number = p_x - node.transform.g2d_worldX;
        var ty:Number = p_y - node.transform.g2d_worldY;

        if (g2d_node.transform.g2d_worldRotation != 0) {
            var cos:Number = Math.cos(-node.transform.g2d_worldRotation);
            var sin:Number = Math.sin(-node.transform.g2d_worldRotation);

            var ox:Number = tx;
            tx = (tx*cos - ty*sin);
            ty = (ty*cos + ox*sin);
        }

        tx /= g2d_node.transform.g2d_worldScaleX*texture.width;
        ty /= g2d_node.transform.g2d_worldScaleY*texture.height;

        tx += .5;
        ty += .5;

        if (tx >= -texture.pivotX / texture.width && tx <= 1 - texture.pivotX / texture.width && ty >= -texture.pivotY / texture.height && ty <= 1 - texture.pivotY / texture.height) {
            if (p_pixelEnabled && texture.getAlphaAtUV(tx+texture.pivotX/texture.width, ty+texture.pivotY/texture.height) <= mousePixelTreshold) {
                return false;
            }
            return true;
        }

        return false;
    }

    /**
     *  @private
     **/
	override public function processContextMouseSignal(p_captured:Boolean, p_cameraX:Number, p_cameraY:Number, p_contextSignal:GMouseSignal):Boolean {
		if (p_captured && p_contextSignal.type == GMouseSignalType.MOUSE_UP) g2d_node.g2d_mouseDownNode = null;

		if (p_captured || texture == null || texture.width == 0 || texture.height == 0 || g2d_node.transform.g2d_worldScaleX == 0 || g2d_node.transform.g2d_worldScaleY == 0) {
			if (g2d_node.g2d_mouseOverNode == g2d_node) g2d_node.dispatchNodeMouseSignal(GMouseSignalType.MOUSE_OUT, g2d_node, 0, 0, p_contextSignal);
			return false;
		}

        // Invert translations
        var tx:Number = p_cameraX - g2d_node.transform.g2d_worldX;
        var ty:Number = p_cameraY - g2d_node.transform.g2d_worldY;

        if (g2d_node.transform.g2d_worldRotation != 0) {
            var cos:Number = Math.cos(-g2d_node.transform.g2d_worldRotation);
            var sin:Number = Math.sin(-g2d_node.transform.g2d_worldRotation);

            var ox:Number = tx;
            tx = (tx*cos - ty*sin);
            ty = (ty*cos + ox*sin);
        }

        tx /= g2d_node.transform.g2d_worldScaleX*texture.width;
        ty /= g2d_node.transform.g2d_worldScaleY*texture.height;

        tx += .5;
        ty += .5;

		if (tx >= -texture.pivotX / texture.width && tx <= 1 - texture.pivotX / texture.width && ty >= -texture.pivotY / texture.height && ty <= 1 - texture.pivotY / texture.height) {
			if (mousePixelEnabled && texture.getAlphaAtUV(tx+texture.pivotX/texture.width, ty+texture.pivotY/texture.height) <= mousePixelTreshold) {
				if (g2d_node.g2d_mouseOverNode == node) {
					g2d_node.dispatchNodeMouseSignal(GMouseSignalType.MOUSE_OUT, g2d_node, tx*texture.width-texture.width*.5, ty*texture.height-texture.height*.5, p_contextSignal);
				}
				return false;
			}

			g2d_node.dispatchNodeMouseSignal(p_contextSignal.type, g2d_node, tx*texture.width-texture.width*.5, ty*texture.height-texture.height*.5, p_contextSignal);
			if (g2d_node.g2d_mouseOverNode != g2d_node) {
				g2d_node.dispatchNodeMouseSignal(GMouseSignalType.MOUSE_OVER, g2d_node, tx*texture.width-texture.width*.5, ty*texture.height-texture.height*.5, p_contextSignal);
			}
			
			return true;
		} else {
			if (g2d_node.g2d_mouseOverNode == g2d_node) {
				g2d_node.dispatchNodeMouseSignal(GMouseSignalType.MOUSE_OUT, g2d_node, tx*texture.width-texture.width*.5, ty*texture.height-texture.height*.5, p_contextSignal);
			}
		}
		
		return false;
	}

    /**
     *  @private
     **/
    public function getBounds(p_bounds:Rectangle = null):Rectangle {
        if (texture == null) {
            if (p_bounds != null) p_bounds.setTo(0, 0, 0, 0);
            else p_bounds = new Rectangle(0, 0, 0, 0);
        } else {
            if (p_bounds != null) p_bounds.setTo(-texture.width*.5-texture.pivotX, -texture.height*.5-texture.pivotY, texture.width, texture.height);
            else p_bounds = new Rectangle(-texture.width*.5-texture.pivotX, -texture.height*.5-texture.pivotY, texture.width, texture.height);
        }

        return p_bounds;
    }
}
}