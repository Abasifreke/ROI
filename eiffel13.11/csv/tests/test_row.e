note
	description: "Summary description for {TEST_ROW}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TEST_ROW
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
		end

feature -- Test cases
	t1 : BOOLEAN
		local
			r : ROW
		do
			comment ("t1: valid unquoted fields")

			--a,b,c,d,e-> (a) (b) (c) (d) (e)
			create r.make ("a,b,c,d,e", 1)
			Result := r.is_well_formatted and
						r[1] ~ create {FIELD}.make ("a")  and
						r[2] ~ create {FIELD}.make ("b") and
						r[3] ~ create {FIELD}.make ("c") and
						r[4] ~ create {FIELD}.make ("d") and
						r[5] ~ create {FIELD}.make ("e")
			check Result end

			--a, b, c, d, e-> (a) ( b) ( c) ( d) ( e)
			create r.make ("a, b, c, d, e", 1)
			Result := r.is_well_formatted and
						r[1] ~ create {FIELD}.make ("a")  and
						r[2] ~ create {FIELD}.make (" b") and
						r[3] ~ create {FIELD}.make (" c") and
						r[4] ~ create {FIELD}.make (" d") and
						r[5] ~ create {FIELD}.make (" e")
			check Result end

			--,-> () ()
			create r.make (",", 1)
			Result := r.is_well_formatted and
						r[1] ~ create {FIELD}.make ("")  and
						r[2] ~ create {FIELD}.make ("")  and
						r.is_empty_from (1) and
						r.is_empty_from (2)
			check Result end

			--, , , ,-> () ( ) ( ) ( ) ()
			create r.make (", , , ,", 1)
			Result := r.is_well_formatted and
						r[1] ~ create {FIELD}.make ("")  and
						r[2] ~ create {FIELD}.make (" ") and
						r[3] ~ create {FIELD}.make (" ") and
						r[4] ~ create {FIELD}.make (" ") and
						r[5] ~ create {FIELD}.make ("")  and
						r.is_empty_from (1) and
						r.is_empty_from (2) and
						r.is_empty_from (3) and
						r.is_empty_from (4) and
						r.is_empty_from (5)
			check Result end
		end

	t2 : BOOLEAN
		local
			r : ROW
		do
			comment ("t2: valid quoted fields")

			--"a","b","c","d","e"->(a) (b) (c) (d) (e)
			create r.make ("%"a%",%"b%",%"c%",%"d%",%"e%"", 1)
			Result := r.is_well_formatted and
						r[1] ~ create {FIELD}.make ("a")  and
						r[2] ~ create {FIELD}.make ("b") and
						r[3] ~ create {FIELD}.make ("c") and
						r[4] ~ create {FIELD}.make ("d") and
						r[5] ~ create {FIELD}.make ("e")
			check Result end

			--"a","b, c","d","e"->(a) (b, c) (d) (e)
			create r.make ("%"a%",%"b, c%",%"d%",%"e%"", 1)
			Result := r.is_well_formatted and
						r[1] ~ create {FIELD}.make ("a")  and
						r[2] ~ create {FIELD}.make ("b, c") and
						r[3] ~ create {FIELD}.make ("d") and
						r[4] ~ create {FIELD}.make ("e")
			check Result end

			--"a","b, c" fg,"d","e"->(a) (b, c fg) (d) (e)
			create r.make ("%"a%",%"b, c%" fg,%"d%",%"e%"", 1)
			Result := r.is_well_formatted and
						r[1] ~ create {FIELD}.make ("a")  and
						r[2] ~ create {FIELD}.make ("b, c fg") and
						r[3] ~ create {FIELD}.make ("d") and
						r[4] ~ create {FIELD}.make ("e")
			check Result end

			--"b, c" fg,"a","d","e"->(b, c fg) (a) (d) (e)
			create r.make ("%"b, c%" fg,%"a%",%"d%",%"e%"", 1)
			Result := r.is_well_formatted and
						r[1] ~ create {FIELD}.make ("b, c fg") and
						r[2] ~ create {FIELD}.make ("a")  and
						r[3] ~ create {FIELD}.make ("d") and
						r[4] ~ create {FIELD}.make ("e")
			check Result end

			--"a", "b;c" fg,"d","e"->(a) ("b;c" fg) (d) (e)
			create r.make ("%"a%", %"b;c%" fg,%"d%",%"e%"", 1)
			Result := r.is_well_formatted and
						r[1] ~ create {FIELD}.make ("a")  and
						r[2] ~ create {FIELD}.make (" %"b;c%" fg") and
						r[3] ~ create {FIELD}.make ("d") and
						r[4] ~ create {FIELD}.make ("e")
			check Result end

			--"a", "b, c" fg,"d","e"->(a) ("b) ( c" fg) (d) (e)
			create r.make ("%"a%", %"b, c%" fg,%"d%",%"e%"", 1)
			Result := r.is_well_formatted and
						r[1] ~ create {FIELD}.make ("a")  and
						r[2] ~ create {FIELD}.make (" %"b") and
						r[3] ~ create {FIELD}.make (" c%" fg") and
						r[4] ~ create {FIELD}.make ("d") and
						r[5] ~ create {FIELD}.make ("e")
			check Result end

			--"a", "b, " c" fg, "d","e"->(a) ("b,  c" fg) (d) (e)
			create r.make ("%"a%",%"b, %" c%" fg,%"d%",%"e%"", 1)
			Result := r.is_well_formatted and
						r[1] ~ create {FIELD}.make ("a")  and
						r[2] ~ create {FIELD}.make ("b,  c%" fg") and
						r[3] ~ create {FIELD}.make ("d") and
						r[4] ~ create {FIELD}.make ("e")
			check Result end
		end

	t3 : BOOLEAN
		local
			r : ROW
		do
			comment ("t3: test invalid row -- unmaching quotes")

			--a,"b, c, d,-> ill-formatted
			create r.make ("a,%"b, c, d,", 1)
			Result := not r.is_well_formatted
			check Result end

			--"b, c, d,-> ill-formatted
			create r.make ("%"b, c, d,", 1)
			Result := not r.is_well_formatted
			check Result end
		end
end
