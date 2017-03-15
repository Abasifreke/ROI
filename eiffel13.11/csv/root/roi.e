note
	description: "test-array application root class"
	date: "$DATE"
	revision: "$Revision$"

class 
	ROI

inherit
	ES_SUITE

	ARGUMENTS

create 
	make

feature 

	wholetwr: REAL_64

	parttwr: REAL_64

	wprecise: REAL_64

	eprecise: REAL_64

	make
		local
			p: PARSER
			t: TWR_CALC
			a: ARRAY [TUPLE [DATE, REAL_64, REAL_64, REAL_64, REAL_64]]
			pre: PRECISE
			earray, warray: ARRAYED_LIST [TUPLE [REAL_64, REAL_64]]
			error_message: STRING_8
			data_header: TUPLE [errcode: INTEGER_32; name: STRING_8; eval_start_date: DATE; eval_end_date: DATE; whole_start_date: DATE; whole_end_date: DATE]
		do
			if argument_count = 0 then
				create p.make_from_file_name ("csv-inputs/roi-test1.csv")
			else
				create p.make_from_file_name (argument (1))
			end
			create t.make
			create pre.make
			a := p.get_rows
			data_header := p.get_header_data
			if data_header.errcode <= 0 then
				wholetwr := t.twr (data_header.whole_start_date, data_header.whole_end_date, a)
				parttwr := t.twr (data_header.eval_start_date, data_header.eval_end_date, a)
				warray := pre.new_array (a)
				pre.wholerate (warray)
				wprecise := pre.whole
				if data_header.errcode = 0 then
					earray := pre.new_subarray (data_header.eval_start_date, data_header.eval_end_date, a)
					pre.partrate (earray)
					eprecise := pre.part
				end
			else
				if data_header.errcode > 0 then
					error_message := p.get_error_message
					Io.put_string (error_message)
					Io.put_new_line
				end
			end
			printer (p.get_header_data)
		end
	
feature 

	printer (data_header: TUPLE [errcode: INTEGER_32; name: STRING_8; eval_start_date: DATE; eval_end_date: DATE; whole_start_date: DATE; whole_end_date: DATE])
		local
			p: PARSER
			error_message: STRING_8
		do
			if data_header.errcode <= 0 then
				if argument_count = 0 then
					Io.put_string ("csv-inputs/roi-test1.csv")
					Io.put_new_line
				else
					Io.put_string (argument (1))
					Io.put_new_line
				end
				Io.put_string ("Name: ")
				Io.put_string (data_header.name)
				Io.put_new_line
				Io.put_string ("Whole period: ")
				Io.put_string (data_header.whole_start_date.formatted_out ("yyyy-mm-dd"))
				Io.put_string (" to ")
				Io.put_string (data_header.whole_end_date.formatted_out ("yyyy-mm-dd"))
				Io.put_new_line
				if data_header.errcode = 0 then
					Io.put_string ("Part period:  ")
					Io.put_string (data_header.eval_start_date.formatted_out ("yyyy-mm-dd"))
					Io.put_string (" to ")
					Io.put_string (data_header.eval_end_date.formatted_out ("yyyy-mm-dd"))
					Io.put_new_line
					Io.put_string ("%T--results as a percentage%N")
					Io.put_string ("ROI (TWR) : %N")
					Io.put_string ("%TWhole Period: ")
					Io.put_string (wholetwr.out)
					Io.put_new_line
					Io.put_string ("%TPart Period:   ")
					Io.put_string (parttwr.out)
					Io.put_new_line
					Io.put_string ("ROI (precise) : %N")
					Io.put_string ("%TWhole Period: ")
					Io.put_string (wprecise.out)
					Io.put_new_line
					Io.put_string ("%TPart Period:   ")
					Io.put_string (eprecise.out)
					Io.put_new_line
				else
					if data_header.errcode < 0 then
						error_message := p.get_error_message
						Io.put_string (error_message)
					end
				end
			end
		end
	
end -- class ROI

