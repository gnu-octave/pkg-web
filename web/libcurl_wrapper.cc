/*

Copyright (C) 2017 Kai T. Ohlhus <k.ohlhus@gmail.com>

This file is part of Octave.

Octave is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

Octave is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Octave; see the file COPYING.  If not, see
<http://www.gnu.org/licenses/>.

*/

//#if defined (HAVE_CURL)
#  include <curl/curl.h>
#  include <curl/curlver.h>
#  include <curl/easy.h>
//#endif

#include <octave/oct.h>

class libcurl_wrapper {
private:
  CURL* curl;  //! curl instance
  char errbuf[CURL_ERROR_SIZE]; //! curl error buffer

  //! Throw an Octave error and print message and code from libcurl
  void curl_error (CURLcode c) {
    if(c != CURLE_OK) {
      error ("libcurl (code = %d): %s\n", c, curl_easy_strerror (c));
    }
  }

protected:
  libcurl_wrapper () : curl(curl_easy_init ()) {
    std::cout << "libcurl_wrapper: new instance" << std::endl;
  }

public:
  //! Static factory method
  static libcurl_wrapper create () {
    libcurl_wrapper obj;
    // default error buffer is that of the object itself
    obj.setERRORBUFFER (obj.errbuf);
    obj.setVERBOSE (true);
    return obj;
  }

  //! Destructor
  ~libcurl_wrapper() {
    if (curl) {
      curl_easy_cleanup (curl);
    }
    std::cout << "libcurl_wrapper: destruct" << std::endl;
  }

  //! Wrapper for curl_easy_perform
  void perform () {
    curl_error (curl_easy_perform (curl));
  }

  //! BEHAVIOR OPTIONS
  //! set verbose mode on (true) /off (false)
  void setVERBOSE (bool b) {
    curl_error (curl_easy_setopt (curl, CURLOPT_VERBOSE, (b ? 1L : 0L)));
  }

  //! ERROR OPTIONS
  //! set error buffer for error messages
  void setERRORBUFFER (char* buf) {
    curl_error (curl_easy_setopt (curl, CURLOPT_ERRORBUFFER, buf));
  }

  //! NETWORK OPTIONS
  //! provide the URL to use in the request
  void setURL (std::string url) {
    curl_error (curl_easy_setopt (curl, CURLOPT_URL, url.c_str ()));
  }

  //! GETINFO
  //! get the last used URL
  std::string getEFFECTIVE_URL () {
    char* urlp;
    std::string s;
    curl_error (curl_easy_getinfo (curl, CURLINFO_EFFECTIVE_URL, &urlp));
    if (urlp) {
      return std::string (urlp);
    }
    return "";
  }
};

DEFUN_DLD (__curl__, args, , "Add A to B")
{
  if (args.length () != 1)
    print_usage ();

  auto a = libcurl_wrapper::create();
  a.setURL ("http://example.com");
  a.perform ();

  return octave_value (a.getEFFECTIVE_URL ());
}
