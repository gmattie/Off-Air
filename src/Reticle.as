package 
{
    //Imports
    import flash.display.CapsStyle;
    import flash.display.GradientType;
    import flash.display.LineScaleMode;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.filters.GlowFilter;
    import flash.geom.Matrix;
    
    //Class
    internal final class Reticle extends Sprite
    {
        //Constants
        public static const LINE_WIDTH:uint = 2.0;
        public static const PADDING:uint = 1.0;
        
        //Properties
        private var widthProperty:Number;
        private var heightProperty:Number;
        private var volumeProperty:Number;
        private var pitchProperty:Number;
                
        //Variables
        private var linesGradientBox:Matrix;
        private var lines:Shape;
        
        //Constructor
        public function Reticle(width:Number, height:Number, volume:Number, pitch:Number)
        {
            widthProperty = width;
            heightProperty = height;
            volumeProperty = volume;
            pitchProperty = pitch;
            
            alpha = 0.0;
            
            init();
        }
        
        //Initialize
        private function init():void
        {
            linesGradientBox = new Matrix();
            lines = new Shape();
            
            addChild(lines);
            
            lines.filters = [new GlowFilter(0xFFFFFF, 1.0, 4.0, 4.0, 2, 3)];
            draw();
            position(true, true);
        }
        
        //Draw
        private function draw():void
        {
            linesGradientBox.createGradientBox(widthProperty * 2, heightProperty * 2, 0, -widthProperty, -heightProperty);
            
            lines.graphics.clear();
            lines.graphics.lineStyle(LINE_WIDTH, 0xFFFFFF, 1.0, true, LineScaleMode.NONE, CapsStyle.NONE);
            lines.graphics.lineGradientStyle(GradientType.RADIAL, [0xFFFFFF, 0xFFFFFF], [1.0, 0.0], [0, 255], linesGradientBox);
            lines.graphics.moveTo(-widthProperty, 0);
            lines.graphics.lineTo(widthProperty, 0);
            lines.graphics.moveTo(0, -heightProperty);
            lines.graphics.lineTo(0, heightProperty);
        }
        
        //Position
        private function position(setPitch:Boolean, setVolume:Boolean):void
        {
            if  (setPitch)
            {
                lines.x = Math.min(Math.max(PADDING, widthProperty * pitchProperty), widthProperty - PADDING);
            }
            
            if  (setVolume)
            {
                lines.y = Math.min(Math.max(PADDING, heightProperty - heightProperty * volumeProperty), heightProperty - PADDING);
            }
        }
        
        //Dispose
        public function dispose():void
        {
            while (numChildren)
            {
                removeChildAt(numChildren - 1);
            }
            
            linesGradientBox = null;
        }
        
        //Get X
        public override function get x():Number
        {
            return lines.x;
        }
        
        //Get Y
        public override function get y():Number
        {
            return lines.y;
        }
        
        //Set Width
        override public function set width(value:Number):void
        {
            widthProperty = value;
            draw();
            position(true, true);
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
            position(true, true);
        }
        
        //Get Height
        override public function get height():Number
        {
            return heightProperty;
        }
        
        //Set Volume
        public function set volume(value:Number):void
        {
            if  (volumeProperty != value)
            {
                volumeProperty = Math.min(Math.max(0.0, value), 1.0);
                position(false, true);                
            }
        }
        
        //Get Volume
        public function get volume():Number
        {
            return volumeProperty;
        }
        
        //Set Pitch
        public function set pitch(value:Number):void
        {
            if  (pitchProperty != value)
            {
                pitchProperty = Math.min(Math.max(0.0, value), 1.0);
                position(true, false);                
            }
        }
        
        //Get Pitch
        public function get pitch():Number
        {
            return pitchProperty;
        }
    }
}