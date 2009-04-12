/**
* @author Alexander Aivars (alexander.aivars(at)gmail.com)
*/
package as3ui.display
{
	import as3ui.events.UIEvent;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;

	[Event (name="resize", type="as3ui.events.UIEvent")]
	[Event (name="move", type="as3ui.events.UIEvent")]
	[Event (name="moveComplete", type="as3ui.events.UIEvent")]
	[Event (name="show", type="as3ui.events.UIEvent")]
	[Event (name="showComplete", type="as3ui.events.UIEvent")]
	[Event (name="hide", type="as3ui.events.UIEvent")]
	[Event (name="hideComplete", type="as3ui.events.UIEvent")]

	public class UISprite extends Sprite
	{
		protected var m_maxWidth		:	Number;
		protected var m_minWidth		:	Number;
		protected var m_maxHeight		:	Number;
		protected var m_minHeight		:	Number;
		protected var m_visibleHeight	:	Number;
		protected var m_visibleWidth	:	Number;
		protected var m_xpos			:	Number;
		protected var m_ypos			:	Number;
		protected var m_autosize		:	Boolean;
		
		public function UISprite()
		{
			if(m_autosize)
			{
				addEventListener(Event.ADDED,onAdded);
				addEventListener(Event.REMOVED,onRemoved);
			}
			super();
		}

		private function onAdded( a_event:Event ):void
		{
			if(a_event.target != this) return;
			parent.removeEventListener(UIEvent.RESIZE,parentResize);
			parent.addEventListener(UIEvent.RESIZE,parentResize);
		}
		
		private function onRemoved( a_event:Event ):void
		{
			if(a_event.target != this) return;
			parent.removeEventListener(UIEvent.RESIZE,parentResize);
		}
		
		public function move(a_x:Number,a_y:Number, a_pixelSnap:Boolean = false):void
		{
			var oldX:Number = m_xpos;
			var oldY:Number = m_ypos;
			
			m_xpos = a_x;
			m_ypos = a_y;
			
			if(a_pixelSnap == true)
			{
				this.x = Math.round(m_xpos);
				this.y = Math.round(m_ypos);
			}
			else 
			{
				this.x = m_xpos;
				this.y = m_ypos;				
			}
			
			if(oldX != this.x || oldY != this.y)
			{
				dispatchEvent(new UIEvent(UIEvent.MOVE,true,true));
				moveComplete();
			}
		}

		protected function moveComplete():void
		{
			dispatchEvent(new UIEvent(UIEvent.MOVE_COMPLETE,true,true));
		}


		protected function parentResize( a_event:Event = null):void
		{
			if( width != parent.width || height != parent.height )
			{
				setSize(parent.width,parent.height);
			}
		}

		public function show():void
		{
			
			dispatchEvent(new UIEvent(UIEvent.SHOW,true,true));
			showComplete();	
		}

		protected function showComplete():void
		{
//			if(!visible)
//			{
				visible = true;
				dispatchEvent(new UIEvent(UIEvent.SHOW_COMPLETE,true,true));
//			}
		}

		public function hide():void
		{
			if(visible)
			{
				dispatchEvent(new UIEvent(UIEvent.HIDE,true,true));
				hideComplete();
			}
		}
		
		protected function hideComplete():void
		{
			visible = false;
			dispatchEvent(new UIEvent(UIEvent.HIDE_COMPLETE,true,true));
		}


		public function setSize(a_width:Number = NaN, a_height:Number = NaN, a_pixelSnap:Boolean = false):void
		{
			var newWidth:Number;
			var newHeight:Number;

			if(isNaN(a_width))
			{
				a_width = super.width;
			}

			if(isNaN(a_height))
			{
				a_height = super.height;
			}

			if( a_pixelSnap )
			{
				a_height = Math.round( a_height );
				a_width = Math.round( a_width );
			}

			if(a_height<0)
			{
				a_height = 0;
			}

			if(a_width<0)
			{
				a_width = 0;
			}

			if(!isNaN(m_maxWidth) && !isNaN(m_minWidth))
			{
				newWidth = Math.max(Math.min(a_width,m_maxWidth),m_minWidth);
			}
			else if ( !isNaN(m_maxWidth) )
			{
				newWidth = Math.min(a_width,m_maxWidth);
			}
			else if ( !isNaN(m_minWidth) )
			{
				newWidth = Math.max(a_width,m_minWidth);
			}
			else
			{
				newWidth = a_width;
			}
			
			if(!isNaN(m_maxHeight) && !isNaN(m_minHeight))
			{
				newHeight = Math.max(Math.min(a_height,m_maxHeight),m_minHeight);
			}
			else if ( !isNaN(m_maxHeight) )
			{
				newHeight = Math.min(a_height,m_maxHeight);
			}
			else if ( !isNaN(m_minHeight) )
			{
				newHeight = Math.max(a_height,m_minHeight);
			}
			else
			{
				newHeight = a_height;
			}
	
	
			if( newWidth != m_visibleWidth || newHeight != m_visibleHeight )
			{
				m_visibleWidth = newWidth;	
				m_visibleHeight = newHeight;
				dispatchEvent(new UIEvent(UIEvent.RESIZE,true,true));
			}
		}
		
		public function setMaxSize(a_maxWidth:Number = NaN, a_maxHeight:Number = NaN):void
		{
			if(!isNaN(a_maxWidth)) m_maxWidth = a_maxWidth;
			if(!isNaN(a_maxHeight)) m_maxHeight = a_maxHeight;	
		}
		
		public function setMinSize(a_minWidth:Number = NaN, a_minHeight:Number = NaN):void
		{
			if(!isNaN(a_minWidth)) m_minWidth = a_minWidth;
			if(!isNaN(a_minHeight)) m_minHeight = a_minHeight;	
		}

		override public function get height():Number 
		{
			return isNaN(m_visibleHeight)?super.height:m_visibleHeight;
		}

		override public function get width():Number 
		{
			return isNaN(m_visibleWidth)?super.width:m_visibleWidth;
		}

		public function set globalX(value:Number):void
		{
			var origion:Point = stage.globalToLocal(localToGlobal(new Point(0,0) ));
			var diff:Number = value-origion.x;
			var result:Number = x + diff;
			m_xpos = x = result;

		}
	
		public function set globalY(value:Number):void
		{
			var origion:Point = stage.globalToLocal(localToGlobal(new Point(0,0) ));
			var diff:Number = value-origion.y;
			var result:Number = y + diff;
			
			m_ypos = y = result;

		}

		public function get globalX():Number
		{
			return stage.globalToLocal(localToGlobal(new Point(0,0) )).x;
		}
	
		public function get globalY():Number
		{
			return stage.globalToLocal(localToGlobal(new Point(0,0) )).y;
		}
		
		
	}
}