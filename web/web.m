## Copyright (C) 2017 Kai T. Ohlhus <k.ohlhus@gmail.com>
## 
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*- 
## @deftypefn  {} {} web (@var{url})
## @deftypefnx {} {} web (@var{url}, @var{option1}, @dots{}, @var{optionN})
## @deftypefnx {} {[@var{status}, @var{handle}, @var{url}] =} web (@var{url}, @dots{})
##
## Open @var{url} in browser.  Each option can be one of:
##
## @itemize @bullet
## @item
## @samp{-browser} Opens @var{url} in the default system browser.
##
## @item
## @samp{-new} Unimplemented.  Opens @var{url} in a new Octave browser window.
## Does not apply to the system browser.
##
## @item
## @samp{-noaddressbox} Unimplemented.  Opens @var{url} in the Octave browser
## that does not display the address box.  Does not apply to the system
## browser.
##
## @item
## @samp{-notoolbar} Unimplemented.  Opens @var{url} in the Octave browser
## that does not display a toolbar or address box.  Does not apply to the
## system browser.
##
## @end itemize
##
## The return value @var{status} has one of the values:
##
## @itemize @bullet
## @item
## @samp{0} Found and opened system browser successfully.
##
## @item
## @samp{1} Cannot find the system browser.
##
## @item
## @samp{2} System browser found, but an error occurred.
##
## @end itemize
##
## The return values @var{handle} and @var{url} are currently unimplemented
## but given for compatibility.
##
## @seealso{urlread, urlwrite}
## @end deftypefn

## Author: Kai T. Ohlhus <k.ohlhus@gmail.com>
## Created: 2017-09-24

function [status, handle, ret_url] = web (url, varargin)

if (nargin < 1 || nargout > 3)
  print_usage ();
endif

url = char (url);  # Input validation.
status = 1;        # Assume the worst: cannot find system browser.
handle = [];       # Unimplemented.  Empty handle to Octave web brower.
ret_url = url([]); # Unimplemented.  Empty output with data type of `url`.

use_browser      = false;
use_new          = false;
use_noaddressbox = false;
use_notoolbar    = false;
opts = {"-browser", "-new", "-noaddressbox", "-notoolbar"};
for i = 1:length(varargin)
  switch (validatestring (varargin{i}, opts))
    case "-browser"
      use_browser = true;
    case "-new"
      use_new = true;
    case "-noaddressbox"
      use_noaddressbox = true;
    case "-notoolbar"
      use_notoolbar = true;
    endswitch
endfor

if (use_new)
  warning ("web: The option '-new' is not implemented and has no effect.");
endif
if (use_noaddressbox)
  warning (["web: The option '-noaddressbox' is not implemented and has ", ...
    "no effect."]);
endif
if (use_notoolbar)
  warning (["web: The option '-notoolbar' is not implemented and has no ", ...
    "effect."]);
endif
if (! use_browser)
  warning (["web: Octave does not have a builtin browser yet.  Using ", ...
    "option '-browser' by default."]);
  use_browser = true;
endif

if use_browser
  if ispc ()
    ## Windows is very easy with this.
    status = system (url);
    if status != 0
      status = 2;
    endif
  endif

  if ismac ()
    ## Use open <https://developer.apple.com/library/content/documentation/
    ##           OpenSource/Conceptual/ShellScripting/CommandLInePrimer/
    ##           CommandLine.html#//apple_ref/doc/uid/TP40004268-CH271-SW9>
    status = system (["open ", url]);
    if status != 0
      status = 2;
    endif
  endif

  if isunix ()
    ## Check for xdg-open <https://portland.freedesktop.org/doc/xdg-open.html>
    if (system ("xdg-open --version &> /dev/null") != 0)
      warning (["web: Cannot find the `xdg-open` command.  ", ...
        "Please make sure to have the `xdg-utils` installed on your system."]);
      return;
    endif
    status = system (["xdg-open ", url, " &> /dev/null"]);
    if status != 0
      status = 2;
    endif
  endif
endif

endfunction

%!error
%! web ();

%!error
%! web ("https://www.octave.org", "-invalid_Option");

%!error
%! [a, b, c, d] = web ("https://www.octave.org");