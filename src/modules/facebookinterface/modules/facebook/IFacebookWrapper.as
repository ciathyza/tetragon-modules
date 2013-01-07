/*
 *      _________  __      __
 *    _/        / / /____ / /________ ____ ____  ___
 *   _/        / / __/ -_) __/ __/ _ `/ _ `/ _ \/ _ \
 *  _/________/  \__/\__/\__/_/  \_,_/\_, /\___/_//_/
 *                                   /___/
 * 
 * tetragon : Engine for Flash-based web and desktop games.
 * Licensed under the MIT License.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package modules.facebook
{
	import com.facebook.graph.data.Batch;
	import com.facebook.graph.data.FQLMultiQuery;
	import com.facebook.graph.data.FacebookAuthResponse;
	import com.facebook.graph.data.FacebookSession;
	import com.facebook.graph.net.FacebookRequest;
	import com.facebook.graph.utils.IResultParser;
	
	
	/**
	 * IFacebookWrapper Interface
	 */
	public interface IFacebookWrapper
	{
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		function init(applicationId:String, callback:Function = null, options:Object = null, accessToken:String = null):void;
		function login(callback:Function, extendedPermissions:Array = null):void;
		function logout(callback:Function = null, appOrigin:String = null):void
		function postData(method:String, callback:Function, params:* = null):void
		function api(method:String, callback:Function = null, params:* = null, requestMethod:String = "GET"):void
		function batchRequest(batch:Batch, callback:Function = null):void
		function callRestAPI(methodName:String, callback:Function = null, values:* = null, requestMethod:String = "GET"):void
		function deleteObject(method:String, callback:Function = null):void;
		function fqlMultiQuery(queries:FQLMultiQuery, callback:Function = null, parser:IResultParser = null):void
		function fqlQuery(query:String, callback:Function = null, values:Object = null):void
		function getImageUrl(id:String, type:String = null):String
		function getRawResult(data:Object):Object
		function getSession():FacebookSession
		function hasNext(data:Object):Boolean
		function hasPrevious(data:Object):Boolean
		function nextPage(data:Object, callback:Function):FacebookRequest
		function previousPage(data:Object, callback:Function):FacebookRequest
		function requestExtendedPermissions(callback:Function, ...args:*):void
		function uploadVideo(method:String, callback:Function = null, params:* = null):void
		
		/* Web only! */
		function addJSEventListener(event:String, listener:Function):void
		function removeJSEventListener(event:String, listener:Function):void
		function callJS(methodName:String, params:Object):void
		function getAuthResponse():FacebookAuthResponse
		function getLoginStatus():void
		function hasJSEventListener(event:String, listener:Function):Boolean
		function mobileLogin(redirectUri:String, display:String = "touch", extendedPermissions:Array = null):void
		function mobileLogout(redirectUri:String):void
		function setCanvasAutoResize(autoSize:Boolean = true, interval:uint = 100):void
		function setCanvasSize(width:Number, height:Number):void
		function ui(method:String, data:Object, callback:Function = null, display:String = null):void
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		function set locale(v:String):void;
		function set manageSession(v:Boolean):void;
	}
}
