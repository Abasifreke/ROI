note
	description: "[
		Representation of rows appearing in a comma-separated document.
		While the (finite) number of specified fields in the source line can be queried,
		a row is abstracted as an infinite-length array. 
		This means that when accessing a field whose position is beyond the number of
		specified fields, an empty string is returned.
		Rows in the original file are converted to ASCII (losing UTF or other characters).
		Query `was_ascii' to see if there was such a conversion.
	]"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ROW
inherit
	ANY
	redefine
		out
	end
create
	make

feature {NONE} -- Implementation

	is_valid_field_position (i : INTEGER) : BOOLEAN
			-- Is 'i' a valid field position in the current row?
		do
			Result := 1 <= i and i <= number_of_specified_fields
		end

feature -- Constructor

	make (s32 : READABLE_STRING_GENERAL; i : INTEGER)
			-- Initialize from field string 's32' and convert to ASCII
		require
			i >= 1
			input_string_exists:
				s32 /= Void
		local
			words : LIST[STRING]
			word : STRING
			expecting_ending_quote : BOOLEAN
			ending_quote_pos : INTEGER
			field : FIELD
			combined_words : STRING
			s: STRING
		do
			if is_ascii (s32) then
				was_ascii := true
			else
				was_ascii := false
			end
			s := to_ascii (s32)

			number := i
			words := s.split (',')
			from
				words.start
				expecting_ending_quote := false
				create contents.make_empty
			until
				words.after
			loop
				word := words.item
				if word.starts_with ("%"") then
					if expecting_ending_quote then
						create field.make (combined_words)
						expecting_ending_quote := false
					else
						ending_quote_pos := word.index_of ('%"', 2)
						if ending_quote_pos > 0 then
							create field.make (word.substring (2, ending_quote_pos - 1))
						else
							expecting_ending_quote := true
							create combined_words.make_from_string (word.substring (2, word.count))
						end
					end
				elseif word.has ('%"') then
					ending_quote_pos := word.index_of ('%"', 1)
					if expecting_ending_quote then
						combined_words.append_character (',')
						combined_words.append (word.substring (1, ending_quote_pos - 1))
						combined_words.append (word.substring (ending_quote_pos + 1, word.count))
						create field.make (combined_words)
						expecting_ending_quote := false
					else
						create field.make (word)
					end
				else
					if expecting_ending_quote then
						combined_words.append_character (',')
						combined_words.append (word)
					else
						create field.make (word)
					end
				end

				if not expecting_ending_quote then
					contents.force (field, contents.count + 1)
				end

				words.forth
			end

			if not expecting_ending_quote then
				is_well_formatted := true
			end
		end

feature -- Query on well-formedness

	is_well_formatted : BOOLEAN

feature -- Queries on status

	number : INTEGER

	contents : ARRAY[FIELD]

	number_of_specified_fields : INTEGER
			-- Return the number of specified fields.
		require
			is_well_formatted
		do
			Result := contents.count
		end

	item alias "[]", at alias "@" (i: INTEGER): FIELD
			-- Retrieve field at position 'i'.
		require
			is_well_formatted
		do
			if is_valid_field_position (i) then
				Result := contents [i]
			else
				create Result.make ("")
			end
		ensure
			1 <= i and i <= number_of_specified_fields implies
				Result ~ contents [i]
			i > number_of_specified_fields implies
				Result ~ create {FIELD}.make ("")
		end

	is_empty : BOOLEAN
			-- Is the entire row empty?
		require
			is_well_formatted
		do
			Result := is_empty_from (1)
		ensure
			Result = is_empty_from (1)
		end

	is_empty_from (i : INTEGER) : BOOLEAN
			-- Is the row empty from the 'i'th field?
		require
			is_well_formatted
		local
			j : INTEGER
		do
			if is_valid_field_position (i) then
				from
					j := i
					Result := true
				until
					j > number_of_specified_fields or not Result
				loop
					Result := Result and item (j).is_empty
					j := j + 1
				end
			else
				Result := true
			end
		ensure
			1 <= i and i <= number_of_specified_fields implies
				(Result = across i |..| number_of_specified_fields as pos
					 		all item (pos.item).is_empty end)
			i > number_of_specified_fields implies Result
		end

	contains (s : STRING) : BOOLEAN
			-- Does the current row contain 's' as a substring?
		require
			is_well_formatted
		do
			Result := across contents as field
					  some field.item.out.has_substring (s) end
		ensure
			Result = across contents as field
					 some field.item.out.has_substring (s) end
		end

feature --ASCII
	was_ascii: BOOLEAN
		-- Was this row in original CSV file ASCII?

	is_ascii(s: READABLE_STRING_GENERAL): BOOLEAN
			--Is `s' ASCII?
		require
			non_void_string: s /= Void
		local
			c32: CHARACTER_32
			i: INTEGER
			not_ascii: BOOLEAN
		do
			from
				i := 1
			until
				i > s.count or not_ascii
			loop
				c32 := s.as_string_32.item (i)
				if
					printable_ascii_character (c32)
				then
					Result := true
				else
					Result := false
					not_ascii := true
				end
				i := i + 1
			end
		end


	to_ascii(s: READABLE_STRING_GENERAL): STRING_8
			-- convert unicode string to ascii string
			-- dropping non-Ascii chars
		require
			non_void_string: s /= Void
		local
			c32: CHARACTER_32
			c8: CHARACTER_8
			i: INTEGER
		do
			create Result.make_empty
			from
				i := 1
			until
				i > s.count
			loop
				c32 := s.as_string_32.item (i)
				if
					control_character (c32) or printable_ascii_character (c32)
				then
					c8 := c32.to_character_8
					Result.append_character (c8)
				end
				i := i + 1
			end
		end



	printable_ascii_character(c: CHARACTER_32): BOOLEAN
			-- includes space
		local
			a: ASCII
		do
			create a
			if a.first_printable <= c.code and c.code <= a.last_printable  then
				Result := true
			end
		ensure
			correct_result: (create {ASCII}).first_printable <= c.code and c.code <= (create {ASCII}).first_printable  implies Result
		end


	control_character(c: CHARACTER_32): BOOLEAN
			-- CR, LF, TAB
		do
			if c.code = 9 or c.code = 10 or c.code = 13 then
				Result := true
			end
		ensure
			correct_result: (c.code = 9 or c.code = 10 ) implies Result
		end

feature -- Query on string representation

	out : STRING
		local
			i : INTEGER
		do
			create Result.make_empty
			from
				i := contents.lower
			until
				i > contents.upper
			loop
				Result.append_string (contents[i].out)

				if i < contents.upper then
					Result.append_character (',')
				end

				i := i + 1
			end
		end
end
