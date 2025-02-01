#! config/_ytt_lib/distro/distro_lookup.star
#!   Looks up a distribution definition by name.
#!
#!   (this is a ytt-flavored Starlark file: https://carvel.dev/ytt/docs/v0.51.0/lang/#overview)

def lookup_distro_definition(distro_definitions, distribution):
  distros = [
    distro for distro in distro_definitions 
      if distro.distribution == distribution
  ]
  if len(distros) == 0:
    fail("could not find distro definition for \"" + distribution + "\" in data value \"distro_definitions\"; is there a distro/definitions/" + distribution + ".yml file?")
  end

  return distros[0]
end
