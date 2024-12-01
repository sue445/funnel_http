package main_test

import (
	"github.com/jarcoal/httpmock"
	"github.com/stretchr/testify/assert"
	"github.com/sue445/funnel_http"
	"net/http"
	"testing"
)

func TestRunRequests(t *testing.T) {
	httpmock.Activate()
	t.Cleanup(httpmock.DeactivateAndReset)

	httpmock.RegisterResponder("GET", "http://example.com/1",
		func(req *http.Request) (*http.Response, error) {
			resp := httpmock.NewStringResponse(200, "GET http://example.com/1")

			resp.Header.Set("Content-Type", "text/plain")

			for key, values := range req.Header {
				for _, value := range values {
					resp.Header.Add(key, value)
				}
			}

			return resp, nil
		})

	httpmock.RegisterResponder("GET", "http://example.com/2",
		func(req *http.Request) (*http.Response, error) {
			resp := httpmock.NewStringResponse(200, "GET http://example.com/2")

			resp.Header.Set("Content-Type", "text/plain")

			for key, values := range req.Header {
				for _, value := range values {
					resp.Header.Add(key, value)
				}
			}

			return resp, nil
		})

	tests := []struct {
		name     string
		requests []main.Request
		expected []main.Response
	}{
		{
			name: "1 request",
			requests: []main.Request{
				{
					Method: "GET",
					URL:    "http://example.com/1",
					Header: map[string][]string{
						"X-My-Request-Header": {"a", "b"},
					},
				},
			},
			expected: []main.Response{
				{
					StatusCode: 200,
					Body:       []byte("GET http://example.com/1"),
					Header: map[string][]string{
						"Content-Type":        {"text/plain"},
						"X-My-Request-Header": {"a", "b"},
					},
				},
			},
		},
		{
			name: "multiple requests",
			requests: []main.Request{
				{
					Method: "GET",
					URL:    "http://example.com/1",
					Header: map[string][]string{
						"X-My-Request-Header": {"a", "b"},
					},
				},
				{
					Method: "GET",
					URL:    "http://example.com/2",
					Header: map[string][]string{
						"X-My-Request-Header": {"c", "d"},
					},
				},
			},
			expected: []main.Response{
				{
					StatusCode: 200,
					Body:       []byte("GET http://example.com/1"),
					Header: map[string][]string{
						"Content-Type":        {"text/plain"},
						"X-My-Request-Header": {"a", "b"},
					},
				},
				{
					StatusCode: 200,
					Body:       []byte("GET http://example.com/2"),
					Header: map[string][]string{
						"Content-Type":        {"text/plain"},
						"X-My-Request-Header": {"c", "d"},
					},
				},
			},
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			actual, err := main.RunRequests(tt.requests)
			if assert.NoError(t, err) {
				assert.Equal(t, tt.expected, actual)
			}
		})
	}
}