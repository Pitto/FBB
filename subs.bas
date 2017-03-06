declare sub keyboard_listener(	input_mode as proto_input_mode ptr, _
								user_mouse as mouse_proto, _
								view_area as view_area_proto ptr)

declare sub draw_input_mode (input_mode as proto_input_mode, x as integer, y as integer)
declare sub draw_mouse_pointer	(	user_mouse as mouse_proto, _
							input_mode as proto_input_mode, _
							icon_set() as Uinteger ptr)
declare sub mouse_listener(user_mouse as mouse_proto ptr, view_area as view_area_proto ptr)
declare sub load_bmp ( bmp() as Uinteger ptr, w as integer, h as integer, _
					   cols as integer, rows as integer, Byref bmp_path as string)
	   
declare sub display (head as p_proto ptr, user_mouse as mouse_proto ptr,  view_area as view_area_proto)
declare sub draw_bottom_info (icon_set() as Uinteger ptr)

declare sub draw_segment (	x1 as single, 	y1 as single,  _
							x1h as single, 	y1h as single, _
							x2 as single, 	y2 as single,  _
							x2h as single, 	y2h as single)

sub draw_bottom_info (icon_set() as Uinteger ptr)
	dim c as integer = 0
	
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

sub keyboard_listener(	input_mode as proto_input_mode ptr, _
						user_mouse as mouse_proto, _
						view_area as view_area_proto ptr)
	
	static old_input_mode as proto_input_mode = pen
	
	dim e As EVENT
	If (ScreenEvent(@e)) Then
		Select Case e.type
		Case EVENT_KEY_RELEASE
			'switch Debug mode ON/OFF___________________________________
			If (e.scancode = SC_D) Then
				if Debug_mode then
					Debug_mode = false
				else
					Debug_mode = true
				end if
			end if
			
		End Select
	End If
	
	'this is for the hand ovverride tool
	if multikey (SC_SPACE) then
		*input_mode = hand
	else
		*input_mode = old_input_mode
	end if
	if multikey (SC_V) then *input_mode = selection
	if multikey (SC_A) then *input_mode = direct_selection
	if multikey (SC_P) then *input_mode = pen
	
	'this is for the hand ovverride tool
	if *input_mode <> hand then
		old_input_mode = *input_mode
	end if
	
end sub

sub draw_input_mode (input_mode as proto_input_mode, x as integer, y as integer)
	select case input_mode
		case selection
			draw string (x, y), "SELECTION"
		case direct_selection
			draw string (x, y), "DIRECT SELECTION"
		case pen
			draw string (x, y), "PEN TOOL"
		case hand
			draw string (x, y), "HAND TOOL"
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
								
	

	select case input_mode
		case pen
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
		case selection
			put (user_mouse.x-12, user_mouse.y), icon_set(icon_selection), trans
		case direct_selection
			put (user_mouse.x-12, user_mouse.y), icon_set(icon_direct_selection), trans
		case hand
			put (user_mouse.x-12, user_mouse.y), icon_set(icon_hand), trans
			
	end select

end sub

sub mouse_listener(user_mouse as mouse_proto ptr, view_area as view_area_proto ptr)
	static old_is_lbtn_pressed as boolean = false
	static old_is_rbtn_pressed as boolean = false
	static as integer old_x, old_y
	static store_xy as boolean = false
	
	if User_Mouse->old_wheel < User_Mouse->wheel and view_area->zoom < 4 then
		view_area->zoom *= 2.0f
	end if
	if User_Mouse->old_wheel > User_Mouse->wheel and view_area->zoom > 0.25 then
		view_area->zoom *= 0.5f
	end if
	
	'recognize if the left button has been pressed
	if User_Mouse->buttons and 1 then
		User_Mouse->is_lbtn_pressed = true
	else
		User_Mouse->is_lbtn_pressed = false
	end if
	
	'recognize if the right button has been pressed
	if User_Mouse->buttons and 2 then
		User_Mouse->is_rbtn_pressed = true
	else
		User_Mouse->is_rbtn_pressed = false
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
	
	'recognize if the right button has been released
	if old_is_rbtn_pressed and User_Mouse->is_rbtn_pressed = false then 
		User_Mouse->is_rbtn_released = true
	end if
	
	'recognize drag
	if (User_Mouse->is_lbtn_pressed) and CBool((old_x <> user_mouse->x) or (old_y <> user_mouse->y)) then
		user_mouse->is_dragging = true
		'cuspid node
		if multikey(SC_ALT) then
			user_mouse->oppo_x = user_mouse->old_oppo_x
			user_mouse->oppo_y = user_mouse->old_oppo_y
		'normal node
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
	'store the old state of left button
	old_is_rbtn_pressed = User_Mouse->is_rbtn_pressed
	'store the old wheel state
	User_Mouse->old_wheel = User_Mouse->wheel
	
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

sub display (head as p_proto ptr, user_mouse as mouse_proto ptr, view_area as view_area_proto)
dim as integer p_oldx, p_oldy, py, px, p_oldx_h, p_oldy_h, prev_p_oldx_h, prev_p_oldy_h
dim c as integer = 0


draw string (50, 50), str(hex(head))

'handles of last segment
if (head) then
	
	line 	(head->x * view_area.zoom + view_area.x, _
			head->y * view_area.zoom + view_area.y)- _
			(head->x_h * view_area.zoom + view_area.x, _
			head->y_h * view_area.zoom + view_area.y), 	HANDLE_COLOR
	
	line 	(head->x * view_area.zoom + view_area.x, _
			head->y * view_area.zoom + view_area.y)- _
			(head->x_h_prev * view_area.zoom + view_area.x, _
			head->y_h_prev * view_area.zoom + view_area.y), 	HANDLE_COLOR
			
		
	circle 	(head->x * view_area.zoom + view_area.x, _
			head->y * view_area.zoom + view_area.y), NODE_W, HANDLE_COLOR, , , , F
	circle 	(head->x_h * view_area.zoom + view_area.x, _
			head->y_h * view_area.zoom + view_area.y), NODE_W, HANDLE_COLOR, , , , F
	circle 	(head->x_h_prev * view_area.zoom + view_area.x, _
			head->y_h_prev * view_area.zoom + view_area.y), NODE_W, HANDLE_COLOR, , , , F

end if



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
			circle (p_oldx * view_area.zoom + view_area.x, _
					p_oldy * view_area.zoom + view_area.y), NODE_W, NODE_COLOR, , , , F

			draw_segment(	p_oldx * view_area.zoom + view_area.x, _
							p_oldy * view_area.zoom + view_area.y, _
							p_oldx_h * view_area.zoom + view_area.x, _
							p_oldy_h * view_area.zoom + view_area.y, _
							head->x * view_area.zoom + view_area.x,_
							head->y * view_area.zoom + view_area.y,_
							head->x_h_prev * view_area.zoom + view_area.x,_
							head->y_h_prev * view_area.zoom + view_area.y)
			
			'shows Hex values of linked list's node pointers
			if (Debug_mode) then 		
				draw string ((p_oldx + 4) * view_area.zoom + view_area.x, _
							(p_oldy + 4) * view_area.zoom + view_area.y), "[+] " + str(hex(head)), C_GRAY
				draw string ((p_oldx + 4) * view_area.zoom + view_area.x, _
							(p_oldy + 9) * view_area.zoom + view_area.y), "[>] " + str(hex(head->next_p)), C_GRAY
			end if			
			'highlight last node
			if head-> next_p = NULL then
				circle (head->x * view_area.zoom + view_area.x, _
						head->y * view_area.zoom + view_area.y), _
						NODE_W +1, NODE_COLOR
				circle (head->x * view_area.zoom + view_area.x, _
						head->y * view_area.zoom + view_area.y), _
						NODE_W, NODE_COLOR
			end if
					
		end if
		c +=1
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
		
		if (t) then
			line (old_tx, old_ty)-(tx,ty), C_GRAY
		end if
		old_tx = tx
		old_ty = ty
	next t

end sub
