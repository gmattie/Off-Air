package 
{
    //Imports
    import flash.display.GradientType;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.geom.ColorTransform;
    import flash.geom.Matrix;
    
    //Class
    internal final class GradientOverlay extends Sprite
    {
        //Properties
        private var widthProperty:Number;
        private var heightProperty:Number;
        private var colorProperty:uint;
        
        //Variables    
        public var colorGradient:Shape;
        public var colorGradientMask:Shape;
        
        private var colorGradientBox:Matrix;
        private var horizontalShadowGradientBox:Matrix;
        private var horizontalShadowGradient:Shape;
        private var verticalShadowGradientBox:Matrix;
        private var verticalShadowGradient:Shape;
        private var colorTransform:ColorTransform;
        
        //Constructor
        public function GradientOverlay(width:Number, height:Number, color:uint)
        {
            widthProperty = width;
            heightProperty = height;
            colorProperty = color;

            init();
        }
        
        //Initialize
        private function init():void
        {
            colorGradientBox = new Matrix();
            colorGradient = new Shape();
            
            horizontalShadowGradientBox = new Matrix();
            horizontalShadowGradient = new Shape();
            
            verticalShadowGradientBox = new Matrix();
            verticalShadowGradient = new Shape();
            
            colorGradientMask = new Shape();
            
            colorTransform = new ColorTransform();
            
            addChild(colorGradient);
            addChild(horizontalShadowGradient);
            addChild(verticalShadowGradient);
            addChild(colorGradientMask);
            
            draw(true);
        }
        
        //Draw
        private function draw(drawMask:Boolean = false):void
        {
            colorGradientBox.createGradientBox(widthProperty, heightProperty);
            
            colorGradient.graphics.clear();
            colorGradient.graphics.beginGradientFill(GradientType.LINEAR, [colorProperty, colorProperty], [0.5, 0.0], [128, 255], colorGradientBox);
            colorGradient.graphics.drawRect(0, 0, widthProperty, heightProperty);
            colorGradient.graphics.endFill();
            
            horizontalShadowGradientBox.createGradientBox(widthProperty, heightProperty);
            
            horizontalShadowGradient.graphics.clear();
            horizontalShadowGradient.graphics.beginGradientFill(GradientType.LINEAR, [0x000000, 0x000000], [0.9, 0.0], [0, 128], horizontalShadowGradientBox);
            horizontalShadowGradient.graphics.drawRect(0, 0, widthProperty, heightProperty);
            horizontalShadowGradient.graphics.endFill();         
            
            verticalShadowGradientBox.createGradientBox(widthProperty, heightProperty, -90 * Math.PI / 180);
            
            verticalShadowGradient.graphics.clear();
            verticalShadowGradient.graphics.beginGradientFill(GradientType.LINEAR, [0x000000, 0x000000], [0.9, 0.0], [0, 255], verticalShadowGradientBox);
            verticalShadowGradient.graphics.drawRect(0, 0, widthProperty, heightProperty);
            verticalShadowGradient.graphics.endFill();
            
            if (drawMask)
            {
                colorGradientMask.graphics.clear();
                colorGradientMask.graphics.beginFill(0x000000, 1.0);
                colorGradientMask.graphics.drawRect(0, 0, widthProperty, heightProperty);
                colorGradientMask.graphics.endFill();                
            }
        }
        
        //Dispose
        public function dispose():void
        {
            while (numChildren)
            {
                removeChildAt(numChildren - 1);
            }
            
            colorGradientBox = null;
            horizontalShadowGradientBox = null;
            verticalShadowGradientBox = null;
        }
        
        //Set Width
        override public function set width(value:Number):void
        {
            widthProperty = value;
            draw();
        }
        
        //Get Width
        override public function get width():Number
        {
            return widthProperty;
        }
        
        //Set Height
        override public function set height(value:Number):void
        {
            heightProperty = value;
            draw();
        }
        
        //Get Height
        override public function get height():Number
        {
            return heightProperty;
        }
        
        //Set Color
        public function set color(value:uint):void
        {
            colorProperty = colorTransform.color = value;
            colorGradient.transform.colorTransform = colorTransform;
        }
        
        //Get Color
        public function get color():uint
        {
            return colorProperty;
        }
    }
}