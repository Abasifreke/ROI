note
 description: "Summary description for {PRECISE}."
 author: ""
 date: "$Date$"
 revision: "$Revision$"
class
 PRECISE
create
 make

feature
 make
  do
   --create
  end
feature
whole:REAL_64
part:REAL_64
countday:INTEGER
feature -- creation

 new_array (ary: ARRAY[TUPLE[date:DATE; mv:REAL_64; cf:REAL_64; af:REAL_64]]):ARRAYED_LIST[TUPLE[REAL_64,REAL_64]]
  local
    temp:ARRAY[TUPLE[x,y:REAL_64]]
    i:INTEGER
    myTuple:TUPLE[a:REAL_64;b:REAL_64]

  do
     create temp.make_empty
     create myTuple.default_create
     myTuple.a :=(ary[1].mv + ary[1].cf - ary[1].af)
     myTuple.b :=( ary[ary.count].date.days -ary[1].date.days )/365.2422
     temp.force (myTuple.deep_twin, 1)

     from
       i:=2
     until
       i=ary.count
     loop
       myTuple.a :=(ary[i].cf - ary[i].af)
       myTuple.b :=(ary[ary.count].date.days - ary[i].date.days)/365.2422
       temp.force (myTuple.deep_twin, i)
       i:=i+1
     end

     temp.force (myTuple.deep_twin, ary.count)
     temp[i].x:=(ary[i].cf-ary[i].af-ary[i].mv)
     temp[i].y:=0
    create RESULT.make_from_array(temp)
  end

new_subarray(start_date:DATE;end_date:DATE; ary: ARRAY[TUPLE[date:DATE; mv:REAL_64; cf:REAL_64; af:REAL_64]]):ARRAYED_LIST[TUPLE[REAL_64,REAL_64]]
  local
    temp:ARRAY[TUPLE[x,y:REAL_64]]
    i,j,count:INTEGER
    myTuple:TUPLE[a:REAL_64;b:REAL_64]
    exit:BOOLEAN
  do
     create temp.make_empty
     create myTuple.default_create
     exit:=FALSE
     count:=1
     countday:=end_date.days-start_date.days
     from
       i:=1
     until
       i>ary.count or exit
     loop
      if (start_date.days-ary[i].date.days=0)or (start_date.days<ary[i].date.days)
      then
       myTuple.a :=(ary[i].mv+ary[i].cf-ary[i].af)
       myTuple.b :=(end_date.days-ary[i].date.days)/365.2422


       temp.force (myTuple.deep_twin, count)
       count:=count+1
       exit:=TRUE
      end
      i:=i+1
     end

     if (exit=TRUE)
     then
      from
       j:=i
      until
       (j>ary.count or (end_date.days-ary[j].date.days=0)or (end_date.days<ary[j+1].date.days) )
      loop
       myTuple.a :=(ary[j].cf-ary[j].af)
       myTuple.b :=(end_date.days-ary[j].date.days)/365.2422
       temp.force (myTuple.deep_twin, count)
       count:=count+1
       j:=j+1
      end
     end
     myTuple.a:=(ary[j].cf-ary[j].af-ary[j].mv)
     myTuple.b:=0
     temp.force (myTuple.deep_twin, count)

    create RESULT.make_from_array(temp)
  end
 new_polynomial (ls: ARRAYED_LIST [TUPLE [x,y: REAL_64]]): NR_POLYNOMIAL
  do
   create Result.make_from_list (ls)
  end -- access
 wholerate(ls: ARRAYED_LIST [TUPLE [REAL_64, REAL_64]]) --return a whole rate
  require
  voidcheck: ls /= void
  local
    poly: NR_POLYNOMIAL
   do
    poly:=new_polynomial(ls)
    poly.search_root
    whole:=(poly.solution-1)*100
   end
 partrate(ls: ARRAYED_LIST [TUPLE [REAL_64, REAL_64]])--return a partial rate
  local
    poly: NR_POLYNOMIAL
  do
    poly:=new_polynomial(ls)
    poly.search_root
    --print(poly.solution)
    part:= ((poly.solution^(countday/365.2422))-1)*100
  end

end
