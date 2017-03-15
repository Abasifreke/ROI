note
	description: "Summary description for {TEST_CSV_PARSER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TEST_CSV_PARSER
inherit
	ES_TEST
create
	make

feature -- Constructor
	make
		do
			add_boolean_case (agent t1)
			add_boolean_case (agent t2)
			add_boolean_case (agent t3)
			add_boolean_case (agent t4)
		end

feature -- Test cases
	t1 : BOOLEAN
		local
			input_file : KL_TEXT_INPUT_FILE
			csv_doc : CSV_DOCUMENT
			csv_doc_it : CSV_DOC_ITERATION_CURSOR
			row : ROW
		do
			comment ("t1: csv-inputs\roi-test1.csv")
			create input_file.make ("csv-inputs/roi-test1.csv")
			input_file.open_read
			create csv_doc.make (input_file)
			csv_doc_it := csv_doc.new_cursor

			-- test on line 1: Name: Trudel Stonehead,,,,,
			row := csv_doc_it.item
			Result := row.number_of_specified_fields = 6 and
						row.number = 1 and
						row [1] ~ create {FIELD}.make ("Name: Trudel Stonehead") and
						not row.is_empty_from (1) and
						(across 2 |..| 6 as i all row.is_empty_from (i.item) end)
			check Result end

			-- test on line 2: Description: BMO RRSP, bonds and equities,,,,,
			csv_doc_it.forth
			row := csv_doc_it.item
			Result := row.number_of_specified_fields = 7 and
						row.number = 2 and
						row [1] ~ create {FIELD}.make ("Description: BMO RRSP") and
						row [2] ~ create {FIELD}.make (" bonds and equities") and
						(across 1 |..| 2 as i all not row.is_empty_from (i.item) end) and
						(across 3 |..| 7 as i all row.is_empty_from (i.item) end)
			check Result end

			-- test on line 3: Account#: 478902,,,,,
			csv_doc_it.forth
			row := csv_doc_it.item
			Result := row.number_of_specified_fields = 6 and
						row.number = 3 and
						row [1] ~ create {FIELD}.make ("Account#: 478902") and
						(across 1 |..| 1 as i all not row.is_empty_from (i.item) end) and
						(across 2 |..| 6 as i all row.is_empty_from (i.item) end)
			check Result end

			-- test on line 4: Email: trudel@gmail.com,,,,,
			csv_doc_it.forth
			row := csv_doc_it.item
			Result := row.number_of_specified_fields = 6 and
						row.number = 4 and
						row [10] ~ create {FIELD}.make ("") and
						row [1] ~ create {FIELD}.make ("Email: trudel@gmail.com") and
						(across 1 |..| 1 as i all not row.is_empty_from (i.item) end) and
						(across 2 |..| 6 as i all row.is_empty_from (i.item) end)
			check Result end

			-- test on line 5: Address: 4700 Keele Street, Toronto, M3J 1P3,,,,,
			csv_doc_it.forth
			row := csv_doc_it.item
			Result := row.number_of_specified_fields = 8 and
						row.number = 5 and
						row [1] ~ create {FIELD}.make ("Address: 4700 Keele Street") and
						row [2] ~ create {FIELD}.make (" Toronto") and
						row [3] ~ create {FIELD}.make (" M3J 1P3") and
						(across 1 |..| 3 as i all not row.is_empty_from (i.item) end) and
						(across 4 |..| 8 as i all row.is_empty_from (i.item) end)
			check Result end

			-- test on line 6: Phone: 416-736-2100 x70000,,,,,
			csv_doc_it.forth
			row := csv_doc_it.item
			Result := row.number_of_specified_fields = 6 and
						row.number = 6 and
						row [1] ~ create {FIELD}.make ("Phone: 416-736-2100 x70000") and
						(across 1 |..| 1 as i all not row.is_empty_from (i.item) end) and
						(across 2 |..| 6 as i all row.is_empty_from (i.item) end)
			check Result end

			-- test on line 7: Evaluation Period: 2008-01-01 to 2009-04-01,,,,,
			csv_doc_it.forth
			row := csv_doc_it.item
			Result := row.number_of_specified_fields = 6 and
						row.number = 7 and
						row [1] ~ create {FIELD}.make ("Evaluation Period: 2008-01-01 to 2009-04-01") and
						not row [1].is_date and
						(across 1 |..| 1 as i all not row.is_empty_from (i.item) end) and
						(across 2 |..| 6 as i all row.is_empty_from (i.item) end)
			check Result end

			-- test on line 8: ,,,,,
			csv_doc_it.forth
			row := csv_doc_it.item
			Result := row.number_of_specified_fields = 6 and
						row.number = 8 and
						(across 1 |..| 6 as i all row [i.item].is_empty end) and
						(across 1 |..| 6 as i all row.is_empty_from (i.item) end)
			check Result end

			-- test on line 9: Transaction Date,Market Value,Cash Flow,Agent Fees,Benchmark,
			csv_doc_it.forth
			row := csv_doc_it.item
			Result := row.number_of_specified_fields = 6 and
						row.number = 9 and
						row [1] ~ create {FIELD}.make ("Transaction Date") and
						row [2] ~ create {FIELD}.make ("Market Value") and
						row [3] ~ create {FIELD}.make ("Cash Flow") and
						row [4] ~ create {FIELD}.make ("Agent Fees") and
						row [5] ~ create {FIELD}.make ("Benchmark") and
						not (across 1 |..| 5 as i some row.is_empty_from (i.item) end) and
						row.is_empty_from (6)
			check Result end

			-- test on line 10: 2007-01-01,100000,,,,
			csv_doc_it.forth
			row := csv_doc_it.item
			Result := row.number_of_specified_fields = 6 and
						row.number = 10 and
						row [1] ~ create {FIELD}.make ("2007-01-01") and
						row[1].is_date and
						row [2] ~ create {FIELD}.make ("100000") and
						(across 1 |..| 2 as i all not row.is_empty_from (i.item) end) and
						(across 3 |..| 6 as i all row.is_empty_from (i.item) end)
			check Result end

			csv_doc_it.forth
			csv_doc_it.forth
			csv_doc_it.forth

			-- test on line 14: 2008-01-01,145000,,,15.00%,
			csv_doc_it.forth
			row := csv_doc_it.item
			Result := row.number_of_specified_fields = 6 and
						row.number = 14 and
						row [1] ~ create {FIELD}.make ("2008-01-01") and
						row [1].is_date  and
						row [2] ~ create {FIELD}.make ("145000") and
						row [2].is_int and
						row [2].as_int = 145000 and
						row [2].is_double and
						row [2].as_double = 145000.00 and
						row [5] ~ create {FIELD}.make ("15.00%%") and
						not row[5].is_double and
						row [5].is_percentage and
						(across 1 |..| 5 as i all not row.is_empty_from (i.item) end) and
						(across 6 |..| 6 as i all row.is_empty_from (i.item) end)
			check Result end

			csv_doc_it.forth
			csv_doc_it.forth
			csv_doc_it.forth
			csv_doc_it.forth
			csv_doc_it.forth
			csv_doc_it.forth

			-- test on line 21: ,,,
			csv_doc_it.forth
			row := csv_doc_it.item
			Result := row.number_of_specified_fields = 4 and
						row.number = 21 and
						(across 1 |..| 4 as i all row.is_empty_from (i.item) end)
			check Result end

			-- test on line 22: ,
			csv_doc_it.forth
			row := csv_doc_it.item
			Result := row.number_of_specified_fields = 2 and
						row.number = 22 and
						(across 1 |..| 2 as i all row.is_empty_from (i.item) end)
			check Result end
		end

	t2 : BOOLEAN
		local
			input_file : KL_TEXT_INPUT_FILE
			csv_doc : CSV_DOCUMENT
			csv_doc_it : CSV_DOC_ITERATION_CURSOR
			row : ROW
			num_rows : INTEGER
		do
			comment ("t2: csv-inputs\T4.csv (a 219-line file) -- Part I")
			create input_file.make ("csv-inputs/T4.csv")
			input_file.open_read
			create csv_doc.make (input_file)

			from
				csv_doc_it := csv_doc.new_cursor
				num_rows := 0
				Result := true
			until
				csv_doc_it.after
			loop
				row := csv_doc_it.item
				num_rows := num_rows + 1

				-- ensuring that each source line is well-formatted
				Result := Result and row.is_well_formatted
				check Result end

				if num_rows = 1 then
					-- test on line 1: Name: Trudel Stonehead,,,,
					Result := row.number_of_specified_fields = 5 and
								row [1] ~ create {FIELD}.make ("Name: Trudel Stonehead") and
								not row.is_empty_from (1) and
								(across 2 |..| 5 as i all row.is_empty_from (i.item) end)
					check Result end
				elseif num_rows = 2 then
					-- test on line 2: Description: BMO RRSP, bonds and equities,,,
					Result := row.number_of_specified_fields = 5 and
								row [1] ~ create {FIELD}.make ("Description: BMO RRSP") and
								row [2] ~ create {FIELD}.make (" bonds and equities") and
								(across 1 |..| 2 as i all not row.is_empty_from (i.item) end) and
								(across 3 |..| 5 as i all row.is_empty_from (i.item) end)
					check Result end
				elseif num_rows = 3 then
					-- test on line 3: Account#: 478902,,,,
					Result := row.number_of_specified_fields = 5 and
								row [1] ~ create {FIELD}.make ("Account#: 478902") and
								(across 1 |..| 1 as i all not row.is_empty_from (i.item) end) and
								(across 2 |..| 5 as i all row.is_empty_from (i.item) end)
					check Result end
				elseif num_rows = 4 then
					-- test on line 4: Email: trudel@gmail.com,,,,
					Result := row.number_of_specified_fields = 5 and
								row [1] ~ create {FIELD}.make ("Email: trudel@gmail.com") and
								(across 1 |..| 1 as i all not row.is_empty_from (i.item) end) and
								(across 2 |..| 5 as i all row.is_empty_from (i.item) end)
					check Result end
				elseif num_rows = 5 then
					-- test on line 5: Address: 4700 Keele Street, Toronto, M3J 1P3,,
					Result := row.number_of_specified_fields = 5 and
								row [1] ~ create {FIELD}.make ("Address: 4700 Keele Street") and
								row [2] ~ create {FIELD}.make (" Toronto") and
								row [3] ~ create {FIELD}.make (" M3J 1P3") and
								(across 1 |..| 3 as i all not row.is_empty_from (i.item) end) and
								(across 4 |..| 5 as i all row.is_empty_from (i.item) end)
					check Result end
				elseif num_rows = 6 then
					-- test on line 6: Phone: 416-736-2100 x70000,,,,
					Result := row.number_of_specified_fields = 5 and
								row [1] ~ create {FIELD}.make ("Phone: 416-736-2100 x70000") and
								(across 1 |..| 1 as i all not row.is_empty_from (i.item) end) and
								(across 2 |..| 5 as i all row.is_empty_from (i.item) end)
					check Result end
				elseif num_rows = 7 then
					-- test on line 7: Evaluation Period: 2008-01-01 to 2009-04-01,,,,
					Result := row.number_of_specified_fields = 5 and
								row [1] ~ create {FIELD}.make ("Evaluation Period: 1925-06-16 to 1978-01-13") and
								not row [1].is_date and
								(across 1 |..| 1 as i all not row.is_empty_from (i.item) end) and
								(across 2 |..| 5 as i all row.is_empty_from (i.item) end)
					check Result end
				elseif num_rows = 8 then
					-- test on line 8: ,,,,
					Result := row.number_of_specified_fields = 5 and
								row.is_empty and
								(across 1 |..| 5 as i all row [i.item].is_empty end) and
								(across 1 |..| 5 as i all row.is_empty_from (i.item) end)
					check Result end
				elseif num_rows = 9 then
					-- test on line 9: Transaction Date,Market Value,Cash Flow,Agent Fees,Benchmark
					Result := row.number_of_specified_fields = 5 and
								row [1] ~ create {FIELD}.make ("Transaction Date") and
								row [2] ~ create {FIELD}.make ("Market Value") and
								row [3] ~ create {FIELD}.make ("Cash Flow") and
								row [4] ~ create {FIELD}.make ("Agent Fees") and
								row [5] ~ create {FIELD}.make ("Benchmark") and
								not (across 1 |..| 5 as i some row.is_empty_from (i.item) end)
					check Result end
				elseif num_rows = 10 then
					-- test on line 10: 1900-01-01,4684,40265,,125%,,,
					Result := row.number_of_specified_fields = 8 and
								row[1] ~ create {FIELD}.make ("1900-01-01") and
								row[1].is_date and
								row[2] ~ create {FIELD}.make ("4684") and
								row[2].is_int and
								row[2].as_int = 4684 and
								row[2].is_double and
								row[2].as_double = 4684.00 and
								row[3] ~ create {FIELD}.make ("40265") and
								row[3].is_int and
								row[3].as_int = 40265 and
								row[3].is_double and
								row[3].as_double = 40265.00 and
								row[4].is_empty and
								row[5] ~ create {FIELD}.make ("125%%") and
								row[5].is_percentage and
								not (across 1 |..| 5 as i some row.is_empty_from (i.item) end) and
								across 6 |..| 8 as i all row.is_empty_from (i.item) end
				elseif num_rows = 164 then
					-- test on line 164: 1980-01-01,875949,-459885,,-54%,,,
					Result := row.number_of_specified_fields = 8 and
								row[1] ~ create {FIELD}.make ("1980-01-01") and
								row[1].is_date and
								row[2] ~ create {FIELD}.make ("875949") and
								row[2].is_int and
								row[2].as_int = 875949 and
								row[2].is_double and
								row[2].as_double = 875949.00 and
								row[3] ~ create {FIELD}.make ("-459885") and
								row[3].is_int and
								row[3].as_int = -459885 and
								row[3].is_double and
								row[3].as_double = -459885.00 and
								row[4].is_empty and
								row[5] ~ create {FIELD}.make ("-54%%") and
								row[5].is_percentage and
								not (across 1 |..| 5 as i some row.is_empty_from (i.item) end) and
								across 6 |..| 8 as i all row.is_empty_from (i.item) end
				elseif num_rows = 219 then
					-- test on line 219: 2012-07-14,776221,-220411,,,,,
					Result := row.number_of_specified_fields = 8 and
								row[1] ~ create {FIELD}.make ("2012-07-14") and
								row[1].is_date and
								row[2] ~ create {FIELD}.make ("776221") and
								row[2].is_int and
								row[2].as_int = 776221 and
								row[2].is_double and
								row[2].as_double = 776221.00 and
								row[3] ~ create {FIELD}.make ("-220411") and
								row[3].is_int and
								row[3].as_int = -220411 and
								row[3].is_double and
								row[3].as_double = -220411.00 and
								not (across 1 |..| 3 as i some row.is_empty_from (i.item) end) and
								across 4 |..| 8 as i all row.is_empty_from (i.item) end
				end

				csv_doc_it.forth
			end

			-- checking that exactly 219 lines are read from the source csv file
			Result := num_rows = 219
			check Result end
		end

	t3 : BOOLEAN
		local
			input_file : KL_TEXT_INPUT_FILE
			csv_doc : CSV_DOCUMENT
			csv_doc_it : CSV_DOC_ITERATION_CURSOR
			row : ROW
			pattern : STRING
			regexp : RX_PCRE_REGULAR_EXPRESSION
			date1, date2 : STRING
			i : INTEGER
		do
			comment ("t3: csv-inputs\T4.csv -- Part II : searching and extracting dates")
			create input_file.make ("csv-inputs/T4.csv")
			input_file.open_read
			create csv_doc.make (input_file)

			from
				csv_doc_it := csv_doc.new_cursor
				Result := true
				i := 1
			until
				csv_doc_it.after
			loop
				row := csv_doc_it.item

				if row.contains ("Evaluation Period") then
					pattern := " *Evaluation +Period *: *(\d\d\d\d-\d\d-\d\d) +to +(\d\d\d\d-\d\d-\d\d) *"
					create regexp.make
					regexp.compile (pattern)
					check regexp.is_compiled end
					regexp.match (row.out)
					check regexp.has_matched end
					date1 := regexp.captured_substring (1)
					date2 := regexp.captured_substring (2)
					Result := date1 ~ "1925-06-16" and
								date2 ~ "1978-01-13"
					check Result end
				end

				csv_doc_it.forth
				i := i + 1
			end
		end

	t4 : BOOLEAN
		local
			input_file : KL_TEXT_INPUT_FILE
			csv_doc : CSV_DOCUMENT
			csv_doc_it : CSV_DOC_ITERATION_CURSOR
			row : ROW
			i : INTEGER
			cash_flow_header_passed : BOOLEAN
		do
			comment ("t4: csv-inputs\T4.csv -- Part II : searching and extracting a single date")
			create input_file.make ("csv-inputs/T4.csv")
			input_file.open_read
			create csv_doc.make (input_file)

			from
				csv_doc_it := csv_doc.new_cursor
				Result := true
				i := 1
			until
				csv_doc_it.after
			loop
				row := csv_doc_it.item

				if row.contains ("Cash Flow") then
					cash_flow_header_passed := true
				elseif cash_flow_header_passed then
					-- just as examples: retrieve the date column for the first and the last lines
					if i = 10 then
						Result := row[1].is_date and
									row[1] ~ create {FIELD}.make ("1900-01-01")
						check Result end
					elseif i = 219 then
						Result := row[1].is_date and
									row[1] ~ create {FIELD}.make ("2012-07-14")
						check Result end
					end
				end

				csv_doc_it.forth
				i := i + 1
			end
		end

end
