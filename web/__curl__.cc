#include <octave/oct.h>
#include "libcurl_wrapper.cc"

DEFUN_DLD (__curl__, args, , "Some __curl__ demo.")
{
  if (args.length () != 1)
    print_usage ();

  auto a = libcurl_wrapper::create();
  a.setURL (args (0).string_value ());
  a.perform ();

  return octave_value (a.getEFFECTIVE_URL ());
}
