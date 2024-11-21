package main

import (
	"bytes"
	"github.com/cockroachdb/errors"
	"golang.org/x/sync/errgroup"
	"io"
	"net/http"
)

// Request is proxy between CRuby and Go
type Request struct {
	Method string
	URL    string
	Header map[string][]string
}

// Response is proxy between CRuby and Go
type Response struct {
	StatusCode int
	Header     map[string][]string
	Body       []byte
}

// RunRequests perform HTTP requests in parallel
func RunRequests(requests []Request) ([]Response, error) {
	g := new(errgroup.Group)
	responses := make([]Response, len(requests))

	httpClient := &http.Client{}

	for i, request := range requests {
		// https://golang.org/doc/faq#closures_and_goroutines
		i := i
		request := request

		g.Go(func() error {
			var body []byte
			httpReq, err := http.NewRequest(request.Method, request.URL, bytes.NewBuffer(body))
			if err != nil {
				return errors.WithStack(err)
			}

			for key, values := range request.Header {
				for _, value := range values {
					httpReq.Header.Add(key, value)
				}
			}

			httpResp, err := httpClient.Do(httpReq)
			if err != nil {
				return errors.WithStack(err)
			}
			defer httpResp.Body.Close()

			responses[i].StatusCode = httpResp.StatusCode

			buf, err := io.ReadAll(httpResp.Body)
			if err != nil {
				return errors.WithStack(err)
			}

			responses[i].Body = buf
			responses[i].Header = map[string][]string{}

			for key, values := range httpResp.Header {
				for _, value := range values {
					responses[i].Header[key] = append(responses[i].Header[key], value)
				}
			}

			return nil
		})
	}

	if err := g.Wait(); err != nil {
		return []Response{}, errors.WithStack(err)
	}

	return responses, nil
}
