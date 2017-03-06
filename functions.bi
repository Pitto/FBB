declare function add (	head as p_proto ptr ptr, x as single, y as single, _
						x_h as single, y_h as single, x_h_prev as single, y_h_prev as single) as p_proto ptr
						'dim as p_proto ptr p = callocate(sizeof(p_proto))
declare function mix(a as single, b as single, t as single) as single
declare function BezierQuadratic(A as single, B as single, C as single, t as single) as single

declare function BezierCubic(A as single, B as single, C as single, D as single, t as single) as single
declare function d_b_t_p (x1 as single, y1 as single, x2 as single, y2 as single) as single

declare function resizePixels(byval img_source as FB.Image ptr, _
                  w1 as integer, _
                  h1 as integer, _
                  w2 as integer, _
                  h2 as integer) as FB.Image ptr

declare function scaleImg( _
            byval img as FB.Image ptr, _
            byval targetWidth as const integer, _
            byval targetHeight as const integer) as FB.Image ptr
'fbGFXAddon by D.J. Peters  
declare function ImageScale(byval s as fb.Image ptr, _
                    byval w as integer, _
                    byval h as integer) as fb.Image ptr

'This routine has been written by noop
 'http://www.freebasic.net/forum/viewtopic.php?t=24586
'declare function scaleImg( _
'            byval img as FB.Image ptr, _
'            byval targetWidth as const integer, _
'            byval targetHeight as const integer) as FB.Image ptr
'This routine has been written by noop
    'http://www.freebasic.net/forum/viewtopic.php?t=24586        
declare Function bmp_load( ByRef filename As Const String ) As Any Ptr

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



function resizePixels(byval img_source as FB.Image ptr, _
                  w1 as integer, _
                  h1 as integer, _
                  w2 as integer, _
                  h2 as integer) as FB.Image ptr
                  
    dim as FB.Image ptr temp = imagecreate(w2,h2)

    dim x_ratio as integer = (int((w1 shl 16)\w2)) +1
    dim y_ratio as integer = (int((h1 shl 16)\h2)) +1
    
    dim as integer x2, y2, i, j


    for i = 0 to (h2-1)
      for j = 0 to (w2-1)
			
			x2 = ((j*x_ratio) shr 16)
            y2 = ((i*y_ratio) shr 16)
           
			dim as FB.Image ptr pt = getPixelAddress(img_source,x2,y2)
			dim as FB.Image ptr a = getPixelAddress(temp,j,i)
			
			a->bpp = pt->bpp
			
      next j
    next i
   
    return temp
   
end function

'This routine has been written by noop
'    http://www.freebasic.net/forum/viewtopic.php?t=24586
function scaleImg( _
            byval img as FB.Image ptr, _
            byval targetWidth as const integer, _
            byval targetHeight as const integer) as FB.Image ptr
    ' Scale an image. Optimized for downscaling. Not optimized for speed.
    '
    ' Algorithm: (downscaling)
    '    Think of pixels as squares. We want to use fewer pixels to store an
    '    image. That means each square(=pixel) of the downscaled image will
    '    cover several squares of the original image.
    '    First, we will choose a square size for the large squares of the
    '    downscaled image, such that all squares are of the same size and the
    '    whole original image is covered (think of a two chessboards of the
    '    same size but with different numbers of squares).
    '    Let's look at one of the large squares of the downscaled image.
    '       We will call the large square S.
    '    S covers several squares of the original image. Some of them will
    '    only be partially covered. By by A1,...,An we denote a parition of S
    '    such that the union of A1,...,An equals S and each small square
    '    corresponds to exactly one Ai.)
    '    Since the Ai have different areas, the contribution of the colour of
    '    each Ai to the colour of S differs. In order to not distort the image
    '    a colour which is closer to the center of S is more important than a
    '    colour far away from the center.
    '    So we seek a weighting function which gives a colour in the center of
    '    S a larger contribution to the colour of S.
    '    Here, we choose a bilinear function. If we transform S with a
    '    transformation function t(x,y) onto the domain [-1,1]^2, i.e.
    '       t(S)=[-1,1]^2,
    '    then the bilinear function on [-1,1]^2 reads
    '       f(x,y) = (1-x)*(1-y).
    '    Let Bi := t(Ai). The integral over [-1,1]^2 of f(x,y) is 4. Thus it is
    '       integral_[-1,1]^2 f(x,y)/4 d(x,y) = 1.
    '    Let c_R(x,y) denote the red part of the colour on [-1,1]^2 with
    '    respect to the original image (analogously c_G,c_B,c_A are defined).
    '    Then c_R(Bi) is constant. We define the red part of the colour of S as
    '         integral_[-1,1]^2 c_R(x,y)*f(x,y)/4 d(x,y) =
    '       = sum_Bi c_R(Bi)/4*integral_Bi f(x,y) d(x,y).
    '    Now let Bi = [x1,x2]x[y1,y2] then with sfn(v):=v*(1-0.5*v) we have
    '       I(Bi) := integral_Bi f(x,y) d(x,y)
    '              = sfn(x2)-sfn(x1))*(sfn(y2)-sfn(y1))
    '    and (analogously I_G,I_B,I_A are defined)
    '       I_R(S) := ( sum_Bi c_R(Bi)*I(Bi) )/4.
    '    Therefore, we can define the colour of the pixel S as
    '       colour(S) := rgba(I_R(S),I_G(S),I_B(S),I_A(S)).
    '
   
    if (img = 0) then return 0
   
    dim as FB.Image ptr nimg = imagecreate(targetWidth,targetHeight)
    if (img->width = targetWidth) andAlso (img->height = targetHeight) then
        ' Create a copy of the image.
        dim as any ptr p1 = getPixelAddress(nimg,0,0)
        dim as any ptr p2 = getPixelAddress(nimg,targetHeight,0)-1
        memcpy(p1,getPixelAddress(img,0,0),p2-p1+1)
        return nimg
    end if
   
    dim as const double fh = img->height/nimg->height
    dim as const double fw = img->width/nimg->width
    dim as const double e = 0.000001  ' account for rounding errors
    for i as integer = 1 to nimg->height
        ' For the large square S we have
        '    S = [xl,xr]x[yt,yb].
        dim as const double yt = 0.5+fh*(i-1)    ' yTop
        dim as const double ym = 0.5+fh*(i-0.5)  ' yMiddle
        dim as const double yb = 0.5+fh*i        ' yBottom
        for j as integer = 1 to nimg->width
            ' For the large square S we have
            '    S = [xl,xr]x[yt,yb].
            dim as const double xl = 0.5+fw*(j-1)    ' xLeft
            dim as const double xm = 0.5+fw*(j-0.5)  ' xMiddle
            dim as const double xr = 0.5+fw*j        ' xRight
           
            ' Integrate on the partition Ai of S.
            dim as double integ_r = 0.0, integ_g = 0.0, integ_b = 0.0, integ_a = 0.0
            dim as double ki = yt
            while (ki < yb-e)
                dim as const integer kim = round(ki)
                dim as const double kib = fmin(yb,kim+0.5)
                dim as double kj = xl
                while (kj < xr-e)
                    dim as const integer kjm = round(kj)
                    dim as const double kjr = fmin(xr,kjm+0.5)
                    dim as ulong p = *cptr(ulong ptr,getPixelAddress(img,kim-1,kjm-1))
                   
                    ' We now have Ai = [kj,kjr]x[ki,kib] and colour(Ai)=p.
                    ' Next we transform the Ai to Bi = [t_x1,t_x2]x[t_y1,t_y2].
                    dim as const double t_x1 = (xm-kj)/(fw/2)
                    dim as const double t_x2 = (xm-kjr)/(fw/2)
                    dim as const double t_y1 = (ym-ki)/(fh/2)
                    dim as const double t_y2 = (ym-kib)/(fh/2)
                   
                    ' Compute the integral integral_Bi f(x,y).
                    dim as const double iv = (sfn(t_x2)-sfn(t_x1))*(sfn(t_y2)-sfn(t_y1))
                   
                    ' Step after step, compute the integrals I_R(S)*4,...,I_A(S)*4.
                    integ_r += RGBA_R(p)*iv
                    integ_g += RGBA_G(p)*iv
                    integ_b += RGBA_B(p)*iv
                    integ_a += RGBA_A(p)*iv
                   
                    kj = kjr
                wend
                ki = kib
            wend
           
            dim as ulong ptr pt = getPixelAddress(nimg,i-1,j-1)
            ' colour(S) := rgba(I_R(S),I_G(S),I_B(S),I_A(S)).
            *pt = rgba(integ_r/4,integ_g/4,integ_b/4,integ_a/4)
        next j
    next i
   
    return nimg
end function

'This routine has been written by noop
    'http://www.freebasic.net/forum/viewtopic.php?t=24586
Function bmp_load( ByRef filename As Const String ) As Any Ptr

    Dim As Long filenum, bmpwidth, bmpheight
    Dim As Any Ptr img

    '' open BMP file
    filenum = FreeFile()
    If Open( filename For Binary Access Read As #filenum ) <> 0 Then Return NULL

        '' retrieve BMP dimensions
        Get #filenum, 19, bmpwidth
        Get #filenum, 23, bmpheight

    Close #filenum

    '' create image with BMP dimensions
    img = ImageCreate( bmpwidth, Abs(bmpheight) )

    If img = NULL Then Return NULL

    '' load BMP file into image buffer
    If BLoad( filename, img ) <> 0 Then ImageDestroy( img ): Return NULL

    Return img

End Function

'fbGFXAddon by D.J. Peters
function ImageScale(byval s as fb.Image ptr, _
                    byval w as integer, _
                    byval h as integer) as fb.Image ptr
  #macro SCALELOOP()
  for ty = 0 to t->height-1
    ' address of the row
    pr=ps+(y shr 20)*sp
    x=0 ' first column
    for tx = 0 to t->width-1
      *pt=pr[x shr 20]
      pt+=1 ' next column
      x+=xs ' add xstep value
    next
    pt+=tp ' next row
    y+=ys ' add ystep value
  next
  #endmacro
  ' no source image
  if s        =0 then return 0
  ' source widh or height legal ?
  if s->width <1 then return 0
  if s->height<1 then return 0
  ' target min size ok ?
  if w<2 then w=1
  if h<2 then h=1
  ' create new scaled image
  dim as fb.Image ptr t=ImageCreate(w,h,RGB(0,0,0))
  ' x and y steps in fixed point 12:20
  dim as FIXED xs=&H100000*(s->width /t->width ) ' [x] [S]tep
  dim as FIXED ys=&H100000*(s->height/t->height) ' [y] [S]tep
  dim as integer x,y,ty,tx
  select case as const s->bpp
  case 1 ' color palette
    dim as ubyte    ptr ps=cptr(ubyte ptr,s)+32 ' [p]ixel   [s]ource
    dim as uinteger     sp=s->pitch             ' [s]ource  [p]itch
    dim as ubyte    ptr pt=cptr(ubyte ptr,t)+32 ' [p]ixel   [t]arget
    dim as uinteger     tp=t->pitch - t->width  ' [t]arget  [p]itch
    dim as ubyte    ptr pr                      ' [p]ointer [r]ow
    SCALELOOP()
  case 2 ' 15/16 bit
    dim as ushort   ptr ps=cptr(ushort ptr,s)+16
    dim as uinteger     sp=(s->pitch shr 1)
    dim as ushort   ptr pt=cptr(ushort ptr,t)+16
    dim as uinteger     tp=(t->pitch shr 1) - t->width
    dim as ushort   ptr pr
    SCALELOOP()
  case 4 ' 24/32 bit
    dim as ulong    ptr ps=cptr(uinteger ptr,s)+8
    dim as uinteger     sp=(s->pitch shr 2)
    dim as ulong    ptr pt=cptr(uinteger ptr,t)+8
    dim as uinteger     tp=(t->pitch shr 2) - t->width
    dim as ulong    ptr pr
    SCALELOOP()
  end select
  return t
  #undef SCALELOOP
end function



