package
{
    //Imports
    import com.mattie.data.Archive;
    import com.mattie.events.ArchiveEvent;
    import flash.desktop.NativeApplication;
    import flash.display.NativeWindowDisplayState;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.NativeWindowBoundsEvent;
    import flash.events.NativeWindowDisplayStateEvent;
    import flash.events.TimerEvent;
    import flash.geom.Point;
    import flash.system.Capabilities;
    import flash.utils.Timer;

    //Class
    [SWF (backgroundColor = 0x000000, frameRate = 60)]
	public class OffAir extends Sprite
	{
        //Constants
        private static const DEFAULT_WINDOW_WIDTH:uint = 400;
        private static const DEFAULT_WINDOW_HEIGHT:uint = 222;
        private static const DEFAULT_VOLUME:Number = 0.75;
        private static const DEFAULT_PITCH:Number = 0.1;
        
        private static const MAX_WINDOW_WIDTH:uint = 800;
        private static const MAX_WINDOW_HEIGHT:uint = 422;
        
        private static const PREF_WINDOW_WIDTH:String = "prefWindowWidth";
        private static const PREF_WINDOW_HEIGHT:String = "prefWindowHeight";
        private static const PREF_WINDOW_X:String = "prefWindowX";
        private static const PREF_WINDOW_Y:String = "prefWindowY";
        private static const PREF_CANVAS_VOLUME:String = "prefCanvasVolume";
        private static const PREF_CANVAS_PITCH:String = "prefCanvasPitch";

        //Properties
        private var archive:Archive;
        private var canvas:Canvas;
        
        //Variables
        private var canvasVolume:Number;
        private var canvasPitch:Number;
        private var activationTimer:Timer;
        
        //Constructor
		public function OffAir()
		{
            stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

            stage.nativeWindow.minSize = new Point(DEFAULT_WINDOW_WIDTH, DEFAULT_WINDOW_HEIGHT);
            stage.nativeWindow.maxSize = new Point(MAX_WINDOW_WIDTH, MAX_WINDOW_HEIGHT);
            
            activationTimer = new Timer(100, 1);
            activationTimer.addEventListener(TimerEvent.TIMER, activationTimerEventHandler);
                                            
            initArchive();
        }
        
        //Initialize Archive
        private function initArchive():void
        {
            archive = new Archive();
            archive.addEventListener(ArchiveEvent.LOAD, init);
            archive.load();
		}
        
        //Initialize
        private function init(event:ArchiveEvent):void
        {
            archive.removeEventListener(ArchiveEvent.LOAD, init);
            
            var screenWidth:uint = Capabilities.screenResolutionX;
            var screenHeight:uint = Capabilities.screenResolutionY;
            
            stage.nativeWindow.width = archive.read(PREF_WINDOW_WIDTH, DEFAULT_WINDOW_WIDTH);
            stage.nativeWindow.height = archive.read(PREF_WINDOW_HEIGHT, DEFAULT_WINDOW_HEIGHT);
            stage.nativeWindow.x = archive.read(PREF_WINDOW_X, screenWidth / 2 - stage.nativeWindow.width / 2);
            stage.nativeWindow.y = archive.read(PREF_WINDOW_Y, screenHeight / 2 - stage.nativeWindow.height / 2);
            
            canvasVolume = archive.read(PREF_CANVAS_VOLUME, DEFAULT_VOLUME);
            canvasPitch = archive.read(PREF_CANVAS_PITCH, DEFAULT_PITCH);

            canvas = new Canvas(stage.stageWidth, stage.stageHeight, MAX_WINDOW_WIDTH, MAX_WINDOW_HEIGHT, canvasVolume, canvasPitch);
            
            stage.nativeWindow.addEventListener(NativeWindowBoundsEvent.RESIZE, resizeWindowEventHandler);
            stage.nativeWindow.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE, displayStateChangeEventHandler);
            stage.nativeWindow.addEventListener(Event.ACTIVATE, applicationFocusEventHandler);
            stage.nativeWindow.addEventListener(Event.DEACTIVATE, applicationFocusEventHandler);
            stage.nativeWindow.addEventListener(Event.CLOSING, applicationExitingEventHandler);
            
            addChild(canvas);          
        }
        
        //Resize Window Event Handler
        private function resizeWindowEventHandler(event:NativeWindowBoundsEvent):void
        {
            canvas.width = stage.stageWidth;
            canvas.height = stage.stageHeight;
        }
        
        //Display State Change Event Handler
        private function displayStateChangeEventHandler(event:NativeWindowDisplayStateEvent):void
        {
            switch (stage.nativeWindow.displayState)
            {
                case NativeWindowDisplayState.MINIMIZED:    canvas.toggleMinimizeDisplayState(true);
                                                            break;
                                                            
                case NativeWindowDisplayState.NORMAL:       canvas.toggleMinimizeDisplayState(false);
            }
        }
        
        //Application Focus Event Handler
        private function applicationFocusEventHandler(event:Event):void
        {
            switch (event.type)
            {
                case Event.ACTIVATE:        activationTimer.start();
                                            break;
                                            
                case Event.DEACTIVATE:      if (activationTimer.running)
                                            {
                                                activationTimer.stop();
                                            }
                                            
                                            canvas.nativeWindowHasFocus = false;
                                            canvas.popUpMenuIsDisplaying = false;
            }
            
        }
        
        //Activation Timer Event Handler
        private function activationTimerEventHandler(event:TimerEvent):void
        {
            canvas.nativeWindowHasFocus = true;
        }
        
        //Application Exiting Event Handler
        private function applicationExitingEventHandler(event:Event):void
        {
            stage.nativeWindow.removeEventListener(Event.CLOSING, applicationExitingEventHandler);
            
            archive.write(PREF_WINDOW_WIDTH, stage.nativeWindow.width);
            archive.write(PREF_WINDOW_HEIGHT, stage.nativeWindow.height);
            archive.write(PREF_WINDOW_X, stage.nativeWindow.x);
            archive.write(PREF_WINDOW_Y, stage.nativeWindow.y);
            archive.write(PREF_CANVAS_VOLUME, canvas.volume);
            archive.write(PREF_CANVAS_PITCH, canvas.pitch);

            archive.addEventListener(ArchiveEvent.SAVE, archiveSavedEventHandler);
            archive.save();
        }
        
        //Archive Saved Event Handler
        private function archiveSavedEventHandler(event:ArchiveEvent):void
        {
            archive.removeEventListener(ArchiveEvent.SAVE, archiveSavedEventHandler);
            
            NativeApplication.nativeApplication.exit();
        }
	}
}