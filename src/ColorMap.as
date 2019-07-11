package  
{
    //Imports
    import com.mattie.utils.ColorUtils;
    
    //Class
    public final class ColorMap 
    {
        //Constants
        private static const BLUE:uint = 0x0000FF;
        private static const MAGENTA:uint = 0xFF00FF;
        private static const RED:uint = 0xFF0000;
        private static const YELLOW:uint = 0xFFFF00;
        private static const GREEN:uint = 0x00FF00;
        private static const CYAN:uint = 0x00FFFF;
        private static const BLACK:uint = 0x000000;
        
        private static const DARK_INCREASE:Number = 0.5;
    
        //Properties
        private var spectrum:Vector.<uint>;
        private var bandwidth:Number; 
        
        //Constructor
        public function ColorMap()
        {
            init();
        }
        
        //Init
        private function init():void
        {            
            var colorConstants:Vector.<uint> = new <uint>[BLUE, MAGENTA, RED, YELLOW, GREEN, CYAN, BLUE];
            
            spectrum = new Vector.<uint>;
            
            for each (var color:uint in colorConstants)
            {
                var darkenedColor:uint = ColorUtils.blend(color, BLACK, DARK_INCREASE);
                
                spectrum.push(darkenedColor);
            }
            
            colorConstants.length = 0;
            colorConstants = null;

            bandwidth = 1.0 / (spectrum.length - 1);
        }
        
        //Get Color
        public function getColor(mapX:Number, mapY:Number):uint
        {
            mapX = (mapX < 0.0 || mapX > 1.0) ? Math.max(0.0, Math.min(1.0, mapX)) : mapX;
            mapY = (mapY < 0.0 || mapY > 1.0) ? Math.max(0.0, Math.min(1.0, mapY)) : mapY;
            
            if (mapX == 0.0 || mapX == 1.0 || mapX % bandwidth == 0)
            {
                return ColorUtils.blend(spectrum[mapX / bandwidth], BLACK, mapY);
            }
            
            var targetIndex:uint = Math.floor(mapX / bandwidth);
            var color1:uint = spectrum[targetIndex];
            var color2:uint = spectrum[targetIndex + 1];
            var colorsPartition:Number = (mapX - bandwidth * targetIndex) / bandwidth;
            
            return ColorUtils.blend(ColorUtils.blend(color1, color2, colorsPartition), BLACK, mapY);
        }
    }
}