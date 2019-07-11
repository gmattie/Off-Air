package 
{
    //Imports
    import caurina.transitions.Equations;
    import caurina.transitions.Tweener;
    import flash.desktop.NativeApplication;
    import flash.display.NativeMenu;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.ContextMenuEvent;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.ui.ContextMenu;
    import flash.ui.ContextMenuItem;
    import flash.ui.Keyboard;
    
    //Class
    public class Canvas extends Sprite
    {
        //Constants
        private static const WINDOW_TITLE:String = "Off Air";
        private static const WINDOW_TITLE_PAUSED:String = "Off Air (Paused)";
        private static const POP_UP_MENU_PAUSE:String = "Pause";
        private static const POP_UP_MENU_PLAY:String = "Play";
        
        private static const TWEEN_DURATION:Number = 0.15;
        private static const TWEEN_TRANSITION:Function = Equations.easeNone;
        private static const TWEEN_DURATION_FADE_IN:Number = 3.0;
        private static const TWEEN_TRANSITION_FADE_IN:Function = Equations.easeInOutCubic;
        private static const DELTA_DURATION:uint = 5;
        private static const DELTA_MINIMUM:Number = 0.25;
        private static const RETICLE_DEFAULT_ALPHA:Number = 0.25;
        
        //Properties
        public var nativeWindowHasFocus:Boolean;
        public var popUpMenuIsDisplaying:Boolean;
        
        private var widthProperty:Number;
        private var heightProperty:Number;
        private var maxWidthProperty:Number;
        private var maxHeightProperty:Number;
        private var volumeProperty:Number;
        private var pitchProperty:Number;
        
        private var colorMap:ColorMap;
        private var noise:Noise;
        private var gradientOverlay:GradientOverlay;
        private var reticle:Reticle;
        private var selectedReticle:Reticle;
        private var popUpMenu:NativeMenu;
        private var popUpMenuItemPlayPause:ContextMenuItem;
        
        //Variables
        private var deltaX:Number;
        private var deltaY:Number;
        private var hasDelta:Boolean;
        private var mousePoint:Point;
        private var isPaused:Boolean;
        
        //Constructor
        public function Canvas(width:Number, height:Number, maxWidth:uint, maxHeight:uint, volume:Number, pitch:Number)
        {
            widthProperty = width;
            heightProperty = height;
            maxWidthProperty = maxWidth;
            maxHeightProperty = maxHeight;
            volumeProperty = volume;
            pitchProperty = pitch;
            
            nativeWindowHasFocus = true;
            mousePoint = new Point();
            isPaused = true;
            
            colorMap = new ColorMap();
            
            addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        //Initialize
        private function init(event:Event):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            
            noise = new Noise(maxWidthProperty, maxHeightProperty);
            noise.width = widthProperty;
            noise.height = heightProperty;
            noise.volume = 0.0;
            noise.pitch = 0.0;
            
            gradientOverlay = new GradientOverlay(widthProperty, heightProperty, colorMap.getColor(pitchProperty, 1.0 - volumeProperty));
            reticle = new Reticle(widthProperty, heightProperty, 0.0, 0.0);
            
            addChild(noise);
            addChild(gradientOverlay);
            addChild(reticle);

            noise.playImage();
            noise.playSound();
            
            popUpMenuItemPlayPause = new ContextMenuItem(POP_UP_MENU_PAUSE);
            
            popUpMenu = new NativeMenu();
            popUpMenu.addItem(popUpMenuItemPlayPause);
            popUpMenu.addEventListener(Event.SELECT, popUpMenuSelectEventHandler);
            
            Tweener.addTween(gradientOverlay.colorGradientMask, {alpha: 0.0, time: TWEEN_DURATION_FADE_IN, transition: TWEEN_TRANSITION_FADE_IN});
            Tweener.addTween(reticle, {volume: volumeProperty, pitch: pitchProperty, alpha: RETICLE_DEFAULT_ALPHA, time: TWEEN_DURATION_FADE_IN, transition: TWEEN_TRANSITION_FADE_IN});
            Tweener.addTween(noise, {volume: volumeProperty, pitch: pitchProperty, time: TWEEN_DURATION_FADE_IN, transition: TWEEN_TRANSITION_FADE_IN, onComplete: initComplete});
        }
        
        //Initialization Complete
        private function initComplete():void
        {
            stage.addEventListener(KeyboardEvent.KEY_DOWN, keyboardPauseEventHandler);
            stage.addEventListener(MouseEvent.RIGHT_MOUSE_UP, rightMouseUpEventHandler);
            
            togglePause();
        }
        
        //Toggle Pause
        private function togglePause():void
        {
            isPaused = !isPaused
            
            if (isPaused)
            {
                noise.stopImage();
                noise.stopSound();
                
                stage.nativeWindow.title = WINDOW_TITLE_PAUSED;
                
                popUpMenuItemPlayPause.caption = POP_UP_MENU_PLAY;
                
                removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownEventHandler);
                removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveEventHandler);
                removeEventListener(Event.ENTER_FRAME, enterFrameEventHandler);
                
                stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyboardEventHandler);
                stage.removeEventListener(KeyboardEvent.KEY_UP, keyboardEventHandler);
                
                toggleReticleMouseOverOutEvent(false);
            }
            else
            {
                noise.playImage();
                noise.playSound();
                
                stage.nativeWindow.title = WINDOW_TITLE;
                
                popUpMenuItemPlayPause.caption = POP_UP_MENU_PAUSE;
                
                addEventListener(MouseEvent.MOUSE_DOWN, mouseDownEventHandler);

                stage.addEventListener(KeyboardEvent.KEY_DOWN, keyboardEventHandler);
                stage.addEventListener(KeyboardEvent.KEY_UP, keyboardEventHandler);
                
                toggleReticleMouseOverOutEvent(true);
            }
        }
        
        //Mouse Down Event Handler
        private function mouseDownEventHandler(event:MouseEvent):void
        {
            if (nativeWindowHasFocus)
            {
                if (!popUpMenuIsDisplaying)
                {
                    reticle.removeEventListener(MouseEvent.MOUSE_OVER, reticleMouseOverOutEventHandler);
                    reticle.removeEventListener(MouseEvent.MOUSE_OUT, reticleMouseOverOutEventHandler);
                        
                    addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveEventHandler);
                    stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpEventHandler);
                    
                    mousePoint.x = stage.mouseX;
                    mousePoint.y = stage.mouseY;
                    
                    Tweener.addTween(   reticle,
                                        {
                                            pitch: Math.min(Math.max(0.0, (mousePoint.x - x) / reticle.width), 1.0),
                                            volume: 1.0 - Math.min(Math.max(0.0, (mousePoint.y - y) / reticle.height), 1.0),
                                            alpha: 1.0,
                                            time: TWEEN_DURATION,
                                            transition: TWEEN_TRANSITION,
                                            onUpdate: updateSoundAndColor
                                        }
                                    );
                }
                
                popUpMenuIsDisplaying = false;
            }
        }

        //Mouse Move Event Handler
        private function mouseMoveEventHandler(event:MouseEvent):void
        {
            Tweener.removeTweens(reticle, "pitch", "volume");
            
            hasDelta = true;
            
            removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveEventHandler);
            addEventListener(Event.ENTER_FRAME, enterFrameEventHandler);
        }

        //Enter Frame Event Handler
        private function enterFrameEventHandler(event:Event):void
        {
            if  (hasDelta)
            {
                deltaX = reticle.width * reticle.pitch - stage.mouseX + x; 
                deltaY = reticle.height * (1.0 - reticle.volume) - stage.mouseY + y;

                if  (Math.abs(deltaX) > DELTA_MINIMUM && Math.abs(deltaY) > DELTA_MINIMUM)
                {
                    reticle.pitch = (reticle.width * reticle.pitch - deltaX / DELTA_DURATION) / reticle.width;
                    reticle.volume = (reticle.height * reticle.volume + deltaY / DELTA_DURATION) / reticle.height;
                }
                else
                {
                    hasDelta = false;
                    return;
                }
            }
            else
            {
                reticle.pitch = Math.min(Math.max(0.0, (stage.mouseX - x) / widthProperty), 1.0);
                reticle.volume = 1.0 - Math.min(Math.max(0.0, (stage.mouseY - y) / heightProperty), 1.0);
                reticle.alpha = 1.0;
            }
            
            mousePoint.x = stage.mouseX;
            mousePoint.y = stage.mouseY; 
            
            updateSoundAndColor();
        }
        
        //Mouse Up Event Handler
        private function mouseUpEventHandler(event:MouseEvent):void
        {
            removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveEventHandler);
            removeEventListener(Event.ENTER_FRAME, enterFrameEventHandler);
            stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpEventHandler);
            
            toggleReticleMouseOverOutEvent(true);
                
            hasDelta = false;
            
            if (mousePoint.x != stage.mouseX && mousePoint.y != stage.mouseY)
            {
                Tweener.addTween(   reticle,
                                    {
                                        pitch: Math.min(Math.max(0.0, (mousePoint.x - x) / reticle.width), 1.0),
                                        volume: Math.min(Math.max(0.0, 1.0 - (mousePoint.y - y) / reticle.height), 1.0),
                                        time: TWEEN_DURATION,
                                        transition: TWEEN_TRANSITION,
                                        onUpdate: updateSoundAndColor
                                    }
                                );
            }
        }
        
        //Reticle Mouse Over Out Event Handler
        private function reticleMouseOverOutEventHandler(event:MouseEvent):void
        {
            if (nativeWindowHasFocus)
            {
                switch (event.type)
                {
                    case MouseEvent.MOUSE_OVER:     toggleReticleAlpha(true);
                                                    selectedReticle = Reticle(event.target);
                                                    break;
                                                    
                    case MouseEvent.MOUSE_OUT:      toggleReticleAlpha(false);
                                                    break;
                }
            }
        }

        //Right Mouse Up Event Handler
        private function rightMouseUpEventHandler(event:MouseEvent):void
        {
            if (nativeWindowHasFocus)
            {
                popUpMenuIsDisplaying = true;
                
                popUpMenu.display(stage, event.stageX, event.stageY);                
            }
        }
                
        //Keyboard Event Handler
        private function keyboardEventHandler(event:KeyboardEvent):void
        { 
            if (event.type == KeyboardEvent.KEY_DOWN)
            {
                switch (event.keyCode)
                {
                    case Keyboard.RIGHT:    reticle.pitch = Math.min(1.0, pitch + 1.0 / stage.stageWidth);
                                            toggleReticleMouseOverOutEvent(false);
                                            toggleReticleAlpha(true);
                                            break;
                                            
                    case Keyboard.LEFT:     reticle.pitch = Math.max(0.0, pitch - 1.0 / stage.stageWidth);
                                            toggleReticleMouseOverOutEvent(false);
                                            toggleReticleAlpha(true);
                                            break;
                                            
                    case Keyboard.UP:       reticle.volume = Math.min(1.0, volume + 1.0 / stage.stageHeight);
                                            toggleReticleMouseOverOutEvent(false);
                                            toggleReticleAlpha(true);
                                            break;
                                            
                    case Keyboard.DOWN:     reticle.volume = Math.max(0.0, volume - 1.0 / stage.stageHeight);
                                            toggleReticleMouseOverOutEvent(false);
                                            toggleReticleAlpha(true);
                }
            }
            else
            {
                if (event.keyCode == Keyboard.RIGHT || event.keyCode == Keyboard.LEFT || event.keyCode == Keyboard.UP || event.keyCode == Keyboard.DOWN)
                {
                    toggleReticleMouseOverOutEvent(true);
                    
                    if (mouseX != reticle.x || mouseY != reticle.y)
                    {
                        toggleReticleAlpha(false);                        
                    }
                }
            }
            
            updateSoundAndColor();
        }
        
        //Keyboard Pause Event Handler
        private function keyboardPauseEventHandler(event:KeyboardEvent):void
        {
            if (event.keyCode == Keyboard.SPACE)
            {
                togglePause();
            }
        }

        //Pop Up Menu Select Event Handler
        private function popUpMenuSelectEventHandler(event:Event):void
        {
            switch (event.target)
            {
                case popUpMenuItemPlayPause:        togglePause();
            }
            
            popUpMenuIsDisplaying = false;
        }
        
        //Update Sound And Color
        private function updateSoundAndColor():void
        {
            pitch = reticle.pitch;
            volume = reticle.volume;
            color = colorMap.getColor(reticle.pitch, 1.0 - reticle.volume);
        }
        
        //Dispose
        public function dispose():void
        {
            removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownEventHandler);
            removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveEventHandler);
            removeEventListener(Event.ENTER_FRAME, enterFrameEventHandler);
                
            stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpEventHandler);
            stage.removeEventListener(MouseEvent.RIGHT_MOUSE_UP, rightMouseUpEventHandler);
            stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyboardEventHandler);
            stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyboardPauseEventHandler)
            stage.removeEventListener(KeyboardEvent.KEY_UP, keyboardEventHandler);
            
            toggleReticleMouseOverOutEvent(false);
            
            Tweener.removeTweens(reticle);
            
            reticle.dispose();
            gradientOverlay.dispose();
            noise.dispose();
            
            while (numChildren)
            {
                removeChildAt(numChildren - 1);
            }
        }
        
        //Toggle Reticle Alpha
        private function toggleReticleAlpha(on:Boolean):void
        {
            Tweener.addTween(reticle, {alpha: (on) ? 1.0 : RETICLE_DEFAULT_ALPHA, time: TWEEN_DURATION, transition: TWEEN_TRANSITION});
        }
        
        //Toggle Reticle Mouse Over Out Event
        private function toggleReticleMouseOverOutEvent(on:Boolean):void
        {
            if (on)
            {
                reticle.addEventListener(MouseEvent.MOUSE_OVER, reticleMouseOverOutEventHandler);
                reticle.addEventListener(MouseEvent.MOUSE_OUT, reticleMouseOverOutEventHandler);
            }
            else
            {
                reticle.removeEventListener(MouseEvent.MOUSE_OVER, reticleMouseOverOutEventHandler);
                reticle.removeEventListener(MouseEvent.MOUSE_OUT, reticleMouseOverOutEventHandler);
            }
        }
        
        //Toggle Minimize Display State
        public function toggleMinimizeDisplayState(minimize:Boolean):void
        {
            if (!isPaused)
            {
                if (minimize)
                {
                    noise.stopImage();
                }
                else
                {
                    noise.playImage();
                }
            }
        }
        
        //Set Width
        override public function set width(value:Number):void
        {
            widthProperty = noise.width = gradientOverlay.width = reticle.width = value;
        }
        
        //Get Width
        override public function get width():Number
        {
            return widthProperty;
        }
        
        //Set Height
        override public function set height(value:Number):void
        {
            heightProperty = noise.height = gradientOverlay.height = reticle.height = value;
        }
        
        //Get Height
        override public function get height():Number
        {
            return heightProperty;
        }

        //Set Volume
        public function set volume(value:Number):void
        {
            volumeProperty = noise.volume = reticle.volume = value;
        }
        
        //Get Volume
        public function get volume():Number
        {
            return volumeProperty;
        }
        
        //Set Pitch
        public function set pitch(value:Number):void
        {
            pitchProperty = noise.pitch = reticle.pitch = value;
        }
        
        //Get Pitch
        public function get pitch():Number
        {
            return pitchProperty;
        }
        
        //Set Color
        public function set color(value:uint):void
        {
            gradientOverlay.color = value;
        }
        
        //Get Color
        public function get color():uint
        {
            return gradientOverlay.color;
        }
    }
}