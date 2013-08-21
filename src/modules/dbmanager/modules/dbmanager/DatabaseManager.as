/*
 *      _________  __      __
 *    _/        / / /____ / /________ ____ ____  ___
 *   _/        / / __/ -_) __/ __/ _ `/ _ `/ _ \/ _ \
 *  _/________/  \__/\__/\__/_/  \_,_/\_, /\___/_//_/
 *                                   /___/
 * 
 * Tetragon : Game Engine for multi-platform ActionScript projects.
 * http://www.tetragonengine.com/ - Copyright (C) 2012 Sascha Balkau
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
package modules.dbmanager
{
	import tetragon.core.signals.Signal;
	import tetragon.data.Settings;
	import tetragon.debug.Log;
	import tetragon.modules.IModule;
	import tetragon.modules.IModuleInfo;
	import tetragon.modules.Module;
	import tetragon.util.structures.queues.Queue;

	import flash.data.SQLConnection;
	import flash.data.SQLMode;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.Dictionary;
	
	
	/**
	 * 
	 */
	public final class DatabaseManager extends Module implements IModule
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		private static const MODE_OPEN_DB:String							= "modeOpenDB";
		private static const MODE_CREATE_DB:String							= "modeCreateDB";
		private static const MODE_CREATE_TABLES:String						= "modeCreateTables";
		private static const MODE_INSERT_DEFAULT_ROWS:String				= "modeInsertDefaultRows";
		private static const MODE_INSERT_DEFAULT_ROWS_AFTER_RESET:String	= "modeInsertDefaultRowsAfterReset";
		private static const MODE_RESET_TABLE:String						= "modeResetTable";
		private static const MODE_ADD_ROW:String							= "modeAddRow";
		private static const MODE_CONTAINS_ROW:String						= "modeContainsRow";
		private static const MODE_UPDATE_ROW:String							= "modeUpdateRow";
		private static const MODE_QUERY:String								= "modeQuery";
		private static const MODE_EXPORT:String								= "modeExport";
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _connection:SQLConnection;
		private var _manifests:Dictionary;
		private var _mode:String;
		private var _manifestMap:Dictionary;
		private var _manifestQueue:Queue;
		private var _exportTablesMap:Dictionary;
		
		private var _rowsInsertCount:int;
		private var _exportTablesCount:int;
		
		private var _userDataPath:String;
		private var _csvExportSeparator:String;
		
		private var _debug:Boolean;
		private var _isInsertDefaultRows:Boolean;
		private var _csvExportIncludeHeaders:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Signals
		//-----------------------------------------------------------------------------------------
		
		private var _databaseCreatedSignal:Signal;
		private var _containsRowSignal:Signal;
		private var _rowAddedSignal:Signal;
		private var _rowUpdatedSignal:Signal;
		private var _tableResetSignal:Signal;
		private var _querySignal:Signal;
		private var _exportSignal:Signal;
		private var _errorSignal:Signal;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function init():void
		{
			_manifests = new Dictionary();
			_manifestMap = new Dictionary();
			_manifestQueue = new Queue();
			_exportTablesMap = new Dictionary();
			
			_userDataPath = main.registry.settings.getString(Settings.USER_DATA_DIR);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function start():void
		{
			_connection = new SQLConnection();
			_connection.addEventListener(SQLEvent.OPEN, onConnectionOpen);
			_connection.addEventListener(SQLEvent.CLOSE, onConnectionClose);
			_connection.addEventListener(SQLErrorEvent.ERROR, onConnectionError);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function stop():void
		{
			_connection.close();
		}
		
		
		/**
		 * @param manifest
		 * @param force
		 */
		public function createDatabase(manifest:DatabaseManifest, force:Boolean = false):void
		{
			if (!manifest || _manifests[manifest.id != null]) return;
			_manifests[manifest.id] = manifest;
			_manifestQueue.enqueue(manifest);
			
			if (force || !manifest.file.exists)
			{
				Log.verbose("Creating database in " + manifest.file.nativePath + " ...", this);
				_mode = MODE_CREATE_DB;
				_connection.openAsync(manifest.file, SQLMode.CREATE);
			}
			else
			{
				Log.verbose("Opening database in " + manifest.file.nativePath + " ...", this);
				_mode = MODE_OPEN_DB;
				_connection.openAsync(manifest.file, SQLMode.UPDATE);
			}
		}
		
		
		/**
		 * @param databaseID
		 */
		public function resetDatabaseTable(databaseID:String, tableName:String):void
		{
			var manifest:DatabaseManifest = _manifests[databaseID];
			if (!manifest) return;
			var table:DBTable = manifest.getTable(tableName);
			if (!table) return;
			
			_mode = MODE_RESET_TABLE;
			
			var text:String = "DELETE FROM '" + table.name + "';";
			var statement:SQLStatement = getNewSQLStatement();
			
			statement.text = text;
			_manifestMap[statement] = manifest;
			
			logStatement(statement);
			statement.execute();
		}
		
		
		/**
		 * @param databaseID
		 * @param separator
		 * @param includeHeaders
		 */
		public function exportToCSV(databaseID:String, separator:String = ";",
			includeHeaders:Boolean = true):void
		{
			var manifest:DatabaseManifest = _manifests[databaseID];
			if (!manifest) return;
			
			_mode = MODE_EXPORT;
			
			_csvExportSeparator = separator;
			_csvExportIncludeHeaders = includeHeaders;
			
			var tables:Vector.<DBTable> = manifest.tables;
			_exportTablesCount = tables.length;
			for (var i:uint = 0; i < _exportTablesCount; i++)
			{
				var table:DBTable = tables[i];
				var text:String = "SELECT * FROM '" + table.name + "';";
				var statement:SQLStatement = getNewSQLStatement();
				
				statement.text = text;
				_manifestMap[statement] = manifest;
				_exportTablesMap[statement] = table;
				
				logStatement(statement);
				statement.execute();
			}
		}
		
		
		/**
		 * @param databaseID
		 */
		public function databaseExists(databaseID:String):Boolean
		{
			var manifest:DatabaseManifest = _manifests[databaseID];
			if (!manifest) return false;
			return new File(manifest.filePath).exists;
		}
		
		
		/**
		 * Adds a row of values into a specific database table.
		 * 
		 * @param databaseID
		 * @param tableName
		 * @param values
		 */
		public function addRow(databaseID:String, tableName:String, values:Array):void
		{
			var manifest:DatabaseManifest = _manifests[databaseID];
			if (!manifest || !values) return;
			var table:DBTable = manifest.getTable(tableName);
			if (!table) return;
			
			_mode = MODE_ADD_ROW;
			
			var columns:Vector.<DBColumn> = table.columns;
			var text:String = "INSERT INTO '" + table.name + "' (";
			var statement:SQLStatement = getNewSQLStatement();
			var j:uint;
			
			for (j = 0; j < columns.length; j++)
			{
				var column:DBColumn = columns[j];
				text += "'" + column.name + "'";
				if (j < columns.length - 1) text += ", ";
			}
			text += ") VALUES (";
			
			for (j = 0; j < values.length; j++)
			{
				text += "?" + (j + 1);
				if (j < columns.length - 1) text += ", ";
			}
			text += ");";
			
			statement.text = text;
			
			for (j = 0; j < values.length; j++)
			{
				statement.parameters[j] = values[j];
			}
			
			_manifestMap[statement] = manifest;
			
			logStatement(statement);
			statement.execute();
		}
		
		
		/**
		 * Updates values in a specific database table row. If the row doesn't exist, it will
		 * be created.
		 * 
		 * @param databaseID
		 * @param tableName
		 * @param rowID ID or value (in the primary key field) of the row to be updated.
		 * @param values
		 */
		public function updateRow(databaseID:String, tableName:String, rowID:*, values:Array):void
		{
			var manifest:DatabaseManifest = _manifests[databaseID];
			if (!manifest || !values) return;
			var table:DBTable = manifest.getTable(tableName);
			if (!table) return;
			
			_mode = MODE_UPDATE_ROW;
			
			var columns:Vector.<DBColumn> = table.columns;
			var text:String = "UPDATE '" + table.name + "' SET ";
			var statement:SQLStatement = getNewSQLStatement();
			var j:uint;
			
			for (j = 0; j < columns.length; j++)
			{
				var column:DBColumn = columns[j];
				text += "'" + column.name + "'=?" + (j + 1);
				if (j < columns.length - 1) text += ", ";
			}
			text += " WHERE " + table.primaryKey + "=" + "'" + rowID + "';";
			
			statement.text = text;
			
			for (j = 0; j < values.length; j++)
			{
				statement.parameters[j] = values[j];
			}
			
			_manifestMap[statement] = manifest;
			
			logStatement(statement);
			statement.execute();
		}
		
		
		/**
		 * Retrieves values from a specific database table.
		 * 
		 * @param databaseID
		 * @param tableName
		 * @param key
		 * @param value
		 */
		public function query(databaseID:String, tableName:String, key:* = null, value:* = null):void
		{
			var manifest:DatabaseManifest = _manifests[databaseID];
			if (!manifest) return;
			var table:DBTable = manifest.getTable(tableName);
			if (!table) return;
			
			_mode = MODE_QUERY;
			
			var text:String;
			if (key == null && value == null)
			{
				text = "SELECT * FROM '" + table.name + "';";
			}
			else
			{
				text = "SELECT * FROM '" + table.name + "' WHERE " + key + "='" + value + "';";
			}
			var statement:SQLStatement = getNewSQLStatement();
			
			statement.text = text;
			_manifestMap[statement] = manifest;
			
			logStatement(statement);
			statement.execute();
		}
		
		
		/**
		 * 
		 */
		public function containsRow(databaseID:String, tableName:String, primaryKey:String, value:*):void
		{
			var manifest:DatabaseManifest = _manifests[databaseID];
			if (!manifest || primaryKey == null) return;
			var table:DBTable = manifest.getTable(tableName);
			if (!table) return;
			
			_mode = MODE_CONTAINS_ROW;
			
			var text:String = "SELECT * FROM '" + table.name + "' WHERE " + primaryKey + "='" + value + "';";
			var statement:SQLStatement = getNewSQLStatement();
			
			statement.text = text;
			_manifestMap[statement] = manifest;
			
			logStatement(statement);
			statement.execute();
		}
		
		
		/**
		 * @param id
		 */
		public function getDatabaseManifest(id:String):DatabaseManifest
		{
			return _manifests[id];
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public static function get defaultID():String
		{
			return "databaseManager";
		}
		
		
		override public function get moduleInfo():IModuleInfo
		{
			return new DatabaseManagerModuleInfo();
		}


		public function get debug():Boolean
		{
			return _debug;
		}
		public function set debug(v:Boolean):void
		{
			_debug = v;
		}
		
		
		public function get databaseCreatedSignal():Signal
		{
			if (!_databaseCreatedSignal) _databaseCreatedSignal = new Signal();
			return _databaseCreatedSignal;
		}
		
		
		public function get containsRowSignal():Signal
		{
			if (!_containsRowSignal) _containsRowSignal = new Signal();
			return _containsRowSignal;
		}
		
		
		public function get rowAddedSignal():Signal
		{
			if (!_rowAddedSignal) _rowAddedSignal = new Signal();
			return _rowAddedSignal;
		}
		
		
		public function get rowUpdatedSignal():Signal
		{
			if (!_rowUpdatedSignal) _rowUpdatedSignal = new Signal();
			return _rowUpdatedSignal;
		}
		
		
		public function get querySignal():Signal
		{
			if (!_querySignal) _querySignal = new Signal();
			return _querySignal;
		}
		
		
		public function get tableResetSignal():Signal
		{
			if (!_tableResetSignal) _tableResetSignal = new Signal();
			return _tableResetSignal;
		}
		
		
		public function get exportSignal():Signal
		{
			if (!_exportSignal) _exportSignal = new Signal();
			return _exportSignal;
		}
		
		
		public function get errorSignal():Signal
		{
			if (!_errorSignal) _errorSignal = new Signal();
			return _errorSignal;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function onConnectionOpen(e:SQLEvent):void
		{
			var manifest:DatabaseManifest = _manifestQueue.dequeue();
			if (!manifest) return;
			
			Log.debug("Database with ID \"" + manifest.id + "\" opened.", this);
			
			/* Mode is create and db was just opened! Proceed to create db structure. */
			if (_mode == MODE_CREATE_DB)
			{
				createDatabaseTables(manifest);
			}
		}
		
		
		/**
		 * @private
		 */
		private function onConnectionClose(e:SQLEvent):void
		{
			Log.debug("Database closed.", this);
			_connection.removeEventListener(SQLEvent.OPEN, onConnectionOpen);
			_connection.removeEventListener(SQLEvent.CLOSE, onConnectionClose);
			_connection.removeEventListener(SQLErrorEvent.ERROR, onConnectionError);
		}
		
		
		/**
		 * @private
		 */
		private function onConnectionError(e:SQLErrorEvent):void
		{
			Log.error("Connection error: " + e.error.message + " (Details: "
				+ e.error.details + ").", this);
			if (_errorSignal) _errorSignal.dispatch();
		}
		
		
		/**
		 * @private
		 */
		private function onStatementResult(e:SQLEvent):void
		{
			var statement:SQLStatement = e.currentTarget as SQLStatement;
			statement.removeEventListener(SQLEvent.RESULT, onStatementResult);
			statement.removeEventListener(SQLErrorEvent.ERROR, onStatementError);
			
			var manifest:DatabaseManifest = _manifestMap[statement];
			delete _manifestMap[statement];
			
			var result:SQLResult = statement.getResult();
			var resultData:Array = result ? result.data : null;
			
			//Debug.traceObj(resultData);
			
			switch (_mode)
			{
				case MODE_CREATE_TABLES:
					if (manifest.rowsNum > 0)
					{
						_mode = MODE_INSERT_DEFAULT_ROWS;
						insertDefaultRows(manifest);
					}
					else
					{
						_mode = null;
						if (_databaseCreatedSignal) _databaseCreatedSignal.dispatch();
					}
					break;
				case MODE_INSERT_DEFAULT_ROWS:
					_rowsInsertCount--;
					if (_rowsInsertCount <= -1)
					{
						_rowsInsertCount = 0;
						_mode = null;
						_isInsertDefaultRows = false;
						if (_databaseCreatedSignal) _databaseCreatedSignal.dispatch();
					}
					break;
				case MODE_CONTAINS_ROW:
					_mode = null;
					var rowExists:Boolean = (resultData != null && resultData.length > 0);
					if (_containsRowSignal) _containsRowSignal.dispatch(rowExists);
					break;
				case MODE_ADD_ROW:
					_mode = null;
					if (_rowAddedSignal) _rowAddedSignal.dispatch();
					break;
				case MODE_UPDATE_ROW:
					_mode = null;
					if (_rowUpdatedSignal) _rowUpdatedSignal.dispatch();
					break;
				case MODE_QUERY:
					_mode = null;
					if (_querySignal) _querySignal.dispatch(resultData);
					break;
				case MODE_RESET_TABLE:
					if (manifest.rowsNum > 0)
					{
						_mode = MODE_INSERT_DEFAULT_ROWS_AFTER_RESET;
						insertDefaultRows(manifest);
					}
					else
					{
						_mode = null;
						if (_tableResetSignal) _tableResetSignal.dispatch();
					}
					break;
				case MODE_INSERT_DEFAULT_ROWS_AFTER_RESET:
					_rowsInsertCount--;
					if (_rowsInsertCount <= 0)
					{
						_rowsInsertCount = 0;
						_mode = null;
						_isInsertDefaultRows = false;
						_connection.compact();
						if (_tableResetSignal) _tableResetSignal.dispatch();
					}
					break;
				case MODE_EXPORT:
					var exportedTable:DBTable = _exportTablesMap[statement];
					delete _exportTablesMap[statement];
					exportDataToFile(manifest, exportedTable, resultData);
					break;
			}
		}
		
		
		/**
		 * @private
		 */
		private function onStatementError(e:SQLErrorEvent):void
		{
			var statement:SQLStatement = e.currentTarget as SQLStatement;
			statement.removeEventListener(SQLEvent.RESULT, onStatementResult);
			statement.removeEventListener(SQLErrorEvent.ERROR, onStatementError);
			
			/* If tried to insert a default row with an already existing primary key,
			 * it results in an error. In that case ignore the error and dispatch after
			 * finished! Ideally we shouid check for row-existance before instead of
			 * relying on errors here. */
			if (_mode == MODE_INSERT_DEFAULT_ROWS && _isInsertDefaultRows)
			{
				Log.notice("Rows already existed for some tables, ignoring!", this);
				if (_rowsInsertCount == 0)
				{
					_mode = null;
					_isInsertDefaultRows = false;
					if (_databaseCreatedSignal) _databaseCreatedSignal.dispatch();
				}
				else
				{
					_rowsInsertCount--;
				}
				return;
			}
			
			if (_mode == MODE_INSERT_DEFAULT_ROWS_AFTER_RESET && _isInsertDefaultRows)
			{
				Log.notice("Rows already existed for some tables, ignoring!", this);
				_rowsInsertCount--; // TODO Needs tersting!!
				if (_rowsInsertCount == 0)
				{
					_mode = null;
					_isInsertDefaultRows = false;
					if (_tableResetSignal) _tableResetSignal.dispatch();
				}
				else
				{
					//_rowsInsertCount--;
				}
				return;
			}
			
			var msg:String = e.error.message;
			Log.error("SQLStatement error: " + msg + " (Details: " + e.error.details + ").", this);
			if (_errorSignal) _errorSignal.dispatch();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function createDatabaseTables(manifest:DatabaseManifest):void
		{
			Log.verbose("Creating database tables ...", this);
			
			_mode = MODE_CREATE_TABLES;
			var tables:Vector.<DBTable> = manifest.tables;
			
			for (var i:uint = 0; i < tables.length; i++)
			{
				var table:DBTable = tables[i];
				var columns:Vector.<DBColumn> = table.columns;
				var statement:SQLStatement = getNewSQLStatement();
				var text:String = "CREATE TABLE IF NOT EXISTS '" + table.name + "' (";
				
				for (var j:uint = 0; j < columns.length; j++)
				{
					var column:DBColumn = columns[j];
					text += "'" + column.name + "'";
					text += " " + column.type + "";
					if (column.primaryKey) text += " PRIMARY KEY";
					if (column.autoInc) text += " AUTOINCREMENT";
					if (!column.allowNull) text += " NOT NULL";
					if (column.unique) text += " UNIQUE";
					if (column.defaultValue != null) text += " DEFAULT " + column.defaultValue;
					if (j < columns.length - 1) text += ", ";
				}
				text += ");";
				
				statement.text = text;
				_manifestMap[statement] = manifest;
				
				logStatement(statement);
				statement.execute();
			}
		}
		
		
		/**
		 * @private
		 */
		private function insertDefaultRows(manifest:DatabaseManifest):void
		{
			Log.verbose("Inserting " + manifest.rowsNum + " default rows into database tables ...", this);
			
			_isInsertDefaultRows = true;
			_rowsInsertCount += manifest.rowsNum;
			
			var tables:Vector.<DBTable> = manifest.tables;
			
			for (var i:uint = 0; i < tables.length; i++)
			{
				var table:DBTable = tables[i];
				var columns:Vector.<DBColumn> = table.columns;
				var rows:Vector.<Array> = table.rows;
				
				if (!rows) continue;
				
				for (var k:uint = 0; k < rows.length; k++)
				{
					var row:Array = rows[k];
					var statement:SQLStatement = getNewSQLStatement();
					var text:String = "INSERT INTO '" + table.name + "' (";
					var j:uint;
					
					for (j = 0; j < columns.length; j++)
					{
						var column:DBColumn = columns[j];
						text += "'" + column.name + "'";
						if (j < columns.length - 1) text += ", ";
					}
					text += ") VALUES (";
					
					for (j = 0; j < row.length; j++)
					{
						text += "?" + (j + 1);
						if (j < columns.length - 1) text += ", ";
					}
					text += ");";
					
					statement.text = text;
					
					for (j = 0; j < row.length; j++)
					{
						statement.parameters[j] = row[j];
					}
					
					_manifestMap[statement] = manifest;
					
					logStatement(statement);
					statement.execute();
				}
			}
		}
		
		
		/**
		 * @private
		 */
		private function exportDataToFile(manifest:DatabaseManifest, table:DBTable, resultData:Array):void
		{
			if (table != null)
			{
				if (!resultData)
				{
					Log.info("No table data found! Exporting empty table ...", this);
					resultData = [];
				}
				
				if (table.primaryKey != null)
				{
					resultData.sortOn(table.primaryKey, Array.NUMERIC);
				}
				
				var lf:String = File.lineEnding;
				var len:uint = resultData.length;
				var text:String = "";
				var columns:Vector.<DBColumn> = table.columns;
				var i:uint;
				var j:uint;
				var row:Object;
				var col:DBColumn;
				
				if (_csvExportIncludeHeaders)
				{
					for (j = 0; j < columns.length; j++)
					{
						col = columns[j];
						text += col.name + _csvExportSeparator;
					}
					text += lf;
				}
				
				for (i = 0; i < len; i++)
				{
					row = resultData[i];
					for (j = 0; j < columns.length; j++)
					{
						col = columns[j];
						text += row[col.name] + _csvExportSeparator;
					}
					text += lf;
				}
				
				//Debug.trace(text);
				
				var fileName:String = table.name + ".csv";
				var filePath:String;
				if (manifest.fileSubFolder != null)
				{
					filePath = _userDataPath + File.separator + manifest.fileSubFolder + File.separator + fileName;
				}
				else
				{
					filePath = _userDataPath + File.separator + fileName;
				}
				var file:File = new File(filePath);
				var fs:FileStream = new FileStream();
				var success:Boolean = true;
				
				try
				{
					fs.open(file, FileMode.WRITE);
					fs.writeUTFBytes(text);
					fs.close();
				}
				catch (err:Error)
				{
					success = false;
					Log.error("Could not write database table export file.", this);
				}
				
				if (success)
				{
					Log.debug("Database table \"" + table.name + "\" exported.", this);
				}
			}
			else
			{
				Log.debug("exportDataToFile:: Nothing to export!", this);
			}
			
			_exportTablesCount--;
			
			if (_exportTablesCount <= 0)
			{
				_exportTablesCount = 0;
				_mode = null;
				exportSignal.dispatch();
			}
		}
		
		
		/**
		 * @private
		 */
		private function getNewSQLStatement():SQLStatement
		{
			var statement:SQLStatement = new SQLStatement();
			statement.sqlConnection = _connection;
			statement.addEventListener(SQLEvent.RESULT, onStatementResult);
			statement.addEventListener(SQLErrorEvent.ERROR, onStatementError);
			return statement;
		}
		
		
		/**
		 * @private
		 */
		private function logStatement(statement:SQLStatement):void
		{
			if (!_debug || !statement) return;
			Log.trace(statement.text, this);
		}
	}
}
