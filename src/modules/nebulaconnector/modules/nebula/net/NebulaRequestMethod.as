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
    /**
     * The NebulaRequestMethod indicates the value of the HTTP Method that the NebulaRequest should use when sending data to a server.
     *
     * @author joe (joe@nothing.ch)
     */
    public class NebulaRequestMethod
    {
        /** Defines that the NebulaRequest should be submitted using the DELETE method. */
        public static const DELETE:String = "DELETE";
        /** Defines that the NebulaRequest should be submitted using the GET method. */
        public static const GET:String = "GET";
        /** Defines that the NebulaRequest should be submitted using the POST method. */
        public static const POST:String = "POST";
        /** Defines that the NebulaRequest should be submitted using the PUT method. */
        public static const PUT:String = "PUT";
		/** Defines that the NebulaRequest should be submitted using the POST method with
		 * a X-HTTP-Method-Override: GET header.
		 */
		public static const GET_OVERRIDE:String = "GET_OVERRIDE";
    }
}
