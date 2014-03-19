# encoding=UTF-8

import urllib
import httplib
import urlparse
import base64

class Response(object):
    """HTTP response to encapsulates status code (200, 404, as an integer), 
    message (such as 'OK', 'Not Found', as a string), headers (as a 
    dictionnary), and body (as a string)."""

    def __init__(self, status, message, headers={}, body=None):
        self.status = status
        self.message = message
        self.headers = headers
        self.body = body

    def __str__(self):
        if self.body:
            _body = str(self.body).strip().replace('\n', '\\n')
            if len(_body) > 100:
                _body = _body[:97]+'...'
        else:
            _body = ''
        return "Response(status=%s, message='%s', headers=%s, body='%s')" %\
            (self.status, self.message, self.headers, _body)

def request(url, params={}, method='GET', body=None, headers={},
            content_type=None, content_length=True,
            username=None, password=None, capitalize_headers=True):
    """Perform a http_request:
    - url: the URL call, including protocol and parameters (such as
      'http://www.google.com?foo=1&bar=2').
    - params: URL parameters as a map, so that {'foo': 1, 'bar': 2} will result
      in an URL ending with '?foo=1&bar=2'.
    - method: the HTTP method (such as 'GET' or 'POST'). Defaults to 'GET'.
    - body: the body of the request as a string. Defaults to None.
    - headers: request headers as a dictionnary. Defaults to '{}'.
    - content_type: the content type header of the request. Defauls to None.
    - content_lenth: tells if we should add content length headers to the
      request. Defaults to true.
    - username: username while performing basic authentication, must be set
      with password.
    - password: password while performing basic authentication, must be set
      with username.
    Returns the response as a Response object. NOTE: to call HTTPS URLs, 
    Python must have been built with SSL support."""
    _urlparts = urlparse.urlparse(url)
    _host = _urlparts.netloc
    _params = ''
    if len(_urlparts.query) > 0:
        _params = _urlparts.query
    if len(params) > 0:
        if len(_params) > 0:
            _params += '&'
        _params += urllib.urlencode(params)
    _path = _urlparts.path
    if len(_params) > 0:
        _path += '?'
        _path += _params
    _https = (_urlparts.scheme == 'https')
    _headers = {}
    for _name in headers:
        _headers[str(_name)] = str(headers[_name])
    if content_type:
        _headers['Content-Type'] = str(content_type)
    if content_length:
        if body:
            _headers['Content-Length'] = str(len(body))
        else:
            _headers['Content-Length'] = '0'
    if username and password:
        authorization = "Basic %s" % base64.b64encode(("%s:%s" % (username, password)))
        _headers['Authorization'] = authorization
    _capitalized_headers = {}
    if capitalize_headers:
        for _name in _headers:
            _capitalized = '-'.join(map(lambda s: s.capitalize(), _name.split('-'))) #pylint: disable=W0141
            _capitalized_headers[_capitalized] =_headers[_name]
        _headers = _capitalized_headers
    if _https:
        connection = httplib.HTTPSConnection(_host)
    else:
        connection = httplib.HTTPConnection(_host)
    connection.request(method, _path, body, _headers)
    _response = connection.getresponse()
    # method getheaders() not available in Python 2.2.1
    _response_headers = {}
    _pairs = _response.msg.items()
    if _pairs:
        for _pair in _pairs:
            _name = _pair[0]
            _value = _pair[1]
            if capitalize_headers:
                _name = '-'.join(map(lambda s: s.capitalize(), _name.split('-'))) #pylint: disable=W0141
            _response_headers[_name] = _value
    return Response(status=_response.status,
                    message=_response.reason,
                    headers=_response_headers,
                    body=_response.read())

