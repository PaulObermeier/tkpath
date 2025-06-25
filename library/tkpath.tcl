# tkpath.tcl --
#
# 20160121 ensemble version created
#
#       Various support procedures for the tkpath package.
#
#  Copyright (c) 2016 r.zaumseil@freenet.de
#  Copyright (c) 2018 Dimitrios Zachariadis (dzach)
#  		      for tkp::path::cg::*, tkp::path::annulus/parc

namespace eval ::tkp {
    namespace export *
    namespace ensemble create -map {matrix ::tkp::matrix path ::tkp::path}

    # All functions inside this namespace return a transformation matrix.
    namespace eval matrix {
	namespace export *
	namespace ensemble create
    }

    # All functions inside this namespace return a path description.
    namespace eval path {
	namespace eval cg {}
	namespace export *
	namespace ensemble create
    }
}

# ::tkp::matrix::rotate --
# Arguments:
#	angle	Angle in radians or degrees (with "d" suffix)
#	cx	X-center coordinate
#	cy	Y-center coordinate
# Results:
#       The transformation matrix.
proc ::tkp::matrix::rotate {angle {cx 0} {cy 0}} {
    if {[string match "*d" $angle]} {
	set angle [expr {[string range $angle 0 end-1] * 0.017453292519943295}]
    }
    set myCos [expr {cos($angle)}]
    set mySin [expr {sin($angle)}]
    if {$cx == 0 && $cy == 0} {
	return [list [list $myCos $mySin] [list [expr {-1.*$mySin}] $myCos] {0 0}]
    }
    return [list [list $myCos $mySin] [list [expr {-1.*$mySin}] $myCos] \
	[list [expr {$cx - $myCos*$cx + $mySin*$cy}] \
	[expr {$cy - $mySin*$cx - $myCos*$cy}]]]
}

# ::tkp::matrix::scale --
# Arguments:
#	sx	Scaling factor x-coordinate
#	sy	Scaling factor y-coordinate
# Results:
#       The transformation matrix.
proc ::tkp::matrix::scale {sx {sy {}}} {
    if {$sy eq {}} {set sy $sx}
    return [list [list $sx 0] [list 0 $sy] {0 0}]
}

# ::tkp::matrix::flip --
# Arguments:
#	fx	1 no flip, -1 horizontal flip
#	fy	1 no flip, -1 vertical flip
# Results:
#       The transformation matrix.
proc ::tkp::matrix::flip {{cx 0} {cy 0} {fx 1} {fy 1}} {
    return [list [list $fx 0] [list 0 $fy] \
	[list [expr {$cx*(1.-$fx)}] [expr {$cy*(1.-$fy)}]]]
}

# ::tkp::matrix::rotateflip --
# Arguments:
#	angle	Angle in radians or degrees (with "d" suffix)
#	cx	X-center coordinate
#	cy	Y-center coordinate
#	fx	1 no flip, -1 horizontal flip
#	fy	1 no flip, -1 vertical flip
# Results:
#       The transformation matrix.
proc ::tkp::matrix::rotateflip {{angle 0} {cx 0} {cy 0} {fx 1} {fy 1}} {
    if {[string match "*d" $angle]} {
	set angle [expr {[string range $angle 0 end-1] * 0.017453292519943295}]
    }
    set myCos [expr {cos($angle)}]
    set mySin [expr {sin($angle)}]
    if {$cx == 0 && $cy == 0} {
	return [list [list [expr {$fx*$myCos}] [expr {$fx*$mySin}]] \
	    [list [expr {-1.*$mySin*$fy}] [expr {$myCos*$fy}]] {0 0}]
    }
    return [list [list [expr {$fx*$myCos}] [expr {$fx*$mySin}]] \
	[list [expr {-1.*$mySin*$fy}] [expr {$myCos*$fy}]] \
        [list \
       	[expr {$myCos*$cx*(1.-$fx) - $mySin*$cy*(1.-$fy) + $cx - $myCos*$cx + $mySin*$cy}] \
        [expr {$mySin*$cx*(1.-$fx) + $myCos*$cy*(1.-$fy) + $cy - $mySin*$cx - $myCos*$cy}] \
	]]

}

# ::tkp::matrix::skewx --
# Arguments:
#	angle	Angle in radians or degrees (with "d" suffix)
# Results:
#       The transformation matrix.
proc ::tkp::matrix::skewx {angle} {
    if {[string match "*d" $angle]} {
	set angle [expr {[string range $angle 0 end-1] * 0.017453292519943295}]
    }
    return [list {1 0} [list [expr {tan($angle)}] 1] {0 0}]
}

# ::tkp::matrix::skewy --
# Arguments:
#	angle	Angle in radians or degrees (with "d" suffix)
# Results:
#       The transformation matrix.
proc ::tkp::matrix::skewy {angle} {
    if {[string match "*d" $angle]} {
	set angle [expr {[string range $angle 0 end-1] * 0.017453292519943295}]
    }
    return [list [list 1 [expr {tan($angle)}]] {0 1} {0 0}]
}

# ::tkp::matrix::move --
# Arguments:
#	dx	Difference in x direction
#	dy	Difference in y direction
# Results:
#       The transformation matrix.
proc ::tkp::matrix::move {dx dy} {
    return [list {1 0} {0 1} [list $dx $dy]]
}

# ::tkp::matrix::mult --
# Arguments:
# 	ma	First matrix
# 	mb	Second matrix
# Results:
#       Product of transformation matrices.
proc ::tkp::matrix::mult {ma mb} {
    foreach {ma1 ma2 ma3} $ma {mb1 mb2 mb3} $mb {
	lassign $ma1 a1 b1
	lassign $ma2 c1 d1
	lassign $ma3 x1 y1
	lassign $mb1 a2 b2
	lassign $mb2 c2 d2
	lassign $mb3 x2 y2
    }
    return [list \
	[list [expr {$a1*$a2 + $c1*$b2}] [expr {$b1*$a2 + $d1*$b2}]] \
	[list [expr {$a1*$c2 + $c1*$d2}] [expr {$b1*$c2 + $d1*$d2}]] \
	[list [expr {$a1*$x2 + $c1*$y2 + $x1}] [expr {$b1*$x2 + $d1*$y2 + $y1}]]] 
}

# ::tkp::path::cg::deg2rad
# Arguments:
#	a	angle in degrees
# Results:
#	Angle in radians.
proc ::tkp::path::cg::deg2rad a {
    expr {($a < 0 ? 360 + $a : $a) * 0.017453292519943295}
}

# ::tkp::path::cg::rad2deg
# Arguments:
#	a	angle in radians
# Results:
#	Angle in degrees.
proc ::tkp::path::cg::rad2deg a {
    expr {$a * 57.29577951308232}
}

# ::tkp::path::cg::xyad2p
# Arguments:
#	cx	center x coordinate
#	cy	center y coordinate
#	a	angle in radians or degrees (with "d" suffix)
#	d ...	distances
# Results:
#	Return points at given distances on a ray from center x,y to angle a.
proc ::tkp::path::cg::xyad2p {cx cy a d args} {
    if {[string match "*d" $a]} {
	set a [expr {[string range $a 0 end-1] * 0.017453292519943295}]
    }
    lmap d [concat $d $args] {
	list [expr {$cx + $d * cos($a)}] [expr {$cy - $d * sin($a)}]
    }
}

# ::tkp::path::cg::xyra2p
# Arguments:
#	cx	center x coordinate
#	cy	center y coordinate
#	r	radius
#	a	angle in radians or degrees (with "d" suffix)
# Results:
#	Return points forming angle a on a circle with radius r.
proc ::tkp::path::cg::xyra2p {cx cy r a args} {
    if {[string match "*d" $a]} {
	set a [expr {[string range $a 0 end-1] * 0.017453292519943295}]
    }
    lmap a [concat $a $args] {
	list [expr {$cx + $r * cos($a)}] [expr {$cy - $r * sin($a)}]
    }
}

# ::tkp::path::ellipse --
# Arguments:
#	x	Start x coordinate
#	y	Start y coordinate
#	rx	Radius in x direction
#	ry	Radius in y direction
# Results:
#	The path definition.
proc ::tkp::path::ellipse {x y rx ry} {
    return [list M $x $y a $rx $ry 0 1 1 0 [expr {2*$ry}] a $rx $ry 0 1 1 0 [expr {-2*$ry}] Z]
}

# ::tkp::path::circle --
# Arguments:
#	x	Start x coordinate
#	y	Start y coordinate
#	r	Radius of circle
# Results:
#       The path definition.
proc ::tkp::path::circle {x y r} {
    return [list M $x $y a $r $r 0 1 1 0 [expr {2*$r}] a $r $r 0 1 1 0 [expr {-2*$r}] Z]
}

# ::tkp::path::annulus --
# Arguments:
#	cx	Center x coordinate
#	cy	Center y coordinate
#	r1	Radius 1 of annulus
#	r2	Radius 2 of annulus
#	ext	Extending angle in degrees, 0 is east, 90 is north
#	args	Options:
#		-start angle	start angle in degrees
# Results:
#       The path definition of the annulus shape.
proc ::tkp::path::annulus {cx cy r r2 ext args} {
    array set o {
	-start 0
    }
    # merge user input
    array set o $args
    set ext [cg::deg2rad $ext]
    set o(-start) [cg::deg2rad $o(-start)]
    set sweep [expr {abs($ext) != $ext}]
    set la [expr {abs(fmod($ext,6.283185307179586)) > 3.141592653589793}]
    lassign [cg::xyad2p $cx $cy $o(-start) $r $r2] p1 p3
    lassign [cg::xyad2p $cx $cy [expr {$o(-start) + $ext}] $r2 $r] p2 p4
    concat M {*}$p1 A $r $r 0 $la $sweep {*}$p4 L {*}$p2 A $r2 $r2 0 $la [expr {!$sweep}] {*}$p3 L {*}$p1
}

# ::tkp::path::parc --
#	cx	Center x coordinate
#	cy	Center y coordinate
#	r	Radius of arc
#	ext	Extending angle in degrees, 0 is east, 90 is north
#	args	Options:
#		-start angle	start angle in degrees
#		-style style 	'piesclice', 'chord', or 'arc'
# Arguments:
#       The path definition of the arc shape.
proc ::tkp::path::parc {cx cy r ext args} {
    array set o {
	-start 0
	-style pieslice
    }
    # merge user input
    array set o $args
    set ext [cg::deg2rad $ext]
    set o(-start) [cg::deg2rad $o(-start)]
    set sweep [expr {abs($ext) != $ext}]
    set la [expr {abs(fmod($ext,6.283185307179586)) > 3.141592653589793}]
    lassign [cg::xyra2p $cx $cy $r $o(-start) [expr {$o(-start) + $ext}]] p1 p2
    if {[string match "pie*" $o(-style)]} {
	concat M $cx $cy L {*}$p1 A $r $r 0 $la $sweep {*}$p2 Z
    } else {
	# unknown styles are plotted as simple arcs
	set z [expr {[string match "cho*" $o(-style)]? "Z" : ""}]
	concat M {*}$p1 A $r $r 0 $la $sweep {*}$p2 $z
    }
}

# ::tkp::gradientstopsstyle --
#       Utility function to create named example gradient definitions.
# Arguments:
#       name      the name of the gradient
#       args
# Results:
#       The stops list.
proc ::tkp::gradientstopsstyle {name args} {
    switch -- $name {
	rainbow {
	    return {
		{0.00 "#ff0000"}
		{0.15 "#ff7f00"}
		{0.30 "#ffff00"}
		{0.45 "#00ff00"}
		{0.65 "#0000ff"}
		{0.90 "#7f00ff"}
		{1.00 "#7f007f"}
	    }
	}
	default {
	    return -code error "the named gradient '$name' is unknown"
	}
    }
}
