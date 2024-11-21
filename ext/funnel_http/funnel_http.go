package main

/*
#include "funnel_http.h"

VALUE rb_funnel_http_sum(VALUE self, VALUE a, VALUE b);
*/
import "C"

import (
	"github.com/ruby-go-gem/go-gem-wrapper/ruby"
)

//export rb_funnel_http_sum
func rb_funnel_http_sum(_ C.VALUE, a C.VALUE, b C.VALUE) C.VALUE {
	longA := ruby.NUM2LONG(ruby.VALUE(a))
	longB := ruby.NUM2LONG(ruby.VALUE(b))

	sum := longA + longB

	return C.VALUE(ruby.LONG2NUM(sum))
}

// revive:disable:exported

//export Init_funnel_http
func Init_funnel_http() {
	rb_mFunnelHttp := ruby.RbDefineModule("FunnelHttp")
	ruby.RbDefineSingletonMethod(rb_mFunnelHttp, "sum", C.rb_funnel_http_sum, 2)
}

// revive:enable:exported

func main() {
}
