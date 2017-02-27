' FB Free Hand - by Pitto

'This program is free software; you can redistribute it and/or
'modify it under the terms of the GNU General Public License
'as published by the Free Software Foundation; either version 2
'of the License, or (at your option) any later version.
'
'This program is distributed in the hope that it will be useful,
'but WITHOUT ANY WARRANTY; without even the implied warranty of
'MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
'GNU General Public License for more details.
'
'You should have received a copy of the GNU General Public License
'along with this program; if not, write to the Free Software
'Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
'Also add information on how to contact you by electronic and paper mail.

'#######################################################################

' Compiling instructions: fbc -w all -exx "%f"
' use 1.04 freebasic compiler

' SOME CODING CONVENTIONS USED IN THIS SOURCE CODE______________________
' UPPERCASED  				is a constant
' First_leter uppercased 	is a shared variable
' first_letter_lowercase 	is a local variable
'
' Often the "c" variable name is used as counter variable


#include once "fbgfx.bi"
#include once "crt/string.bi"
#include once "crt/math.bi"
#ifndef NULL
const NULL as any ptr = 0
#endif

#ifndef getPixelAddress
    #define getPixelAddress(img,row,col) cast(any ptr,img) + _
        sizeof(FB.IMAGE) + (img)->pitch * (row) + (img)->bpp * (col)
#endif
#ifndef RGBA_R
    #define RGBA_R( c ) ( CUInt( c ) Shr 16 And 255 )
#endif
#ifndef RGBA_G
    #define RGBA_G( c ) ( CUInt( c ) Shr  8 And 255 )
#endif
#ifndef RGBA_B
    #define RGBA_B( c ) ( CUInt( c )        And 255 )
#endif
#ifndef RGBA_A
    #define RGBA_A( c ) ( CUInt( c ) Shr 24         )
#endif

#define sfn(v) ((v)*(1.0-0.5*(v)))

#macro _abtp (x1,y1,x2,y2)
    -Atan2(y2-y1,x2-x1)
#endmacro


Using FB
Randomize Timer()

'__MACROS_______________________________________________________________
'calculate angle between two points

dim shared Debug_mode		as boolean = false

'#INCLUDE FILES_________________________________________________________

#include "enums.bi"
#include "types.bas"
#include "define_and_consts.bas"
#include "functions.bi"
#include "subs.bas"

'VARIABLES Declarations_________________________________________________

DIM workpage 				AS INTEGER
Dim user_mouse 				as mouse_proto
Dim input_mode				as proto_input_mode
dim head 					as p_proto ptr
dim icon_set (0 to 39) 		as Uinteger ptr
'dim test_bmp  				as Uinteger ptr
dim c 						as integer
dim last_point				as p_proto
dim view_area				as view_area_proto


'initializing some variables

last_point.x = -1

head = NULL
input_mode = pen
user_mouse.is_dragging = false
user_mouse.is_lbtn_released = false
user_mouse.is_lbtn_pressed = false

view_area.x = 0
view_area.y = 0
view_area.zoom = 1.0f
view_area.old_zoom = view_area.zoom


'INITIALIZING GRAPHICS _________________________________________________
screenres SCR_W, SCR_H, 24		'initialize graphics
SetMouse SCR_W\2, SCR_H\2, 0 	'hides mouse pointer

dim as FB.Image ptr test_bmp = bmp_load( "img/test.bmp" )
dim as FB.Image ptr test_bmp_2
test_bmp_2 = scaleImg(test_bmp,test_bmp->width,test_bmp->height)
load_bmp (icon_set(), 240, 96, 10, 4,"img/icon-set.bmp")


'MAIN LOOP______________________________________________________________
do
	if MULTIKEY (SC_Escape) then exit do
	
	
	keyboard_listener(@input_mode, @view_area)
	mouse_listener(@user_mouse)
	
	screenlock ' Lock the screen
	screenset Workpage, Workpage xor 1 ' Swap work pages.
	cls
	put (view_area.x,view_area.y), test_bmp_2
	
	'header info
	draw string (SCR_W - 350, 10), APP_NAME + " " + APP_VERSION
	draw string (SCR_W - 350, 20), "An utility for learning Bezier tool"
	draw string (SCR_W - 350, 30), "Developed in Freebasic by Pitto"
	
	if (Debug_mode) then
		draw string (SCR_W - 150, SCR_H - 10), str(user_mouse.is_lbtn_released)
		draw string (SCR_W - 150, SCR_H - 20), "is drag: " + str(user_mouse.is_dragging)
		draw string (SCR_W - 150, SCR_H - 30), "Debug " + str(Debug_mode)
		draw string (SCR_W - 150, SCR_H - 40), "ZOOM " + str(int(view_area.zoom * 100)) + " %"
		draw string (SCR_W - 150, SCR_H - 60), "View_area.x " + str(int(view_area.x)) 
		draw string (SCR_W - 150, SCR_H - 50), "View_area.y " + str(int(view_area.y)) 
		draw string (user_mouse.x-10, user_mouse.y+5), "x: " + str(int(user_mouse.x / view_area.zoom + (-view_area.x / view_area.zoom)))
		draw string (user_mouse.x-10, user_mouse.y+13), "y: " + str(int(user_mouse.y / view_area.zoom + (-view_area.y / view_area.zoom))) 
	end if
	
	
	
	select case input_mode
		'####################### PEN TOOL #############################
		case pen
			'add new node_______________________________________________
			if (user_mouse.is_lbtn_released) then
				add		(@head, _
						user_mouse.old_x / view_area.zoom + (-view_area.x / view_area.zoom), _
						user_mouse.old_y / view_area.zoom + (-view_area.y / view_area.zoom), _
						user_mouse.oppo_x / view_area.zoom + (-view_area.x / view_area.zoom), _
						user_mouse.oppo_y / view_area.zoom + (-view_area.y / view_area.zoom), _
						user_mouse.x / view_area.zoom + (-view_area.x / view_area.zoom), _
						user_mouse.y / view_area.zoom + (-view_area.y / view_area.zoom))
				user_mouse.is_lbtn_released = false
			end if
			'draw last segment of the path______________________________
			if (head) then
				if (user_mouse.is_dragging = false) then
				draw_segment(	head->x * view_area.zoom + view_area.x,_
								head->y * view_area.zoom + view_area.y,_
								head->x_h_prev * view_area.zoom + view_area.x,_
								head->y_h_prev * view_area.zoom + view_area.y, _
								user_mouse.x,user_mouse.y, user_mouse.x,user_mouse.y)
				else
				draw_segment(	head->x * view_area.zoom + view_area.x,_
								head->y * view_area.zoom + view_area.y,_
								head->x_h_prev * view_area.zoom + view_area.x,_
								head->y_h_prev * view_area.zoom + view_area.y, _
								user_mouse.old_x,user_mouse.old_y, user_mouse.oppo_x,user_mouse.oppo_y)
				end if
			end if
		case selection
			user_mouse.is_lbtn_released = false
		case direct_selection
			user_mouse.is_lbtn_released = false
		case hand
			'####################### HAND TOOL #########################
			if (user_mouse.is_dragging) then
				line (user_mouse.x, user_mouse.y)-(user_mouse.old_X, user_mouse.old_y)
			end if
			if (user_mouse.is_lbtn_released) then
				view_area.x += (user_mouse.x - user_mouse.old_x)
				view_area.y += (user_mouse.y - user_mouse.old_y)
			end if
			user_mouse.is_lbtn_released = false
	end select
	
	if (view_area.old_zoom <> view_area.zoom) then
		test_bmp_2 = scaleImg(test_bmp,view_area.zoom*test_bmp->width,view_area.zoom*test_bmp->height)
	end if
	
	view_area.old_zoom = view_area.zoom

	draw_input_mode	(input_mode, 10, SCR_H - 50)
	draw_mouse_pointer(user_mouse, input_mode, icon_set())
	display(head, @user_mouse, view_area)
	draw_bottom_info (icon_set())
	
	workpage = 1 - Workpage ' Swap work pages.
	screenunlock
	sleep 20,1
LOOP

'FREE MEMORY____________________________________________________________

'destroy icon_Set bitmaps form memory
for c = 0 to Ubound(icon_set)
	ImageDestroy icon_set(c)
next c

'destroy icon_Set bitmaps form memory
ImageDestroy test_bmp
ImageDestroy test_bmp_2

