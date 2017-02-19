declare sub keyboard_listener(input_mode as proto_input_mode ptr)
declare sub draw_input_mode (input_mode as proto_input_mode ptr, x as integer, y as integer)
declare sub draw_mouse_pointer	(	user_mouse as mouse_proto, _
							input_mode as proto_input_mode, _
							icon_set() as Uinteger ptr)
declare sub mouse_listener(user_mouse as mouse_proto ptr)
declare sub load_bmp ( bmp() as Uinteger ptr, w as integer, h as integer, _
					   cols as integer, rows as integer, Byref bmp_path as string)
	   
declare sub display (head as p_proto ptr, user_mouse as mouse_proto ptr)
declare sub draw_bottom_info (icon_set() as Uinteger ptr)

declare sub draw_segment (	x1 as single, 	y1 as single,  _
							x1h as single, 	y1h as single, _
							x2 as single, 	y2 as single,  _
							x2h as single, 	y2h as single)

sub draw_bottom_info (icon_set() as Uinteger ptr)
	dim c as integer = 0
	
	'put footer bar
	for c = 0 to (SCR_W \ ICON_W) + 1
		put (ICON_W * c, SCR_H - ICON_H), icon_set(icon_bottom_bar), trans
	next c
	
	for c = 0 to 3
		select case c
			case 0
				if multikey (SC_LSHIFT) then
					put (ICON_W * c, SCR_H - ICON_H),_
					icon_set(icon_shift_is_pressed), trans
				else
					put (ICON_W * c, SCR_H - ICON_H),_
					icon_set(icon_shift), trans
				end if
			case 1
				if multikey (SC_CONTROL) then
					put (ICON_W * c, SCR_H - ICON_H),_
					icon_set(icon_ctrl_is_pressed), trans
				else
					put (ICON_W * c, SCR_H - ICON_H),_
					icon_set(icon_ctrl), trans
				end if
			case 2
				if multikey (SC_ALT) then
					put (ICON_W * c, SCR_H - ICON_H),_
					icon_set(icon_alt_is_pressed), trans
				else
					put (ICON_W * c, SCR_H - ICON_H),_
					icon_set(icon_alt), trans
				end if
			case 3
				if multikey (SC_SPACE) then
					put (ICON_W * c, SCR_H - ICON_H),_
					icon_set(icon_spacebar_is_pressed), trans
				else
					put (ICON_W * c, SCR_H - ICON_H),_
					icon_set(icon_spacebar), trans
				end if
		end select
	next c
	
	
end sub

sub keyboard_listener(input_mode as proto_input_mode ptr)
	if multikey (SC_V) then *input_mode = selection
	if multikey (SC_A) then *input_mode = direct_selection
	if multikey (SC_P) then *input_mode = pen
end sub

sub draw_input_mode (input_mode as proto_input_mode ptr, x as integer, y as integer)
	select case *input_mode
		case selection
			draw string (x, y), "SELECTION"
		case direct_selection
			draw string (x, y), "DIRECT SELECTION"
		case pen
			draw string (x, y), "PEN TOOL"
		case else
			draw string (x, y), "???"
	end select
end sub

sub draw_mouse_pointer	(	user_mouse as mouse_proto, _
							input_mode as proto_input_mode, _
							icon_set() as Uinteger ptr)
							
	User_Mouse.res = 	GetMouse( 	User_Mouse.x, User_Mouse.y, _
								User_Mouse.wheel, User_Mouse.buttons,_
								User_Mouse.clip)
								
	draw string (10, 10), "x " + str(User_Mouse.x)
	draw string (60, 10), "y " + str(User_Mouse.y)

	if User_Mouse.is_lbtn_pressed then
		circle (User_Mouse.x, User_Mouse.y), 2, C_RED	
		circle (User_Mouse.oppo_x, User_Mouse.oppo_y), 2, C_RED	
	end if
	
		

	if User_Mouse.is_dragging = false then
		put (user_mouse.x-12, user_mouse.y), icon_set(icon_pen), trans
		
	else
				
		circle(User_mouse.old_x, User_mouse.old_y), 2
		circle (User_mouse.oppo_x, User_mouse.oppo_y), 2, C_RED
				
		line (User_Mouse.x, User_Mouse.y)-(User_Mouse.old_x, User_Mouse.old_y), C_DARK_RED
		line (User_Mouse.old_x, User_Mouse.old_y)-(User_mouse.oppo_x, User_mouse.oppo_y), C_DARK_RED
		
		put (user_mouse.x-12, user_mouse.y), icon_set(icon_drag_handle), trans
	end if

end sub

sub mouse_listener(user_mouse as mouse_proto ptr)
	static old_is_lbtn_pressed as boolean = false
	static as integer old_x, old_y
	static store_xy as boolean = false
	
	'recognize if the left button has been pressed
	if User_Mouse->buttons and 1 then
		User_Mouse->is_lbtn_pressed = true
	else
		User_Mouse->is_lbtn_pressed = false
	end if
	
	'recognize if the left button has been released
	if old_is_lbtn_pressed = false and User_Mouse->is_lbtn_pressed and store_xy = false then 
		store_xy = true
	end if
	
	if store_xy then
		user_mouse->old_x = user_mouse->x
		user_mouse->old_y = user_mouse->y
		store_xy = false
	end if
	
	'recognize if the left button has been released
	if old_is_lbtn_pressed and User_Mouse->is_lbtn_pressed = false then 
		User_Mouse->is_lbtn_released = true
	end if
	
	'recognize drag
	if (User_Mouse->is_lbtn_pressed) and CBool((old_x <> user_mouse->x) or (old_y <> user_mouse->y)) then
		user_mouse->is_dragging = true
		if multikey(SC_ALT) then
			user_mouse->oppo_x = user_mouse->old_oppo_x
			user_mouse->oppo_y = user_mouse->old_oppo_y
		else
			user_mouse->oppo_x = User_Mouse->old_x - _
						cos (_abtp (User_Mouse->old_x, User_Mouse->old_y, User_Mouse->x, User_Mouse->y)) * _
						(d_b_t_p(User_Mouse->old_x, User_Mouse->old_y, User_Mouse->x, User_Mouse->y))
			user_mouse->oppo_y = User_Mouse->old_y - _
						-sin(_abtp (User_Mouse->old_x, User_Mouse->old_y, User_Mouse->x, User_Mouse->y)) * _
						(d_b_t_p(User_Mouse->old_x, User_Mouse->old_y, User_Mouse->x, User_Mouse->y))
			user_mouse->old_oppo_x = user_mouse->oppo_x
			user_mouse->old_oppo_y = user_mouse->oppo_y
		end if			
		
	else
		user_mouse->is_dragging = false
	end if
	
	'store the old state of left button
	old_is_lbtn_pressed = User_Mouse->is_lbtn_pressed
	
end sub

sub load_bmp ( 	bmp() as Uinteger ptr, w as integer, h as integer, _
				cols as integer, rows as integer, Byref bmp_path as string)
				
	dim as integer c, tiles, tile_w, tile_h, y, x
	tiles = cols * rows
	tile_w = w\cols
	tile_h = h\rows
	y = 0
	x = 0
	
	BLOAD bmp_path, 0
	
	for c = 0 to Ubound(bmp)
		if c > 0 and c mod cols = 0 then
			y+= tile_h 
			x = 0 
		end if
		bmp(c) = IMAGECREATE (tile_w, tile_h)
		GET (x, y)-(x + tile_w - 1, y + tile_h - 1), bmp(c)
		x += tile_w

	next c

end sub

sub display (head as p_proto ptr, user_mouse as mouse_proto ptr)
dim as integer p_oldx, p_oldy, py, px, p_oldx_h, p_oldy_h, prev_p_oldx_h, prev_p_oldy_h
dim c as integer
dim last as p_proto ptr
	while (head <> NULL)
		
		
		
		p_oldx = head->x
		p_oldy = head->y
		p_oldx_h = head->x_h
		p_oldy_h = head->y_h
		prev_p_oldx_h = head->x_h_prev
		prev_p_oldy_h = head->y_h_prev
	
		head = head->next_p
	
		if (head) then

			px = head->x
			py = head->y
			
			'node higlight
			circle (p_oldx, p_oldy), NODE_W, NODE_COLOR, , , , F

			'handles
			line (p_oldx, p_oldy)-(p_oldx_h, p_oldy_h), HANDLE_COLOR
			circle (p_oldx_h, p_oldy_h), NODE_W, HANDLE_COLOR, , , , F
			line (head->x, head->y)-(head->x_h, head->y_h), HANDLE_COLOR
			circle (head->x_h, head->y_h), NODE_W, HANDLE_COLOR, , , , F
			line (p_oldx, p_oldy)-(prev_p_oldx_h, prev_p_oldy_h), HANDLE_COLOR
			circle (head->x_h_prev, head->y_h_prev), NODE_W, HANDLE_COLOR, , , , F
			
			draw_segment(	p_oldx,p_oldy,p_oldx_h,p_oldy_h, _
							head->x,head->y,head->x_h_prev,head->y_h_prev)
							
			
					
		end if
		
	wend
	
end sub

sub draw_segment (	x1 as single, 	y1 as single,  _
					x1h as single, 	y1h as single, _
					x2 as single, 	y2 as single,  _
					x2h as single, 	y2h as single)
	dim as single t, tx, ty, old_tx, old_ty
	for t = 0 to 1 step SEGMENT_PRECISION
		tx = BezierCubic( x1, x1h, x2h, x2, t)
		ty = BezierCubic( y1, y1h, y2h, y2, t)
		'pset (	BezierCubic( x1, x1h, x2h, x2, t),_
		'		BezierCubic( y1, y1h, y2h, y2, t))
		
		if (t) then
			line (old_tx, old_ty)-(tx,ty)
		end if
		old_tx = tx
		old_ty = ty
	next t

end sub
