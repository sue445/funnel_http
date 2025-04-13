package main_test

import (
	"github.com/cockroachdb/errors"
	"github.com/jarcoal/httpmock"
	"github.com/stretchr/testify/assert"
	"github.com/sue445/funnel_http"
	"io"
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

	httpmock.RegisterResponder("POST", "http://example.com/1",
		func(req *http.Request) (*http.Response, error) {
			payload, err := io.ReadAll(req.Body)
			if err != nil {
				return nil, errors.WithStack(err)
			}

			resp := httpmock.NewStringResponse(200, string(payload))

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
			name: "GET 1 request",
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
					URL:        "http://example.com/1",
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
			name: "GET multiple requests",
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
					URL:        "http://example.com/1",
					StatusCode: 200,
					Body:       []byte("GET http://example.com/1"),
					Header: map[string][]string{
						"Content-Type":        {"text/plain"},
						"X-My-Request-Header": {"a", "b"},
					},
				},
				{
					URL:        "http://example.com/2",
					StatusCode: 200,
					Body:       []byte("GET http://example.com/2"),
					Header: map[string][]string{
						"Content-Type":        {"text/plain"},
						"X-My-Request-Header": {"c", "d"},
					},
				},
			},
		},
		{
			name: "POST 1 request",
			requests: []main.Request{
				{
					Method: "POST",
					URL:    "http://example.com/1",
					Header: map[string][]string{
						"X-My-Request-Header": {"a", "b"},
					},
					Body: []byte("111"),
				},
			},
			expected: []main.Response{
				{
					URL:        "http://example.com/1",
					StatusCode: 200,
					Body:       []byte("111"),
					Header: map[string][]string{
						"Content-Type":        {"text/plain"},
						"X-My-Request-Header": {"a", "b"},
					},
				},
			},
		},
		{
			name: "POST multiple requests",
			requests: []main.Request{
				{
					Method: "POST",
					URL:    "http://example.com/1",
					Header: map[string][]string{
						"X-My-Request-Header": {"a", "b"},
					},
					Body: []byte("111"),
				},
				{
					Method: "POST",
					URL:    "http://example.com/1",
					Header: map[string][]string{
						"X-My-Request-Header": {"c", "d"},
					},
					Body: []byte("222"),
				},
			},
			expected: []main.Response{
				{
					URL:        "http://example.com/1",
					StatusCode: 200,
					Body:       []byte("111"),
					Header: map[string][]string{
						"Content-Type":        {"text/plain"},
						"X-My-Request-Header": {"a", "b"},
					},
				},
				{
					URL:        "http://example.com/1",
					StatusCode: 200,
					Body:       []byte("222"),
					Header: map[string][]string{
						"Content-Type":        {"text/plain"},
						"X-My-Request-Header": {"c", "d"},
					},
				},
			},
		},
	}

	httpClient := http.Client{}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			actual, err := main.RunRequests(&httpClient, tt.requests)
			if assert.NoError(t, err) {
				assert.Equal(t, tt.expected, actual)
			}
		})
	}
}
