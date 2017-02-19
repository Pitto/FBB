declare function add (	head as p_proto ptr ptr, x as single, y as single, _
						x_h as single, y_h as single, x_h_prev as single, y_h_prev as single) as p_proto ptr
						dim as p_proto ptr p = callocate(sizeof(p_proto))
declare function mix(a as single, b as single, t as single) as single
declare function BezierQuadratic(A as single, B as single, C as single, t as single) as single

declare function BezierCubic(A as single, B as single, C as single, D as single, t as single) as single
declare function d_b_t_p (x1 as single, y1 as single, x2 as single, y2 as single) as single



function d_b_t_p (x1 as single, y1 as single, x2 as single, y2 as single) as single
    return Sqr(((x1-x2)*(x1-x2))+((y1-y2)*(y1-y2)))
end function

function add 	(head as p_proto ptr ptr, x as single, y as single, _
				x_h as single, y_h as single, x_h_prev as single, y_h_prev as single) as p_proto ptr
    dim as p_proto ptr p = callocate(sizeof(p_proto))
    p->x = x
    p->y = y
    p->x_h = x_h
    p->y_h = y_h
    p->x_h_prev = x_h_prev
    p->y_h_prev = y_h_prev
    
	p->next_p = *head
    *head = p
    return p
end function


function mix(a as single, b as single, t as single) as single
    ' degree 1
    return (a * (1.0 - t) + b*t)
end function

function BezierQuadratic(A as single, B as single, C as single, t as single) as single
    ' degree 2
    dim as single AB, BC
    AB = mix(A, B, t)
    BC = mix(B, C, t)
    return mix(AB, BC, t)
end function

function BezierCubic(A as single, B as single, C as single, D as single, t as single) as single
    ' degree 3
    dim as single ABC, BCD
    ABC = BezierQuadratic(A, B, C, t)
    BCD = BezierQuadratic(B, C, D, t)
    return mix(ABC, BCD, t)
end function


