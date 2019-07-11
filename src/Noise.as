package  
{
    //Imports
    import com.mattie.media.noise.NoiseImage;
    import com.mattie.media.noise.NoiseSound;
    import flash.display.Sprite;
    
    //Class
    public class Noise extends Sprite
    {
        //Properties
        private var image:NoiseImage;
        private var sound:NoiseSound;
        
        //Constructor
        public function Noise(maxImageWidth:uint, maxImageHeight:uint)
        {
            image = new NoiseImage(maxImageWidth, maxImageHeight);
            sound = new NoiseSound();
            
            addChild(image);
        }
        
        //Play Image
        public function playImage():void
        {
            image.play();
        }
        
        //Stop Image
        public function stopImage():void
        {
            image.stop();
        }
        
        //Play Sound
        public function playSound():void
        {
            sound.play();
        }
        
        //Stop Sound
        public function stopSound():void
        {
            sound.stop();
        }
        
        //Dispose
        public function dispose():void
        {
            image.dispose();
            sound.dispose();
            
            removeChild(image);
        }
        
        //Set Width
        override public function set width(value:Number):void
        {
            image.width = value;
        }
        
        //Get Width
        override public function get width():Number
        {
            return image.width;
        }
        
        //Set Height
        override public function set height(value:Number):void
        {
            image.height = value;
        }
        
        //Get Height
        override public function get height():Number
        {
            return image.height;
        }
        
        //Set Volume
        public function set volume(value:Number):void
        {
            sound.volume = value;
        }
        
        //Get Volume
        public function get volume():Number
        {
            return sound.volume;
        }
        
        //Set Pitch
        public function set pitch(value:Number):void
        {
            sound.pitch = value;
        }
        
        //Get Pitch
        public function get pitch():Number
        {
            return sound.pitch;
        }
    }
}