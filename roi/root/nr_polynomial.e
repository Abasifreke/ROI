note
 description: "Summary description for {NR_POLYNOMIAL}."
 author: ""
 date: "$Date$"
 revision: "$Revision$"
class
 NR_POLYNOMIAL
create
 make_from_list
feature {NONE} -- Initialization
 make_from_list (ls: LIST [TUPLE [x,y: REAL_64]])
  do
   poly_list := ls
  end
feature -- Access
 derivative: NR_POLYNOMIAL
  local
   ls: ARRAYED_LIST [TUPLE [x,y: REAL_64]]
  do
   create ls.make (poly_list.count)
   across 1 |..| poly_list.count as c loop
    ls.extend ([ poly_list [c.item].x * poly_list [c.item].y, poly_list [c.item].y - 1.0 ])
   end
   create Result.make_from_list (ls)
  end
 item (x: REAL_64): REAL_64
  do
   across poly_list.new_cursor as c loop
    Result := Result + (c.item.x * (x ^ c.item.y))
   end
  end
 solution: REAL_64
 guess: REAL_64 = 0.1
 Tries: INTEGER_32 = 200
 Epsilon: REAL_64 = .001
feature -- Status report
 solution_not_found: BOOLEAN
feature -- Basic operation
 search_root
  local
   i,j: INTEGER_32
   r0, r1, fr0, dfr0, err: REAL_64
   seed: REAL_64
   df: NR_POLYNOMIAL
  do
   solution_not_found := True
   df := derivative
   from
    seed := guess
    i := 0
    err := err.Max_value
   until
    i = 200 or err < epsilon or not solution_not_found
   loop
    i := i + 1
    from
     r0 := seed
     err := err.Max_value
     j := 1
    until
     r0 < 0.0 or err < Epsilon or j = Tries
    loop
     fr0 := item (r0)
     dfr0 := df.item (r0)
     if (dfr0 - 0.0).abs < 100*{REAL_64}.Min_value then
      r1 := r0 / 2.0
     else
      r1 := r0 - (fr0 / dfr0)
     end
     err := (r1 - r0).abs
     r0 := r1
     j := j + 1
    end
    seed := seed + 1.0
    if err < epsilon then
     solution := r0
     solution_not_found := False
    else
     solution_not_found := True
    end
   end
  end
feature {NONE} -- Implementation
 poly_list: LIST [TUPLE [x,y: REAL_64]]
end
