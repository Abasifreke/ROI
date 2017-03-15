note
	description: "Representation of an iteration over a comma-separated document."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	CSV_DOC_ITERATION_CURSOR
inherit
	ITERATION_CURSOR[ROW]
create
	make

feature {NONE} -- Input stream

	stream : KI_TEXT_INPUT_STREAM

	line_num : INTEGER

feature {CSV_DOCUMENT} -- Constructor

	make (input_stream : KI_TEXT_INPUT_STREAM)
			-- Initialize the iterator.
		require
			input_stream /= Void
		do
			stream := input_stream
			if not stream.end_of_input then
				stream.read_line
				line_num := 1
			end
		end

feature -- Iteration

	item : ROW
			-- Return element at the current iterator position.
		do
			create Result.make (stream.last_string.twin, line_num)
		end

	after : BOOLEAN
			-- Has the iterator reached the end of the input?
		do
			Result := stream.end_of_input
		end

	forth
			-- Move the iterator to the next element.
		require else
			not after
		do
			stream.read_line
			line_num := line_num + 1
		end

	exit
			-- Terminate the iterator.
		do
			stream.close
		end
end
