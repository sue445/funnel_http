package main_test

import (
	"github.com/stretchr/testify/assert"
	"github.com/sue445/funnel_http"
	"testing"
)

func TestRunRequests(t *testing.T) {
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
					Body:       "GET http://example.com/1",
					Header:     map[string][]string{},
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
