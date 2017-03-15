note
	description: "Abstracts the CSV traversal to return well-formatted data in convenient-to-use data structures."
	author: "Dmytro Shebanov"
	date: "Jul 28, 2014"
	revision: "1.1"

class
	PARSER

create
	make_from_file_name

feature -- creation & initial parsing step

	make_from_file_name(path: STRING)
		local
			input_file: KL_TEXT_INPUT_FILE
		do
			-- initialize data fields:
			rowcount := 0
			create data.make_empty
			create header_data.default_create
			data_row_found := false
			error_message := ""
			-- check if file exists:
			create input_file.make(path)
			if (not input_file.exists) then
				header_data.errcode := 5 -- bad file
				error_message := "The file with path: " + path + " Does not exist."
			else
				if (not input_file.is_readable) then
					header_data.errcode := 5 -- bad file
					error_message := "The file with the path: " + path + " Read access permissions denied."
				else
					create csv_doc.make_from_file_name(path)
					csv_iteration_cursor := csv_doc.new_cursor
					-- begin attempting to parse spreadsheet:
					parse_main
				end
			end
		end

feature -- accessors

	get_header_data: TUPLE[INTEGER, STRING, DATE, DATE, DATE, DATE]
	do
		Result := header_data
	end

	get_rows: ARRAY[like t]
	do
		Result := data
	end

	get_error_message: STRING
	do
		Result := error_message
	end

feature {NONE} -- CSV data storage

	--date1, date2: STRING
	t: TUPLE [date: DATE;
	        mv: REAL_64;
	        cf: REAL_64;
	        af: REAL_64;
	        bm: REAL_64]
	header_data: TUPLE [errcode: INTEGER;
			name: STRING;
			eval_start_date: DATE;
			eval_end_date: DATE;
			whole_start_date: DATE;
			whole_end_date: DATE]
	data: ARRAY [like t]
	--client_name: STRING
	error: BOOLEAN
	error_message: STRING
	rowcount: INTEGER

feature {NONE} -- globals

	csv_doc: CSV_DOCUMENT
	csv_iteration_cursor: CSV_DOC_ITERATION_CURSOR
	data_row_found: BOOLEAN

feature {NONE} -- parsing implementation

	parse_main
		do
			parse_name
			if (not error) then
				parse_evaluation_period
				if (not error) then
					if (header_data.eval_end_date < header_data.eval_start_date) then
						header_data.errcode := -2 -- warning: start of eval date is later than end (no time travel!!!)
						error_message := "Evaluation period begins after it already ended."
					end
				else
					header_data.errcode := -1 -- warning: omitted evaluation period is fine, but we should signal this event
				end
				--else --
					parse_data_header
					if (not error) then
						parse_data_items
						if (not error) then
							if (header_data.eval_start_date < header_data.whole_start_date) or (header_data.eval_end_date > header_data.whole_end_date) then
								header_data.errcode := -3 -- warning: eval period lies outside of whole time period
								error_message := "Evaluation period lies outside of first and last transaction dates."
							else
								parse_empty_rows
								if (not error) then
									header_data.errcode := 0 -- default success
								else
									header_data.errcode := 4 -- extraneous data rows detected
								end
							end
						else
							header_data.errcode := 3 -- malformed data
						end
					else
						header_data.errcode := 2 -- no header row is very bad.
					end
				--end --
			else
				header_data.errcode := 1 -- no name field
			end
		end

	parse_data_items
		local
			l_found: BOOLEAN
			l_date: DATE -- transaction date
			mv: REAL_64 -- market value
			cf: REAL_64 -- cash flow
			af: REAL_64 -- agent fees
			bm: REAL_64 -- benchmark

			i: INTEGER
			l_date_prev: DATE -- previous iteration's date
			row : ROW
			mv_prev, cf_prev: REAL_64 -- previous iteration's market value, cash flow
		do
			create l_date_prev.make_day_month_year (1,1,1900)
			mv_prev := -1.0
			cf_prev := -1.0
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
						if (i = 1) then -- record the overall starting date
							header_data.whole_start_date := l_date.twin
						end
						if (not (l_date > l_date_prev)) then
							error := true
							error_message := "Row number " + row.number.out
								+ ": transactions should be in descending order, by date."
						else
							if row [2].is_float then
								mv := row [2].as_float
							else
								mv := 0.0
								--mv := void --doesn't work
							end
							if (mv < 0.0) then
								error := true
								error_message := "Row number " + row.number.out
									+ ": market value cannot be negative."
							else
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
									bm := row [5].as_percentage -- what about percentage
								else
									bm := 0.0
									--bm := void
								end
								if (mv + cf < 0) then
									error := true
									error_message := "Row number " + row.number.out
										+ ": cannot withdraw more than the market value"
								else
									if ((mv_prev = 0 and cf_prev = 0) and (not(mv = 0))) then
										error := true
										error_message := "Row number " + row.number.out
											+ ": Account cannot grow from zero market value and cash flow."
									else
										t := [l_date, mv, cf, af, bm]
										data.force (t, i)
										i := i + 1
										error := false
										l_date_prev := l_date.twin
										mv_prev := mv
										cf_prev := cf
									end
								end
							end
						end
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
			if (not error) then
				rowcount := i - 1
				header_data.whole_end_date := l_date.twin -- record the overall end date
				if (rowcount < 2) then
					error := true
					error_message := "At least two data rows required for processing."
				end
			end
		end

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
				header_data.name := regexp.captured_substring (1)
				(header_data.name).trim
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
			date1, date2: DATE
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
				csv_iteration_cursor.after or l_found or data_row_found
			loop
				row := csv_iteration_cursor.item
				regexp.match (row.out)
				if row [1].out.has_substring ("Evaluation Period") and row.is_empty_from (2) and regexp.has_matched then
					create date1.make_day_month_year (1,1,1900)
					create date2.make_day_month_year (1,1,1900)
					date1.make_from_string (regexp.captured_substring (1), "yyyy-mm-dd")
					date2.make_from_string (regexp.captured_substring (2), "yyyy-mm-dd")
					header_data.eval_start_date := date1
					header_data.eval_end_date := date2
					l_found := true
				end
				if row.out.starts_with ("Transaction Date,Market Value,Cash Flow,Agent Fees,Benchmark") and then row.is_empty_from (6) then
					data_row_found := true
				end
				csv_iteration_cursor.forth
			end
			if not l_found then
				error := true
				error_message := "The %"Evaluation Period%" row is not found."
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
				if data_row_found or (row.out.starts_with ("Transaction Date,Market Value,Cash Flow,Agent Fees,Benchmark") and then row.is_empty_from (6)) then
					l_found := true
				end
				csv_iteration_cursor.forth
			end
			if not l_found then
				error := true
				error_message := "Data header (i.e. Transaction Date,Market Value,Cash Flow,Agent Fees,Benchmark) is not found."
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
