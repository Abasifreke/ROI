note
	description: "Summary description for {TEST_ROOTS}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
 TEST_ROOTS
inherit
 ES_TEST
create
 make
feature -- Initialization
 make
  do
   add_boolean_case (agent t11)
   add_boolean_case (agent t4)
   add_boolean_case (agent t1)
   add_boolean_case (agent t3)
   add_boolean_case (agent t20)
   add_boolean_case (agent t21)
   add_boolean_case (agent t22)
   add_boolean_case (agent t23)
   add_boolean_case (agent t24)
  end
feature -- Creation
 new_polynomial (ls: ARRAYED_LIST [TUPLE [x,y: REAL_64]]): NR_POLYNOMIAL
  do
   create Result.make_from_list (ls)
  end
feature -- Test cases
 tolerance: REAL_64 = 0.0015
 almost_equal (x, y: REAL_64): BOOLEAN
  do
   if x ~ 0.0 and y ~ 0.0 then
    Result := True
   else   Result := (x - y).abs / x.abs.max (y.abs) < tolerance
   end
  end
 t1: BOOLEAN
  local
   f: NR_POLYNOMIAL
   fmt: FORMAT_DOUBLE
  -- sln,
   two: REAL_64
  -- e: REAL_64
   ls: ARRAYED_LIST [TUPLE [REAL_64, REAL_64]]
  do
   comment ("t1: test root finding in dummy square root finding class")
   create fmt.make (10, 10)
   two := 2.0
   create ls.make_from_array (<< [2.0, 0.0], [-1.0, 2.0] >>)
   create f.make_from_list (ls)
    -- the roots of f are the square roots of 2
   f.search_root
   check not f.solution_not_found end
   Result := almost_equal (f.solution * f.solution, 2.0)
   check Result end
  end
 t3: BOOLEAN
  local
   f: NR_POLYNOMIAL
   ls: ARRAYED_LIST [TUPLE [REAL_64, REAL_64]]
  do
   comment ("t3: build a polynomial from financial data and find its roots")
   create ls.make_from_array (<<[10.0,0.0],[10000.0,.25],[-10500.0,.5]>>)
   f := new_polynomial (ls)
   f.search_root
   check not f.solution_not_found end
   Result := f.item (f.solution).abs < tolerance
   check Result end
   Result := almost_equal (f.solution, 0.8261596392439689884)
  end
 t4: BOOLEAN
  local
   f: NR_POLYNOMIAL
   ls: ARRAYED_LIST [TUPLE [REAL_64, REAL_64]]
   expected: REAL_64
   precision: REAL_64
  do
   comment("t4: test polynomila with ROI data")
    -- answer is 22.75% ROI
   expected := 1 + .227509
    -- We are solving polynomial f(R) for R = 1+r
   precision := .0005 -- estimated Excel precision
    -- create a polynomial f(R)
   create ls.make_from_array (<<
    [ 100000.0, 2.00274],
    [  20000.0, 1.5006849],
    [      0.0, 1.00274],
    [-178000.5, 0.0]>>)
   f := new_polynomial (ls)
   f.search_root
   Result := not f.solution_not_found
   check Result end
   Result := f.item (f.solution).abs < tolerance -- (f(x) = [-a, +b], i.e. 0 in [-a, +b].
   check Result end
   --print(f.solution,expected)
   Result := almost_equal (f.solution, expected)
   check Result end
   Result := not (f.item (expected).abs < tolerance)
    -- Excel didn't get as close as we did.
  end
 t11: BOOLEAN
  local
   f1: NR_POLYNOMIAL
   ls: ARRAYED_LIST [TUPLE [x,y: REAL_64]]
  do
   comment ("t11: find roots of an polynomial with large values")
   create ls.make_from_array (
    <<  [3.0, 2.0],
     [-1.0e9, 1.0],
     [5.0, 0.0] >>)
   f1 := new_polynomial (ls)
   f1.search_root
   Result := (f1.solution - 5.0e-9).abs < 1.0e-12
    or (f1.solution - 333333333.3333333).abs < 10.0
  end

t20: BOOLEAN
  local
   f: NR_POLYNOMIAL
   ls: ARRAYED_LIST [TUPLE [REAL_64, REAL_64]]
   expected: REAL_64
   precision: REAL_64
   ans: REAL_64
  do
   comment("t20: test polynomila with partial ROI data")
   expected := 1 + 0.0799
   precision := .0005 -- estimated Excel precision
   create ls.make_from_array (<<
       [ 125000.0, 165.0/365.0],
       [ -135000.0, 0.0]>>)
   f := new_polynomial (ls)
   f.search_root
   ans:= (f.solution)^(165/365)
   Result := not f.solution_not_found
   check Result end
   Result := f.item (f.solution).abs < tolerance -- (f(x) = [-a, +b], i.e. 0 in [-a, +b].
   check Result end
   --print(ans, expected)
   Result := almost_equal (ans, expected)
   check Result end
   Result := not (f.item (expected).abs < tolerance)
    -- Excel didn't get as close as we did.
  end
  t21: BOOLEAN
  local
   p: PRECISE
   ls: ARRAYED_LIST [TUPLE [REAL_64, REAL_64]]
   expected: REAL_64
  do
   comment("t21: test PRECISE Class wholerate function(Whole period) from arraylist")
   expected := 22.75
   create ls.make_from_array(<<
    [ 100000.0, 2.00274],
    [  20000.0, 1.5006849],
    [      0.0, 1.00274],
    [-178000.5, 0.0]>>)
   create p.make
   p.wholerate(ls)
   --print(p.whole,expected)
   Result := almost_equal (p.whole, expected)
  end
-- t22: BOOLEAN
--  local
--   p: PRECISE
--   ls: ARRAYED_LIST [TUPLE [REAL_64, REAL_64]]
--   expected: REAL_64
--  do
--   comment("t22: test PRECISE Class partrate function (part period) from array list")
--   expected := 7.99
--   create ls.make_from_array(<<
--       [ 125000.0, 165.0/365.0],
--       [ -135000.0, 0.0]>>)
--   create p.make
--   p.partrate(ls)
--   --print(p.part,expected)
--   Result := almost_equal (p.part, expected)
--  end

t23:BOOLEAN
 local
  ary: ARRAY[TUPLE[DATE,REAL_64, REAL_64, REAL_64]]
  re:REAL_64
  p:TWR_CALC
  ptest:PRECISE
  d1,d2,d3,d4: DATE
    expected:REAL_64
 do
   comment("t23: test PRECISE Class (whole period) from array")
   expected:=22.75
   --create ary.make_from_array(<< [2007-01-01,100000,0, 0], [2007-07-01,105000, 20000, 0],[2008-01-01,135000,0, 0], [2009-01-01,178000.5,0, 0] >>)
   create d1.make_day_month_year (1, 1, 2007)
   create d2.make_day_month_year (1, 7, 2007)
   create d3.make_day_month_year (1, 1, 2008)
   create d4.make_day_month_year (1, 1, 2009)
   create ptest.make
   ptest.wholerate (ptest.new_array(<< [d1,100000.0,0.0, 0.0], [d2,105000.0, 20000.0, 0.0],[d3,135000.0,0.0, 0.0], [d4,178000.5,0.0, 0.0] >>))
   Result := almost_equal (ptest.whole, expected)
 end

t24:BOOLEAN
 local

   ary: ARRAY[TUPLE[DATE,REAL_64, REAL_64, REAL_64]]
   re:REAL_64
   p:TWR_CALC
   ptest:PRECISE
   --atest:ARRAY
   d1,d2,d3,d4: DATE
    expected:REAL_64
   -- Run application.
  do
   comment("t24: test PRECISE Class from array (part period) from array")
   expected:=8.00
   create d1.make_day_month_year (1, 1, 2007)
   create d2.make_day_month_year (1, 7, 2007)
   create d3.make_day_month_year (1, 1, 2008)
   create d4.make_day_month_year (1, 1, 2009)
   create ptest.make
   ptest.partrate (ptest.new_subarray(d2,d3,(<< [d1,100000.0,0.0, 0.0], [d2,105000.0, 20000.0, 0.0],[d3,135000.0,0.0, 0.0], [d4,178000.5,0.0, 0.0] >>)))
   --print(ptest.part,expected)
   Result := almost_equal (ptest.part, expected)
  end

t22:BOOLEAN
 local

   ary: ARRAY[TUPLE[DATE,REAL_64, REAL_64, REAL_64]]
   re:REAL_64
   p:TWR_CALC
   ptest:PRECISE
   --atest:ARRAY
   da,db,d1,d2,d3,d4: DATE
    expected:REAL_64
   -- Run application.
  do
   comment("t22: test PRECISE Class with a date that has a start date in between valid period and finish date in between another valid period")
   expected:=8.00
   create d1.make_day_month_year (1, 1, 2007)
   create d2.make_day_month_year (1, 7, 2007)
   create d3.make_day_month_year (1, 1, 2008)
   create d4.make_day_month_year (1, 1, 2009)
   create da.make_day_month_year (1, 7, 2007)
   create db.make_day_month_year (1, 12, 2007)

   create ptest.make
   ptest.partrate (ptest.new_subarray(da,db,(<< [d1,100000.0,0.0, 0.0], [d2,105000.0, 20000.0, 0.0],[d3,135000.0,0.0, 0.0], [d4,178000.5,0.0, 0.0] >>)))
   --print(ptest.part,expected)
   Result := almost_equal (ptest.part, expected)


  end



end
