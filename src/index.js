// Using a fixed Oracle time zone helps avoid machine and deployment differences
process.env.ORA_SDTZ = 'UTC';

const oracledb = require('oracledb');
const dbConfig = require('./dbconfig.js');

// On Windows and macOS, you can specify the directory containing the Oracle
// Client Libraries at runtime, or before Node.js starts.  On other platforms
// the system library search path must always be set before Node.js is started.
// See the node-oracledb installation documentation.
// If the search path is not correct, you will get a DPI-1047 error.
//
// oracledb.initOracleClient({ libDir: 'C:\\instantclient_19_8' });                            // Windows
// oracledb.initOracleClient({ libDir: '/Users/your_username/Downloads/instantclient_19_8' }); // macOS

async function run() {
	let connection;

	try {
		let sql, binds, options, result;

		connection = await oracledb.getConnection(dbConfig);

		//
		// Create a table
		//
		const stmts = [
			//`CREATE TABLE no_example (id NUMBER, data VARCHAR2(20))`,
		
			`DECLARE
				ncount  NUMBER;
				v_sql   LONG;
			BEGIN
				SELECT
					COUNT(*)
				INTO ncount
				FROM
					user_tables
				WHERE
					table_name = 'NO_EXAMPLE';
			
				IF ( ncount <= 0 ) THEN
					v_sql := 'CREATE TABLE no_example(id NUMBER not null PRIMARY KEY, data VARCHAR2(20))';
					EXECUTE IMMEDIATE v_sql;
				END IF;
			
			END;`,

			`DELETE FROM no_example`
		];

		for (const s of stmts) {
			try {
				await connection.execute(s);
			} catch (e) {
				if (e.errorNum != 942)
					console.error(e);
			}
		}

		//
		// Insert three rows
		//
		sql = `INSERT INTO no_example VALUES (:1, :2)`;
		binds = [
			[101, "Alpha"],
			[102, "Beta"],
			[103, "Gamma"]
		];
		// For a complete list of options see the documentation.
		options = {
			autoCommit: true,
			// batchErrors: true,  // continue processing even if there are data errors
			bindDefs: [
				{ type: oracledb.NUMBER },
				{ type: oracledb.STRING, maxSize: 20 }
			]
		};

		result = await connection.executeMany(sql, binds, options);

		console.log("Number of rows inserted:", result.rowsAffected);

		//
		// Query the data
		//
		sql = `SELECT * FROM no_example`;
		binds = {};
		// For a complete list of options see the documentation.
		options = {
			outFormat: oracledb.OUT_FORMAT_OBJECT,   // query result format
			// extendedMetaData: true,               // get extra metadata
			// prefetchRows:     100,                // internal buffer allocation size for tuning
			// fetchArraySize:   100                 // internal buffer allocation size for tuning
		};

		result = await connection.execute(sql, binds, options);

		console.log("Metadata: ");
		console.dir(result.metaData, { depth: null });
		console.log("Query results: ");
		console.dir(result.rows, { depth: null });

		//
		// Show the date.  The value of ORA_SDTZ affects the output
		//
		sql = `SELECT TO_CHAR(CURRENT_DATE, 'DD-Mon-YYYY HH24:MI') AS CD FROM DUAL`;
		result = await connection.execute(sql, binds, options);
		console.log("Current date query results: ");
		console.log(result.rows[0]['CD']);

	} catch (err) {
		console.error(err);
	} finally {
		if (connection) {
			try {
				await connection.close();
			} catch (err) {
				console.error(err);
			}
		}
	}
}

run();