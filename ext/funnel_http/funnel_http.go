package main

/*
#include "funnel_http.h"

VALUE rb_go_data_alloc(VALUE klass);
VALUE rb_funnel_http_run_requests(VALUE self, VALUE rbAry);
*/
import "C"

import (
	"github.com/ruby-go-gem/go-gem-wrapper/ruby"
	"net/http"
	"unsafe"
)

//export rb_funnel_http_run_requests
func rb_funnel_http_run_requests(self C.VALUE, rbAry C.VALUE) C.VALUE {
	rbAryLength := int(ruby.RARRAY_LEN(ruby.VALUE(rbAry)))
	requests := make([]Request, 0, rbAryLength)

	for i := 0; i < rbAryLength; i++ {
		rbHash := ruby.RbAryEntry(ruby.VALUE(rbAry), ruby.Long(i))

		req := Request{
			Method: getRbHashValueAsString(rbHash, "method"),
			URL:    getRbHashValueAsString(rbHash, "url"),
			Header: getRbHashValueAsMap(rbHash, "header"),
		}
		requests = append(requests, req)
	}

	httpClient := getHttpClientFromInstanceVariable(ruby.VALUE(self))

	responses, err := RunRequests(&httpClient, requests)
	if err != nil {
		ruby.RbRaise(rb_cFunnelHttpError, "%s", err.Error())
	}

	var rbHashSlice []ruby.VALUE
	for _, response := range responses {
		rbHash := ruby.RbHashNew()

		ruby.RbHashAset(rbHash, ruby.RbId2Sym(ruby.RbIntern("status_code")), ruby.INT2NUM(response.StatusCode))
		ruby.RbHashAset(rbHash, ruby.RbId2Sym(ruby.RbIntern("body")), ruby.String2Value(string(response.Body)))

		rbHashHeader := ruby.RbHashNew()
		ruby.RbGcRegisterAddress(&rbHashHeader)
		defer ruby.RbGcUnregisterAddress(&rbHashHeader)

		for key, values := range response.Header {
			var headerValues []ruby.VALUE
			for _, value := range values {
				v := ruby.String2Value(value)
				ruby.RbGcRegisterAddress(&v)
				defer ruby.RbGcUnregisterAddress(&v)

				headerValues = append(headerValues, v)
			}
			k := ruby.String2Value(key)
			ruby.RbGcRegisterAddress(&k)
			defer ruby.RbGcUnregisterAddress(&k)

			v := ruby.Slice2rbAry(headerValues)
			ruby.RbGcRegisterAddress(&v)
			defer ruby.RbGcUnregisterAddress(&v)

			ruby.RbHashAset(rbHashHeader, k, v)
		}
		ruby.RbHashAset(rbHash, ruby.RbId2Sym(ruby.RbIntern("header")), rbHashHeader)

		rbHashSlice = append(rbHashSlice, rbHash)
	}

	return C.VALUE(ruby.Slice2rbAry(rbHashSlice))
}

func getHttpClientFromInstanceVariable(self ruby.VALUE) http.Client {
	id := ruby.RbIntern("@__go_data")
	value := ruby.RbIvarGet(self, id)

	if !ruby.RB_NIL_P(value) {
		// return http.Client in instance variable
		data := (*goData)(ruby.GetGoStruct(value))
		return data.httpClient
	}

	// Create instance of FunnelHttp::Ext::GoData
	obj := ruby.RbObjAlloc(rb_cFunnelHttpExtGoData)
	data := ruby.GetGoStruct(obj)

	// Save FunnelHttp::Ext::GoData to instance variable of FunnelHttp::Ext::Client
	dataValue := (*ruby.VALUE)(data)
	ruby.RbIvarSet(self, id, *dataValue)

	return ((*goData)(data)).httpClient
}

type goData struct {
	httpClient http.Client
}

//export rb_go_data_alloc
func rb_go_data_alloc(klass C.VALUE) C.VALUE {
	data := goData{}
	return C.VALUE(ruby.NewGoStruct(ruby.VALUE(klass), unsafe.Pointer(&data)))
}

func getRbHashValueAsString(rbHash ruby.VALUE, key string) string {
	value := ruby.RbHashAref(rbHash, ruby.RbToSymbol(ruby.String2Value(key)))
	return ruby.Value2String(value)
}

func getRbHashValueAsMap(rbHash ruby.VALUE, key string) map[string][]string {
	rbHashValue := ruby.RbHashAref(rbHash, ruby.RbToSymbol(ruby.String2Value(key)))
	rbKeys := ruby.CallFunction(rbHashValue, "keys")

	var ret = map[string][]string{}

	for i := 0; i < int(ruby.RARRAY_LEN(rbKeys)); i++ {
		rbKey := ruby.RbAryEntry(rbKeys, ruby.Long(i))
		rbAryValue := ruby.RbHashAref(rbHashValue, rbKey)

		var values []string
		for j := 0; j < int(ruby.RARRAY_LEN(rbAryValue)); j++ {
			str := ruby.Value2String(ruby.RbAryEntry(rbAryValue, ruby.Long(j)))
			values = append(values, str)
		}

		keyName := ruby.Value2String(rbKey)
		ret[keyName] = values
	}

	return ret
}

// revive:disable:exported

var rb_cFunnelHttpError ruby.VALUE
var rb_cFunnelHttpExtGoData ruby.VALUE

//export Init_funnel_http
func Init_funnel_http() {
	rb_mFunnelHttp := ruby.RbDefineModule("FunnelHttp")

	// FunnelHttp::Ext
	rb_mFunnelHttpExt := ruby.RbDefineModuleUnder(rb_mFunnelHttp, "Ext")

	// FunnelHttp::Ext::Client
	rb_cFunnelHttpExtClient := ruby.RbDefineClassUnder(rb_mFunnelHttpExt, "Client", ruby.VALUE(C.rb_cObject))
	ruby.RbDefineMethod(rb_cFunnelHttpExtClient, "run_requests", C.rb_funnel_http_run_requests, 1)

	// FunnelHttp::Ext::GoData
	rb_cFunnelHttpExtGoData = ruby.RbDefineClassUnder(rb_mFunnelHttpExt, "GoData", ruby.VALUE(C.rb_cObject))
	ruby.RbDefineAllocFunc(rb_cFunnelHttpExtGoData, C.rb_go_data_alloc)

	// FunnelHttp::Error
	rb_cFunnelHttpError = ruby.RbDefineClassUnder(rb_mFunnelHttp, "Error", ruby.VALUE(C.rb_eStandardError))
}

// revive:enable:exported

func main() {
}
