package main

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
	Body       string
}

// RunRequests perform HTTP requests in parallel
func RunRequests(requests []Request) ([]Response, error) {
	return []Response{}, nil
}
