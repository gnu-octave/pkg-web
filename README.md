# octave-web

Reimplement [GNU Octave's](https://www.octave.org) web functions compatible to
[Matlab's RESTful web services](https://www.mathworks.com/help/matlab/internet-file-access.html).

# Octave's state of the art.

Currently, Octave supports Matlab's deprecated web interface functions
[urlread](https://www.gnu.org/software/octave/doc/interpreter/XREFurlread)
and
[urlwrite](https://www.gnu.org/software/octave/doc/interpreter/XREFurlwrite):

    [S, SUCCESS, MESSAGE] = urlread  (URL, METHOD, PARAM)
    [F, SUCCESS, MESSAGE] = urlwrite (URL, LOCALFILE)

both defined in
[`libinterp/corefcn/urlwrite.cc`](http://hg.savannah.gnu.org/hgweb/octave/file/d52aa3a2794a/libinterp/corefcn/urlwrite.cc)
alongside the
[FTP](https://www.gnu.org/software/octave/doc/interpreter/FTP-Objects.html)
class functions of Octave:

    handle = __ftp__ (host, username, password)  % New FTP-connection.
    pwd =  __ftp_pwd__  (handle)   % Print host's working directory.
    list = __ftp_dir__  (handle)   % List working directory content.
    mode = __ftp_mode__ (handle)   % Query transfer mode.
    __ftp_ascii__  (handle)        % Set transfer mode to ASCII.
    __ftp_binary__ (handle)        % Set transfer mode to binary.
    __ftp_close__  (handle)        % Close FTP-connection.
    __ftp_cwd__    (handle, path)  % Change host's working directory to `path`.
    __ftp_delete__ (handle, path)  % Delete file `path` at host.
    __ftp_rmdir__  (handle, path)  % Delete directory `path` at host.
    __ftp_mkdir__  (handle, path)  % Create directory `path` at host.
    __ftp_rename__ (handle, old, new)  % Rename `old` to `new` at host.
    __ftp_mput__ (handle, pattern)  % Upload files matching `pattern` to host.
    % Download files matching `pattern` from host to local `target` directory.
    __ftp_mget__ (handle, pattern, target)

All those functions above are realized by the
[libcurl](https://curl.haxx.se/libcurl/c/curl_easy_init.html)
wrapper classes:

    +----------------------+     +---------------------------+
    | octave::url_transfer | --> | octave::base_url_transfer |
    +----------------------+     +---------------------------+
                                               A
                                               |
                                   +-----------------------+
                                   | octave::curl_transfer |
                                   +-----------------------+

Those are implemented inside
[`liboctave/util/url-transfer.[h/cc]`](http://hg.savannah.gnu.org/hgweb/octave/file/d52aa3a2794a/liboctave/util/url-transfer.h).

The current access to web connections (for example for FTP-objects) is given by
a `octave::url_handle_manager` implemented in
[`libinterp/corefcn/url-handle-manager.[h/cc]`](http://hg.savannah.gnu.org/hgweb/octave/file/d52aa3a2794a/libinterp/corefcn/url-handle-manager.h).

Another player in connecting to the web is the **GUI**.  It provides a checkbox,
whether Octave should be able to connect to the web for obtaining news from the
community and provides settings for an HTTP-Proxy, that up to my knowledge are
nowhere used.  It should be stated clearly, that those options have no influence
on the rest of Octave.  For connecting to the web, the GUI uses
[`octave::url_transfer`](http://hg.savannah.gnu.org/hgweb/octave/file/d52aa3a2794a/libgui/src/main-window.cc#l2752)
directly as well.


# Things to improve

* Octave should become more **Matlab compatible** by implementing the
  [RESTful](https://en.wikipedia.org/wiki/Representational_state_transfer)
  web services.
  * This enables web request using cookies.
* The **security** sensible web access should not spread across two libraries
  `liboctave` and `libinterp`.
  * Everything should go into `libinterp`.
  * It should be possible to opt it's functionality out, even after Octave was
    built, without making it useless.
* The web access should be implemented as *m-files*:
  * Web access is much slower than interpreting *m-files* ==> no performance
    killer.
  * Great flexibility is gained:
    * Security evaluation by human readable actions, not compiled libraries.
    * Possibility to debug.
    * Adaption of code without waiting for the next release.


# The intended design

According to the
[Matlab documentation](https://www.mathworks.com/help/matlab/internet-file-access.html),
the RESTful web services consist of the following files:

* `[status, handle, url] = web (url, option1, ..., optionN)` --
  Open web page or file in system or builtin browser.
* `[data, cmap, alpha] = webread (url, QueryKey1, QueryVal1, ..., QueryKeyN,
  QueryValN, options)` -- Read content from RESTful web service.
* `response = webwrite (url, PostKey1, PostVal1, ..., PostKeyN, PostValN,
  options)` -- Write data to RESTful web service.
* `outfilename = websave (filename, url, QueryKey1, QueryVal1, ..., QueryKeyN,
  QueryValN, options)` -- Save content from RESTful web service to file.
* `options = weboptions (Key, Value)` -- Specify parameters for RESTful web
  service.
* `sendmail (recipients, subject, message, attachments)` -- Send email message
  to address list.
* `ftp` -- Like Octave's current
  [FTP](https://www.gnu.org/software/octave/doc/interpreter/FTP-Objects.html).

With this in mind, I would prefer an architecture like this:

    +--------------+--------------+-------------+---------+--------------+
    |  urlread.m   |  urlwrite.m  |             |         |              |
    | (deprecated) | (deprecated) |             |         |              |
    +--------------+--------------+             |         |              |
    |  webread.m   |  webwrite.m  |  websave.m  |  ftp.m  |  sendmail.m  |
    +--------------+--------------+-------------+         |              |
    |                weboptions.m               |         |              |
    +-------------------------------------------+---------+--------------+
    |  libinterp/corefun/libcurl_wrapper.cc                              |
    |   |- handle = __curl_easy_init__ ()                                |
    |   |- __curl_easy_cleanup__ (handle)                                |
    |   |- __curl_easy_setopt__ (handle, option, param)                  |
    |   |- __curl_easy_perform__ (handle)                                |
    |   +- __curl_easy_getinfo__ (handle, option)                        |
    +--------------------------------------------------------------------+

Where all *m-files* are located in the foldes `scripts\web` or
`scripts/deprecated`, respectively.
