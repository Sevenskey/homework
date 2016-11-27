fun same_string(s1 : string, s2 : string) =
  s1 = s2

(* string * string list -> string list option *)
fun all_except_option ( str : string, strl : string list ) = 
  let 
    fun new_strl strl = 
        case strl of
          [] => []
        | x :: xs => if same_string ( x, str ) 
                     then new_strl ( xs )
                     else x :: new_strl ( xs )
    val newl = new_strl strl
  in if newl = strl then NONE else SOME newl
  end
  
(* string list list * string -> string list *)
fun get_substitutions1 ( strll : string list list, str : string  ) = 
  case strll of
    [] => []
  | strl :: strlx => let val newl = all_except_option ( str, strl ) 
                     in case newl of 
                       SOME ( x :: xs ) => ( x :: xs ) @ get_substitutions1 ( strlx, str )
                     | _ => get_substitutions1 ( strlx, str )
                     end

(*string list list * string -> string list*)
(*using a local tail recursive*)
fun get_substitutions2 ( strll : string list list, str : string ) = 
  let
    fun aux ( strlx, acc ) = 
      case strlx of
        [] => acc
      | strl_ :: strlx_ => let val newl = all_except_option ( str, strl_ )
                           in case newl of 
                             SOME ( x :: xs ) => aux ( strlx_, acc @ ( x :: xs ) ) 
                           | _ => aux ( strlx_, acc )
                           end
  in aux ( strll, [] )
  end
 
(*string list list * { first : string, middle : string, last : string }*)
fun similar_names ( strll : string list list, { first = first: string, middle = middle : string, last = last : string } ) = 
  let 
    val first_namel = first :: get_substitutions1 ( strll, first )
    fun gen_namel ( firstl, acc ) =
      case firstl of
        [] => acc
      | x :: xs => gen_namel( xs, acc @  [ { first=x, middle=middle, last=last } ] )
  in 
    gen_namel ( first_namel, [] )
  end
  

datatype suit = Clubs | Diamonds | Hearts | Spades
datatype rank = Jack | Queen | King | Ace | Num of int 
type card = suit * rank

datatype color = Red | Black
datatype move = Discard of card | Draw 

exception IllegalMove

fun card_color ( s : suit, n : rank )= 
  case s of
    Clubs => Black
  | Spades => Black
  | _ => Red

fun card_value ( s : suit, n : rank )=
  case n of
    Num i => i
  | Ace => 11
  | _ => 10
  
(*card list * card * exception -> card list*)
fun remove_card ( cs : card list, c : card, e ) = 
  case cs of
    [] => raise e
  | cx :: csx => if cx = c
                 then csx
                 else cx :: remove_card ( csx, c, e )
                 
(*card list -> boolean*)
fun all_same_color ( cs : card list ) = 
  case cs of
    [] => true
  | c :: [] => true
  | c1 :: ( c2 :: cs_ ) => if card_color c1 = card_color c2
                           then all_same_color ( c2 :: cs_ )
                           else false

(*card list -> int*)
fun sum_cards ( cs : card list ) =
  case cs of
    [] => 0
  | c :: cs_ => card_value c + sum_cards cs_

(*card list * int -> int*)
fun score ( cs : card list, goal : int ) =
  let
    fun sum_all ( cs : card list ) =
      case cs of
        [] => 0
      | c :: cs_ =>  card_value c + sum_all cs_
    val sum = sum_all cs
    val ps = if sum > goal then 3 * ( sum - goal ) else goal - sum
  in
    if all_same_color cs
    then ps div 2
    else ps
  end

(*card list * move * int -> int*)
fun officiate ( cs : card list, ops : move list, goal : int ) =
  let 
    fun operating ( cs : card list, ops : move list, held_list : card list ) =
      case ops of 
        [] => score ( held_list, goal )
      | Discard c :: ops_ => operating ( cs, ops_, remove_card ( held_list, c, IllegalMove ))
      | Draw :: ops_ => case cs of
                          [] => score ( held_list, goal )
                        | c :: cs_ => 
                            (*。。。太尼玛坑爹了就是因为你我坐在教室找了两个小时bug*)
                            (*带有::操作符的表达式在作为显式单参时外面一！定！要！加！括！号！！！*)
                            if (sum_cards  ( c :: held_list ) )  > goal 
                            then score ( c :: held_list, goal ) 
                            else operating ( cs_, ops_, c :: held_list )
  in
    operating ( cs, ops, [] )
  end
