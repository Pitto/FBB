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


#include "fbgfx.bi"
#ifndef NULL
const NULL as any ptr = 0
#endif

Using FB
Randomize Timer()

'__MACROS_______________________________________________________________
'calculate angle between two points
#macro _abtp (x1,y1,x2,y2)
    -Atan2(y2-y1,x2-x1)
#endmacro

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
dim test_bmp  				as Uinteger ptr
dim c 						as integer
dim last_point				as p_proto

'initializing some variables
last_point.x = -1

head = NULL
input_mode = selection
user_mouse.is_dragging = false
user_mouse.is_lbtn_released = false
user_mouse.is_lbtn_pressed = false


'INITIALIZING GRAPHICS _________________________________________________
screenres SCR_W, SCR_H, 24		'initialize graphics
SetMouse SCR_W\2, SCR_H\2, 0 	'hides mouse pointer

BLOAD "img/test.bmp", 0
test_bmp = IMAGECREATE (800, 600)
GET (0,0)-(799,599), test_bmp


load_bmp (icon_set(), 240, 96, 10, 4,"img/icon-set.bmp")




'MAIN LOOP______________________________________________________________
do
	if MULTIKEY (SC_Escape) then exit do
	keyboard_listener(@input_mode)
	mouse_listener(@user_mouse)
	screenlock ' Lock the screen
	screenset Workpage, Workpage xor 1 ' Swap work pages.
	cls
	'header info
	draw string (SCR_W - 350, 10), APP_NAME + " " + APP_VERSION
	draw string (SCR_W - 350, 20), "An utility for learning Bezier tool"
	draw string (SCR_W - 350, 30), "Developed in Freebasic by Pitto"
	draw string (SCR_W - 150, SCR_H - 10), str(user_mouse.is_lbtn_released)
	draw string (SCR_W - 150, SCR_H - 20), "is drag: " + str(user_mouse.is_dragging)
	put (0,0), test_bmp
	draw_input_mode(@input_mode, 10, SCR_H - 16)
	draw_mouse_pointer(user_mouse, input_mode, icon_set())
	
	workpage = 1 - Workpage ' Swap work pages.
	if (user_mouse.is_lbtn_released) then
		add(@head, user_mouse.old_x, user_mouse.old_y, user_mouse.oppo_x, user_mouse.oppo_y, user_mouse.x, user_mouse.y)
		last_point.x = user_mouse.old_x
		last_point.y = user_mouse.old_y
		last_point.x_h = user_mouse.x
		last_point.y_h = user_mouse.y
		user_mouse.is_lbtn_released= false
	end if
	
	'draw last segment
	if (user_mouse.is_dragging and CBool(last_point.x <> -1)) then
		draw_segment(	last_point.x,last_point.y,last_point.x_h,last_point.y_h, _
						user_mouse.old_x,user_mouse.old_y, user_mouse.oppo_x,user_mouse.oppo_y)
	end if

	display(head, @user_mouse)

	draw_bottom_info (icon_set())

	screenunlock
	sleep 20,1
LOOP

'FREE MEMORY____________________________________________________________

'destroy icon_Set bitmaps form memory
for c = 0 to Ubound(icon_set)
	ImageDestroy icon_set(c)
next c

'destroy icon_Set bitmaps form memory

'	ImageDestroy test_bmp

