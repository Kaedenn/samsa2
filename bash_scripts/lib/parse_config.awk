
BEGIN {
  if (V=="") {
    print "Expected V variable to be set"
    exit 1
  }
  if (DEF_VAL=="") {
    DEF_VAL = "undef"
  }
}
/^[ ]*#/{ next }
/^[ ]*$/{ next }

$1==V {
  value = substr($0, index($0, "=")+1)
  if (value == "true") {
    print 1
  } else if (value == "false") {
    print ""
  } else if (value == "") {
    print DEF_VAL
  } else {
    print value
  }
}
