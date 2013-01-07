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
package modules.nebula.data
{
    import modules.nebula.utils.StringUtils;

    /**
     * @author joe (joe@nothing.ch)
     */
    public class NebulaSession
    {
        /**
         * Authorization token of the current session. It should be included with the request everytime that a
         * call needs to be signed.
         */
        public var authToken:String;
        /** The date in which this session will expire. Currently this property is not used.*/
        public var expireDate:Date;
        /** Identifier of the current session. It is returned by the server. */
        public var id:int;
        /** Life in seconds, of the current session. */
        public var lifetime:int;
        /** Current location of the player. */
        public var location:Object;
        /** Nonce number used to identify each message. It should be incremented after each usage. */
        public var nonce:int;
        /** Current player of the session. */
        public var player:NebulaPlayer;
        /** Key used in conjuction with the secret key to sign every request. */
        public var sessionKey:String;

        /**
         * Creates a new NebulaSession instance.
         *
         * @param id
         * @param key
         * @param authToken
         * @param nonce
         *
         */
        public function NebulaSession(id:int, sessionKey:String, authToken:String, nonce:int, lifetime:int):void
        {
            // initializes the variables.
            this.id = id;
            this.sessionKey = sessionKey;
            this.authToken = authToken;
            this.nonce = nonce;
            this.lifetime = lifetime;

            location = null;
            player = null;
        }

        public function toString():String
        {
            return StringUtils.format("[NebulaSession id={0}]", id);
        }
    }
}
