
	note
		description : "twr application root class"
		date        : "$Date$"
		revision    : "$Revision$"

	class
	 	APPLICATION

	inherit
	 ANY

	create
		make

--	feature {NONE} -- Initialization

--			make
--					-- Run application.
--				do
--					--| Add your code here
--					print ("Hello Eiffel World!%N")
--				end
feature{NONE} -- Implementation
	date: DATE






	tr:SEQ[TUPLE[date:DATE; mv:VALUE; cf:VALUE; af:VALUE]]


	count:INTEGER
	do
	Result:=tr.count
	end

	dates:SET[DATE]



	start,end:DATE


	duration:VALUE
	do
	Result:= days(end - start) / 365.2422
	end



	di (d:DATE): INTEGER
	local
	i:INTEGER
	do
	i:=1
	loop
	if d = tr[i]
	Result:= i
	end
	i:=i+1
	end

	ensure Result ∈ tr.domain ^ tr[Result].date = d

	end

	twr (a_start, a_end: DATE): VALUE
	-- TWR for the period start .. end
	local
		wealth:VALUE
		i:
	require
	a_start, a_end ∈ dates
	a_end > a_start
	do
	loop

	end

	ensure
	Result (Π i: INTEGER | di (a_start) < i <= di (a_end) ⋅ wealth (i)) – 1
	where wealth(i) tr[i].mv ÷ (tr [ i - 1].mv + tr [i - 1].cf + tr [i - 1].af)
	end

	compounded_TWR: VALUE
	ensure Result = twr(start, end )


	annual_compounded_TWR: VALUE
	ensure
	(duration >= 1) => Result = ((1 + compounded _ TWR)^(1 ÷ duration)) - 1
	(duration < 1) => Result = compounded _ TWR

	Note: Multiply by 100 to represent as a percentage

	end

	feature{NONE} -- Y: Implementation
tr:SEQ[TUPLE]

--date:DATE
--mv:VALUE
--cf:VALUE
--duration:VALUE
--wealth:VALUE
--twr:VALUE


--		end


end
