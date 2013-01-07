/*
 *      _________  __      __
 *    _/        / / /____ / /________ ____ ____  ___
 *   _/        / / __/ -_) __/ __/ _ `/ _ `/ _ \/ _ \
 *  _/________/  \__/\__/\__/_/  \_,_/\_, /\___/_//_/
 *                                   /___/
 * 
 * Tetragon : Game Engine for multi-platform ActionScript projects.
 * http://www.tetragonengine.com/
 * Copyright (c) The respective Copyright Holder (see LICENSE).
 * 
 * Permission is hereby granted, to any person obtaining a copy of this software
 * and associated documentation files (the "Software") under the rules defined in
 * the license found at http://www.tetragonengine.com/license/ or the LICENSE
 * file included within this distribution.
 * 
 * The above copyright notice and this permission notice must be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND. THE COPYRIGHT
 * HOLDER AND ITS LICENSORS DISCLAIM ALL WARRANTIES AND CONDITIONS, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO ANY IMPLIED WARRANTIES AND CONDITIONS OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT, AND ANY
 * WARRANTIES AND CONDITIONS ARISING OUT OF COURSE OF DEALING OR USAGE OF TRADE.
 * NO ADVICE OR INFORMATION, WHETHER ORAL OR WRITTEN, OBTAINED FROM THE COPYRIGHT
 * HOLDER OR ELSEWHERE WILL CREATE ANY WARRANTY OR CONDITION NOT EXPRESSLY STATED
 * IN THIS AGREEMENT.
 */
package modules.nebula.net
{
    import flash.net.URLRequest;
    
    import modules.nebula.utils.StringUtils;

    /**
     * NebulaRequest VO.
     *
     * @author hexagon (hexagon@nothing.ch)
     * @author joe (joe@nothing.ch)
     */
    public final class NebulaRequest
    {
        /** Function that needs to be executed before performing the request. */
        public var beforeSendHandler:Function;
        /** Function used to handle an error in the request. */
        public var errorHandler:Function;
        /** HTTP method that will be used to perform the request. */
        public var requestMethod:String;
        /** Response from the service. */
        public var responseData:Object;
        /** Object containing the data that needs to be sent.*/
        public var sendData:Object;
        /** Function used to handle the success of the request. */
        public var successHandler:Function;
        /** API method that will be called. */
        public var urlPath:String;
        /** URLRequest used to communicate with the service. */
        public var urlRequest:URLRequest;

        /**
         * Creates a new instance of the class.
         *
         * @param requestMethod
         * @param urlPath
         * @param sendData
         * @param successHandler
         * @param errorHandler
         */
        public function NebulaRequest(requestMethod:String, urlPath:String, sendData:Object = null, successHandler:Function = null, errorHandler:Function = null)
        {
            this.requestMethod = requestMethod;
            this.urlPath = urlPath;
            this.sendData = sendData || {};
            this.successHandler = successHandler;
            this.errorHandler = errorHandler;
        }

        /**
         * @inheritDoc
         */
        public function toString():String
        {
            return StringUtils.format("[NebulaRequest requestMethod={0} urlPath={1}]", requestMethod, urlPath);
        }
    }
}
