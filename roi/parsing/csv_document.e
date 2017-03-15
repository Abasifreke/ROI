note
	description: "[
		Representation of a comma-separated (CSV) document.
		
		A row is well-formatted if and only if it contains matching quotes.
		i.e. either when a double quote %" happens in the beginning of the row, 
		     or when it happens immediately after a comma separator, 
		     we expect for it a matching, ending quote. 
		     
		Rows in the original file are converted to ASCII (losing UTF or other characters).
		Query `was_ascii' to see if there was such a conversion.
	]"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	CSV_DOCUMENT
inherit
	ITERABLE[ROW]
create
	make,
	make_from_file_name

feature -- Input stream

	stream : KI_TEXT_INPUT_STREAM

feature -- Constructor

	make (input_stream : KI_TEXT_INPUT_STREAM)
		do
			stream := input_stream
		end

	make_from_file_name(path: STRING)
		local
			input_file: KL_TEXT_INPUT_FILE
		do
			create input_file.make (path)
			input_file.open_read
			make (input_file)
		end


feature -- Iteration

	new_cursor : CSV_DOC_ITERATION_CURSOR
		do
			create Result.make (stream)
		end
end
