proc errMsgImage { imgName } {
    if { [string index $::tk_version 0] eq "9" } {
	return "image \"$imgName\" does not exist"
    } else {
	return "image \"$imgName\" doesn't exist"
    }
}

proc errMsgBadDistance { distance } {
    if { [string index $::tk_version 0] eq "9" } {
        return "expected screen distance but got \"$distance\""
    } else {
        return "bad screen distance \"$distance\""
    }
} 

