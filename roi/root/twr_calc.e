note
	description: "Summary description for {TWR_CALC}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TWR_CALC

create
		make

	feature {NONE} -- Initialization

		make
		do
		end

feature

	start, dend:DATE

	duration:REAL_64
	do
		Result:= (dend.days - start.days) / 365.2422
	end

	twr (start_date: DATE; end_date: DATE; data: ARRAY[TUPLE[trdate: DATE; mv: REAL_64; cf: REAL_64; af: REAL_64; f4: REAL_64]]): REAL_64

		require
			voidcheck: start_date /= void; end_date/= void; data /= void

		local
	--		denominator: REAL_64
			i, upper_index, lower_index: INTEGER
			wealth: REAL_64
			upper_found, lower_found: BOOLEAN

		do
			upper_found := false
			lower_found := false

			-- find upper bound:
			from
				i := 1
			until
				i = data.count or upper_found
			loop
				if (data[i].trdate >= start_date) then
					upper_found := true
					upper_index := i
				end
				i := i + 1
			end
			-- find lower bound:
			from
				i := data.count
			until
				i = 1 or lower_found
			loop
				if (data[i].trdate <= end_date) then
					lower_found := true
					lower_index := i
				end
				i := i - 1
			end
			-- calculate twr:
			wealth := 1.0
			from
				i := (upper_index+1)
			until
				i = lower_index
			loop
				wealth := wealth * (data[i].mv / (data[i-1].mv + data[i-1].cf - data[i-1].af))
				i := i + 1
			end
			Result := (wealth -1)*100
		end

	compounded_TWR(data: ARRAY[TUPLE[trdate: DATE; mv: REAL_64; cf: REAL_64; af: REAL_64; f4: REAL_64]]): REAL_64
	do
		Result := twr(data[1].trdate, data[data.capacity].trdate, data)
	end

	annual_compounded_TWR (data: ARRAY[TUPLE[trdate: DATE; mv: REAL_64; cf: REAL_64; af: REAL_64; f4: REAL_64]]): REAL_64
	--Note: Multiply by 100 to represent as a percentage
	local
		one:REAL_64
	do
		one:=1
		 if duration>=1 then

       		Result := (one.plus( compounded_TWR(data) ).power(   (  (one).quotient(duration) )   ).minus(one))
		else
       		Result := compounded_TWR(data)
		end

	end

end

