note
	description: "Summary description for {TEST_CSV_USE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TEST_CSV_USE

inherit

	ES_TEST

create
	make

feature

	make
		do
			add_boolean_case (agent t1)
			add_boolean_case (agent t2)
			add_boolean_case (agent t3)
			add_boolean_case (agent t4)
			add_boolean_case (agent t5)
			add_boolean_case (agent t6)
			add_boolean_case (agent t7)
			add_boolean_case (agent t8)
		end

feature -- CSV data storage

	date1, date2: STRING
	t: TUPLE [date: DATE;
	          mv: TUPLE[BOOLEAN,REAL_64];
	          cf: REAL_64;
	          af: REAL_64;
	          bm: TUPLE[BOOLEAN, REAL_64]]
	data: ARRAY [like t]
	client_name: STRING
	error: BOOLEAN
	error_message: STRING

feature -- globals

	csv_doc: CSV_DOCUMENT
	csv_iteration_cursor: CSV_DOC_ITERATION_CURSOR

feature --command pattern

	commands: LIST[PROCEDURE[ANY,TUPLE]]

	parse_csv_document
		local
			l_commands: LINKED_LIST[PROCEDURE[ANY,TUPLE]]
		do
			-- initialize commands
			create l_commands.make
			commands := l_commands
			commands.extend (agent parse_name)
			commands.extend (agent parse_evaluation_period)
			commands.extend (agent parse_data_header)
			commands.extend (agent parse_data_items)
			commands.extend (agent parse_empty_rows)

			-- execute commands
			from
				commands.start
			until
				commands.after or error
			loop
				commands.item.call ([])
				commands.forth
			end
		end

feature -- parse CSV

	t1: BOOLEAN
		do
			comment ("t1: roi-test1.csv")
			error := false
			create data.make_empty
			create csv_doc.make_from_file_name("csv-inputs/roi-test1.csv")
			csv_iteration_cursor := csv_doc.new_cursor
			create data.make_empty
			data.compare_objects

			parse_csv_document

			Result := not error and data.count = 11
			check
				Result
			end
		end

	t2 : BOOLEAN
		do
			comment ("t2: roi-test1.csv -- name not found")
			error := false
			create data.make_empty
			create csv_doc.make_from_file_name("csv-inputs/roi-test1-errors/error1.csv")
			csv_iteration_cursor := csv_doc.new_cursor
			create data.make_empty
			data.compare_objects

			parse_csv_document

			Result := error and
						error_message ~
							"Row number 1: Row containing the client name is not found."
			check
				Result
			end
		end

	t3 : BOOLEAN
		do
			comment ("t3: roi-test1.csv -- evaluation period not found")
			error := false
			create data.make_empty
			create csv_doc.make_from_file_name("csv-inputs/roi-test1-errors/error2.csv")
			csv_iteration_cursor := csv_doc.new_cursor
			create data.make_empty
			data.compare_objects

			parse_csv_document

			Result := error and
						error_message ~
							"Row number 21: The %"Evaluation Period%" row is not found."
			check
				Result
			end
		end

	t4 : BOOLEAN
		do
			comment ("t4: roi-test1.csv -- data header not found")
			error := false
			create data.make_empty
			create csv_doc.make_from_file_name("csv-inputs/roi-test1-errors/error3.csv")
			csv_iteration_cursor := csv_doc.new_cursor
			create data.make_empty
			data.compare_objects

			parse_csv_document

			Result := error and
						error_message ~
							"Row number 21: Data header (i.e. Transaction Date,Market Value,Cash Flow,Agent Fees,Benchmark) is not found."
			check
				Result
			end
		end

	t5 : BOOLEAN
		do
			comment ("t5: roi-test1.csv -- column 1 of a data row does not contain a date")
			error := false
			create data.make_empty
			create csv_doc.make_from_file_name("csv-inputs/roi-test1-errors/error4.csv")
			csv_iteration_cursor := csv_doc.new_cursor
			create data.make_empty
			data.compare_objects

			parse_csv_document

			Result := error and
						error_message ~
							"Row number 10: a data item row should have a date as its first field."
			check
				Result
			end
		end

	t6 : BOOLEAN
		do
			comment ("t6: roi-test1.csv -- columns 2 to 5 of a data row do not have expected types")
			error := false
			create data.make_empty
			create csv_doc.make_from_file_name("csv-inputs/roi-test1-errors/error5.csv")
			csv_iteration_cursor := csv_doc.new_cursor
			create data.make_empty
			data.compare_objects

			parse_csv_document

			Result := error and
						error_message ~
							"Row number 14: types of a data item row should be: [DATE, DOUBLE, FLOAT, FLOAT, _%%]."
			check
				Result
			end
		end

	t7 : BOOLEAN
		do
			comment ("t7: roi-test1.csv -- non-empty rows appear after data rows")
			error := false
			create data.make_empty
			create csv_doc.make_from_file_name("csv-inputs/roi-test1-errors/error6.csv")
			csv_iteration_cursor := csv_doc.new_cursor
			create data.make_empty
			data.compare_objects

			parse_csv_document

			Result := error and
						error_message ~
							"Row number 22: only empty rows are allowed between the last data item and end of file."
			check
				Result
			end
		end

	t8 : BOOLEAN
		do
			comment ("t8: T4.csv (larger file)")
			error := false
			create data.make_empty
			create csv_doc.make_from_file_name("csv-inputs/T4.csv")
			csv_iteration_cursor := csv_doc.new_cursor
			create data.make_empty
			data.compare_objects

			parse_csv_document

			Result := not error and
						date1 ~ "1925-06-16" and date2 ~ "1978-01-13" and
						(create {FIELD}.make (date1)).is_date and
						(create {FIELD}.make (date2)).is_date and
						client_name ~ "Trudel Stonehead" and
						data.count = 210 and
						data [209].date.out ~ "01/20/2011"
			check
				Result
			end
		end

feature -- phases

	parse_name
		local
			row : ROW
			pattern: STRING
			regexp: RX_PCRE_REGULAR_EXPRESSION
		do
			pattern := " *Name *: *(.+)"
			create regexp.make
			regexp.compile (pattern)
			check
				regexp.is_compiled
			end
			row := csv_iteration_cursor.item
			regexp.match (row [1].out)
			if regexp.has_matched then
				client_name := regexp.captured_substring (1)
				client_name.trim
			else
				error := true
				error_message := "Row number " + row.number.out
                   			+ ": Row containing the client name is not found."
			end
		end

	parse_evaluation_period
		local
			l_found: BOOLEAN
			row: ROW
			pattern: STRING
			regexp: RX_PCRE_REGULAR_EXPRESSION
		do
			from
				csv_iteration_cursor.forth
				pattern := " *Evaluation +Period *: *(\d\d\d\d-\d\d-\d\d) +to +(\d\d\d\d-\d\d-\d\d) *"
				create regexp.make
				regexp.compile (pattern)
				check
					regexp.is_compiled
				end
			until
				csv_iteration_cursor.after or l_found
			loop
				row := csv_iteration_cursor.item
				regexp.match (row.out)
				if row [1].out.has_substring ("Evaluation Period") and row.is_empty_from (2) and regexp.has_matched then
					date1 := regexp.captured_substring (1)
					date2 := regexp.captured_substring (2)
					l_found := true
				end
				csv_iteration_cursor.forth
			end
			if not l_found then
				error := true
				error_message := "Row number " + row.number.out
                   			+ ": The %"Evaluation Period%" row is not found."
			end
		end

	parse_data_header
		local
			l_found: BOOLEAN
			row : ROW
		do
			from
			until
				csv_iteration_cursor.after or l_found
			loop
				row := csv_iteration_cursor.item
				if row.out.starts_with ("Transaction Date,Market Value,Cash Flow,Agent Fees,Benchmark") and then row.is_empty_from (6) then
					l_found := true
				end
				csv_iteration_cursor.forth
			end
			if not l_found then
				error := true
				error_message := "Row number " + row.number.out
                   			+ ": Data header (i.e. Transaction Date,Market Value,Cash Flow,Agent Fees,Benchmark) is not found."
			end
		end

	parse_data_items
		local
			l_found: BOOLEAN
			mv: TUPLE [exists: BOOLEAN; value: REAL_64] -- market value
			cf: REAL_64 -- cash flow
			af: REAL_64 -- agent fees
			bm: TUPLE [exists: BOOLEAN; value: REAL_64] -- benchmark
			l_date: DATE
			i: INTEGER
			row : ROW
		do
			from
				i := 1
			until
				csv_iteration_cursor.after or l_found or error
			loop
				row := csv_iteration_cursor.item
				if row [1].is_date then
					if row [1].is_date and (row [2].is_double or row [2] ~ "") -- mv
						and (row [3].is_float or row [3].out ~ "") -- cf
						and (row [4].is_float or row [4].out ~ "") -- af
						and (row [5].is_percentage or row [5].out ~ "") -- bm
						and row.is_empty_from (6)
					then
						l_date := row [1].as_date
						if row [2].is_float then
							mv := [true, row [2].as_float]
						else
							mv := [false, 0.0]
						end
						if row [3].is_float then
							cf := row [3].as_float
						else
							cf := 0.0
						end
						if row [4].is_float then
							af := row [4].as_float
						else
							af := 0.0
						end
						if row [5].is_percentage then
							bm := [true, row [5].as_percentage] -- what about percentage
						else
							bm := [false, 0.0]
						end
						t := [l_date, mv, cf, af, bm]
						data.force (t, i)
						i := i + 1
						error := false
					else
						error := true
						error_message := "Row number " + row.number.out
                   			+ ": types of a data item row should be: [DATE, DOUBLE, FLOAT, FLOAT, _%%]."
					end
				elseif row.is_empty then
					l_found := true
				else
					error := true
					error_message := "Row number " + row.number.out
                   			+ ": a data item row should have a date as its first field."
				end
				csv_iteration_cursor.forth
			end
		end

		parse_empty_rows
			local
				row : ROW
			do
				from
           		until
               		csv_iteration_cursor.after or error
           		loop
               		row := csv_iteration_cursor.item
               		if not row.is_empty then
                   		error := true
                   		error_message := "Row number " + row.number.out
                   			+ ": only empty rows are allowed between the last data item and end of file."
               		end
               		csv_iteration_cursor.forth
           		end
			end



end
