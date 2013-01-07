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
    public final class NebulaScore
    {
        /** Date in which the score was produced. */
        public var date:Date;
		/** Identifier of the last checkpoint reached with the score. */
		public var lastCheckpoint:String;
		/** Identifier of the last level reached with the score. */
		public var lastLevel:String;
        /** Location in which the score was produced. */
        public var location:NebulaLocation;
        /** Player that produced the score. */
        public var player:NebulaPlayer;
        /** Score produced by the given player. */
        public var score:int;

        /**
         * Creates a new NebulaScore instance.
         */
        public function NebulaScore()
        {
            location = null;
            player = null;
			lastCheckpoint = null;
			lastLevel = null;
            score = 0;
            date = null;
        }

        public function toString():String
        {
            return StringUtils.format("[NebulaScore player={0} score={1} lastLevel=\"{2}\" lastCheckpoint=\"{3}\" location={4} date={5}]", player, score, lastLevel, lastCheckpoint, location, date);
        }
    }
}
