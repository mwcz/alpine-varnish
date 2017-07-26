#
# This is an example VCL file for Varnish.
#
# It does not do anything by default, delegating control to the
# builtin VCL. The builtin VCL is called when there is no explicit
# return statement.
#
# See the VCL chapters in the Users Guide at https://www.varnish-cache.org/docs/
# and https://www.varnish-cache.org/trac/wiki/VCLExamples for more examples.

# Marker to tell the VCL compiler that this VCL has been adapted to the
# new 4.0 format.
vcl 4.0;

import std;

# Default backend definition. Set this to point to your content server.
backend default {
    .host = "{{ APP_IP }}";
    .port = "{{ APP_PORT }}";
}

backend chrome {
    .host = "172.27.1.50";
    .port = "80";
}


sub vcl_recv {
    # Happens before we check if we have this in cache already.
    #
    # Typically you clean up the request here, removing cookies you don't need,
    # rewriting the request, etc.

    if(req.url ~ "/services/chrome") {
        set req.backend_hint = chrome;
    }
    else {
        set req.backend_hint = default;
    }
}

sub vcl_backend_response {
    # Happens after we have read the response headers from the backend.
    #
    # Here you clean the response headers, removing silly Set-Cookie headers
    # and other mistakes your backend does.

    if (beresp.status == 503 && bereq.retries < 5) {
        return(retry);
    }

    set beresp.do_esi = true;
    set beresp.ttl = 0m;
}

sub vcl_backend_error {
    if (beresp.status == 503 && bereq.retries == 5) {
        synthetic(std.fileread("/etc/varnish/503.html"));
        return(deliver);
    }
}

sub vcl_synth {
    if (resp.status == 503) {
        synthetic(std.fileread("/etc/varnish/503.html"));
        return(deliver);
    }
}

sub vcl_deliver {
    if (resp.status == 503) {
        return(restart);
    }
}

sub vcl_deliver {
    # Happens when we have all the pieces we need, and are about to send the
    # response to the client.
    #
    # You can do accounting or modifying the final object here.
}
